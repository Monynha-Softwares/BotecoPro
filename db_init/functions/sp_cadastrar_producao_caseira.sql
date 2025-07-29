CREATE OR REPLACE FUNCTION sp_cadastrar_producao_caseira(
    p_nome TEXT,
    p_quantidade NUMERIC,
    p_unidade TEXT,
    p_tempo_preparo INT,
    p_data_inicio TIMESTAMP,
    p_data_fim TIMESTAMP
) RETURNS TABLE(id_producao INT) AS $$
INSERT INTO producao_caseira(
    nome, quantidade_gerada, unidade_gerada, tempo_preparo,
    data_inicio_producao, data_fim_disponivel, user_id
) VALUES (
    p_nome, p_quantidade, p_unidade, p_tempo_preparo,
    p_data_inicio, p_data_fim, auth.uid()
) RETURNING id_producao;
$$ LANGUAGE SQL;
