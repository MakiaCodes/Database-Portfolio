-- Farmccity Portfolio 2 query workload.
-- Run the buyer history plan and query before and after indexes.sql.

ANALYZE orders;

EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, order_date, order_status
FROM orders
WHERE buyer_id = (
    SELECT buyer_id
    FROM buyers
    WHERE email = 'perf-buyer-0050@example.com'
)
ORDER BY order_date DESC
LIMIT 10;

SELECT order_id, order_date, order_status
FROM orders
WHERE buyer_id = (
    SELECT buyer_id
    FROM buyers
    WHERE email = 'perf-buyer-0050@example.com'
)
ORDER BY order_date DESC
LIMIT 10;

SELECT
    c.category_name,
    p.product_name,
    l.unit,
    SUM(oi.quantity) AS quantity_sold,
    SUM(oi.quantity * oi.unit_price_snapshot) AS gross_sales_ngn
FROM order_items AS oi
JOIN listings AS l ON l.listing_id = oi.listing_id
JOIN products AS p ON p.product_id = l.product_id
JOIN categories AS c ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name, p.product_id, p.product_name, l.unit
ORDER BY gross_sales_ngn DESC, p.product_name;
