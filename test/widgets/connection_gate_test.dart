import 'dart:async';
import 'dart:convert';

import 'package:boteco_pro/models/connection.dart';
import 'package:boteco_pro/pages/connection/connection_gate.dart';
import 'package:boteco_pro/providers/odoo_session_provider.dart';
import 'package:boteco_pro/services/odoo/odoo_client.dart';
import 'package:boteco_pro/services/odoo/odoo_runtime.dart';
import 'package:boteco_pro/services/storage/credentials_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class _MemoryCredentialsStorage extends CredentialsStorageService {
  const _MemoryCredentialsStorage();

  @override
  Future<ConnectionConfig?> readConnection() async => null;

  @override
  Future<String?> readApiKey() async => null;
}

class _RejectedClient extends http.BaseClient {
  final requestStarted = Completer<void>();
  final releaseRequest = Completer<void>();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (!requestStarted.isCompleted) requestStarted.complete();
    await releaseRequest.future;
    final body = utf8.encode(jsonEncode(<String, Object?>{}));
    return http.StreamedResponse(
      http.ByteStream.fromBytes(body),
      401,
      request: request,
    );
  }
}

Finder _field(String label) => find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == label,
    );

String _fieldValue(WidgetTester tester, String label) =>
    tester.widget<TextField>(_field(label)).controller!.text;

void main() {
  testWidgets('connection form survives a rejected authentication attempt',
      (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final client = _RejectedClient();
    final session = OdooSessionProvider(
      credentialsStorage: const _MemoryCredentialsStorage(),
      runtimeFactory: OdooRuntimeFactory(
        clientBuilder: (connection, apiKey) => OdooClient(
          connection: connection,
          apiKey: apiKey,
          httpClient: client,
        ),
      ),
    );
    addTearDown(session.dispose);
    await session.initialize();

    await tester.pumpWidget(
      ChangeNotifierProvider<OdooSessionProvider>.value(
        value: session,
        child: const MaterialApp(home: ConnectionGate()),
      ),
    );

    await tester.enterText(_field('Instância'), 'https://odoo.example.test');
    await tester.enterText(_field('Utilizador'), 'operator@example.test');
    await tester.enterText(_field('Base de dados (opcional)'), 'example');
    await tester.enterText(_field('API key'), 'sentinel-widget-key');
    final connectButton = find.widgetWithText(FilledButton, 'Testar conexão');
    await tester.ensureVisible(connectButton);
    await tester.tap(connectButton);
    await client.requestStarted.future;
    await tester.pump();

    expect(session.state, OdooSessionState.connecting);
    expect(find.text('Conectar ao Odoo'), findsWidgets);
    expect(_fieldValue(tester, 'Instância'), 'https://odoo.example.test');
    expect(_fieldValue(tester, 'Utilizador'), 'operator@example.test');
    expect(_fieldValue(tester, 'Base de dados (opcional)'), 'example');

    client.releaseRequest.complete();
    for (var attempt = 0;
        attempt < 20 && session.state != OdooSessionState.error;
        attempt++) {
      await tester.pump(const Duration(milliseconds: 10));
    }

    expect(session.state, OdooSessionState.error);
    expect(find.text('Conectar ao Odoo'), findsWidgets);
    expect(_fieldValue(tester, 'Instância'), 'https://odoo.example.test');
    expect(_fieldValue(tester, 'Utilizador'), 'operator@example.test');
    expect(_fieldValue(tester, 'Base de dados (opcional)'), 'example');
    expect(find.textContaining('API key inválida'), findsOneWidget);
    expect(session.error?.message, isNot(contains('sentinel-widget-key')));
    expect(tester.widget<TextField>(_field('API key')).obscureText, isTrue);
  });
}
