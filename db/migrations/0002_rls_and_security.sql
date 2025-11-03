begin;
-- Harden trigger function with explicit search_path
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  new.updated_at = now();
  return new;
end $$;

-- Enable RLS on all domain tables
alter table if exists public.suppliers enable row level security;
alter table if exists public.products enable row level security;
alter table if exists public.bar_tables enable row level security;
alter table if exists public.orders enable row level security;
alter table if exists public.order_items enable row level security;
alter table if exists public.sales enable row level security;
alter table if exists public.recipes enable row level security;
alter table if exists public.recipe_ingredients enable row level security;
alter table if exists public.internal_production enable row level security;
alter table if exists public.production_ingredients enable row level security;
alter table if exists public.stock_movements enable row level security;

-- Authenticated users: allow full CRUD during development/modeling
-- (Tighten later with org/tenant or ownership constraints.)

-- Suppliers
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='suppliers' AND policyname='auth_select_suppliers'
  ) THEN
    CREATE POLICY auth_select_suppliers ON public.suppliers FOR SELECT USING (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='suppliers' AND policyname='auth_insert_suppliers'
  ) THEN
    CREATE POLICY auth_insert_suppliers ON public.suppliers FOR INSERT WITH CHECK (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='suppliers' AND policyname='auth_update_suppliers'
  ) THEN
    CREATE POLICY auth_update_suppliers ON public.suppliers FOR UPDATE USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='suppliers' AND policyname='auth_delete_suppliers'
  ) THEN
    CREATE POLICY auth_delete_suppliers ON public.suppliers FOR DELETE USING (auth.role() = 'authenticated');
  END IF;
END $$;

-- Products
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='products' AND policyname='auth_select_products') THEN
    CREATE POLICY auth_select_products ON public.products FOR SELECT USING (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='products' AND policyname='auth_insert_products') THEN
    CREATE POLICY auth_insert_products ON public.products FOR INSERT WITH CHECK (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='products' AND policyname='auth_update_products') THEN
    CREATE POLICY auth_update_products ON public.products FOR UPDATE USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='products' AND policyname='auth_delete_products') THEN
    CREATE POLICY auth_delete_products ON public.products FOR DELETE USING (auth.role() = 'authenticated');
  END IF;
END $$;

-- Bar tables
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='bar_tables' AND policyname='auth_select_bar_tables') THEN
    CREATE POLICY auth_select_bar_tables ON public.bar_tables FOR SELECT USING (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='bar_tables' AND policyname='auth_insert_bar_tables') THEN
    CREATE POLICY auth_insert_bar_tables ON public.bar_tables FOR INSERT WITH CHECK (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='bar_tables' AND policyname='auth_update_bar_tables') THEN
    CREATE POLICY auth_update_bar_tables ON public.bar_tables FOR UPDATE USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='bar_tables' AND policyname='auth_delete_bar_tables') THEN
    CREATE POLICY auth_delete_bar_tables ON public.bar_tables FOR DELETE USING (auth.role() = 'authenticated');
  END IF;
END $$;

-- Orders
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='orders' AND policyname='auth_select_orders') THEN
    CREATE POLICY auth_select_orders ON public.orders FOR SELECT USING (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='orders' AND policyname='auth_insert_orders') THEN
    CREATE POLICY auth_insert_orders ON public.orders FOR INSERT WITH CHECK (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='orders' AND policyname='auth_update_orders') THEN
    CREATE POLICY auth_update_orders ON public.orders FOR UPDATE USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='orders' AND policyname='auth_delete_orders') THEN
    CREATE POLICY auth_delete_orders ON public.orders FOR DELETE USING (auth.role() = 'authenticated');
  END IF;
END $$;

-- Order items
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='order_items' AND policyname='auth_select_order_items') THEN
    CREATE POLICY auth_select_order_items ON public.order_items FOR SELECT USING (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='order_items' AND policyname='auth_insert_order_items') THEN
    CREATE POLICY auth_insert_order_items ON public.order_items FOR INSERT WITH CHECK (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='order_items' AND policyname='auth_update_order_items') THEN
    CREATE POLICY auth_update_order_items ON public.order_items FOR UPDATE USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='order_items' AND policyname='auth_delete_order_items') THEN
    CREATE POLICY auth_delete_order_items ON public.order_items FOR DELETE USING (auth.role() = 'authenticated');
  END IF;
END $$;

-- Sales
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='sales' AND policyname='auth_select_sales') THEN
    CREATE POLICY auth_select_sales ON public.sales FOR SELECT USING (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='sales' AND policyname='auth_insert_sales') THEN
    CREATE POLICY auth_insert_sales ON public.sales FOR INSERT WITH CHECK (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='sales' AND policyname='auth_update_sales') THEN
    CREATE POLICY auth_update_sales ON public.sales FOR UPDATE USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='sales' AND policyname='auth_delete_sales') THEN
    CREATE POLICY auth_delete_sales ON public.sales FOR DELETE USING (auth.role() = 'authenticated');
  END IF;
END $$;

-- Recipes
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='recipes' AND policyname='auth_select_recipes') THEN
    CREATE POLICY auth_select_recipes ON public.recipes FOR SELECT USING (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='recipes' AND policyname='auth_insert_recipes') THEN
    CREATE POLICY auth_insert_recipes ON public.recipes FOR INSERT WITH CHECK (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='recipes' AND policyname='auth_update_recipes') THEN
    CREATE POLICY auth_update_recipes ON public.recipes FOR UPDATE USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='recipes' AND policyname='auth_delete_recipes') THEN
    CREATE POLICY auth_delete_recipes ON public.recipes FOR DELETE USING (auth.role() = 'authenticated');
  END IF;
END $$;

-- Recipe ingredients
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='recipe_ingredients' AND policyname='auth_select_recipe_ingredients') THEN
    CREATE POLICY auth_select_recipe_ingredients ON public.recipe_ingredients FOR SELECT USING (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='recipe_ingredients' AND policyname='auth_insert_recipe_ingredients') THEN
    CREATE POLICY auth_insert_recipe_ingredients ON public.recipe_ingredients FOR INSERT WITH CHECK (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='recipe_ingredients' AND policyname='auth_update_recipe_ingredients') THEN
    CREATE POLICY auth_update_recipe_ingredients ON public.recipe_ingredients FOR UPDATE USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='recipe_ingredients' AND policyname='auth_delete_recipe_ingredients') THEN
    CREATE POLICY auth_delete_recipe_ingredients ON public.recipe_ingredients FOR DELETE USING (auth.role() = 'authenticated');
  END IF;
END $$;

-- Internal production
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='internal_production' AND policyname='auth_select_internal_production') THEN
    CREATE POLICY auth_select_internal_production ON public.internal_production FOR SELECT USING (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='internal_production' AND policyname='auth_insert_internal_production') THEN
    CREATE POLICY auth_insert_internal_production ON public.internal_production FOR INSERT WITH CHECK (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='internal_production' AND policyname='auth_update_internal_production') THEN
    CREATE POLICY auth_update_internal_production ON public.internal_production FOR UPDATE USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='internal_production' AND policyname='auth_delete_internal_production') THEN
    CREATE POLICY auth_delete_internal_production ON public.internal_production FOR DELETE USING (auth.role() = 'authenticated');
  END IF;
END $$;

-- Production ingredients
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='production_ingredients' AND policyname='auth_select_production_ingredients') THEN
    CREATE POLICY auth_select_production_ingredients ON public.production_ingredients FOR SELECT USING (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='production_ingredients' AND policyname='auth_insert_production_ingredients') THEN
    CREATE POLICY auth_insert_production_ingredients ON public.production_ingredients FOR INSERT WITH CHECK (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='production_ingredients' AND policyname='auth_update_production_ingredients') THEN
    CREATE POLICY auth_update_production_ingredients ON public.production_ingredients FOR UPDATE USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='production_ingredients' AND policyname='auth_delete_production_ingredients') THEN
    CREATE POLICY auth_delete_production_ingredients ON public.production_ingredients FOR DELETE USING (auth.role() = 'authenticated');
  END IF;
END $$;

-- Stock movements
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='stock_movements' AND policyname='auth_select_stock_movements') THEN
    CREATE POLICY auth_select_stock_movements ON public.stock_movements FOR SELECT USING (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='stock_movements' AND policyname='auth_insert_stock_movements') THEN
    CREATE POLICY auth_insert_stock_movements ON public.stock_movements FOR INSERT WITH CHECK (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='stock_movements' AND policyname='auth_update_stock_movements') THEN
    CREATE POLICY auth_update_stock_movements ON public.stock_movements FOR UPDATE USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='stock_movements' AND policyname='auth_delete_stock_movements') THEN
    CREATE POLICY auth_delete_stock_movements ON public.stock_movements FOR DELETE USING (auth.role() = 'authenticated');
  END IF;
END $$;

commit;
