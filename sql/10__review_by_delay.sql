--分析用ビューを参照し、遅延区分別に注文件数とレビューの状況を集計する
--有効レビューは1〜5点、低評価は1〜2点と定義する
--レビュー点数がNULLの注文も、全注文件数に含める
--有効レビューなし件数＝全注文件数－有効レビュー件数（NULL・1〜5点以外を含む）
--有効レビューなし率＝有効レビューなし件数÷全注文件数×100
--低評価率＝低評価件数÷有効レビュー件数×100
--分母が0の場合はNULLIFにより計算結果をNULLとする
--遅延区分ごとに集計し、前倒し・当日・1〜2日遅延・3〜5日遅延・6日以上遅延の順に表示する

SELECT
  rank_delay,
  COUNT(*) AS all_od,

  SUM(CASE
             WHEN review_score BETWEEN 1 AND 5 THEN 1 ELSE 0
             END) AS review_count,
  
  COUNT(*) - SUM(CASE
             WHEN review_score BETWEEN 1 AND 5 THEN 1 ELSE 0
             END) AS  no_valid_review_count,

  ROUND(
    100.0 * (COUNT(*) - SUM(CASE
             WHEN review_score BETWEEN 1 AND 5 THEN 1 ELSE 0
             END)) / NULLIF(COUNT(*),0),
             2
             ) AS no_valid_review_rate_pct,

  SUM(CASE
            WHEN review_score IN (1, 2) THEN 1 ELSE 0
            END) AS low_review_count,

  ROUND(
        100.0 *  SUM(CASE
                WHEN review_score IN (1, 2) THEN 1 ELSE 0
                END) 
                / 
                NULLIF(SUM(CASE
                WHEN review_score BETWEEN 1 AND 5 THEN 1 ELSE 0
                END),0),
                2
            ) AS low_review_rate_pct

FROM  `bq-sql-505714.olist_raw.v_order_delivery_review` 
GROUP BY rank_delay
ORDER BY rank_delay;



