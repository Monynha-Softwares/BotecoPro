-- Indexes to improve common queries
CREATE INDEX IF NOT EXISTS idx_produtos_id_categoria ON produtos(id_categoria);
CREATE INDEX IF NOT EXISTS idx_pedidos_id_mesa ON pedidos(id_mesa);
CREATE INDEX IF NOT EXISTS idx_vendas_data_venda ON vendas(data_venda);
