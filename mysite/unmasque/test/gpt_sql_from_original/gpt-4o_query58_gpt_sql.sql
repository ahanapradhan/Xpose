SELECT i.i_item_id, i.i_item_desc, SUM(ss.ss_net_paid) AS store_revenue, SUM(cs.cs_net_paid) AS catalog_revenue, SUM(ws.ws_net_paid) AS web_revenue FROM item i JOIN store_sales ss ON i.i_item_sk = ss.ss_item_sk JOIN catalog_sales cs ON i.i_item_sk = cs.cs_item_sk JOIN web_sales ws ON i.i_item_sk = ws.ws_item_sk JOIN date_dim d ON ss.ss_sold_date_sk = d.d_date_sk AND cs.cs_sold_date_sk = d.d_date_sk AND ws.ws_sold_date_sk = d.d_date_sk WHERE d.d_week_seq = (SELECT d_week_seq FROM date_dim WHERE d_date = '2023-10-07') GROUP BY i.i_item_id, i.i_item_desc HAVING ABS(SUM(ss.ss_net_paid) - SUM(cs.cs_net_paid)) < 100 AND ABS(SUM(cs.cs_net_paid) - SUM(ws.ws_net_paid)) < 100 AND ABS(SUM(ws.ws_net_paid) - SUM(ss.ss_net_paid)) < 100 ORDER BY (SUM(ss.ss_net_paid) + SUM(cs.cs_net_paid) + SUM(ws.ws_net_paid)) DESC LIMIT 10;
