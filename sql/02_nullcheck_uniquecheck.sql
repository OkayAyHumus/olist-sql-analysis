--指定テーブルの総行数と、各列のNULL・非NULL・ユニーク件数を確認
--対象テーブルはtarget_tableで指定
--空文字や複合キーの重複は、このSQLでは判定しない

DECLARE target_table STRING DEFAULT 'seilers';
DECLARE check_sql STRING;

SET check_sql = (
  SELECT
    'SELECT COUNT(*) AS total_rows, '
    || STRING_AGG(
      FORMAT(
          'COUNT(*) - COUNT(`%s`) AS `%s_nulls`, '
          || 'COUNT(`%s`) AS `%s_non_nulls`, '
          || 'COUNT(DISTINCT `%s`) AS `%s_unique`',
          column_name, column_name,
          column_name, column_name,
          column_name, column_name
      ),
      ', ' ORDER BY ordinal_position
    )
    || FORMAT(
      ' FROM `bq-sql-505714.olist_raw.%s`',
      target_table
    )
  FROM `bq-sql-505714.olist_raw.INFORMATION_SCHEMA.COLUMNS`
  WHERE table_name = target_table
);

EXECUTE IMMEDIATE check_sql;

