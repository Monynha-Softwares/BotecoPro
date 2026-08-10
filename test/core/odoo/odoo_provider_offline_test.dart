import 'package:boteco_pro/core/odoo/odoo_cart_store.dart';
import 'package:boteco_pro/core/odoo/odoo_client.dart';
import 'package:boteco_pro/core/odoo/odoo_connection.dart';
import 'package:boteco_pro/core/odoo/odoo_credentials_store.dart';
import 'package:boteco_pro/core/odoo/odoo_provider.dart';
import 'package:boteco_pro/core/odoo/odoo_snapshot.dart';
import 'package:boteco_pro/core/odoo/odoo_snapshot_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class _OfflineClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      Future<http.StreamedResponse>.error(http.ClientException('offline'));
}

class _Credentials extends OdooCredentialsStore {
  _Credentials();

  static const connection = OdooConnection(
    baseUrl: 'https://example.odoo.com',
    username: 'user@example.com',
  );

  @override
  Future<OdooConnection?> readConnection() async => connection;

  @override
  Future<String?> readApiKey() async => 'sentinel-local-test-key';

  @override
  Future<int?> readUserId() async => 2;

  @override
  Future<int?> readCompanyId() async => 1;

  @override
  Future<int?> readPosConfigId() async => 3;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('restores a compatible snapshot after a real network failure', () async {
    const snapshotStore = OdooSnapshotStore();
    await snapshotStore.save(OdooSnapshotEnvelope(
      context: const OdooSnapshotContext(
        instanceKey: 'https://example.odoo.com',
        userId: 2,
        companyId: 1,
        posConfigId: 3,
      ),
      synchronizedAt: DateTime.utc(2026, 8, 10),
      odooVersion: 'saas~19.4+e',
      company: const OdooCompany(id: 1, name: 'Empresa'),
      posConfig: const OdooPosConfig(
        id: 3,
        name: 'POS',
        companyId: 1,
        active: true,
        limitCategories: true,
        categoryIds: [4],
        restaurant: false,
        catalogProductCount: 1,
      ),
      categories: const [OdooCategory(id: 4, name: 'Bebidas')],
      products: const [OdooProduct(id: 42, name: 'Produto', price: 8.5)],
      floors: const [],
      tables: const [],
    ));
    final provider = OdooProvider(
      store: _Credentials(),
      snapshotStore: snapshotStore,
      cartStore: const OdooCartStore(),
      clientFactory: (connection, apiKey) => OdooClient(
        connection: connection,
        apiKey: apiKey,
        httpClient: _OfflineClient(),
        timeout: const Duration(milliseconds: 10),
      ),
    );

    await provider.initialize();

    expect(provider.state, OdooConnectionState.connected);
    expect(provider.isOffline, isTrue);
    expect(provider.isDemoMode, isFalse);
    expect(provider.products.single.id, 42);
    expect(provider.categories.single.id, 4);
    expect(provider.lastSynchronizedAt, DateTime.utc(2026, 8, 10));
  });
}
