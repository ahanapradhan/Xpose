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
        item ON store_sales.ss_item_sk = item.i_item_sk
    WHERE
        i_category IN ('Children', 'Women', 'Electronics')
        AND ss_sold_date_sk BETWEEN 
            (SELECT d_date_sk FROM date_dim WHERE d_date = '2001-02-03') AND
            (SELECT d_date_sk FROM date_dim WHERE d_date = '2001-03-05')
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


