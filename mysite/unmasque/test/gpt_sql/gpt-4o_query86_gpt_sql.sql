SELECT i.i_category, i.i_class, SUM(ws.ws_net_paid) AS total_sales, RANK() OVER (PARTITION BY i.i_category ORDER BY SUM(ws.ws_net_paid) DESC) AS sales_rank FROM web_sales ws JOIN item i ON ws.ws_item_sk = i.i_item_sk JOIN date_dim d ON ws.ws_sold_date_sk = d.d_date_sk WHERE d.d_date BETWEEN DATE '2022-01-01' AND DATE '2022-12-31' GROUP BY i.i_category, i.i_class ORDER BY i.i_category, sales_rank FETCH FIRST 100 ROWS ONLY;
