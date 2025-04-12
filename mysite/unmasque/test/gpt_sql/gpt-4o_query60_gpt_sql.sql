WITH sales_data AS (
    SELECT
        ss_item_sk AS item_sk,
        ss_ext_sales_price AS sales_price
    FROM
        store_sales
    JOIN
        date_dim ON ss_sold_date_sk = d_date_sk
    JOIN
        customer ON ss_customer_sk = c_customer_sk
    WHERE
        d_year = 1999 AND d_moy = 8 AND c_current_gmt_offset = -6
    UNION ALL
    SELECT
        cs_item_sk AS item_sk,
        cs_ext_sales_price AS sales_price
    FROM
        catalog_sales
    JOIN
        date_dim ON cs_sold_date_sk = d_date_sk
    JOIN
        customer ON cs_bill_customer_sk = c_customer_sk
    WHERE
        d_year = 1999 AND d_moy = 8 AND c_current_gmt_offset = -6
    UNION ALL
    SELECT
        ws_item_sk AS item_sk,
        ws_ext_sales_price AS sales_price
    FROM
        web_sales
    JOIN
        date_dim ON ws_sold_date_sk = d_date_sk
    JOIN
        customer ON ws_bill_customer_sk = c_customer_sk
    WHERE
        d_year = 1999 AND d_moy = 8 AND c_current_gmt_offset = -6
)
SELECT
    item_sk,
    SUM(sales_price) AS total_sales
FROM
    sales_data
JOIN
    item ON item_sk = i_item_sk
WHERE
    i_category = 'Jewelry'
GROUP BY
    item_sk
ORDER BY
    total_sales DESC,
    item_sk
LIMIT 100;


