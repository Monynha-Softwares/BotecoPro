CREATE OR REPLACE FUNCTION sp_adicionar_item_pedido(
    p_id_pedido INT,
    p_tipo_item TEXT,
    p_id_item INT,
    p_quantidade NUMERIC,
    p_preco NUMERIC,
    p_observacao TEXT,
    p_user_id UUID
) RETURNS TABLE(id_pedido_item INT) AS $$
INSERT INTO pedido_itens(
    id_pedido, tipo_item, id_item, quantidade, preco_unitario, observacao, user_id
) VALUES (
    p_id_pedido, p_tipo_item, p_id_item, p_quantidade, p_preco, p_observacao, p_user_id
) RETURNING id_pedido_item;
$$ LANGUAGE SQL;
