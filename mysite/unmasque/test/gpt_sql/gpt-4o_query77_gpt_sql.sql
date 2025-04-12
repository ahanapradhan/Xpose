WITH sales_data AS (
    SELECT
        'store' AS channel,
        ss_store_sk AS channel_id,
        SUM(ss_ext_sales_price) AS total_sales,
        SUM(ss_net_profit) AS net_profit
    FROM store_sales
    JOIN date_dim ON ss_sold_date_sk = d_date_sk
    WHERE d_date BETWEEN '2001-08-16' AND '2001-09-14'
    GROUP BY ss_store_sk

    UNION ALL

    SELECT
        'catalog' AS channel,
        cs_call_center_sk AS channel_id,
        SUM(cs_ext_sales_price) AS total_sales,
        SUM(cs_net_profit) AS net_profit
    FROM catalog_sales
    JOIN date_dim ON cs_sold_date_sk = d_date_sk
    WHERE d_date BETWEEN '2001-08-16' AND '2001-09-14'
    GROUP BY cs_call_center_sk

    UNION ALL

    SELECT
        'web' AS channel,
        ws_web_site_sk AS channel_id,
        SUM(ws_ext_sales_price) AS total_sales,
        SUM(ws_net_profit) AS net_profit
    FROM web_sales
    JOIN date_dim ON ws_sold_date_sk = d_date_sk
    WHERE d_date BETWEEN '2001-08-16' AND '2001-09-14'
    GROUP BY ws_web_site_sk
),

returns_data AS (
    SELECT
        'store' AS channel,
        sr_store_sk AS channel_id,
        SUM(sr_return_amt) AS total_returns
    FROM store_returns
    JOIN date_dim ON sr_returned_date_sk = d_date_sk
    WHERE d_date BETWEEN '2001-08-16' AND '2001-09-14'
    GROUP BY sr_store_sk

    UNION ALL

    SELECT
        'catalog' AS channel,
        cr_call_center_sk AS channel_id,
        SUM(cr_return_amount) AS total_returns
    FROM catalog_returns
    JOIN date_dim ON cr_returned_date_sk = d_date_sk
    WHERE d_date BETWEEN '2001-08-16' AND '2001-09-14'
    GROUP BY cr_call_center_sk

    UNION ALL

    SELECT
        'web' AS channel,
        wr_web_site_sk AS channel_id,
        SUM(wr_return_amt) AS total_returns
    FROM web_returns
    JOIN date_dim ON wr_returned_date_sk = d_date_sk
    WHERE d_date BETWEEN '2001-08-16' AND '2001-09-14'
    GROUP BY wr_web_site_sk
)

SELECT
    COALESCE(sales.channel, returns.channel) AS channel,
    COALESCE(sales.channel_id, returns.channel_id) AS channel_id,
    SUM(sales.total_sales) AS total_sales,
    SUM(returns.total_returns) AS total_returns,
    SUM(sales.net_profit) - SUM(returns.total_returns) AS net_profit
FROM sales_data sales
FULL OUTER JOIN returns_data returns
ON sales.channel = returns.channel AND sales.channel_id = returns.channel_id
GROUP BY ROLLUP(channel, channel_id)
ORDER BY channel, channel_id
LIMIT 100;


