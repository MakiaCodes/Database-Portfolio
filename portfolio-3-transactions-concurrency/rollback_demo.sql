BEGIN ISOLATION LEVEL READ COMMITTED;

UPDATE listings AS l
SET available_quantity = l.available_quantity - 1
FROM farmers AS f, products AS p, categories AS c
WHERE l.farmer_id = f.farmer_id
  AND l.product_id = p.product_id
  AND p.category_id = c.category_id
  AND f.email = 'p3-test-farmer@example.com'
  AND p.product_name = 'Portfolio 3 Test Produce'
  AND c.category_name = 'Portfolio 3 Test Category'
  AND l.available_quantity >= 1
RETURNING l.available_quantity AS quantity_inside_transaction;

ROLLBACK;

SELECT l.available_quantity AS quantity_after_rollback
FROM listings AS l
JOIN farmers AS f ON f.farmer_id = l.farmer_id
JOIN products AS p ON p.product_id = l.product_id
WHERE f.email = 'p3-test-farmer@example.com'
  AND p.product_name = 'Portfolio 3 Test Produce';
