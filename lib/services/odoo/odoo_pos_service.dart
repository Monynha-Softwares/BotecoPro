import '../../models/pos_config.dart';
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
      );
}
