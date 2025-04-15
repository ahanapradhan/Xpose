SELECT i.i_item_id, i.i_product_name, SUM(cs.cs_ext_sales_price) AS total_revenue, SUM(cs.cs_ext_sales_price) / SUM(SUM(cs.cs_ext_sales_price)) OVER (PARTITION BY i.i_class) AS revenue_ratio FROM catalog_sales cs JOIN item i ON cs.cs_item_sk = i.i_item_sk JOIN customer_address ca ON cs.cs_bill_addr_sk = ca.ca_address_sk JOIN date_dim d ON cs.cs_sold_date_sk = d.d_date_sk JOIN call_center cc ON cs.cs_call_center_sk = cc.cc_call_center_sk WHERE ca.ca_zip != cc.cc_zip AND d.d_year = 1998 AND d.d_moy = 11 AND i.i_manager_id = 8 GROUP BY i.i_item_id, i.i_product_name, i.i_class ORDER BY total_revenue DESC;
