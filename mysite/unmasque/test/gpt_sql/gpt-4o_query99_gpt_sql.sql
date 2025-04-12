SELECT 
    SUBSTRING(w.warehouse_name, 1, 20) AS warehouse_name,
    cs.ship_mode,
    cc.call_center_name,
    SUM(CASE 
        WHEN DATEDIFF(cs.ship_date, cs.sold_date) <= 30 THEN cs.sales_price 
        ELSE 0 
    END) AS sales_within_30_days,
    SUM(CASE 
        WHEN DATEDIFF(cs.ship_date, cs.sold_date) BETWEEN 31 AND 60 THEN cs.sales_price 
        ELSE 0 
    END) AS sales_31_to_60_days,
    SUM(CASE 
        WHEN DATEDIFF(cs.ship_date, cs.sold_date) BETWEEN 61 AND 90 THEN cs.sales_price 
        ELSE 0 
    END) AS sales_61_to_90_days,
    SUM(CASE 
        WHEN DATEDIFF(cs.ship_date, cs.sold_date) BETWEEN 91 AND 120 THEN cs.sales_price 
        ELSE 0 
    END) AS sales_91_to_120_days,
    SUM(CASE 
        WHEN DATEDIFF(cs.ship_date, cs.sold_date) > 120 THEN cs.sales_price 
        ELSE 0 
    END) AS sales_over_120_days
FROM 
    catalog_sales cs
JOIN 
    warehouse w ON cs.warehouse_sk = w.warehouse_sk
JOIN 
    call_center cc ON cs.call_center_sk = cc.call_center_sk
GROUP BY 
    SUBSTRING(w.warehouse_name, 1, 20), 
    cs.ship_mode, 
    cc.call_center_name
ORDER BY 
    warehouse_name, 
    ship_mode, 
    call_center_name
LIMIT 100;


