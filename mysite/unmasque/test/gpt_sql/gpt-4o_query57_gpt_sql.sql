WITH sales_data AS (
    SELECT
        pc.product_category,
        pb.product_brand,
        cc.call_center_id,
        s.sales_month,
        s.sales_year,
        SUM(s.sales_amount) AS total_sales,
        AVG(s.sales_amount) OVER (PARTITION BY pc.product_category, pb.product_brand, cc.call_center_id, s.sales_year) AS avg_monthly_sales
    FROM
        sales s
    JOIN
        product p ON s.product_id = p.product_id
    JOIN
        product_category pc ON p.product_category_id = pc.product_category_id
    JOIN
        product_brand pb ON p.product_brand_id = pb.product_brand_id
    JOIN
        call_center cc ON s.call_center_id = cc.call_center_id
    WHERE
        s.sales_year = 2000
    GROUP BY
        pc.product_category, pb.product_brand, cc.call_center_id, s.sales_month, s.sales_year
),
ranked_sales AS (
    SELECT
        sd.*,
        LAG(sd.total_sales) OVER (PARTITION BY sd.product_category, sd.product_brand, sd.call_center_id ORDER BY sd.sales_year, sd.sales_month) AS prev_month_sales,
        LEAD(sd.total_sales) OVER (PARTITION BY sd.product_category, sd.product_brand, sd.call_center_id ORDER BY sd.sales_year, sd.sales_month) AS next_month_sales
    FROM
        sales_data sd
),
deviation_analysis AS (
    SELECT
        rs.*,
        (rs.total_sales - rs.avg_monthly_sales) / rs.avg_monthly_sales * 100 AS sales_deviation
    FROM
        ranked_sales rs
    WHERE
        rs.avg_monthly_sales > 0
)
SELECT
    product_category,
    product_brand,
    call_center_id,
    sales_month,
    sales_year,
    total_sales,
    avg_monthly_sales,
    sales_deviation
FROM
    deviation_analysis
WHERE
    ABS(sales_deviation) > 10
ORDER BY
    ABS(sales_deviation) DESC
LIMIT 100;


