WITH sales_2001 AS (
    SELECT
        p.p_product_name,
        s.s_store_name,
        c.c_customer_id,
        SUM(ss.ss_quantity) AS sales_count_2001,
        SUM(ss.ss_wholesale_cost) AS wholesale_cost_2001,
        SUM(ss.ss_list_price) AS list_price_2001,
        SUM(ss.ss_coupon_amt) AS coupon_amt_2001,
        SUM(ss.ss_sales_price) AS sales_price_2001,
        SUM(sr.sr_refunded_cash) AS refunded_cash_2001
    FROM
        store_sales ss
    JOIN
        store_returns sr ON ss.ss_item_sk = sr.sr_item_sk AND ss.ss_ticket_number = sr.sr_ticket_number
    JOIN
        item p ON ss.ss_item_sk = p.i_item_sk
    JOIN
        store s ON ss.ss_store_sk = s.s_store_sk
    JOIN
        customer c ON ss.ss_customer_sk = c.c_customer_sk
    WHERE
        ss.ss_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_year = 2001 AND d_moy = 1 AND d_dom = 1)
        AND (SELECT d_date_sk FROM date_dim WHERE d_year = 2001 AND d_moy = 12 AND d_dom = 31)
        AND p.i_color IN ('Red', 'Blue', 'Green') -- Example colors
        AND p.i_current_price BETWEEN 10 AND 100 -- Example price range
    GROUP BY
        p.p_product_name, s.s_store_name, c.c_customer_id
    HAVING
        SUM(ss.ss_sales_price) > 1.5 * SUM(sr.sr_refunded_cash)
),
sales_2002 AS (
    SELECT
        p.p_product_name,
        s.s_store_name,
        c.c_customer_id,
        SUM(ss.ss_quantity) AS sales_count_2002,
        SUM(ss.ss_wholesale_cost) AS wholesale_cost_2002,
        SUM(ss.ss_list_price) AS list_price_2002,
        SUM(ss.ss_coupon_amt) AS coupon_amt_2002,
        SUM(ss.ss_sales_price) AS sales_price_2002,
        SUM(sr.sr_refunded_cash) AS refunded_cash_2002
    FROM
        store_sales ss
    JOIN
        store_returns sr ON ss.ss_item_sk = sr.sr_item_sk AND ss.ss_ticket_number = sr.sr_ticket_number
    JOIN
        item p ON ss.ss_item_sk = p.i_item_sk
    JOIN
        store s ON ss.ss_store_sk = s.s_store_sk
    JOIN
        customer c ON ss.ss_customer_sk = c.c_customer_sk
    WHERE
        ss.ss_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_year = 2002 AND d_moy = 1 AND d_dom = 1)
        AND (SELECT d_date_sk FROM date_dim WHERE d_year = 2002 AND d_moy = 12 AND d_dom = 31)
        AND p.i_color IN ('Red', 'Blue', 'Green') -- Example colors
        AND p.i_current_price BETWEEN 10 AND 100 -- Example price range
    GROUP BY
        p.p_product_name, s.s_store_name, c.c_customer_id
    HAVING
        SUM(ss.ss_sales_price) > 1.5 * SUM(sr.sr_refunded_cash)
)
SELECT
    s1.p_product_name,
    s1.s_store_name,
    s1.c_customer_id,
    s1.sales_count_2001,
    s2.sales_count_2002,
    s1.wholesale_cost_2001,
    s2.wholesale_cost_2002,
    s1.list_price_2001,
    s2.list_price_2002,
    s1.coupon_amt_2001,
    s2.coupon_amt_2002
FROM
    sales_2001 s1
FULL OUTER JOIN
    sales_2002 s2 ON s1.p_product_name = s2.p_product_name
    AND s1.s_store_name = s2.s_store_name
    AND s1.c_customer_id = s2.c_customer_id
ORDER BY
    s1.p_product_name,
    s1.s_store_name,
    s1.sales_count_2001 DESC;


