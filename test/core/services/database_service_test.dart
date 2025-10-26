import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boteco_pro/core/models/data_models.dart';
import 'package:boteco_pro/core/services/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DatabaseService order lifecycle', () {
    late DatabaseService databaseService;
    late Order order;
    late TableModel table;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      databaseService = DatabaseService();

      order = Order(
        id: 'order-1',
        tableId: 'table-1',
        tableNumber: 5,
        items: [
          OrderItem(
            id: 'item-1',
            productId: 'product-1',
            productName: 'Test Product',
            quantity: 2,
            price: 10,
          ),
        ],
      );

      table = TableModel(
        id: 'table-1',
        number: 5,
        status: TableStatus.occupied,
        capacity: 4,
        currentOrderId: order.id,
      );

      await databaseService.saveOrders([order]);
      await databaseService.saveTables([table]);
    });

    test('cancelOrder marks order as canceled and frees the table', () async {
      await databaseService.cancelOrder(order.id);

      final savedOrders = await databaseService.getOrders();
      final savedTables = await databaseService.getTables();
      final sales = await databaseService.getSales();

      expect(savedOrders, hasLength(1));
      final savedOrder = savedOrders.first;
      expect(savedOrder.isClosed, isTrue);
      expect(savedOrder.status, OrderStatus.canceled);
      expect(
        savedOrder.items.every((item) => item.status == OrderStatus.canceled),
        isTrue,
      );

      expect(savedTables, hasLength(1));
      final savedTable = savedTables.first;
      expect(savedTable.status, TableStatus.free);
      expect(savedTable.currentOrderId, isNull);

      expect(sales, isEmpty);
    });

    test('closeOrder updates stock, sales and frees the table', () async {
      final product = Product(
        id: 'product-1',
        name: 'Test Product',
        category: ProductCategory.food,
        price: 10,
        stockQuantity: 10,
        unit: 'unidade',
      );

      await databaseService.saveProducts([product]);

      await databaseService.closeOrder(order.id);

      final updatedProducts = await databaseService.getProducts();
      final savedTables = await databaseService.getTables();
      final sales = await databaseService.getSales();
      final savedOrder = (await databaseService.getOrders()).first;

      expect(savedOrder.isClosed, isTrue);
      expect(updatedProducts.first.stockQuantity, 8);
      expect(savedTables.first.status, TableStatus.free);
      expect(savedTables.first.currentOrderId, isNull);
      expect(sales, hasLength(1));
      expect(sales.first.total, savedOrder.total);
    });
  });
}
