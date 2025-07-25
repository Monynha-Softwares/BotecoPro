-- ============================================
-- RLS Policies for Schema: order
-- ============================================

-- Ativar RLS nas tabelas principais
alter table "order".order_main enable row level security;
alter table "order".order_item enable row level security;
alter table "order".order_item_addition enable row level security;

-- =====================
-- order_main
-- =====================

-- Leitura: apenas o funcionário que criou o pedido
create policy "staff can view own orders"
on "order".order_main
for select
using (
  auth.jwt() ->> 'role' = 'waiter' and employee_id = cast(auth.uid() as integer)
);

-- Escrita: permitir criação de pedido pelo garçom
create policy "waiter can insert orders"
on "order".order_main
for insert
with check (
  auth.jwt() ->> 'role' = 'waiter' and employee_id = cast(auth.uid() as integer)
);

-- =====================
-- order_item
-- =====================

-- Leitura: se usuário pode ler order_main
create policy "view items of own orders"
on "order".order_item
for select
using (
  exists (
    select 1 from "order".order_main m
    where m.order_id = order_item.order_id
    and m.employee_id = cast(auth.uid() as integer)
  )
);

-- Escrita: permitido se for autor do pedido
create policy "insert items into own orders"
on "order".order_item
for insert
with check (
  exists (
    select 1 from "order".order_main m
    where m.order_id = order_item.order_id
    and m.employee_id = cast(auth.uid() as integer)
  )
);

-- =====================
-- order_item_addition
-- =====================

-- Leitura: mesmo critério de order_item
create policy "view additions of own orders"
on "order".order_item_addition
for select
using (
  exists (
    select 1 from "order".order_main m
    where m.order_id = order_item_addition.order_id
    and m.employee_id = cast(auth.uid() as integer)
  )
);

-- Escrita: mesmo critério
create policy "insert additions into own orders"
on "order".order_item_addition
for insert
with check (
  exists (
    select 1 from "order".order_main m
    where m.order_id = order_item_addition.order_id
    and m.employee_id = cast(auth.uid() as integer)
  )
);
