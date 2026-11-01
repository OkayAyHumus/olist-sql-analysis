--ER図作成前確認：複数のレヴューがある注文について、レヴューの中身を確認

SELECT * 
FROM `bq-sql-505714.olist_raw.order_reviews`
QUALIFY COUNT(*) OVER (PARTITION BY order_id) > 1
ORDER BY
  order_id,
  review_answer_timestamp;