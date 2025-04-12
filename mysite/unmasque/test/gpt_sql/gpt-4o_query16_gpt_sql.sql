SELECT 
    cs_ship_date_sk,
    COUNT(DISTINCT cs_order_number) AS unique_orders,
    SUM(cs_ext_ship_cost) AS total_shipping_cost,
    SUM(cs_net_profit) AS total_net_profit
FROM 
    catalog_sales
JOIN 
    customer ON cs_bill_customer_sk = c_customer_sk
JOIN 
    customer_address ON c_current_addr_sk = ca_address_sk
JOIN 
    date_dim ON cs_ship_date_sk = d_date_sk
WHERE 
    d_date BETWEEN '2002-03-01' AND '2002-04-30'
    AND ca_state = 'IA'
    AND ca_county = 'Williamson'
    AND cs_warehouse_sk IS NOT NULL
    AND cs_returned_date_sk IS NULL
GROUP BY 
    cs_ship_date_sk
ORDER BY 
    unique_orders DESC
LIMIT 100;


