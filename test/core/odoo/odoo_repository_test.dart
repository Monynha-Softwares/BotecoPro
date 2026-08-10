import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:boteco_pro/core/odoo/odoo_client.dart';
import 'package:boteco_pro/core/odoo/odoo_connection.dart';
import 'package:boteco_pro/core/odoo/odoo_repository.dart';

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

OdooClient _client(Future<http.Response> Function(http.BaseRequest) handler) {
  return OdooClient(
    connection: OdooConnection.fromInput(
      baseUrl: 'https://odoo.example.com',
      username: 'user@example.com',
    ),
    apiKey: 'test-api-key',
    httpClient: _FakeClient(handler),
  );
}

OdooPosConfig _posConfig(List<int> categoryIds) {
  return OdooPosConfig(
    id: 1,
    name: 'POS principal',
    companyId: 1,
    active: true,
    limitCategories: true,
    categoryIds: categoryIds,
    restaurant: false,
  );
}

void main() {
  test('reports an empty catalog for incompatible POS categories', () async {
    late Map<String, dynamic> countRequest;
    final repository = OdooRepository(_client((request) async {
      final body =
          jsonDecode((request as http.Request).body) as Map<String, dynamic>;
      if (request.url.path.endsWith('/pos.config/search_read')) {
        return http.Response(
          jsonEncode([
            {
              'id': 1,
              'name': 'POS principal',
              'company_id': [1, 'Company'],
              'active': true,
              'limit_categories': true,
              'iface_available_categ_ids': [1, 2],
              'module_pos_restaurant': false,
              'current_session_state': false,
              'currency_id': false,
              'pricelist_id': false,
            },
          ]),
          200,
        );
      }
      countRequest = body;
      return http.Response('0', 200);
    }));

    final configs = await repository.listPosConfigs(companyId: 1);

    expect(configs, hasLength(1));
    expect(configs.single.catalogProductCount, 0);
    expect(configs.single.hasCatalogProducts, isFalse);
    expect(countRequest['context'], {
      'allowed_company_ids': [1]
    });
    expect(
      countRequest['domain'],
      [
        ['active', '=', true],
        ['product_tmpl_id.available_in_pos', '=', true],
        [
          'product_tmpl_id.pos_categ_ids',
          'in',
          [1, 2]
        ],
      ],
    );
  });

  test(
      'uses the same category domain, company context and pagination for products',
      () async {
    late Map<String, dynamic> requestBody;
    final repository = OdooRepository(_client((request) async {
      requestBody =
          jsonDecode((request as http.Request).body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode([
          {
            'id': 42,
            'display_name': 'Produto Odoo',
            'lst_price': 12.5,
            'product_tmpl_id': [9, 'Produto Odoo'],
            'default_code': 'SKU-42',
            'barcode': false,
            'uom_id': [1, 'Units'],
            'pos_categ_ids': [4],
            'write_date': '2026-08-10 12:00:00',
          },
        ]),
        200,
      );
    }));

    final products = await repository.listProducts(
      companyId: 1,
      posConfig: _posConfig([4, 5, 6, 7, 8]),
      offset: 100,
      limit: 100,
    );

    expect(products.single.id, 42);
    expect(requestBody['offset'], 100);
    expect(requestBody['limit'], 100);
    expect(requestBody['context'], {
      'allowed_company_ids': [1]
    });
    expect(
      requestBody['domain'],
      [
        ['active', '=', true],
        ['product_tmpl_id.available_in_pos', '=', true],
        [
          'product_tmpl_id.pos_categ_ids',
          'in',
          [4, 5, 6, 7, 8]
        ],
      ],
    );
  });
}
