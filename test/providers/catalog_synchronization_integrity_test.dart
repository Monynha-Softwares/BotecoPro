import 'dart:async';
import 'dart:convert';

import 'package:boteco_pro/models/company.dart';
import 'package:boteco_pro/models/connection.dart';
import 'package:boteco_pro/models/connection_diagnostic.dart';
import 'package:boteco_pro/models/identity.dart';
import 'package:boteco_pro/models/pos_config.dart';
import 'package:boteco_pro/models/sync_snapshot.dart';
import 'package:boteco_pro/providers/catalog_provider.dart';
import 'package:boteco_pro/providers/odoo_session_provider.dart';
import 'package:boteco_pro/services/odoo/odoo_client.dart';
import 'package:boteco_pro/services/odoo/odoo_exception.dart';
import 'package:boteco_pro/services/odoo/odoo_runtime.dart';
import 'package:boteco_pro/services/storage/snapshot_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

class _HttpClient extends http.BaseClient {
  _HttpClient(this.handler);

  final Future<http.Response> Function(http.Request request) handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await handler(request as http.Request);
    return http.StreamedResponse(
      http.ByteStream.fromBytes(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      request: request,
    );
  }
}

class _SessionHarness extends OdooSessionProvider {
  _SessionHarness({
    required OperationalContext context,
    required PosConfig posConfig,
    required ConnectionDiagnostic diagnostic,
    required OdooRuntime runtime,
  })  : _context = context,
        _posConfig = posConfig,
        _diagnostic = diagnostic,
        _runtime = runtime;

  OperationalContext _context;
  PosConfig _posConfig;
  ConnectionDiagnostic _diagnostic;
  OdooRuntime _runtime;
  int _revision = 1;

  @override
  bool get isConnected => true;

  @override
  bool get isDemoMode => false;

  @override
  int get contextRevision => _revision;

  @override
  OperationalContext get operationalContext => _context;

  @override
  PosConfig get selectedPosConfig => _posConfig;

  @override
  ConnectionDiagnostic get diagnostic => _diagnostic;

  @override
  OdooRuntime get runtime => _runtime;

  @override
  SyncSnapshot? get offlineSnapshot => null;

  void replace({
    required OperationalContext context,
    required PosConfig posConfig,
    required ConnectionDiagnostic diagnostic,
    required OdooRuntime runtime,
  }) {
    _context = context;
    _posConfig = posConfig;
    _diagnostic = diagnostic;
    _runtime = runtime;
    _revision++;
  }
}

class _RecordingSnapshotStorage extends SnapshotStorageService {
  int saveCalls = 0;
  int readCalls = 0;
  SyncSnapshot? persisted;

  @override
  Future<void> save(SyncSnapshot snapshot) async {
    saveCalls++;
    persisted = snapshot;
  }

  @override
  Future<SyncSnapshot?> read(OperationalContext context) async {
    readCalls++;
    return persisted != null && persisted!.matches(context) ? persisted : null;
  }
}

class _DelayedFirstSnapshotStorage extends SnapshotStorageService {
  final firstSaveStarted = Completer<void>();
  final releaseFirstSave = Completer<void>();
  final secondSaveFinished = Completer<void>();

  int saveCalls = 0;
  SyncSnapshot? persisted;

  @override
  Future<void> save(SyncSnapshot snapshot) async {
    final call = ++saveCalls;
    if (call == 1) {
      firstSaveStarted.complete();
      await releaseFirstSave.future;
    }
    persisted = snapshot;
    if (call == 2) secondSaveFinished.complete();
  }

  @override
  Future<SyncSnapshot?> read(OperationalContext context) async => null;
}

const _connection = ConnectionConfig(
  baseUrl: 'https://odoo.example.com',
  username: 'operator@example.com',
);

PosConfig _posConfig({required int id, required int companyId}) => PosConfig(
      id: id,
      name: 'POS $id',
      companyId: companyId,
      active: true,
      limitCategories: false,
      categoryIds: const [],
      restaurant: false,
      currencyId: 6,
    );

ConnectionDiagnostic _diagnostic({
  required Company company,
  required PosConfig posConfig,
}) =>
    ConnectionDiagnostic(
      odooVersion: 'saas~19.4+e',
      identity: AuthenticatedUser(
        id: 2,
        name: 'Operador',
        login: _connection.username,
        companyId: company.id,
        companyIds: [company.id],
      ),
      currentCompany: company,
      companies: [company],
      posConfigs: [posConfig],
      modelAccess: const {
        'res.company': true,
        'pos.config': true,
        'pos.category': true,
        'product.product': true,
      },
    );

OdooRuntime _runtime(
  Future<http.Response> Function(http.Request request) handler,
) =>
    OdooRuntimeFactory(
      clientBuilder: (connection, apiKey) => OdooClient(
        connection: connection,
        apiKey: apiKey,
        httpClient: _HttpClient(handler),
      ),
    ).create(_connection, 'sentinel-test-key');

Map<String, Object?> _product(int id, int companyId) => {
      'id': id,
      'display_name': 'Produto $id',
      'lst_price': id.toDouble(),
      'product_tmpl_id': [id, 'Produto $id'],
      'default_code': 'SKU-$id',
      'barcode': false,
      'uom_id': [1, 'Unidade'],
      'currency_id': [6, 'BRL'],
      'pos_categ_ids': const <int>[],
      'write_date': '2026-08-10 12:00:00',
      'company_marker': companyId,
    };

Future<Map<String, dynamic>> _body(http.Request request) async =>
    Map<String, dynamic>.from(jsonDecode(request.body) as Map);

Future<void> _waitUntil(bool Function() predicate) async {
  for (var attempt = 0; attempt < 500; attempt++) {
    if (predicate()) return;
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  fail('A sincronização controlada não terminou no tempo esperado.');
}

void main() {
  test('rejects duplicate product IDs across pages without saving a snapshot',
      () async {
    final storage = _RecordingSnapshotStorage();
    const company = Company(id: 1, name: 'Empresa 1', currencyId: 6);
    final posConfig = _posConfig(id: 10, companyId: company.id);
    final runtime = _runtime((request) async {
      if (request.url.path.endsWith('/pos.category/search_read')) {
        return http.Response('[]', 200);
      }
      if (request.url.path.endsWith('/product.product/search_count')) {
        return http.Response('101', 200);
      }
      if (request.url.path.endsWith('/product.product/search_read')) {
        final body = await _body(request);
        final offset = body['offset'] as int;
        final rows = offset == 0
            ? [for (var id = 1; id <= 100; id++) _product(id, company.id)]
            : [_product(100, company.id), _product(101, company.id)];
        return http.Response(jsonEncode(rows), 200);
      }
      return http.Response('{}', 404);
    });
    final context = OperationalContext(
      instanceKey: _connection.baseUrl,
      userId: 2,
      companyId: company.id,
      posConfigId: posConfig.id,
    );
    final session = _SessionHarness(
      context: context,
      posConfig: posConfig,
      diagnostic: _diagnostic(company: company, posConfig: posConfig),
      runtime: runtime,
    );
    final catalog = CatalogProvider(snapshotStorage: storage);

    catalog.bind(session);
    await _waitUntil(() => catalog.error != null);

    expect(catalog.freshness, CatalogFreshness.unavailable);
    expect(catalog.error?.message, contains('duplicados'));
    expect(catalog.products, isEmpty);
    expect(storage.saveCalls, 0);
    expect(storage.readCalls, 0);
    expect(storage.persisted, isNull);

    catalog.dispose();
    session.dispose();
    runtime.close();
  });

  test('an older in-flight save cannot overwrite a newer POS context',
      () async {
    final storage = _DelayedFirstSnapshotStorage();
    const firstCompany = Company(id: 1, name: 'Empresa 1', currencyId: 6);
    const secondCompany = Company(id: 2, name: 'Empresa 2', currencyId: 6);
    final firstPos = _posConfig(id: 10, companyId: firstCompany.id);
    final secondPos = _posConfig(id: 20, companyId: secondCompany.id);
    final firstContext = OperationalContext(
      instanceKey: _connection.baseUrl,
      userId: 2,
      companyId: firstCompany.id,
      posConfigId: firstPos.id,
    );
    final secondContext = OperationalContext(
      instanceKey: _connection.baseUrl,
      userId: 2,
      companyId: secondCompany.id,
      posConfigId: secondPos.id,
    );
    final secondReadyToSave = Completer<void>();

    OdooRuntime runtimeFor(Company company, {Completer<void>? ready}) {
      var countCalls = 0;
      return _runtime((request) async {
        if (request.url.path.endsWith('/pos.category/search_read')) {
          return http.Response('[]', 200);
        }
        if (request.url.path.endsWith('/product.product/search_count')) {
          countCalls++;
          if (countCalls == 2 && ready != null && !ready.isCompleted) {
            ready.complete();
          }
          return http.Response('1', 200);
        }
        if (request.url.path.endsWith('/product.product/search_read')) {
          return http.Response(
            jsonEncode([_product(company.id * 100 + 1, company.id)]),
            200,
          );
        }
        return http.Response('{}', 404);
      });
    }

    final firstRuntime = runtimeFor(firstCompany);
    final secondRuntime = runtimeFor(
      secondCompany,
      ready: secondReadyToSave,
    );
    final session = _SessionHarness(
      context: firstContext,
      posConfig: firstPos,
      diagnostic: _diagnostic(company: firstCompany, posConfig: firstPos),
      runtime: firstRuntime,
    );
    final catalog = CatalogProvider(snapshotStorage: storage);

    catalog.bind(session);
    await storage.firstSaveStarted.future.timeout(const Duration(seconds: 2));

    session.replace(
      context: secondContext,
      posConfig: secondPos,
      diagnostic: _diagnostic(company: secondCompany, posConfig: secondPos),
      runtime: secondRuntime,
    );
    catalog.bind(session);
    await secondReadyToSave.future.timeout(const Duration(seconds: 2));
    storage.releaseFirstSave.complete();
    await storage.secondSaveFinished.future.timeout(const Duration(seconds: 2));
    await _waitUntil(
      () =>
          catalog.freshness == CatalogFreshness.online &&
          catalog.operationalContext?.matches(secondContext) == true,
    );

    expect(storage.saveCalls, 2);
    expect(storage.persisted?.context.matches(secondContext), isTrue);
    expect(storage.persisted?.products.single.id, 201);
    expect(catalog.products.single.id, 201);
    expect(catalog.error, isNull);

    catalog.dispose();
    session.dispose();
    firstRuntime.close();
    secondRuntime.close();
  });

  test(
      'clears the previous context immediately and keeps it empty after a non-network error',
      () async {
    final storage = _RecordingSnapshotStorage();
    const firstCompany = Company(id: 1, name: 'Empresa 1', currencyId: 6);
    const secondCompany = Company(id: 2, name: 'Empresa 2', currencyId: 6);
    final firstPos = _posConfig(id: 10, companyId: firstCompany.id);
    final secondPos = _posConfig(id: 20, companyId: secondCompany.id);
    final firstContext = OperationalContext(
      instanceKey: _connection.baseUrl,
      userId: 2,
      companyId: firstCompany.id,
      posConfigId: firstPos.id,
    );
    final secondContext = OperationalContext(
      instanceKey: _connection.baseUrl,
      userId: 2,
      companyId: secondCompany.id,
      posConfigId: secondPos.id,
    );
    final secondRequestStarted = Completer<void>();
    final releaseSecondRequest = Completer<void>();

    final firstRuntime = _runtime((request) async {
      if (request.url.path.endsWith('/pos.category/search_read')) {
        return http.Response('[]', 200);
      }
      if (request.url.path.endsWith('/product.product/search_count')) {
        return http.Response('1', 200);
      }
      if (request.url.path.endsWith('/product.product/search_read')) {
        return http.Response(jsonEncode([_product(101, firstCompany.id)]), 200);
      }
      return http.Response('{}', 404);
    });
    final secondRuntime = _runtime((request) async {
      if (request.url.path.endsWith('/pos.category/search_read')) {
        if (!secondRequestStarted.isCompleted) secondRequestStarted.complete();
        await releaseSecondRequest.future;
        return http.Response(jsonEncode({'message': 'Acesso negado.'}), 403);
      }
      return http.Response('{}', 404);
    });
    final session = _SessionHarness(
      context: firstContext,
      posConfig: firstPos,
      diagnostic: _diagnostic(company: firstCompany, posConfig: firstPos),
      runtime: firstRuntime,
    );
    final catalog = CatalogProvider(snapshotStorage: storage);

    catalog.bind(session);
    await _waitUntil(() => catalog.freshness == CatalogFreshness.online);
    expect(catalog.products.single.id, 101);
    expect(storage.saveCalls, 1);

    session.replace(
      context: secondContext,
      posConfig: secondPos,
      diagnostic: _diagnostic(company: secondCompany, posConfig: secondPos),
      runtime: secondRuntime,
    );
    catalog.bind(session);
    await secondRequestStarted.future.timeout(const Duration(seconds: 2));

    expect(catalog.operationalContext?.matches(secondContext), isTrue);
    expect(catalog.freshness, CatalogFreshness.synchronizing);
    expect(catalog.products, isEmpty);
    expect(catalog.categories, isEmpty);

    releaseSecondRequest.complete();
    await _waitUntil(() => catalog.error != null);

    expect(catalog.error?.kind, OdooErrorKind.forbidden);
    expect(catalog.freshness, CatalogFreshness.unavailable);
    expect(catalog.products, isEmpty);
    expect(catalog.categories, isEmpty);
    expect(storage.readCalls, 0);
    expect(storage.saveCalls, 1);

    catalog.dispose();
    session.dispose();
    firstRuntime.close();
    secondRuntime.close();
  });
}
