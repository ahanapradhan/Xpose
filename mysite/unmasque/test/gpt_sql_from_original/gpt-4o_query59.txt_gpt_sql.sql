SELECT s.s_store_id, d.d_day_name, (SUM(CASE WHEN d.d_year = EXTRACT(YEAR FROM CURRENT_DATE) THEN ss.ss_net_paid ELSE 0 END) - SUM(CASE WHEN d.d_year = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN ss.ss_net_paid ELSE 0 END)) AS sales_increase FROM store_sales ss JOIN date_dim d ON ss.ss_sold_date_sk = d.d_date_sk JOIN store s ON ss.ss_store_sk = s.s_store_sk WHERE d.d_year IN (EXTRACT(YEAR FROM CURRENT_DATE), EXTRACT(YEAR FROM CURRENT_DATE) - 1) GROUP BY s.s_store_id, d.d_day_name, d.d_week_seq HAVING SUM(CASE WHEN d.d_year = EXTRACT(YEAR FROM CURRENT_DATE) THEN ss.ss_net_paid ELSE 0 END) > 0 AND SUM(CASE WHEN d.d_year = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN ss.ss_net_paid ELSE 0 END) > 0 ORDER BY s.s_store_id, d.d_day_name;
