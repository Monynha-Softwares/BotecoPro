import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:boteco_pro/models/connection.dart';
import 'package:boteco_pro/services/odoo/odoo_client.dart';
import 'package:boteco_pro/services/odoo/odoo_exception.dart';

class _FakeClient extends http.BaseClient {
  _FakeClient(this.handler);

  final Future<http.Response> Function(http.BaseRequest request) handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await handler(request);
    return http.StreamedResponse(
      http.ByteStream.fromBytes(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      request: request,
    );
  }
}

void main() {
  test('builds a JSON-2 request with bearer authentication', () async {
    late http.BaseRequest request;
    final fake = _FakeClient((incoming) async {
      request = incoming;
      return http.Response('{}', 200);
    });
    final client = OdooClient(
      connection: ConnectionConfig.fromInput(
        baseUrl: 'https://bar-do-jonas.odoo.com/',
        username: 'user@example.com',
        database: 'bar_do_jonas',
      ),
      apiKey: 'unit-test-placeholder',
      httpClient: fake,
    );

    await client.call('res.users', 'context_get');

    expect(request.url.path, '/json/2/res.users/context_get');
    expect(request.headers['Authorization'], 'bearer unit-test-placeholder');
    expect(request.headers['X-Odoo-Database'], 'bar_do_jonas');
    expect(request.headers['Content-Type'], contains('application/json'));
  });

  test('redacts secrets in server errors and maps unauthorized responses',
      () async {
    final fake = _FakeClient((_) async {
      return http.Response(
        jsonEncode({
          'message': 'Invalid apikey unit-test-placeholder',
          'debug': 'traceback with credentials should not escape',
        }),
        401,
      );
    });
    final client = OdooClient(
      connection: ConnectionConfig.fromInput(
        baseUrl: 'https://bar-do-jonas.odoo.com',
        username: 'user@example.com',
      ),
      apiKey: 'unit-test-placeholder',
      httpClient: fake,
    );

    await expectLater(
      client.call('res.users', 'context_get'),
      throwsA(
        isA<OdooException>()
            .having((error) => error.kind, 'kind', OdooErrorKind.unauthorized)
            .having(
              (error) => error.message,
              'message',
              'Invalid apikey [redacted]',
            ),
      ),
    );
  });

  test('maps transport timeouts without leaking request credentials', () async {
    final fake = _FakeClient((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return http.Response('{}', 200);
    });
    final client = OdooClient(
      connection: ConnectionConfig.fromInput(
        baseUrl: 'https://bar-do-jonas.odoo.com',
        username: 'user@example.com',
      ),
      apiKey: 'unit-test-placeholder',
      httpClient: fake,
      timeout: const Duration(milliseconds: 1),
    );

    await expectLater(
      client.call('res.users', 'context_get'),
      throwsA(
        isA<OdooException>()
            .having((error) => error.kind, 'kind', OdooErrorKind.timeout)
            .having(
              (error) => error.toString(),
              'safe message',
              isNot(contains('unit-test-placeholder')),
            ),
      ),
    );
  });
}
