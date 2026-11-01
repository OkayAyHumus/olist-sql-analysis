--配達日時が購入・承認・配送業者への引渡し日時より前の注文を確認する
--24時間未満の逆転も検出するため、日時を直接比較する



WITH review_summary as(
SELECT 
    order_id,
    review_id,
    review_score,
    review_creation_date,
    review_answer_timestamp,
    COUNT(*) OVER(PARTITION BY order_id) AS review_cnt,
    ROW_NUMBER() OVER(PARTITION BY order_id
      ORDER BY 
               review_answer_timestamp DESC,
               review_creation_date DESC,
               review_id ASC
               ) AS review_num  
FROM `bq-sql-505714.olist_raw.order_reviews`)


SELECT 
        o.order_id, 
        r.review_score,
        o.order_status,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        TIMESTAMP_DIFF(o.order_delivered_customer_date,o.order_purchase_timestamp,DAY
                ) AS delivery_days_from_purchase,
        TIMESTAMP_DIFF(o.order_delivered_customer_date,o.order_approved_at,DAY
                ) AS delivery_days_from_approved,
        TIMESTAMP_DIFF(o.order_delivered_customer_date,o.order_delivered_carrier_date,DAY
                ) AS delivery_days_from_carrier
FROM `bq-sql-505714.olist_raw.orders` o
LEFT JOIN review_summary r
ON    o.order_id  = r.order_id AND r.review_num = 1
WHERE
    o.order_delivered_customer_date < o.order_purchase_timestamp
    OR o.order_delivered_customer_date < o.order_approved_at
    OR o.order_delivered_customer_date < o.order_delivered_carrier_date;
