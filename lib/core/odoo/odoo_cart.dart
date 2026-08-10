import 'odoo_connection.dart';

class OdooCartItem {
  const OdooCartItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    this.quantity = 1,
    this.note = '',
  });

  final int productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final String note;

  double get subtotal => unitPrice * quantity;

  OdooCartItem copyWith({int? quantity, String? note}) => OdooCartItem(
        productId: productId,
        productName: productName,
        unitPrice: unitPrice,
        quantity: quantity ?? this.quantity,
        note: note ?? this.note,
      );
}

class OdooLocalCart {
  const OdooLocalCart({
    required this.companyId,
    required this.posConfigId,
    this.table,
    this.items = const [],
  });

  final int companyId;
  final int posConfigId;
  final OdooRestaurantTable? table;
  final List<OdooCartItem> items;

  int get itemCount => items.fold(0, (total, item) => total + item.quantity);
  double get subtotal => items.fold(0, (total, item) => total + item.subtotal);

  OdooLocalCart add(OdooProduct product) {
    final index = items.indexWhere((item) => item.productId == product.id);
    if (index < 0) {
      return copyWith(
        items: [
          ...items,
          OdooCartItem(
              productId: product.id,
              productName: product.name,
              unitPrice: product.price)
        ],
      );
    }
    return updateQuantity(product.id, items[index].quantity + 1);
  }

  OdooLocalCart updateQuantity(int productId, int quantity) {
    if (quantity <= 0) return remove(productId);
    return copyWith(
      items: [
        for (final item in items)
          if (item.productId == productId)
            item.copyWith(quantity: quantity)
          else
            item,
      ],
    );
  }

  OdooLocalCart updateNote(int productId, String note) => copyWith(
        items: [
          for (final item in items)
            if (item.productId == productId)
              item.copyWith(note: note.trim())
            else
              item,
        ],
      );

  OdooLocalCart remove(int productId) => copyWith(
        items: items
            .where((item) => item.productId != productId)
            .toList(growable: false),
      );

  OdooLocalCart clear() => copyWith(items: const []);

  OdooLocalCart copyWith(
          {OdooRestaurantTable? table, List<OdooCartItem>? items}) =>
      OdooLocalCart(
        companyId: companyId,
        posConfigId: posConfigId,
        table: table ?? this.table,
        items: items ?? this.items,
      );
}
