WITH Sales_CTE AS (
    SELECT
        i_category,
        i_class,
        SUM(ws_net_paid) AS total_sales
    FROM
        web_sales
    JOIN
        item ON web_sales.ws_item_sk = item.i_item_sk
    WHERE
        ws_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_date = '2000-01-01')
        AND (SELECT d_date_sk FROM date_dim WHERE d_date = '2000-12-31')
    GROUP BY
        i_category, i_class
),
Ranked_Sales AS (
    SELECT
        i_category,
        i_class,
        total_sales,
        RANK() OVER (PARTITION BY i_category ORDER BY total_sales DESC) AS sales_rank
    FROM
        Sales_CTE
)
SELECT
    i_category,
    i_class,
    total_sales,
    sales_rank
FROM
    Ranked_Sales
ORDER BY
    i_category,
    sales_rank
LIMIT 100;


