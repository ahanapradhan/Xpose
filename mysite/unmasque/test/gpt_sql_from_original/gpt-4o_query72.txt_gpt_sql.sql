SELECT cs.cs_item_sk AS item_id, cs.cs_warehouse_sk AS warehouse_id, dd.d_week_seq AS week_id, COUNT(CASE WHEN cs.cs_promo_sk IS NOT NULL THEN 1 END) AS sales_with_promotion, COUNT(CASE WHEN cs.cs_promo_sk IS NULL THEN 1 END) AS sales_without_promotion FROM catalog_sales cs JOIN date_dim dd ON cs.cs_sold_date_sk = dd.d_date_sk GROUP BY cs.cs_item_sk, cs.cs_warehouse_sk, dd.d_week_seq;
