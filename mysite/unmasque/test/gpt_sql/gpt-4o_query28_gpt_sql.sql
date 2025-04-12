SELECT 
    CASE 
        WHEN ss_quantity BETWEEN 1 AND 10 THEN '1-10'
        WHEN ss_quantity BETWEEN 11 AND 20 THEN '11-20'
        WHEN ss_quantity BETWEEN 21 AND 30 THEN '21-30'
        WHEN ss_quantity BETWEEN 31 AND 40 THEN '31-40'
        WHEN ss_quantity BETWEEN 41 AND 50 THEN '41-50'
        ELSE '51+'
    END AS quantity_group,
    AVG(ss_list_price) AS avg_list_price,
    COUNT(ss_list_price) AS total_count_list_price,
    COUNT(DISTINCT ss_list_price) AS distinct_count_list_price
FROM 
    store_sales
WHERE 
    ss_list_price > 0 
    AND ss_coupon_amt = 0 
    AND ss_wholesale_cost > 0
GROUP BY 
    quantity_group
ORDER BY 
    quantity_group
LIMIT 100;


