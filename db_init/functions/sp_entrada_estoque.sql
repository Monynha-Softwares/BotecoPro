CREATE OR REPLACE FUNCTION sp_entrada_estoque(
    p_id_produto INT,
    p_quantidade NUMERIC,
    p_data TIMESTAMP,
    p_observacao TEXT
) RETURNS TABLE(id_entrada INT) AS $$
INSERT INTO entrada_estoque(
    id_produto, quantidade_entrada, data_entrada, observacao, user_id
) VALUES (
    p_id_produto, p_quantidade, p_data, p_observacao, auth.uid()
) RETURNING id_entrada;
$$ LANGUAGE SQL;
