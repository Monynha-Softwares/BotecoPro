CREATE OR REPLACE FUNCTION sp_criar_pedido(
    p_id_venda INT,
    p_id_mesa INT,
    p_nome_funcionario TEXT,
    p_data TIMESTAMP,
    p_status TEXT
) RETURNS TABLE(id_pedido INT) AS $$
INSERT INTO pedidos(
    id_venda, id_mesa, nome_funcionario, data_pedido, status_pedido, user_id
) VALUES (
    p_id_venda, p_id_mesa, p_nome_funcionario, p_data, p_status, auth.uid()
) RETURNING id_pedido;
$$ LANGUAGE SQL;
