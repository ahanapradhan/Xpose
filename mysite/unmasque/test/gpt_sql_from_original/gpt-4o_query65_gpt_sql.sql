SELECT s.s_store_id, i.i_item_id, SUM(ss.ss_net_paid) AS item_revenue FROM store_sales ss JOIN store s ON ss.ss_store_sk = s.s_store_sk JOIN item i ON ss.ss_item_sk = i.i_item_sk GROUP BY s.s_store_id, i.i_item_id HAVING SUM(ss.ss_net_paid) < 0.1 * ( SELECT AVG(store_revenue) FROM ( SELECT ss_inner.ss_store_sk, SUM(ss_inner.ss_net_paid) AS store_revenue FROM store_sales ss_inner GROUP BY ss_inner.ss_store_sk ) AS store_avg_revenue WHERE store_avg_revenue.ss_store_sk = s.s_store_sk ) ORDER BY s.s_store_id, i.i_item_id;
