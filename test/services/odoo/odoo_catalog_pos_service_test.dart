import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:boteco_pro/models/connection.dart';
import 'package:boteco_pro/models/pos_config.dart';
import 'package:boteco_pro/services/odoo/odoo_catalog_service.dart';
import 'package:boteco_pro/services/odoo/odoo_client.dart';
import 'package:boteco_pro/services/odoo/odoo_exception.dart';
import 'package:boteco_pro/services/odoo/odoo_pos_service.dart';

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
    connection: ConnectionConfig.fromInput(
      baseUrl: 'https://odoo.example.com',
      username: 'user@example.com',
    ),
    apiKey: 'test-api-key',
    httpClient: _FakeClient(handler),
  );
}

({OdooCatalogService catalog, OdooPosService pos}) _services(
  Future<http.Response> Function(http.BaseRequest) handler,
) {
  final client = _client(handler);
  final catalog = OdooCatalogService(client);
  return (catalog: catalog, pos: OdooPosService(client, catalog));
}

PosConfig _posConfig(List<int> categoryIds) {
  return PosConfig(
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
    final services = _services((request) async {
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
              'currency_id': [6, 'BRL'],
              'pricelist_id': [9, 'Tabela padrão'],
              'available_pricelist_ids': [9, 10],
              'use_pricelist': true,
              'payment_method_ids': [20, 21],
              'current_session_id': false,
            },
          ]),
          200,
        );
      }
      countRequest = body;
      return http.Response('0', 200);
    });

    final configs = await services.pos.listPosConfigs(companyId: 1);

    expect(configs, hasLength(1));
    expect(configs.single.catalogProductCount, 0);
    expect(configs.single.hasCatalogProducts, isFalse);
    expect(configs.single.currencyId, 6);
    expect(configs.single.pricelistId, 9);
    expect(configs.single.availablePricelistIds, [9, 10]);
    expect(configs.single.usePricelist, isTrue);
    expect(configs.single.paymentMethodIds, [20, 21]);
    expect(configs.single.currentSessionId, isNull);
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
    final services = _services((request) async {
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
            'currency_id': [6, 'BRL'],
            'pos_categ_ids': [4],
            'write_date': '2026-08-10 12:00:00',
          },
        ]),
        200,
      );
    });

    final products = await services.catalog.listProducts(
      companyId: 1,
      posConfig: _posConfig([4, 5, 6, 7, 8]),
      offset: 100,
      limit: 100,
    );

    expect(products.single.id, 42);
    expect(products.single.currencyId, 6);
    expect(requestBody['offset'], 100);
    expect(requestBody['limit'], 100);
    expect(requestBody['order'], 'id');
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

  test(
      'reads restaurant floors and active tables with the selected POS context',
      () async {
    final requests = <String, Map<String, dynamic>>{};
    final services = _services((request) async {
      final body =
          jsonDecode((request as http.Request).body) as Map<String, dynamic>;
      requests[request.url.path] = body;
      if (request.url.path.endsWith('/restaurant.floor/search_read')) {
        return http.Response(
          jsonEncode([
            {
              'id': 2,
              'name': 'Salão',
              'pos_config_ids': [1],
            },
          ]),
          200,
        );
      }
      return http.Response(
        jsonEncode([
          {
            'id': 8,
            'table_number': 12,
            'seats': 4,
            'floor_id': [2, 'Salão'],
            'active': true,
          },
        ]),
        200,
      );
    });

    final floors = await services.pos.listRestaurantFloors(
      companyId: 1,
      posConfigId: 1,
    );
    final tables = await services.pos.listRestaurantTables(
      companyId: 1,
      floors: floors,
    );

    expect(floors.single.name, 'Salão');
    expect(tables.single.label, 'Salão · Mesa 12');
    expect(
      requests['/json/2/restaurant.floor/search_read']?['domain'],
      [
        [
          'pos_config_ids',
          'in',
          [1]
        ],
      ],
    );
    expect(
      requests['/json/2/restaurant.table/search_read']?['domain'],
      [
        ['active', '=', true],
        [
          'floor_id',
          'in',
          [2]
        ],
      ],
    );
  });

  test('loads currency, pricelist, sessions and configured payment methods',
      () async {
    final requests = <String, Map<String, dynamic>>{};
    final services = _services((request) async {
      final body =
          jsonDecode((request as http.Request).body) as Map<String, dynamic>;
      requests[request.url.path] = body;
      return switch (request.url.path) {
        '/json/2/res.currency/read' => http.Response(
            jsonEncode([
              {
                'id': 6,
                'name': 'BRL',
                'symbol': r'R$',
                'position': 'before',
                'decimal_places': 2,
                'rounding': 0.01,
              },
            ]),
            200,
          ),
        '/json/2/product.pricelist/read' => http.Response(
            jsonEncode([
              {
                'id': 9,
                'name': 'Tabela padrão',
                'currency_id': [6, 'BRL'],
                'company_id': [1, 'Empresa'],
                'active': true,
              },
            ]),
            200,
          ),
        '/json/2/pos.session/search_read' => http.Response(
            jsonEncode([
              {
                'id': 12,
                'name': 'POS/0012',
                'state': 'opened',
                'config_id': [1, 'POS principal'],
                'user_id': [2, 'Operador'],
                'currency_id': [6, 'BRL'],
                'payment_method_ids': [20, 21],
                'rescue': false,
                'start_at': '2026-08-10 12:00:00',
                'stop_at': false,
              },
            ]),
            200,
          ),
        '/json/2/pos.payment.method/read' => http.Response(
            jsonEncode([
              {
                'id': 20,
                'name': 'Numerário',
                'active': true,
                'is_cash_count': true,
                'split_transactions': false,
                'sequence': 1,
                'type': 'cash',
                'payment_method_type': 'none',
              },
              {
                'id': 21,
                'name': 'Cartão',
                'active': true,
                'is_cash_count': false,
                'split_transactions': true,
                'sequence': 2,
                'type': 'bank',
                'payment_method_type': 'terminal',
              },
            ]),
            200,
          ),
        _ => http.Response('{}', 404),
      };
    });
    final config = PosConfig(
      id: 1,
      name: 'POS principal',
      companyId: 1,
      active: true,
      limitCategories: false,
      categoryIds: const [],
      restaurant: true,
      currencyId: 6,
      pricelistId: 9,
      availablePricelistIds: const [9],
      usePricelist: true,
      paymentMethodIds: const [20, 21],
      currentSessionId: 12,
    );

    final profile = await services.pos.loadOperationalProfile(
      companyId: 1,
      posConfig: config,
    );

    expect(profile.currency.name, 'BRL');
    expect(profile.currency.symbol, r'R$');
    expect(profile.pricelist?.id, 9);
    expect(profile.nonClosedSessions.single.userName, 'Operador');
    expect(
      profile.nonClosedSessions.single.startedAt,
      DateTime.utc(2026, 8, 10, 12),
    );
    expect(profile.paymentMethods, hasLength(2));
    expect(profile.pricelistReadable, isTrue);
    expect(profile.hasOpenedSession, isTrue);
    expect(profile.paymentMethods.first.isCashCount, isTrue);
    expect(profile.sessionsReadable, isTrue);
    expect(profile.paymentMethodsReadable, isTrue);
    expect(
      requests['/json/2/pos.session/search_read']?['domain'],
      [
        ['config_id', '=', 1],
        ['rescue', '=', false],
        [
          'state',
          'in',
          ['opening_control', 'opened', 'closing_control'],
        ],
      ],
    );
    expect(
      requests['/json/2/pos.payment.method/read']?['ids'],
      [20, 21],
    );
    expect(
      requests.values,
      everyElement(
        containsPair('context', {
          'allowed_company_ids': [1]
        }),
      ),
    );
  });

  test('keeps essential profile when optional POS reads are forbidden',
      () async {
    final services = _services((request) async {
      if (request.url.path.endsWith('/res.currency/read')) {
        return http.Response(
          jsonEncode([
            {
              'id': 6,
              'name': 'BRL',
              'symbol': r'R$',
              'position': 'before',
              'decimal_places': 2,
              'rounding': 0.01,
            },
          ]),
          200,
        );
      }
      return http.Response(jsonEncode({'message': 'Access denied'}), 403);
    });

    final profile = await services.pos.loadOperationalProfile(
      companyId: 1,
      posConfig: PosConfig(
        id: 1,
        name: 'POS principal',
        companyId: 1,
        active: true,
        limitCategories: false,
        categoryIds: const [],
        restaurant: false,
        currencyId: 6,
        paymentMethodIds: const [20],
      ),
    );

    expect(profile.currency.id, 6);
    expect(profile.sessionsReadable, isFalse);
    expect(profile.paymentMethodsReadable, isFalse);
    expect(profile.nonClosedSessions, isEmpty);
    expect(profile.paymentMethods, isEmpty);
  });

  test('keeps currency when the configured pricelist is not readable',
      () async {
    final services = _services((request) async {
      return switch (request.url.path) {
        '/json/2/res.currency/read' => http.Response(
            jsonEncode([
              {
                'id': 6,
                'name': 'BRL',
                'symbol': r'R$',
                'position': 'before',
                'decimal_places': 2,
                'rounding': 0.01,
              },
            ]),
            200,
          ),
        '/json/2/product.pricelist/read' =>
          http.Response(jsonEncode({'message': 'Access denied'}), 403),
        '/json/2/pos.session/search_read' => http.Response('[]', 200),
        _ => http.Response('{}', 404),
      };
    });

    final profile = await services.pos.loadOperationalProfile(
      companyId: 1,
      posConfig: const PosConfig(
        id: 1,
        name: 'POS principal',
        companyId: 1,
        active: true,
        limitCategories: false,
        categoryIds: [],
        restaurant: false,
        currencyId: 6,
        pricelistId: 9,
        usePricelist: true,
      ),
    );

    expect(profile.currency.id, 6);
    expect(profile.pricelist, isNull);
    expect(profile.pricelistReadable, isFalse);
    expect(profile.nonClosedSessions, isEmpty);
  });

  test('rejects a missing catalog value instead of inventing zero', () async {
    final services = _services((request) async => http.Response(
          jsonEncode([
            {
              'id': 42,
              'display_name': 'Produto sem preço',
              'product_tmpl_id': [9, 'Produto'],
              'uom_id': [1, 'Units'],
              'currency_id': [6, 'BRL'],
              'pos_categ_ids': [4],
            },
          ]),
          200,
        ));

    expect(
      () => services.catalog.listProducts(
        companyId: 1,
        posConfig: _posConfig([4]),
      ),
      throwsA(isA<OdooException>()),
    );
  });

  test('accepts an explicit zero catalog value', () async {
    final services = _services((request) async => http.Response(
          jsonEncode([
            {
              'id': 42,
              'display_name': 'Produto gratuito',
              'lst_price': 0,
              'product_tmpl_id': [9, 'Produto'],
              'uom_id': [1, 'Units'],
              'currency_id': [6, 'BRL'],
              'pos_categ_ids': [4],
            },
          ]),
          200,
        ));

    final products = await services.catalog.listProducts(
      companyId: 1,
      posConfig: _posConfig([4]),
    );

    expect(products.single.catalogPrice, 0);
  });
}
