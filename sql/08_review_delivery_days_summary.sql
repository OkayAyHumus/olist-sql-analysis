--レビュー点数別に、購入・支払い承認・配送業者への引渡しから配達までの平均所要日数を確認する
--各平均の算出対象件数を併記する
--所要日数は24時間単位で計算する
--この段階では、ステータスによる絞り込みや日時逆転の除外は行わない

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
        r.review_score,
        COUNT(*) AS order_count,
        AVG(TIMESTAMP_DIFF(o.order_delivered_customer_date,order_purchase_timestamp,DAY
                )) AS diray_deliverd_from_purchase_avg,
       COUNT(TIMESTAMP_DIFF(o.order_delivered_customer_date,order_purchase_timestamp,DAY
                )) AS diray_deliverd_from_purchase_cnt,
        AVG(TIMESTAMP_DIFF(o.order_delivered_customer_date,o.order_approved_at,DAY
                )) AS diray_deliverd_from_approved_avg,
        COUNT(TIMESTAMP_DIFF(o.order_delivered_customer_date,o.order_approved_at,DAY
                )) AS diray_deliverd_from_approved_cnt,
        AVG(TIMESTAMP_DIFF(order_delivered_customer_date,o.order_delivered_carrier_date,DAY
                )) AS diray_deliverd_from_carrier_avg,
        COUNT(TIMESTAMP_DIFF(order_delivered_customer_date,o.order_delivered_carrier_date,DAY
                )) AS diray_deliverd_from_carrier_cnt
FROM `bq-sql-505714.olist_raw.orders` o
LEFT JOIN review_summary r
ON    o.order_id  = r.order_id AND r.review_num = 1
GROUP BY r.review_score;

