import 'odoo_connection.dart';

enum OdooCartItemState { available, changed, unavailable }

class OdooCartItem {
  const OdooCartItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    this.quantity = 1,
    this.note = '',
    this.state = OdooCartItemState.available,
    this.currentProductName,
    this.currentUnitPrice,
  });

  final int productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final String note;
  final OdooCartItemState state;
  final String? currentProductName;
  final double? currentUnitPrice;

  double get subtotal => unitPrice * quantity;

  OdooCartItem copyWith({
    int? quantity,
    String? note,
    OdooCartItemState? state,
    String? currentProductName,
    double? currentUnitPrice,
    bool clearCurrentValues = false,
  }) =>
      OdooCartItem(
        productId: productId,
        productName: productName,
        unitPrice: unitPrice,
        quantity: quantity ?? this.quantity,
        note: note ?? this.note,
        state: state ?? this.state,
        currentProductName: clearCurrentValues
            ? null
            : currentProductName ?? this.currentProductName,
        currentUnitPrice: clearCurrentValues
            ? null
            : currentUnitPrice ?? this.currentUnitPrice,
      );

  Map<String, Object?> toJson() => {
        'productId': productId,
        'productName': productName,
        'unitPrice': unitPrice,
        'quantity': quantity,
        'note': note,
      };

  factory OdooCartItem.fromJson(Map<String, dynamic> json) => OdooCartItem(
        productId: json['productId'] as int,
        productName: json['productName'] as String,
        unitPrice: (json['unitPrice'] as num).toDouble(),
        quantity: json['quantity'] as int,
        note: json['note'] as String? ?? '',
      );
}

class OdooLocalCart {
  OdooLocalCart({
    required this.instanceKey,
    required this.userId,
    required this.companyId,
    required this.posConfigId,
    this.table,
    this.items = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now().toUtc(),
        updatedAt = updatedAt ?? DateTime.now().toUtc();

  static const currentSchemaVersion = 1;

  final String instanceKey;
  final int userId;
  final int companyId;
  final int posConfigId;
  final OdooRestaurantTable? table;
  final List<OdooCartItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get itemCount => items.fold(0, (total, item) => total + item.quantity);
  double get subtotal => items.fold(0, (total, item) => total + item.subtotal);
  bool get hasUnavailableItems =>
      items.any((item) => item.state == OdooCartItemState.unavailable);

  bool matchesContext({
    required String instanceKey,
    required int userId,
    required int companyId,
    required int posConfigId,
  }) =>
      this.instanceKey == instanceKey &&
      this.userId == userId &&
      this.companyId == companyId &&
      this.posConfigId == posConfigId;

  OdooLocalCart add(OdooProduct product) {
    final index = items.indexWhere((item) => item.productId == product.id);
    if (index < 0) {
      return copyWith(items: [
        ...items,
        OdooCartItem(
          productId: product.id,
          productName: product.name,
          unitPrice: product.price,
        )
      ]);
    }
    return updateQuantity(product.id, items[index].quantity + 1);
  }

  OdooLocalCart updateQuantity(int productId, int quantity) {
    if (quantity <= 0) return remove(productId);
    return copyWith(items: [
      for (final item in items)
        if (item.productId == productId)
          item.copyWith(quantity: quantity)
        else
          item,
    ]);
  }

  OdooLocalCart updateNote(int productId, String note) => copyWith(items: [
        for (final item in items)
          if (item.productId == productId)
            item.copyWith(note: note.trim())
          else
            item,
      ]);

  OdooLocalCart remove(int productId) => copyWith(
        items: items
            .where((item) => item.productId != productId)
            .toList(growable: false),
      );

  OdooLocalCart clear() => copyWith(items: const []);

  OdooLocalCart reconcile(List<OdooProduct> products) {
    final catalog = {for (final product in products) product.id: product};
    return copyWith(items: [
      for (final item in items) _reconcileItem(item, catalog[item.productId]),
    ]);
  }

  OdooCartItem _reconcileItem(OdooCartItem item, OdooProduct? product) {
    if (product == null) {
      return item.copyWith(state: OdooCartItemState.unavailable);
    }
    final priceChanged =
        (item.unitPrice * 100).round() != (product.price * 100).round();
    final changed = item.productName != product.name || priceChanged;
    return item.copyWith(
      state: changed ? OdooCartItemState.changed : OdooCartItemState.available,
      currentProductName: changed ? product.name : null,
      currentUnitPrice: changed ? product.price : null,
      clearCurrentValues: !changed,
    );
  }

  OdooLocalCart copyWith({
    OdooRestaurantTable? table,
    bool clearTable = false,
    List<OdooCartItem>? items,
    DateTime? updatedAt,
  }) =>
      OdooLocalCart(
        instanceKey: instanceKey,
        userId: userId,
        companyId: companyId,
        posConfigId: posConfigId,
        table: clearTable ? null : table ?? this.table,
        items: items ?? this.items,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now().toUtc(),
      );

  Map<String, Object?> toJson() => {
        'schemaVersion': currentSchemaVersion,
        'instanceKey': instanceKey,
        'userId': userId,
        'companyId': companyId,
        'posConfigId': posConfigId,
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

  factory OdooLocalCart.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != currentSchemaVersion) {
      throw const FormatException('Unsupported local cart schema.');
    }
    final tableValue = json['table'];
    final table = tableValue == null
        ? null
        : Map<String, dynamic>.from(tableValue as Map);
    return OdooLocalCart(
      instanceKey: json['instanceKey'] as String,
      userId: json['userId'] as int,
      companyId: json['companyId'] as int,
      posConfigId: json['posConfigId'] as int,
      table: table == null
          ? null
          : OdooRestaurantTable(
              id: table['id'] as int,
              number: table['number'] as int,
              floorId: table['floorId'] as int,
              floorName: table['floorName'] as String,
              active: table['active'] as bool,
              seats: table['seats'] as int?,
            ),
      items: List<dynamic>.from(json['items'] as List)
          .map((item) => OdooCartItem.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(growable: false),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
