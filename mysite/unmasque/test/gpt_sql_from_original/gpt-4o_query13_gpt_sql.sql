SELECT cd.cd_marital_status, cd.cd_education_status, hd.hd_dep_count, ca.ca_state, AVG(ss.ss_quantity) AS avg_sales_quantity, AVG(ss.ss_sales_price) AS avg_sales_price, AVG(ss.ss_wholesale_cost) AS avg_wholesale_cost, SUM(ss.ss_wholesale_cost) AS total_wholesale_cost FROM store_sales ss JOIN customer c ON ss.ss_customer_sk = c.c_customer_sk JOIN customer_demographics cd ON ss.ss_cdemo_sk = cd.cd_demo_sk JOIN household_demographics hd ON ss.ss_hdemo_sk = hd.hd_demo_sk JOIN customer_address ca ON ss.ss_addr_sk = ca.ca_address_sk JOIN date_dim d ON ss.ss_sold_date_sk = d.d_date_sk WHERE d.d_year = 2023 GROUP BY cd.cd_marital_status, cd.cd_education_status, hd.hd_dep_count, ca.ca_state;
