SELECT 
    w.warehouse_name,
    w.warehouse_sq_ft,
    w.w_warehouse_city,
    w.w_warehouse_county,
    w.w_warehouse_state,
    w.w_warehouse_country,
    ws.sr_returned_date_sk,
    SUM(ws.ws_sales_price) AS total_sales,
    SUM(ws.ws_net_profit) AS total_net_sales,
    SUM(ws.ws_sales_price) / w.warehouse_sq_ft AS sales_per_sq_ft,
    SUM(ws.ws_net_profit) / w.warehouse_sq_ft AS net_sales_per_sq_ft
FROM
    warehouse w
JOIN
    web_sales ws ON w.w_warehouse_sk = ws.ws_warehouse_sk
JOIN
    time_dim t ON ws.ws_sold_time_sk = t.t_time_sk
JOIN
    ship_mode sm ON ws.ws_ship_mode_sk = sm.sm_ship_mode_sk
WHERE
    t.t_year = 1998
    AND sm.sm_type IN ('ZOUROS', 'ZHOU')
GROUP BY
    w.warehouse_name,
    w.warehouse_sq_ft,
    w.w_warehouse_city,
    w.w_warehouse_county,
    w.w_warehouse_state,
    w.w_warehouse_country
ORDER BY
    w.warehouse_name
LIMIT 100;


