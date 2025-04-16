SELECT i.i_manufact_id AS ManufacturerID, SUM(cs.cs_ext_sales_price) / 4 AS QuarterlySales, SUM(cs.cs_ext_sales_price) AS YearlySales FROM item i JOIN catalog_sales cs ON i.i_item_sk = cs.cs_item_sk JOIN date_dim d ON cs.cs_sold_date_sk = d.d_date_sk WHERE i.i_class = 'specific characteristics' GROUP BY i.i_manufact_id HAVING AVG(cs.cs_ext_sales_price) > 0.1 * SUM(cs.cs_ext_sales_price) / 12;
