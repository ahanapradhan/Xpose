SELECT c.c_customer_id FROM customer c JOIN store_sales ss1 ON c.c_customer_sk = ss1.ss_customer_sk JOIN store_sales ss2 ON c.c_customer_sk = ss2.ss_customer_sk JOIN web_sales ws1 ON c.c_customer_sk = ws1.ws_bill_customer_sk JOIN web_sales ws2 ON c.c_customer_sk = ws2.ws_bill_customer_sk JOIN date_dim d1 ON ss1.ss_sold_date_sk = d1.d_date_sk JOIN date_dim d2 ON ss2.ss_sold_date_sk = d2.d_date_sk JOIN date_dim d3 ON ws1.ws_sold_date_sk = d3.d_date_sk JOIN date_dim d4 ON ws2.ws_sold_date_sk = d4.d_date_sk WHERE d1.d_year = 2001 AND d2.d_year = 2002 AND d3.d_year = 2001 AND d4.d_year = 2002 GROUP BY c.c_customer_id HAVING SUM(ws2.ws_net_paid) - SUM(ws1.ws_net_paid) > SUM(ss2.ss_net_paid) - SUM(ss1.ss_net_paid);
