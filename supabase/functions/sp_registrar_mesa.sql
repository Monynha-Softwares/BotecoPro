CREATE OR REPLACE FUNCTION sp_registrar_mesa(
    p_numero INT,
    p_quantidade_lugares INT,
    p_status BOOLEAN,
    p_nome_cliente TEXT
) RETURNS TABLE(id_mesa INT) AS $$
INSERT INTO mesas(
    numero_mesa, quantidade_lugares, status_ocupada, nome_cliente, user_id
) VALUES (
    p_numero, p_quantidade_lugares, p_status, p_nome_cliente, auth.uid()
) RETURNING id_mesa;
$$ LANGUAGE SQL;
