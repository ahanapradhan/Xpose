WITH sales_data AS (
    SELECT
        i_item_id,
        'store' AS channel,
        SUM(ss_ext_sales_price) AS revenue
    FROM
        store_sales
    JOIN
        date_dim ON ss_sold_date_sk = d_date_sk
    WHERE
        d_date BETWEEN '2002-02-25' AND '2002-03-03'
    GROUP BY
        i_item_id

    UNION ALL

    SELECT
        i_item_id,
        'catalog' AS channel,
        SUM(cs_ext_sales_price) AS revenue
    FROM
        catalog_sales
    JOIN
        date_dim ON cs_sold_date_sk = d_date_sk
    WHERE
        d_date BETWEEN '2002-02-25' AND '2002-03-03'
    GROUP BY
        i_item_id

    UNION ALL

    SELECT
        i_item_id,
        'web' AS channel,
        SUM(ws_ext_sales_price) AS revenue
    FROM
        web_sales
    JOIN
        date_dim ON ws_sold_date_sk = d_date_sk
    WHERE
        d_date BETWEEN '2002-02-25' AND '2002-03-03'
    GROUP BY
        i_item_id
),
total_revenue AS (
    SELECT
        i_item_id,
        SUM(revenue) AS total_revenue
    FROM
        sales_data
    GROUP BY
        i_item_id
),
channel_contribution AS (
    SELECT
        sd.i_item_id,
        sd.channel,
        sd.revenue,
        tr.total_revenue,
        (sd.revenue / tr.total_revenue) * 100 AS percentage_contribution
    FROM
        sales_data sd
    JOIN
        total_revenue tr ON sd.i_item_id = tr.i_item_id
),
balanced_items AS (
    SELECT
        i_item_id
    FROM
        channel_contribution
    GROUP BY
        i_item_id
    HAVING
        MAX(percentage_contribution) - MIN(percentage_contribution) <= 10
)
SELECT
    ci.i_item_id,
    SUM(CASE WHEN channel = 'store' THEN revenue ELSE 0 END) AS store_revenue,
    SUM(CASE WHEN channel = 'catalog' THEN revenue ELSE 0 END) AS catalog_revenue,
    SUM(CASE WHEN channel = 'web' THEN revenue ELSE 0 END) AS web_revenue
FROM
    channel_contribution ci
JOIN
    balanced_items bi ON ci.i_item_id = bi.i_item_id
GROUP BY
    ci.i_item_id
ORDER BY
    store_revenue DESC,
    ci.i_item_id
LIMIT 100;


