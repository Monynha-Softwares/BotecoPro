import 'package:flutter_test/flutter_test.dart';

import 'package:boteco_pro/models/catalog.dart';
import 'package:boteco_pro/models/draft_cart.dart';
import 'package:boteco_pro/models/restaurant.dart';
import 'package:boteco_pro/models/sync_snapshot.dart';

const _context = OperationalContext(
  instanceKey: 'https://example.odoo.com',
  userId: 2,
  companyId: 1,
  posConfigId: 3,
);

CatalogProduct _product(
  int id, {
  double price = 10,
  int? currencyId = 6,
}) =>
    CatalogProduct(
      id: id,
      name: 'Produto $id',
      catalogPrice: price,
      currencyId: currencyId,
    );

void main() {
  test('keeps real Odoo product IDs and calculates local cart subtotal', () {
    const table = RestaurantTable(
      id: 8,
      number: 12,
      floorId: 2,
      floorName: 'Salão',
      active: true,
      seats: 4,
    );
    final cart = DraftCart(
      context: _context,
      table: table,
    );

    final updated = cart
        .add(_product(42, price: 8.5))
        .add(_product(42, price: 8.5))
        .add(_product(9, price: 4));

    expect(updated.context.companyId, 1);
    expect(updated.context.posConfigId, 3);
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
    final cart = DraftCart(
      context: const OperationalContext(
        instanceKey: 'https://example.odoo.com',
        userId: 2,
        companyId: 1,
        posConfigId: 1,
      ),
    );
    final withItems = cart.add(_product(10)).add(_product(11, price: 5));
    final noted = withItems.updateNote(10, ' sem gelo ');
    final reduced = noted.updateQuantity(10, 3);
    final removed = reduced.updateQuantity(11, 0);

    expect(noted.items.first.note, 'sem gelo');
    expect(reduced.items.first.quantity, 3);
    expect(removed.items, hasLength(1));
    expect(removed.items.single.productId, 10);
    expect(removed.clear().items, isEmpty);
    expect(removed.clear().context.companyId, 1);
    expect(removed.clear().context.posConfigId, 1);
  });

  test('serializes a local draft without authentication secrets', () {
    final now = DateTime.utc(2026, 8, 10, 12);
    final cart = DraftCart(
      context: _context,
      createdAt: now,
      updatedAt: now,
    ).add(_product(42, price: 8.5)).updateNote(42, 'sem gelo');

    final json = cart.toJson();
    final encoded = json.toString();
    final restored = DraftCart.fromJson(json);

    expect(json['schemaVersion'], DraftCart.currentSchemaVersion);
    expect(json['instanceKey'], _context.instanceKey);
    expect((json['items'] as List).single, containsPair('unitPrice', 8.5));
    expect((json['items'] as List).single, containsPair('currencyId', 6));
    expect((json['items'] as List).single, isNot(contains('catalogPrice')));
    expect(
      (json['items'] as List).single,
      isNot(contains('capturedUnitPrice')),
    );
    expect(encoded, isNot(contains('apiKey')));
    expect(encoded, isNot(contains('Authorization')));
    expect(restored.items.single.note, 'sem gelo');
    expect(restored.items.single.capturedCurrencyId, 6);
    expect(restored.createdAt, now);
    expect(
      restored.matchesContext(const OperationalContext(
        instanceKey: 'https://example.odoo.com',
        userId: 2,
        companyId: 1,
        posConfigId: 3,
      )),
      isTrue,
    );
    expect(
      restored.matchesContext(const OperationalContext(
        instanceKey: 'https://example.odoo.com',
        userId: 2,
        companyId: 9,
        posConfigId: 3,
      )),
      isFalse,
    );
  });

  test('restores a schema-v1 cart saved before currency metadata existed', () {
    final now = DateTime.utc(2026, 8, 10, 12);
    final json = DraftCart(
      context: _context,
      createdAt: now,
      updatedAt: now,
    ).add(_product(42, price: 8.5)).toJson();
    final items = List<Map<String, Object?>>.from(
      (json['items'] as List).map(
        (item) => Map<String, Object?>.from(item as Map)..remove('currencyId'),
      ),
    );
    json['items'] = items;

    final restored = DraftCart.fromJson(json);

    expect(restored.items.single.productId, 42);
    expect(restored.items.single.capturedCurrencyId, isNull);
    expect(restored.items.single.capturedUnitPrice, 8.5);
  });

  test('reconciles available, changed and unavailable products', () {
    final cart = DraftCart(
      context: const OperationalContext(
        instanceKey: 'https://example.odoo.com',
        userId: 2,
        companyId: 1,
        posConfigId: 1,
      ),
    ).add(_product(1, price: 10)).add(_product(2, price: 5)).add(_product(3));

    final reconciled = cart.reconcile([
      _product(1, price: 10),
      _product(2, price: 6),
    ]);

    expect(reconciled.items[0].state, DraftCartItemState.available);
    expect(reconciled.items[1].state, DraftCartItemState.changed);
    expect(reconciled.items[1].capturedUnitPrice, 5);
    expect(reconciled.items[1].currentCatalogPrice, 6);
    expect(reconciled.items[2].state, DraftCartItemState.unavailable);
    expect(reconciled.items, hasLength(3));
  });

  test('marks a product changed when its catalog currency changes', () {
    final cart = DraftCart(context: _context).add(
      _product(42, price: 8.5, currencyId: 6),
    );

    final reconciled = cart.reconcile([
      _product(42, price: 8.5, currencyId: 2),
    ]);

    expect(reconciled.items.single.state, DraftCartItemState.changed);
    expect(reconciled.items.single.capturedCurrencyId, 6);
    expect(reconciled.items.single.currentCurrencyId, 2);
    expect(reconciled.items.single.capturedUnitPrice, 8.5);
    expect(reconciled.items.single.currentCatalogPrice, 8.5);
  });
}
