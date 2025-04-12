WITH sales_data AS (
    SELECT
        'store' AS channel,
        ss_store_sk AS channel_id,
        SUM(ss_ext_sales_price) AS total_sales,
        SUM(ss_net_profit) AS total_profit,
        SUM(ss_ext_list_price - ss_ext_sales_price) AS total_returns
    FROM store_sales
    JOIN date_dim ON ss_sold_date_sk = d_date_sk
    WHERE d_date BETWEEN '2002-08-22' AND '2002-09-04'
    GROUP BY ss_store_sk

    UNION ALL

    SELECT
        'catalog' AS channel,
        cs_catalog_page_sk AS channel_id,
        SUM(cs_ext_sales_price) AS total_sales,
        SUM(cs_net_profit) AS total_profit,
        SUM(cs_ext_list_price - cs_ext_sales_price) AS total_returns
    FROM catalog_sales
    JOIN date_dim ON cs_sold_date_sk = d_date_sk
    WHERE d_date BETWEEN '2002-08-22' AND '2002-09-04'
    GROUP BY cs_catalog_page_sk

    UNION ALL

    SELECT
        'web' AS channel,
        ws_web_site_sk AS channel_id,
        SUM(ws_ext_sales_price) AS total_sales,
        SUM(ws_net_profit) AS total_profit,
        SUM(ws_ext_list_price - ws_ext_sales_price) AS total_returns
    FROM web_sales
    JOIN date_dim ON ws_sold_date_sk = d_date_sk
    WHERE d_date BETWEEN '2002-08-22' AND '2002-09-04'
    GROUP BY ws_web_site_sk
)

SELECT
    channel,
    channel_id,
    SUM(total_sales) AS total_sales,
    SUM(total_returns) AS total_returns,
    SUM(total_profit) AS total_profit,
    SUM(total_sales - total_returns) AS adjusted_profit
FROM sales_data
GROUP BY ROLLUP(channel, channel_id)
ORDER BY channel, channel_id
LIMIT 100;


