import 'package:boteco_pro/core/odoo/odoo_cart.dart';
import 'package:boteco_pro/core/odoo/odoo_cart_store.dart';
import 'package:boteco_pro/core/odoo/odoo_connection.dart';
import 'package:boteco_pro/core/odoo/odoo_snapshot.dart';
import 'package:boteco_pro/core/odoo/odoo_snapshot_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('snapshot store never serves another company or POS', () async {
    const store = OdooSnapshotStore();
    const context = OdooSnapshotContext(
      instanceKey: 'https://example.odoo.com',
      userId: 2,
      companyId: 1,
      posConfigId: 3,
    );
    await store.save(OdooSnapshotEnvelope(
      context: context,
      synchronizedAt: DateTime.utc(2026, 8, 10),
      odooVersion: 'saas~19.4+e',
      company: const OdooCompany(id: 1, name: 'Empresa'),
      posConfig: const OdooPosConfig(
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
      await store.read(const OdooSnapshotContext(
        instanceKey: 'https://example.odoo.com',
        userId: 2,
        companyId: 9,
        posConfigId: 3,
      )),
      isNull,
    );
    expect(await store.read(context), isNull);
    expect(
      await store.read(const OdooSnapshotContext(
        instanceKey: 'https://example.odoo.com',
        userId: 2,
        companyId: 1,
        posConfigId: 4,
      )),
      isNull,
    );
  });

  test('cart store restores only the matching operational context', () async {
    const store = OdooCartStore();
    final cart = OdooLocalCart(
      instanceKey: 'https://example.odoo.com',
      userId: 2,
      companyId: 1,
      posConfigId: 3,
    ).add(const OdooProduct(id: 42, name: 'Produto', price: 8.5));
    await store.save(cart);

    final restored = await store.read(
      instanceKey: 'https://example.odoo.com',
      userId: 2,
      companyId: 1,
      posConfigId: 3,
    );
    expect(restored?.items.single.productId, 42);
    expect(
      await store.read(
        instanceKey: 'https://example.odoo.com',
        userId: 2,
        companyId: 1,
        posConfigId: 99,
      ),
      isNull,
    );

    expect(
      await store.read(
        instanceKey: 'https://example.odoo.com',
        userId: 2,
        companyId: 1,
        posConfigId: 3,
      ),
      isNull,
    );

    await store.clear();
    expect(
      await store.read(
        instanceKey: 'https://example.odoo.com',
        userId: 2,
        companyId: 1,
        posConfigId: 3,
      ),
      isNull,
    );
  });
}
