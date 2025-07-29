CREATE OR REPLACE FUNCTION sp_adicionar_ingrediente_producao(
    p_id_producao INT,
    p_id_produto INT,
    p_quantidade NUMERIC,
    p_user_id UUID
) RETURNS TABLE(id INT) AS $$
INSERT INTO producao_ingredientes(
    id_producao, id_produto, quantidade_utilizada, user_id
) VALUES (
    p_id_producao, p_id_produto, p_quantidade, p_user_id
) RETURNING id;
$$ LANGUAGE SQL;
