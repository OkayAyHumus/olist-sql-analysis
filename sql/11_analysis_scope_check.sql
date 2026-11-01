--分析対象の件数・購入期間・購入日時の欠損を確認する

SELECT
    COUNT(*) AS order_count,
    COUNT(DISTINCT order_id) AS unique_order_count,
    MIN(order_purchase_timestamp) AS first_purchase_at,
    MAX(order_purchase_timestamp) AS last_purchase_at,
    COUNT(*) - COUNT(order_purchase_timestamp)
        AS missing_purchase_timestamp
FROM `bq-sql-505714.olist_raw.v_order_delivery_review`;