CREATE OR REPLACE VIEW vw_produto_detalhes AS
SELECT p.*, c.nome AS categoria_nome
FROM produtos p
LEFT JOIN categorias c ON p.id_categoria = c.id_categoria;
