WITH ItemRevenue AS (
    SELECT
        i_item_id,
        i_item_desc,
        i_category,
        i_class,
        i_current_price,
        SUM(ss_ext_sales_price) AS total_revenue
    FROM
        store_sales
    JOIN
        item ON ss_item_sk = i_item_sk
    JOIN
        date_dim ON ss_sold_date_sk = d_date_sk
    WHERE
        i_category IN ('Home', 'Men', 'Women')
        AND d_date BETWEEN '2000-05-11' AND '2000-06-09'
    GROUP BY
        i_item_id, i_item_desc, i_category, i_class, i_current_price
),
ClassRevenue AS (
    SELECT
        i_class,
        SUM(total_revenue) AS class_total_revenue
    FROM
        ItemRevenue
    GROUP BY
        i_class
)
SELECT
    ir.i_item_id,
    ir.i_item_desc,
    ir.i_category,
    ir.i_class,
    ir.i_current_price,
    ir.total_revenue,
    (ir.total_revenue / cr.class_total_revenue) AS revenue_ratio
FROM
    ItemRevenue ir
JOIN
    ClassRevenue cr ON ir.i_class = cr.i_class
ORDER BY
    ir.i_category,
    ir.i_class,
    ir.i_item_id,
    ir.i_item_desc,
    revenue_ratio DESC
LIMIT 100;


