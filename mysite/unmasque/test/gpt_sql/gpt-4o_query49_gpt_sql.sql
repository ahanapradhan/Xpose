WITH sales_data AS (
    SELECT
        i_item_id,
        'web' AS channel,
        ws_quantity AS total_quantity,
        ws_net_paid AS net_paid,
        wr_return_quantity AS return_quantity,
        wr_return_amt AS return_amount
    FROM web_sales
    JOIN web_returns ON ws_item_sk = wr_item_sk AND ws_order_number = wr_order_number
    JOIN item ON ws_item_sk = i_item_sk
    WHERE ws_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_date = '1999-12-01')
                              AND (SELECT d_date_sk FROM date_dim WHERE d_date = '1999-12-31')
    
    UNION ALL
    
    SELECT
        i_item_id,
        'catalog' AS channel,
        cs_quantity AS total_quantity,
        cs_net_paid AS net_paid,
        cr_return_quantity AS return_quantity,
        cr_return_amount AS return_amount
    FROM catalog_sales
    JOIN catalog_returns ON cs_item_sk = cr_item_sk AND cs_order_number = cr_order_number
    JOIN item ON cs_item_sk = i_item_sk
    WHERE cs_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_date = '1999-12-01')
                              AND (SELECT d_date_sk FROM date_dim WHERE d_date = '1999-12-31')
    
    UNION ALL
    
    SELECT
        i_item_id,
        'store' AS channel,
        ss_quantity AS total_quantity,
        ss_net_paid AS net_paid,
        sr_return_quantity AS return_quantity,
        sr_return_amt AS return_amount
    FROM store_sales
    JOIN store_returns ON ss_item_sk = sr_item_sk AND ss_ticket_number = sr_ticket_number
    JOIN item ON ss_item_sk = i_item_sk
    WHERE ss_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_date = '1999-12-01')
                              AND (SELECT d_date_sk FROM date_dim WHERE d_date = '1999-12-31')
),
ranked_items AS (
    SELECT
        i_item_id,
        channel,
        return_quantity / NULLIF(total_quantity, 0) AS return_ratio,
        return_amount / NULLIF(net_paid, 0) AS currency_ratio,
        ROW_NUMBER() OVER (PARTITION BY channel ORDER BY return_quantity / NULLIF(total_quantity, 0) DESC, return_amount / NULLIF(net_paid, 0) DESC) AS rank
    FROM sales_data
)
SELECT
    i_item_id,
    channel,
    return_ratio,
    currency_ratio,
    rank
FROM ranked_items
WHERE rank <= 10
ORDER BY channel, rank
LIMIT 100;


