WITH sales_returns AS (
    SELECT
        i_item_id,
        i_item_desc,
        s_state,
        ss_quantity AS sales_quantity,
        sr_return_quantity AS return_quantity
    FROM
        store_sales
    JOIN
        item ON ss_item_sk = i_item_sk
    JOIN
        store ON ss_store_sk = s_store_sk
    LEFT JOIN
        store_returns ON ss_ticket_number = sr_ticket_number
    WHERE
        ss_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_year = 1999 AND d_moy BETWEEN 1 AND 9)
        AND (SELECT d_date_sk FROM date_dim WHERE d_year = 1999 AND d_moy BETWEEN 1 AND 9)
    UNION ALL
    SELECT
        i_item_id,
        i_item_desc,
        NULL AS s_state,
        cs_quantity AS sales_quantity,
        cr_return_quantity AS return_quantity
    FROM
        catalog_sales
    JOIN
        item ON cs_item_sk = i_item_sk
    LEFT JOIN
        catalog_returns ON cs_order_number = cr_order_number
    WHERE
        cs_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_year = 1999 AND d_moy BETWEEN 1 AND 9)
        AND (SELECT d_date_sk FROM date_dim WHERE d_year = 1999 AND d_moy BETWEEN 1 AND 9)
)
SELECT
    i_item_id,
    i_item_desc,
    s_state,
    COUNT(sales_quantity) AS sales_count,
    AVG(sales_quantity) AS avg_sales_quantity,
    STDDEV(sales_quantity) AS stddev_sales_quantity,
    CASE WHEN AVG(sales_quantity) = 0 THEN 0 ELSE STDDEV(sales_quantity) / AVG(sales_quantity) END AS cov_sales_quantity,
    COUNT(return_quantity) AS return_count,
    AVG(return_quantity) AS avg_return_quantity,
    STDDEV(return_quantity) AS stddev_return_quantity,
    CASE WHEN AVG(return_quantity) = 0 THEN 0 ELSE STDDEV(return_quantity) / AVG(return_quantity) END AS cov_return_quantity
FROM
    sales_returns
GROUP BY
    i_item_id,
    i_item_desc,
    s_state
ORDER BY
    i_item_id,
    i_item_desc,
    s_state
LIMIT 100;


