SELECT LEFT(w.w_warehouse_name, 20) AS warehouse_name, sm.sm_type AS shipping_mode_type, ws_site.web_name AS website_name, COUNT(*) AS total_shipments, SUM(CASE WHEN sd.d_date - d.d_date <= 30 THEN 1 ELSE 0 END) AS within_30_days, SUM(CASE WHEN sd.d_date - d.d_date BETWEEN 31 AND 60 THEN 1 ELSE 0 END) AS between_31_and_60_days, SUM(CASE WHEN sd.d_date - d.d_date BETWEEN 61 AND 90 THEN 1 ELSE 0 END) AS between_61_and_90_days, SUM(CASE WHEN sd.d_date - d.d_date BETWEEN 91 AND 120 THEN 1 ELSE 0 END) AS between_91_and_120_days, SUM(CASE WHEN sd.d_date - d.d_date > 120 THEN 1 ELSE 0 END) AS over_120_days FROM web_sales ws JOIN date_dim d ON ws.ws_sold_date_sk = d.d_date_sk JOIN date_dim sd ON ws.ws_ship_date_sk = sd.d_date_sk JOIN warehouse w ON ws.ws_warehouse_sk = w.w_warehouse_sk JOIN ship_mode sm ON ws.ws_ship_mode_sk = sm.sm_ship_mode_sk JOIN web_site ws_site ON ws.ws_web_site_sk = ws_site.web_site_sk WHERE d.d_date BETWEEN '2022-01-01' AND '2022-12-31' GROUP BY LEFT(w.w_warehouse_name, 20), sm.sm_type, ws_site.web_name ORDER BY total_shipments DESC LIMIT 100;
