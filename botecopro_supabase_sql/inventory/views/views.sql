CREATE VIEW inventory.ingredients_below_min AS
SELECT
    i.ingredient_id,
    i.name,
    i.stock_quantity,
    i.stock_minimum,
    (i.stock_minimum - i.stock_quantity) AS shortage,
    s.name AS supplier_name
FROM inventory.ingredient i
LEFT JOIN inventory.supplier s ON i.supplier_id = s.supplier_id
WHERE i.stock_quantity < i.stock_minimum;
