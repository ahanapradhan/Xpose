WITH SalesData AS (
    SELECT
        i_manufact_id,
        i_category,
        i_class,
        i_brand,
        SUM(ss_sales_price) AS total_sales,
        AVG(SUM(ss_sales_price)) OVER (PARTITION BY i_manufact_id, i_category, i_class, i_brand, CEIL(d_date/91)) AS avg_quarterly_sales
    FROM
        store_sales
    JOIN
        item ON store_sales.ss_item_sk = item.i_item_sk
    JOIN
        date_dim ON store_sales.ss_sold_date_sk = date_dim.d_date_sk
    WHERE
        i_category IN ('Books', 'Children', 'Electronics', 'Women', 'Music', 'Men')
        AND d_year = 2001
    GROUP BY
        i_manufact_id, i_category, i_class, i_brand, CEIL(d_date/91)
),
FilteredSales AS (
    SELECT
        i_manufact_id,
        i_category,
        i_class,
        i_brand,
        total_sales,
        avg_quarterly_sales
    FROM
        SalesData
    WHERE
        ABS(total_sales - avg_quarterly_sales) / avg_quarterly_sales > 0.10
)
SELECT
    i_manufact_id,
    i_category,
    i_class,
    i_brand,
    total_sales,
    avg_quarterly_sales
FROM
    FilteredSales
ORDER BY
    avg_quarterly_sales DESC,
    total_sales DESC,
    i_manufact_id
FETCH FIRST 100 ROWS ONLY;


