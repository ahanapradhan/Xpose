SELECT 
    c.c_customer_zip AS customer_zip,
    SUM(cs.cs_ext_sales_price) AS total_sales_revenue
FROM 
    catalog_sales cs
JOIN 
    customer c ON cs.cs_bill_customer_sk = c.c_customer_sk
WHERE 
    cs.cs_sold_date_sk IN (
        SELECT d_date_sk 
        FROM date_dim 
        WHERE d_year = 1998 AND d_qoy = 1
    )
    AND (
        c.c_customer_zip LIKE '123%' OR 
        c.c_customer_zip LIKE '456%' OR 
        c.c_customer_zip LIKE '789%' OR 
        c.c_current_addr_sk IN (
            SELECT ca_address_sk 
            FROM customer_address 
            WHERE ca_state IN ('CA', 'WA', 'GA')
        ) OR 
        cs.cs_ext_sales_price > 500
    )
GROUP BY 
    c.c_customer_zip
ORDER BY 
    customer_zip
LIMIT 100;


