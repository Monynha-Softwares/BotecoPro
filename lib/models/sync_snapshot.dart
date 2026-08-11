import 'catalog.dart';
import 'company.dart';
import 'currency.dart';
import 'pos_config.dart';
import 'pos_operational_profile.dart';
import 'restaurant.dart';

class OperationalContext {
  const OperationalContext({
    required this.instanceKey,
    required this.userId,
    required this.companyId,
    required this.posConfigId,
  });

  final String instanceKey;
  final int userId;
  final int companyId;
  final int posConfigId;

  bool matches(OperationalContext other) =>
      instanceKey == other.instanceKey &&
      userId == other.userId &&
      companyId == other.companyId &&
      posConfigId == other.posConfigId;

  Map<String, Object?> toJson() => {
        'instanceKey': instanceKey,
        'userId': userId,
        'companyId': companyId,
        'posConfigId': posConfigId,
      };

  factory OperationalContext.fromJson(Map<String, dynamic> json) =>
      OperationalContext(
        instanceKey: json['instanceKey'] as String,
        userId: json['userId'] as int,
        companyId: json['companyId'] as int,
        posConfigId: json['posConfigId'] as int,
      );
}

class SyncSnapshot {
  const SyncSnapshot({
    required this.context,
    required this.synchronizedAt,
    required this.odooVersion,
    required this.company,
    required this.posConfig,
    required this.categories,
    required this.products,
    required this.floors,
    required this.tables,
    this.posOperationalProfile,
    this.schemaVersion = currentSchemaVersion,
  });

  static const currentSchemaVersion = 1;

  final int schemaVersion;
  final OperationalContext context;
  final DateTime synchronizedAt;
  final String odooVersion;
  final Company company;
  final PosConfig posConfig;
  final List<CatalogCategory> categories;
  final List<CatalogProduct> products;
  final List<RestaurantFloor> floors;
  final List<RestaurantTable> tables;
  final PosOperationalProfile? posOperationalProfile;

  int get productCount => products.length;

  bool matches(OperationalContext candidate) =>
      schemaVersion == currentSchemaVersion && context.matches(candidate);

  Map<String, Object?> toJson() => {
        'schemaVersion': schemaVersion,
        'context': context.toJson(),
        'synchronizedAt': synchronizedAt.toUtc().toIso8601String(),
        'odooVersion': odooVersion,
        'productCount': productCount,
        'company': {
          'id': company.id,
          'name': company.name,
          'currencyId': company.currencyId,
          'countryId': company.countryId,
        },
        'posConfig': {
          'id': posConfig.id,
          'name': posConfig.name,
          'companyId': posConfig.companyId,
          'active': posConfig.active,
          'limitCategories': posConfig.limitCategories,
          'categoryIds': posConfig.categoryIds,
          'restaurant': posConfig.restaurant,
          // Session state is live operational data and is never cached.
          'currentSessionState': null,
          'currencyId': posConfig.currencyId,
          'pricelistId': posConfig.pricelistId,
          'availablePricelistIds': posConfig.availablePricelistIds,
          'usePricelist': posConfig.usePricelist,
          'paymentMethodIds': posConfig.paymentMethodIds,
          'currentSessionId': null,
          'catalogProductCount': posConfig.catalogProductCount,
        },
        'posOperationalProfile': posOperationalProfile == null
            ? null
            : {
                'posConfigId': posOperationalProfile!.posConfigId,
                'currency': {
                  'id': posOperationalProfile!.currency.id,
                  'name': posOperationalProfile!.currency.name,
                  'symbol': posOperationalProfile!.currency.symbol,
                  'position': posOperationalProfile!.currency.position.name,
                  'decimalPlaces':
                      posOperationalProfile!.currency.decimalPlaces,
                  'rounding': posOperationalProfile!.currency.rounding,
                },
                'pricelist': posOperationalProfile!.pricelist == null
                    ? null
                    : {
                        'id': posOperationalProfile!.pricelist!.id,
                        'name': posOperationalProfile!.pricelist!.name,
                        'currencyId':
                            posOperationalProfile!.pricelist!.currencyId,
                        'companyId':
                            posOperationalProfile!.pricelist!.companyId,
                        'active': posOperationalProfile!.pricelist!.active,
                      },
                'pricelistReadable': posOperationalProfile!.pricelistReadable,
                // Session ownership and payment methods are live operational
                // state. They are deliberately not persisted: an offline
                // snapshot must not expose a person's name or imply that a
                // stale session/payment configuration is current.
                'sessionsReadable': false,
                'nonClosedSessions': const <Object?>[],
                'paymentMethodsReadable': false,
                'paymentMethods': const <Object?>[],
              },
        'categories': [
          for (final category in categories)
            {
              'id': category.id,
              'name': category.name,
              'parentId': category.parentId,
            }
        ],
        'products': [
          for (final product in products)
            {
              'id': product.id,
              'name': product.name,
              'price': product.catalogPrice,
              'templateId': product.templateId,
              'defaultCode': product.defaultCode,
              'barcode': product.barcode,
              'uomId': product.uomId,
              'currencyId': product.currencyId,
              'categoryIds': product.categoryIds,
              'writeDate': product.writeDate?.toUtc().toIso8601String(),
            }
        ],
        'floors': [
          for (final floor in floors)
            {
              'id': floor.id,
              'name': floor.name,
              'posConfigIds': floor.posConfigIds,
            }
        ],
        'tables': [
          for (final table in tables)
            {
              'id': table.id,
              'number': table.number,
              'floorId': table.floorId,
              'floorName': table.floorName,
              'active': table.active,
              'seats': table.seats,
            }
        ],
      };

  factory SyncSnapshot.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != currentSchemaVersion) {
      throw const FormatException('Unsupported Odoo snapshot schema.');
    }
    final companyJson = _map(json['company']);
    final posJson = _map(json['posConfig']);
    final profileJson = _optionalMap(json['posOperationalProfile']);
    final synchronizedAt = DateTime.parse(json['synchronizedAt'] as String);
    final products = _list(json['products']).map((value) {
      final item = _map(value);
      return CatalogProduct(
        id: item['id'] as int,
        name: item['name'] as String,
        catalogPrice: (item['price'] as num).toDouble(),
        templateId: item['templateId'] as int?,
        defaultCode: item['defaultCode'] as String?,
        barcode: item['barcode'] as String?,
        uomId: item['uomId'] as int?,
        currencyId: item['currencyId'] as int?,
        categoryIds: _intList(item['categoryIds']),
        writeDate: item['writeDate'] == null
            ? null
            : DateTime.parse(item['writeDate'] as String),
      );
    }).toList(growable: false);
    if (json['productCount'] != products.length) {
      throw const FormatException('Incomplete Odoo snapshot.');
    }
    final profile =
        profileJson == null ? null : _parseOperationalProfile(profileJson);
    final context = OperationalContext.fromJson(_map(json['context']));
    final company = Company(
      id: companyJson['id'] as int,
      name: companyJson['name'] as String,
      currencyId: companyJson['currencyId'] as int?,
      countryId: companyJson['countryId'] as int?,
    );
    final posConfig = PosConfig(
      id: posJson['id'] as int,
      name: posJson['name'] as String,
      companyId: posJson['companyId'] as int,
      active: posJson['active'] as bool,
      limitCategories: posJson['limitCategories'] as bool,
      categoryIds: _intList(posJson['categoryIds']),
      restaurant: posJson['restaurant'] as bool,
      currentSessionState: null,
      currencyId: posJson['currencyId'] as int?,
      pricelistId: posJson['pricelistId'] as int?,
      availablePricelistIds: _optionalIntList(posJson['availablePricelistIds']),
      usePricelist: posJson['usePricelist'] as bool? ?? false,
      paymentMethodIds: _optionalIntList(posJson['paymentMethodIds']),
      currentSessionId: null,
      catalogProductCount: posJson['catalogProductCount'] as int?,
    );
    _validateContextIntegrity(
      context: context,
      company: company,
      posConfig: posConfig,
      profile: profile,
    );
    return SyncSnapshot(
      context: context,
      synchronizedAt: synchronizedAt,
      odooVersion: json['odooVersion'] as String,
      company: company,
      posConfig: posConfig,
      posOperationalProfile: profile,
      categories: _list(json['categories']).map((value) {
        final item = _map(value);
        return CatalogCategory(
          id: item['id'] as int,
          name: item['name'] as String,
          parentId: item['parentId'] as int?,
        );
      }).toList(growable: false),
      products: products,
      floors: _list(json['floors']).map((value) {
        final item = _map(value);
        return RestaurantFloor(
          id: item['id'] as int,
          name: item['name'] as String,
          posConfigIds: _intList(item['posConfigIds']),
        );
      }).toList(growable: false),
      tables: _list(json['tables']).map((value) {
        final item = _map(value);
        return RestaurantTable(
          id: item['id'] as int,
          number: item['number'] as int,
          floorId: item['floorId'] as int,
          floorName: item['floorName'] as String,
          active: item['active'] as bool,
          seats: item['seats'] as int?,
        );
      }).toList(growable: false),
    );
  }

  static Map<String, dynamic> _map(Object? value) =>
      Map<String, dynamic>.from(value! as Map);
  static Map<String, dynamic>? _optionalMap(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;
  static List<dynamic> _list(Object? value) =>
      List<dynamic>.from(value! as List);
  static List<int> _intList(Object? value) =>
      _list(value).map((item) => item as int).toList(growable: false);
  static List<int> _optionalIntList(Object? value) => value is List
      ? value.map((item) => item as int).toList(growable: false)
      : const <int>[];

  static PosOperationalProfile _parseOperationalProfile(
    Map<String, dynamic> value,
  ) {
    final currency = _map(value['currency']);
    final pricelist = _optionalMap(value['pricelist']);
    return PosOperationalProfile(
      posConfigId: value['posConfigId'] as int,
      currency: CurrencyInfo(
        id: currency['id'] as int,
        name: currency['name'] as String,
        symbol: currency['symbol'] as String,
        position: currency['position'] == 'after'
            ? CurrencySymbolPosition.after
            : CurrencySymbolPosition.before,
        decimalPlaces: currency['decimalPlaces'] as int,
        rounding: (currency['rounding'] as num).toDouble(),
      ),
      pricelist: pricelist == null
          ? null
          : PricelistInfo(
              id: pricelist['id'] as int,
              name: pricelist['name'] as String,
              currencyId: pricelist['currencyId'] as int,
              companyId: pricelist['companyId'] as int?,
              active: pricelist['active'] as bool,
            ),
      pricelistReadable: value['pricelistReadable'] as bool? ?? true,
      sessionsReadable: value['sessionsReadable'] as bool? ?? true,
      nonClosedSessions:
          _list(value['nonClosedSessions'] ?? value['openSessions']).map((raw) {
        final session = _map(raw);
        return PosSessionSummary(
          id: session['id'] as int,
          name: session['name'] as String,
          state: session['state'] as String,
          configId: session['configId'] as int,
          userId: session['userId'] as int,
          userName: session['userName'] as String,
          currencyId: session['currencyId'] as int,
          paymentMethodIds: _optionalIntList(session['paymentMethodIds']),
          startedAt: session['startedAt'] == null
              ? null
              : DateTime.parse(session['startedAt'] as String).toUtc(),
          stoppedAt: session['stoppedAt'] == null
              ? null
              : DateTime.parse(session['stoppedAt'] as String).toUtc(),
        );
      }).toList(growable: false),
      paymentMethodsReadable: value['paymentMethodsReadable'] as bool? ?? true,
      paymentMethods: _list(value['paymentMethods']).map((raw) {
        final method = _map(raw);
        return PaymentMethodSummary(
          id: method['id'] as int,
          name: method['name'] as String,
          active: method['active'] as bool,
          isCashCount: method['isCashCount'] as bool,
          splitTransactions: method['splitTransactions'] as bool,
          sequence: method['sequence'] as int,
          type: method['type'] as String?,
          paymentMethodType: method['paymentMethodType'] as String?,
        );
      }).toList(growable: false),
    );
  }

  static void _validateContextIntegrity({
    required OperationalContext context,
    required Company company,
    required PosConfig posConfig,
    required PosOperationalProfile? profile,
  }) {
    final profileMatches = profile == null ||
        (profile.posConfigId == posConfig.id &&
            (posConfig.currencyId == null ||
                profile.currency.id == posConfig.currencyId) &&
            (profile.pricelist == null ||
                (profile.pricelist!.id == posConfig.pricelistId &&
                    profile.pricelist!.currencyId == profile.currency.id)));
    if (company.id != context.companyId ||
        posConfig.id != context.posConfigId ||
        posConfig.companyId != context.companyId ||
        !profileMatches) {
      throw const FormatException('Inconsistent Odoo snapshot context.');
    }
  }
}
