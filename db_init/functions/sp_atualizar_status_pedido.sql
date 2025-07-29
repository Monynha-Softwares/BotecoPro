CREATE OR REPLACE FUNCTION sp_atualizar_status_pedido(
    p_id_pedido INT,
    p_status TEXT,
    p_user_id UUID
) RETURNS VOID AS $$
UPDATE pedidos
SET status_pedido = p_status
WHERE id_pedido = p_id_pedido AND user_id = p_user_id;
$$ LANGUAGE SQL;
