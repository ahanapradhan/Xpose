SELECT i.i_item_id, i.i_item_desc, i.i_category, i.i_class, i.i_current_price, SUM(cs.cs_ext_sales_price) AS total_revenue, SUM(cs.cs_ext_sales_price) / SUM(SUM(cs.cs_ext_sales_price)) OVER (PARTITION BY i.i_class) AS revenue_ratio FROM catalog_sales cs JOIN item i ON cs.cs_item_sk = i.i_item_sk JOIN date_dim d ON cs.cs_sold_date_sk = d.d_date_sk WHERE i.i_category IN ('Children', 'Women', 'Electronics') AND d.d_date BETWEEN '2001-02-03' AND '2001-03-05' GROUP BY i.i_item_id, i.i_item_desc, i.i_category, i.i_class, i.i_current_price ORDER BY i.i_category, i.i_class, i.i_item_id, i.i_item_desc, revenue_ratio DESC LIMIT 100;
