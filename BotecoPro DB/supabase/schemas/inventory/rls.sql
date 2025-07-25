-- ============================================
-- RLS Policies for Schema: inventory
-- ============================================

-- Ativar RLS na tabela de fornecedores
alter table inventory.supplier enable row level security;

-- =====================
-- supplier
-- =====================

-- Leitura: liberada para todos os papéis
create policy "public read access to suppliers"
on inventory.supplier
for select
using (true);

-- Escrita: restrita a gerentes
create policy "only manager can manage suppliers"
on inventory.supplier
for all
using (auth.jwt() ->> 'role' = 'manager')
with check (auth.jwt() ->> 'role' = 'manager');
