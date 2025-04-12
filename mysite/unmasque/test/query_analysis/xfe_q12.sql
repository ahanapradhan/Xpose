SELECT
    i_item_id,
    i_item_desc,
    i_category,
    i_class,
    i_current_price,
    SUM(ws_ext_sales_price) AS item_revenue,
    ROUND(
        100.0 * SUM(ws_ext_sales_price) /
        SUM(SUM(ws_ext_sales_price)) OVER (PARTITION BY i_category),
        2
    ) AS revenue_ratio_percent
FROM
    date_dim
JOIN
    web_sales ON date_dim.d_date_sk = web_sales.ws_sold_date_sk
JOIN
    item ON item.i_item_sk = web_sales.ws_item_sk
WHERE
    item.i_category IN ('Home', 'Men', 'Women')
    AND date_dim.d_date BETWEEN '2000-05-11' AND '2000-06-10'
GROUP BY
    i_item_id, i_item_desc, i_category, i_class, i_current_price
ORDER BY
    i_category ASC, i_class ASC, i_item_id ASC, i_item_desc ASC, item_revenue ASC, i_current_price ASC
LIMIT 100;
