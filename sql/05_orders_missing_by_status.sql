--注文ステータス別に、注文件数と分析用列のNULL件数を確認する
--注文ごとに最新レビュー1件を採用し、レビューのない注文も保持する
--確認対象は配達日時・配達予定日時・レビュー点数

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
  o.order_status,
  COUNT(*) AS order_count,
  SUM(CASE
        WHEN o.order_delivered_customer_date IS NULL THEN 1
        ELSE 0
      END) AS missing_delivered_date,
  SUM(CASE 
        WHEN o.order_estimated_delivery_date IS NULL THEN 1
        ELSE 0  
      END) AS missing_estimated_date,   
  SUM(CASE
        WHEN r.review_score IS NULL THEN 1
        ELSE 0
      END) AS missing_review_score
FROM `bq-sql-505714.olist_raw.orders` o
LEFT JOIN review_summary r
  ON  o.order_id = r.order_id AND r.review_num = 1
GROUP BY o.order_status
ORDER BY order_count DESC;