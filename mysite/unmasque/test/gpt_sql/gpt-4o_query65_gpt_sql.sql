SELECT s.store_name,
       i.i_item_desc,
       SUM(ss.ss_ext_sales_price) AS revenue,
       i.i_current_price,
       i.i_wholesale_cost,
       i.i_brand
FROM store_sales ss
JOIN item i ON ss.ss_item_sk = i.i_item_sk
JOIN store s ON ss.ss_store_sk = s.s_store_sk
WHERE ss.ss_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_date = 'YYYY-01-01')
                             AND (SELECT d_date_sk FROM date_dim WHERE d_date = 'YYYY-12-31')
GROUP BY s.store_name, i.i_item_desc, i.i_current_price, i.i_wholesale_cost, i.i_brand
HAVING SUM(ss.ss_ext_sales_price) <= 0.10 * (SELECT AVG(total_revenue)
                                              FROM (SELECT SUM(ss2.ss_ext_sales_price) AS total_revenue
                                                    FROM store_sales ss2
                                                    WHERE ss2.ss_store_sk = ss.ss_store_sk
                                                      AND ss2.ss_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_date = 'YYYY-01-01')
                                                                                 AND (SELECT d_date_sk FROM date_dim WHERE d_date = 'YYYY-12-31')
                                                    GROUP BY ss2.ss_item_sk) AS store_avg_revenue)
ORDER BY s.store_name, i.i_item_desc
LIMIT 100;


