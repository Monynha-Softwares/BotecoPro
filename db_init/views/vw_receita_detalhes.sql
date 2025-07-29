CREATE OR REPLACE VIEW vw_receita_detalhes AS
SELECT r.*, c.nome AS categoria_nome
FROM receitas r
LEFT JOIN categorias c ON r.id_categoria = c.id_categoria;
