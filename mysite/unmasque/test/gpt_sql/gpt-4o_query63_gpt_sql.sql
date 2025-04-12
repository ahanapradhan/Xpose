WITH CategorySales AS (
    SELECT
        s_manager_id,
        p_category,
        p_class,
        p_brand,
        EXTRACT(YEAR FROM d_date) AS sales_year,
        EXTRACT(MONTH FROM d_date) AS sales_month,
        SUM(ss_sales_price) AS total_monthly_sales,
        AVG(SUM(ss_sales_price)) OVER (PARTITION BY s_manager_id, p_category, p_class, p_brand, EXTRACT(YEAR FROM d_date)) AS avg_monthly_sales
    FROM
        store_sales
    JOIN
        date_dim ON ss_sold_date_sk = d_date_sk
    JOIN
        item ON ss_item_sk = i_item_sk
    WHERE
        p_category IN ('Books', 'Children', 'Electronics', 'Women', 'Music', 'Men')
        AND d_date BETWEEN DATE '2022-01-01' AND DATE '2022-12-31'
    GROUP BY
        s_manager_id, p_category, p_class, p_brand, EXTRACT(YEAR FROM d_date), EXTRACT(MONTH FROM d_date)
),
DeviatedManagers AS (
    SELECT
        s_manager_id,
        p_category,
        p_class,
        p_brand,
        sales_year,
        sales_month,
        total_monthly_sales,
        avg_monthly_sales,
        ABS(total_monthly_sales - avg_monthly_sales) / avg_monthly_sales AS deviation
    FROM
        CategorySales
    WHERE
        ABS(total_monthly_sales - avg_monthly_sales) / avg_monthly_sales > 0.10
)
SELECT
    s_manager_id,
    p_category,
    p_class,
    p_brand,
    sales_year,
    sales_month,
    total_monthly_sales,
    avg_monthly_sales,
    deviation
FROM
    DeviatedManagers
ORDER BY
    s_manager_id,
    avg_monthly_sales DESC,
    total_monthly_sales DESC
LIMIT 100;


