SELECT COUNT(DISTINCT ss_customer_sk) AS unique_customers FROM store_sales JOIN date_dim ON store_sales.ss_sold_date_sk = date_dim.d_date_sk WHERE d_date BETWEEN DATE '2022-01-01' AND DATE '2022-12-31' AND ss_customer_sk NOT IN ( SELECT cs_bill_customer_sk FROM catalog_sales JOIN date_dim ON catalog_sales.cs_sold_date_sk = date_dim.d_date_sk WHERE d_date BETWEEN DATE '2022-01-01' AND DATE '2022-12-31' UNION SELECT ws_bill_customer_sk FROM web_sales JOIN date_dim ON web_sales.ws_sold_date_sk = date_dim.d_date_sk WHERE d_date BETWEEN DATE '2022-01-01' AND DATE '2022-12-31' );
