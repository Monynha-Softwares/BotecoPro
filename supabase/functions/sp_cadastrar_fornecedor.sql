CREATE OR REPLACE FUNCTION sp_cadastrar_fornecedor(
    p_nome TEXT,
    p_telefone TEXT,
    p_email TEXT,
    p_contato TEXT,
    p_detalhes TEXT
) RETURNS TABLE(id_fornecedor INT) AS $$
INSERT INTO fornecedores(nome, telefone, email, contato, detalhes, user_id)
VALUES (p_nome, p_telefone, p_email, p_contato, p_detalhes, auth.uid())
RETURNING id_fornecedor;
$$ LANGUAGE SQL;
