import 'dart:convert';

import 'package:http/http.dart' as http;

import 'odoo_connection.dart';
import 'odoo_exception.dart';

class OdooClient {
  OdooClient({
    required this.connection,
    required String apiKey,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 20),
  })  : _apiKey = apiKey,
        _http = httpClient ?? http.Client();

  final OdooConnection connection;
  final String _apiKey;
  final http.Client _http;
  final Duration timeout;

  Future<String> getVersion() async {
    try {
      final response = await _http.get(connection.versionUri).timeout(timeout);
      final body = _decode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw OdooException.fromHttp(
          statusCode: response.statusCode,
          body: body,
          sensitiveValues: [_apiKey],
        );
      }
      if (body is! Map<String, dynamic> || body['version'] == null) {
        throw const OdooException(
          kind: OdooErrorKind.unexpected,
          message: 'Resposta de versão do Odoo inválida.',
        );
      }
      return body['version'].toString();
    } on OdooException {
      rethrow;
    } catch (_) {
      throw const OdooException(
        kind: OdooErrorKind.network,
        message: 'Não foi possível comunicar com o Odoo.',
      );
    }
  }

  Future<dynamic> call(
    String model,
    String method, {
    Map<String, dynamic> arguments = const {},
  }) async {
    if (_apiKey.trim().isEmpty) {
      throw const OdooException(
        kind: OdooErrorKind.invalidConfiguration,
        message: 'Informe uma API key do Odoo.',
      );
    }

    final headers = <String, String>{
      'Authorization': 'bearer $_apiKey',
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      'User-Agent': 'BotecoPRO Flutter Odoo JSON-2',
    };
    if (connection.database != null) {
      headers['X-Odoo-Database'] = connection.database!;
    }

    try {
      final response = await _http
          .post(
            connection.json2Uri(model, method),
            headers: headers,
            body: jsonEncode(arguments),
          )
          .timeout(timeout);
      final body = _decode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw OdooException.fromHttp(
          statusCode: response.statusCode,
          body: body,
          sensitiveValues: [_apiKey],
        );
      }
      return body;
    } on OdooException {
      rethrow;
    } catch (_) {
      throw const OdooException(
        kind: OdooErrorKind.network,
        message: 'Não foi possível comunicar com o Odoo.',
      );
    }
  }

  dynamic _decode(String raw) {
    if (raw.trim().isEmpty) return <String, dynamic>{};
    try {
      return jsonDecode(raw);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  void close() => _http.close();
}
