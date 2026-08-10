import 'package:flutter/foundation.dart';

import 'odoo_client.dart';
import 'odoo_connection.dart';
import 'odoo_credentials_store.dart';
import 'odoo_exception.dart';
import 'odoo_repository.dart';

enum OdooConnectionState { loading, needsConnection, connecting, connected, error }

class OdooProvider extends ChangeNotifier {
  OdooProvider({OdooCredentialsStore? store})
      : _store = store ?? const OdooCredentialsStore();

  final OdooCredentialsStore _store;

  OdooConnectionState _state = OdooConnectionState.loading;
  OdooConnection? _connection;
  OdooClient? _client;
  OdooRepository? _repository;
  OdooConnectionDiagnostic? _diagnostic;
  OdooException? _error;
  OdooPosConfig? _selectedPosConfig;
  List<OdooCategory> _categories = const [];
  List<OdooProduct> _products = const [];
  bool _demoMode = false;
  bool _loadingProducts = false;

  OdooConnectionState get state => _state;
  OdooConnection? get connection => _connection;
  OdooConnectionDiagnostic? get diagnostic => _diagnostic;
  OdooException? get error => _error;
  OdooPosConfig? get selectedPosConfig => _selectedPosConfig;
  List<OdooCategory> get categories => _categories;
  List<OdooProduct> get products => _products;
  bool get isDemoMode => _demoMode;
  bool get isConnected => _state == OdooConnectionState.connected;
  bool get isLoadingProducts => _loadingProducts;

  Future<void> initialize() async {
    try {
      _connection = await _store.readConnection();
      final apiKey = await _store.readApiKey();
      if (_connection == null || apiKey == null || apiKey.isEmpty) {
        if (kDebugMode && _debugConnectionReady) {
          await connect(
            baseUrl: _debugUrl,
            username: _debugUsername,
            apiKey: _debugApiKey,
            database: _debugDatabase,
          );
          return;
        }
        _state = OdooConnectionState.needsConnection;
        notifyListeners();
        return;
      }
      await _connect(_connection!, apiKey, persist: false);
    } catch (error) {
      _setError(error);
    }
  }

  Future<void> connect({
    required String baseUrl,
    required String username,
    required String apiKey,
    String? database,
  }) async {
    _state = OdooConnectionState.connecting;
    _error = null;
    _demoMode = false;
    notifyListeners();
    try {
      final connection = OdooConnection.fromInput(
        baseUrl: baseUrl,
        username: username,
        database: database,
      );
      await _connect(connection, apiKey.trim(), persist: true);
    } catch (error) {
      _setError(error);
    }
  }

  void enterDemoMode() {
    _demoMode = true;
    _state = OdooConnectionState.connected;
    _error = null;
    notifyListeners();
  }

  Future<void> disconnect() async {
    _client?.close();
    _client = null;
    _repository = null;
    _connection = null;
    _diagnostic = null;
    _selectedPosConfig = null;
    _categories = const [];
    _products = const [];
    _demoMode = false;
    await _store.clear();
    _state = OdooConnectionState.needsConnection;
    notifyListeners();
  }

  Future<void> selectPosConfig(OdooPosConfig config) async {
    _selectedPosConfig = config;
    await _store.saveSelections(
      companyId: _diagnostic?.currentCompany.id,
      posConfigId: config.id,
    );
    _categories = const [];
    _products = const [];
    notifyListeners();
    if (_diagnostic != null && _repository != null) {
      try {
        _categories = await _repository!.listCategories(
          companyId: _diagnostic!.currentCompany.id,
          categoryIds: config.limitCategories ? config.categoryIds : null,
        );
        notifyListeners();
        await loadProducts();
      } catch (error) {
        _setError(error, preserveConnection: true);
      }
    }
  }

  Future<void> selectCompany(OdooCompany company) async {
    final diagnostic = _diagnostic;
    final repository = _repository;
    if (diagnostic == null || repository == null ||
        diagnostic.currentCompany.id == company.id) {
      return;
    }
    try {
      final posConfigs = await repository.listPosConfigs(companyId: company.id);
      _diagnostic = diagnostic.copyWith(
        currentCompany: company,
        posConfigs: posConfigs,
      );
      _selectedPosConfig = _selectInitialPosConfig(_diagnostic!);
      _categories = const [];
      _products = const [];
      await _store.saveSelections(
        companyId: company.id,
        posConfigId: _selectedPosConfig?.id,
      );
      if (_selectedPosConfig != null &&
          diagnostic.modelAccess['pos.category'] == true) {
        _categories = await repository.listCategories(
          companyId: company.id,
          categoryIds: _selectedPosConfig!.limitCategories
              ? _selectedPosConfig!.categoryIds
              : null,
        );
      }
      notifyListeners();
      await loadProducts();
    } catch (error) {
      _setError(error, preserveConnection: true);
    }
  }

  Future<void> loadProducts({bool append = false}) async {
    if (_repository == null || _diagnostic == null || _selectedPosConfig == null) {
      return;
    }
    if (_loadingProducts) return;
    _loadingProducts = true;
    notifyListeners();
    try {
      final page = await _repository!.listProducts(
        companyId: _diagnostic!.currentCompany.id,
        posConfig: _selectedPosConfig!,
        offset: append ? _products.length : 0,
      );
      _products = append ? [..._products, ...page] : page;
    } catch (error) {
      _setError(error, preserveConnection: true);
    } finally {
      _loadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> _connect(
    OdooConnection connection,
    String apiKey, {
    required bool persist,
  }) async {
    if (apiKey.isEmpty) {
      throw const OdooException(
        kind: OdooErrorKind.invalidConfiguration,
        message: 'Informe uma API key do Odoo.',
      );
    }
    final client = OdooClient(connection: connection, apiKey: apiKey);
    final repository = OdooRepository(client);
    try {
      var diagnostic = await repository.testConnection(
        expectedUsername: connection.username,
      );
      final savedCompanyId = await _store.readCompanyId();
      if (savedCompanyId != null &&
          savedCompanyId != diagnostic.currentCompany.id &&
          diagnostic.companies.any((company) => company.id == savedCompanyId)) {
        final company = diagnostic.companies.firstWhere(
          (candidate) => candidate.id == savedCompanyId,
        );
        diagnostic = diagnostic.copyWith(
          currentCompany: company,
          posConfigs: await repository.listPosConfigs(companyId: company.id),
        );
      }
      _client?.close();
      _client = client;
      _repository = repository;
      _connection = connection;
      _diagnostic = diagnostic;
      final savedPosConfigId = await _store.readPosConfigId();
      _selectedPosConfig = _selectInitialPosConfig(
        diagnostic,
        savedPosConfigId: savedPosConfigId,
      );
      if (_selectedPosConfig != null &&
          diagnostic.modelAccess['pos.category'] == true) {
        _categories = await repository.listCategories(
          companyId: diagnostic.currentCompany.id,
          categoryIds: _selectedPosConfig!.limitCategories
              ? _selectedPosConfig!.categoryIds
              : null,
        );
      }
      if (persist) {
        await _store.saveConnection(connection: connection, apiKey: apiKey);
        await _store.saveSelections(
          companyId: diagnostic.currentCompany.id,
          posConfigId: _selectedPosConfig?.id,
        );
      }
      _state = OdooConnectionState.connected;
      _error = null;
      notifyListeners();
      await loadProducts();
    } catch (_) {
      client.close();
      rethrow;
    }
  }

  OdooPosConfig? _selectInitialPosConfig(
    OdooConnectionDiagnostic diagnostic, {
    int? savedPosConfigId,
  }) {
    final configs = diagnostic.posConfigs;
    if (configs.isEmpty) return null;
    if (savedPosConfigId != null) {
      for (final config in configs) {
        if (config.id == savedPosConfigId) return config;
      }
    }
    return configs.first;
  }

  void _setError(Object error, {bool preserveConnection = false}) {
    _error = error is OdooException
        ? error
        : OdooException(
            kind: OdooErrorKind.unexpected,
            message: error is FormatException
                ? error.message
                : 'Não foi possível concluir a conexão com o Odoo.',
          );
    if (!preserveConnection) {
      _state = OdooConnectionState.error;
    }
    notifyListeners();
  }

  static const _debugUrl = String.fromEnvironment('ODOO_ONLINE_URL');
  static const _debugUsername = String.fromEnvironment('ODOO_ONLINE_USERNAME');
  static const _debugApiKey = String.fromEnvironment('ODOO_ONLINE_API_KEY');
  static const _debugDatabase = String.fromEnvironment('ODOO_ONLINE_DATABASE');

  static bool get _debugConnectionReady =>
      _debugUrl.isNotEmpty && _debugUsername.isNotEmpty && _debugApiKey.isNotEmpty;
}
