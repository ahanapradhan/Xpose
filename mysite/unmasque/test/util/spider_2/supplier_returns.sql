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

top10s AS (
    SELECT
        *
    FROM (
        SELECT 
            *, 
            ROW_NUMBER() OVER(PARTITION BY month ORDER BY month DESC, parts_returned DESC, total_revenue_lost DESC) AS seq
        FROM (
            SELECT 
                date_trunc('month', order_date) AS month,
                supplier_id,
                part_id,
                COUNT(*) AS parts_returned,
                SUM(customer_cost) AS total_revenue_lost
            FROM 
                order_line_item
            WHERE 
                item_status = 'R'
            GROUP BY 
                month,
                supplier_id,
                part_id
        ) x
    ) y
    WHERE 
        seq <= 10
    ORDER BY
        month DESC,
        seq DESC
)

SELECT 
    top10s.*,
    s.s_name,
    s.s_phone,
    p.p_name
FROM 
    top10s
LEFT JOIN supplier s
    ON top10s.supplier_id = s.s_suppkey
LEFT JOIN part p
    ON top10s.part_id = p.p_partkey;
