SELECT 
    c.c_last_name,
    c.c_first_name,
    LEFT(c.c_city, 30) AS c_city,
    ss.ss_ticket_number,
    ss.ss_coupon_amt,
    (ss.ss_sales_price - ss.ss_coupon_amt) AS net_profit
FROM 
    store_sales ss
JOIN 
    customer c ON ss.ss_customer_sk = c.c_customer_sk
JOIN 
    store s ON ss.ss_store_sk = s.s_store_sk
JOIN 
    household_demographics hd ON c.c_current_hdemo_sk = hd.hd_demo_sk
WHERE 
    ss.ss_sold_date_sk IN (
        SELECT d_date_sk 
        FROM date_dim 
        WHERE d_day_of_week = 1 
        AND d_year IN (2000, 2001, 2002)
    )
    AND s.s_number_employees BETWEEN 200 AND 295
    AND (hd.hd_dep_count = 8 OR hd.hd_vehicle_count > 4)
ORDER BY 
    c.c_last_name,
    c.c_first_name,
    c.c_city,
    net_profit
LIMIT 100;


