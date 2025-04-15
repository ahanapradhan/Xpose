SELECT cs.cs_order_number, cs.cs_item_sk, cs.cs_ext_discount_amt, (cs.cs_ext_discount_amt - 1.3 * avg_discount.avg_discount) AS excess_discount FROM catalog_sales cs JOIN item i ON cs.cs_item_sk = i.i_item_sk JOIN date_dim dd ON cs.cs_sold_date_sk = dd.d_date_sk JOIN ( SELECT cs_item_sk, AVG(cs_ext_discount_amt) AS avg_discount FROM catalog_sales JOIN date_dim ON catalog_sales.cs_sold_date_sk = date_dim.d_date_sk WHERE date_dim.d_date BETWEEN '2001-03-04' AND '2001-06-02' GROUP BY cs_item_sk ) avg_discount ON cs.cs_item_sk = avg_discount.cs_item_sk WHERE i.i_manufact_id = 610 AND dd.d_date BETWEEN '2001-03-04' AND '2001-06-02' AND cs.cs_ext_discount_amt > 1.3 * avg_discount.avg_discount ORDER BY excess_discount DESC LIMIT 100;
