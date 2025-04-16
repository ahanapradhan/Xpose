SELECT w.w_warehouse_id, cc.cc_call_center_id, sm.sm_ship_mode_id, SUM(CASE WHEN d.d_date - sd.d_date <= 30 THEN 1 ELSE 0 END) AS "0-30 Days", SUM(CASE WHEN d.d_date - sd.d_date BETWEEN 31 AND 60 THEN 1 ELSE 0 END) AS "31-60 Days", SUM(CASE WHEN d.d_date - sd.d_date BETWEEN 61 AND 90 THEN 1 ELSE 0 END) AS "61-90 Days", SUM(CASE WHEN d.d_date - sd.d_date BETWEEN 91 AND 120 THEN 1 ELSE 0 END) AS "91-120 Days", SUM(CASE WHEN d.d_date - sd.d_date > 120 THEN 1 ELSE 0 END) AS "Over 120 Days" FROM catalog_sales cs JOIN date_dim d ON cs.cs_ship_date_sk = d.d_date_sk JOIN date_dim sd ON cs.cs_sold_date_sk = sd.d_date_sk JOIN warehouse w ON cs.cs_warehouse_sk = w.w_warehouse_sk JOIN call_center cc ON cs.cs_call_center_sk = cc.cc_call_center_sk JOIN ship_mode sm ON cs.cs_ship_mode_sk = sm.sm_ship_mode_sk WHERE d.d_year = 2023 GROUP BY w.w_warehouse_id, cc.cc_call_center_id, sm.sm_ship_mode_id;
