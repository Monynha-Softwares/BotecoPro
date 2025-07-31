-- Row Level Security policies for BotecoPro tables

-- Enable RLS and restrict access by user_id for all tables
ALTER TABLE fornecedores ENABLE ROW LEVEL SECURITY;
CREATE POLICY p_fornecedores ON fornecedores USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;
CREATE POLICY p_categorias ON categorias USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
CREATE POLICY p_produtos ON produtos USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

ALTER TABLE produtos_venda ENABLE ROW LEVEL SECURITY;
CREATE POLICY p_produtos_venda ON produtos_venda USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

ALTER TABLE receitas ENABLE ROW LEVEL SECURITY;
CREATE POLICY p_receitas ON receitas USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

ALTER TABLE receita_ingredientes ENABLE ROW LEVEL SECURITY;
CREATE POLICY p_receita_ingredientes ON receita_ingredientes USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

ALTER TABLE producao_caseira ENABLE ROW LEVEL SECURITY;
CREATE POLICY p_producao_caseira ON producao_caseira USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

ALTER TABLE producao_ingredientes ENABLE ROW LEVEL SECURITY;
CREATE POLICY p_producao_ingredientes ON producao_ingredientes USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

ALTER TABLE estoque ENABLE ROW LEVEL SECURITY;
CREATE POLICY p_estoque ON estoque USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

ALTER TABLE entrada_estoque ENABLE ROW LEVEL SECURITY;
CREATE POLICY p_entrada_estoque ON entrada_estoque USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

ALTER TABLE ajuste_estoque ENABLE ROW LEVEL SECURITY;
CREATE POLICY p_ajuste_estoque ON ajuste_estoque USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

ALTER TABLE consumo_interno ENABLE ROW LEVEL SECURITY;
CREATE POLICY p_consumo_interno ON consumo_interno USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

ALTER TABLE mesas ENABLE ROW LEVEL SECURITY;
CREATE POLICY p_mesas ON mesas USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

ALTER TABLE vendas ENABLE ROW LEVEL SECURITY;
CREATE POLICY p_vendas ON vendas USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

ALTER TABLE pedidos ENABLE ROW LEVEL SECURITY;
CREATE POLICY p_pedidos ON pedidos USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

ALTER TABLE pedido_itens ENABLE ROW LEVEL SECURITY;
CREATE POLICY p_pedido_itens ON pedido_itens USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
