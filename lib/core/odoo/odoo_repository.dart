import 'odoo_client.dart';
import 'odoo_connection.dart';
import 'odoo_exception.dart';

class OdooRepository {
  const OdooRepository(this.client);

  final OdooClient client;

  Future<OdooConnectionDiagnostic> testConnection({
    required String expectedUsername,
  }) async {
    final version = await client.getVersion();
    final context = await client.call('res.users', 'context_get');
    final uid = _asInt(context is Map ? context['uid'] : null);
    if (uid == null) {
      throw const OdooException(
        kind: OdooErrorKind.unexpected,
        message: 'Odoo não devolveu a identidade do utilizador.',
      );
    }

    final userRows = await client.call(
      'res.users',
      'search_read',
      arguments: {
        'domain': [
          ['id', '=', uid],
        ],
        'fields': [
          'id',
          'name',
          'login',
          'company_id',
          'company_ids',
          'lang',
          'tz',
        ],
        'limit': 1,
      },
    );
    if (userRows is! List || userRows.isEmpty || userRows.first is! Map) {
      throw const OdooException(
        kind: OdooErrorKind.unexpected,
        message: 'Odoo não devolveu os dados do utilizador.',
      );
    }

    final user = Map<String, dynamic>.from(userRows.first as Map);
    final login = _asString(user['login']);
    if (login == null || login.toLowerCase() != expectedUsername.trim().toLowerCase()) {
      throw const OdooException(
        kind: OdooErrorKind.unauthorized,
        message: 'A API key pertence a outro utilizador do Odoo.',
      );
    }

    final companyId = _relationId(user['company_id']);
    final companyIds = _relationIds(user['company_ids']);
    if (companyId == null || companyIds.isEmpty) {
      throw const OdooException(
        kind: OdooErrorKind.unexpected,
        message: 'O utilizador não possui uma empresa Odoo válida.',
      );
    }

    final identity = OdooIdentity(
      id: uid,
      name: _asString(user['name']) ?? login,
      login: login,
      companyId: companyId,
      companyIds: companyIds,
      language: _asString(user['lang']),
      timezone: _asString(user['tz']),
    );
    final companies = await listCompanies(companyIds);
    final currentCompany = companies.firstWhere(
      (company) => company.id == companyId,
      orElse: () => OdooCompany(id: companyId, name: 'Empresa atual'),
    );

    final access = <String, bool>{};
    for (final model in <String>[
      'res.company',
      'pos.config',
      'pos.category',
      'product.product',
    ]) {
      access[model] = await _canRead(model);
    }

    final posConfigs = access['pos.config'] == true
        ? await listPosConfigs(companyId: companyId)
        : <OdooPosConfig>[];

    return OdooConnectionDiagnostic(
      odooVersion: version,
      identity: identity,
      currentCompany: currentCompany,
      companies: companies,
      posConfigs: posConfigs,
      modelAccess: access,
    );
  }

  Future<List<OdooCompany>> listCompanies(List<int> companyIds) async {
    final rows = await client.call(
      'res.company',
      'search_read',
      arguments: {
        'domain': [
          ['id', 'in', companyIds],
        ],
        'fields': ['id', 'name', 'currency_id', 'country_id'],
        'order': 'id',
        'limit': companyIds.length,
        'context': {'allowed_company_ids': companyIds},
      },
    );
    if (rows is! List) return const <OdooCompany>[];
    return rows
        .whereType<Map>()
        .map((row) {
          final value = Map<String, dynamic>.from(row);
          return OdooCompany(
            id: _asInt(value['id']) ?? 0,
            name: _asString(value['name']) ?? 'Empresa',
            currencyId: _relationId(value['currency_id']),
            countryId: _relationId(value['country_id']),
          );
        })
        .where((company) => company.id > 0)
        .toList(growable: false);
  }

  Future<List<OdooPosConfig>> listPosConfigs({required int companyId}) async {
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
        ],
        'order': 'id',
        'limit': 100,
        'context': {'allowed_company_ids': [companyId]},
      },
    );
    if (rows is! List) return const <OdooPosConfig>[];
    return rows
        .whereType<Map>()
        .map((row) => _parsePosConfig(Map<String, dynamic>.from(row)))
        .where((config) => config.id > 0)
        .toList(growable: false);
  }

  Future<List<OdooCategory>> listCategories({
    required int companyId,
    List<int>? categoryIds,
  }) async {
    final domain = <List<Object?>>[];
    if (categoryIds != null && categoryIds.isNotEmpty) {
      domain.add(['id', 'in', categoryIds]);
    }
    final rows = await client.call(
      'pos.category',
      'search_read',
      arguments: {
        'domain': domain,
        'fields': ['id', 'name', 'parent_id'],
        'order': 'sequence,id',
        'limit': 1000,
        'context': {'allowed_company_ids': [companyId]},
      },
    );
    if (rows is! List) return const <OdooCategory>[];
    return rows
        .whereType<Map>()
        .map((row) {
          final value = Map<String, dynamic>.from(row);
          return OdooCategory(
            id: _asInt(value['id']) ?? 0,
            name: _asString(value['name']) ?? 'Categoria',
            parentId: _relationId(value['parent_id']),
          );
        })
        .where((category) => category.id > 0)
        .toList(growable: false);
  }

  Future<List<OdooProduct>> listProducts({
    required int companyId,
    required OdooPosConfig posConfig,
    int offset = 0,
    int limit = 100,
  }) async {
    final domain = <List<Object?>>[
      ['active', '=', true],
      ['product_tmpl_id.available_in_pos', '=', true],
    ];
    if (posConfig.limitCategories && posConfig.categoryIds.isNotEmpty) {
      domain.add([
        'product_tmpl_id.pos_categ_ids',
        'in',
        posConfig.categoryIds,
      ]);
    }
    final rows = await client.call(
      'product.product',
      'search_read',
      arguments: {
        'domain': domain,
        'fields': [
          'id',
          'display_name',
          'lst_price',
          'product_tmpl_id',
          'default_code',
          'barcode',
          'uom_id',
          'pos_categ_ids',
          'write_date',
        ],
        'order': 'default_code,name,id',
        'offset': offset,
        'limit': limit,
        'context': {'allowed_company_ids': [companyId]},
      },
    );
    if (rows is! List) return const <OdooProduct>[];
    return rows
        .whereType<Map>()
        .map((row) => _parseProduct(Map<String, dynamic>.from(row)))
        .where((product) => product.id > 0)
        .toList(growable: false);
  }

  Future<bool> _canRead(String model) async {
    try {
      await client.call(
        model,
        'search_read',
        arguments: {
          'domain': <Object?>[],
          'fields': ['id'],
          'limit': 1,
        },
      );
      return true;
    } on OdooException {
      return false;
    }
  }

  OdooPosConfig _parsePosConfig(Map<String, dynamic> value) {
    return OdooPosConfig(
      id: _asInt(value['id']) ?? 0,
      name: _asString(value['name']) ?? 'POS',
      companyId: _relationId(value['company_id']) ?? 0,
      active: value['active'] != false,
      limitCategories: value['limit_categories'] == true,
      categoryIds: _relationIds(value['iface_available_categ_ids']),
      restaurant: value['module_pos_restaurant'] == true,
      currentSessionState: _asString(value['current_session_state']),
      currencyId: _relationId(value['currency_id']),
      pricelistId: _relationId(value['pricelist_id']),
    );
  }

  OdooProduct _parseProduct(Map<String, dynamic> value) {
    final writeDate = _asString(value['write_date']);
    return OdooProduct(
      id: _asInt(value['id']) ?? 0,
      name: _asString(value['display_name']) ?? _asString(value['name']) ?? 'Produto',
      price: _asDouble(value['lst_price']),
      templateId: _relationId(value['product_tmpl_id']),
      defaultCode: _asString(value['default_code']),
      barcode: _asString(value['barcode']),
      uomId: _relationId(value['uom_id']),
      categoryIds: _relationIds(value['pos_categ_ids']),
      writeDate: writeDate == null ? null : DateTime.tryParse(writeDate),
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _asString(Object? value) {
    if (value == null || value == false) return null;
    return value.toString();
  }

  static int? _relationId(Object? value) {
    if (value is List && value.isNotEmpty) return _asInt(value.first);
    return _asInt(value);
  }

  static List<int> _relationIds(Object? value) {
    if (value is! List) return const <int>[];
    return value
        .map(_relationId)
        .whereType<int>()
        .where((id) => id > 0)
        .toList(growable: false);
  }
}
