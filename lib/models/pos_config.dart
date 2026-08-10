class PosConfig {
  const PosConfig({
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

  PosConfig copyWith({int? catalogProductCount}) => PosConfig(
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
