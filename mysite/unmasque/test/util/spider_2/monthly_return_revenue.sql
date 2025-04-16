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
)

SELECT 
    date_trunc('month', order_date) AS month,
    ROUND(SUM(customer_cost), 2) AS return_total,
    COUNT(DISTINCT order_id) AS orders_with_returns,
    COUNT(*) AS items_returned
FROM 
    order_line_item
WHERE 
    item_status = 'R' 
GROUP BY 
    month
ORDER BY
    month;
