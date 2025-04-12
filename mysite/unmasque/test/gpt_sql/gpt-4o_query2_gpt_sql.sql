WITH weekly_sales AS (
    SELECT
        d1.d_week_seq AS week_seq_1998,
        d2.d_week_seq AS week_seq_1999,
        d1.d_day_name AS day_of_week,
        SUM(ws1.ws_sales_price) AS web_sales_1998,
        SUM(cs1.cs_sales_price) AS catalog_sales_1998,
        SUM(ws2.ws_sales_price) AS web_sales_1999,
        SUM(cs2.cs_sales_price) AS catalog_sales_1999
    FROM
        date_dim d1
    JOIN
        web_sales ws1 ON d1.d_date_sk = ws1.ws_sold_date_sk
    JOIN
        catalog_sales cs1 ON d1.d_date_sk = cs1.cs_sold_date_sk
    JOIN
        date_dim d2 ON d1.d_date = d2.d_date - INTERVAL '53 weeks'
    JOIN
        web_sales ws2 ON d2.d_date_sk = ws2.ws_sold_date_sk
    JOIN
        catalog_sales cs2 ON d2.d_date_sk = cs2.cs_sold_date_sk
    WHERE
        d1.d_year = 1998 AND d2.d_year = 1999
    GROUP BY
        d1.d_week_seq, d2.d_week_seq, d1.d_day_name
)
SELECT
    week_seq_1998,
    week_seq_1999,
    day_of_week,
    web_sales_1998,
    web_sales_1999,
    catalog_sales_1998,
    catalog_sales_1999,
    CASE WHEN web_sales_1999 = 0 THEN NULL ELSE web_sales_1998 / web_sales_1999 END AS web_sales_ratio,
    CASE WHEN catalog_sales_1999 = 0 THEN NULL ELSE catalog_sales_1998 / catalog_sales_1999 END AS catalog_sales_ratio
FROM
    weekly_sales
ORDER BY
    week_seq_1998, day_of_week;


