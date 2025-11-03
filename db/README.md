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

## Using in VS Code with MCP

- Apply a migration: use the “Apply migration” action targeting Supabase and paste the SQL contents.
- Verify schema: list tables in schema `public`.
- Advisors: check security/performance advisors to review RLS and index suggestions.

## Notes

- RLS is currently disabled for simplicity while modeling. Before production, enable RLS and add policies.
- UUIDs use `gen_random_uuid()` (pgcrypto extension). If needed, ensure the extension is available in your project.
- Generated column: `order_items.total` is computed from quantity × unit_price.
