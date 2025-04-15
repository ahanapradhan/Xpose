WITH ItemSales AS ( SELECT i.i_item_id, i.i_class, SUM(ws.ws_ext_sales_price) AS total_sales FROM web_sales ws JOIN item i ON ws.ws_item_sk = i.i_item_sk JOIN date_dim d ON ws.ws_sold_date_sk = d.d_date_sk WHERE i.i_category IN ('Sports', 'Books', 'Home') AND d.d_date BETWEEN '1999-02-22' AND '1999-03-23' GROUP BY i.i_item_id, i.i_class ), ClassSales AS ( SELECT i_class, SUM(total_sales) AS class_total_sales FROM ItemSales GROUP BY i_class ) SELECT isales.i_item_id, isales.i_class, isales.total_sales / cs.class_total_sales AS revenue_ratio FROM ItemSales isales JOIN ClassSales cs ON isales.i_class = cs.i_class;
