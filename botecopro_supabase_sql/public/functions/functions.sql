
create or replace function public.get_my_orders()
returns table (
  order_id integer,
  table_id integer,
  status text,
  order_datetime timestamp
)
language sql
security definer
as $$
  select
    order_id, table_id, status, order_datetime
  from orders.order_main
  where employee_id = (auth.jwt() ->> 'employee_id')::integer;
$$;
