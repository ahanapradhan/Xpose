SELECT COUNT(CASE WHEN ws_promo_sk IS NOT NULL THEN 1 END) AS promotional_sales_count, COUNT(*) AS total_sales_count, COUNT(CASE WHEN ws_promo_sk IS NOT NULL THEN 1 END) / NULLIF(COUNT(*), 0) AS promo_to_total_ratio FROM web_sales JOIN item ON ws_item_sk = i_item_sk JOIN date_dim ON ws_sold_date_sk = d_date_sk JOIN customer_address ON ws_bill_addr_sk = ca_address_sk WHERE i_category = 'Electronics' -- Example category AND d_month_seq = 202309 -- Example month (September 2023) AND ca_gmt_offset = -5.00; -- Example time zone (EST)
