SELECT COUNT(DISTINCT cs.cs_bill_customer_sk) AS customer_count FROM catalog_sales cs JOIN web_sales ws ON cs.cs_bill_customer_sk = ws.ws_bill_customer_sk AND cs.cs_sold_date_sk = ws.ws_sold_date_sk JOIN store_sales ss ON cs.cs_bill_customer_sk = ss.ss_customer_sk AND cs.cs_sold_date_sk = ss.ss_sold_date_sk JOIN date_dim dd ON cs.cs_sold_date_sk = dd.d_date_sk WHERE dd.d_month_seq = 1200;
