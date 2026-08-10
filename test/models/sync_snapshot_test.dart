import 'dart:convert';

import 'package:boteco_pro/models/catalog.dart';
import 'package:boteco_pro/models/company.dart';
import 'package:boteco_pro/models/pos_config.dart';
import 'package:boteco_pro/models/restaurant.dart';
import 'package:boteco_pro/models/sync_snapshot.dart';
import 'package:boteco_pro/services/odoo/odoo_exception.dart';
import 'package:boteco_pro/services/storage/cache_fallback_policy.dart';
import 'package:flutter_test/flutter_test.dart';

SyncSnapshot _snapshot() => SyncSnapshot(
      context: const OperationalContext(
        instanceKey: 'https://example.odoo.com',
        userId: 2,
        companyId: 1,
        posConfigId: 7,
      ),
      synchronizedAt: DateTime.utc(2026, 8, 10, 12),
      odooVersion: 'saas~19.4+e',
      company: const Company(id: 1, name: 'Empresa', currencyId: 6),
      posConfig: const PosConfig(
        id: 7,
        name: 'POS',
        companyId: 1,
        active: true,
        limitCategories: true,
        categoryIds: [4, 5],
        restaurant: true,
        catalogProductCount: 1,
      ),
      categories: const [CatalogCategory(id: 4, name: 'Bebidas')],
      products: [
        CatalogProduct(
          id: 42,
          name: 'Produto',
          catalogPrice: 8.5,
          categoryIds: const [4],
          writeDate: DateTime.utc(2026, 8, 9),
        ),
      ],
      floors: const [
        RestaurantFloor(id: 1, name: 'Salão', posConfigIds: [7]),
      ],
      tables: const [
        RestaurantTable(
          id: 8,
          number: 2,
          floorId: 1,
          floorName: 'Salão',
          active: true,
          seats: 4,
        ),
      ],
    );

void main() {
  test('serializes and restores a complete versioned snapshot', () {
    final source = _snapshot();
    final json = jsonEncode(source.toJson());
    final restored = SyncSnapshot.fromJson(
      Map<String, dynamic>.from(jsonDecode(json) as Map),
    );

    expect(restored.schemaVersion, SyncSnapshot.currentSchemaVersion);
    expect(restored.synchronizedAt, source.synchronizedAt);
    expect(restored.products.single.id, 42);
    expect(restored.categories.single.id, 4);
    expect(restored.tables.single.seats, 4);
    expect(json, isNot(contains('apiKey')));
    expect(json, isNot(contains('Authorization')));
    expect(json, isNot(contains('Bearer')));
  });

  test('rejects incompatible schema and incomplete payloads', () {
    final wrongSchema = _snapshot().toJson()..['schemaVersion'] = 99;
    expect(
      () => SyncSnapshot.fromJson(wrongSchema),
      throwsFormatException,
    );

    final incomplete = _snapshot().toJson()..['productCount'] = 2;
    expect(
      () => SyncSnapshot.fromJson(incomplete),
      throwsFormatException,
    );
  });

  test('matches only the same instance, user, company and POS', () {
    final snapshot = _snapshot();
    expect(snapshot.matches(snapshot.context), isTrue);
    expect(
      snapshot.matches(const OperationalContext(
        instanceKey: 'https://other.odoo.com',
        userId: 2,
        companyId: 1,
        posConfigId: 7,
      )),
      isFalse,
    );
    expect(
      snapshot.matches(const OperationalContext(
        instanceKey: 'https://example.odoo.com',
        userId: 2,
        companyId: 1,
        posConfigId: 9,
      )),
      isFalse,
    );
  });

  test('allows snapshot fallback only for transport interruptions', () {
    for (final kind in [OdooErrorKind.network, OdooErrorKind.timeout]) {
      expect(
        CacheFallbackPolicy.canUse(
          OdooException(kind: kind, message: 'offline'),
        ),
        isTrue,
      );
    }
    for (final kind in [
      OdooErrorKind.unauthorized,
      OdooErrorKind.forbidden,
      OdooErrorKind.invalidConfiguration,
      OdooErrorKind.validation,
    ]) {
      expect(
        CacheFallbackPolicy.canUse(
          OdooException(kind: kind, message: 'não usar cache'),
        ),
        isFalse,
      );
    }
  });
}
