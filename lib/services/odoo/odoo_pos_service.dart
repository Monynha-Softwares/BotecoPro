import '../../models/currency.dart';
import '../../models/pos_config.dart';
import '../../models/pos_operational_profile.dart';
import '../../models/restaurant.dart';
import 'odoo_catalog_service.dart';
import 'odoo_client.dart';
import 'odoo_exception.dart';
import 'odoo_value_parser.dart';

class OdooPosService {
  const OdooPosService(this.client, this.catalogService);

  final OdooClient client;
  final OdooCatalogService catalogService;

  Future<List<PosConfig>> listPosConfigs({required int companyId}) async {
    final rows = await client.call(
      'pos.config',
      'search_read',
      arguments: {
        'domain': [
          ['active', '=', true],
          ['company_id', '=', companyId],
        ],
        'fields': [
          'id',
          'name',
          'company_id',
          'active',
          'limit_categories',
          'iface_available_categ_ids',
          'module_pos_restaurant',
          'current_session_state',
          'currency_id',
          'pricelist_id',
          'available_pricelist_ids',
          'use_pricelist',
          'payment_method_ids',
          'current_session_id',
        ],
        'order': 'id',
        'limit': 100,
        'context': {
          'allowed_company_ids': [companyId],
        },
      },
    );
    if (rows is! List) return const <PosConfig>[];
    final configs = rows
        .whereType<Map>()
        .map((row) => _parsePosConfig(Map<String, dynamic>.from(row)))
        .where((config) => config.id > 0)
        .toList(growable: false);
    return Future.wait(configs.map((config) async {
      try {
        return config.copyWith(
          catalogProductCount: await catalogService.countProducts(
            companyId: companyId,
            posConfig: config,
          ),
        );
      } on OdooException {
        return config;
      }
    }));
  }

  Future<PosOperationalProfile> loadOperationalProfile({
    required int companyId,
    required PosConfig posConfig,
  }) async {
    final currencyId = posConfig.currencyId;
    if (currencyId == null) {
      throw const OdooException(
        kind: OdooErrorKind.unexpected,
        message: 'A configuração POS não informou a moeda operacional.',
      );
    }
    final currency = await readCurrency(
      companyId: companyId,
      currencyId: currencyId,
    );
    var pricelistReadable = true;
    PricelistInfo? pricelist;
    if (posConfig.usePricelist && posConfig.pricelistId != null) {
      try {
        pricelist = await readPricelist(
          companyId: companyId,
          pricelistId: posConfig.pricelistId!,
        );
      } on OdooException catch (error) {
        if (!_isOptionalReadFailure(error)) rethrow;
        pricelistReadable = false;
      }
    }
    if (pricelist != null && pricelist.currencyId != currency.id) {
      throw const OdooException(
        kind: OdooErrorKind.unexpected,
        message: 'A pricelist e a configuração POS usam moedas diferentes.',
      );
    }
    var sessionsReadable = true;
    var sessions = const <PosSessionSummary>[];
    try {
      sessions = await listNonClosedSessions(
        companyId: companyId,
        posConfigId: posConfig.id,
      );
    } on OdooException catch (error) {
      if (!_isOptionalReadFailure(error)) rethrow;
      sessionsReadable = false;
    }
    var paymentMethodsReadable = true;
    var paymentMethods = const <PaymentMethodSummary>[];
    try {
      paymentMethods = await listPaymentMethods(
        companyId: companyId,
        paymentMethodIds: posConfig.paymentMethodIds,
      );
    } on OdooException catch (error) {
      if (!_isOptionalReadFailure(error)) rethrow;
      paymentMethodsReadable = false;
    }
    return PosOperationalProfile(
      posConfigId: posConfig.id,
      currency: currency,
      pricelist: pricelist,
      pricelistReadable: pricelistReadable,
      nonClosedSessions: sessions,
      sessionsReadable: sessionsReadable,
      paymentMethods: paymentMethods,
      paymentMethodsReadable: paymentMethodsReadable,
    );
  }

  Future<CurrencyInfo> readCurrency({
    required int companyId,
    required int currencyId,
  }) async {
    final rows = await client.call(
      'res.currency',
      'read',
      arguments: {
        'ids': [currencyId],
        'fields': [
          'id',
          'name',
          'symbol',
          'position',
          'decimal_places',
          'rounding',
        ],
        'context': {
          'allowed_company_ids': [companyId],
        },
      },
    );
    if (rows is! List || rows.isEmpty || rows.first is! Map) {
      throw const OdooException(
        kind: OdooErrorKind.unexpected,
        message: 'Odoo não devolveu a moeda da configuração POS.',
      );
    }
    final value = Map<String, dynamic>.from(rows.first as Map);
    final id = odooInt(value['id']);
    final name = odooString(value['name']);
    final position = odooString(value['position']);
    final decimalPlaces = odooInt(value['decimal_places']);
    final rounding = odooNullableDouble(value['rounding']);
    if (id == null ||
        id != currencyId ||
        name == null ||
        (position != 'before' && position != 'after') ||
        decimalPlaces == null ||
        decimalPlaces < 0 ||
        rounding == null ||
        rounding <= 0) {
      throw const OdooException(
        kind: OdooErrorKind.unexpected,
        message: 'Odoo devolveu metadados de moeda inválidos.',
      );
    }
    return CurrencyInfo(
      id: id,
      name: name,
      symbol: odooString(value['symbol']) ?? name,
      position: position == 'after'
          ? CurrencySymbolPosition.after
          : CurrencySymbolPosition.before,
      decimalPlaces: decimalPlaces,
      rounding: rounding,
    );
  }

  Future<PricelistInfo> readPricelist({
    required int companyId,
    required int pricelistId,
  }) async {
    final rows = await client.call(
      'product.pricelist',
      'read',
      arguments: {
        'ids': [pricelistId],
        'fields': ['id', 'name', 'currency_id', 'company_id', 'active'],
        'context': {
          'allowed_company_ids': [companyId],
        },
      },
    );
    if (rows is! List || rows.isEmpty || rows.first is! Map) {
      throw const OdooException(
        kind: OdooErrorKind.unexpected,
        message: 'Odoo não devolveu a pricelist da configuração POS.',
      );
    }
    final value = Map<String, dynamic>.from(rows.first as Map);
    final id = odooInt(value['id']);
    final name = odooString(value['name']);
    final currencyId = odooRelationId(value['currency_id']);
    final company = odooRelationId(value['company_id']);
    if (id == null ||
        id != pricelistId ||
        name == null ||
        currencyId == null ||
        (company != null && company != companyId)) {
      throw const OdooException(
        kind: OdooErrorKind.unexpected,
        message: 'Odoo devolveu metadados de pricelist inválidos.',
      );
    }
    return PricelistInfo(
      id: id,
      name: name,
      currencyId: currencyId,
      companyId: company,
      active: value['active'] != false,
    );
  }

  Future<List<PosSessionSummary>> listNonClosedSessions({
    required int companyId,
    required int posConfigId,
  }) async {
    final rows = await client.call(
      'pos.session',
      'search_read',
      arguments: {
        'domain': [
          ['config_id', '=', posConfigId],
          ['rescue', '=', false],
          [
            'state',
            'in',
            ['opening_control', 'opened', 'closing_control'],
          ],
        ],
        'fields': [
          'id',
          'name',
          'state',
          'config_id',
          'user_id',
          'currency_id',
          'payment_method_ids',
          'rescue',
          'start_at',
          'stop_at',
        ],
        'order': 'id desc',
        'limit': 100,
        'context': {
          'allowed_company_ids': [companyId],
        },
      },
    );
    if (rows is! List) return const <PosSessionSummary>[];
    final sessions = rows.whereType<Map>().map((row) {
      final value = Map<String, dynamic>.from(row);
      if (value['rescue'] == true ||
          !value.containsKey('state') ||
          !value.containsKey('config_id') ||
          !value.containsKey('user_id') ||
          !value.containsKey('currency_id') ||
          !value.containsKey('payment_method_ids')) {
        throw const OdooException(
          kind: OdooErrorKind.unexpected,
          message: 'Odoo devolveu metadados de sessão POS inválidos.',
        );
      }
      final user = value['user_id'];
      return PosSessionSummary(
        id: odooInt(value['id']) ?? 0,
        name: odooString(value['name']) ?? 'Sessão POS',
        state: odooString(value['state']) ?? 'unknown',
        configId: odooRelationId(value['config_id']) ?? 0,
        userId: odooRelationId(user) ?? 0,
        userName: user is List && user.length > 1
            ? odooString(user[1]) ?? 'Utilizador Odoo'
            : 'Utilizador Odoo',
        currencyId: odooRelationId(value['currency_id']) ?? 0,
        paymentMethodIds: odooRelationIds(value['payment_method_ids']),
        startedAt: odooDateTimeUtc(value['start_at']),
        stoppedAt: odooDateTimeUtc(value['stop_at']),
      );
    }).toList(growable: false);
    if (sessions.length != rows.length ||
        sessions.any((session) =>
            session.id <= 0 ||
            session.configId != posConfigId ||
            session.userId <= 0 ||
            session.currencyId <= 0)) {
      throw const OdooException(
        kind: OdooErrorKind.unexpected,
        message: 'Odoo devolveu metadados de sessão POS inválidos.',
      );
    }
    return sessions;
  }

  Future<List<PaymentMethodSummary>> listPaymentMethods({
    required int companyId,
    required List<int> paymentMethodIds,
  }) async {
    if (paymentMethodIds.isEmpty) return const <PaymentMethodSummary>[];
    final rows = await client.call(
      'pos.payment.method',
      'read',
      arguments: {
        'ids': paymentMethodIds,
        'fields': [
          'id',
          'name',
          'active',
          'is_cash_count',
          'split_transactions',
          'sequence',
          'type',
          'payment_method_type',
        ],
        'context': {
          'allowed_company_ids': [companyId],
        },
      },
    );
    if (rows is! List) return const <PaymentMethodSummary>[];
    final methods = rows.whereType<Map>().map((row) {
      final value = Map<String, dynamic>.from(row);
      if (!value.containsKey('id') ||
          !value.containsKey('name') ||
          !value.containsKey('active') ||
          !value.containsKey('is_cash_count') ||
          !value.containsKey('split_transactions') ||
          !value.containsKey('sequence')) {
        throw const OdooException(
          kind: OdooErrorKind.unexpected,
          message: 'Odoo devolveu métodos de pagamento POS inválidos.',
        );
      }
      return PaymentMethodSummary(
        id: odooInt(value['id']) ?? 0,
        name: odooString(value['name']) ?? 'Método de pagamento',
        active: value['active'] != false,
        isCashCount: value['is_cash_count'] == true,
        splitTransactions: value['split_transactions'] == true,
        sequence: odooInt(value['sequence']) ?? 0,
        type: odooString(value['type']),
        paymentMethodType: odooString(value['payment_method_type']),
      );
    }).toList(growable: false);
    final requestedIds = paymentMethodIds.toSet();
    final returnedIds = methods.map((method) => method.id).toSet();
    if (methods.length != rows.length ||
        methods.any((method) => method.id <= 0 || method.name.isEmpty) ||
        returnedIds.length != methods.length ||
        !returnedIds.containsAll(requestedIds) ||
        !requestedIds.containsAll(returnedIds)) {
      throw const OdooException(
        kind: OdooErrorKind.unexpected,
        message: 'Odoo devolveu métodos de pagamento POS inválidos.',
      );
    }
    return methods;
  }

  Future<List<RestaurantFloor>> listRestaurantFloors({
    required int companyId,
    required int posConfigId,
  }) async {
    final rows = await client.call(
      'restaurant.floor',
      'search_read',
      arguments: {
        'domain': [
          [
            'pos_config_ids',
            'in',
            [posConfigId],
          ],
        ],
        'fields': ['id', 'name', 'pos_config_ids'],
        'order': 'sequence,id',
        'limit': 100,
        'context': {
          'allowed_company_ids': [companyId],
        },
      },
    );
    if (rows is! List) return const <RestaurantFloor>[];
    return rows
        .whereType<Map>()
        .map((row) {
          final value = Map<String, dynamic>.from(row);
          return RestaurantFloor(
            id: odooInt(value['id']) ?? 0,
            name: odooString(value['name']) ?? 'Piso',
            posConfigIds: odooRelationIds(value['pos_config_ids']),
          );
        })
        .where((floor) => floor.id > 0)
        .toList(growable: false);
  }

  Future<List<RestaurantTable>> listRestaurantTables({
    required int companyId,
    required List<RestaurantFloor> floors,
  }) async {
    if (floors.isEmpty) return const <RestaurantTable>[];
    final floorNames = {for (final floor in floors) floor.id: floor.name};
    final rows = await client.call(
      'restaurant.table',
      'search_read',
      arguments: {
        'domain': [
          ['active', '=', true],
          ['floor_id', 'in', floorNames.keys.toList()],
        ],
        'fields': ['id', 'table_number', 'seats', 'floor_id', 'active'],
        'order': 'floor_id,table_number,id',
        'limit': 1000,
        'context': {
          'allowed_company_ids': [companyId],
        },
      },
    );
    if (rows is! List) return const <RestaurantTable>[];
    return rows
        .whereType<Map>()
        .map((row) {
          final value = Map<String, dynamic>.from(row);
          final floorId = odooRelationId(value['floor_id']) ?? 0;
          return RestaurantTable(
            id: odooInt(value['id']) ?? 0,
            number: odooInt(value['table_number']) ?? 0,
            floorId: floorId,
            floorName: floorNames[floorId] ?? 'Piso',
            active: value['active'] != false,
            seats: odooInt(value['seats']),
          );
        })
        .where((table) => table.id > 0 && table.number > 0)
        .toList(growable: false);
  }

  PosConfig _parsePosConfig(Map<String, dynamic> value) => PosConfig(
        id: odooInt(value['id']) ?? 0,
        name: odooString(value['name']) ?? 'POS',
        companyId: odooRelationId(value['company_id']) ?? 0,
        active: value['active'] != false,
        limitCategories: value['limit_categories'] == true,
        categoryIds: odooRelationIds(value['iface_available_categ_ids']),
        restaurant: value['module_pos_restaurant'] == true,
        currentSessionState: odooString(value['current_session_state']),
        currencyId: odooRelationId(value['currency_id']),
        pricelistId: odooRelationId(value['pricelist_id']),
        availablePricelistIds:
            odooRelationIds(value['available_pricelist_ids']),
        usePricelist: value['use_pricelist'] == true,
        paymentMethodIds: odooRelationIds(value['payment_method_ids']),
        currentSessionId: odooRelationId(value['current_session_id']),
      );

  bool _isOptionalReadFailure(OdooException error) =>
      error.kind == OdooErrorKind.forbidden ||
      error.kind == OdooErrorKind.notFound;
}
