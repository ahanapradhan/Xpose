WITH sales_growth AS (
    SELECT
        ws.ws_county AS county,
        SUM(CASE WHEN ws.ws_sold_date_sk BETWEEN d1.d_date_sk AND d2.d_date_sk THEN ws.ws_sales_price ELSE 0 END) AS web_sales_q1,
        SUM(CASE WHEN ws.ws_sold_date_sk BETWEEN d2.d_date_sk AND d3.d_date_sk THEN ws.ws_sales_price ELSE 0 END) AS web_sales_q2,
        SUM(CASE WHEN ws.ws_sold_date_sk BETWEEN d3.d_date_sk AND d4.d_date_sk THEN ws.ws_sales_price ELSE 0 END) AS web_sales_q3,
        SUM(CASE WHEN ss.ss_sold_date_sk BETWEEN d1.d_date_sk AND d2.d_date_sk THEN ss.ss_sales_price ELSE 0 END) AS store_sales_q1,
        SUM(CASE WHEN ss.ss_sold_date_sk BETWEEN d2.d_date_sk AND d3.d_date_sk THEN ss.ss_sales_price ELSE 0 END) AS store_sales_q2,
        SUM(CASE WHEN ss.ss_sold_date_sk BETWEEN d3.d_date_sk AND d4.d_date_sk THEN ss.ss_sales_price ELSE 0 END) AS store_sales_q3
    FROM
        web_sales ws
    JOIN
        store_sales ss ON ws.ws_sold_date_sk = ss.ss_sold_date_sk
    JOIN
        date_dim d1 ON d1.d_year = 2001 AND d1.d_moy = 1
    JOIN
        date_dim d2 ON d2.d_year = 2001 AND d2.d_moy = 4
    JOIN
        date_dim d3 ON d3.d_year = 2001 AND d3.d_moy = 7
    JOIN
        date_dim d4 ON d4.d_year = 2001 AND d4.d_moy = 10
    WHERE
        ws.ws_sold_date_sk BETWEEN d1.d_date_sk AND d4.d_date_sk
        AND ss.ss_sold_date_sk BETWEEN d1.d_date_sk AND d4.d_date_sk
    GROUP BY
        ws.ws_county
),
growth_comparison AS (
    SELECT
        county,
        (web_sales_q2 - web_sales_q1) / NULLIF(web_sales_q1, 0) AS web_growth_q1_q2,
        (web_sales_q3 - web_sales_q2) / NULLIF(web_sales_q2, 0) AS web_growth_q2_q3,
        (store_sales_q2 - store_sales_q1) / NULLIF(store_sales_q1, 0) AS store_growth_q1_q2,
        (store_sales_q3 - store_sales_q2) / NULLIF(store_sales_q2, 0) AS store_growth_q2_q3
    FROM
        sales_growth
)
SELECT
    county
FROM
    growth_comparison
WHERE
    web_growth_q1_q2 > store_growth_q1_q2
    AND web_growth_q2_q3 > store_growth_q2_q3;


