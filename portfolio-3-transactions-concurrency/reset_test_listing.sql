-- Run only after both concurrency-test sessions have ended.

UPDATE listings AS l
SET available_quantity = 1.000,
    listing_status = 'active'
FROM farmers AS f, products AS p, categories AS c
WHERE l.farmer_id = f.farmer_id
  AND l.product_id = p.product_id
  AND p.category_id = c.category_id
  AND f.email = 'p3-test-farmer@example.com'
  AND p.product_name = 'Portfolio 3 Test Produce'
  AND c.category_name = 'Portfolio 3 Test Category'
RETURNING l.listing_id, l.available_quantity, l.unit;
