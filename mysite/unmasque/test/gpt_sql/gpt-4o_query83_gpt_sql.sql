WITH total_returns AS (
    SELECT
        i_item_id,
        SUM(COALESCE(sr_return_quantity, 0)) AS store_return_qty,
        SUM(COALESCE(cr_return_quantity, 0)) AS catalog_return_qty,
        SUM(COALESCE(wr_return_quantity, 0)) AS web_return_qty
    FROM
        item
    LEFT JOIN store_returns ON sr_item_sk = i_item_sk
    LEFT JOIN catalog_returns ON cr_item_sk = i_item_sk
    LEFT JOIN web_returns ON wr_item_sk = i_item_sk
    WHERE
        (sr_returned_date_sk IS NULL OR sr_returned_date_sk IN (SELECT d_date_sk FROM date_dim WHERE d_year = 1999))
        AND (cr_returned_date_sk IS NULL OR cr_returned_date_sk IN (SELECT d_date_sk FROM date_dim WHERE d_year = 1999))
        AND (wr_returned_date_sk IS NULL OR wr_returned_date_sk IN (SELECT d_date_sk FROM date_dim WHERE d_year = 1999))
    GROUP BY
        i_item_id
),
channel_contribution AS (
    SELECT
        i_item_id,
        store_return_qty,
        catalog_return_qty,
        web_return_qty,
        (store_return_qty + catalog_return_qty + web_return_qty) AS total_return_qty,
        (store_return_qty * 100.0 / NULLIF((store_return_qty + catalog_return_qty + web_return_qty), 0)) AS store_pct,
        (catalog_return_qty * 100.0 / NULLIF((store_return_qty + catalog_return_qty + web_return_qty), 0)) AS catalog_pct,
        (web_return_qty * 100.0 / NULLIF((store_return_qty + catalog_return_qty + web_return_qty), 0)) AS web_pct
    FROM
        total_returns
),
average_return AS (
    SELECT
        i_item_id,
        store_return_qty,
        catalog_return_qty,
        web_return_qty,
        total_return_qty,
        store_pct,
        catalog_pct,
        web_pct,
        (store_return_qty + catalog_return_qty + web_return_qty) / 3.0 AS avg_return_qty
    FROM
        channel_contribution
)
SELECT
    i_item_id,
    store_return_qty,
    catalog_return_qty,
    web_return_qty,
    total_return_qty,
    store_pct,
    catalog_pct,
    web_pct,
    avg_return_qty
FROM
    average_return
ORDER BY
    i_item_id,
    store_return_qty DESC
LIMIT 100;


