SELECT SUM(ss_quantity) AS total_quantity_sold
FROM store_sales
JOIN customer ON ss_customer_sk = c_customer_sk
JOIN customer_address ON c_current_addr_sk = ca_address_sk
JOIN date_dim ON ss_sold_date_sk = d_date_sk
WHERE d_year = 1999
AND (
    (c_marital_status = 'W' AND c_education_status = 'Secondary' AND ss_sales_price BETWEEN 100 AND 150)
    OR (c_marital_status = 'M' AND c_education_status = 'Advanced Degree' AND ss_sales_price BETWEEN 50 AND 100)
    OR (c_marital_status = 'D' AND c_education_status = '2-year Degree' AND ss_sales_price BETWEEN 150 AND 200)
)
AND ca_country = 'United States'
AND (
    (ca_state IN ('TX', 'NE', 'MO') AND ss_net_profit BETWEEN 0 AND 1000)
    OR (ca_state IN ('CO', 'TN', 'ND') AND ss_net_profit BETWEEN 100 AND 500)
    OR (ca_state IN ('OK', 'PA', 'CA') AND ss_net_profit BETWEEN 50 AND 300)
);


