import 'dart:convert';

import 'package:boteco_pro/models/catalog.dart';
import 'package:boteco_pro/models/company.dart';
import 'package:boteco_pro/models/currency.dart';
import 'package:boteco_pro/models/pos_config.dart';
import 'package:boteco_pro/models/pos_operational_profile.dart';
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
        currentSessionState: 'opened',
        currentSessionId: 31,
        currencyId: 6,
        pricelistId: 11,
        availablePricelistIds: [11],
        usePricelist: true,
        paymentMethodIds: [21, 22],
        catalogProductCount: 1,
      ),
      posOperationalProfile: PosOperationalProfile(
        posConfigId: 7,
        currency: const CurrencyInfo(
          id: 6,
          name: 'BRL',
          symbol: r'R$',
          position: CurrencySymbolPosition.before,
          decimalPlaces: 2,
          rounding: 0.01,
        ),
        pricelist: const PricelistInfo(
          id: 11,
          name: 'Padrão',
          currencyId: 6,
          active: true,
          companyId: 1,
        ),
        pricelistReadable: true,
        nonClosedSessions: [
          PosSessionSummary(
            id: 31,
            name: 'POS/00031',
            state: 'opened',
            configId: 7,
            userId: 2,
            userName: 'Operador',
            currencyId: 6,
            paymentMethodIds: const [21, 22],
            startedAt: DateTime.utc(2026, 8, 10, 10),
          ),
        ],
        sessionsReadable: true,
        paymentMethods: const [
          PaymentMethodSummary(
            id: 21,
            name: 'Dinheiro',
            active: true,
            isCashCount: true,
            splitTransactions: false,
            sequence: 1,
            type: 'cash',
            paymentMethodType: 'none',
          ),
          PaymentMethodSummary(
            id: 22,
            name: 'Cartão',
            active: true,
            isCashCount: false,
            splitTransactions: false,
            sequence: 2,
            type: 'bank',
            paymentMethodType: 'terminal',
          ),
        ],
        paymentMethodsReadable: true,
      ),
      categories: const [CatalogCategory(id: 4, name: 'Bebidas')],
      products: [
        CatalogProduct(
          id: 42,
          name: 'Produto',
          catalogPrice: 8.5,
          currencyId: 6,
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
    expect(restored.products.single.currencyId, 6);
    expect(restored.categories.single.id, 4);
    expect(restored.tables.single.seats, 4);
    expect(restored.posConfig.usePricelist, isTrue);
    expect(restored.posConfig.currentSessionId, isNull);
    expect(restored.posConfig.currentSessionState, isNull);
    expect(restored.posOperationalProfile?.currency.name, 'BRL');
    expect(restored.posOperationalProfile?.pricelist?.id, 11);
    expect(restored.posOperationalProfile?.nonClosedSessions, isEmpty);
    expect(restored.posOperationalProfile?.sessionsReadable, isFalse);
    expect(restored.posOperationalProfile?.paymentMethods, isEmpty);
    expect(restored.posOperationalProfile?.paymentMethodsReadable, isFalse);
    expect(json, isNot(contains('apiKey')));
    expect(json, isNot(contains('Authorization')));
    expect(json, isNot(contains('Bearer')));
    expect(json, isNot(contains('access_token')));
    expect(json, isNot(contains('cookie')));
    expect(json, isNot(contains('Operador')));
    expect(json, isNot(contains('Dinheiro')));
    expect(json, isNot(contains('Cartão')));
  });

  test('restores a legacy schema-v1 snapshot without enriched POS metadata',
      () {
    final legacy = Map<String, Object?>.from(_snapshot().toJson())
      ..remove('posOperationalProfile');
    final posConfig = Map<String, Object?>.from(legacy['posConfig']! as Map)
      ..remove('availablePricelistIds')
      ..remove('usePricelist')
      ..remove('paymentMethodIds')
      ..remove('currentSessionId');
    legacy['posConfig'] = posConfig;
    legacy['products'] = [
      for (final raw in legacy['products']! as List)
        Map<String, Object?>.from(raw as Map)..remove('currencyId'),
    ];

    final restored = SyncSnapshot.fromJson(
      Map<String, dynamic>.from(
        jsonDecode(jsonEncode(legacy)) as Map,
      ),
    );

    expect(restored.schemaVersion, 1);
    expect(restored.posOperationalProfile, isNull);
    expect(restored.posConfig.availablePricelistIds, isEmpty);
    expect(restored.posConfig.usePricelist, isFalse);
    expect(restored.products.single.currencyId, isNull);
    expect(restored.products.single.catalogPrice, 8.5);
  });

  test('never carries live POS session identity or state into offline data',
      () {
    final encoded = _snapshot().toJson();
    final posConfig = Map<String, Object?>.from(encoded['posConfig']! as Map);
    final restored = SyncSnapshot.fromJson(
      Map<String, dynamic>.from(
        jsonDecode(jsonEncode(encoded)) as Map,
      ),
    );

    expect(posConfig['currentSessionId'], isNull);
    expect(posConfig['currentSessionState'], isNull);
    expect(restored.posConfig.currentSessionId, isNull);
    expect(restored.posConfig.currentSessionState, isNull);
    expect(restored.posOperationalProfile?.nonClosedSessions, isEmpty);
    expect(restored.posOperationalProfile?.sessionsReadable, isFalse);
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

    final inconsistent = _snapshot().toJson();
    inconsistent['posConfig'] = {
      ...Map<String, Object?>.from(inconsistent['posConfig']! as Map),
      'companyId': 99,
    };
    expect(
      () => SyncSnapshot.fromJson(inconsistent),
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
