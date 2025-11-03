begin;

-- Suppliers
insert into public.suppliers (id, name, contact, phone, email) values
  ('00000000-0000-0000-0000-000000000001', 'Distribuidora São Paulo', 'João Silva', '(11) 98765-4321', 'joao@distsp.com.br'),
  ('00000000-0000-0000-0000-000000000002', 'Cervejaria Nacional', 'Maria Santos', '(21) 99876-5432', 'maria@cervnacional.com.br'),
  ('00000000-0000-0000-0000-000000000003', 'Alimentos Frescos Ltda', 'Pedro Oliveira', '(11) 91234-5678', 'pedro@alimentosfrescos.com.br')
on conflict (id) do nothing;

-- Products (drinks)
insert into public.products (id, name, category, price, stock_quantity, supplier_id, is_active) values
  ('10000000-0000-0000-0000-000000000001', 'Cerveja Pilsen 600ml', 'drink', 8.50, 100, '00000000-0000-0000-0000-000000000002', true),
  ('10000000-0000-0000-0000-000000000002', 'Chopp Claro 500ml', 'drink', 12.00, 80, '00000000-0000-0000-0000-000000000002', true),
  ('10000000-0000-0000-0000-000000000003', 'Refrigerante 350ml', 'drink', 5.00, 150, '00000000-0000-0000-0000-000000000001', true),
  ('10000000-0000-0000-0000-000000000004', 'Água Mineral 500ml', 'drink', 3.50, 200, '00000000-0000-0000-0000-000000000001', true),
  ('10000000-0000-0000-0000-000000000005', 'Caipirinha', 'drink', 15.00, 50, null, true),
  ('10000000-0000-0000-0000-000000000006', 'Cachaça 50ml', 'drink', 4.00, 100, '00000000-0000-0000-0000-000000000001', true),
  ('10000000-0000-0000-0000-000000000007', 'Limão (unidade)', 'food', 0.50, 80, '00000000-0000-0000-0000-000000000003', true),
  ('10000000-0000-0000-0000-000000000008', 'Açúcar (kg)', 'food', 3.00, 20, '00000000-0000-0000-0000-000000000003', true)
on conflict (name, category) do nothing;

-- Products (food)
insert into public.products (id, name, category, price, stock_quantity, supplier_id, is_active) values
  ('20000000-0000-0000-0000-000000000001', 'Porção de Batata Frita', 'food', 18.00, 30, '00000000-0000-0000-0000-000000000003', true),
  ('20000000-0000-0000-0000-000000000002', 'Porção de Mandioca', 'food', 16.00, 25, '00000000-0000-0000-0000-000000000003', true),
  ('20000000-0000-0000-0000-000000000003', 'Pastel (unidade)', 'food', 6.00, 40, '00000000-0000-0000-0000-000000000003', true),
  ('20000000-0000-0000-0000-000000000004', 'Coxinha (unidade)', 'food', 5.50, 45, '00000000-0000-0000-0000-000000000003', true),
  ('20000000-0000-0000-0000-000000000005', 'Espetinho de Carne', 'food', 8.00, 35, '00000000-0000-0000-0000-000000000003', true)
on conflict (name, category) do nothing;

-- Bar tables
insert into public.bar_tables (id, name, status) values
  ('30000000-0000-0000-0000-000000000001', 'Mesa 1', 'free'),
  ('30000000-0000-0000-0000-000000000002', 'Mesa 2', 'free'),
  ('30000000-0000-0000-0000-000000000003', 'Mesa 3', 'free'),
  ('30000000-0000-0000-0000-000000000004', 'Mesa 4', 'free'),
  ('30000000-0000-0000-0000-000000000005', 'Mesa 5', 'free'),
  ('30000000-0000-0000-0000-000000000006', 'Mesa 6', 'free'),
  ('30000000-0000-0000-0000-000000000007', 'Balcão 1', 'free'),
  ('30000000-0000-0000-0000-000000000008', 'Balcão 2', 'free')
on conflict (name) do nothing;

-- Recipe for Caipirinha (shows how ingredients map to products)
insert into public.recipes (id, product_id, notes) values
  ('40000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000005', 'Caipirinha tradicional - misturar cachaça, limão, açúcar e gelo')
on conflict (product_id) do nothing;

insert into public.recipe_ingredients (recipe_id, ingredient_product_id, quantity, unit) values
  ('40000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000006', 50, 'ml'),  -- Cachaça
  ('40000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000007', 1, 'unidade'),  -- Limão
  ('40000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000008', 0.02, 'kg')   -- Açúcar (20g)
on conflict do nothing;

-- Sample internal production (e.g., preparing 10 caipirinhas in advance)
insert into public.internal_production (id, product_id, produced_qty, notes) values
  ('50000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000005', 10, 'Preparo inicial de caipirinhas para o dia')
on conflict (id) do nothing;

insert into public.production_ingredients (production_id, ingredient_product_id, quantity, unit) values
  ('50000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000006', 500, 'ml'),   -- Cachaça
  ('50000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000007', 10, 'unidade'), -- Limão
  ('50000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000008', 0.2, 'kg')    -- Açúcar
on conflict do nothing;

commit;
