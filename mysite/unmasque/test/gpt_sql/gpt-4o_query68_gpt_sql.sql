SELECT 
    c.c_last_name,
    c.c_first_name,
    c.c_current_cdemo_sk,
    s.s_city AS store_city,
    ss_ticket_number,
    SUM(ss_ext_sales_price) AS total_ext_sales_price,
    SUM(ss_ext_tax) AS total_ext_tax,
    SUM(ss_list_price) AS total_list_price
FROM 
    store_sales ss
JOIN 
    customer c ON ss.ss_customer_sk = c.c_customer_sk
JOIN 
    store s ON ss.ss_store_sk = s.s_store_sk
JOIN 
    household_demographics hd ON c.c_current_hdemo_sk = hd.hd_demo_sk
WHERE 
    (s.s_city = 'Fairview' OR s.s_city = 'Midway')
    AND (hd.hd_dep_count = 8 AND hd.hd_vehicle_count = 3)
    AND (EXTRACT(DAY FROM ss_sold_date) IN (1, 2))
    AND (EXTRACT(YEAR FROM ss_sold_date) IN (1998, 1999, 2000))
    AND c.c_current_cdemo_sk != s.s_city
GROUP BY 
    c.c_last_name, c.c_first_name, c.c_current_cdemo_sk, s.s_city, ss_ticket_number
ORDER BY 
    c.c_last_name, ss_ticket_number
LIMIT 100;


