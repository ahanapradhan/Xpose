SELECT 
    COUNT(DISTINCT ws_order_number) AS distinct_order_count,
    SUM(ws_ext_ship_cost) AS total_shipping_cost,
    SUM(ws_net_profit) AS total_net_profit
FROM 
    web_sales
JOIN 
    customer ON ws_bill_customer_sk = c_customer_sk
JOIN 
    web_site ON ws_web_site_sk = web_site_sk
JOIN 
    warehouse ON ws_warehouse_sk = w_warehouse_sk
WHERE 
    c_state = 'MT'
    AND web_site_name = 'pri'
    AND ws_ship_date BETWEEN DATE '2000-03-01' AND DATE '2000-04-29'
    AND ws_order_number IN (
        SELECT ws_order_number
        FROM web_sales
        GROUP BY ws_order_number
        HAVING COUNT(DISTINCT ws_warehouse_sk) > 1
    )
    AND ws_returned_date IS NULL
GROUP BY 
    ws_order_number
ORDER BY 
    distinct_order_count DESC
LIMIT 100;


