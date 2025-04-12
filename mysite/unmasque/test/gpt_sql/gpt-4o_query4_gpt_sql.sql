WITH sales_2001 AS (
    SELECT
        c_customer_id,
        SUM(CASE WHEN d_year = 2001 THEN ss_ext_sales_price ELSE 0 END) AS store_sales_2001,
        SUM(CASE WHEN d_year = 2001 THEN cs_ext_sales_price ELSE 0 END) AS catalog_sales_2001,
        SUM(CASE WHEN d_year = 2001 THEN ws_ext_sales_price ELSE 0 END) AS web_sales_2001
    FROM
        customer
    LEFT JOIN store_sales ON c_customer_id = ss_customer_sk
    LEFT JOIN catalog_sales ON c_customer_id = cs_bill_customer_sk
    LEFT JOIN web_sales ON c_customer_id = ws_bill_customer_sk
    LEFT JOIN date_dim ON ss_sold_date_sk = d_date_sk OR cs_sold_date_sk = d_date_sk OR ws_sold_date_sk = d_date_sk
    WHERE
        d_year = 2001
    GROUP BY
        c_customer_id
),
sales_2002 AS (
    SELECT
        c_customer_id,
        SUM(CASE WHEN d_year = 2002 THEN ss_ext_sales_price ELSE 0 END) AS store_sales_2002,
        SUM(CASE WHEN d_year = 2002 THEN cs_ext_sales_price ELSE 0 END) AS catalog_sales_2002,
        SUM(CASE WHEN d_year = 2002 THEN ws_ext_sales_price ELSE 0 END) AS web_sales_2002
    FROM
        customer
    LEFT JOIN store_sales ON c_customer_id = ss_customer_sk
    LEFT JOIN catalog_sales ON c_customer_id = cs_bill_customer_sk
    LEFT JOIN web_sales ON c_customer_id = ws_bill_customer_sk
    LEFT JOIN date_dim ON ss_sold_date_sk = d_date_sk OR cs_sold_date_sk = d_date_sk OR ws_sold_date_sk = d_date_sk
    WHERE
        d_year = 2002
    GROUP BY
        c_customer_id
)
SELECT
    c.c_customer_id,
    c.c_first_name,
    c.c_last_name,
    c.c_preferred_cust_flag
FROM
    customer c
JOIN sales_2001 s1 ON c.c_customer_id = s1.c_customer_id
JOIN sales_2002 s2 ON c.c_customer_id = s2.c_customer_id
WHERE
    s1.catalog_sales_2001 > 0
    AND (s2.catalog_sales_2002 - s1.catalog_sales_2001) / s1.catalog_sales_2001 > 
        (s2.store_sales_2002 - s1.store_sales_2001) / NULLIF(s1.store_sales_2001, 0)
    AND (s2.catalog_sales_2002 - s1.catalog_sales_2001) / s1.catalog_sales_2001 > 
        (s2.web_sales_2002 - s1.web_sales_2001) / NULLIF(s1.web_sales_2001, 0)
ORDER BY
    c.c_customer_id,
    c.c_first_name,
    c.c_last_name,
    c.c_preferred_cust_flag
LIMIT 100;


