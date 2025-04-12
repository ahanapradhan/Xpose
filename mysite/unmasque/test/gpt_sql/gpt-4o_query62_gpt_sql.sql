SELECT 
    SUBSTRING(w.warehouse_name, 1, 20) AS warehouse_name,
    sm.sm_type AS shipping_mode_type,
    ws.web_site_name,
    CASE 
        WHEN DATEDIFF(ws.ws_ship_date_sk, ws.ws_sold_date_sk) <= 30 THEN 'Within 30 days'
        WHEN DATEDIFF(ws.ws_ship_date_sk, ws.ws_sold_date_sk) BETWEEN 31 AND 60 THEN '31-60 days'
        WHEN DATEDIFF(ws.ws_ship_date_sk, ws.ws_sold_date_sk) BETWEEN 61 AND 90 THEN '61-90 days'
        WHEN DATEDIFF(ws.ws_ship_date_sk, ws.ws_sold_date_sk) BETWEEN 91 AND 120 THEN '91-120 days'
        ELSE 'Over 120 days'
    END AS delivery_time_frame,
    COUNT(*) AS order_count
FROM 
    web_sales ws
JOIN 
    warehouse w ON ws.ws_warehouse_sk = w.w_warehouse_sk
JOIN 
    ship_mode sm ON ws.ws_ship_mode_sk = sm.sm_ship_mode_sk
JOIN 
    web_site ws ON ws.ws_web_site_sk = ws.web_site_sk
WHERE 
    ws.ws_sold_date_sk BETWEEN (SELECT MIN(d_date_sk) FROM date_dim WHERE d_year = 2022) 
    AND (SELECT MAX(d_date_sk) FROM date_dim WHERE d_year = 2022)
GROUP BY 
    SUBSTRING(w.warehouse_name, 1, 20),
    sm.sm_type,
    ws.web_site_name,
    delivery_time_frame
ORDER BY 
    order_count DESC
LIMIT 100;


