SELECT 
    wr_reason_desc,
    AVG(ws_quantity) AS avg_sales_quantity,
    AVG(wr_refunded_cash) AS avg_refunded_cash,
    AVG(wr_fee) AS avg_fee
FROM 
    web_sales
JOIN 
    web_returns ON ws_order_number = wr_order_number
JOIN 
    customer ON ws_bill_customer_sk = c_customer_sk
JOIN 
    customer_demographics ON c_current_cdemo_sk = cd_demo_sk
JOIN 
    household_demographics ON c_current_hdemo_sk = hd_demo_sk
JOIN 
    customer_address ON c_current_addr_sk = ca_address_sk
WHERE 
    ws_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_year = 2001 AND d_moy = 1 AND d_dom = 1)
    AND (SELECT d_date_sk FROM date_dim WHERE d_year = 2001 AND d_moy = 12 AND d_dom = 31)
    AND cd_marital_status IN ('W', 'D', 'M')
    AND cd_education_status IN ('Primary', 'Secondary', 'College', 'Graduate')
    AND ws_sales_price BETWEEN 100 AND 500
    AND ca_state IN ('CA', 'NY', 'TX', 'FL', 'IL')
    AND ws_net_profit BETWEEN 10 AND 100
GROUP BY 
    wr_reason_desc
ORDER BY 
    COUNT(wr_reason_desc) DESC
LIMIT 100;


