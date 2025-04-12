WITH InventoryStats AS (
    SELECT
        inv_warehouse_sk,
        inv_item_sk,
        EXTRACT(YEAR FROM d_date) AS year,
        EXTRACT(MONTH FROM d_date) AS month,
        AVG(inv_quantity_on_hand) AS mean_quantity,
        STDDEV(inv_quantity_on_hand) AS stddev_quantity
    FROM
        inventory
    JOIN
        date_dim ON inv_date_sk = d_date_sk
    WHERE
        EXTRACT(YEAR FROM d_date) = 2002
    GROUP BY
        inv_warehouse_sk, inv_item_sk, EXTRACT(YEAR FROM d_date), EXTRACT(MONTH FROM d_date)
),
COVStats AS (
    SELECT
        inv_warehouse_sk,
        inv_item_sk,
        month,
        stddev_quantity / NULLIF(mean_quantity, 0) AS cov
    FROM
        InventoryStats
),
HighCOVItems AS (
    SELECT
        a.inv_warehouse_sk,
        a.inv_item_sk,
        a.month AS month_a,
        b.month AS month_b,
        a.cov AS cov_a,
        b.cov AS cov_b
    FROM
        COVStats a
    JOIN
        COVStats b ON a.inv_warehouse_sk = b.inv_warehouse_sk
        AND a.inv_item_sk = b.inv_item_sk
        AND a.month = b.month - 1
    WHERE
        a.cov > 1 AND b.cov > 1
),
FilteredHighCOVItems AS (
    SELECT
        *
    FROM
        HighCOVItems
    WHERE
        cov_a > 1.5
)
SELECT
    *
FROM
    FilteredHighCOVItems;


