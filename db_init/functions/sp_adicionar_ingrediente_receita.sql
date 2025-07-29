CREATE OR REPLACE FUNCTION sp_adicionar_ingrediente_receita(
    p_id_receita INT,
    p_id_produto INT,
    p_quantidade NUMERIC,
    p_user_id UUID
) RETURNS TABLE(id INT) AS $$
INSERT INTO receita_ingredientes(
    id_receita, id_produto, quantidade_utilizada, user_id
) VALUES (
    p_id_receita, p_id_produto, p_quantidade, p_user_id
) RETURNING id;
$$ LANGUAGE SQL;
