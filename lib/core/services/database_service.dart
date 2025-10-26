// lib/core/services/database_service.dart
//
/// DatabaseService - Serviço de Persistência de Dados
///
/// IMPLEMENTAÇÃO ATUAL:
/// - Usa SharedPreferences para armazenar dados localmente
/// - Serializa/deserializa objetos como JSON
/// - Singleton pattern para acesso global
/// - Métodos CRUD para todas as entidades
///
/// ENTIDADES GERENCIADAS:
/// - Suppliers (Fornecedores)
/// - Products (Produtos)
/// - Tables (Mesas)
/// - Orders (Pedidos)
/// - Recipes (Receitas)
/// - InternalProductions (Produções Caseiras)
/// - Sales (Vendas - histórico)
///
/// PADRÃO DE USO:
/// ```dart
/// final dbService = DatabaseService();
///
/// // Criar
/// await dbService.addProduct(product);
///
/// // Ler
/// final products = await dbService.getProducts();
///
/// // Atualizar
/// await dbService.updateProduct(updatedProduct);
///
/// // Deletar
/// await dbService.deleteProduct(productId);
/// ```
///
/// LIMITAÇÕES DO SharedPreferences:
/// - ❌ Não recomendado para grandes volumes de dados (>10MB)
/// - ❌ Sem suporte a queries complexas
/// - ❌ Performance degrada com muitos registros
/// - ❌ Sem relacionamentos entre entidades
///
/// QUANDO MIGRAR PARA DatabaseProvider (SQLite):
/// - Quando tiver >1000 produtos/pedidos
/// - Quando precisar de relatórios complexos
/// - Quando precisar de melhor performance
/// - Ver: lib/core/providers/database_provider.dart
///
/// MÉTODOS PRINCIPAIS:
/// - initializeData(): Cria dados de exemplo na primeira execução
/// - get*(): Retorna lista de entidades
/// - add*(): Adiciona nova entidade
/// - update*(): Atualiza entidade existente
/// - delete*(): Remove entidade por ID
/// - save*(): Salva lista completa de entidades
///

import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';
import '../models/data_models.dart';

/// DatabaseService - Gerenciador de persistência local com SharedPreferences
class DatabaseService {
  // Chaves para armazenamento no SharedPreferences
  static const String _suppliersKey = 'suppliers';
  static const String _productsKey = 'products';
  static const String _tablesKey = 'tables';
  static const String _ordersKey = 'orders';
  static const String _salesKey = 'sales';
  static const String _recipesKey = 'recipes';
  static const String _productionsKey = 'productions';

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Lock para prevenir race conditions em operações concorrentes
  final Lock _lock = Lock();

  /// Valida formato de UUID v4.
  /// 
  /// Lança ArgumentError se o ID não for válido.
  /// Isso previne injeção de código e garante integridade dos dados.
  String _validateId(String id) {
    // Regex para UUID v4: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    
    if (!uuidRegex.hasMatch(id)) {
      throw ArgumentError('ID inválido: $id. Esperado formato UUID v4.');
    }
    
    return id;
  }

  // Carrega dados iniciais se necessário
  Future<void> initializeData() async {
    final prefs = await SharedPreferences.getInstance();

    // Verifica se já existem dados
    if (!prefs.containsKey(_tablesKey)) {
      // Cria algumas mesas de exemplo
      List<TableModel> tables = List.generate(
        10,
        (index) => TableModel(number: index + 1, capacity: (index % 3 + 2)),
      );
      await saveTables(tables);
    }

    // Cria produtos de exemplo se não existirem
    if (!prefs.containsKey(_productsKey)) {
      List<Product> products = [
        Product(
          name: 'Chopp',
          category: ProductCategory.drink,
          price: 10.0,
          stockQuantity: 100,
          unit: 'ml',
          description: 'Chopp artesanal 300ml',
        ),
        Product(
          name: 'Caipirinha',
          category: ProductCategory.drink,
          price: 18.0,
          stockQuantity: 50,
          unit: 'unidade',
          description: 'Caipirinha tradicional de limão',
        ),
        Product(
          name: 'Batata Frita',
          category: ProductCategory.food,
          price: 25.0,
          stockQuantity: 30,
          unit: 'porção',
          description: 'Porção de batata frita com cheddar e bacon',
        ),
        Product(
          name: 'Isca de Frango',
          category: ProductCategory.food,
          price: 30.0,
          stockQuantity: 30,
          unit: 'porção',
          description: 'Porção de isca de frango com molho especial',
        ),
        Product(
          name: 'Refrigerante Lata',
          category: ProductCategory.drink,
          price: 6.0,
          stockQuantity: 120,
          unit: 'unidade',
          description: 'Refrigerante em lata 350ml',
        ),
      ];
      await saveProducts(products);
    }

    // Cria fornecedores de exemplo
    if (!prefs.containsKey(_suppliersKey)) {
      List<Supplier> suppliers = [
        Supplier(
          name: 'Distribuidora de Bebidas ABC',
          contact: '(11) 99999-8888',
          address: 'Rua das Bebidas, 123',
          notes: 'Entrega toda segunda-feira',
        ),
        Supplier(
          name: 'Alimentos Frescos Ltda',
          contact: '(11) 97777-6666',
          address: 'Av. dos Alimentos, 456',
          notes: 'Fornecedor de alimentos frescos',
        ),
      ];
      await saveSuppliers(suppliers);
    }

    // Cria receitas de exemplo
    if (!prefs.containsKey(_recipesKey)) {
      List<Recipe> recipes = [
        Recipe(
          name: 'Caipirinha Tradicional',
          type: RecipeType.drink,
          price: 18.0,
          instructions:
              'Corte o limão em pedaços, adicione açúcar, cachaça e gelo. Mexa bem.',
          ingredients: [
            RecipeIngredient(
              productId: '', // Será preenchido depois
              productName: 'Limão',
              quantity: 1,
              unit: 'unidade',
            ),
            RecipeIngredient(
              productId: '', // Será preenchido depois
              productName: 'Cachaça',
              quantity: 50,
              unit: 'ml',
            ),
          ],
        ),
        Recipe(
          name: 'Porção de Batata Frita',
          type: RecipeType.food,
          price: 25.0,
          instructions:
              'Fritar as batatas e adicionar sal. Opcionalmente, adicionar cheddar e bacon.',
          ingredients: [
            RecipeIngredient(
              productId: '', // Será preenchido depois
              productName: 'Batata',
              quantity: 300,
              unit: 'g',
            ),
          ],
        ),
      ];
      await saveRecipes(recipes);
    }

    // Cria produções caseiras de exemplo
    if (!prefs.containsKey(_productionsKey)) {
      List<InternalProduction> productions = [
        InternalProduction(
          name: 'Cachaça de Abacaxi',
          quantity: 1000,
          unit: 'ml',
          notes: 'Deixar curtir por uma semana',
          ingredients: [
            ProductionIngredient(
              productId: '', // Será preenchido depois
              productName: 'Cachaça Pura',
              quantity: 1,
              unit: 'litro',
            ),
            ProductionIngredient(
              productId: '', // Será preenchido depois
              productName: 'Abacaxi',
              quantity: 1,
              unit: 'unidade',
            ),
          ],
        ),
      ];
      await saveInternalProductions(productions);
    }
  }

  // Métodos para Fornecedores
  Future<List<Supplier>> getSuppliers() async {
    final prefs = await SharedPreferences.getInstance();
    final suppliersJson = prefs.getStringList(_suppliersKey) ?? [];
    return suppliersJson.map((e) => Supplier.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveSuppliers(List<Supplier> suppliers) async {
    final prefs = await SharedPreferences.getInstance();
    final suppliersJson = suppliers.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_suppliersKey, suppliersJson);
  }

  Future<void> addSupplier(Supplier supplier) async {
    final suppliers = await getSuppliers();
    suppliers.add(supplier);
    await saveSuppliers(suppliers);
  }

  Future<void> updateSupplier(Supplier supplier) async {
    await _lock.synchronized(() async {
      final suppliers = await getSuppliers();
      final index = suppliers.indexWhere((e) => e.id == supplier.id);
      if (index != -1) {
        suppliers[index] = supplier;
        await saveSuppliers(suppliers);
      }
    });
  }

  Future<void> deleteSupplier(String id) async {
    await _lock.synchronized(() async {
      _validateId(id);
      final suppliers = await getSuppliers();
      suppliers.removeWhere((e) => e.id == id);
      await saveSuppliers(suppliers);
    });
  }

  // Métodos para Produtos
  Future<List<Product>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = prefs.getStringList(_productsKey) ?? [];
    return productsJson.map((e) => Product.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = products.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_productsKey, productsJson);
  }

  Future<void> addProduct(Product product) async {
    final products = await getProducts();
    products.add(product);
    await saveProducts(products);
  }

  Future<void> updateProduct(Product product) async {
    await _lock.synchronized(() async {
      final products = await getProducts();
      final index = products.indexWhere((e) => e.id == product.id);
      if (index != -1) {
        products[index] = product;
        await saveProducts(products);
      }
    });
  }

  Future<void> deleteProduct(String id) async {
    await _lock.synchronized(() async {
      _validateId(id);
      final products = await getProducts();
      products.removeWhere((e) => e.id == id);
      await saveProducts(products);
    });
  }

  Future<void> updateProductStock(String id, int newQuantity) async {
    await _lock.synchronized(() async {
      _validateId(id);
      final products = await getProducts();
      final index = products.indexWhere((e) => e.id == id);
      if (index != -1) {
        products[index] = products[index].copyWith(stockQuantity: newQuantity);
        await saveProducts(products);
      }
    });
  }

  // Métodos para Mesas
  Future<List<TableModel>> getTables() async {
    final prefs = await SharedPreferences.getInstance();
    final tablesJson = prefs.getStringList(_tablesKey) ?? [];
    return tablesJson.map((e) => TableModel.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveTables(List<TableModel> tables) async {
    final prefs = await SharedPreferences.getInstance();
    final tablesJson = tables.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_tablesKey, tablesJson);
  }

  Future<void> updateTable(TableModel table) async {
    await _lock.synchronized(() async {
      final tables = await getTables();
      final index = tables.indexWhere((e) => e.id == table.id);
      if (index != -1) {
        tables[index] = table;
        await saveTables(tables);
      }
    });
  }

  // Métodos para Pedidos
  Future<List<Order>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getStringList(_ordersKey) ?? [];
    return ordersJson.map((e) => Order.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveOrders(List<Order> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = orders.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_ordersKey, ordersJson);
  }

  Future<void> addOrder(Order order) async {
    final orders = await getOrders();
    orders.add(order);
    await saveOrders(orders);

    // Atualiza status da mesa
    final tables = await getTables();
    final tableIndex = tables.indexWhere((t) => t.id == order.tableId);
    if (tableIndex != -1) {
      tables[tableIndex] = tables[tableIndex].copyWith(
        status: TableStatus.occupied,
        currentOrderId: order.id,
      );
      await saveTables(tables);
    }
  }

  Future<void> updateOrder(Order order) async {
    await _lock.synchronized(() async {
      final orders = await getOrders();
      final index = orders.indexWhere((e) => e.id == order.id);
      if (index != -1) {
        orders[index] = order;
        await saveOrders(orders);
      }
    });
  }

  Future<void> closeOrder(String orderId) async {
    await _lock.synchronized(() async {
      _validateId(orderId);
      final orders = await getOrders();
      final index = orders.indexWhere((e) => e.id == orderId);
      if (index != -1) {
        orders[index] = orders[index].copyWith(isClosed: true);
        await saveOrders(orders);

        // Atualiza o estoque dos produtos
        final products = await getProducts();
        for (var item in orders[index].items) {
          final productIndex = products.indexWhere((p) => p.id == item.productId);
          if (productIndex != -1) {
            final currentStock = products[productIndex].stockQuantity;
            final updatedStock = max(currentStock - item.quantity, 0);
            products[productIndex] =
                products[productIndex].copyWith(stockQuantity: updatedStock);
          }
        }
        await saveProducts(products);

        // Libera a mesa
        final tables = await getTables();
        final tableIndex =
            tables.indexWhere((t) => t.id == orders[index].tableId);
        if (tableIndex != -1) {
          final table = tables[tableIndex];
          tables[tableIndex] = TableModel(
            id: table.id,
            number: table.number,
            status: TableStatus.free,
            capacity: table.capacity,
            currentOrderId: null,
          );
          await saveTables(tables);
        }

        // Cria uma venda
        final sale = Sale(
          orderId: orderId,
          total: orders[index].total,
        );
        await addSale(sale);
      }
    });
  }

  Future<void> cancelOrder(String orderId) async {
    await _lock.synchronized(() async {
      _validateId(orderId);
      final orders = await getOrders();
      final index = orders.indexWhere((order) => order.id == orderId);
      if (index == -1) {
        return;
      }

      final canceledItems = orders[index]
          .items
          .map((item) => item.status == OrderStatus.canceled
              ? item
              : item.copyWith(status: OrderStatus.canceled))
          .toList();

      orders[index] = orders[index].copyWith(
        status: OrderStatus.canceled,
        items: canceledItems,
        isClosed: true,
      );
      await saveOrders(orders);

      final tables = await getTables();
      final tableIndex = tables.indexWhere((t) => t.id == orders[index].tableId);
      if (tableIndex != -1) {
        tables[tableIndex] = tables[tableIndex].copyWith(
          status: TableStatus.free,
          clearCurrentOrderId: true,
        );
        await saveTables(tables);
      }
    });
  }

  // Métodos para Vendas
  Future<List<Sale>> getSales() async {
    final prefs = await SharedPreferences.getInstance();
    final salesJson = prefs.getStringList(_salesKey) ?? [];
    return salesJson.map((e) => Sale.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveSales(List<Sale> sales) async {
    final prefs = await SharedPreferences.getInstance();
    final salesJson = sales.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_salesKey, salesJson);
  }

  Future<void> addSale(Sale sale) async {
    final sales = await getSales();
    sales.add(sale);
    await saveSales(sales);
  }

  // Métodos para consultas específicas
  Future<Order?> getActiveOrderForTable(String tableId) async {
    _validateId(tableId);
    final orders = await getOrders();
    try {
      return orders.firstWhere(
        (order) => order.tableId == tableId && !order.isClosed,
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<Order>> getActiveOrders() async {
    final orders = await getOrders();
    return orders.where((order) => !order.isClosed).toList();
  }

  Future<double> getTodaySales() async {
    final sales = await getSales();
    final today = DateTime.now();
    final todaySales = sales.where((sale) =>
        sale.timestamp.year == today.year &&
        sale.timestamp.month == today.month &&
        sale.timestamp.day == today.day);
    double total = 0;
    for (var sale in todaySales) {
      total += sale.total;
    }
    return total;
  }

  Future<List<Product>> getLowStockProducts(int threshold) async {
    final products = await getProducts();
    return products
        .where((product) => product.stockQuantity <= threshold)
        .toList();
  }

  // Métodos para Receitas
  Future<List<Recipe>> getRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = prefs.getStringList(_recipesKey) ?? [];
    return recipesJson.map((e) => Recipe.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveRecipes(List<Recipe> recipes) async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = recipes.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_recipesKey, recipesJson);
  }

  Future<void> addRecipe(Recipe recipe) async {
    final recipes = await getRecipes();
    recipes.add(recipe);
    await saveRecipes(recipes);
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await _lock.synchronized(() async {
      final recipes = await getRecipes();
      final index = recipes.indexWhere((e) => e.id == recipe.id);
      if (index != -1) {
        recipes[index] = recipe;
        await saveRecipes(recipes);
      }
    });
  }

  Future<void> deleteRecipe(String id) async {
    await _lock.synchronized(() async {
      _validateId(id);
      final recipes = await getRecipes();
      recipes.removeWhere((e) => e.id == id);
      await saveRecipes(recipes);
    });
  }

  Future<void> addRecipeIngredient(
      String recipeId, RecipeIngredient ingredient) async {
    await _lock.synchronized(() async {
      _validateId(recipeId);
      final recipes = await getRecipes();
      final index = recipes.indexWhere((e) => e.id == recipeId);
      if (index != -1) {
        final ingredients = [...recipes[index].ingredients, ingredient];
        recipes[index] = recipes[index].copyWith(ingredients: ingredients);
        await saveRecipes(recipes);
      }
    });
  }

  // Métodos para Produções Caseiras
  Future<List<InternalProduction>> getInternalProductions() async {
    final prefs = await SharedPreferences.getInstance();
    final productionsJson = prefs.getStringList(_productionsKey) ?? [];
    return productionsJson
        .map((e) => InternalProduction.fromJson(jsonDecode(e)))
        .toList();
  }

  Future<void> saveInternalProductions(
      List<InternalProduction> productions) async {
    final prefs = await SharedPreferences.getInstance();
    final productionsJson =
        productions.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_productionsKey, productionsJson);
  }

  Future<void> addInternalProduction(InternalProduction production) async {
    final productions = await getInternalProductions();
    productions.add(production);
    await saveInternalProductions(productions);
  }

  Future<void> updateInternalProduction(InternalProduction production) async {
    await _lock.synchronized(() async {
      final productions = await getInternalProductions();
      final index = productions.indexWhere((e) => e.id == production.id);
      if (index != -1) {
        productions[index] = production;
        await saveInternalProductions(productions);
      }
    });
  }

  Future<void> deleteInternalProduction(String id) async {
    await _lock.synchronized(() async {
      _validateId(id);
      final productions = await getInternalProductions();
      productions.removeWhere((e) => e.id == id);
      await saveInternalProductions(productions);
    });
  }

  Future<void> addProductionIngredient(
      String productionId, ProductionIngredient ingredient) async {
    await _lock.synchronized(() async {
      _validateId(productionId);
      final productions = await getInternalProductions();
      final index = productions.indexWhere((e) => e.id == productionId);
      if (index != -1) {
        final ingredients = [...productions[index].ingredients, ingredient];
        productions[index] =
            productions[index].copyWith(ingredients: ingredients);
        await saveInternalProductions(productions);
      }
    });
  }
}
