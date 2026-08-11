import 'package:boteco_pro/models/catalog.dart';
import 'package:boteco_pro/models/company.dart';
import 'package:boteco_pro/models/connection.dart';
import 'package:boteco_pro/models/currency.dart';
import 'package:boteco_pro/models/draft_cart.dart';
import 'package:boteco_pro/models/pos_config.dart';
import 'package:boteco_pro/models/pos_operational_profile.dart';
import 'package:boteco_pro/models/restaurant.dart';
import 'package:boteco_pro/models/sync_snapshot.dart';
import 'package:boteco_pro/providers/cart_provider.dart';
import 'package:boteco_pro/providers/catalog_provider.dart';
import 'package:boteco_pro/providers/odoo_session_provider.dart';
import 'package:boteco_pro/services/odoo/odoo_client.dart';
import 'package:boteco_pro/services/odoo/odoo_runtime.dart';
import 'package:boteco_pro/services/storage/cart_storage_service.dart';
import 'package:boteco_pro/services/storage/credentials_storage_service.dart';
import 'package:boteco_pro/services/storage/snapshot_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class _OfflineClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      Future<http.StreamedResponse>.error(http.ClientException('offline'));
}

class _Credentials extends CredentialsStorageService {
  const _Credentials({this.companyId = 1, this.posConfigId = 3});

  static const connection = ConnectionConfig(
    baseUrl: 'https://example.odoo.com',
    username: 'user@example.com',
  );

  final int companyId;
  final int posConfigId;

  @override
  Future<ConnectionConfig?> readConnection() async => connection;

  @override
  Future<String?> readApiKey() async => 'sentinel-local-test-key';

  @override
  Future<int?> readUserId() async => 2;

  @override
  Future<int?> readCompanyId() async => companyId;

  @override
  Future<int?> readPosConfigId() async => posConfigId;
}

const _context = OperationalContext(
  instanceKey: 'https://example.odoo.com',
  userId: 2,
  companyId: 1,
  posConfigId: 3,
);

final _synchronizedAt = DateTime.utc(2026, 8, 10);

SyncSnapshot _snapshot() => SyncSnapshot(
      context: _context,
      synchronizedAt: _synchronizedAt,
      odooVersion: 'saas~19.4+e',
      company: const Company(id: 1, name: 'Empresa'),
      posConfig: const PosConfig(
        id: 3,
        name: 'POS',
        companyId: 1,
        active: true,
        limitCategories: true,
        categoryIds: [4],
        restaurant: false,
        currencyId: 6,
        pricelistId: 11,
        availablePricelistIds: [11],
        usePricelist: true,
        paymentMethodIds: [21],
        catalogProductCount: 1,
      ),
      posOperationalProfile: const PosOperationalProfile(
        posConfigId: 3,
        currency: CurrencyInfo(
          id: 6,
          name: 'BRL',
          symbol: r'R$',
          position: CurrencySymbolPosition.before,
          decimalPlaces: 2,
          rounding: 0.01,
        ),
        pricelist: PricelistInfo(
          id: 11,
          name: 'Padrão',
          currencyId: 6,
          active: true,
          companyId: 1,
        ),
        pricelistReadable: true,
        nonClosedSessions: [],
        sessionsReadable: true,
        paymentMethods: [
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
        ],
        paymentMethodsReadable: true,
      ),
      categories: const [CatalogCategory(id: 4, name: 'Bebidas')],
      products: const [
        CatalogProduct(
          id: 42,
          name: 'Produto',
          catalogPrice: 8.5,
          currencyId: 6,
        ),
      ],
      floors: const [],
      tables: const [],
    );

OdooRuntimeFactory _offlineRuntimeFactory() => OdooRuntimeFactory(
      clientBuilder: (connection, apiKey) => OdooClient(
        connection: connection,
        apiKey: apiKey,
        httpClient: _OfflineClient(),
        timeout: const Duration(milliseconds: 10),
      ),
    );

Future<void> _settleAsyncWork() async {
  for (var index = 0; index < 6; index++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'session, catalog and cart restore the same context after network failure',
    () async {
      const snapshotStorage = SnapshotStorageService();
      const cartStorage = CartStorageService();
      await snapshotStorage.save(_snapshot());
      await cartStorage.save(
        DraftCart(context: _context).add(
          const CatalogProduct(
            id: 42,
            name: 'Produto',
            catalogPrice: 8.5,
            currencyId: 6,
          ),
        ),
      );

      final session = OdooSessionProvider(
        credentialsStorage: const _Credentials(),
        snapshotStorage: snapshotStorage,
        cartStorage: cartStorage,
        runtimeFactory: _offlineRuntimeFactory(),
      );
      final catalog = CatalogProvider(snapshotStorage: snapshotStorage);
      final cart = CartProvider(storage: cartStorage);

      await session.initialize();
      catalog.bind(session);
      await _settleAsyncWork();
      cart.bind(session, catalog);
      await _settleAsyncWork();

      expect(session.state, OdooSessionState.connected);
      expect(session.isOfflineBootstrap, isTrue);
      expect(session.isDemoMode, isFalse);
      expect(session.operationalContext?.matches(_context), isTrue);
      expect(session.posOperationalProfile?.posConfigId, 3);
      expect(session.posOperationalProfile?.currency.name, 'BRL');
      expect(session.posOperationalProfile?.pricelist?.id, 11);
      expect(session.posOperationalProfile?.sessionsReadable, isFalse);
      expect(session.posOperationalProfile?.nonClosedSessions, isEmpty);
      expect(session.posOperationalProfile?.paymentMethods, isEmpty);
      expect(session.posOperationalProfile?.paymentMethodsReadable, isFalse);
      expect(session.posProfileError, isNull);
      expect(session.isPosProfileLoading, isFalse);
      expect(catalog.freshness, CatalogFreshness.offline);
      expect(catalog.products.single.id, 42);
      expect(catalog.categories.single.id, 4);
      expect(catalog.lastSynchronizedAt, _synchronizedAt);
      expect(cart.items.single.productId, 42);
      expect(cart.items.single.state, DraftCartItemState.available);

      cart.selectTable(const RestaurantTable(
        id: 10,
        number: 1,
        floorId: 5,
        floorName: 'Salão',
        active: true,
      ));
      cart.clear();
      await _settleAsyncWork();
      expect(cart.items, isEmpty);
      expect(cart.selectedTable, isNull);
      expect(await cartStorage.read(_context), isNull);
    },
  );

  test('never restores a snapshot from another company or POS context',
      () async {
    const snapshotStorage = SnapshotStorageService();
    for (final candidate in const [
      OperationalContext(
        instanceKey: 'https://example.odoo.com',
        userId: 2,
        companyId: 99,
        posConfigId: 3,
      ),
      OperationalContext(
        instanceKey: 'https://example.odoo.com',
        userId: 2,
        companyId: 1,
        posConfigId: 99,
      ),
    ]) {
      await snapshotStorage.save(_snapshot());
      final session = OdooSessionProvider(
        credentialsStorage: _Credentials(
          companyId: candidate.companyId,
          posConfigId: candidate.posConfigId,
        ),
        snapshotStorage: snapshotStorage,
        runtimeFactory: _offlineRuntimeFactory(),
      );
      final catalog = CatalogProvider(snapshotStorage: snapshotStorage);

      await session.initialize();
      catalog.bind(session);
      await _settleAsyncWork();

      expect(session.state, OdooSessionState.error);
      expect(session.isOfflineBootstrap, isFalse);
      expect(session.isDemoMode, isFalse);
      expect(catalog.freshness, CatalogFreshness.unavailable);
      expect(catalog.products, isEmpty);
      expect(await snapshotStorage.read(candidate), isNull);

      session.dispose();
      catalog.dispose();
    }
  });
}
