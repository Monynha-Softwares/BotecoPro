-- ============================================
-- invoice/functions.sql
-- ============================================

create or replace function invoice.generate_invoice(
  order_id integer,
  food_tax_rate numeric,
  drink_tax_rate numeric
)
returns integer
language plpgsql
as $$
declare
  total_food numeric := 0;
  total_drink numeric := 0;
  tax_amount numeric;
  total_amount numeric;
  invoice_id integer;
begin
  select coalesce(sum(oi.quantity * oi.base_price), 0)
    into total_food
  from "order".order_item oi
  join core.recipe r on oi.recipe_id = r.recipe_id
  join core.category c on r.category_id = c.category_id
  where oi.order_id = order_id and c.name = 'Food';

  select coalesce(sum(oi.quantity * oi.base_price), 0)
    into total_drink
  from "order".order_item oi
  join core.recipe r on oi.recipe_id = r.recipe_id
  join core.category c on r.category_id = c.category_id
  where oi.order_id = order_id and c.name = 'Drink';

  tax_amount := (total_food * food_tax_rate / 100) + (total_drink * drink_tax_rate / 100);
  total_amount := total_food + total_drink + tax_amount;

  insert into invoice.invoice (order_id, total_amount, tax_amount, food_tax_rate, drink_tax_rate)
  values (order_id, total_amount, tax_amount, food_tax_rate, drink_tax_rate)
  returning invoice_id into invoice_id;

  return invoice_id;
end;
$$;
