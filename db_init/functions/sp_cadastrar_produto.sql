CREATE OR REPLACE FUNCTION sp_cadastrar_produto(
    p_nome TEXT,
    p_unidade_base TEXT,
    p_tipo_produto TEXT,
    p_controla_estoque BOOLEAN,
    p_id_categoria INT
) RETURNS TABLE(id_produto INT) AS $$
INSERT INTO produtos(
    nome, unidade_base, tipo_produto, controla_estoque,
    id_categoria, user_id
) VALUES (
    p_nome, p_unidade_base, p_tipo_produto, p_controla_estoque,
    p_id_categoria, auth.uid()
) RETURNING id_produto;
$$ LANGUAGE SQL;
