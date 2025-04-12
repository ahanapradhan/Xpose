SELECT 
    CASE 
        WHEN grouping(sales_channel) = 1 THEN 'All Channels'
        ELSE sales_channel 
    END AS sales_channel,
    CASE 
        WHEN sales_channel = 'store' THEN store_id
        WHEN sales_channel = 'catalog' THEN catalog_page_id
        WHEN sales_channel = 'web' THEN web_site_id
    END AS channel_id,
    SUM(sales_amount) AS total_sales,
    SUM(returns_amount) AS total_returns,
    SUM(net_profit) AS total_net_profit
FROM (
    SELECT 
        'store' AS sales_channel,
        ss_store_sk AS store_id,
        NULL AS catalog_page_id,
        NULL AS web_site_id,
        SUM(ss_ext_sales_price) AS sales_amount,
        SUM(coalesce(sr_return_amt, 0)) AS returns_amount,
        SUM(ss_net_profit) AS net_profit
    FROM store_sales
    LEFT JOIN store_returns ON ss_item_sk = sr_item_sk AND ss_ticket_number = sr_ticket_number
    JOIN item ON ss_item_sk = i_item_sk
    WHERE i_current_price > 50
    AND ss_sold_date_sk BETWEEN 2451772 AND 2451801
    AND ss_promo_sk NOT IN (SELECT p_promo_sk FROM promotion WHERE p_channel_tv = 'Y')
    GROUP BY ss_store_sk

    UNION ALL

    SELECT 
        'catalog' AS sales_channel,
        NULL AS store_id,
        cs_catalog_page_sk AS catalog_page_id,
        NULL AS web_site_id,
        SUM(cs_ext_sales_price) AS sales_amount,
        SUM(coalesce(cr_return_amount, 0)) AS returns_amount,
        SUM(cs_net_profit) AS net_profit
    FROM catalog_sales
    LEFT JOIN catalog_returns ON cs_item_sk = cr_item_sk AND cs_order_number = cr_order_number
    JOIN item ON cs_item_sk = i_item_sk
    WHERE i_current_price > 50
    AND cs_sold_date_sk BETWEEN 2451772 AND 2451801
    AND cs_promo_sk NOT IN (SELECT p_promo_sk FROM promotion WHERE p_channel_tv = 'Y')
    GROUP BY cs_catalog_page_sk

    UNION ALL

    SELECT 
        'web' AS sales_channel,
        NULL AS store_id,
        NULL AS catalog_page_id,
        ws_web_site_sk AS web_site_id,
        SUM(ws_ext_sales_price) AS sales_amount,
        SUM(coalesce(wr_return_amt, 0)) AS returns_amount,
        SUM(ws_net_profit) AS net_profit
    FROM web_sales
    LEFT JOIN web_returns ON ws_item_sk = wr_item_sk AND ws_order_number = wr_order_number
    JOIN item ON ws_item_sk = i_item_sk
    WHERE i_current_price > 50
    AND ws_sold_date_sk BETWEEN 2451772 AND 2451801
    AND ws_promo_sk NOT IN (SELECT p_promo_sk FROM promotion WHERE p_channel_tv = 'Y')
    GROUP BY ws_web_site_sk
) sales_data
GROUP BY ROLLUP(sales_channel, channel_id)
ORDER BY sales_channel, channel_id
LIMIT 100;


