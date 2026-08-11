import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/catalog.dart';
import '../models/restaurant.dart';
import '../models/sync_snapshot.dart';
import '../services/odoo/odoo_exception.dart';
import '../services/storage/cache_fallback_policy.dart';
import '../services/storage/snapshot_storage_service.dart';
import 'odoo_session_provider.dart';

enum CatalogFreshness { unavailable, synchronizing, online, offline }

class CatalogProvider extends ChangeNotifier {
  CatalogProvider({SnapshotStorageService? snapshotStorage})
      : _snapshotStorage = snapshotStorage ?? const SnapshotStorageService();

  final SnapshotStorageService _snapshotStorage;

  OdooSessionProvider? _session;
  List<CatalogCategory> _categories = const [];
  List<CatalogProduct> _products = const [];
  List<RestaurantFloor> _restaurantFloors = const [];
  List<RestaurantTable> _restaurantTables = const [];
  CatalogFreshness _freshness = CatalogFreshness.unavailable;
  OdooException? _error;
  DateTime? _lastSynchronizedAt;
  OperationalContext? _operationalContext;
  int _boundSessionRevision = -1;
  int _generation = 0;
  int _dataRevision = 0;
  Future<void> _snapshotWriteTail = Future<void>.value();

  List<CatalogCategory> get categories => _categories;
  List<CatalogProduct> get products => _products;
  List<RestaurantFloor> get restaurantFloors => _restaurantFloors;
  List<RestaurantTable> get restaurantTables => _restaurantTables;
  CatalogFreshness get freshness => _freshness;
  OdooException? get error => _error;
  DateTime? get lastSynchronizedAt => _lastSynchronizedAt;
  OperationalContext? get operationalContext => _operationalContext;
  bool get isOffline => _freshness == CatalogFreshness.offline;
  bool get isLoading => _freshness == CatalogFreshness.synchronizing;
  int get dataRevision => _dataRevision;

  void bind(OdooSessionProvider session) {
    _session = session;
    if (session.contextRevision == _boundSessionRevision) return;
    _boundSessionRevision = session.contextRevision;
    final generation = ++_generation;
    scheduleMicrotask(() => _applySessionBinding(session, generation));
  }

  void _applySessionBinding(
    OdooSessionProvider session,
    int generation,
  ) {
    if (generation != _generation) return;
    if (!session.isConnected || session.isDemoMode) {
      _clear();
      return;
    }
    final context = session.operationalContext;
    if (context == null) {
      _clear();
      return;
    }
    final contextChanged =
        _operationalContext == null || !_operationalContext!.matches(context);
    _operationalContext = context;
    final offlineSnapshot = session.offlineSnapshot;
    if (offlineSnapshot != null && offlineSnapshot.matches(context)) {
      _applySnapshot(offlineSnapshot);
      return;
    }
    if (session.runtime == null) {
      _clear();
      return;
    }
    if (contextChanged) {
      _categories = const [];
      _products = const [];
      _restaurantFloors = const [];
      _restaurantTables = const [];
      _lastSynchronizedAt = null;
      _dataRevision++;
    }
    _freshness = CatalogFreshness.synchronizing;
    _error = null;
    notifyListeners();
    unawaited(_synchronize(session, context, generation));
  }

  Future<void> refresh() async {
    final session = _session;
    if (session == null) return;
    if (isOffline || session.runtime == null) {
      await session.reconnect();
      return;
    }
    await session.refreshPosOperationalProfile();
    final context = session.operationalContext;
    if (context == null) return;
    final generation = ++_generation;
    _freshness = CatalogFreshness.synchronizing;
    _error = null;
    notifyListeners();
    await _synchronize(session, context, generation);
  }

  Future<void> _synchronize(
    OdooSessionProvider session,
    OperationalContext context,
    int generation,
  ) async {
    final runtime = session.runtime;
    final diagnostic = session.diagnostic;
    final posConfig = session.selectedPosConfig;
    if (runtime == null || diagnostic == null || posConfig == null) return;
    try {
      final categories = diagnostic.modelAccess['pos.category'] == true
          ? await runtime.catalog.listCategories(
              companyId: context.companyId,
              categoryIds:
                  posConfig.limitCategories ? posConfig.categoryIds : null,
            )
          : const <CatalogCategory>[];

      var floors = const <RestaurantFloor>[];
      var tables = const <RestaurantTable>[];
      if (posConfig.restaurant) {
        try {
          floors = await runtime.pos.listRestaurantFloors(
            companyId: context.companyId,
            posConfigId: context.posConfigId,
          );
          tables = await runtime.pos.listRestaurantTables(
            companyId: context.companyId,
            floors: floors,
          );
        } on OdooException catch (error) {
          if (error.kind == OdooErrorKind.network) rethrow;
          if (error.kind != OdooErrorKind.forbidden &&
              error.kind != OdooErrorKind.notFound) {
            rethrow;
          }
        }
      }

      final products = <CatalogProduct>[];
      final productIds = <int>{};
      final initialCount = await runtime.catalog.countProducts(
        companyId: context.companyId,
        posConfig: posConfig,
      );
      while (products.length < initialCount) {
        final page = await runtime.catalog.listProducts(
          companyId: context.companyId,
          posConfig: posConfig,
          offset: products.length,
        );
        for (final product in page) {
          if (!productIds.add(product.id)) {
            throw const OdooException(
              kind: OdooErrorKind.unexpected,
              message: 'Odoo devolveu produtos duplicados na paginação.',
            );
          }
          products.add(product);
        }
        if (page.isEmpty || page.length < 100) break;
      }
      final confirmedCount = await runtime.catalog.countProducts(
        companyId: context.companyId,
        posConfig: posConfig,
      );

      final currentContext = session.operationalContext;
      if (generation != _generation ||
          currentContext == null ||
          !context.matches(currentContext)) {
        return;
      }
      if (initialCount != confirmedCount || products.length != confirmedCount) {
        throw const OdooException(
          kind: OdooErrorKind.unexpected,
          message:
              'O catálogo Odoo mudou durante a sincronização. Atualize novamente.',
        );
      }

      final synchronizedAt = DateTime.now().toUtc();
      final snapshot = SyncSnapshot(
        context: context,
        synchronizedAt: synchronizedAt,
        odooVersion: diagnostic.odooVersion,
        company: diagnostic.currentCompany,
        posConfig: posConfig.copyWith(catalogProductCount: products.length),
        categories: categories,
        products: products,
        floors: floors,
        tables: tables,
        posOperationalProfile: session.posOperationalProfile,
      );
      if (!await _saveSnapshotIfCurrent(snapshot, generation)) return;
      _categories = categories;
      _products = products;
      _restaurantFloors = floors;
      _restaurantTables = tables;
      _lastSynchronizedAt = synchronizedAt;
      _freshness = CatalogFreshness.online;
      _error = null;
      _dataRevision++;
      notifyListeners();
    } catch (error) {
      if (generation != _generation) return;
      if (CacheFallbackPolicy.canUse(error)) {
        final snapshot = await _snapshotStorage.read(context);
        if (generation != _generation) return;
        if (snapshot != null) {
          _applySnapshot(snapshot);
          return;
        }
      }
      _categories = const [];
      _products = const [];
      _restaurantFloors = const [];
      _restaurantTables = const [];
      _lastSynchronizedAt = null;
      _error = _asException(error);
      _freshness = CatalogFreshness.unavailable;
      _dataRevision++;
      notifyListeners();
    }
  }

  Future<bool> _saveSnapshotIfCurrent(
    SyncSnapshot snapshot,
    int generation,
  ) async {
    final previous = _snapshotWriteTail.then<void>(
      (_) {},
      onError: (_, __) {},
    );
    final write = previous.then<void>((_) async {
      if (generation != _generation) return;
      await _snapshotStorage.save(snapshot);
    });
    _snapshotWriteTail = write;
    await write;
    return generation == _generation;
  }

  void _applySnapshot(SyncSnapshot snapshot) {
    _operationalContext = snapshot.context;
    _categories = snapshot.categories;
    _products = snapshot.products;
    _restaurantFloors = snapshot.floors;
    _restaurantTables = snapshot.tables;
    _lastSynchronizedAt = snapshot.synchronizedAt;
    _freshness = CatalogFreshness.offline;
    _error = null;
    _dataRevision++;
    notifyListeners();
  }

  void _clear() {
    _generation++;
    _categories = const [];
    _products = const [];
    _restaurantFloors = const [];
    _restaurantTables = const [];
    _operationalContext = null;
    _freshness = CatalogFreshness.unavailable;
    _lastSynchronizedAt = null;
    _error = null;
    _dataRevision++;
    notifyListeners();
  }

  OdooException _asException(Object error) => error is OdooException
      ? error
      : const OdooException(
          kind: OdooErrorKind.unexpected,
          message: 'Não foi possível atualizar o catálogo Odoo.',
        );
}
