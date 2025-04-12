SELECT 
    CASE 
        WHEN ss_quantity BETWEEN 1 AND 20 THEN '1-20'
        WHEN ss_quantity BETWEEN 21 AND 40 THEN '21-40'
        WHEN ss_quantity BETWEEN 41 AND 60 THEN '41-60'
        WHEN ss_quantity BETWEEN 61 AND 80 THEN '61-80'
        ELSE '81+'
    END AS quantity_range,
    CASE 
        WHEN COUNT(*) > 100 THEN AVG(ss_list_price)
        ELSE AVG(ss_net_profit)
    END AS average_value
FROM 
    store_sales
JOIN 
    reason ON store_sales.ss_reason_sk = reason.r_reason_sk
WHERE 
    reason.r_reason_sk = 1
GROUP BY 
    quantity_range
ORDER BY 
    quantity_range;


