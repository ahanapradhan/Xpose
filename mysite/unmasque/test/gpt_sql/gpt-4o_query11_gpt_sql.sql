WITH sales_growth AS (
    SELECT
        ws.ws_bill_customer_sk AS customer_sk,
        SUM(CASE WHEN ws.ws_sold_date_sk BETWEEN d1.d_date_sk AND d2.d_date_sk THEN ws.ws_net_paid ELSE 0 END) AS web_sales_2001,
        SUM(CASE WHEN ws.ws_sold_date_sk BETWEEN d3.d_date_sk AND d4.d_date_sk THEN ws.ws_net_paid ELSE 0 END) AS web_sales_2002,
        SUM(CASE WHEN ss.ss_sold_date_sk BETWEEN d1.d_date_sk AND d2.d_date_sk THEN ss.ss_net_paid ELSE 0 END) AS store_sales_2001,
        SUM(CASE WHEN ss.ss_sold_date_sk BETWEEN d3.d_date_sk AND d4.d_date_sk THEN ss.ss_net_paid ELSE 0 END) AS store_sales_2002
    FROM
        web_sales ws
    JOIN
        store_sales ss ON ws.ws_bill_customer_sk = ss.ss_customer_sk
    JOIN
        date_dim d1 ON d1.d_year = 2001 AND d1.d_moy = 1 AND d1.d_dom = 1
    JOIN
        date_dim d2 ON d2.d_year = 2001 AND d2.d_moy = 12 AND d2.d_dom = 31
    JOIN
        date_dim d3 ON d3.d_year = 2002 AND d3.d_moy = 1 AND d3.d_dom = 1
    JOIN
        date_dim d4 ON d4.d_year = 2002 AND d4.d_moy = 12 AND d4.d_dom = 31
    GROUP BY
        ws.ws_bill_customer_sk
),
growth_comparison AS (
    SELECT
        customer_sk,
        (web_sales_2002 - web_sales_2001) / NULLIF(web_sales_2001, 0) AS web_growth_rate,
        (store_sales_2002 - store_sales_2001) / NULLIF(store_sales_2001, 0) AS store_growth_rate
    FROM
        sales_growth
)
SELECT
    c.c_customer_id,
    c.c_first_name,
    c.c_last_name,
    c.c_birth_country
FROM
    growth_comparison gc
JOIN
    customer c ON gc.customer_sk = c.c_customer_sk
WHERE
    web_growth_rate > store_growth_rate
ORDER BY
    web_growth_rate - store_growth_rate DESC
LIMIT 100;


