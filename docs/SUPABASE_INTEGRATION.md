# Supabase Integration Guide

## Overview

BotecoPro now supports **two database backends**:

1. **SharedPreferences** (default) - Local-only, client-side persistence
2. **Supabase** (optional) - Remote PostgreSQL with multi-device sync

Both backends expose the **same API**, so you can switch between them without changing application code.

## Quick Start (Supabase)

### 1. Install dependencies

```powershell
flutter pub get
```

This installs `supabase_flutter: ^2.10.3` (already in pubspec.yaml).

### 2. Get Supabase credentials

1. Create a free project at https://app.supabase.com
2. Go to **Settings > API**
3. Copy:
   - **Project URL** (e.g., `https://abcdefgh.supabase.co`)
   - **anon/public key** (starts with `eyJhbG...`)

### 3. Configure environment

Add to `.env` (copy from `.env.example`):

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 4. Run with Supabase enabled

```powershell
# Web
flutter run -d web --dart-define=USE_SUPABASE=true

# Desktop/Mobile
flutter run -d windows --dart-define=USE_SUPABASE=true
```

**Without the flag**, the app uses SharedPreferences (default behavior).

## Architecture

### File Structure

```
lib/core/
├── config/
│   └── database_config.dart       # Toggle USE_SUPABASE flag
├── services/
│   ├── database_service.dart      # SharedPreferences implementation
│   └── supabase_database_service.dart  # Supabase implementation
└── models/
    └── data_models.dart           # Shared models (Supplier, Product, Order, etc.)

db/
├── migrations/
│   ├── 0001_init_boteco_schema.sql
│   ├── 0002_rls_and_security.sql
│   ├── 0003_seed_demo_data.sql
│   └── 0004_helper_functions.sql
└── README.md
```

### API Compatibility

Both services implement the same interface:

```dart
// Suppliers
Future<List<Supplier>> getSuppliers()
Future<void> addSupplier(Supplier supplier)
Future<void> updateSupplier(Supplier supplier)
Future<void> deleteSupplier(String id)

// Products
Future<List<Product>> getProducts()
Future<void> addProduct(Product product)
Future<void> updateProduct(Product product)
Future<void> deleteProduct(String id)
Future<void> updateProductStock(String id, int newQuantity)

// Tables
Future<List<TableModel>> getTables()
Future<void> updateTable(TableModel table)

// Orders
Future<List<Order>> getOrders()
Future<void> addOrder(Order order)
Future<void> updateOrder(Order order)
Future<void> closeOrder(String orderId)  // Closes order, updates stock, frees table, creates sale

// Sales
Future<List<Sale>> getSales()
Future<void> addSale(Sale sale)

// Queries
Future<Order?> getActiveOrderForTable(String tableId)
Future<List<Order>> getActiveOrders()
Future<double> getTodaySales()
Future<List<Product>> getLowStockProducts(int threshold)

// Recipes
Future<List<Recipe>> getRecipes()
Future<void> addRecipe(Recipe recipe)
Future<void> updateRecipe(Recipe recipe)
Future<void> deleteRecipe(String id)
Future<void> addRecipeIngredient(String recipeId, RecipeIngredient ingredient)

// Internal Productions
Future<List<InternalProduction>> getInternalProductions()
Future<void> addInternalProduction(InternalProduction production)
Future<void> updateInternalProduction(InternalProduction production)
Future<void> deleteInternalProduction(String id)
Future<void> addProductionIngredient(String productionId, ProductionIngredient ingredient)

// Lifecycle
Future<void> initializeData()  // Seeds demo data (SharedPreferences only)
void dispose()
```

## Integration Example

### Option A: Direct instantiation (simple)

```dart
import 'package:boteco_pro/core/config/database_config.dart';
import 'package:boteco_pro/core/services/database_service.dart';
import 'package:boteco_pro/core/services/supabase_database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Choose backend based on config
  final dbService = DatabaseConfig.useSupabase
      ? SupabaseDatabaseService()
      : DatabaseService();

  // Initialize Supabase if selected
  if (DatabaseConfig.useSupabase) {
    await (dbService as SupabaseDatabaseService).initialize(
      url: DatabaseConfig.supabaseUrl,
      anonKey: DatabaseConfig.supabaseAnonKey,
    );
  } else {
    await (dbService as DatabaseService).initializeData();
  }

  runApp(MyApp(dbService: dbService));
}
```

### Option B: Provider pattern (recommended)

```dart
// lib/core/providers/database_provider_factory.dart
import 'package:boteco_pro/core/config/database_config.dart';
import 'package:boteco_pro/core/services/database_service.dart';
import 'package:boteco_pro/core/services/supabase_database_service.dart';

class DatabaseProviderFactory {
  static dynamic create() {
    return DatabaseConfig.useSupabase
        ? SupabaseDatabaseService()
        : DatabaseService();
  }

  static Future<void> initialize(dynamic service) async {
    if (service is SupabaseDatabaseService) {
      await service.initialize(
        url: DatabaseConfig.supabaseUrl,
        anonKey: DatabaseConfig.supabaseAnonKey,
      );
    } else if (service is DatabaseService) {
      await service.initializeData();
    }
  }
}

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbService = DatabaseProviderFactory.create();
  await DatabaseProviderFactory.initialize(dbService);

  runApp(MyApp(dbService: dbService));
}
```

### In pages (usage remains identical)

```dart
class ProductsPage extends StatefulWidget {
  final dynamic dbService;  // Works with both DatabaseService and SupabaseDatabaseService

  const ProductsPage({required this.dbService, super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // Listen to changes (both services support this)
    widget.dbService.changes.listen((_) {
      if (mounted) _loadData();
    });
  }

  Future<void> _loadData() async {
    final products = await widget.dbService.getProducts();
    if (mounted) {
      setState(() => _products = products);
    }
  }

  // ... rest of page
}
```

## Database Schema

See `db/README.md` for full schema documentation. Key entities:

- **suppliers** - Vendor contacts
- **products** - Inventory items (drinks, food, ingredients)
- **bar_tables** - Table/counter seats with status (free/occupied)
- **orders** + **order_items** - Customer orders with line items
- **sales** - Completed sales records
- **recipes** + **recipe_ingredients** - Product recipes (e.g., Caipirinha = cachaça + limão + açúcar)
- **internal_production** + **production_ingredients** - Batch production tracking
- **stock_movements** - Inventory ledger (sales, productions, adjustments)

## Migration History

All migrations are tracked in `db/migrations/`:

1. `0001_init_boteco_schema.sql` - Core schema (tables, enums, triggers)
2. `0002_rls_and_security.sql` - Row-level security + hardened functions
3. `0003_seed_demo_data.sql` - Demo suppliers, products, tables, recipes
4. `0004_helper_functions.sql` - `decrement_product_stock()` for atomic updates

## Differences: SharedPreferences vs Supabase

| Feature | SharedPreferences | Supabase |
|---------|------------------|----------|
| **Data location** | Browser localStorage | Remote Postgres DB |
| **Sync** | Single device only | Multi-device sync |
| **Offline** | ✅ Always works | ❌ Requires internet |
| **Queries** | List filtering in Dart | SQL queries (JOIN, GROUP BY) |
| **Storage limit** | ~5-10 MB (browser) | 500 MB (free tier) |
| **Latency** | <1ms | 50-200ms (network) |
| **Backup** | Manual export | Automatic daily |
| **Security** | Client-side only | Row-level security (RLS) |
| **Cost** | Free | Free tier, then usage-based |

## Troubleshooting

### Supabase initialization fails

**Error**: `Supabase credentials missing`

**Fix**: Ensure `.env` contains valid `SUPABASE_URL` and `SUPABASE_ANON_KEY`, and you're running with `--dart-define=USE_SUPABASE=true`.

### Data not appearing

**Issue**: Switching from SharedPreferences to Supabase shows empty data.

**Reason**: They are separate backends. Data in localStorage doesn't sync to Supabase automatically.

**Solution**: Either:
- Re-create orders/products in Supabase UI
- Export from localStorage and import to Supabase (manual JSON migration)
- Use demo data (already seeded in migration 0003)

### closeOrder() fails on Supabase

**Error**: `function public.decrement_product_stock does not exist`

**Fix**: Apply migration 0004:
```sql
-- In Supabase SQL Editor
-- Paste contents of db/migrations/0004_helper_functions.sql
```

### RLS policy errors

**Error**: `new row violates row-level security policy`

**Reason**: Authenticated user policies expect `auth.role() = 'authenticated'`.

**Fix**: Ensure Clerk user is authenticated and Supabase session is valid. For development, you can temporarily disable RLS:
```sql
ALTER TABLE products DISABLE ROW LEVEL SECURITY;
```

## Next Steps

- [ ] Add real-time subscriptions for live updates across devices
- [ ] Implement soft deletes (track `deleted_at` instead of hard DELETE)
- [ ] Add tenant/organization support (multi-bar management)
- [ ] Create views for common reports (daily sales, top products, low stock alerts)
- [ ] Add indexes for frequently queried columns (orders by date, products by category)
- [ ] Implement offline-first mode with local cache + background sync

## Resources

- Supabase Docs: https://supabase.com/docs
- Flutter Supabase SDK: https://supabase.com/docs/guides/getting-started/tutorials/with-flutter
- PostgREST API: https://postgrest.org/en/stable/
- Row Level Security: https://supabase.com/docs/guides/auth/row-level-security
