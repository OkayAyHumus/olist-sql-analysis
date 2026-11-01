--作業：データ型の確認・ローデータの確認

SELECT
  column_name,
  data_type,
  is_nullable
FROM  `bq-sql-505714.olist_raw.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'seilers'
ORDER BY ordinal_position;


SELECT *
FROM `bq-sql-505714.olist_raw.seilers`
LIMIT 100;