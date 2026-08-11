import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/catalog.dart';
import '../models/draft_cart.dart';
import '../models/restaurant.dart';
import '../models/sync_snapshot.dart';
import '../services/storage/cart_storage_service.dart';
import 'catalog_provider.dart';
import 'odoo_session_provider.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({CartStorageService? storage})
      : _storage = storage ?? const CartStorageService();

  final CartStorageService _storage;

  DraftCart? _cart;
  OperationalContext? _boundContext;
  int _boundCatalogRevision = -1;
  int _generation = 0;
  bool _hasPersistenceError = false;
  Future<void> _writeChain = Future<void>.value();

  List<DraftCartItem> get items => _cart?.items ?? const [];
  RestaurantTable? get selectedTable => _cart?.table;
  int get itemCount => _cart?.itemCount ?? 0;
  double get subtotal => _cart?.subtotal ?? 0;
  bool get hasUnavailableItems => _cart?.hasUnavailableItems ?? false;
  bool get hasPersistenceError => _hasPersistenceError;

  void bind(OdooSessionProvider session, CatalogProvider catalog) {
    final context = session.isConnected && !session.isDemoMode
        ? session.operationalContext
        : null;
    if (context == null) {
      if (_boundContext != null || _cart != null) {
        _boundContext = null;
        _cart = null;
        final generation = ++_generation;
        _queueClear();
        scheduleMicrotask(() {
          if (generation == _generation) notifyListeners();
        });
      }
      return;
    }

    if (_boundContext == null || !_boundContext!.matches(context)) {
      final replacesExistingContext = _boundContext != null;
      _boundContext = context;
      _cart = null;
      _boundCatalogRevision = catalog.dataRevision;
      final generation = ++_generation;
      if (replacesExistingContext) _queueClear();
      scheduleMicrotask(() {
        if (generation != _generation) return;
        notifyListeners();
        unawaited(_restore(context, catalog, generation));
      });
      return;
    }

    if (_boundCatalogRevision != catalog.dataRevision) {
      _boundCatalogRevision = catalog.dataRevision;
      if (_cart != null && _catalogReady(catalog)) {
        final generation = _generation;
        scheduleMicrotask(() {
          if (generation != _generation || _cart == null) return;
          _cart = _cart!.reconcile(catalog.products);
          _queueSave(_cart!);
          notifyListeners();
        });
      }
    }
  }

  void add(CatalogProduct product) {
    final context = _boundContext;
    if (context == null) return;
    _cart = (_cart ?? DraftCart(context: context)).add(product);
    _queueSave(_cart!);
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    if (_cart == null) return;
    _cart = _cart!.updateQuantity(productId, quantity);
    _queueSave(_cart!);
    notifyListeners();
  }

  void updateNote(int productId, String note) {
    if (_cart == null) return;
    _cart = _cart!.updateNote(productId, note);
    _queueSave(_cart!);
    notifyListeners();
  }

  void remove(int productId) {
    if (_cart == null) return;
    _cart = _cart!.remove(productId);
    _queueSave(_cart!);
    notifyListeners();
  }

  void clear() {
    if (_cart == null) return;
    final context = _boundContext;
    _cart = context == null ? null : DraftCart(context: context);
    _queueClear();
    notifyListeners();
  }

  void selectTable(RestaurantTable? table) {
    if (_cart == null) return;
    _cart = _cart!.copyWith(table: table, clearTable: table == null);
    _queueSave(_cart!);
    notifyListeners();
  }

  Future<void> _restore(
    OperationalContext context,
    CatalogProvider catalog,
    int generation,
  ) async {
    final stored = await _storage.read(context);
    if (generation != _generation || stored == null) return;
    _cart = _catalogReady(catalog, context)
        ? stored.reconcile(catalog.products)
        : stored;
    if (_catalogReady(catalog, context)) _queueSave(_cart!);
    notifyListeners();
  }

  bool _catalogReady(
    CatalogProvider catalog, [
    OperationalContext? context,
  ]) {
    final expectedContext = context ?? _boundContext;
    final catalogContext = catalog.operationalContext;
    return expectedContext != null &&
        catalogContext != null &&
        catalogContext.matches(expectedContext) &&
        (catalog.freshness == CatalogFreshness.online ||
            catalog.freshness == CatalogFreshness.offline);
  }

  void _queueSave(DraftCart cart) {
    final generation = _generation;
    _enqueue(() async {
      final context = _boundContext;
      if (generation != _generation ||
          context == null ||
          !cart.matchesContext(context)) {
        return;
      }
      await _storage.save(cart);
    });
  }

  void _queueClear() {
    _enqueue(_storage.clear);
  }

  void _enqueue(Future<void> Function() operation) {
    _writeChain = _writeChain.then((_) async {
      try {
        await operation();
        if (_hasPersistenceError) {
          _hasPersistenceError = false;
          notifyListeners();
        }
      } on Object {
        _hasPersistenceError = true;
        notifyListeners();
      }
    });
  }
}
