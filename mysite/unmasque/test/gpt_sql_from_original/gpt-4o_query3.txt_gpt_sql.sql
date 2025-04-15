SELECT i.i_brand, SUM(cs.cs_ext_sales_price) AS total_extended_sales_price FROM catalog_sales cs JOIN item i ON cs.cs_item_sk = i.i_item_sk JOIN date_dim d ON cs.cs_sold_date_sk = d.d_date_sk WHERE i.i_manufact_id = <specific_manufacturer_id> AND d.d_year = <specific_year> AND d.d_moy = <specific_month> GROUP BY i.i_brand;
