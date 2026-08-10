import 'package:flutter/foundation.dart';

import '../models/company.dart';
import '../models/connection.dart';
import '../models/connection_diagnostic.dart';
import '../models/identity.dart';
import '../models/pos_config.dart';
import '../models/sync_snapshot.dart';
import '../services/odoo/odoo_exception.dart';
import '../services/odoo/odoo_runtime.dart';
import '../services/storage/cache_fallback_policy.dart';
import '../services/storage/cart_storage_service.dart';
import '../services/storage/credentials_storage_service.dart';
import '../services/storage/snapshot_storage_service.dart';

enum OdooSessionState {
  loading,
  needsConnection,
  connecting,
  connected,
  error,
}

class OdooSessionProvider extends ChangeNotifier {
  OdooSessionProvider({
    CredentialsStorageService? credentialsStorage,
    SnapshotStorageService? snapshotStorage,
    CartStorageService? cartStorage,
    OdooRuntimeFactory? runtimeFactory,
  })  : _credentialsStorage =
            credentialsStorage ?? const CredentialsStorageService(),
        _snapshotStorage = snapshotStorage ?? const SnapshotStorageService(),
        _cartStorage = cartStorage ?? const CartStorageService(),
        _runtimeFactory = runtimeFactory ?? const OdooRuntimeFactory();

  final CredentialsStorageService _credentialsStorage;
  final SnapshotStorageService _snapshotStorage;
  final CartStorageService _cartStorage;
  final OdooRuntimeFactory _runtimeFactory;

  OdooSessionState _state = OdooSessionState.loading;
  ConnectionConfig? _connection;
  ConnectionDiagnostic? _diagnostic;
  PosConfig? _selectedPosConfig;
  OdooRuntime? _runtime;
  OdooException? _error;
  SyncSnapshot? _offlineSnapshot;
  bool _demoMode = false;
  int _contextRevision = 0;
  int _operationGeneration = 0;

  OdooSessionState get state => _state;
  ConnectionConfig? get connection => _connection;
  ConnectionDiagnostic? get diagnostic => _diagnostic;
  PosConfig? get selectedPosConfig => _selectedPosConfig;
  OdooRuntime? get runtime => _runtime;
  OdooException? get error => _error;
  SyncSnapshot? get offlineSnapshot => _offlineSnapshot;
  bool get isDemoMode => _demoMode;
  bool get isConnected => _state == OdooSessionState.connected;
  bool get isOfflineBootstrap => _offlineSnapshot != null;
  int get contextRevision => _contextRevision;

  OperationalContext? get operationalContext {
    final connection = _connection;
    final diagnostic = _diagnostic;
    final pos = _selectedPosConfig;
    if (connection == null || diagnostic == null || pos == null) return null;
    return OperationalContext(
      instanceKey: connection.baseUrl,
      userId: diagnostic.identity.id,
      companyId: diagnostic.currentCompany.id,
      posConfigId: pos.id,
    );
  }

  Future<void> initialize() async {
    final generation = ++_operationGeneration;
    try {
      _connection = await _credentialsStorage.readConnection();
      final apiKey = await _credentialsStorage.readApiKey();
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
        _state = OdooSessionState.needsConnection;
        notifyListeners();
        return;
      }
      await _connect(
        _connection!,
        apiKey,
        persistConnection: false,
        generation: generation,
      );
    } catch (error) {
      if (generation != _operationGeneration) return;
      if (CacheFallbackPolicy.canUse(error) && await _restoreSavedSnapshot()) {
        return;
      }
      _setError(error);
    }
  }

  Future<void> connect({
    required String baseUrl,
    required String username,
    required String apiKey,
    String? database,
  }) async {
    final generation = ++_operationGeneration;
    _state = OdooSessionState.connecting;
    _error = null;
    _demoMode = false;
    notifyListeners();
    try {
      final connection = ConnectionConfig.fromInput(
        baseUrl: baseUrl,
        username: username,
        database: database,
      );
      await _connect(
        connection,
        apiKey.trim(),
        persistConnection: true,
        generation: generation,
      );
    } catch (error) {
      if (generation != _operationGeneration) return;
      _setError(error);
    }
  }

  Future<void> reconnect() async {
    final generation = ++_operationGeneration;
    final connection =
        _connection ?? await _credentialsStorage.readConnection();
    final apiKey = await _credentialsStorage.readApiKey();
    if (connection == null || apiKey == null || apiKey.isEmpty) return;
    _state = OdooSessionState.connecting;
    _error = null;
    notifyListeners();
    try {
      await _connect(
        connection,
        apiKey,
        persistConnection: false,
        generation: generation,
      );
    } catch (error) {
      if (generation != _operationGeneration) return;
      if (CacheFallbackPolicy.canUse(error) && await _restoreSavedSnapshot()) {
        return;
      }
      _setError(error);
    }
  }

  void enterDemoMode() {
    _operationGeneration++;
    _runtime?.close();
    _runtime = null;
    _demoMode = true;
    _offlineSnapshot = null;
    _state = OdooSessionState.connected;
    _error = null;
    _contextRevision++;
    notifyListeners();
  }

  Future<void> disconnect() async {
    _operationGeneration++;
    _runtime?.close();
    _runtime = null;
    _connection = null;
    _diagnostic = null;
    _selectedPosConfig = null;
    _offlineSnapshot = null;
    _error = null;
    _demoMode = false;
    await _snapshotStorage.clear();
    await _cartStorage.clear();
    await _credentialsStorage.clear();
    _state = OdooSessionState.needsConnection;
    _contextRevision++;
    notifyListeners();
  }

  Future<void> selectCompany(Company company) async {
    final diagnostic = _diagnostic;
    final runtime = _runtime;
    if (diagnostic == null ||
        runtime == null ||
        diagnostic.currentCompany.id == company.id) {
      return;
    }
    final generation = ++_operationGeneration;
    try {
      final configs = await runtime.pos.listPosConfigs(companyId: company.id);
      if (generation != _operationGeneration || runtime != _runtime) return;
      _diagnostic = diagnostic.copyWith(
        currentCompany: company,
        posConfigs: configs,
      );
      _selectedPosConfig = _selectInitialPosConfig(_diagnostic!);
      _offlineSnapshot = null;
      await _credentialsStorage.saveSelections(
        companyId: company.id,
        posConfigId: _selectedPosConfig?.id,
      );
      _contextRevision++;
      _error = null;
      notifyListeners();
    } catch (error) {
      if (generation != _operationGeneration) return;
      _setError(error, preserveConnection: true);
    }
  }

  Future<void> selectPosConfig(PosConfig config) async {
    if (_selectedPosConfig?.id == config.id) return;
    _operationGeneration++;
    _selectedPosConfig = config;
    _offlineSnapshot = null;
    _contextRevision++;
    _error = null;
    notifyListeners();
    try {
      await _credentialsStorage.saveSelections(
        companyId: _diagnostic?.currentCompany.id,
        posConfigId: config.id,
      );
    } catch (error) {
      _setError(error, preserveConnection: true);
    }
  }

  Future<void> _connect(
    ConnectionConfig connection,
    String apiKey, {
    required bool persistConnection,
    required int generation,
  }) async {
    if (apiKey.isEmpty) {
      throw const OdooException(
        kind: OdooErrorKind.invalidConfiguration,
        message: 'Informe uma API key do Odoo.',
      );
    }
    final nextRuntime = _runtimeFactory.create(connection, apiKey);
    try {
      var diagnostic = await nextRuntime.connection.testConnection(
        expectedUsername: connection.username,
      );
      if (generation != _operationGeneration) {
        nextRuntime.close();
        return;
      }
      final savedCompanyId = await _credentialsStorage.readCompanyId();
      if (savedCompanyId != null &&
          savedCompanyId != diagnostic.currentCompany.id &&
          diagnostic.companies.any((company) => company.id == savedCompanyId)) {
        final company = diagnostic.companies.firstWhere(
          (candidate) => candidate.id == savedCompanyId,
        );
        diagnostic = diagnostic.copyWith(
          currentCompany: company,
          posConfigs:
              await nextRuntime.pos.listPosConfigs(companyId: company.id),
        );
      }
      if (generation != _operationGeneration) {
        nextRuntime.close();
        return;
      }
      final savedPosConfigId = await _credentialsStorage.readPosConfigId();
      final selectedPos = _selectInitialPosConfig(
        diagnostic,
        savedPosConfigId: savedPosConfigId,
      );

      if (generation != _operationGeneration) {
        nextRuntime.close();
        return;
      }

      if (persistConnection) {
        await _credentialsStorage.saveConnection(
          connection: connection,
          apiKey: apiKey,
        );
      }
      await _credentialsStorage.saveUserId(diagnostic.identity.id);
      await _credentialsStorage.saveSelections(
        companyId: diagnostic.currentCompany.id,
        posConfigId: selectedPos?.id,
      );

      if (generation != _operationGeneration) {
        nextRuntime.close();
        return;
      }

      _runtime?.close();
      _runtime = nextRuntime;
      _connection = connection;
      _diagnostic = diagnostic;
      _selectedPosConfig = selectedPos;
      _offlineSnapshot = null;
      _demoMode = false;
      _state = OdooSessionState.connected;
      _error = null;
      _contextRevision++;
      notifyListeners();
    } catch (_) {
      nextRuntime.close();
      rethrow;
    }
  }

  PosConfig? _selectInitialPosConfig(
    ConnectionDiagnostic diagnostic, {
    int? savedPosConfigId,
  }) {
    if (diagnostic.posConfigs.isEmpty) return null;
    if (savedPosConfigId != null) {
      for (final config in diagnostic.posConfigs) {
        if (config.id == savedPosConfigId) return config;
      }
    }
    return diagnostic.posConfigs.first;
  }

  Future<bool> _restoreSavedSnapshot() async {
    final connection = _connection;
    final userId = await _credentialsStorage.readUserId();
    final companyId = await _credentialsStorage.readCompanyId();
    final posConfigId = await _credentialsStorage.readPosConfigId();
    if (connection == null ||
        userId == null ||
        companyId == null ||
        posConfigId == null) {
      return false;
    }
    final context = OperationalContext(
      instanceKey: connection.baseUrl,
      userId: userId,
      companyId: companyId,
      posConfigId: posConfigId,
    );
    final snapshot = await _snapshotStorage.read(context);
    if (snapshot == null) return false;

    _runtime?.close();
    _runtime = null;
    _offlineSnapshot = snapshot;
    _selectedPosConfig = snapshot.posConfig;
    _diagnostic = ConnectionDiagnostic(
      odooVersion: snapshot.odooVersion,
      identity: AuthenticatedUser(
        id: userId,
        name: 'Utilizador Odoo #$userId',
        login: connection.username,
        companyId: companyId,
        companyIds: [companyId],
      ),
      currentCompany: snapshot.company,
      companies: [snapshot.company],
      posConfigs: [snapshot.posConfig],
      modelAccess: const {
        'res.company': true,
        'pos.config': true,
        'pos.category': true,
        'product.product': true,
      },
    );
    _demoMode = false;
    _state = OdooSessionState.connected;
    _error = null;
    _contextRevision++;
    notifyListeners();
    return true;
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
    if (!preserveConnection) _state = OdooSessionState.error;
    notifyListeners();
  }

  @override
  void dispose() {
    _runtime?.close();
    super.dispose();
  }

  static const _debugUrl = String.fromEnvironment('ODOO_ONLINE_URL');
  static const _debugUsername = String.fromEnvironment('ODOO_ONLINE_USERNAME');
  static const _debugApiKey = String.fromEnvironment('ODOO_ONLINE_API_KEY');
  static const _debugDatabase = String.fromEnvironment('ODOO_ONLINE_DATABASE');

  static bool get _debugConnectionReady =>
      _debugUrl.isNotEmpty &&
      _debugUsername.isNotEmpty &&
      _debugApiKey.isNotEmpty;
}
