-- Farmccity Portfolio 3 test listing.
-- Safe to run again. It creates the dedicated listing only if it does not exist.

BEGIN;

INSERT INTO farmers (farm_name, contact_name, email)
VALUES (
    'Portfolio 3 Test Farm',
    'Portfolio 3 Test Contact',
    'p3-test-farmer@example.com'
)
ON CONFLICT (email) DO NOTHING;

INSERT INTO categories (category_name)
VALUES ('Portfolio 3 Test Category')
ON CONFLICT (category_name) DO NOTHING;

INSERT INTO products (category_id, product_name, description)
SELECT category_id, 'Portfolio 3 Test Produce', 'Dedicated produce listing for transaction tests.'
FROM categories
WHERE category_name = 'Portfolio 3 Test Category'
ON CONFLICT (category_id, product_name) DO NOTHING;

INSERT INTO listings (
    farmer_id,
    product_id,
    available_quantity,
    unit,
    unit_price,
    listing_status
)
SELECT f.farmer_id, p.product_id, 1.000, 'kg', 1.00, 'active'
FROM farmers AS f
CROSS JOIN products AS p
JOIN categories AS c ON c.category_id = p.category_id
WHERE f.email = 'p3-test-farmer@example.com'
  AND c.category_name = 'Portfolio 3 Test Category'
  AND p.product_name = 'Portfolio 3 Test Produce'
  AND NOT EXISTS (
      SELECT 1
      FROM listings AS l
      WHERE l.farmer_id = f.farmer_id
        AND l.product_id = p.product_id
  );

COMMIT;

SELECT
    l.listing_id,
    f.farm_name,
    p.product_name,
    l.available_quantity,
    l.unit
FROM listings AS l
JOIN farmers AS f ON f.farmer_id = l.farmer_id
JOIN products AS p ON p.product_id = l.product_id
WHERE f.email = 'p3-test-farmer@example.com'
  AND p.product_name = 'Portfolio 3 Test Produce';
