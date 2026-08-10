class OdooConnection {
  const OdooConnection({
    required this.baseUrl,
    required this.username,
    this.database,
  });

  final String baseUrl;
  final String username;
  final String? database;

  factory OdooConnection.fromInput({
    required String baseUrl,
    required String username,
    String? database,
  }) {
    final normalized = baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    final uri = Uri.tryParse(normalized);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw const FormatException('Use uma URL HTTPS válida do Odoo.');
    }
    if (username.trim().isEmpty) {
      throw const FormatException('Informe o utilizador do Odoo.');
    }

    return OdooConnection(
      baseUrl: normalized,
      username: username.trim(),
      database: database?.trim().isEmpty == true ? null : database?.trim(),
    );
  }

  Uri get versionUri => Uri.parse('$baseUrl/web/version');

  Uri json2Uri(String model, String method) {
    final encodedModel = Uri.encodeComponent(model);
    final encodedMethod = Uri.encodeComponent(method);
    return Uri.parse('$baseUrl/json/2/$encodedModel/$encodedMethod');
  }

  OdooConnection copyWith({
    String? baseUrl,
    String? username,
    String? database,
  }) {
    return OdooConnection(
      baseUrl: baseUrl ?? this.baseUrl,
      username: username ?? this.username,
      database: database ?? this.database,
    );
  }
}

class OdooIdentity {
  const OdooIdentity({
    required this.id,
    required this.name,
    required this.login,
    required this.companyId,
    required this.companyIds,
    this.language,
    this.timezone,
  });

  final int id;
  final String name;
  final String login;
  final int companyId;
  final List<int> companyIds;
  final String? language;
  final String? timezone;
}

class OdooCompany {
  const OdooCompany({
    required this.id,
    required this.name,
    this.currencyId,
    this.countryId,
  });

  final int id;
  final String name;
  final int? currencyId;
  final int? countryId;
}

class OdooPosConfig {
  const OdooPosConfig({
    required this.id,
    required this.name,
    required this.companyId,
    required this.active,
    required this.limitCategories,
    required this.categoryIds,
    required this.restaurant,
    this.currentSessionState,
    this.currencyId,
    this.pricelistId,
    this.catalogProductCount,
  });

  final int id;
  final String name;
  final int companyId;
  final bool active;
  final bool limitCategories;
  final List<int> categoryIds;
  final bool restaurant;
  final String? currentSessionState;
  final int? currencyId;
  final int? pricelistId;
  final int? catalogProductCount;

  bool get hasCatalogProducts =>
      catalogProductCount == null || catalogProductCount! > 0;

  OdooPosConfig copyWith({int? catalogProductCount}) {
    return OdooPosConfig(
      id: id,
      name: name,
      companyId: companyId,
      active: active,
      limitCategories: limitCategories,
      categoryIds: categoryIds,
      restaurant: restaurant,
      currentSessionState: currentSessionState,
      currencyId: currencyId,
      pricelistId: pricelistId,
      catalogProductCount: catalogProductCount ?? this.catalogProductCount,
    );
  }
}

class OdooCategory {
  const OdooCategory({
    required this.id,
    required this.name,
    this.parentId,
  });

  final int id;
  final String name;
  final int? parentId;
}

class OdooProduct {
  const OdooProduct({
    required this.id,
    required this.name,
    required this.price,
    this.templateId,
    this.defaultCode,
    this.barcode,
    this.uomId,
    this.categoryIds = const [],
    this.writeDate,
  });

  final int id;
  final String name;
  final double price;
  final int? templateId;
  final String? defaultCode;
  final String? barcode;
  final int? uomId;
  final List<int> categoryIds;
  final DateTime? writeDate;
}

enum OdooDiagnosticStatus { success, authenticatedButNotReady }

class OdooConnectionDiagnostic {
  const OdooConnectionDiagnostic({
    required this.odooVersion,
    required this.identity,
    required this.currentCompany,
    required this.companies,
    required this.posConfigs,
    required this.modelAccess,
  });

  final String odooVersion;
  final OdooIdentity identity;
  final OdooCompany currentCompany;
  final List<OdooCompany> companies;
  final List<OdooPosConfig> posConfigs;
  final Map<String, bool> modelAccess;

  OdooConnectionDiagnostic copyWith({
    OdooCompany? currentCompany,
    List<OdooPosConfig>? posConfigs,
  }) {
    return OdooConnectionDiagnostic(
      odooVersion: odooVersion,
      identity: identity,
      currentCompany: currentCompany ?? this.currentCompany,
      companies: companies,
      posConfigs: posConfigs ?? this.posConfigs,
      modelAccess: modelAccess,
    );
  }

  bool get isReady =>
      posConfigs.isNotEmpty &&
      modelAccess.values.every((accessible) => accessible) &&
      posConfigs.any((config) => config.hasCatalogProducts);

  OdooDiagnosticStatus get status => isReady
      ? OdooDiagnosticStatus.success
      : OdooDiagnosticStatus.authenticatedButNotReady;
}
