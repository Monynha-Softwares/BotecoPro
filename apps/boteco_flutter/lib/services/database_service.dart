import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_models.dart';

class DatabaseService {
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
          instructions: 'Corte o limão em pedaços, adicione açúcar, cachaça e gelo. Mexa bem.',
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
          instructions: 'Fritar as batatas e adicionar sal. Opcionalmente, adicionar cheddar e bacon.',
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
    return suppliersJson
        .map((e) => Supplier.fromJson(jsonDecode(e)))
        .toList();
  }

  Future<void> saveSuppliers(List<Supplier> suppliers) async {
    final prefs = await SharedPreferences.getInstance();
    final suppliersJson =
        suppliers.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_suppliersKey, suppliersJson);
  }

  Future<void> addSupplier(Supplier supplier) async {
    final suppliers = await getSuppliers();
    suppliers.add(supplier);
    await saveSuppliers(suppliers);
  }

  Future<void> updateSupplier(Supplier supplier) async {
    final suppliers = await getSuppliers();
    final index = suppliers.indexWhere((e) => e.id == supplier.id);
    if (index != -1) {
      suppliers[index] = supplier;
      await saveSuppliers(suppliers);
    }
  }

  Future<void> deleteSupplier(String id) async {
    final suppliers = await getSuppliers();
    suppliers.removeWhere((e) => e.id == id);
    await saveSuppliers(suppliers);
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
    final products = await getProducts();
    final index = products.indexWhere((e) => e.id == product.id);
    if (index != -1) {
      products[index] = product;
      await saveProducts(products);
    }
  }

  Future<void> deleteProduct(String id) async {
    final products = await getProducts();
    products.removeWhere((e) => e.id == id);
    await saveProducts(products);
  }

  Future<void> updateProductStock(String id, int newQuantity) async {
    final products = await getProducts();
    final index = products.indexWhere((e) => e.id == id);
    if (index != -1) {
      products[index] = products[index].copyWith(stockQuantity: newQuantity);
      await saveProducts(products);
    }
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
    final tables = await getTables();
    final index = tables.indexWhere((e) => e.id == table.id);
    if (index != -1) {
      tables[index] = table;
      await saveTables(tables);
    }
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
    final orders = await getOrders();
    final index = orders.indexWhere((e) => e.id == order.id);
    if (index != -1) {
      orders[index] = order;
      await saveOrders(orders);
    }
  }

  Future<void> closeOrder(String orderId) async {
    final orders = await getOrders();
    final index = orders.indexWhere((e) => e.id == orderId);
    if (index != -1) {
      orders[index] = orders[index].copyWith(isClosed: true);
      await saveOrders(orders);

      // Atualiza o estoque dos produtos
      final products = await getProducts();
      for (var item in orders[index].items) {
        final productIndex =
            products.indexWhere((p) => p.id == item.productId);
        if (productIndex != -1) {
          final currentStock = products[productIndex].stockQuantity;
          products[productIndex] = products[productIndex]
              .copyWith(stockQuantity: currentStock - item.quantity);
        }
      }
      await saveProducts(products);

      // Libera a mesa
      final tables = await getTables();
      final tableIndex =
          tables.indexWhere((t) => t.id == orders[index].tableId);
      if (tableIndex != -1) {
        tables[tableIndex] = tables[tableIndex].copyWith(
          status: TableStatus.free,
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

  // Métodos para consultas especu00edficas
  Future<Order?> getActiveOrderForTable(String tableId) async {
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
    return products.where((product) => product.stockQuantity <= threshold).toList();
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
    final recipes = await getRecipes();
    final index = recipes.indexWhere((e) => e.id == recipe.id);
    if (index != -1) {
      recipes[index] = recipe;
      await saveRecipes(recipes);
    }
  }

  Future<void> deleteRecipe(String id) async {
    final recipes = await getRecipes();
    recipes.removeWhere((e) => e.id == id);
    await saveRecipes(recipes);
  }

  Future<void> addRecipeIngredient(String recipeId, RecipeIngredient ingredient) async {
    final recipes = await getRecipes();
    final index = recipes.indexWhere((e) => e.id == recipeId);
    if (index != -1) {
      final ingredients = [...recipes[index].ingredients, ingredient];
      recipes[index] = recipes[index].copyWith(ingredients: ingredients);
      await saveRecipes(recipes);
    }
  }

  // Métodos para Produçu00f5es Caseiras
  Future<List<InternalProduction>> getInternalProductions() async {
    final prefs = await SharedPreferences.getInstance();
    final productionsJson = prefs.getStringList(_productionsKey) ?? [];
    return productionsJson.map((e) => InternalProduction.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveInternalProductions(List<InternalProduction> productions) async {
    final prefs = await SharedPreferences.getInstance();
    final productionsJson = productions.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_productionsKey, productionsJson);
  }

  Future<void> addInternalProduction(InternalProduction production) async {
    final productions = await getInternalProductions();
    productions.add(production);
    await saveInternalProductions(productions);
  }

  Future<void> updateInternalProduction(InternalProduction production) async {
    final productions = await getInternalProductions();
    final index = productions.indexWhere((e) => e.id == production.id);
    if (index != -1) {
      productions[index] = production;
      await saveInternalProductions(productions);
    }
  }

  Future<void> deleteInternalProduction(String id) async {
    final productions = await getInternalProductions();
    productions.removeWhere((e) => e.id == id);
    await saveInternalProductions(productions);
  }

  Future<void> addProductionIngredient(String productionId, ProductionIngredient ingredient) async {
    final productions = await getInternalProductions();
    final index = productions.indexWhere((e) => e.id == productionId);
    if (index != -1) {
      final ingredients = [...productions[index].ingredients, ingredient];
      productions[index] = productions[index].copyWith(ingredients: ingredients);
      await saveInternalProductions(productions);
    }
  }
}