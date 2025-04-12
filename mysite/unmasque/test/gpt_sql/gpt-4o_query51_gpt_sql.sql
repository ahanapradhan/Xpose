WITH web_sales_cumulative AS (
    SELECT
        ws_item_sk AS item_sk,
        ws_sold_date_sk AS sold_date_sk,
        SUM(ws_sales_price) OVER (PARTITION BY ws_item_sk ORDER BY ws_sold_date_sk) AS cumulative_web_sales
    FROM
        web_sales
    JOIN
        date_dim ON ws_sold_date_sk = d_date_sk
    WHERE
        d_year = 2001
),
store_sales_cumulative AS (
    SELECT
        ss_item_sk AS item_sk,
        ss_sold_date_sk AS sold_date_sk,
        SUM(ss_sales_price) OVER (PARTITION BY ss_item_sk ORDER BY ss_sold_date_sk) AS cumulative_store_sales
    FROM
        store_sales
    JOIN
        date_dim ON ss_sold_date_sk = d_date_sk
    WHERE
        d_year = 2001
)
SELECT
    wsc.item_sk,
    wsc.sold_date_sk,
    wsc.cumulative_web_sales,
    ssc.cumulative_store_sales
FROM
    web_sales_cumulative wsc
JOIN
    store_sales_cumulative ssc ON wsc.item_sk = ssc.item_sk AND wsc.sold_date_sk = ssc.sold_date_sk
WHERE
    wsc.cumulative_web_sales > ssc.cumulative_store_sales
ORDER BY
    wsc.item_sk,
    wsc.sold_date_sk
LIMIT 100;


