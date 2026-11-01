CREATE OR REPLACE VIEW
    `bq-sql-505714.olist_raw.v_order_delivery_review` AS

    WITH review_no1 AS(
SELECT
        order_id,
        review_id,
        review_score,
        ROW_NUMBER() OVER(
                PARTITION BY order_id 
                ORDER BY review_answer_timestamp DESC,
                         review_creation_date DESC,
                         review_id ASC
                )AS review_num 
FROM `bq-sql-505714.olist_raw.order_reviews`
),

delay_date_tb AS(
SELECT 
        o.order_id,
        o.customer_id,
        DATE_DIFF(DATE(o.order_delivered_customer_date),DATE(o.order_estimated_delivery_date),DAY) AS delay_date,
        r.review_score,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        o.order_purchase_timestamp
FROM `bq-sql-505714.olist_raw.orders` o
LEFT JOIN review_no1 r
        ON o.order_id = r.order_id AND review_num = 1
WHERE  o.order_estimated_delivery_date IS NOT NULL 
        AND o.order_delivered_customer_date IS NOT NULL 
        --AND r.review_score IS NOT NULL
        AND NOT(
                COALESCE(o.order_delivered_customer_date < order_purchase_timestamp , FALSE)
                OR COALESCE(o.order_delivered_customer_date < order_approved_at , FALSE)
                OR COALESCE(o.order_delivered_customer_date < order_delivered_carrier_date , FALSE)
        )
        AND order_status ="delivered"
)

SELECT      
        order_id,
        customer_id,
        order_purchase_timestamp,
        order_delivered_customer_date,
        order_estimated_delivery_date,
        review_score,
        delay_date,
        CASE
                WHEN  delay_date < 0 THEN "1,Arrive early"
                WHEN  delay_date = 0 THEN "2,On the day"
                WHEN  delay_date >= 1 AND delay_date <= 2 THEN "3,Little delay"
                WHEN  delay_date >= 3 AND delay_date <= 5 THEN "4,Middle delay"
                ELSE  "5,Major delay"
        END AS rank_delay
FROM delay_date_tb;