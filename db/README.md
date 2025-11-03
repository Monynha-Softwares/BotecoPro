# Database Migrations (Supabase)

This folder tracks SQL migrations applied to the remote Boteco database (Supabase/Postgres).

## Applied migrations

- 0001_init_boteco_schema.sql
  - Enums: table_status, order_status, product_category, stock_movement_type
  - Tables: suppliers, products, bar_tables, orders, order_items, sales, recipes, recipe_ingredients, internal_production, production_ingredients, stock_movements
  - Triggers: set_updated_at() for updated_at maintenance
- 0002_rls_and_security.sql
  - Enabled RLS on all public tables
  - Added permissive policies for authenticated role (SELECT, INSERT, UPDATE, DELETE)
  - Hardened set_updated_at() function with explicit search_path
- 0003_seed_demo_data.sql
  - 3 suppliers (Distribuidora SP, Cervejaria Nacional, Alimentos Frescos)
  - 13 products (drinks: beers, chopp, caipirinha, ingredients; food: batata frita, mandioca, pastel, coxinha, espetinho)
  - 8 bar tables (Mesa 1-6, Balcão 1-2)
  - 1 recipe (Caipirinha with ingredients: cachaça, limão, açúcar)
  - 1 internal production record (preparing 10 caipirinhas)
- 0004_helper_functions.sql
  - Created `decrement_product_stock(product_id, quantity)` function for safe stock updates
  - Used by SupabaseDatabaseService.closeOrder() to atomically decrement inventory

## Using in VS Code with MCP

- Apply a migration: use the “Apply migration” action targeting Supabase and paste the SQL contents.
- Verify schema: list tables in schema `public`.
- Advisors: check security/performance advisors to review RLS and index suggestions.

## Notes

- RLS is currently disabled for simplicity while modeling. Before production, enable RLS and add policies.
- UUIDs use `gen_random_uuid()` (pgcrypto extension). If needed, ensure the extension is available in your project.
- Generated column: `order_items.total` is computed from quantity × unit_price.

## Using Supabase in the Flutter app

The app includes `SupabaseDatabaseService` (`lib/core/services/supabase_database_service.dart`) that mirrors the `DatabaseService` API but persists to Supabase instead of SharedPreferences.

### Setup steps

1. **Get Supabase credentials**:
   - Create project at https://app.supabase.com
   - Navigate to Settings > API
   - Copy Project URL and anon/public key

2. **Configure environment**:
   ```bash
   # Add to .env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

3. **Run with Supabase**:
   ```powershell
   # Compile with USE_SUPABASE flag
   flutter run -d web --dart-define=USE_SUPABASE=true
   ```

4. **Integrate in code** (example):
   ```dart
   import 'package:boteco_pro/core/config/database_config.dart';
   import 'package:boteco_pro/core/services/database_service.dart';
   import 'package:boteco_pro/core/services/supabase_database_service.dart';

   // In main() or service initialization
   final dbService = DatabaseConfig.useSupabase
       ? SupabaseDatabaseService()
       : DatabaseService();

   if (DatabaseConfig.useSupabase) {
     await (dbService as SupabaseDatabaseService).initialize(
       url: DatabaseConfig.supabaseUrl,
       anonKey: DatabaseConfig.supabaseAnonKey,
     );
   }

   // Use identical API
   final products = await dbService.getProducts();
   await dbService.addOrder(order);
   ```

### Benefits of Supabase

- ✅ Multi-device sync (data persists server-side)
- ✅ Complex queries (JOINs, aggregations via PostgREST)
- ✅ Real-time subscriptions (optional)
- ✅ Automatic backups
- ✅ Row-level security for multi-tenant apps

### Limitations

- ❌ Requires internet connection
- ❌ Network latency (vs instant local access)
- ❌ Usage-based pricing after free tier (500MB DB, 2GB egress/month)

### Current state

- All migrations applied to remote Supabase project
- Demo data seeded (3 suppliers, 13 products, 8 tables, recipes, productions)
- RLS enabled with permissive authenticated policies
- Helper functions created for stock management

