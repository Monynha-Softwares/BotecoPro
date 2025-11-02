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
library;


import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
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

  // Cache SharedPreferences instance to avoid repeated async lookups
  SharedPreferences? _sharedPreferences;
  Completer<SharedPreferences>? _sharedPreferencesCompleter;

  // Mutex for write operations to prevent race conditions
  final Map<String, Completer<void>> _writeLocks = {};
  
  // Global operation lock for complex multi-entity operations like closeOrder
  Completer<void>? _closeOrderLock;

  // Broadcast stream to notify UI about data changes
  final StreamController<String> _changesController =
      StreamController<String>.broadcast();
  Stream<String> get changes => _changesController.stream;

  // Debounce notification to avoid excessive UI updates
  Timer? _notifyTimer;
  final Set<String> _pendingNotifications = {};

  // In-memory cache for frequently accessed data
  List<Supplier>? _suppliersCache;
  List<Product>? _productsCache;
  List<TableModel>? _tablesCache;
  List<Order>? _ordersCache;
  List<Sale>? _salesCache;
  List<Recipe>? _recipesCache;
  List<InternalProduction>? _productionsCache;

  /// Get cached SharedPreferences instance (web-optimized)
  Future<SharedPreferences> get _prefsInstance async {
    if (_sharedPreferences != null) return _sharedPreferences!;
    
    // If already loading, wait for it
    if (_sharedPreferencesCompleter != null) {
      return _sharedPreferencesCompleter!.future;
    }
    
    // Start loading
    _sharedPreferencesCompleter = Completer<SharedPreferences>();
    try {
      _sharedPreferences = await SharedPreferences.getInstance();
      _sharedPreferencesCompleter!.complete(_sharedPreferences!);
      return _sharedPreferences!;
    } catch (error) {
      _sharedPreferencesCompleter!.completeError(error);
      _sharedPreferencesCompleter = null;
      rethrow;
    }
  }

  /// Acquire write lock for a key to prevent concurrent modifications
  Future<void> _acquireWriteLock(String key) async {
    while (_writeLocks.containsKey(key)) {
      await _writeLocks[key]!.future;
    }
    _writeLocks[key] = Completer<void>();
  }

  /// Release write lock for a key
  void _releaseWriteLock(String key) {
    if (_writeLocks.containsKey(key)) {
      _writeLocks[key]!.complete();
      _writeLocks.remove(key);
    }
  }

  /// Notify UI with debouncing to batch updates
  void _notify(String topic) {
    if (_changesController.isClosed) return;
    
    _pendingNotifications.add(topic);
    
    // Invalidate cache for the changed topic
    _invalidateCache(topic);
    
    // Cancel existing timer and create new one
    _notifyTimer?.cancel();
    _notifyTimer = Timer(const Duration(milliseconds: 50), () {
      for (final notif in _pendingNotifications) {
        _changesController.add(notif);
      }
      _pendingNotifications.clear();
    });
  }

  /// Invalidate cache for specific data type
  void _invalidateCache(String key) {
    switch (key) {
      case 'suppliers':
        _suppliersCache = null;
        break;
      case 'products':
        _productsCache = null;
        break;
      case 'tables':
        _tablesCache = null;
        break;
      case 'orders':
        _ordersCache = null;
        break;
      case 'sales':
        _salesCache = null;
        break;
      case 'recipes':
        _recipesCache = null;
        break;
      case 'productions':
        _productionsCache = null;
        break;
    }
  }

  /// Clear all in-memory caches (useful for memory management)
  void clearCache() {
    _suppliersCache = null;
    _productsCache = null;
    _tablesCache = null;
    _ordersCache = null;
    _salesCache = null;
    _recipesCache = null;
    _productionsCache = null;
  }

  /// Dispose resources (call when app closes)
  void dispose() {
    _notifyTimer?.cancel();
    _changesController.close();
  }

  // Carrega dados iniciais se necessário
  Future<void> initializeData() async {
    final prefs = await _prefsInstance;
    
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
    // Return cached data if available
    if (_suppliersCache != null) {
      return _suppliersCache!;
    }
    
    try {
      final prefs = await _prefsInstance;
      final suppliersJson = prefs.getStringList(_suppliersKey) ?? [];
      final suppliers = suppliersJson
          .map((jsonString) => Supplier.fromJson(jsonDecode(jsonString)))
          .toList();
      
      // Cache the result
      _suppliersCache = suppliers;
      return suppliers;
    } catch (error) {
      print('Error loading suppliers: $error');
      return [];
    }
  }

  Future<void> saveSuppliers(List<Supplier> suppliers) async {
    await _acquireWriteLock(_suppliersKey);
    try {
      final prefs = await _prefsInstance;
      final suppliersJson =
          suppliers.map((supplier) => jsonEncode(supplier.toJson())).toList();
      await prefs.setStringList(_suppliersKey, suppliersJson);
      _notify('suppliers');
    } catch (error) {
      print('Error saving suppliers: $error');
      rethrow;
    } finally {
      _releaseWriteLock(_suppliersKey);
    }
  }

  Future<void> addSupplier(Supplier supplier) async {
    final suppliers = await getSuppliers();
    suppliers.add(supplier);
    await saveSuppliers(suppliers);
  }

  Future<void> updateSupplier(Supplier supplier) async {
    final suppliers = await getSuppliers();
    final index = suppliers.indexWhere((existingSupplier) => existingSupplier.id == supplier.id);
    if (index != -1) {
      suppliers[index] = supplier;
      await saveSuppliers(suppliers);
    }
  }

  Future<void> deleteSupplier(String id) async {
    final suppliers = await getSuppliers();
    suppliers.removeWhere((supplier) => supplier.id == id);
    await saveSuppliers(suppliers);
  }

  // Métodos para Produtos
  Future<List<Product>> getProducts() async {
    // Return cached data if available
    if (_productsCache != null) {
      return _productsCache!;
    }
    
    try {
      final prefs = await _prefsInstance;
      final productsJson = prefs.getStringList(_productsKey) ?? [];
      final products = productsJson.map((jsonString) => Product.fromJson(jsonDecode(jsonString))).toList();
      
      // Cache the result
      _productsCache = products;
      return products;
    } catch (error) {
      print('Error loading products: $error');
      return [];
    }
  }

  Future<void> saveProducts(List<Product> products) async {
    await _acquireWriteLock(_productsKey);
    try {
      final prefs = await _prefsInstance;
      final productsJson = products.map((product) => jsonEncode(product.toJson())).toList();
      await prefs.setStringList(_productsKey, productsJson);
      _notify('products');
    } catch (error) {
      print('Error saving products: $error');
      rethrow;
    } finally {
      _releaseWriteLock(_productsKey);
    }
  }

  Future<void> addProduct(Product product) async {
    final products = await getProducts();
    products.add(product);
    await saveProducts(products);
  }

  Future<void> updateProduct(Product product) async {
    final products = await getProducts();
    final index = products.indexWhere((existingProduct) => existingProduct.id == product.id);
    if (index != -1) {
      products[index] = product;
      await saveProducts(products);
    }
  }

  Future<void> deleteProduct(String id) async {
    final products = await getProducts();
    products.removeWhere((product) => product.id == id);
    await saveProducts(products);
  }

  Future<void> updateProductStock(String id, int newQuantity) async {
    final products = await getProducts();
    final index = products.indexWhere((product) => product.id == id);
    if (index != -1) {
      products[index] = products[index].copyWith(stockQuantity: newQuantity);
      await saveProducts(products);
    }
  }

  // Métodos para Mesas
  Future<List<TableModel>> getTables() async {
    // Return cached data if available
    if (_tablesCache != null) {
      return _tablesCache!;
    }
    
    try {
      final prefs = await _prefsInstance;
      final tablesJson = prefs.getStringList(_tablesKey) ?? [];
      final tables = tablesJson.map((jsonString) => TableModel.fromJson(jsonDecode(jsonString))).toList();
      
      // Cache the result
      _tablesCache = tables;
      return tables;
    } catch (error) {
      print('Error loading tables: $error');
      return [];
    }
  }

  Future<void> saveTables(List<TableModel> tables) async {
    await _acquireWriteLock(_tablesKey);
    try {
      final prefs = await _prefsInstance;
      final tablesJson = tables.map((table) => jsonEncode(table.toJson())).toList();
      await prefs.setStringList(_tablesKey, tablesJson);
      _notify('tables');
    } catch (error) {
      print('Error saving tables: $error');
      rethrow;
    } finally {
      _releaseWriteLock(_tablesKey);
    }
  }

  Future<void> updateTable(TableModel table) async {
    final tables = await getTables();
    final index = tables.indexWhere((existingTable) => existingTable.id == table.id);
    if (index != -1) {
      tables[index] = table;
      await saveTables(tables);
    }
  }

  // Métodos para Pedidos
  Future<List<Order>> getOrders() async {
    // Return cached data if available
    if (_ordersCache != null) {
      return _ordersCache!;
    }
    
    try {
      final prefs = await _prefsInstance;
      final ordersJson = prefs.getStringList(_ordersKey) ?? [];
      final orders = ordersJson.map((jsonString) => Order.fromJson(jsonDecode(jsonString))).toList();
      
      // Cache the result
      _ordersCache = orders;
      return orders;
    } catch (error) {
      print('Error loading orders: $error');
      return [];
    }
  }

  Future<void> saveOrders(List<Order> orders) async {
    await _acquireWriteLock(_ordersKey);
    try {
      final prefs = await _prefsInstance;
      final ordersJson = orders.map((order) => jsonEncode(order.toJson())).toList();
      await prefs.setStringList(_ordersKey, ordersJson);
      _notify('orders');
    } catch (error) {
      print('Error saving orders: $error');
      rethrow;
    } finally {
      _releaseWriteLock(_ordersKey);
    }
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
    final index = orders.indexWhere((existingOrder) => existingOrder.id == order.id);
    if (index != -1) {
      orders[index] = order;
      await saveOrders(orders);
    }
  }

  Future<void> closeOrder(String orderId) async {
    // Acquire global lock to prevent concurrent closeOrder operations
    while (_closeOrderLock != null) {
      await _closeOrderLock!.future;
    }
    _closeOrderLock = Completer<void>();
    
    try {
      // Fetch all required data in parallel for better performance
      // Including sales to avoid stale cache in addSale
      final results = await Future.wait([
        getOrders(),
        getProducts(),
        getTables(),
        getSales(),
      ]);
      
      final orders = results[0] as List<Order>;
      final products = results[1] as List<Product>;
      final tables = results[2] as List<TableModel>;
      final sales = results[3] as List<Sale>;
      
      final index = orders.indexWhere((order) => order.id == orderId);
      if (index == -1) return;
      
      // Close the order
      orders[index] = orders[index].copyWith(isClosed: true);
      
      // Update product stock
      for (var item in orders[index].items) {
        final productIndex = products.indexWhere((product) => product.id == item.productId);
        if (productIndex != -1) {
          final currentStock = products[productIndex].stockQuantity;
          products[productIndex] = products[productIndex]
              .copyWith(stockQuantity: currentStock - item.quantity);
        }
      }
      
      // Free the table
      final tableIndex = tables.indexWhere((table) => table.id == orders[index].tableId);
      if (tableIndex != -1) {
        tables[tableIndex] = tables[tableIndex].copyWith(
          status: TableStatus.free,
          currentOrderId: null,
        );
      }
      
      // Create sale record and add to sales list
      final sale = Sale(
        orderId: orderId,
        total: orders[index].total,
      );
      sales.add(sale);
      
      // Batch all saves together to minimize I/O
      // Note: Using direct list updates to avoid race conditions
      await Future.wait([
        saveOrders(orders),
        saveProducts(products),
        saveTables(tables),
        saveSales(sales),
      ]);
    } finally {
      // Always release the lock
      _closeOrderLock!.complete();
      _closeOrderLock = null;
    }
  }

  // Métodos para Vendas
  Future<List<Sale>> getSales() async {
    // Return cached data if available
    if (_salesCache != null) {
      return _salesCache!;
    }
    
    try {
      final prefs = await _prefsInstance;
      final salesJson = prefs.getStringList(_salesKey) ?? [];
      final sales = salesJson.map((jsonString) => Sale.fromJson(jsonDecode(jsonString))).toList();
      
      // Cache the result
      _salesCache = sales;
      return sales;
    } catch (error) {
      print('Error loading sales: $error');
      return [];
    }
  }

  Future<void> saveSales(List<Sale> sales) async {
    await _acquireWriteLock(_salesKey);
    try {
      final prefs = await _prefsInstance;
      final salesJson = sales.map((sale) => jsonEncode(sale.toJson())).toList();
      await prefs.setStringList(_salesKey, salesJson);
      _notify('sales');
    } catch (error) {
      print('Error saving sales: $error');
      rethrow;
    } finally {
      _releaseWriteLock(_salesKey);
    }
  }

  Future<void> addSale(Sale sale) async {
    final sales = await getSales();
    sales.add(sale);
    await saveSales(sales);
  }

  // Métodos para consultas específicas
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
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    // More efficient filtering with early exit
    double total = 0;
    for (var sale in sales) {
      if (!sale.timestamp.isBefore(startOfDay) && sale.timestamp.isBefore(endOfDay)) {
        total += sale.total;
      }
    }
    return total;
  }

  Future<List<Product>> getLowStockProducts(int threshold) async {
    final products = await getProducts();
    return products.where((product) => product.stockQuantity <= threshold).toList();
  }
  
  // Métodos para Receitas
  Future<List<Recipe>> getRecipes() async {
    // Return cached data if available
    if (_recipesCache != null) {
      return _recipesCache!;
    }
    
    try {
      final prefs = await _prefsInstance;
      final recipesJson = prefs.getStringList(_recipesKey) ?? [];
      final recipes = recipesJson.map((jsonString) => Recipe.fromJson(jsonDecode(jsonString))).toList();
      
      // Cache the result
      _recipesCache = recipes;
      return recipes;
    } catch (error) {
      print('Error loading recipes: $error');
      return [];
    }
  }

  Future<void> saveRecipes(List<Recipe> recipes) async {
    await _acquireWriteLock(_recipesKey);
    try {
      final prefs = await _prefsInstance;
      final recipesJson = recipes.map((recipe) => jsonEncode(recipe.toJson())).toList();
      await prefs.setStringList(_recipesKey, recipesJson);
      _notify('recipes');
    } catch (error) {
      print('Error saving recipes: $error');
      rethrow;
    } finally {
      _releaseWriteLock(_recipesKey);
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    final recipes = await getRecipes();
    recipes.add(recipe);
    await saveRecipes(recipes);
  }

  Future<void> updateRecipe(Recipe recipe) async {
    final recipes = await getRecipes();
    final index = recipes.indexWhere((existingRecipe) => existingRecipe.id == recipe.id);
    if (index != -1) {
      recipes[index] = recipe;
      await saveRecipes(recipes);
    }
  }

  Future<void> deleteRecipe(String id) async {
    final recipes = await getRecipes();
    recipes.removeWhere((recipe) => recipe.id == id);
    await saveRecipes(recipes);
  }

  Future<void> addRecipeIngredient(String recipeId, RecipeIngredient ingredient) async {
    final recipes = await getRecipes();
    final index = recipes.indexWhere((recipe) => recipe.id == recipeId);
    if (index != -1) {
      final ingredients = [...recipes[index].ingredients, ingredient];
      recipes[index] = recipes[index].copyWith(ingredients: ingredients);
      await saveRecipes(recipes);
    }
  }

  // Métodos para Produções Caseiras
  Future<List<InternalProduction>> getInternalProductions() async {
    // Return cached data if available
    if (_productionsCache != null) {
      return _productionsCache!;
    }
    
    try {
      final prefs = await _prefsInstance;
      final productionsJson = prefs.getStringList(_productionsKey) ?? [];
      final productions = productionsJson.map((jsonString) => InternalProduction.fromJson(jsonDecode(jsonString))).toList();
      
      // Cache the result
      _productionsCache = productions;
      return productions;
    } catch (error) {
      print('Error loading productions: $error');
      return [];
    }
  }

  Future<void> saveInternalProductions(List<InternalProduction> productions) async {
    await _acquireWriteLock(_productionsKey);
    try {
      final prefs = await _prefsInstance;
      final productionsJson = productions.map((production) => jsonEncode(production.toJson())).toList();
      await prefs.setStringList(_productionsKey, productionsJson);
      _notify('productions');
    } catch (error) {
      print('Error saving productions: $error');
      rethrow;
    } finally {
      _releaseWriteLock(_productionsKey);
    }
  }

  Future<void> addInternalProduction(InternalProduction production) async {
    final productions = await getInternalProductions();
    productions.add(production);
    await saveInternalProductions(productions);
  }

  Future<void> updateInternalProduction(InternalProduction production) async {
    final productions = await getInternalProductions();
    final index = productions.indexWhere((existingProduction) => existingProduction.id == production.id);
    if (index != -1) {
      productions[index] = production;
      await saveInternalProductions(productions);
    }
  }

  Future<void> deleteInternalProduction(String id) async {
    final productions = await getInternalProductions();
    productions.removeWhere((production) => production.id == id);
    await saveInternalProductions(productions);
  }

  Future<void> addProductionIngredient(String productionId, ProductionIngredient ingredient) async {
    final productions = await getInternalProductions();
    final index = productions.indexWhere((production) => production.id == productionId);
    if (index != -1) {
      final ingredients = [...productions[index].ingredients, ingredient];
      productions[index] = productions[index].copyWith(ingredients: ingredients);
      await saveInternalProductions(productions);
    }
  }
}