SELECT ca.ca_county, AVG(cs.cs_quantity) AS avg_quantity, AVG(cs.cs_list_price) AS avg_list_price, AVG(cs.cs_coupon_amt) AS avg_coupon_amt, AVG(cs.cs_sales_price) AS avg_sales_price, AVG(cs.cs_net_profit) AS avg_net_profit, AVG(d.d_year - c.c_birth_year) AS avg_age, AVG(cd.cd_dep_count) AS avg_dependents FROM catalog_sales cs JOIN customer c ON cs.cs_bill_customer_sk = c.c_customer_sk JOIN customer_address ca ON cs.cs_bill_addr_sk = ca.ca_address_sk JOIN customer_demographics cd ON cs.cs_bill_cdemo_sk = cd.cd_demo_sk JOIN date_dim d ON cs.cs_sold_date_sk = d.d_date_sk WHERE c.c_birth_month IN (1, 6, 8, 9, 12, 2) AND ca.ca_state IN ('MS', 'IN', 'ND', 'OK', 'NM', 'VA', 'MS') AND cd.cd_gender = 'F' AND cd.cd_education_status = 'Unknown' AND d.d_year = 1998 GROUP BY ca.ca_county;
