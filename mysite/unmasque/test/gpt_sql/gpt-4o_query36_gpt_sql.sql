WITH sales_data AS (
    SELECT
        i_category,
        i_class,
        SUM(ss_ext_sales_price) AS total_sales,
        SUM(ss_net_profit) AS total_profit
    FROM
        store_sales
    JOIN
        date_dim ON store_sales.ss_sold_date_sk = date_dim.d_date_sk
    JOIN
        store ON store_sales.ss_store_sk = store.s_store_sk
    JOIN
        item ON store_sales.ss_item_sk = item.i_item_sk
    WHERE
        d_year = 2000
        AND s_state = 'TN'
    GROUP BY
        ROLLUP(i_category, i_class)
),
ranked_data AS (
    SELECT
        i_category,
        i_class,
        total_sales,
        total_profit,
        CASE WHEN total_sales > 0 THEN total_profit / total_sales ELSE 0 END AS gross_margin,
        RANK() OVER (PARTITION BY i_category, i_class ORDER BY CASE WHEN total_sales > 0 THEN total_profit / total_sales ELSE 0 END DESC) AS margin_rank
    FROM
        sales_data
)
SELECT
    i_category,
    i_class,
    total_sales,
    total_profit,
    gross_margin,
    margin_rank
FROM
    ranked_data
ORDER BY
    i_category NULLS FIRST,
    i_class NULLS FIRST,
    margin_rank
FETCH FIRST 100 ROWS ONLY;


