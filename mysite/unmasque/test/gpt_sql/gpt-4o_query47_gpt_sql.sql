WITH MonthlySales AS (
    SELECT
        s_store_id,
        i_category,
        i_brand,
        d_year,
        d_moy,
        SUM(ss_sales_price) AS total_sales,
        AVG(SUM(ss_sales_price)) OVER (PARTITION BY s_store_id, i_category, i_brand, d_year) AS avg_monthly_sales
    FROM
        store_sales
    JOIN
        item ON ss_item_sk = i_item_sk
    JOIN
        date_dim ON ss_sold_date_sk = d_date_sk
    WHERE
        d_year = 1999
    GROUP BY
        s_store_id, i_category, i_brand, d_year, d_moy
),
SalesDeviation AS (
    SELECT
        s_store_id,
        i_category,
        i_brand,
        d_year,
        d_moy,
        total_sales,
        avg_monthly_sales,
        LAG(total_sales) OVER (PARTITION BY s_store_id, i_category, i_brand, d_year ORDER BY d_moy) AS prev_month_sales,
        LEAD(total_sales) OVER (PARTITION BY s_store_id, i_category, i_brand, d_year ORDER BY d_moy) AS next_month_sales
    FROM
        MonthlySales
),
SignificantFluctuations AS (
    SELECT
        s_store_id,
        i_category,
        i_brand,
        d_year,
        d_moy,
        total_sales,
        avg_monthly_sales,
        prev_month_sales,
        next_month_sales,
        ABS(total_sales - avg_monthly_sales) / avg_monthly_sales AS deviation
    FROM
        SalesDeviation
    WHERE
        (ABS(total_sales - avg_monthly_sales) / avg_monthly_sales > 0.10)
        OR (prev_month_sales IS NOT NULL AND ABS(prev_month_sales - avg_monthly_sales) / avg_monthly_sales > 0.10)
        OR (next_month_sales IS NOT NULL AND ABS(next_month_sales - avg_monthly_sales) / avg_monthly_sales > 0.10)
)
SELECT
    s_store_id,
    i_category,
    i_brand,
    d_year,
    d_moy,
    total_sales,
    avg_monthly_sales,
    deviation
FROM
    SignificantFluctuations
ORDER BY
    deviation DESC
FETCH FIRST 100 ROWS ONLY;


