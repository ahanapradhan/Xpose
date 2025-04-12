WITH sales_data AS (
    SELECT
        w_state,
        i_item_id,
        SUM(CASE WHEN d_date < '2002-06-01' THEN (ss_sales_price - COALESCE(sr_refunded_cash, 0)) ELSE 0 END) AS sales_before,
        SUM(CASE WHEN d_date >= '2002-06-01' THEN (ss_sales_price - COALESCE(sr_refunded_cash, 0)) ELSE 0 END) AS sales_after
    FROM
        store_sales
    JOIN
        date_dim ON ss_sold_date_sk = d_date_sk
    JOIN
        item ON ss_item_sk = i_item_sk
    JOIN
        warehouse ON ss_warehouse_sk = w_warehouse_sk
    LEFT JOIN
        store_returns ON ss_ticket_number = sr_ticket_number AND ss_item_sk = sr_item_sk
    WHERE
        i_current_price BETWEEN 0.99 AND 1.49
        AND d_date BETWEEN '2002-04-02' AND '2002-07-31'
    GROUP BY
        w_state, i_item_id
)
SELECT
    w_state,
    i_item_id,
    sales_before,
    sales_after
FROM
    sales_data
ORDER BY
    w_state,
    i_item_id
LIMIT 100;


