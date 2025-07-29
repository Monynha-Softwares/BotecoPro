CREATE OR REPLACE FUNCTION sp_cancelar_venda(
    p_id_venda INT
) RETURNS VOID AS $$
UPDATE vendas
SET cancelada = TRUE
WHERE id_venda = p_id_venda AND user_id = auth.uid();
$$ LANGUAGE SQL;
