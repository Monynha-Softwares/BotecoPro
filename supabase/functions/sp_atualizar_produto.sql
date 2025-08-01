CREATE OR REPLACE FUNCTION sp_atualizar_produto(
    p_id_produto INT,
    p_nome TEXT,
    p_unidade_base TEXT,
    p_tipo_produto TEXT,
    p_controla_estoque BOOLEAN,
    p_id_categoria INT,
    p_descricao_venda TEXT,
    p_quantidade_base NUMERIC,
    p_preco_venda NUMERIC
) RETURNS VOID AS $$
BEGIN
    UPDATE produtos
    SET nome = p_nome,
        unidade_base = p_unidade_base,
        tipo_produto = p_tipo_produto,
        controla_estoque = p_controla_estoque,
        id_categoria = p_id_categoria
    WHERE id_produto = p_id_produto AND user_id = auth.uid();

    UPDATE produtos_venda
    SET descricao_venda = p_descricao_venda,
        quantidade_base = p_quantidade_base,
        preco_venda = p_preco_venda
    WHERE id_produto = p_id_produto AND user_id = auth.uid();
END;
$$ LANGUAGE plpgsql;
