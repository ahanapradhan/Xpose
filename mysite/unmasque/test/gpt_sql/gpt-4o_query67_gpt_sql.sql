SELECT i.i_category, i.i_class, i.i_brand, i.i_product_name, d.d_year, d.d_quarter_name, d.d_moy AS d_month,
s.s_store_name, SUM(ss.ss_sales_price * ss.ss_quantity) AS total_sales
FROM store_sales ss JOIN item i ON ss.ss_item_sk = i.i_item_sk
JOIN date_dim d ON ss.ss_sold_date_sk = d.d_date_sk
JOIN store s ON ss.ss_store_sk = s.s_store_sk
WHERE d.d_year = ? -- specify the year
GROUP BY i.i_category, i.i_class, i.i_brand, i.i_product_name, d.d_year, d.d_quarter_name, d.d_moy, s.s_store_name
QUALIFY ROW_NUMBER() OVER (PARTITION BY i.i_category ORDER BY total_sales DESC) <= 100 ORDER BY i.i_category, total_sales DESC;
