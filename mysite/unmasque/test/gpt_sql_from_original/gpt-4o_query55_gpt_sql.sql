SELECT SUM(ss_net_paid) AS total_store_sales FROM store_sales JOIN date_dim ON store_sales.ss_sold_date_sk = date_dim.d_date_sk JOIN store ON store_sales.ss_store_sk = store.s_store_sk WHERE date_dim.d_year = 1999 AND date_dim.d_moy = 11 AND store.s_manager = '28';
