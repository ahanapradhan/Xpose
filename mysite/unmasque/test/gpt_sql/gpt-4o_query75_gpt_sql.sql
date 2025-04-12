WITH sales_2001 AS (
    SELECT
        p.p_brand,
        p.p_class,
        p.p_category,
        p.p_manufact_id,
        SUM(CASE WHEN d.d_year = 2001 THEN cs.cs_quantity ELSE 0 END) AS catalog_sales_count_2001,
        SUM(CASE WHEN d.d_year = 2001 THEN cs.cs_net_paid ELSE 0 END) AS catalog_sales_amount_2001,
        SUM(CASE WHEN d.d_year = 2001 THEN ss.ss_quantity ELSE 0 END) AS store_sales_count_2001,
        SUM(CASE WHEN d.d_year = 2001 THEN ss.ss_net_paid ELSE 0 END) AS store_sales_amount_2001,
        SUM(CASE WHEN d.d_year = 2001 THEN ws.ws_quantity ELSE 0 END) AS web_sales_count_2001,
        SUM(CASE WHEN d.d_year = 2001 THEN ws.ws_net_paid ELSE 0 END) AS web_sales_amount_2001
    FROM
        catalog_sales cs
        JOIN store_sales ss ON cs.cs_item_sk = ss.ss_item_sk
        JOIN web_sales ws ON cs.cs_item_sk = ws.ws_item_sk
        JOIN item p ON cs.cs_item_sk = p.i_item_sk
        JOIN date_dim d ON cs.cs_sold_date_sk = d.d_date_sk
    WHERE
        p.p_category = 'Men'
    GROUP BY
        p.p_brand, p.p_class, p.p_category, p.p_manufact_id
),
sales_2002 AS (
    SELECT
        p.p_brand,
        p.p_class,
        p.p_category,
        p.p_manufact_id,
        SUM(CASE WHEN d.d_year = 2002 THEN cs.cs_quantity ELSE 0 END) AS catalog_sales_count_2002,
        SUM(CASE WHEN d.d_year = 2002 THEN cs.cs_net_paid ELSE 0 END) AS catalog_sales_amount_2002,
        SUM(CASE WHEN d.d_year = 2002 THEN ss.ss_quantity ELSE 0 END) AS store_sales_count_2002,
        SUM(CASE WHEN d.d_year = 2002 THEN ss.ss_net_paid ELSE 0 END) AS store_sales_amount_2002,
        SUM(CASE WHEN d.d_year = 2002 THEN ws.ws_quantity ELSE 0 END) AS web_sales_count_2002,
        SUM(CASE WHEN d.d_year = 2002 THEN ws.ws_net_paid ELSE 0 END) AS web_sales_amount_2002
    FROM
        catalog_sales cs
        JOIN store_sales ss ON cs.cs_item_sk = ss.ss_item_sk
        JOIN web_sales ws ON cs.cs_item_sk = ws.ws_item_sk
        JOIN item p ON cs.cs_item_sk = p.i_item_sk
        JOIN date_dim d ON cs.cs_sold_date_sk = d.d_date_sk
    WHERE
        p.p_category = 'Men'
    GROUP BY
        p.p_brand, p.p_class, p.p_category, p.p_manufact_id
)
SELECT
    s1.p_brand,
    s1.p_class,
    s1.p_category,
    s1.p_manufact_id,
    (s1.catalog_sales_count_2001 + s1.store_sales_count_2001 + s1.web_sales_count_2001) AS total_sales_count_2001,
    (s2.catalog_sales_count_2002 + s2.store_sales_count_2002 + s2.web_sales_count_2002) AS total_sales_count_2002,
    (s1.catalog_sales_amount_2001 + s1.store_sales_amount_2001 + s1.web_sales_amount_2001) AS total_sales_amount_2001,
    (s2.catalog_sales_amount_2002 + s2.store_sales_amount_2002 + s2.web_sales_amount_2002) AS total_sales_amount_2002
FROM
    sales_2001 s1
    JOIN sales_2002 s2 ON s1.p_brand = s2.p_brand
    AND s1.p_class = s2.p_class
    AND s1.p_category = s2.p_category
    AND s1.p_manufact_id = s2.p_manufact_id
WHERE
    (s1.catalog_sales_count_2001 + s1.store_sales_count_2001 + s1.web_sales_count_2001) > 0
    AND (s2.catalog_sales_count_2002 + s2.store_sales_count_2002 + s2.web_sales_count_2002) < 
        (s1.catalog_sales_count_2001 + s1.store_sales_count_2001 + s1.web_sales_count_2001) * 0.9
ORDER BY
    (s1.catalog_sales_count_2001 + s1.store_sales_count_2001 + s1.web_sales_count_2001) - 
    (s2.catalog_sales_count_2002 + s2.store_sales_count_2002 + s2.web_sales_count_2002) DESC
LIMIT 100;


