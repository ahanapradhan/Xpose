SELECT 
    COUNT(ss_ticket_number) AS sales_count,
    CASE 
        WHEN EXTRACT(HOUR FROM ss_sold_time) = 8 AND EXTRACT(MINUTE FROM ss_sold_time) < 30 THEN '8:00 - 8:30 AM'
        WHEN EXTRACT(HOUR FROM ss_sold_time) = 8 AND EXTRACT(MINUTE FROM ss_sold_time) >= 30 THEN '8:30 - 9:00 AM'
        WHEN EXTRACT(HOUR FROM ss_sold_time) = 9 AND EXTRACT(MINUTE FROM ss_sold_time) < 30 THEN '9:00 - 9:30 AM'
        WHEN EXTRACT(HOUR FROM ss_sold_time) = 9 AND EXTRACT(MINUTE FROM ss_sold_time) >= 30 THEN '9:30 - 10:00 AM'
        WHEN EXTRACT(HOUR FROM ss_sold_time) = 10 AND EXTRACT(MINUTE FROM ss_sold_time) < 30 THEN '10:00 - 10:30 AM'
        WHEN EXTRACT(HOUR FROM ss_sold_time) = 10 AND EXTRACT(MINUTE FROM ss_sold_time) >= 30 THEN '10:30 - 11:00 AM'
        WHEN EXTRACT(HOUR FROM ss_sold_time) = 11 AND EXTRACT(MINUTE FROM ss_sold_time) < 30 THEN '11:00 - 11:30 AM'
        WHEN EXTRACT(HOUR FROM ss_sold_time) = 11 AND EXTRACT(MINUTE FROM ss_sold_time) >= 30 THEN '11:30 - 12:00 PM'
        WHEN EXTRACT(HOUR FROM ss_sold_time) = 12 AND EXTRACT(MINUTE FROM ss_sold_time) < 30 THEN '12:00 - 12:30 PM'
        ELSE '12:30 - 1:00 PM'
    END AS time_interval,
    hd_dep_count,
    hd_vehicle_count
FROM 
    store_sales
JOIN 
    store ON store.s_store_sk = store_sales.ss_store_sk
JOIN 
    household_demographics ON store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
WHERE 
    store.s_store_name = 'ese'
    AND EXTRACT(HOUR FROM ss_sold_time) BETWEEN 8 AND 12
    AND (EXTRACT(HOUR FROM ss_sold_time) <> 12 OR EXTRACT(MINUTE FROM ss_sold_time) < 30)
GROUP BY 
    time_interval, hd_dep_count, hd_vehicle_count
ORDER BY 
    time_interval, hd_dep_count, hd_vehicle_count;


