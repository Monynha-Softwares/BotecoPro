import 'dart:async';

import 'package:flutter/foundation.dart';

import 'odoo_cart.dart';
import 'odoo_cart_store.dart';
import 'odoo_client.dart';
import 'odoo_connection.dart';
import 'odoo_credentials_store.dart';
import 'odoo_exception.dart';
import 'odoo_repository.dart';
import 'odoo_snapshot.dart';
import 'odoo_snapshot_store.dart';

enum OdooConnectionState {
  loading,
  needsConnection,
  connecting,
  connected,
  error
}

typedef OdooClientFactory = OdooClient Function(
  OdooConnection connection,
  String apiKey,
);

class OdooProvider extends ChangeNotifier {
  OdooProvider({
    OdooCredentialsStore? store,
    OdooSnapshotStore? snapshotStore,
    OdooCartStore? cartStore,
    OdooClientFactory? clientFactory,
  })  : _store = store ?? const OdooCredentialsStore(),
        _snapshotStore = snapshotStore ?? const OdooSnapshotStore(),
        _cartStore = cartStore ?? const OdooCartStore(),
        _clientFactory = clientFactory ?? _defaultClientFactory;

  final OdooCredentialsStore _store;
  final OdooSnapshotStore _snapshotStore;
  final OdooCartStore _cartStore;
  final OdooClientFactory _clientFactory;

  static OdooClient _defaultClientFactory(
    OdooConnection connection,
    String apiKey,
  ) =>
      OdooClient(connection: connection, apiKey: apiKey);

  OdooConnectionState _state = OdooConnectionState.loading;
  OdooConnection? _connection;
  OdooClient? _client;
  OdooRepository? _repository;
  OdooConnectionDiagnostic? _diagnostic;
  OdooException? _error;
  OdooPosConfig? _selectedPosConfig;
  List<OdooCategory> _categories = const [];
  List<OdooProduct> _products = const [];
  List<OdooRestaurantFloor> _restaurantFloors = const [];
  List<OdooRestaurantTable> _restaurantTables = const [];
  OdooRestaurantTable? _selectedTable;
  OdooLocalCart? _cart;
  bool _demoMode = false;
  bool _loadingProducts = false;
  bool _usingSnapshot = false;
  DateTime? _lastSynchronizedAt;

  OdooConnectionState get state => _state;
  OdooConnection? get connection => _connection;
  OdooConnectionDiagnostic? get diagnostic => _diagnostic;
  OdooException? get error => _error;
  OdooPosConfig? get selectedPosConfig => _selectedPosConfig;
  List<OdooCategory> get categories => _categories;
  List<OdooProduct> get products => _products;
  List<OdooRestaurantFloor> get restaurantFloors => _restaurantFloors;
  List<OdooRestaurantTable> get restaurantTables => _restaurantTables;
  OdooRestaurantTable? get selectedTable => _selectedTable;
  List<OdooCartItem> get cartItems => _cart?.items ?? const [];
  int get cartItemCount => _cart?.itemCount ?? 0;
  double get cartSubtotal => _cart?.subtotal ?? 0;
  bool get hasMoreProducts {
    final count = _selectedPosConfig?.catalogProductCount;
    return count == null || _products.length < count;
  }

  bool get isDemoMode => _demoMode;
  bool get isConnected => _state == OdooConnectionState.connected;
  bool get isLoadingProducts => _loadingProducts;
  bool get isOffline => _usingSnapshot;
  DateTime? get lastSynchronizedAt => _lastSynchronizedAt;

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
      if (OdooCacheFallbackPolicy.canUse(error)) {
        final restored = await _restoreSavedSnapshot();
        if (restored) return;
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

  Future<void> reconnect() async {
    final connection = _connection ?? await _store.readConnection();
    final apiKey = await _store.readApiKey();
    if (connection == null || apiKey == null || apiKey.isEmpty) return;
    _state = OdooConnectionState.connecting;
    _error = null;
    notifyListeners();
    try {
      await _connect(connection, apiKey, persist: false);
    } catch (error) {
      if (OdooCacheFallbackPolicy.canUse(error)) {
        final restored = await _restoreSavedSnapshot();
        if (restored) return;
      }
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
    _restaurantFloors = const [];
    _restaurantTables = const [];
    _selectedTable = null;
    _cart = null;
    _usingSnapshot = false;
    _lastSynchronizedAt = null;
    _demoMode = false;
    await _snapshotStore.clear();
    await _cartStore.clear();
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
    _restaurantFloors = const [];
    _restaurantTables = const [];
    _selectedTable = null;
    _cart = null;
    _usingSnapshot = false;
    notifyListeners();
    if (_diagnostic != null && _repository != null) {
      try {
        await _loadSelectedPosData();
        notifyListeners();
        await loadProducts();
      } catch (error) {
        if (!OdooCacheFallbackPolicy.canUse(error) ||
            !await _restoreCurrentSnapshot()) {
          _setError(error, preserveConnection: true);
        }
      }
    }
  }

  Future<void> selectCompany(OdooCompany company) async {
    final diagnostic = _diagnostic;
    final repository = _repository;
    if (diagnostic == null ||
        repository == null ||
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
      _restaurantFloors = const [];
      _restaurantTables = const [];
      _selectedTable = null;
      _cart = null;
      _usingSnapshot = false;
      await _store.saveSelections(
        companyId: company.id,
        posConfigId: _selectedPosConfig?.id,
      );
      await _loadSelectedPosData();
      notifyListeners();
      await loadProducts();
    } catch (error) {
      if (!OdooCacheFallbackPolicy.canUse(error) ||
          !await _restoreCurrentSnapshot()) {
        _setError(error, preserveConnection: true);
      }
    }
  }

  Future<void> loadProducts({bool append = false}) async {
    if (_repository == null ||
        _diagnostic == null ||
        _selectedPosConfig == null) {
      return;
    }
    if (_loadingProducts) return;
    _loadingProducts = true;
    notifyListeners();
    try {
      final expectedCount = _selectedPosConfig!.catalogProductCount;
      final loaded = append ? [..._products] : <OdooProduct>[];
      do {
        final page = await _repository!.listProducts(
          companyId: _diagnostic!.currentCompany.id,
          posConfig: _selectedPosConfig!,
          offset: loaded.length,
        );
        loaded.addAll(page);
        if (page.isEmpty || page.length < 100) break;
      } while (expectedCount == null || loaded.length < expectedCount);
      _products = loaded;
      _usingSnapshot = false;
      _error = null;
      await _saveOperationalSnapshot();
      await _restoreAndReconcileCart();
    } catch (error) {
      if (OdooCacheFallbackPolicy.canUse(error)) {
        final restored = await _restoreCurrentSnapshot();
        if (!restored) _setError(error, preserveConnection: true);
      } else {
        _setError(error, preserveConnection: true);
      }
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
    final client = _clientFactory(connection, apiKey);
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
        await _loadSelectedPosData();
      }
      if (persist) {
        await _store.saveConnection(connection: connection, apiKey: apiKey);
        await _store.saveSelections(
          companyId: diagnostic.currentCompany.id,
          posConfigId: _selectedPosConfig?.id,
        );
      }
      await _store.saveUserId(diagnostic.identity.id);
      _state = OdooConnectionState.connected;
      _usingSnapshot = false;
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

  Future<void> _loadSelectedPosData() async {
    final repository = _repository;
    final diagnostic = _diagnostic;
    final config = _selectedPosConfig;
    if (repository == null || diagnostic == null || config == null) return;
    if (diagnostic.modelAccess['pos.category'] == true) {
      _categories = await repository.listCategories(
        companyId: diagnostic.currentCompany.id,
        categoryIds: config.limitCategories ? config.categoryIds : null,
      );
    }
    if (!config.restaurant) return;
    try {
      _restaurantFloors = await repository.listRestaurantFloors(
        companyId: diagnostic.currentCompany.id,
        posConfigId: config.id,
      );
      _restaurantTables = await repository.listRestaurantTables(
        companyId: diagnostic.currentCompany.id,
        floors: _restaurantFloors,
      );
    } on OdooException catch (error) {
      if (error.kind == OdooErrorKind.network) rethrow;
      if (error.kind == OdooErrorKind.forbidden ||
          error.kind == OdooErrorKind.notFound) {
        _restaurantFloors = const [];
        _restaurantTables = const [];
        return;
      }
      rethrow;
    }
  }

  void addToCart(OdooProduct product) {
    final diagnostic = _diagnostic;
    final config = _selectedPosConfig;
    if (diagnostic == null || config == null) return;
    final cart = _cart ??
        OdooLocalCart(
          instanceKey: _connection!.baseUrl,
          userId: diagnostic.identity.id,
          companyId: diagnostic.currentCompany.id,
          posConfigId: config.id,
          table: _selectedTable,
        );
    _cart = cart.add(product);
    unawaited(_cartStore.save(_cart!));
    notifyListeners();
  }

  void updateCartItemQuantity(int productId, int quantity) {
    if (_cart == null) return;
    _cart = _cart!.updateQuantity(productId, quantity);
    unawaited(_cartStore.save(_cart!));
    notifyListeners();
  }

  void updateCartItemNote(int productId, String note) {
    if (_cart == null) return;
    _cart = _cart!.updateNote(productId, note);
    unawaited(_cartStore.save(_cart!));
    notifyListeners();
  }

  void removeCartItem(int productId) {
    if (_cart == null) return;
    _cart = _cart!.remove(productId);
    unawaited(_cartStore.save(_cart!));
    notifyListeners();
  }

  void clearCart() {
    if (_cart == null) return;
    _cart = _cart!.clear();
    unawaited(_cartStore.clear());
    notifyListeners();
  }

  void selectTable(OdooRestaurantTable? table) {
    _selectedTable = table;
    if (_cart != null) {
      _cart = _cart!.copyWith(table: table, clearTable: table == null);
      unawaited(_cartStore.save(_cart!));
    }
    notifyListeners();
  }

  Future<void> _saveOperationalSnapshot() async {
    final connection = _connection;
    final diagnostic = _diagnostic;
    final posConfig = _selectedPosConfig;
    if (connection == null || diagnostic == null || posConfig == null) return;
    final expectedCount = posConfig.catalogProductCount;
    if (expectedCount != null && _products.length != expectedCount) return;
    final synchronizedAt = DateTime.now().toUtc();
    await _snapshotStore.save(OdooSnapshotEnvelope(
      context: OdooSnapshotContext(
        instanceKey: connection.baseUrl,
        userId: diagnostic.identity.id,
        companyId: diagnostic.currentCompany.id,
        posConfigId: posConfig.id,
      ),
      synchronizedAt: synchronizedAt,
      odooVersion: diagnostic.odooVersion,
      company: diagnostic.currentCompany,
      posConfig: posConfig,
      categories: _categories,
      products: _products,
      floors: _restaurantFloors,
      tables: _restaurantTables,
    ));
    _lastSynchronizedAt = synchronizedAt;
  }

  Future<bool> _restoreSavedSnapshot() async {
    final connection = _connection;
    final userId = await _store.readUserId();
    final companyId = await _store.readCompanyId();
    final posConfigId = await _store.readPosConfigId();
    if (connection == null ||
        userId == null ||
        companyId == null ||
        posConfigId == null) {
      return false;
    }
    return _restoreSnapshot(OdooSnapshotContext(
      instanceKey: connection.baseUrl,
      userId: userId,
      companyId: companyId,
      posConfigId: posConfigId,
    ));
  }

  Future<bool> _restoreCurrentSnapshot() async {
    final connection = _connection;
    final diagnostic = _diagnostic;
    final config = _selectedPosConfig;
    if (connection == null || diagnostic == null || config == null) {
      return false;
    }
    return _restoreSnapshot(OdooSnapshotContext(
      instanceKey: connection.baseUrl,
      userId: diagnostic.identity.id,
      companyId: diagnostic.currentCompany.id,
      posConfigId: config.id,
    ));
  }

  Future<bool> _restoreSnapshot(OdooSnapshotContext context) async {
    final snapshot = await _snapshotStore.read(context);
    final connection = _connection;
    if (snapshot == null || connection == null) return false;
    _client?.close();
    _client = null;
    _repository = null;
    _selectedPosConfig = snapshot.posConfig;
    _categories = snapshot.categories;
    _products = snapshot.products;
    _restaurantFloors = snapshot.floors;
    _restaurantTables = snapshot.tables;
    _lastSynchronizedAt = snapshot.synchronizedAt;
    _usingSnapshot = true;
    _error = null;
    _diagnostic = OdooConnectionDiagnostic(
      odooVersion: snapshot.odooVersion,
      identity: OdooIdentity(
        id: context.userId,
        name: 'Utilizador Odoo #${context.userId}',
        login: connection.username,
        companyId: snapshot.company.id,
        companyIds: [snapshot.company.id],
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
    _state = OdooConnectionState.connected;
    await _restoreAndReconcileCart();
    notifyListeners();
    return true;
  }

  Future<void> _restoreAndReconcileCart() async {
    final connection = _connection;
    final diagnostic = _diagnostic;
    final config = _selectedPosConfig;
    if (connection == null || diagnostic == null || config == null) return;
    final stored = await _cartStore.read(
      instanceKey: connection.baseUrl,
      userId: diagnostic.identity.id,
      companyId: diagnostic.currentCompany.id,
      posConfigId: config.id,
    );
    if (stored == null) return;
    _cart = stored.reconcile(_products);
    _selectedTable = _cart!.table;
    await _cartStore.save(_cart!);
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
      _debugUrl.isNotEmpty &&
      _debugUsername.isNotEmpty &&
      _debugApiKey.isNotEmpty;
}
