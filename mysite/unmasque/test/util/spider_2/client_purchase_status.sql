WITH order_line_item AS (
    WITH buyer_costs AS (
        SELECT
            l_orderkey AS order_id,
            l_linenumber AS line_id,
            l_suppkey AS supplier_id,
            l_partkey AS part_id,
            l_returnflag AS item_status,
            ROUND(l_extendedprice * (1 - l_discount), 2) AS item_cost
        FROM lineitem
    )
    SELECT 
        o.o_custkey AS customer_id,
        o.o_orderdate AS order_date,
        o.o_orderkey AS order_id,
        bc.line_id,
        bc.supplier_id,
        bc.part_id,
        bc.item_status,
        bc.item_cost AS customer_cost
    FROM 
        buyer_costs bc 
    LEFT JOIN 
        orders o ON bc.order_id = o.o_orderkey
    ORDER BY
        o.o_custkey,
        o.o_orderdate,
        o.o_orderkey,
        bc.line_id
),

lost_revenue AS (
    WITH ro AS (
        SELECT
            o.o_orderkey,
            c.c_custkey
        FROM orders o
        INNER JOIN customer c ON o.o_custkey = c.c_custkey
    ),

    rl AS (
        SELECT 
            c.c_custkey,
            c.c_name,
            SUM(revenue) AS revenue_lost,
            c.c_acctbal,
            n.n_name,
            c.c_address,
            c.c_phone,
            c.c_comment
        FROM ro
        LEFT JOIN (
            SELECT 
                l.l_orderkey AS order_id,
                o.o_custkey AS customer_id,
                SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue
            FROM lineitem l
            LEFT JOIN orders o ON l.l_orderkey = o.o_orderkey
            WHERE l.l_returnflag = 'R'
            GROUP BY o.o_custkey, l.l_orderkey
        ) lo ON lo.order_id = ro.o_orderkey AND lo.customer_id = ro.c_custkey
        LEFT JOIN customer c ON c.c_custkey = lo.customer_id
        LEFT JOIN nation n ON c.c_nationkey = n.n_nationkey
        WHERE lo.customer_id IS NOT NULL
        GROUP BY 
            c.c_custkey,
            c.c_name,
            c.c_acctbal,
            c.c_phone,
            n.n_name,
            c.c_address,
            c.c_comment
        ORDER BY revenue_lost DESC
    )

    SELECT * FROM rl
)

SELECT 
    customer_id,
    customer_name,
    COALESCE(purchase_total, 0) AS purchase_total,
    COALESCE(lr.revenue_lost, 0) AS return_total,
    COALESCE(COALESCE(purchase_total, 0) - COALESCE(lr.revenue_lost, 0), 0) AS lifetime_value,
    (COALESCE(lr.revenue_lost, 0) / COALESCE(purchase_total, 0)) * 100 AS return_pct,
    CASE 
        WHEN COALESCE(purchase_total, 0) = 0 THEN 'red'
        WHEN (COALESCE(lr.revenue_lost, 0) / COALESCE(purchase_total, 0)) * 100 <= 25 THEN 'green'
        WHEN (COALESCE(lr.revenue_lost, 0) / COALESCE(purchase_total, 0)) * 100 <= 50 THEN 'yellow'
        WHEN (COALESCE(lr.revenue_lost, 0) / COALESCE(purchase_total, 0)) * 100 <= 75 THEN 'orange'
        WHEN (COALESCE(lr.revenue_lost, 0) / COALESCE(purchase_total, 0)) * 100 <= 100 THEN 'red'
    END AS customer_status
FROM (
    SELECT 
        c.c_custkey AS customer_id,
        c.c_name AS customer_name,
        ROUND(SUM(customer_cost), 2) AS purchase_total
    FROM customer c
    LEFT JOIN order_line_item oli ON c.c_custkey = oli.customer_id
    WHERE item_status != 'R'
    GROUP BY c.c_custkey, c.c_name
    ORDER BY c.c_custkey
) co
LEFT JOIN lost_revenue lr ON co.customer_id = lr.c_custkey;
