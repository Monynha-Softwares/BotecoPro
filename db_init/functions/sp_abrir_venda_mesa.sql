CREATE OR REPLACE FUNCTION sp_abrir_venda_mesa(
    p_id_mesa INT,
    p_data TIMESTAMP
) RETURNS TABLE(id_venda INT) AS $$
INSERT INTO vendas(id_mesa, data_venda, status_aberta, cancelada, user_id)
VALUES (p_id_mesa, p_data, TRUE, FALSE, auth.uid())
RETURNING id_venda;
$$ LANGUAGE SQL;
