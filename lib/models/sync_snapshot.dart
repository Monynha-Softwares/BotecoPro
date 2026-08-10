import 'catalog.dart';
import 'company.dart';
import 'pos_config.dart';
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
          'currentSessionState': posConfig.currentSessionState,
          'currencyId': posConfig.currencyId,
          'pricelistId': posConfig.pricelistId,
          'catalogProductCount': posConfig.catalogProductCount,
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
        categoryIds: _intList(item['categoryIds']),
        writeDate: item['writeDate'] == null
            ? null
            : DateTime.parse(item['writeDate'] as String),
      );
    }).toList(growable: false);
    if (json['productCount'] != products.length) {
      throw const FormatException('Incomplete Odoo snapshot.');
    }
    return SyncSnapshot(
      context: OperationalContext.fromJson(_map(json['context'])),
      synchronizedAt: synchronizedAt,
      odooVersion: json['odooVersion'] as String,
      company: Company(
        id: companyJson['id'] as int,
        name: companyJson['name'] as String,
        currencyId: companyJson['currencyId'] as int?,
        countryId: companyJson['countryId'] as int?,
      ),
      posConfig: PosConfig(
        id: posJson['id'] as int,
        name: posJson['name'] as String,
        companyId: posJson['companyId'] as int,
        active: posJson['active'] as bool,
        limitCategories: posJson['limitCategories'] as bool,
        categoryIds: _intList(posJson['categoryIds']),
        restaurant: posJson['restaurant'] as bool,
        currentSessionState: posJson['currentSessionState'] as String?,
        currencyId: posJson['currencyId'] as int?,
        pricelistId: posJson['pricelistId'] as int?,
        catalogProductCount: posJson['catalogProductCount'] as int?,
      ),
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
  static List<dynamic> _list(Object? value) =>
      List<dynamic>.from(value! as List);
  static List<int> _intList(Object? value) =>
      _list(value).map((item) => item as int).toList(growable: false);
}
