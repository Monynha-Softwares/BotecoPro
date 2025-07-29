CREATE OR REPLACE FUNCTION sp_atualizar_fornecedor(
    p_id_fornecedor INT,
    p_nome TEXT,
    p_telefone TEXT,
    p_email TEXT,
    p_contato TEXT,
    p_detalhes TEXT,
    p_user_id UUID
) RETURNS VOID AS $$
UPDATE fornecedores
SET nome = p_nome,
    telefone = p_telefone,
    email = p_email,
    contato = p_contato,
    detalhes = p_detalhes
WHERE id_fornecedor = p_id_fornecedor AND user_id = p_user_id;
$$ LANGUAGE SQL;
