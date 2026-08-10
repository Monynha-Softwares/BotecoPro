import '../../models/company.dart';
import '../../models/connection_diagnostic.dart';
import '../../models/identity.dart';
import '../../models/pos_config.dart';
import 'odoo_client.dart';
import 'odoo_exception.dart';
import 'odoo_pos_service.dart';
import 'odoo_value_parser.dart';

class OdooConnectionService {
  const OdooConnectionService(this.client, this.posService);

  final OdooClient client;
  final OdooPosService posService;

  Future<ConnectionDiagnostic> testConnection({
    required String expectedUsername,
  }) async {
    final version = await client.getVersion();
    final context = await client.call('res.users', 'context_get');
    final uid = odooInt(context is Map ? context['uid'] : null);
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
    final login = odooString(user['login']);
    if (login == null ||
        login.toLowerCase() != expectedUsername.trim().toLowerCase()) {
      throw const OdooException(
        kind: OdooErrorKind.unauthorized,
        message: 'A API key pertence a outro utilizador do Odoo.',
      );
    }

    final companyId = odooRelationId(user['company_id']);
    final companyIds = odooRelationIds(user['company_ids']);
    if (companyId == null || companyIds.isEmpty) {
      throw const OdooException(
        kind: OdooErrorKind.unexpected,
        message: 'O utilizador não possui uma empresa Odoo válida.',
      );
    }

    final identity = AuthenticatedUser(
      id: uid,
      name: odooString(user['name']) ?? login,
      login: login,
      companyId: companyId,
      companyIds: companyIds,
      language: odooString(user['lang']),
      timezone: odooString(user['tz']),
    );
    final companies = await listCompanies(companyIds);
    final currentCompany = companies.firstWhere(
      (company) => company.id == companyId,
      orElse: () => Company(id: companyId, name: 'Empresa atual'),
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
        ? await posService.listPosConfigs(companyId: companyId)
        : <PosConfig>[];
    return ConnectionDiagnostic(
      odooVersion: version,
      identity: identity,
      currentCompany: currentCompany,
      companies: companies,
      posConfigs: posConfigs,
      modelAccess: access,
    );
  }

  Future<List<Company>> listCompanies(List<int> companyIds) async {
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
    if (rows is! List) return const <Company>[];
    return rows
        .whereType<Map>()
        .map((row) {
          final value = Map<String, dynamic>.from(row);
          return Company(
            id: odooInt(value['id']) ?? 0,
            name: odooString(value['name']) ?? 'Empresa',
            currencyId: odooRelationId(value['currency_id']),
            countryId: odooRelationId(value['country_id']),
          );
        })
        .where((company) => company.id > 0)
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
}
