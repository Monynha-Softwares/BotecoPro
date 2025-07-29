CREATE OR REPLACE FUNCTION sp_cadastrar_receita(
    p_nome TEXT,
    p_tipo_receita TEXT,
    p_preco_venda NUMERIC,
    p_tempo_preparo INT,
    p_id_categoria INT
) RETURNS TABLE(id_receita INT) AS $$
INSERT INTO receitas(
    nome, tipo_receita, preco_venda, tempo_preparo_minutos, id_categoria, user_id
) VALUES (
    p_nome, p_tipo_receita, p_preco_venda, p_tempo_preparo, p_id_categoria, auth.uid()
) RETURNING id_receita;
$$ LANGUAGE SQL;
