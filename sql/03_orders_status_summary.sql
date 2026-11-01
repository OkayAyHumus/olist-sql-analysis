WITH all_cnt AS (
  SELECT
    COUNT(*) AS alls
  FROM `bq-sql-505714.olist_raw.orders`
)

SELECT
  a.order_status,
  COUNT(*) AS order_count,
  ROUND(
    COUNT(*) / NULLIF(b.alls, 0) * 100,
    2
  ) AS order_share_pct
FROM `bq-sql-505714.olist_raw.orders` AS a
CROSS JOIN all_cnt AS b
GROUP BY
  a.order_status,
  b.alls
ORDER BY
  order_count DESC;