begin;
create extension if not exists pgcrypto with schema public;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'table_status') THEN
    CREATE TYPE table_status AS ENUM ('free','occupied');
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'order_status') THEN
    CREATE TYPE order_status AS ENUM ('pending','preparing','ready','delivered','canceled');
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'product_category') THEN
    CREATE TYPE product_category AS ENUM ('drink','food','other');
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'stock_movement_type') THEN
    CREATE TYPE stock_movement_type AS ENUM ('sale','production_in','manual_adjustment');
  END IF;
END $$;

create table if not exists suppliers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  contact text,
  phone text,
  email text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category product_category not null default 'other',
  price numeric(12,2) not null default 0,
  stock_quantity integer not null default 0,
  supplier_id uuid references suppliers(id) on delete set null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(name, category)
);

create index if not exists idx_products_name on products (name);

create table if not exists bar_tables (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  status table_status not null default 'free',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists orders (
  id uuid primary key default gen_random_uuid(),
  table_id uuid not null references bar_tables(id) on delete restrict,
  status order_status not null default 'pending',
  created_at timestamptz not null default now(),
  closed_at timestamptz,
  total_amount numeric(12,2) not null default 0
);

create index if not exists idx_orders_table_status on orders (table_id, status);

create table if not exists order_items (
  id bigserial primary key,
  order_id uuid not null references orders(id) on delete cascade,
  product_id uuid not null references products(id) on delete restrict,
  quantity integer not null check (quantity > 0),
  unit_price numeric(12,2) not null,
  total numeric(14,2) generated always as (quantity * unit_price) stored
);

create index if not exists idx_order_items_order on order_items (order_id);
create index if not exists idx_order_items_product on order_items (product_id);

create table if not exists sales (
  id uuid primary key default gen_random_uuid(),
  order_id uuid unique references orders(id) on delete cascade,
  gross_amount numeric(12,2) not null,
  discount_amount numeric(12,2) not null default 0,
  net_amount numeric(12,2) not null,
  created_at timestamptz not null default now()
);

create table if not exists recipes (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null unique references products(id) on delete cascade,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists recipe_ingredients (
  id bigserial primary key,
  recipe_id uuid not null references recipes(id) on delete cascade,
  ingredient_product_id uuid not null references products(id) on delete restrict,
  quantity numeric(12,3) not null check (quantity > 0),
  unit text
);

create index if not exists idx_recipe_ingredients_recipe on recipe_ingredients (recipe_id);

create table if not exists internal_production (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references products(id) on delete restrict,
  produced_qty numeric(12,3) not null check (produced_qty > 0),
  produced_at timestamptz not null default now(),
  notes text
);

create table if not exists production_ingredients (
  id bigserial primary key,
  production_id uuid not null references internal_production(id) on delete cascade,
  ingredient_product_id uuid not null references products(id) on delete restrict,
  quantity numeric(12,3) not null check (quantity > 0),
  unit text
);

create index if not exists idx_production_ingredients_production on production_ingredients (production_id);

create table if not exists stock_movements (
  id bigserial primary key,
  product_id uuid not null references products(id) on delete restrict,
  movement_type stock_movement_type not null,
  quantity numeric(12,3) not null,
  related_order_id uuid references orders(id) on delete set null,
  related_production_id uuid references internal_production(id) on delete set null,
  reason text,
  created_at timestamptz not null default now()
);

create or replace function set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_trigger where tgname = 'trg_suppliers_updated_at'
  ) then
    create trigger trg_suppliers_updated_at before update on suppliers
    for each row execute function set_updated_at();
  end if;

  if not exists (
    select 1 from pg_trigger where tgname = 'trg_products_updated_at'
  ) then
    create trigger trg_products_updated_at before update on products
    for each row execute function set_updated_at();
  end if;

  if not exists (
    select 1 from pg_trigger where tgname = 'trg_bar_tables_updated_at'
  ) then
    create trigger trg_bar_tables_updated_at before update on bar_tables
    for each row execute function set_updated_at();
  end if;

  if not exists (
    select 1 from pg_trigger where tgname = 'trg_recipes_updated_at'
  ) then
    create trigger trg_recipes_updated_at before update on recipes
    for each row execute function set_updated_at();
  end if;
end $$;
commit;
