SELECT i.i_brand, i.i_class, i.i_category, d1.d_year AS year1, SUM(ss1.ss_ext_sales_price) AS sales_year1, d2.d_year AS year2, SUM(ss2.ss_ext_sales_price) AS sales_year2 FROM store_sales ss1 JOIN date_dim d1 ON ss1.ss_sold_date_sk = d1.d_date_sk JOIN store_sales ss2 ON ss1.ss_item_sk = ss2.ss_item_sk JOIN date_dim d2 ON ss2.ss_sold_date_sk = d2.d_date_sk JOIN item i ON ss1.ss_item_sk = i.i_item_sk WHERE d1.d_year = d2.d_year - 1 GROUP BY i.i_brand, i.i_class, i.i_category, d1.d_year, d2.d_year ORDER BY i.i_brand, i.i_class, i.i_category, d1.d_year;
