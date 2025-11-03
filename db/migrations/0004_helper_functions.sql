begin;

-- Helper function to decrement product stock safely
-- Used by closeOrder in SupabaseDatabaseService
create or replace function public.decrement_product_stock(
  product_id uuid,
  quantity integer
)
returns void
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
begin
  update public.products
  set stock_quantity = stock_quantity - quantity
  where id = product_id;
end $$;

commit;
