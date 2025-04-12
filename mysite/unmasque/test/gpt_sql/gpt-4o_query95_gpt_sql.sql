SELECT 
    COUNT(DISTINCT ws_order_number) AS distinct_orders_count,
    SUM(ws_ext_ship_cost) AS total_shipping_cost,
    SUM(ws_net_profit) AS total_net_profit
FROM 
    web_sales
JOIN 
    warehouse ON ws_warehouse_sk = w_warehouse_sk
JOIN 
    customer ON ws_bill_customer_sk = c_customer_sk
JOIN 
    date_dim ON ws_ship_date_sk = d_date_sk
WHERE 
    d_date BETWEEN '2000-04-01' AND '2000-05-30'
    AND c_state = 'IN'
    AND w_company_name LIKE 'pri%'
    AND ws_returned_date_sk IS NOT NULL
GROUP BY 
    ws_order_number
ORDER BY 
    distinct_orders_count DESC
LIMIT 100;


