WITH sales_current_year AS (
    SELECT
        s_store_id,
        s_store_name,
        d_week_seq,
        d_day_name,
        SUM(ss_sales_price) AS total_sales
    FROM
        store_sales
    JOIN
        date_dim ON ss_sold_date_sk = d_date_sk
    JOIN
        store ON ss_store_sk = s_store_sk
    WHERE
        d_year = 2022
    GROUP BY
        s_store_id, s_store_name, d_week_seq, d_day_name
),
sales_previous_year AS (
    SELECT
        s_store_id,
        d_week_seq,
        d_day_name,
        SUM(ss_sales_price) AS total_sales
    FROM
        store_sales
    JOIN
        date_dim ON ss_sold_date_sk = d_date_sk
    WHERE
        d_year = 2021
    GROUP BY
        s_store_id, d_week_seq, d_day_name
)
SELECT
    cy.s_store_id,
    cy.s_store_name,
    cy.d_week_seq,
    cy.d_day_name,
    cy.total_sales AS current_year_sales,
    py.total_sales AS previous_year_sales,
    CASE
        WHEN py.total_sales = 0 THEN NULL
        ELSE cy.total_sales::DECIMAL / py.total_sales
    END AS sales_ratio
FROM
    sales_current_year cy
LEFT JOIN
    sales_previous_year py ON cy.s_store_id = py.s_store_id
    AND cy.d_week_seq = py.d_week_seq
    AND cy.d_day_name = py.d_day_name
ORDER BY
    cy.s_store_name,
    cy.s_store_id,
    cy.d_week_seq
LIMIT 100;


