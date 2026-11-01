--結合作業

SELECT 
  COUNT(*) AS joined_rows,
  COUNT(DISTINCT o.order_id) AS unique_orders,
  COUNT(c.customer_id) AS matched_rows
FROM  `bq-sql-505714.olist_raw.orders` o
LEFT JOIN `bq-sql-505714.olist_raw.customers` c
  using(customer_id);

--全注文あり、行数増加なし


SELECT 
  COUNT(*) AS joined_rows,
  COUNT(DISTINCT o.order_id) AS unique_orders,
  COUNT(r.order_id) AS matched_rows
FROM  `bq-sql-505714.olist_raw.orders` o
LEFT JOIN `bq-sql-505714.olist_raw.order_reviews` r
  using(order_id);
--