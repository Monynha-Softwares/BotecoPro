import 'dart:convert';

import 'package:http/http.dart' as http;

const syntheticBaseUrl = 'https://synthetic-odoo.invalid';
const syntheticUsername = 'qa.operator@example.invalid';
const syntheticApiKey = 'synthetic-integration-key';
const syntheticProductId = 1001;
const syntheticCategoryId = 401;
const syntheticTableId = 701;

class SyntheticOdooHttpClient extends http.BaseClient {
  bool offline = false;
  final requestPaths = <String>[];
  final writeAttempts = <String>[];

  static const _readMethods = {
    'context_get',
    'read',
    'search_count',
    'search_read',
  };

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requestPaths.add(request.url.path);
    if (offline) {
      throw http.ClientException('Synthetic transport is offline.');
    }
    if (request.method == 'GET' && request.url.path == '/web/version') {
      return _response(request, {'version': 'saas~19.4+e-synthetic'});
    }
    if (request.method != 'POST' || !request.url.path.startsWith('/json/2/')) {
      return _response(
          request, {'message': 'Unsupported synthetic request'}, 404);
    }

    final segments = request.url.pathSegments;
    final model = Uri.decodeComponent(segments[2]);
    final method = Uri.decodeComponent(segments[3]);
    if (!_readMethods.contains(method)) {
      writeAttempts.add('$model/$method');
      return _response(
          request, {'message': 'Synthetic fixture is read-only'}, 405);
    }
    final arguments = request is http.Request && request.body.isNotEmpty
        ? Map<String, dynamic>.from(jsonDecode(request.body) as Map)
        : <String, dynamic>{};
    return _response(request, _payload(model, method, arguments));
  }

  dynamic _payload(
    String model,
    String method,
    Map<String, dynamic> arguments,
  ) {
    if (model == 'res.users' && method == 'context_get') {
      return {'uid': 101, 'lang': 'pt_BR', 'tz': 'America/Sao_Paulo'};
    }
    if (model == 'res.users' && method == 'search_read') {
      return [
        {
          'id': 101,
          'name': 'Operadora Sintética QA',
          'login': syntheticUsername,
          'company_id': [301, 'Boteco Demo QA'],
          'company_ids': [301],
          'lang': 'pt_BR',
          'tz': 'America/Sao_Paulo',
        }
      ];
    }
    if (model == 'res.company' && method == 'search_read') {
      if (_isAccessProbe(arguments)) {
        return [
          {'id': 301}
        ];
      }
      return [
        {
          'id': 301,
          'name': 'Boteco Demo QA',
          'currency_id': [601, 'BRL'],
          'country_id': [30, 'Brasil'],
        }
      ];
    }
    if (model == 'pos.config' && method == 'search_read') {
      if (_isAccessProbe(arguments)) {
        return [
          {'id': 201}
        ];
      }
      return [
        {
          'id': 201,
          'name': 'Boteco Demo POS',
          'company_id': [301, 'Boteco Demo QA'],
          'active': true,
          'limit_categories': true,
          'iface_available_categ_ids': [401, 402, 403, 404, 405],
          'module_pos_restaurant': true,
          'current_session_state': 'opened',
          'currency_id': [601, 'BRL'],
          'pricelist_id': false,
          'available_pricelist_ids': <int>[],
          'use_pricelist': false,
          'payment_method_ids': [801, 802],
          'current_session_id': [901, 'QA/0001'],
        }
      ];
    }
    if (model == 'pos.category' && method == 'search_read') {
      if (_isAccessProbe(arguments)) {
        return [
          {'id': 401}
        ];
      }
      return const [
        {'id': 401, 'name': 'Cervejas', 'parent_id': false},
        {'id': 402, 'name': 'Drinks', 'parent_id': false},
        {'id': 403, 'name': 'Comidas', 'parent_id': false},
        {'id': 404, 'name': 'Águas', 'parent_id': false},
        {'id': 405, 'name': 'Outros', 'parent_id': false},
      ];
    }
    if (model == 'product.product' && method == 'search_count') return 20;
    if (model == 'product.product' && method == 'search_read') {
      if (_isAccessProbe(arguments)) {
        return [
          {'id': syntheticProductId}
        ];
      }
      return _products;
    }
    if (model == 'res.currency' && method == 'read') {
      return const [
        {
          'id': 601,
          'name': 'BRL',
          'symbol': r'R$',
          'position': 'before',
          'decimal_places': 2,
          'rounding': 0.01,
        }
      ];
    }
    if (model == 'pos.session' && method == 'search_read') {
      return const [
        {
          'id': 901,
          'name': 'QA/0001',
          'state': 'opened',
          'config_id': [201, 'Boteco Demo POS'],
          'user_id': [101, 'Operadora Sintética QA'],
          'currency_id': [601, 'BRL'],
          'payment_method_ids': [801, 802],
          'rescue': false,
          'start_at': '2026-08-11 08:00:00',
          'stop_at': false,
        }
      ];
    }
    if (model == 'pos.payment.method' && method == 'read') {
      return const [
        {
          'id': 801,
          'name': 'Dinheiro QA',
          'active': true,
          'is_cash_count': true,
          'split_transactions': false,
          'sequence': 1,
          'type': 'cash',
          'payment_method_type': 'none',
        },
        {
          'id': 802,
          'name': 'Cartão QA',
          'active': true,
          'is_cash_count': false,
          'split_transactions': false,
          'sequence': 2,
          'type': 'bank',
          'payment_method_type': 'none',
        },
      ];
    }
    if (model == 'restaurant.floor' && method == 'search_read') {
      return const [
        {
          'id': 501,
          'name': 'Salão',
          'pos_config_ids': [201]
        },
        {
          'id': 502,
          'name': 'Varanda',
          'pos_config_ids': [201]
        },
      ];
    }
    if (model == 'restaurant.table' && method == 'search_read') {
      return [
        for (var number = 1; number <= 12; number++)
          {
            'id': 700 + number,
            'table_number': number,
            'seats': number <= 8 ? 4 : 2,
            'floor_id': number <= 8 ? [501, 'Salão'] : [502, 'Varanda'],
            'active': true,
          }
      ];
    }
    throw StateError('Unexpected synthetic Odoo call: $model/$method');
  }

  bool _isAccessProbe(Map<String, dynamic> arguments) {
    final fields = arguments['fields'];
    return fields is List && fields.length == 1 && fields.single == 'id';
  }

  http.StreamedResponse _response(
    http.BaseRequest request,
    Object? body, [
    int statusCode = 200,
  ]) =>
      http.StreamedResponse(
        http.ByteStream.fromBytes(utf8.encode(jsonEncode(body))),
        statusCode,
        headers: const {'content-type': 'application/json'},
        request: request,
      );

  @override
  void close() {}
}

const _products = <Map<String, Object?>>[
  {
    'id': 1001,
    'display_name': 'Cerveja Aurora Zero',
    'lst_price': 12.5,
    'product_tmpl_id': [2001, 'Cerveja Aurora Zero'],
    'default_code': 'QA-CER-001',
    'barcode': '7900000001001',
    'uom_id': [1, 'Unidade'],
    'currency_id': [601, 'BRL'],
    'pos_categ_ids': [401],
    'write_date': '2026-08-11 08:00:00'
  },
  {
    'id': 1002,
    'display_name': 'Cerveja Horizonte Pilsen',
    'lst_price': 13.0,
    'product_tmpl_id': [2002, 'Cerveja Horizonte Pilsen'],
    'default_code': 'QA-CER-002',
    'barcode': '7900000001002',
    'uom_id': [1, 'Unidade'],
    'currency_id': [601, 'BRL'],
    'pos_categ_ids': [401],
    'write_date': '2026-08-11 08:00:00'
  },
  {
    'id': 1003,
    'display_name': 'Cerveja Neblina IPA',
    'lst_price': 16.0,
    'product_tmpl_id': [2003, 'Cerveja Neblina IPA'],
    'default_code': 'QA-CER-003',
    'barcode': '7900000001003',
    'uom_id': [1, 'Unidade'],
    'currency_id': [601, 'BRL'],
    'pos_categ_ids': [401],
    'write_date': '2026-08-11 08:00:00'
  },
  {
    'id': 1004,
    'display_name': 'Cerveja Farol Weiss',
    'lst_price': 15.5,
    'product_tmpl_id': [2004, 'Cerveja Farol Weiss'],
    'default_code': 'QA-CER-004',
    'barcode': '7900000001004',
    'uom_id': [1, 'Unidade'],
    'currency_id': [601, 'BRL'],
    'pos_categ_ids': [401],
    'write_date': '2026-08-11 08:00:00'
  },
  {
    'id': 1005,
    'display_name': 'Drink Brisa Cítrica',
    'lst_price': 22.0,
    'product_tmpl_id': [2005, 'Drink Brisa Cítrica'],
    'default_code': 'QA-DRK-001',
    'barcode': '7900000001005',
    'uom_id': [1, 'Unidade'],
    'currency_id': [601, 'BRL'],
    'pos_categ_ids': [402],
    'write_date': '2026-08-11 08:00:00'
  },
  {
    'id': 1006,
    'display_name': 'Drink Lua Azul',
    'lst_price': 24.0,
    'product_tmpl_id': [2006, 'Drink Lua Azul'],
    'default_code': 'QA-DRK-002',
    'barcode': '7900000001006',
    'uom_id': [1, 'Unidade'],
    'currency_id': [601, 'BRL'],
    'pos_categ_ids': [402],
    'write_date': '2026-08-11 08:00:00'
  },
  {
    'id': 1007,
    'display_name': 'Drink Jardim Tropical',
    'lst_price': 23.5,
    'product_tmpl_id': [2007, 'Drink Jardim Tropical'],
    'default_code': 'QA-DRK-003',
    'barcode': '7900000001007',
    'uom_id': [1, 'Unidade'],
    'currency_id': [601, 'BRL'],
    'pos_categ_ids': [402],
    'write_date': '2026-08-11 08:00:00'
  },
  {
    'id': 1008,
    'display_name': 'Drink Pôr do Sol',
    'lst_price': 25.0,
    'product_tmpl_id': [2008, 'Drink Pôr do Sol'],
    'default_code': 'QA-DRK-004',
    'barcode': '7900000001008',
    'uom_id': [1, 'Unidade'],
    'currency_id': [601, 'BRL'],
    'pos_categ_ids': [402],
    'write_date': '2026-08-11 08:00:00'
  },
  {
    'id': 1009,
    'display_name': 'Batata da Vila',
    'lst_price': 18.0,
    'product_tmpl_id': [2009, 'Batata da Vila'],
    'default_code': 'QA-COM-001',
    'barcode': '7900000001009',
    'uom_id': [1, 'Porção'],
    'currency_id': [601, 'BRL'],
    'pos_categ_ids': [403],
    'write_date': '2026-08-11 08:00:00'
  },
  {
    'id': 1010,
    'display_name': 'Bolinho Estação',
    'lst_price': 21.0,
    'product_tmpl_id': [2010, 'Bolinho Estação'],
    'default_code': 'QA-COM-002',
    'barcode': '7900000001010',
    'uom_id': [1, 'Porção'],
    'currency_id': [601, 'BRL'],
    'pos_categ_ids': [403],
    'write_date': '2026-08-11 08:00:00'
  },
  {
    'id': 1011,
    'display_name': 'Sanduíche do Bosque',
    'lst_price': 28.0,
    'product_tmpl_id': [2011, 'Sanduíche do Bosque'],
    'default_code': 'QA-COM-003',
    'barcode': '7900000001011',
    'uom_id': [1, 'Unidade'],
    'currency_id': [601, 'BRL'],
    'pos_categ_ids': [403],
    'write_date': '2026-08-11 08:00:00'
  },
  {
    'id': 1012,
    'display_name': 'Tábua Horizonte',
    'lst_price': 34.0,
    'product_tmpl_id': [2012, 'Tábua Horizonte'],
    'default_code': 'QA-COM-004',
    'barcode': '7900000001012',
    'uom_id': [1, 'Porção'],
    'currency_id': [601, 'BRL'],
    'pos_categ_ids': [403],
    'write_date': '2026-08-11 08:00:00'
  },
  {
    'id': 1013,
    'display_name': 'Água Serra Sem Gás',
    'lst_price': 6.0,
    'product_tmpl_id': [2013, 'Água Serra Sem Gás'],
    'default_code': 'QA-AGU-001',
    'barcode': '7900000001013',
    'uom_id': [1, 'Unidade'],
    'currency_id': [601, 'BRL'],
    'pos_categ_ids': [404],
    'write_date': '2026-08-11 08:00:00'
  },
  {
    'id': 1014,
    'display_name': 'Água Serra Com Gás',
    'lst_price': 7.0,
    'product_tmpl_id': [2014, 'Água Serra Com Gás'],
    'default_code': 'QA-AGU-002',
    'barcode': '7900000001014',
    'uom_id': [1, 'Unidade'],
    'currency_id': [601, 'BRL'],
    'pos_categ_ids': [404],
    'write_date': '2026-08-11 08:00:00'
  },
  {
    'id': 1015,
    'display_name': 'Água Tônica Aurora',
    'lst_price': 8.0,
    'product_tmpl_id': [2015, 'Água Tônica Aurora'],
    'default_code': 'QA-AGU-003',
    'barcode': '7900000001015',
    'uom_id': [1, 'Unidade'],
    'currency_id': [601, 'BRL'],
    'pos_categ_ids': [404],
    'write_date': '2026-08-11 08:00:00'
  },
  {
    'id': 1016,
    'display_name': 'Suco Nuvem Limão',
    'lst_price': 9.0,
    'product_tmpl_id': [2016, 'Suco Nuvem Limão'],
    'default_code': 'QA-OUT-001',
    'barcode': '7900000001016',
    'uom_id': [1, 'Unidade'],
    'currency_id': [601, 'BRL'],
    'pos_categ_ids': [405],
    'write_date': '2026-08-11 08:00:00'
  },
  {
    'id': 1017,
    'display_name': 'Refrigerante Vale Cola',
    'lst_price': 8.5,
    'product_tmpl_id': [2017, 'Refrigerante Vale Cola'],
    'default_code': 'QA-OUT-002',
    'barcode': '7900000001017',
    'uom_id': [1, 'Unidade'],
    'currency_id': [601, 'BRL'],
    'pos_categ_ids': [405],
    'write_date': '2026-08-11 08:00:00'
  },
  {
    'id': 1018,
    'display_name': 'Café Praça',
    'lst_price': 5.0,
    'product_tmpl_id': [2018, 'Café Praça'],
    'default_code': 'QA-OUT-003',
    'barcode': '7900000001018',
    'uom_id': [1, 'Unidade'],
    'currency_id': [601, 'BRL'],
    'pos_categ_ids': [405],
    'write_date': '2026-08-11 08:00:00'
  },
  {
    'id': 1019,
    'display_name': 'Chá Campo Gelado',
    'lst_price': 9.5,
    'product_tmpl_id': [2019, 'Chá Campo Gelado'],
    'default_code': 'QA-OUT-004',
    'barcode': '7900000001019',
    'uom_id': [1, 'Unidade'],
    'currency_id': [601, 'BRL'],
    'pos_categ_ids': [405],
    'write_date': '2026-08-11 08:00:00'
  },
  {
    'id': 1020,
    'display_name': 'Sobremesa Estrela',
    'lst_price': 14.0,
    'product_tmpl_id': [2020, 'Sobremesa Estrela'],
    'default_code': 'QA-OUT-005',
    'barcode': '7900000001020',
    'uom_id': [1, 'Unidade'],
    'currency_id': [601, 'BRL'],
    'pos_categ_ids': [405],
    'write_date': '2026-08-11 08:00:00'
  },
];
