WITH sales_growth AS (
    SELECT
        ws.ws_customer_sk AS customer_sk,
        (SUM(CASE WHEN ws.ws_sold_date_sk BETWEEN d1.d_date_sk AND d2.d_date_sk THEN ws.ws_net_paid ELSE 0 END) -
         SUM(CASE WHEN ws.ws_sold_date_sk BETWEEN d3.d_date_sk AND d4.d_date_sk THEN ws.ws_net_paid ELSE 0 END)) /
        NULLIF(SUM(CASE WHEN ws.ws_sold_date_sk BETWEEN d3.d_date_sk AND d4.d_date_sk THEN ws.ws_net_paid ELSE 0 END), 0) AS web_sales_growth,
        (SUM(CASE WHEN ss.ss_sold_date_sk BETWEEN d1.d_date_sk AND d2.d_date_sk THEN ss.ss_net_paid ELSE 0 END) -
         SUM(CASE WHEN ss.ss_sold_date_sk BETWEEN d3.d_date_sk AND d4.d_date_sk THEN ss.ss_net_paid ELSE 0 END)) /
        NULLIF(SUM(CASE WHEN ss.ss_sold_date_sk BETWEEN d3.d_date_sk AND d4.d_date_sk THEN ss.ss_net_paid ELSE 0 END), 0) AS store_sales_growth
    FROM
        web_sales ws
    JOIN
        store_sales ss ON ws.ws_customer_sk = ss.ss_customer_sk
    JOIN
        date_dim d1 ON d1.d_year = 2000 AND d1.d_moy = 1 AND d1.d_dom = 1
    JOIN
        date_dim d2 ON d2.d_year = 2000 AND d2.d_moy = 12 AND d2.d_dom = 31
    JOIN
        date_dim d3 ON d3.d_year = 1999 AND d3.d_moy = 1 AND d3.d_dom = 1
    JOIN
        date_dim d4 ON d4.d_year = 1999 AND d4.d_moy = 12 AND d4.d_dom = 31
    GROUP BY
        ws.ws_customer_sk
)
SELECT
    c.c_customer_id,
    c.c_first_name,
    c.c_last_name
FROM
    sales_growth sg
JOIN
    customer c ON sg.customer_sk = c.c_customer_sk
WHERE
    sg.web_sales_growth > sg.store_sales_growth
ORDER BY
    c.c_customer_id,
    c.c_first_name,
    c.c_last_name
LIMIT 100;


