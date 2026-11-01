--購入者の州別に注文数・平均レビュー点数・遅延件数・遅延率を集計する
--遅延率の分母は、レビューの有無を問わず州別の全注文件数とする
--平均レビュー点数はNULLを除外して計算する

SELECT 
        c.customer_state,
        COUNT(*) AS order_count,
        AVG(rd.review_score) AS score_avg,
SUM(
        CASE
                WHEN rd.delay_date > 0 THEN 1
                ELSE 0
        END
   ) AS delayed_order_count,

ROUND(
100.0 *SUM(
        CASE 
                WHEN rd.delay_date > 0 THEN 1 
                ELSE 0
        END
        )/ NULLIF(COUNT(*), 0),
        2       
) || "%" AS delay_rate_pct

FROM  `bq-sql-505714.olist_raw.v_order_delivery_review` rd

LEFT JOIN `bq-sql-505714.olist_raw.customers` c
        ON rd.customer_id = c.customer_id

GROUP BY c.customer_state
ORDER BY delayed_order_count DESC;
