SELECT i.i_item_id, SUM(cs.cs_sales_price) AS total_sales FROM catalog_sales cs JOIN item i ON cs.cs_item_sk = i.i_item_sk JOIN customer c ON cs.cs_bill_customer_sk = c.c_customer_sk JOIN customer_address ca ON c.c_current_addr_sk = ca.ca_address_sk JOIN date_dim d ON cs.cs_sold_date_sk = d.d_date_sk WHERE i.i_category = 'specific_category' AND ca.ca_gmt_offset = -5.00 AND d.d_month_seq = (SELECT d_month_seq FROM date_dim WHERE d_year = 2023 AND d_moy = 5) GROUP BY i.i_item_id ORDER BY total_sales DESC;
