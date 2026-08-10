import 'package:flutter_test/flutter_test.dart';

import 'package:boteco_pro/core/odoo/odoo_cart.dart';
import 'package:boteco_pro/core/odoo/odoo_connection.dart';

OdooProduct _product(int id, {double price = 10}) => OdooProduct(
      id: id,
      name: 'Produto $id',
      price: price,
    );

void main() {
  test('keeps real Odoo product IDs and calculates local cart subtotal', () {
    const table = OdooRestaurantTable(
      id: 8,
      number: 12,
      floorId: 2,
      floorName: 'Salão',
      active: true,
      seats: 4,
    );
    const cart = OdooLocalCart(companyId: 1, posConfigId: 3, table: table);

    final updated = cart
        .add(_product(42, price: 8.5))
        .add(_product(42, price: 8.5))
        .add(_product(9, price: 4));

    expect(updated.companyId, 1);
    expect(updated.posConfigId, 3);
    expect(updated.table?.id, 8);
    expect(updated.items, hasLength(2));
    expect(updated.items.first.productId, 42);
    expect(updated.items.first.quantity, 2);
    expect(updated.itemCount, 3);
    expect(updated.subtotal, 21);
  });

  test(
      'updates notes, quantities, removes items and clears only the local cart',
      () {
    const cart = OdooLocalCart(companyId: 1, posConfigId: 1);
    final withItems = cart.add(_product(10)).add(_product(11, price: 5));
    final noted = withItems.updateNote(10, ' sem gelo ');
    final reduced = noted.updateQuantity(10, 3);
    final removed = reduced.updateQuantity(11, 0);

    expect(noted.items.first.note, 'sem gelo');
    expect(reduced.items.first.quantity, 3);
    expect(removed.items, hasLength(1));
    expect(removed.items.single.productId, 10);
    expect(removed.clear().items, isEmpty);
    expect(removed.clear().companyId, 1);
    expect(removed.clear().posConfigId, 1);
  });
}
