import 'package:boteco_pro/models/catalog.dart';
import 'package:boteco_pro/models/company.dart';
import 'package:boteco_pro/models/draft_cart.dart';
import 'package:boteco_pro/models/pos_config.dart';
import 'package:boteco_pro/models/sync_snapshot.dart';
import 'package:boteco_pro/services/storage/cart_storage_service.dart';
import 'package:boteco_pro/services/storage/snapshot_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('snapshot store never serves another company or POS', () async {
    const store = SnapshotStorageService();
    const context = OperationalContext(
      instanceKey: 'https://example.odoo.com',
      userId: 2,
      companyId: 1,
      posConfigId: 3,
    );
    await store.save(SyncSnapshot(
      context: context,
      synchronizedAt: DateTime.utc(2026, 8, 10),
      odooVersion: 'saas~19.4+e',
      company: const Company(id: 1, name: 'Empresa'),
      posConfig: const PosConfig(
        id: 3,
        name: 'POS',
        companyId: 1,
        active: true,
        limitCategories: false,
        categoryIds: [],
        restaurant: false,
        catalogProductCount: 0,
      ),
      categories: const [],
      products: const [],
      floors: const [],
      tables: const [],
    ));

    expect(await store.read(context), isNotNull);
    expect(
      await store.read(const OperationalContext(
        instanceKey: 'https://example.odoo.com',
        userId: 2,
        companyId: 9,
        posConfigId: 3,
      )),
      isNull,
    );
    expect(await store.read(context), isNull);
    expect(
      await store.read(const OperationalContext(
        instanceKey: 'https://example.odoo.com',
        userId: 2,
        companyId: 1,
        posConfigId: 4,
      )),
      isNull,
    );
  });

  test('cart store restores only the matching operational context', () async {
    const store = CartStorageService();
    const context = OperationalContext(
      instanceKey: 'https://example.odoo.com',
      userId: 2,
      companyId: 1,
      posConfigId: 3,
    );
    final cart = DraftCart(context: context).add(const CatalogProduct(
      id: 42,
      name: 'Produto',
      catalogPrice: 8.5,
    ));
    await store.save(cart);

    final restored = await store.read(context);
    expect(restored?.items.single.productId, 42);
    expect(
      await store.read(const OperationalContext(
        instanceKey: 'https://example.odoo.com',
        userId: 2,
        companyId: 1,
        posConfigId: 99,
      )),
      isNull,
    );

    expect(
      await store.read(context),
      isNull,
    );

    await store.clear();
    expect(
      await store.read(context),
      isNull,
    );
  });

  test('clear is serialized after pending snapshot and cart writes', () async {
    const snapshotStore = SnapshotStorageService();
    const cartStore = CartStorageService();
    const context = OperationalContext(
      instanceKey: 'https://example.odoo.com',
      userId: 2,
      companyId: 1,
      posConfigId: 3,
    );
    final snapshot = SyncSnapshot(
      context: context,
      synchronizedAt: DateTime.utc(2026, 8, 10),
      odooVersion: 'saas~19.4+e',
      company: const Company(id: 1, name: 'Empresa'),
      posConfig: const PosConfig(
        id: 3,
        name: 'POS',
        companyId: 1,
        active: true,
        limitCategories: false,
        categoryIds: [],
        restaurant: false,
        catalogProductCount: 0,
      ),
      categories: const [],
      products: const [],
      floors: const [],
      tables: const [],
    );
    final cart = DraftCart(context: context).add(const CatalogProduct(
      id: 42,
      name: 'Produto',
      catalogPrice: 8.5,
    ));

    final snapshotWrite = snapshotStore.save(snapshot);
    final snapshotClear = snapshotStore.clear();
    final cartWrite = cartStore.save(cart);
    final cartClear = cartStore.clear();
    await Future.wait([
      snapshotWrite,
      snapshotClear,
      cartWrite,
      cartClear,
    ]);

    expect(await snapshotStore.read(context), isNull);
    expect(await cartStore.read(context), isNull);
  });
}
