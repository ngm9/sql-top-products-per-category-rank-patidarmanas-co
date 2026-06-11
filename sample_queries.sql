SELECT
    c.category_id,
    c.category_name,
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity
FROM fact_order_items oi
JOIN dim_products p ON CAST(oi.product_id AS TEXT) = CAST(p.product_id AS TEXT)
JOIN dim_categories c ON c.category_id = p.category_id
WHERE EXTRACT(YEAR FROM oi.order_date) = EXTRACT(YEAR FROM CURRENT_DATE)
  AND (p.is_discontinued = FALSE OR p.is_discontinued IS NULL)
GROUP BY c.category_id, c.category_name, p.product_id, p.product_name
ORDER BY total_quantity DESC;
