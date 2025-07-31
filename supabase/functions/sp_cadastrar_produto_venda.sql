CREATE OR REPLACE FUNCTION sp_cadastrar_produto_venda(
    p_id_produto INT,
    p_descricao_venda TEXT,
    p_quantidade_base NUMERIC,
    p_preco_venda NUMERIC
) RETURNS TABLE(id_venda INT) AS $$
INSERT INTO produtos_venda(
    id_produto, descricao_venda, quantidade_base, preco_venda, user_id
) VALUES (
    p_id_produto, p_descricao_venda, p_quantidade_base, p_preco_venda, auth.uid()
) RETURNING id_venda;
$$ LANGUAGE SQL;
