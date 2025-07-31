CREATE OR REPLACE FUNCTION sp_fechar_venda(
    p_id_venda INT,
    p_data TIMESTAMP
) RETURNS VOID AS $$
UPDATE vendas
SET status_aberta = FALSE
WHERE id_venda = p_id_venda AND user_id = auth.uid();
$$ LANGUAGE SQL;
