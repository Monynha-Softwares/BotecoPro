class CatalogCategory {
  const CatalogCategory({
    required this.id,
    required this.name,
    this.parentId,
  });

  final int id;
  final String name;
  final int? parentId;
}

class CatalogProduct {
  const CatalogProduct({
    required this.id,
    required this.name,
    required this.catalogPrice,
    this.templateId,
    this.defaultCode,
    this.barcode,
    this.uomId,
    this.categoryIds = const [],
    this.writeDate,
  });

  final int id;
  final String name;

  /// Informational catalog value returned by Odoo (`lst_price`).
  ///
  /// It is not a transactional POS price and does not include future
  /// pricelist, fiscal-position or tax calculations.
  final double catalogPrice;
  final int? templateId;
  final String? defaultCode;
  final String? barcode;
  final int? uomId;
  final List<int> categoryIds;
  final DateTime? writeDate;
}
