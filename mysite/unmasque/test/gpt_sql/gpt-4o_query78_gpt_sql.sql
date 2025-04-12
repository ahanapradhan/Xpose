WITH sales_data AS (
    SELECT
        i_item_id,
        SUM(CASE WHEN d_year = 1999 THEN ss_quantity ELSE 0 END) AS store_sales_qty,
        SUM(CASE WHEN d_year = 1999 THEN ws_quantity ELSE 0 END) AS web_sales_qty,
        SUM(CASE WHEN d_year = 1999 THEN cs_quantity ELSE 0 END) AS catalog_sales_qty,
        SUM(CASE WHEN d_year = 1999 THEN ss_wholesale_cost ELSE 0 END) AS store_wholesale_cost,
        SUM(CASE WHEN d_year = 1999 THEN ws_wholesale_cost ELSE 0 END) AS web_wholesale_cost,
        SUM(CASE WHEN d_year = 1999 THEN cs_wholesale_cost ELSE 0 END) AS catalog_wholesale_cost,
        SUM(CASE WHEN d_year = 1999 THEN ss_sales_price ELSE 0 END) AS store_sales_price,
        SUM(CASE WHEN d_year = 1999 THEN ws_sales_price ELSE 0 END) AS web_sales_price,
        SUM(CASE WHEN d_year = 1999 THEN cs_sales_price ELSE 0 END) AS catalog_sales_price
    FROM
        item
    LEFT JOIN store_sales ON i_item_id = ss_item_id
    LEFT JOIN web_sales ON i_item_id = ws_item_id
    LEFT JOIN catalog_sales ON i_item_id = cs_item_id
    LEFT JOIN date_dim ON ss_sold_date_sk = d_date_sk
    WHERE
        d_year = 1999
    GROUP BY
        i_item_id
),
filtered_items AS (
    SELECT
        i_item_id,
        store_sales_qty,
        web_sales_qty,
        catalog_sales_qty,
        store_wholesale_cost,
        web_wholesale_cost,
        catalog_wholesale_cost,
        store_sales_price,
        web_sales_price,
        catalog_sales_price,
        store_sales_qty / NULLIF((web_sales_qty + catalog_sales_qty), 0) AS sales_ratio
    FROM
        sales_data
    WHERE
        store_sales_qty > 0
        AND web_sales_qty > 0
        AND catalog_sales_qty > 0
)
SELECT
    i_item_id,
    store_sales_qty,
    web_sales_qty,
    catalog_sales_qty,
    store_wholesale_cost,
    web_wholesale_cost,
    catalog_wholesale_cost,
    store_sales_price,
    web_sales_price,
    catalog_sales_price,
    sales_ratio
FROM
    filtered_items
ORDER BY
    store_sales_qty DESC,
    store_wholesale_cost DESC,
    store_sales_price DESC
LIMIT 100;


