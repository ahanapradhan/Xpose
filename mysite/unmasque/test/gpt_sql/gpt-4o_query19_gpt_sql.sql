SELECT i_brand, i_manufact, SUM(cs_ext_sales_price) AS total_sales_revenue FROM catalog_sales JOIN date_dim ON cs_sold_date_sk = d_date_sk JOIN customer_address ca1 ON cs_bill_addr_sk = ca1.ca_address_sk JOIN customer_address ca2 ON cs_ship_addr_sk = ca2.ca_address_sk JOIN item ON cs_item_sk = i_item_sk WHERE d_year = 1998 AND d_moy = 12 AND i_manager_id = 38 AND LEFT(ca1.ca_zip, 3) <> LEFT(ca2.ca_zip, 3) GROUP BY i_brand, i_manufact ORDER BY total_sales_revenue DESC LIMIT 100;
