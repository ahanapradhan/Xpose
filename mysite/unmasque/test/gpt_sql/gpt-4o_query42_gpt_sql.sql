SELECT i_category, SUM(ss_ext_sales_price) AS total_sales
FROM store_sales
JOIN item ON store_sales.ss_item_sk = item.i_item_sk
JOIN store ON store_sales.ss_store_sk = store.s_store_sk
JOIN customer_demographics ON store_sales.ss_cdemo_sk = customer_demographics.cd_demo_sk
WHERE store.s_manager = 1
  AND ss_sold_date_sk IN (
    SELECT d_date_sk
    FROM date_dim
    WHERE d_year = 2000 AND d_moy = 12
  )
GROUP BY i_category
ORDER BY total_sales DESC
LIMIT 100;


