// lib/core/services/supabase_database_service.dart
//
/// SupabaseDatabaseService - Serviço de Persistência com Supabase
///
/// IMPLEMENTAÇÃO ALTERNATIVA ao DatabaseService (SharedPreferences)
/// - Usa Supabase/Postgres para armazenar dados remotamente
/// - Suporta sync entre dispositivos
/// - Queries complexas via PostgREST
/// - RLS para segurança multi-tenant
///
/// PADRÃO DE USO:
/// ```dart
/// final dbService = SupabaseDatabaseService();
/// await dbService.initialize(); // Conecta ao Supabase
/// 
/// // API idêntica ao DatabaseService
/// final products = await dbService.getProducts();
/// await dbService.addOrder(order);
/// ```
///
/// CONFIGURAÇÃO (.env ou ambiente):
/// - SUPABASE_URL=https://seu-projeto.supabase.co
/// - SUPABASE_ANON_KEY=eyJhb...
///
/// VANTAGENS:
/// - ✅ Suporta grandes volumes de dados
/// - ✅ Queries complexas (JOIN, agregações)
/// - ✅ Sync em tempo real (opcional)
/// - ✅ Backup automático
/// - ✅ Row Level Security (RLS)
///
/// LIMITAÇÕES:
/// - ❌ Requer conexão internet
/// - ❌ Latência de rede
/// - ❌ Custo conforme uso (free tier: 500MB DB, 2GB transfer)
///
library;

import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/data_models.dart';

/// SupabaseDatabaseService - Gerenciador de persistência remota com Supabase
class SupabaseDatabaseService {
  // Singleton pattern
  static final SupabaseDatabaseService _instance = SupabaseDatabaseService._internal();
  factory SupabaseDatabaseService() => _instance;
  SupabaseDatabaseService._internal();

  SupabaseClient? _client;
  bool _initialized = false;

  // Broadcast stream to notify UI about data changes (matches DatabaseService API)
  final StreamController<String> _changesController =
      StreamController<String>.broadcast();
  Stream<String> get changes => _changesController.stream;

  // Debounce notification
  Timer? _notifyTimer;
  final Set<String> _pendingNotifications = {};

  /// Initialize Supabase connection
  /// Must be called before any other method
  /// Note: Supabase.initialize() should already be called in main.dart
  /// This method just sets up the client reference
  Future<void> initialize({String? url, String? anonKey}) async {
    if (_initialized) return;

    try {
      // Check if Supabase is already initialized (should be from main.dart)
      try {
        _client = Supabase.instance.client;
        _initialized = true;
        return;
      } catch (e) {
        // If not initialized, we need credentials
        final supabaseUrl = url ?? const String.fromEnvironment('SUPABASE_URL');
        final supabaseAnonKey = anonKey ?? const String.fromEnvironment('SUPABASE_ANON_KEY');

        if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
          throw Exception(
            'Supabase credentials missing. Ensure Supabase is initialized in main.dart, '
            'or set SUPABASE_URL and SUPABASE_ANON_KEY in .env',
          );
        }

        // Only initialize if not already done
        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: supabaseAnonKey,
        );

        _client = Supabase.instance.client;
        _initialized = true;
      }
    } catch (error) {
      print('Error initializing Supabase: $error');
      rethrow;
    }
  }

  /// Ensure client is ready
  SupabaseClient get _supabase {
    if (!_initialized || _client == null) {
      throw Exception('SupabaseDatabaseService not initialized. Call initialize() first.');
    }
    return _client!;
  }

  /// Notify UI with debouncing
  void _notify(String topic) {
    if (_changesController.isClosed) return;

    _pendingNotifications.add(topic);

    _notifyTimer?.cancel();
    _notifyTimer = Timer(const Duration(milliseconds: 50), () {
      for (final notif in _pendingNotifications) {
        _changesController.add(notif);
      }
      _pendingNotifications.clear();
    });
  }

  /// Dispose resources
  void dispose() {
    _notifyTimer?.cancel();
    _changesController.close();
  }

  // ==================== SUPPLIERS ====================

  Future<List<Supplier>> getSuppliers() async {
    try {
      final response = await _supabase
          .from('suppliers')
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Supplier.fromJson(json))
          .toList();
    } catch (error) {
      print('Error loading suppliers: $error');
      return [];
    }
  }

  Future<void> saveSuppliers(List<Supplier> suppliers) async {
    // Not typically used with Supabase (use add/update/delete instead)
    // Implemented for API compatibility
    throw UnimplementedError('Use addSupplier/updateSupplier instead');
  }

  Future<void> addSupplier(Supplier supplier) async {
    try {
      await _supabase.from('suppliers').insert(supplier.toJson());
      _notify('suppliers');
    } catch (error) {
      print('Error adding supplier: $error');
      rethrow;
    }
  }

  Future<void> updateSupplier(Supplier supplier) async {
    try {
      await _supabase
          .from('suppliers')
          .update(supplier.toJson())
          .eq('id', supplier.id);
      _notify('suppliers');
    } catch (error) {
      print('Error updating supplier: $error');
      rethrow;
    }
  }

  Future<void> deleteSupplier(String id) async {
    try {
      await _supabase.from('suppliers').delete().eq('id', id);
      _notify('suppliers');
    } catch (error) {
      print('Error deleting supplier: $error');
      rethrow;
    }
  }

  // ==================== PRODUCTS ====================

  Future<List<Product>> getProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('is_active', true)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (error) {
      print('Error loading products: $error');
      return [];
    }
  }

  Future<void> saveProducts(List<Product> products) async {
    throw UnimplementedError('Use addProduct/updateProduct instead');
  }

  Future<void> addProduct(Product product) async {
    try {
      await _supabase.from('products').insert(product.toJson());
      _notify('products');
    } catch (error) {
      print('Error adding product: $error');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _supabase
          .from('products')
          .update(product.toJson())
          .eq('id', product.id);
      _notify('products');
    } catch (error) {
      print('Error updating product: $error');
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      // Soft delete by setting is_active = false
      await _supabase
          .from('products')
          .update({'is_active': false})
          .eq('id', id);
      _notify('products');
    } catch (error) {
      print('Error deleting product: $error');
      rethrow;
    }
  }

  Future<void> updateProductStock(String id, int newQuantity) async {
    try {
      await _supabase
          .from('products')
          .update({'stock_quantity': newQuantity})
          .eq('id', id);
      _notify('products');
    } catch (error) {
      print('Error updating product stock: $error');
      rethrow;
    }
  }

  // ==================== TABLES ====================

  Future<List<TableModel>> getTables() async {
    try {
      final response = await _supabase
          .from('bar_tables')
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((json) => TableModel.fromJson(json))
          .toList();
    } catch (error) {
      print('Error loading tables: $error');
      return [];
    }
  }

  Future<void> saveTables(List<TableModel> tables) async {
    throw UnimplementedError('Use updateTable instead');
  }

  Future<void> updateTable(TableModel table) async {
    try {
      await _supabase
          .from('bar_tables')
          .update(table.toJson())
          .eq('id', table.id);
      _notify('tables');
    } catch (error) {
      print('Error updating table: $error');
      rethrow;
    }
  }

  // ==================== ORDERS ====================

  Future<List<Order>> getOrders() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, order_items(*)')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Order.fromJson(json))
          .toList();
    } catch (error) {
      print('Error loading orders: $error');
      return [];
    }
  }

  Future<void> saveOrders(List<Order> orders) async {
    throw UnimplementedError('Use addOrder/updateOrder instead');
  }

  Future<void> addOrder(Order order) async {
    try {
      // Insert order
      await _supabase.from('orders').insert({
        'id': order.id,
        'table_id': order.tableId,
        'status': order.status.name,
        'total_amount': order.total,
      });

      // Insert order items
      for (final item in order.items) {
        await _supabase.from('order_items').insert({
          'order_id': order.id,
          'product_id': item.productId,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
        });
      }

      // Update table status to occupied
      await _supabase
          .from('bar_tables')
          .update({'status': 'occupied'})
          .eq('id', order.tableId);

      _notify('orders');
      _notify('tables');
    } catch (error) {
      print('Error adding order: $error');
      rethrow;
    }
  }

  Future<void> updateOrder(Order order) async {
    try {
      await _supabase
          .from('orders')
          .update({
            'status': order.status.name,
            'total_amount': order.total,
            'closed_at': order.isClosed ? DateTime.now().toIso8601String() : null,
          })
          .eq('id', order.id);

      _notify('orders');
    } catch (error) {
      print('Error updating order: $error');
      rethrow;
    }
  }

  Future<void> closeOrder(String orderId) async {
    try {
      // Fetch order with items
      final orderResponse = await _supabase
          .from('orders')
          .select('*, order_items(*)')
          .eq('id', orderId)
          .single();

      final order = Order.fromJson(orderResponse);

      // Update order status
      await _supabase
          .from('orders')
          .update({
            'status': 'delivered',
            'closed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);

      // Decrement product stock for each item
      for (final item in order.items) {
        await _supabase.rpc('decrement_product_stock', params: {
          'product_id': item.productId,
          'quantity': item.quantity,
        });
      }

      // Free the table
      await _supabase
          .from('bar_tables')
          .update({'status': 'free'})
          .eq('id', order.tableId);

      // Create sale record
      await _supabase.from('sales').insert({
        'order_id': orderId,
        'gross_amount': order.total,
        'discount_amount': 0,
        'net_amount': order.total,
      });

      // Log stock movements
      for (final item in order.items) {
        await _supabase.from('stock_movements').insert({
          'product_id': item.productId,
          'movement_type': 'sale',
          'quantity': -item.quantity,
          'related_order_id': orderId,
        });
      }

      _notify('orders');
      _notify('products');
      _notify('tables');
      _notify('sales');
    } catch (error) {
      print('Error closing order: $error');
      rethrow;
    }
  }

  // ==================== SALES ====================

  Future<List<Sale>> getSales() async {
    try {
      final response = await _supabase
          .from('sales')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Sale.fromJson(json))
          .toList();
    } catch (error) {
      print('Error loading sales: $error');
      return [];
    }
  }

  Future<void> saveSales(List<Sale> sales) async {
    throw UnimplementedError('Use addSale instead');
  }

  Future<void> addSale(Sale sale) async {
    try {
      await _supabase.from('sales').insert(sale.toJson());
      _notify('sales');
    } catch (error) {
      print('Error adding sale: $error');
      rethrow;
    }
  }

  // ==================== QUERIES ====================

  Future<Order?> getActiveOrderForTable(String tableId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, order_items(*)')
          .eq('table_id', tableId)
          .neq('status', 'delivered')
          .neq('status', 'canceled')
          .maybeSingle();

      if (response == null) return null;
      return Order.fromJson(response);
    } catch (error) {
      print('Error getting active order: $error');
      return null;
    }
  }

  Future<List<Order>> getActiveOrders() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, order_items(*)')
          .neq('status', 'delivered')
          .neq('status', 'canceled')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Order.fromJson(json))
          .toList();
    } catch (error) {
      print('Error loading active orders: $error');
      return [];
    }
  }

  Future<double> getTodaySales() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final response = await _supabase
          .from('sales')
          .select('net_amount')
          .gte('created_at', startOfDay.toIso8601String());

      double total = 0;
      for (final row in response as List) {
        total += (row['net_amount'] as num).toDouble();
      }
      return total;
    } catch (error) {
      print('Error calculating today sales: $error');
      return 0;
    }
  }

  Future<List<Product>> getLowStockProducts(int threshold) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('is_active', true)
          .lte('stock_quantity', threshold)
          .order('stock_quantity', ascending: true);

      return (response as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (error) {
      print('Error loading low stock products: $error');
      return [];
    }
  }

  // ==================== RECIPES ====================

  Future<List<Recipe>> getRecipes() async {
    try {
      final response = await _supabase
          .from('recipes')
          .select('*, recipe_ingredients(*)')
          .order('id', ascending: true);

      return (response as List)
          .map((json) => Recipe.fromJson(json))
          .toList();
    } catch (error) {
      print('Error loading recipes: $error');
      return [];
    }
  }

  Future<void> saveRecipes(List<Recipe> recipes) async {
    throw UnimplementedError('Use addRecipe/updateRecipe instead');
  }

  Future<void> addRecipe(Recipe recipe) async {
    try {
      await _supabase.from('recipes').insert({
        'id': recipe.id,
        'product_id': recipe.productId,
        'notes': recipe.instructions,
      });

      for (final ingredient in recipe.ingredients) {
        await _supabase.from('recipe_ingredients').insert({
          'recipe_id': recipe.id,
          'ingredient_product_id': ingredient.productId,
          'quantity': ingredient.quantity,
          'unit': ingredient.unit,
        });
      }

      _notify('recipes');
    } catch (error) {
      print('Error adding recipe: $error');
      rethrow;
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    try {
      await _supabase
          .from('recipes')
          .update({'notes': recipe.instructions})
          .eq('id', recipe.id);

      _notify('recipes');
    } catch (error) {
      print('Error updating recipe: $error');
      rethrow;
    }
  }

  Future<void> deleteRecipe(String id) async {
    try {
      // Cascade delete handled by DB
      await _supabase.from('recipes').delete().eq('id', id);
      _notify('recipes');
    } catch (error) {
      print('Error deleting recipe: $error');
      rethrow;
    }
  }

  Future<void> addRecipeIngredient(String recipeId, RecipeIngredient ingredient) async {
    try {
      await _supabase.from('recipe_ingredients').insert({
        'recipe_id': recipeId,
        'ingredient_product_id': ingredient.productId,
        'quantity': ingredient.quantity,
        'unit': ingredient.unit,
      });
      _notify('recipes');
    } catch (error) {
      print('Error adding recipe ingredient: $error');
      rethrow;
    }
  }

  // ==================== INTERNAL PRODUCTIONS ====================

  Future<List<InternalProduction>> getInternalProductions() async {
    try {
      final response = await _supabase
          .from('internal_production')
          .select('*, production_ingredients(*)')
          .order('produced_at', ascending: false);

      return (response as List)
          .map((json) => InternalProduction.fromJson(json))
          .toList();
    } catch (error) {
      print('Error loading internal productions: $error');
      return [];
    }
  }

  Future<void> saveInternalProductions(List<InternalProduction> productions) async {
    throw UnimplementedError('Use addInternalProduction/updateInternalProduction instead');
  }

  Future<void> addInternalProduction(InternalProduction production) async {
    try {
      await _supabase.from('internal_production').insert({
        'id': production.id,
        'product_id': production.productId,
        'produced_qty': production.quantityProduced,
        'notes': production.notes,
      });

      for (final ingredient in production.ingredients) {
        await _supabase.from('production_ingredients').insert({
          'production_id': production.id,
          'ingredient_product_id': ingredient.productId,
          'quantity': ingredient.quantityUsed,
          'unit': ingredient.unit,
        });
      }

      // Log stock movement
      await _supabase.from('stock_movements').insert({
        'product_id': production.productId,
        'movement_type': 'production_in',
        'quantity': production.quantityProduced,
        'related_production_id': production.id,
      });

      _notify('productions');
      _notify('products');
    } catch (error) {
      print('Error adding internal production: $error');
      rethrow;
    }
  }

  Future<void> updateInternalProduction(InternalProduction production) async {
    try {
      await _supabase
          .from('internal_production')
          .update({
            'produced_qty': production.quantityProduced,
            'notes': production.notes,
          })
          .eq('id', production.id);

      _notify('productions');
    } catch (error) {
      print('Error updating internal production: $error');
      rethrow;
    }
  }

  Future<void> deleteInternalProduction(String id) async {
    try {
      await _supabase.from('internal_production').delete().eq('id', id);
      _notify('productions');
    } catch (error) {
      print('Error deleting internal production: $error');
      rethrow;
    }
  }

  Future<void> addProductionIngredient(String productionId, ProductionIngredient ingredient) async {
    try {
      await _supabase.from('production_ingredients').insert({
        'production_id': productionId,
        'ingredient_product_id': ingredient.productId,
        'quantity': ingredient.quantityUsed,
        'unit': ingredient.unit,
      });
      _notify('productions');
    } catch (error) {
      print('Error adding production ingredient: $error');
      rethrow;
    }
  }

  /// Initialize with demo data (only if tables are empty)
  Future<void> initializeData() async {
    try {
      final existingTables = await getTables();
      if (existingTables.isEmpty) {
        print('Database already seeded via migration 0003_seed_demo_data.sql');
        print('If you need to re-seed, run the migration again or manually insert data.');
      }
    } catch (error) {
      print('Note: initializeData() not needed for Supabase (use migrations instead)');
    }
  }
}
