-- Sample seed data ---------------------------------------------------------
INSERT INTO auth.users(id,email) VALUES
    ('00000000-0000-0000-0000-000000000001','demo@boteco.local')
    ON CONFLICT DO NOTHING;

-- Insert sample categories
INSERT INTO categorias (nome, descricao, user_id) VALUES
    ('Bebidas', 'Bebidas em geral', '00000000-0000-0000-0000-000000000001'),
    ('Comidas', 'Alimentos em geral', '00000000-0000-0000-0000-000000000001'),
    ('Outros', 'Produtos diversos', '00000000-0000-0000-0000-000000000001')
    ON CONFLICT DO NOTHING;

-- Insert sample tables
DO $$
BEGIN
    FOR i IN 1..10 LOOP
        INSERT INTO mesas(numero_mesa, quantidade_lugares, status_ocupada, user_id)
        VALUES(i, (i % 3) + 2, FALSE, '00000000-0000-0000-0000-000000000001')
        ON CONFLICT DO NOTHING;
    END LOOP;
END$$;
