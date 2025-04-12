SELECT 
    AVG(ss_quantity) AS avg_quantity_sold,
    AVG(ss_ext_sales_price) AS avg_extended_sales_price,
    AVG(ss_ext_wholesale_cost) AS avg_extended_wholesale_cost,
    SUM(ss_ext_wholesale_cost) AS total_extended_wholesale_cost
FROM 
    store_sales
JOIN 
    customer ON ss_customer_sk = c_customer_sk
JOIN 
    customer_demographics ON c_current_cdemo_sk = cd_demo_sk
JOIN 
    household_demographics ON c_current_hdemo_sk = hd_demo_sk
JOIN 
    date_dim ON ss_sold_date_sk = d_date_sk
WHERE 
    d_year = 2001
    AND cd_marital_status IN ('M', 'S')
    AND cd_education_status IN ('Advanced Degree', 'College', '2 yr Degree')
    AND hd_dep_count BETWEEN 1 AND 3
    AND ss_ext_sales_price BETWEEN 100 AND 500
    AND c_birth_country = 'United States'
    AND c_current_addr_sk IN (
        SELECT ca_address_sk 
        FROM customer_address 
        WHERE ca_state IN ('CA', 'NY', 'TX')
    )
    AND ss_net_profit BETWEEN 0 AND 1000;


