SELECT cd.cd_marital_status, cd.cd_education_status, ca.ca_state, ws.ws_net_profit, AVG(ws.ws_sales_price) AS avg_sales, AVG(wr.wr_refunded_cash) AS avg_refunded_cash, AVG(wr.wr_fee) AS avg_return_fee FROM web_returns wr JOIN web_sales ws ON wr.wr_order_number = ws.ws_order_number JOIN customer_demographics cd ON wr.wr_refunded_cdemo_sk = cd.cd_demo_sk JOIN customer_address ca ON wr.wr_refunded_addr_sk = ca.ca_address_sk JOIN date_dim dd ON ws.ws_sold_date_sk = dd.d_date_sk WHERE dd.d_year = 2000 AND ca.ca_state IN ('IN', 'OH', 'NJ', 'WI', 'CT', 'KY', 'LA', 'IA', 'AR') AND cd.cd_education_status IN ('Advanced Degree', 'College', '2 yr Degree') AND cd.cd_marital_status IN ('M', 'S', 'W') GROUP BY cd.cd_marital_status, cd.cd_education_status, ca.ca_state, ws.ws_net_profit;
