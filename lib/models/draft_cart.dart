import 'catalog.dart';
import 'restaurant.dart';
import 'sync_snapshot.dart';

enum DraftCartItemState { available, changed, unavailable }

class DraftCartItem {
  const DraftCartItem({
    required this.productId,
    required this.productName,
    required this.capturedUnitPrice,
    this.capturedCurrencyId,
    this.quantity = 1,
    this.note = '',
    this.state = DraftCartItemState.available,
    this.currentProductName,
    this.currentCatalogPrice,
    this.currentCurrencyId,
  });

  final int productId;
  final String productName;

  /// Informational catalog value captured when the item entered the draft.
  /// It is not an authoritative Odoo transactional price.
  final double capturedUnitPrice;
  final int? capturedCurrencyId;
  final int quantity;
  final String note;
  final DraftCartItemState state;
  final String? currentProductName;
  final double? currentCatalogPrice;
  final int? currentCurrencyId;

  double get subtotal => capturedUnitPrice * quantity;

  DraftCartItem copyWith({
    int? quantity,
    String? note,
    DraftCartItemState? state,
    String? currentProductName,
    double? currentCatalogPrice,
    int? currentCurrencyId,
    bool clearCurrentValues = false,
  }) =>
      DraftCartItem(
        productId: productId,
        productName: productName,
        capturedUnitPrice: capturedUnitPrice,
        capturedCurrencyId: capturedCurrencyId,
        quantity: quantity ?? this.quantity,
        note: note ?? this.note,
        state: state ?? this.state,
        currentProductName: clearCurrentValues
            ? null
            : currentProductName ?? this.currentProductName,
        currentCatalogPrice: clearCurrentValues
            ? null
            : currentCatalogPrice ?? this.currentCatalogPrice,
        currentCurrencyId: clearCurrentValues
            ? null
            : currentCurrencyId ?? this.currentCurrencyId,
      );

  Map<String, Object?> toJson() => {
        'productId': productId,
        'productName': productName,
        'unitPrice': capturedUnitPrice,
        'currencyId': capturedCurrencyId,
        'quantity': quantity,
        'note': note,
      };

  factory DraftCartItem.fromJson(Map<String, dynamic> json) => DraftCartItem(
        productId: json['productId'] as int,
        productName: json['productName'] as String,
        capturedUnitPrice: (json['unitPrice'] as num).toDouble(),
        capturedCurrencyId: json['currencyId'] as int?,
        quantity: json['quantity'] as int,
        note: json['note'] as String? ?? '',
      );
}

class DraftCart {
  DraftCart({
    required this.context,
    this.table,
    this.items = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now().toUtc(),
        updatedAt = updatedAt ?? DateTime.now().toUtc();

  static const currentSchemaVersion = 1;

  final OperationalContext context;
  final RestaurantTable? table;
  final List<DraftCartItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get itemCount => items.fold(0, (total, item) => total + item.quantity);
  double get subtotal => items.fold(0, (total, item) => total + item.subtotal);
  int? get capturedCurrencyId {
    if (items.isEmpty) return null;
    final candidate = items.first.capturedCurrencyId;
    if (candidate == null ||
        items.any((item) => item.capturedCurrencyId != candidate)) {
      return null;
    }
    return candidate;
  }

  bool get hasUnavailableItems =>
      items.any((item) => item.state == DraftCartItemState.unavailable);

  bool matchesContext(OperationalContext candidate) =>
      context.matches(candidate);

  DraftCart add(CatalogProduct product) {
    final index = items.indexWhere((item) => item.productId == product.id);
    if (index < 0) {
      return copyWith(items: [
        ...items,
        DraftCartItem(
          productId: product.id,
          productName: product.name,
          capturedUnitPrice: product.catalogPrice,
          capturedCurrencyId: product.currencyId,
        )
      ]);
    }
    return updateQuantity(product.id, items[index].quantity + 1);
  }

  DraftCart updateQuantity(int productId, int quantity) {
    if (quantity <= 0) return remove(productId);
    return copyWith(items: [
      for (final item in items)
        if (item.productId == productId)
          item.copyWith(quantity: quantity)
        else
          item,
    ]);
  }

  DraftCart updateNote(int productId, String note) => copyWith(items: [
        for (final item in items)
          if (item.productId == productId)
            item.copyWith(note: note.trim())
          else
            item,
      ]);

  DraftCart remove(int productId) => copyWith(
        items: items
            .where((item) => item.productId != productId)
            .toList(growable: false),
      );

  DraftCart clear() => copyWith(items: const []);

  DraftCart reconcile(
    List<CatalogProduct> products, {
    List<RestaurantTable>? restaurantTables,
  }) {
    final catalog = {for (final product in products) product.id: product};
    final tableStillAvailable = table == null ||
        restaurantTables == null ||
        restaurantTables.any((candidate) => candidate.id == table!.id);
    return copyWith(
      clearTable: !tableStillAvailable,
      items: [
        for (final item in items) _reconcileItem(item, catalog[item.productId]),
      ],
    );
  }

  DraftCartItem _reconcileItem(DraftCartItem item, CatalogProduct? product) {
    if (product == null) {
      return item.copyWith(state: DraftCartItemState.unavailable);
    }
    final priceChanged =
        (item.capturedUnitPrice - product.catalogPrice).abs() > 0.000000001;
    final currencyChanged = item.capturedCurrencyId != product.currencyId;
    final changed =
        item.productName != product.name || priceChanged || currencyChanged;
    return item.copyWith(
      state:
          changed ? DraftCartItemState.changed : DraftCartItemState.available,
      currentProductName: changed ? product.name : null,
      currentCatalogPrice: changed ? product.catalogPrice : null,
      currentCurrencyId: changed ? product.currencyId : null,
      clearCurrentValues: !changed,
    );
  }

  DraftCart copyWith({
    RestaurantTable? table,
    bool clearTable = false,
    List<DraftCartItem>? items,
    DateTime? updatedAt,
  }) =>
      DraftCart(
        context: context,
        table: clearTable ? null : table ?? this.table,
        items: items ?? this.items,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now().toUtc(),
      );

  Map<String, Object?> toJson() => {
        'schemaVersion': currentSchemaVersion,
        'instanceKey': context.instanceKey,
        'userId': context.userId,
        'companyId': context.companyId,
        'posConfigId': context.posConfigId,
        'table': table == null
            ? null
            : {
                'id': table!.id,
                'number': table!.number,
                'floorId': table!.floorId,
                'floorName': table!.floorName,
                'active': table!.active,
                'seats': table!.seats,
              },
        'items': [for (final item in items) item.toJson()],
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory DraftCart.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != currentSchemaVersion) {
      throw const FormatException('Unsupported local cart schema.');
    }
    final tableValue = json['table'];
    final table = tableValue == null
        ? null
        : Map<String, dynamic>.from(tableValue as Map);
    return DraftCart(
      context: OperationalContext(
        instanceKey: json['instanceKey'] as String,
        userId: json['userId'] as int,
        companyId: json['companyId'] as int,
        posConfigId: json['posConfigId'] as int,
      ),
      table: table == null
          ? null
          : RestaurantTable(
              id: table['id'] as int,
              number: table['number'] as int,
              floorId: table['floorId'] as int,
              floorName: table['floorName'] as String,
              active: table['active'] as bool,
              seats: table['seats'] as int?,
            ),
      items: List<dynamic>.from(json['items'] as List)
          .map((item) => DraftCartItem.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(growable: false),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
