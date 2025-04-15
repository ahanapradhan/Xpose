SELECT s_state, SUM(ss_net_profit) AS total_net_profit FROM store_sales JOIN date_dim ON store_sales.ss_sold_date_sk = date_dim.d_date_sk JOIN store ON store_sales.ss_store_sk = store.s_store_sk WHERE date_dim.d_year = ? -- replace ? with the desired year GROUP BY s_state ORDER BY total_net_profit DESC LIMIT 5;
