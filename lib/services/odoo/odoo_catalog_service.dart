import '../../models/catalog.dart';
import '../../models/pos_config.dart';
import 'odoo_client.dart';
import 'odoo_exception.dart';
import 'odoo_value_parser.dart';

class OdooCatalogService {
  const OdooCatalogService(this.client);

  final OdooClient client;

  Future<List<CatalogCategory>> listCategories({
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
        'context': {
          'allowed_company_ids': [companyId],
        },
      },
    );
    if (rows is! List) return const <CatalogCategory>[];
    return rows
        .whereType<Map>()
        .map((row) {
          final value = Map<String, dynamic>.from(row);
          return CatalogCategory(
            id: odooInt(value['id']) ?? 0,
            name: odooString(value['name']) ?? 'Categoria',
            parentId: odooRelationId(value['parent_id']),
          );
        })
        .where((category) => category.id > 0)
        .toList(growable: false);
  }

  Future<List<CatalogProduct>> listProducts({
    required int companyId,
    required PosConfig posConfig,
    int offset = 0,
    int limit = 100,
  }) async {
    final rows = await client.call(
      'product.product',
      'search_read',
      arguments: {
        'domain': buildProductDomain(posConfig),
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
        'context': {
          'allowed_company_ids': [companyId],
        },
      },
    );
    if (rows is! List) return const <CatalogProduct>[];
    return rows
        .whereType<Map>()
        .map((row) => _parseProduct(Map<String, dynamic>.from(row)))
        .where((product) => product.id > 0)
        .toList(growable: false);
  }

  Future<int> countProducts({
    required int companyId,
    required PosConfig posConfig,
  }) async {
    final count = await client.call(
      'product.product',
      'search_count',
      arguments: {
        'domain': buildProductDomain(posConfig),
        'context': {
          'allowed_company_ids': [companyId],
        },
      },
    );
    final value = odooInt(count);
    if (value == null || value < 0) {
      throw const OdooException(
        kind: OdooErrorKind.unexpected,
        message: 'Odoo não devolveu a contagem do catálogo POS.',
      );
    }
    return value;
  }

  List<List<Object?>> buildProductDomain(PosConfig posConfig) {
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
    return domain;
  }

  CatalogProduct _parseProduct(Map<String, dynamic> value) {
    final writeDate = odooString(value['write_date']);
    return CatalogProduct(
      id: odooInt(value['id']) ?? 0,
      name: odooString(value['display_name']) ??
          odooString(value['name']) ??
          'Produto',
      catalogPrice: odooDouble(value['lst_price']),
      templateId: odooRelationId(value['product_tmpl_id']),
      defaultCode: odooString(value['default_code']),
      barcode: odooString(value['barcode']),
      uomId: odooRelationId(value['uom_id']),
      categoryIds: odooRelationIds(value['pos_categ_ids']),
      writeDate: writeDate == null ? null : DateTime.tryParse(writeDate),
    );
  }
}
