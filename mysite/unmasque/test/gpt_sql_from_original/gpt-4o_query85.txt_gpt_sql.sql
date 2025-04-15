SELECT cd.cd_marital_status, cd.cd_education_status, ca.ca_state, AVG(ws.ws_net_profit) AS avg_net_profit, AVG(ws.ws_sales_price) AS avg_sales, AVG(wr.wr_refunded_cash) AS avg_refunded_cash, AVG(wr.wr_fee) AS avg_return_fee FROM web_returns wr JOIN web_sales ws ON wr.wr_order_number = ws.ws_order_number JOIN customer_demographics cd ON wr.wr_refunded_cdemo_sk = cd.cd_demo_sk JOIN customer_address ca ON wr.wr_refunded_addr_sk = ca.ca_address_sk GROUP BY cd.cd_marital_status, cd.cd_education_status, ca.ca_state;
