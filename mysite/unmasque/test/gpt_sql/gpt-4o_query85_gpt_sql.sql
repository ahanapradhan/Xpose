SELECT r.r_reason_desc, AVG(ws.ws_quantity) AS avg_sales_quantity, AVG(wr.wr_refunded_cash) AS avg_refunded_cash, AVG(wr.wr_fee) AS avg_fee FROM web_sales ws JOIN web_returns wr ON ws.ws_order_number = wr.wr_order_number JOIN customer c ON ws.ws_bill_customer_sk = c.c_customer_sk JOIN customer_demographics cd ON c.c_current_cdemo_sk = cd.cd_demo_sk JOIN customer_address ca ON c.c_current_addr_sk = ca.ca_address_sk JOIN date_dim d ON ws.ws_sold_date_sk = d.d_date_sk JOIN reason r ON wr.wr_reason_sk = r.r_reason_sk WHERE d.d_year = 2001 AND cd.cd_marital_status IN ('W', 'D', 'M') AND cd.cd_education_status IN ('Primary', 'Secondary', 'College', 'Graduate') AND ws.ws_sales_price BETWEEN 100 AND 1000 AND ca.ca_state IN ('CA', 'NY', 'TX', 'FL', 'IL') AND ws.ws_net_profit BETWEEN 1000 AND 5000 GROUP BY r.r_reason_desc ORDER BY COUNT(wr.wr_reason_sk) DESC LIMIT 100;
