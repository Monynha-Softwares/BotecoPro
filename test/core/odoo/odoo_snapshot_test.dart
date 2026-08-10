import 'dart:convert';

import 'package:boteco_pro/core/odoo/odoo_connection.dart';
import 'package:boteco_pro/core/odoo/odoo_exception.dart';
import 'package:boteco_pro/core/odoo/odoo_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

OdooSnapshotEnvelope _snapshot() => OdooSnapshotEnvelope(
      context: const OdooSnapshotContext(
        instanceKey: 'https://example.odoo.com',
        userId: 2,
        companyId: 1,
        posConfigId: 7,
      ),
      synchronizedAt: DateTime.utc(2026, 8, 10, 12),
      odooVersion: 'saas~19.4+e',
      company: const OdooCompany(id: 1, name: 'Empresa', currencyId: 6),
      posConfig: const OdooPosConfig(
        id: 7,
        name: 'POS',
        companyId: 1,
        active: true,
        limitCategories: true,
        categoryIds: [4, 5],
        restaurant: true,
        catalogProductCount: 1,
      ),
      categories: const [OdooCategory(id: 4, name: 'Bebidas')],
      products: [
        OdooProduct(
          id: 42,
          name: 'Produto',
          price: 8.5,
          categoryIds: const [4],
          writeDate: DateTime.utc(2026, 8, 9),
        ),
      ],
      floors: const [
        OdooRestaurantFloor(id: 1, name: 'Salão', posConfigIds: [7]),
      ],
      tables: const [
        OdooRestaurantTable(
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
    final restored = OdooSnapshotEnvelope.fromJson(
      Map<String, dynamic>.from(jsonDecode(json) as Map),
    );

    expect(restored.schemaVersion, OdooSnapshotEnvelope.currentSchemaVersion);
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
      () => OdooSnapshotEnvelope.fromJson(wrongSchema),
      throwsFormatException,
    );

    final incomplete = _snapshot().toJson()..['productCount'] = 2;
    expect(
      () => OdooSnapshotEnvelope.fromJson(incomplete),
      throwsFormatException,
    );
  });

  test('matches only the same instance, user, company and POS', () {
    final snapshot = _snapshot();
    expect(snapshot.matches(snapshot.context), isTrue);
    expect(
      snapshot.matches(const OdooSnapshotContext(
        instanceKey: 'https://other.odoo.com',
        userId: 2,
        companyId: 1,
        posConfigId: 7,
      )),
      isFalse,
    );
    expect(
      snapshot.matches(const OdooSnapshotContext(
        instanceKey: 'https://example.odoo.com',
        userId: 2,
        companyId: 1,
        posConfigId: 9,
      )),
      isFalse,
    );
  });

  test('allows snapshot fallback only for network failures', () {
    expect(
      OdooCacheFallbackPolicy.canUse(const OdooException(
        kind: OdooErrorKind.network,
        message: 'offline',
      )),
      isTrue,
    );
    for (final kind in [
      OdooErrorKind.unauthorized,
      OdooErrorKind.forbidden,
      OdooErrorKind.invalidConfiguration,
      OdooErrorKind.validation,
    ]) {
      expect(
        OdooCacheFallbackPolicy.canUse(
          OdooException(kind: kind, message: 'não usar cache'),
        ),
        isFalse,
      );
    }
  });
}
