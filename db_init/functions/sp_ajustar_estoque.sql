CREATE OR REPLACE FUNCTION sp_ajustar_estoque(
    p_id_produto INT,
    p_quantidade_anterior NUMERIC,
    p_quantidade_nova NUMERIC,
    p_data TIMESTAMP,
    p_motivo TEXT,
    p_user_id UUID
) RETURNS TABLE(id_ajuste INT) AS $$
INSERT INTO ajuste_estoque(
    id_produto, quantidade_anterior, quantidade_nova, data_ajuste, motivo, user_id
) VALUES (
    p_id_produto, p_quantidade_anterior, p_quantidade_nova, p_data, p_motivo, p_user_id
) RETURNING id_ajuste;
$$ LANGUAGE SQL;
