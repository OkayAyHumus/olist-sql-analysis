--olist_raw内のテーブル・ビューの名前と種類を確認する

SELECT
  table_name,
  table_type
FROM `bq-sql-505714.olist_raw.INFORMATION_SCHEMA.TABLES`
ORDER BY table_name;


