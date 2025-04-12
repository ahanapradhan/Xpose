SELECT 
    c.c_last_name,
    c.c_first_name,
    c.c_current_cdemo.c_city AS current_city,
    s.s_city AS purchase_city,
    ss_ticket_number,
    SUM(ss_coupon_amt) AS total_coupon_amount,
    SUM(ss_net_profit) AS total_net_profit
FROM 
    store_sales
JOIN 
    customer ON ss_customer_sk = c_customer_sk
JOIN 
    store ON ss_store_sk = s_store_sk
JOIN 
    household_demographics ON c_current_hdemo_sk = hd_demo_sk
WHERE 
    c.c_current_cdemo.c_city <> s.s_city
    AND s.s_city IN ('Midway', 'Fairview')
    AND hd_dep_count = 6 OR hd_vehicle_count = 0
    AND EXTRACT(DOW FROM ss_sold_date_sk) IN (6, 0) -- Saturday = 6, Sunday = 0
    AND EXTRACT(YEAR FROM ss_sold_date_sk) IN (2000, 2001, 2002)
GROUP BY 
    c.c_last_name, c.c_first_name, c.c_current_cdemo.c_city, s.s_city, ss_ticket_number
ORDER BY 
    c.c_last_name, c.c_first_name, current_city, purchase_city, ss_ticket_number
LIMIT 100;


