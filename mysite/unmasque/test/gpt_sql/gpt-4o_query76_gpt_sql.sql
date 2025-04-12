SELECT 
    sales_channel,
    d_year,
    d_qoy,
    i_category,
    COUNT(*) AS total_transactions,
    SUM(ss_net_paid) AS total_sales_amount
FROM (
    SELECT 
        'store' AS sales_channel,
        d_year,
        d_qoy,
        i_category,
        ss_net_paid
    FROM store_sales
    JOIN date_dim ON ss_sold_date_sk = d_date_sk
    JOIN item ON ss_item_sk = i_item_sk
    WHERE ss_customer_sk IS NULL OR ss_warehouse_sk IS NULL

    UNION ALL

    SELECT 
        'web' AS sales_channel,
        d_year,
        d_qoy,
        i_category,
        ws_net_paid
    FROM web_sales
    JOIN date_dim ON ws_sold_date_sk = d_date_sk
    JOIN item ON ws_item_sk = i_item_sk
    WHERE ws_bill_customer_sk IS NULL OR ws_warehouse_sk IS NULL

    UNION ALL

    SELECT 
        'catalog' AS sales_channel,
        d_year,
        d_qoy,
        i_category,
        cs_net_paid
    FROM catalog_sales
    JOIN date_dim ON cs_sold_date_sk = d_date_sk
    JOIN item ON cs_item_sk = i_item_sk
    WHERE cs_bill_customer_sk IS NULL OR cs_warehouse_sk IS NULL
) sales_data
GROUP BY 
    sales_channel,
    d_year,
    d_qoy,
    i_category
ORDER BY 
    sales_channel,
    d_year,
    d_qoy,
    i_category
LIMIT 100;


