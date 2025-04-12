SELECT 
    s.store_name,
    s.store_id,
    s.store_address,
    s.store_city,
    s.store_state,
    s.store_zip,
    COUNT(CASE WHEN DATEDIFF(sr.sr_returned_date_sk, ss.ss_sold_date_sk) <= 30 THEN 1 END) AS returns_within_30_days,
    COUNT(CASE WHEN DATEDIFF(sr.sr_returned_date_sk, ss.ss_sold_date_sk) BETWEEN 31 AND 60 THEN 1 END) AS returns_31_60_days,
    COUNT(CASE WHEN DATEDIFF(sr.sr_returned_date_sk, ss.ss_sold_date_sk) BETWEEN 61 AND 90 THEN 1 END) AS returns_61_90_days,
    COUNT(CASE WHEN DATEDIFF(sr.sr_returned_date_sk, ss.ss_sold_date_sk) BETWEEN 91 AND 120 THEN 1 END) AS returns_91_120_days,
    COUNT(CASE WHEN DATEDIFF(sr.sr_returned_date_sk, ss.ss_sold_date_sk) > 120 THEN 1 END) AS returns_over_120_days
FROM 
    store_sales ss
JOIN 
    store_returns sr ON ss.ss_item_sk = sr.sr_item_sk AND ss.ss_ticket_number = sr.sr_ticket_number
JOIN 
    store s ON ss.ss_store_sk = s.store_sk
JOIN 
    date_dim d ON ss.ss_sold_date_sk = d.d_date_sk
WHERE 
    d.d_year = 2002 AND d.d_moy = 9
GROUP BY 
    s.store_name, s.store_id, s.store_address, s.store_city, s.store_state, s.store_zip
ORDER BY 
    s.store_name, s.store_id
LIMIT 100;


