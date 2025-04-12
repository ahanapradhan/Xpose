SELECT 
    i_item_id,
    c_birth_country AS country,
    c_current_cdemo_sk AS state,
    c_current_addr_sk AS county,
    AVG(ss_quantity) AS avg_quantity_sold,
    AVG(ss_list_price) AS avg_list_price,
    AVG(ss_coupon_amt) AS avg_coupon_amount,
    AVG(ss_sales_price) AS avg_sales_price,
    AVG(ss_net_profit) AS avg_net_profit,
    AVG(c_birth_year) AS avg_birth_year,
    COUNT(DISTINCT i_department) AS department_count
FROM
    store_sales
JOIN
    customer ON ss_customer_sk = c_customer_sk
JOIN
    item ON ss_item_sk = i_item_sk
JOIN
    date_dim ON ss_sold_date_sk = d_date_sk
WHERE
    d_year = 2001
    AND c_current_cdemo_sk IN ('KS', 'IA', 'AL', 'UT', 'VA', 'NC', 'TX')
    AND c_birth_month IN (8, 4, 2, 5, 11, 9)
    AND c_gender = 'F'
    AND c_education_status = 'Secondary'
GROUP BY
    i_item_id,
    c_birth_country,
    c_current_cdemo_sk,
    c_current_addr_sk
ORDER BY
    country,
    state,
    county,
    i_item_id
LIMIT 100;


