-- Farmccity sample records for Portfolio 1.
-- Run once after schema.sql in a new, empty farmccity_db database.

BEGIN;

INSERT INTO buyers (buyer_id, full_name, email, phone)
VALUES (1, 'Ada Okafor', 'ada.okafor@example.com', '+2348000000101');

INSERT INTO farmers (farmer_id, farm_name, contact_name, email, phone)
VALUES
    (1, 'Green Valley Farms', 'Hawa Bello', 'hawa@greenvalley.example', '+2348000000201'),
    (2, 'Sunrise Produce Farm', 'Ikenna Obi', 'ikenna@sunrise.example', '+2348000000202');

INSERT INTO categories (category_id, category_name)
VALUES
    (1, 'Vegetables'),
    (2, 'Tubers');

INSERT INTO products (product_id, category_id, product_name, description)
VALUES
    (1, 1, 'Tomatoes', 'Fresh tomatoes sold by the kilogram.'),
    (2, 2, 'Yam', 'Fresh yam sold by the crate.');

INSERT INTO listings (
    listing_id,
    farmer_id,
    product_id,
    available_quantity,
    unit,
    unit_price,
    listing_status
)
VALUES
    (1, 1, 1, 95, 'kg', 1800.00, 'active'),
    (2, 2, 2, 48, 'crate', 2500.00, 'active');

INSERT INTO orders (
    order_id,
    buyer_id,
    order_date,
    order_status,
    currency_code,
    delivery_address_line,
    delivery_city,
    delivery_region,
    delivery_country_code,
    delivery_postal_code
)
VALUES (
    1,
    1,
    CURRENT_TIMESTAMP,
    'paid',
    'NGN',
    '14 Market Road',
    'Abeokuta',
    'Ogun',
    'NG',
    NULL
);

INSERT INTO order_items (
    order_item_id,
    order_id,
    listing_id,
    quantity,
    unit_snapshot,
    unit_price_snapshot
)
VALUES
    (1, 1, 1, 5, 'kg', 1800.00),
    (2, 1, 2, 2, 'crate', 2500.00);

INSERT INTO payments (payment_id, order_id, amount, payment_status, paid_at)
VALUES (1, 1, 14000.00, 'paid', CURRENT_TIMESTAMP);

INSERT INTO farmer_payouts (
    payout_id,
    order_id,
    farmer_id,
    gross_amount,
    commission_rate,
    commission_amount,
    net_amount,
    payout_status,
    paid_at
)
VALUES
    (1, 1, 1, 9000.00, 0.0100, 90.00, 8910.00, 'paid', CURRENT_TIMESTAMP),
    (2, 1, 2, 5000.00, 0.0100, 50.00, 4950.00, 'paid', CURRENT_TIMESTAMP);

INSERT INTO deliveries (delivery_id, order_id, farmer_id, delivery_status)
VALUES
    (1, 1, 1, 'pending'),
    (2, 1, 2, 'pending');

SELECT setval(pg_get_serial_sequence('buyers', 'buyer_id'), (SELECT MAX(buyer_id) FROM buyers), true);
SELECT setval(pg_get_serial_sequence('farmers', 'farmer_id'), (SELECT MAX(farmer_id) FROM farmers), true);
SELECT setval(pg_get_serial_sequence('categories', 'category_id'), (SELECT MAX(category_id) FROM categories), true);
SELECT setval(pg_get_serial_sequence('products', 'product_id'), (SELECT MAX(product_id) FROM products), true);
SELECT setval(pg_get_serial_sequence('listings', 'listing_id'), (SELECT MAX(listing_id) FROM listings), true);
SELECT setval(pg_get_serial_sequence('orders', 'order_id'), (SELECT MAX(order_id) FROM orders), true);
SELECT setval(pg_get_serial_sequence('order_items', 'order_item_id'), (SELECT MAX(order_item_id) FROM order_items), true);
SELECT setval(pg_get_serial_sequence('payments', 'payment_id'), (SELECT MAX(payment_id) FROM payments), true);
SELECT setval(pg_get_serial_sequence('farmer_payouts', 'payout_id'), (SELECT MAX(payout_id) FROM farmer_payouts), true);
SELECT setval(pg_get_serial_sequence('deliveries', 'delivery_id'), (SELECT MAX(delivery_id) FROM deliveries), true);

COMMIT;

SELECT
    o.order_id,
    p.amount AS buyer_payment_ngn,
    f.farm_name,
    fp.gross_amount,
    fp.commission_amount,
    fp.net_amount,
    fp.payout_status
FROM orders AS o
JOIN payments AS p ON p.order_id = o.order_id
JOIN farmer_payouts AS fp ON fp.order_id = o.order_id
JOIN farmers AS f ON f.farmer_id = fp.farmer_id
ORDER BY f.farm_name;
