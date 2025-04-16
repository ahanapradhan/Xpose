SELECT s.s_store_id, i.i_category, SUM(ss.ss_net_paid) AS total_sales FROM store_sales ss JOIN store s ON ss.ss_store_sk = s.s_store_sk JOIN item i ON ss.ss_item_sk = i.i_item_sk JOIN date_dim d ON ss.ss_sold_date_sk = d.d_date_sk WHERE d.d_year = 2022 GROUP BY s.s_store_id, i.i_category HAVING SUM(ss.ss_net_paid) = ( SELECT MAX(total_sales) FROM ( SELECT s_inner.s_store_id, i_inner.i_category, SUM(ss_inner.ss_net_paid) AS total_sales FROM store_sales ss_inner JOIN store s_inner ON ss_inner.ss_store_sk = s_inner.s_store_sk JOIN item i_inner ON ss_inner.ss_item_sk = i_inner.i_item_sk JOIN date_dim d_inner ON ss_inner.ss_sold_date_sk = d_inner.d_date_sk WHERE d_inner.d_year = 2022 GROUP BY s_inner.s_store_id, i_inner.i_category ) AS category_sales WHERE category_sales.i_category = i.i_category ) ORDER BY i.i_category, total_sales DESC;
