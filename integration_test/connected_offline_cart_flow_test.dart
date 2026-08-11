import 'package:boteco_pro/main.dart';
import 'package:boteco_pro/models/sync_snapshot.dart';
import 'package:boteco_pro/services/odoo/odoo_client.dart';
import 'package:boteco_pro/services/odoo/odoo_runtime.dart';
import 'package:boteco_pro/services/storage/cart_storage_service.dart';
import 'package:boteco_pro/services/storage/credentials_storage_service.dart';
import 'package:boteco_pro/services/storage/snapshot_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/synthetic_odoo.dart';

const _namespace = 'botecopro.integration.synthetic.v1';
const _context = OperationalContext(
  instanceKey: syntheticBaseUrl,
  userId: 101,
  companyId: 301,
  posConfigId: 201,
);

const _credentials = CredentialsStorageService(namespace: _namespace);
const _snapshots = SnapshotStorageService(namespace: _namespace);
const _cartStorage = CartStorageService(namespace: _namespace);

BotecoProDependencies _dependencies(SyntheticOdooHttpClient client) =>
    BotecoProDependencies(
      credentialsStorage: _credentials,
      snapshotStorage: _snapshots,
      cartStorage: _cartStorage,
      runtimeFactory: OdooRuntimeFactory(
        clientBuilder: (connection, apiKey) => OdooClient(
          connection: connection,
          apiKey: apiKey,
          httpClient: client,
        ),
      ),
    );

Future<void> _waitFor(
  WidgetTester tester,
  bool Function() condition, {
  required String reason,
  Duration timeout = const Duration(seconds: 20),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (condition()) return;
  }
  fail(reason);
}

Future<void> _waitForFinder(
  WidgetTester tester,
  Finder finder, {
  required String reason,
}) =>
    _waitFor(tester, () => finder.evaluate().isNotEmpty, reason: reason);

Future<void> _waitForStoredCart(
  WidgetTester tester, {
  required int quantity,
}) async {
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (DateTime.now().isBefore(deadline)) {
    final cart = await _cartStorage.read(_context);
    if (cart != null &&
        cart.items.single.quantity == quantity &&
        cart.items.single.note == 'sem gelo' &&
        cart.table?.id == syntheticTableId) {
      return;
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
  fail('A comanda isolada não foi persistida dentro do timeout.');
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'synthetic connected, offline and cart recovery journey',
    (tester) async {
      final startedAt = DateTime.now().toUtc();
      final steps = <Map<String, Object?>>[];
      final scenarioResult = <String, Object?>{
        'scenario': 'synthetic-connected-offline-cart',
        'status': 'running',
        'started_at': startedAt.toIso8601String(),
        'steps': steps,
      };
      binding.reportData = {'scenario_result': scenarioResult};
      var currentStep = 'connection-flow';

      Future<void> capture(String step, String screenshot) async {
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull,
            reason: 'A tela $step produziu uma exceção Flutter.');
        final bytes = await binding.takeScreenshot(screenshot);
        expect(bytes, isNotEmpty);
        steps.add({
          'name': step,
          'status': 'passed',
          'screenshot': '$screenshot.png',
        });
      }

      final transport = SyntheticOdooHttpClient();
      final dependencies = _dependencies(transport);
      await initializeBotecoProPlatform();
      await _credentials.clear();
      await _snapshots.clear();
      await _cartStorage.clear();
      addTearDown(() async {
        transport.offline = false;
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await _credentials.clear();
        await _snapshots.clear();
        await _cartStorage.clear();
      });

      try {
        await tester.pumpWidget(BotecoProApp(dependencies: dependencies));
        await _waitForFinder(
          tester,
          find.byKey(const Key('connection.submit')),
          reason: 'ConnectionGate não exibiu o formulário inicial.',
        );
        expect(find.text('Conectar ao Odoo'), findsWidgets);

        await tester.enterText(
          find.byKey(const Key('connection.url')),
          syntheticBaseUrl,
        );
        await tester.enterText(
          find.byKey(const Key('connection.username')),
          syntheticUsername,
        );
        await tester.enterText(
          find.byKey(const Key('connection.api_key')),
          syntheticApiKey,
        );
        await tester.ensureVisible(find.byKey(const Key('connection.submit')));
        await tester.tap(find.byKey(const Key('connection.submit')));

        await _waitForFinder(
          tester,
          find.byKey(const Key('connected.home')),
          reason: 'A conexão Odoo sintética não alcançou o shell conectado.',
        );
        await _waitForFinder(
          tester,
          find.text('Online'),
          reason: 'O snapshot sintético inicial não terminou de sincronizar.',
        );
        expect(find.text('Boteco Demo QA'), findsOneWidget);
        currentStep = 'connected-home';
        await tester.tap(find.byKey(const Key('navigation.pos')));
        await _waitForFinder(
          tester,
          find.text('Boteco Demo POS'),
          reason: 'A POS sintética selecionada não apareceu na UI real.',
        );
        expect(find.text('Contexto Restaurant'), findsOneWidget);
        await tester.tap(find.byKey(const Key('navigation.home')));
        await tester.pumpAndSettle();
        await binding.convertFlutterSurfaceToImage();
        await capture('connected-home', '01-connected-home');

        currentStep = 'catalog';
        await tester.tap(find.byKey(const Key('navigation.products')));
        await _waitForFinder(
          tester,
          find.byKey(const Key('catalog.product.$syntheticProductId')),
          reason: 'O catálogo sintético não renderizou o produto principal.',
        );
        expect(find.text('Produtos POS'), findsOneWidget);
        expect(find.text('Online'), findsOneWidget);
        await capture('catalog', '02-catalog');

        currentStep = 'category-filter';
        await tester.tap(
          find.byKey(const Key('catalog.category.$syntheticCategoryId')),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('catalog.product.1001')), findsOneWidget);
        expect(find.byKey(const Key('catalog.product.1002')), findsOneWidget);
        expect(find.byKey(const Key('catalog.product.1005')), findsNothing);
        await capture('category-filter', '03-category-filter');

        currentStep = 'search-result';
        await tester.tap(find.byKey(const Key('catalog.category.all')));
        await tester.enterText(
          find.byKey(const Key('catalog.search')),
          'Aurora Zero',
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('catalog.product.1001')), findsOneWidget);
        expect(find.byKey(const Key('catalog.product.1002')), findsNothing);
        await capture('search-result', '04-search-result');

        currentStep = 'product-detail';
        await tester.tap(find.byKey(const Key('catalog.product.1001')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('catalog.product.detail.1001')),
          findsOneWidget,
        );
        expect(find.text(r'Valor de catálogo Odoo: R$ 12,50'), findsOneWidget);
        await capture('product-detail', '05-product-detail');

        currentStep = 'cart';
        await tester.tap(
          find.byKey(const Key('catalog.product.detail.add.1001')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('cart.open')));
        await _waitForFinder(
          tester,
          find.byKey(const Key('cart.item.1001')),
          reason: 'A comanda não exibiu o produto adicionado.',
        );
        await tester.tap(find.byKey(const Key('cart.quantity.plus.1001')));
        await tester.pumpAndSettle();
        expect(find.text('2'), findsWidgets);

        await tester.tap(find.byKey(const Key('cart.note.1001')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('cart.note.field.1001')),
          'sem gelo',
        );
        await tester.tap(find.byKey(const Key('cart.note.save.1001')));
        await tester.pumpAndSettle();
        expect(find.text('Nota: sem gelo'), findsOneWidget);
        expect(
          tester.widget<Text>(find.byKey(const Key('cart.subtotal'))).data,
          r'R$ 25,00',
        );
        await capture('cart', '06-cart');

        currentStep = 'table-selected';
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pump(const Duration(seconds: 1));
        final tableSelector =
            find.byKey(const Key('restaurant.table.selector'));
        await tester.ensureVisible(tableSelector);
        await tester.pumpAndSettle();
        final tableField = tester.widget<DropdownButtonFormField<int>>(
          tableSelector,
        );
        expect(tableField.onChanged, isNotNull);
        // Dropdown popup routes render as a black surface under flutter drive
        // on the API 36 emulator. Invoke the field's real callback so this
        // scenario validates selection, persistence and recovery without a
        // platform-overlay hit-test dependency.
        tableField.onChanged!(syntheticTableId);
        await tester.pumpAndSettle();
        expect(find.text('Salão · Mesa 1'), findsOneWidget);
        await _waitForStoredCart(tester, quantity: 2);
        await capture('table-selected', '07-table-selected');

        currentStep = 'offline-catalog';
        await tester.pageBack();
        await tester.pumpAndSettle();
        transport.offline = true;
        await tester.tap(find.byKey(const Key('catalog.refresh')));
        await _waitForFinder(
          tester,
          find.text('Offline · Dados locais'),
          reason: 'A falha no transporte não ativou o snapshot offline real.',
        );
        expect(find.byKey(const Key('catalog.product.1001')), findsOneWidget);
        await capture('offline-catalog', '08-offline-catalog');

        currentStep = 'restored-cart';
        await tester.tap(find.byKey(const Key('cart.open')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('cart.quantity.plus.1001')));
        await tester.pumpAndSettle();
        expect(find.text('3'), findsWidgets);
        expect(
          tester.widget<Text>(find.byKey(const Key('cart.subtotal'))).data,
          r'R$ 37,50',
        );
        await _waitForStoredCart(tester, quantity: 3);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await tester.pumpWidget(
          BotecoProApp(
            key: const ValueKey('integration.restart'),
            dependencies: dependencies,
          ),
        );
        await _waitForFinder(
          tester,
          find.text('Offline · Dados locais'),
          reason: 'A recriação do app não restaurou o snapshot offline.',
        );
        await tester.tap(find.byKey(const Key('navigation.products')));
        await _waitForFinder(
          tester,
          find.byKey(const Key('catalog.product.1001')),
          reason: 'O catálogo não foi restaurado após recriar providers.',
        );
        await tester.tap(find.byKey(const Key('cart.open')));
        await _waitForFinder(
          tester,
          find.byKey(const Key('cart.item.1001')),
          reason: 'A comanda não foi restaurada da persistência isolada.',
        );
        expect(find.text('3'), findsWidgets);
        expect(find.text('Nota: sem gelo'), findsOneWidget);
        expect(find.text('Salão · Mesa 1'), findsOneWidget);
        expect(
          tester.widget<Text>(find.byKey(const Key('cart.subtotal'))).data,
          r'R$ 37,50',
        );
        await capture('restored-cart', '09-restored-cart');

        currentStep = 'online-restored';
        await tester.pageBack();
        await tester.pumpAndSettle();
        transport.offline = false;
        await tester.tap(find.byKey(const Key('sync.retry')));
        await _waitForFinder(
          tester,
          find.text('Online'),
          reason: 'A sessão não retornou ao estado online.',
        );
        expect(find.byKey(const Key('catalog.product.1001')), findsOneWidget);
        expect(transport.writeAttempts, isEmpty,
            reason: 'O cenário sintético tentou executar um write Odoo.');
        steps.add({'name': 'online-restored', 'status': 'passed'});

        scenarioResult['status'] = 'passed';
        scenarioResult['finished_at'] =
            DateTime.now().toUtc().toIso8601String();
        scenarioResult['duration_ms'] =
            DateTime.now().toUtc().difference(startedAt).inMilliseconds;
        scenarioResult['request_count'] = transport.requestPaths.length;
        scenarioResult['odoo_write_count'] = transport.writeAttempts.length;
      } catch (error) {
        scenarioResult['status'] = 'failed';
        scenarioResult['failed_step'] = currentStep;
        scenarioResult['error_category'] = error.runtimeType.toString();
        scenarioResult['finished_at'] =
            DateTime.now().toUtc().toIso8601String();
        rethrow;
      }
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
