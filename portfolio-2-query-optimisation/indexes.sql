-- Replace the initial index with a covering index for the buyer history query.

DROP INDEX IF EXISTS idx_orders_buyer_order_date;
CREATE INDEX idx_orders_buyer_order_date
    ON orders (buyer_id, order_date DESC)
    INCLUDE (order_id, order_status);

VACUUM (ANALYZE) orders;
