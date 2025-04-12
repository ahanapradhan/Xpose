WITH Sales_CTE AS (
    SELECT
        p.product_category,
        p.product_class,
        p.product_brand,
        p.product_name,
        s.store_id,
        t.year,
        t.quarter,
        t.month,
        SUM(ss.sales_price * ss.quantity_sold) AS total_sales,
        ROW_NUMBER() OVER (PARTITION BY p.product_category ORDER BY SUM(ss.sales_price * ss.quantity_sold) DESC) AS sales_rank
    FROM
        store_sales ss
    JOIN
        product p ON ss.product_id = p.product_id
    JOIN
        time_dim t ON ss.time_id = t.time_id
    WHERE
        t.year = <specified_year>
    GROUP BY
        p.product_category,
        p.product_class,
        p.product_brand,
        p.product_name,
        s.store_id,
        t.year,
        t.quarter,
        t.month
)
SELECT
    product_category,
    product_class,
    product_brand,
    product_name,
    store_id,
    year,
    quarter,
    month,
    total_sales
FROM
    Sales_CTE
WHERE
    sales_rank <= 100
ORDER BY
    product_category,
    sales_rank;
Replace `<specified_year>` with the desired year for analysis.


