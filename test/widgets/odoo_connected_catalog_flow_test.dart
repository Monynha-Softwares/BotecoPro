import 'dart:convert';

import 'package:boteco_pro/models/company.dart';
import 'package:boteco_pro/models/connection.dart';
import 'package:boteco_pro/models/connection_diagnostic.dart';
import 'package:boteco_pro/models/currency.dart';
import 'package:boteco_pro/models/identity.dart';
import 'package:boteco_pro/models/pos_config.dart';
import 'package:boteco_pro/models/pos_operational_profile.dart';
import 'package:boteco_pro/models/sync_snapshot.dart';
import 'package:boteco_pro/pages/connection/connection_gate.dart';
import 'package:boteco_pro/pages/legacy/main_navigation_screen.dart';
import 'package:boteco_pro/pages/odoo/cart_page.dart';
import 'package:boteco_pro/pages/odoo/main_screen.dart';
import 'package:boteco_pro/providers/cart_provider.dart';
import 'package:boteco_pro/providers/catalog_provider.dart';
import 'package:boteco_pro/providers/odoo_session_provider.dart';
import 'package:boteco_pro/services/odoo/odoo_client.dart';
import 'package:boteco_pro/services/odoo/odoo_runtime.dart';
import 'package:boteco_pro/services/storage/cart_storage_service.dart';
import 'package:boteco_pro/services/storage/snapshot_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _connection = ConnectionConfig(
  baseUrl: 'https://odoo.example.test',
  username: 'operator@example.test',
);

const _context = OperationalContext(
  instanceKey: 'https://odoo.example.test',
  userId: 2,
  companyId: 1,
  posConfigId: 3,
);

const _posConfig = PosConfig(
  id: 3,
  name: 'POS de teste',
  companyId: 1,
  active: true,
  limitCategories: true,
  categoryIds: [4, 5],
  restaurant: false,
  currencyId: 6,
  catalogProductCount: 2,
);

const _diagnostic = ConnectionDiagnostic(
  odooVersion: 'saas~19.4+e',
  identity: AuthenticatedUser(
    id: 2,
    name: 'Operador de teste',
    login: 'operator@example.test',
    companyId: 1,
    companyIds: [1],
  ),
  currentCompany: Company(id: 1, name: 'Empresa de teste', currencyId: 6),
  companies: [Company(id: 1, name: 'Empresa de teste', currencyId: 6)],
  posConfigs: [_posConfig],
  modelAccess: {
    'res.company': true,
    'pos.config': true,
    'pos.category': true,
    'product.product': true,
  },
);

const _profile = PosOperationalProfile(
  posConfigId: 3,
  currency: CurrencyInfo(
    id: 6,
    name: 'BRL',
    symbol: r'R$',
    position: CurrencySymbolPosition.before,
    decimalPlaces: 2,
    rounding: 0.01,
  ),
  pricelist: null,
  pricelistReadable: true,
  nonClosedSessions: [],
  sessionsReadable: true,
  paymentMethods: [],
  paymentMethodsReadable: true,
);

class _CatalogHttpClient extends http.BaseClient {
  final requestPaths = <String>[];
  final unexpectedPaths = <String>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final path = request.url.path;
    requestPaths.add(path);
    final (statusCode, body) = switch (path) {
      '/json/2/pos.category/search_read' => (
          200,
          jsonEncode([
            {'id': 4, 'name': 'Bebidas', 'parent_id': false},
            {'id': 5, 'name': 'Comidas', 'parent_id': false},
          ]),
        ),
      '/json/2/product.product/search_count' => (200, '2'),
      '/json/2/product.product/search_read' => (
          200,
          jsonEncode([
            {
              'id': 42,
              'display_name': 'Cerveja Pilsen',
              'lst_price': 12.5,
              'product_tmpl_id': [420, 'Cerveja Pilsen'],
              'default_code': 'CER-42',
              'barcode': '7890000000042',
              'uom_id': [1, 'Unidade'],
              'currency_id': [6, 'BRL'],
              'pos_categ_ids': [4],
              'write_date': '2026-08-10 12:00:00',
            },
            {
              'id': 43,
              'display_name': 'Batata frita',
              'lst_price': 18.0,
              'product_tmpl_id': [430, 'Batata frita'],
              'default_code': 'COM-43',
              'barcode': false,
              'uom_id': [1, 'Unidade'],
              'currency_id': [6, 'BRL'],
              'pos_categ_ids': [5],
              'write_date': '2026-08-10 12:00:00',
            },
          ]),
        ),
      _ => (500, jsonEncode({'message': 'Unexpected synthetic endpoint'})),
    };
    if (statusCode == 500) unexpectedPaths.add(path);
    return http.StreamedResponse(
      http.ByteStream.fromBytes(utf8.encode(body)),
      statusCode,
      headers: const {'content-type': 'application/json'},
      request: request,
    );
  }
}

class _ConnectedSessionHarness extends OdooSessionProvider {
  _ConnectedSessionHarness(this._runtime);

  final OdooRuntime _runtime;

  @override
  OdooSessionState get state => OdooSessionState.connected;

  @override
  bool get isConnected => true;

  @override
  bool get isDemoMode => false;

  @override
  int get contextRevision => 1;

  @override
  OperationalContext get operationalContext => _context;

  @override
  ConnectionConfig get connection => _connection;

  @override
  ConnectionDiagnostic get diagnostic => _diagnostic;

  @override
  PosConfig get selectedPosConfig => _posConfig;

  @override
  PosOperationalProfile get posOperationalProfile => _profile;

  @override
  OdooRuntime get runtime => _runtime;

  @override
  SyncSnapshot? get offlineSnapshot => null;
}

Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() predicate, {
  String reason = 'A condição assíncrona não foi satisfeita.',
}) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (predicate()) return;
    await tester.pump(const Duration(milliseconds: 10));
  }
  fail(reason);
}

Future<void> _finishRouteAnimation(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'connected Odoo catalog reaches detail and a non-fiscal local cart',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final httpClient = _CatalogHttpClient();
      final runtime = OdooRuntimeFactory(
        clientBuilder: (connection, apiKey) => OdooClient(
          connection: connection,
          apiKey: apiKey,
          httpClient: httpClient,
        ),
      ).create(_connection, 'sentinel-widget-test-key');
      addTearDown(runtime.close);

      final session = _ConnectedSessionHarness(runtime);
      addTearDown(session.dispose);
      final catalog = CatalogProvider(
        snapshotStorage: const SnapshotStorageService(),
      );
      final cart = CartProvider(storage: const CartStorageService());

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<OdooSessionProvider>.value(value: session),
            ChangeNotifierProxyProvider<OdooSessionProvider, CatalogProvider>(
              create: (_) => catalog,
              update: (_, currentSession, currentCatalog) {
                currentCatalog!.bind(currentSession);
                return currentCatalog;
              },
            ),
            ChangeNotifierProxyProvider2<OdooSessionProvider, CatalogProvider,
                CartProvider>(
              create: (_) => cart,
              update: (_, currentSession, currentCatalog, currentCart) {
                currentCart!.bind(currentSession, currentCatalog);
                return currentCart;
              },
            ),
          ],
          child: const MaterialApp(home: ConnectionGate()),
        ),
      );

      await _pumpUntil(
        tester,
        () => catalog.freshness == CatalogFreshness.online,
        reason: 'O catálogo sintético não concluiu a sincronização online.',
      );

      expect(session.isDemoMode, isFalse);
      expect(session.offlineSnapshot, isNull);
      expect(catalog.isOffline, isFalse);
      expect(find.byType(OdooMainScreen), findsOneWidget);
      expect(find.byType(MainNavigationScreen), findsNothing);
      expect(catalog.products.map((product) => product.id), [42, 43]);

      await tester.tap(find.text('Produtos'));
      await tester.pump();

      expect(find.text('Produtos POS'), findsOneWidget);
      expect(find.text('Online'), findsOneWidget);
      expect(find.text('Offline · Dados locais'), findsNothing);
      expect(find.text('Bebidas'), findsOneWidget);
      expect(find.text('Comidas'), findsOneWidget);
      expect(find.text('Cerveja Pilsen'), findsOneWidget);
      expect(find.text('Batata frita'), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Bebidas'));
      await tester.pump();
      expect(find.text('Cerveja Pilsen'), findsOneWidget);
      expect(find.text('Batata frita'), findsNothing);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Todos'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'batata');
      await tester.pump();
      expect(find.text('Cerveja Pilsen'), findsNothing);
      expect(find.text('Batata frita'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      await tester.tap(find.text('Cerveja Pilsen'));
      await _finishRouteAnimation(tester);

      expect(find.text('Referência: CER-42'), findsOneWidget);
      expect(find.text('Código de barras: 7890000000042'), findsOneWidget);
      expect(
        find.text(r'Valor de catálogo Odoo: R$ 12,50'),
        findsOneWidget,
      );
      expect(
        find.textContaining('preço apresentado é informativo'),
        findsOneWidget,
      );

      await tester.tap(find.text('Adicionar à comanda local'));
      await _finishRouteAnimation(tester);
      expect(cart.itemCount, 1);
      expect(cart.items.single.productId, 42);

      await tester.tap(find.byTooltip('Comanda local'));
      await _finishRouteAnimation(tester);

      expect(find.byType(OdooCartPage), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(OdooCartPage),
          matching: find.text('Cerveja Pilsen'),
        ),
        findsOneWidget,
      );
      expect(find.text(r'R$ 12,50 por unidade'), findsOneWidget);
      expect(cart.items.single.quantity, 1);

      await tester.tap(find.byTooltip('Aumentar'));
      await tester.pump();
      expect(cart.items.single.quantity, 2);
      expect(cart.subtotal, 25);
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text(r'R$ 25,00'), findsWidgets);

      await tester.tap(find.text('Adicionar nota'));
      await _finishRouteAnimation(tester);
      final noteField = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(noteField, 'sem gelo');
      await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
      await _finishRouteAnimation(tester);

      expect(cart.items.single.note, 'sem gelo');
      expect(find.text('Nota: sem gelo'), findsOneWidget);
      expect(
        find.text(
          'Sem pedido, pagamento, stock ou lançamento fiscal no Odoo.',
        ),
        findsOneWidget,
      );

      expect(httpClient.unexpectedPaths, isEmpty);
      expect(
        httpClient.requestPaths.where((path) => path.endsWith('/search_count')),
        hasLength(2),
      );
    },
  );
}
