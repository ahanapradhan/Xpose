WITH item_revenue AS (
  SELECT
    i_item_id,
    i_item_desc,
    i_category,
    i_class,
    i_current_price,
    SUM(ss_ext_sales_price) AS itemrevenue
  FROM
    store_sales
  JOIN item ON ss_item_sk = i_item_sk
  JOIN date_dim ON ss_sold_date_sk = d_date_sk
  WHERE
    i_category IN ('Men', 'Home', 'Electronics')
    AND d_date BETWEEN DATE '2000-05-18' AND DATE '2000-05-18' + INTERVAL '30 days'
  GROUP BY
    i_item_id, i_item_desc, i_category, i_class, i_current_price
)

SELECT
  *,
  itemrevenue * 100.0 / SUM(itemrevenue) OVER (PARTITION BY i_class) AS revenueratio
FROM
  item_revenue
ORDER BY
  i_category, i_class, i_item_id, i_item_desc, revenueratio;
