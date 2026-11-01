--注文ごとに最新レビュー1件を採用し、ordersにLEFT JOINする
--回答日時降順、作成日時降順、review_id昇順で採用するレビューを決める
--レビューのない注文も保持し、結合後行数・注文IDユニーク件数・レビュー一致件数を確認する

--SELECT 
--    order_id, 
--    review_id, 
--    review_creation_date, 
--    review_answer_timestamp,
--    ROW_NUMBER() OVER(
--      PARTITION BY order_id 
--      ORDER BY 
--          review_answer_timestamp DESC,
--          review_creation_date DESC,
--          review_id ASC
--      ) AS review_num,
--    COUNT(*) OVER(
--      PARTITION BY order_id
--      ) AS review_cnt
--FROM `bq-sql-505714.olist_raw.order_reviews`
--QUALIFY review_num = 1;


WITH review_summary as(
SELECT 
    order_id,
    review_id,
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
  COUNT(*) AS join_rows,
  COUNT(DISTINCT o.order_id) AS uni_order_id,
  COUNT(r.order_id) AS matched_rows
FROM `bq-sql-505714.olist_raw.orders` o
LEFT JOIN review_summary r
  ON o.order_id = r.order_id AND r.review_num = 1;
--結合後99,441件。注文IDの重複なし。
--うちレビューあり98,673件、レビューなし768件。
