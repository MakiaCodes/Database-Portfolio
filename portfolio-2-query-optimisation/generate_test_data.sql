-- Farmccity Portfolio 2 test data.
-- Run once after Portfolio 1 schema.sql and sample_data.sql.
-- This script adds records and does not delete or replace existing data.

BEGIN;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM buyers
        WHERE email LIKE 'perf-buyer-%@example.com'
    ) THEN
        RAISE EXCEPTION 'Portfolio 2 test data already exists. Do not run this script again.';
    END IF;
END;
$$;

CREATE TEMPORARY TABLE p2_id_base ON COMMIT DROP AS
SELECT
    COALESCE((SELECT MAX(buyer_id) FROM buyers), 0) AS buyer_id,
    COALESCE((SELECT MAX(listing_id) FROM listings), 0) AS listing_id,
    COALESCE((SELECT MAX(order_id) FROM orders), 0) AS order_id,
    COALESCE((SELECT MAX(order_item_id) FROM order_items), 0) AS order_item_id,
    COALESCE((SELECT MAX(payment_id) FROM payments), 0) AS payment_id,
    COALESCE((SELECT MAX(payout_id) FROM farmer_payouts), 0) AS payout_id,
    COALESCE((SELECT MAX(delivery_id) FROM deliveries), 0) AS delivery_id;

INSERT INTO buyers (buyer_id, full_name, email, phone)
SELECT
    base.buyer_id + series.n,
    'Performance Buyer ' || LPAD(series.n::TEXT, 4, '0'),
    'perf-buyer-' || LPAD(series.n::TEXT, 4, '0') || '@example.com',
    NULL
FROM p2_id_base AS base
CROSS JOIN GENERATE_SERIES(1, 100) AS series(n);

INSERT INTO listings (
    listing_id,
    farmer_id,
    product_id,
    available_quantity,
    unit,
    unit_price,
    listing_status
)
SELECT
    base.listing_id + series.n,
    series.n,
    series.n,
    -- These are the remaining quantities after the generated orders.
    CASE series.n
        WHEN 1 THEN 7000.000
        ELSE 8500.000
    END,
    CASE series.n
        WHEN 1 THEN 'kg'
        ELSE 'crate'
    END,
    CASE series.n
        WHEN 1 THEN 1800.00
        ELSE 2500.00
    END,
    'active'
FROM p2_id_base AS base
CROSS JOIN GENERATE_SERIES(1, 2) AS series(n);

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
SELECT
    base.order_id + series.n,
    base.buyer_id + (((series.n - 1) % 100) + 1),
    CURRENT_TIMESTAMP - (series.n * INTERVAL '1 minute'),
    'paid',
    'NGN',
    'Performance address ' || LPAD(series.n::TEXT, 4, '0'),
    'Abeokuta',
    'Ogun',
    'NG',
    LPAD(((series.n - 1) % 999999 + 1)::TEXT, 6, '0')
FROM p2_id_base AS base
CROSS JOIN GENERATE_SERIES(1, 1000) AS series(n);

INSERT INTO order_items (
    order_item_id,
    order_id,
    listing_id,
    quantity,
    unit_snapshot,
    unit_price_snapshot
)
SELECT
    base.order_item_id + ((series.n - 1) * 2) + line.item_number,
    base.order_id + series.n,
    base.listing_id + line.item_number,
    line.quantity,
    line.unit_snapshot,
    line.unit_price_snapshot
FROM p2_id_base AS base
CROSS JOIN GENERATE_SERIES(1, 1000) AS series(n)
CROSS JOIN LATERAL (
    VALUES
        (1, (1 + MOD(series.n, 5))::NUMERIC(12, 3), 'kg'::VARCHAR(20), 1800.00::NUMERIC(12, 2)),
        (2, (1 + MOD(series.n, 2))::NUMERIC(12, 3), 'crate'::VARCHAR(20), 2500.00::NUMERIC(12, 2))
) AS line(item_number, quantity, unit_snapshot, unit_price_snapshot);

INSERT INTO payments (payment_id, order_id, amount, payment_status, paid_at)
SELECT
    base.payment_id + series.n,
    base.order_id + series.n,
    (
        (1 + MOD(series.n, 5)) * 1800.00
        + (1 + MOD(series.n, 2)) * 2500.00
    ),
    'paid',
    CURRENT_TIMESTAMP - (series.n * INTERVAL '1 minute')
FROM p2_id_base AS base
CROSS JOIN GENERATE_SERIES(1, 1000) AS series(n);

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
SELECT
    base.payout_id + ((series.n - 1) * 2) + seller.farmer_id,
    base.order_id + series.n,
    seller.farmer_id,
    seller.gross_amount,
    0.0100,
    ROUND(seller.gross_amount * 0.0100, 2),
    seller.gross_amount - ROUND(seller.gross_amount * 0.0100, 2),
    'paid',
    CURRENT_TIMESTAMP - (series.n * INTERVAL '1 minute')
FROM p2_id_base AS base
CROSS JOIN GENERATE_SERIES(1, 1000) AS series(n)
CROSS JOIN LATERAL (
    VALUES
        (1, ((1 + MOD(series.n, 5)) * 1800.00)::NUMERIC(12, 2)),
        (2, ((1 + MOD(series.n, 2)) * 2500.00)::NUMERIC(12, 2))
) AS seller(farmer_id, gross_amount);

INSERT INTO deliveries (delivery_id, order_id, farmer_id, delivery_status)
SELECT
    base.delivery_id + ((series.n - 1) * 2) + seller.farmer_id,
    base.order_id + series.n,
    seller.farmer_id,
    'pending'
FROM p2_id_base AS base
CROSS JOIN GENERATE_SERIES(1, 1000) AS series(n)
CROSS JOIN GENERATE_SERIES(1, 2) AS seller(farmer_id);

SELECT setval(pg_get_serial_sequence('buyers', 'buyer_id'), (SELECT MAX(buyer_id) FROM buyers), true);
SELECT setval(pg_get_serial_sequence('listings', 'listing_id'), (SELECT MAX(listing_id) FROM listings), true);
SELECT setval(pg_get_serial_sequence('orders', 'order_id'), (SELECT MAX(order_id) FROM orders), true);
SELECT setval(pg_get_serial_sequence('order_items', 'order_item_id'), (SELECT MAX(order_item_id) FROM order_items), true);
SELECT setval(pg_get_serial_sequence('payments', 'payment_id'), (SELECT MAX(payment_id) FROM payments), true);
SELECT setval(pg_get_serial_sequence('farmer_payouts', 'payout_id'), (SELECT MAX(payout_id) FROM farmer_payouts), true);
SELECT setval(pg_get_serial_sequence('deliveries', 'delivery_id'), (SELECT MAX(delivery_id) FROM deliveries), true);

COMMIT;

SELECT
    (SELECT COUNT(*) FROM buyers WHERE email LIKE 'perf-buyer-%@example.com') AS generated_buyers,
    (
        SELECT COUNT(*)
        FROM orders AS o
        JOIN buyers AS b ON b.buyer_id = o.buyer_id
        WHERE b.email LIKE 'perf-buyer-%@example.com'
    ) AS generated_orders,
    (
        SELECT COUNT(*)
        FROM order_items AS oi
        JOIN orders AS o ON o.order_id = oi.order_id
        JOIN buyers AS b ON b.buyer_id = o.buyer_id
        WHERE b.email LIKE 'perf-buyer-%@example.com'
    ) AS generated_order_items,
    (
        SELECT COUNT(*)
        FROM payments AS p
        JOIN orders AS o ON o.order_id = p.order_id
        JOIN buyers AS b ON b.buyer_id = o.buyer_id
        WHERE b.email LIKE 'perf-buyer-%@example.com'
    ) AS generated_payments,
    (
        SELECT COUNT(*)
        FROM farmer_payouts AS fp
        JOIN orders AS o ON o.order_id = fp.order_id
        JOIN buyers AS b ON b.buyer_id = o.buyer_id
        WHERE b.email LIKE 'perf-buyer-%@example.com'
    ) AS generated_payouts;
