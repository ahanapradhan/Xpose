-- algebraic predicates, disjucntion
SELECT
    o_clerk,
    AVG(2 * o_totalprice + 35.90) AS total_price,
    c_acctbal,
    n_name
FROM orders, customer, nation
WHERE
    c_custkey = o_custkey
    AND c_nationkey = n_nationkey
    AND n_nationkey IN (1, 3, 5, 4, 10, 11)
    AND c_acctbal < 7000
    AND c_acctbal > 1000
    AND o_totalprice > 2500
    AND o_totalprice <= 15005.06
    AND c_acctbal <= o_totalprice
GROUP BY o_clerk, c_acctbal, n_name
ORDER BY total_price DESC, o_clerk, c_acctbal, n_name;

-- algebraic predicates
SELECT
    o_clerk,
    AVG(2 * o_totalprice + 1) AS total_price,
    c_acctbal,
    n_name
FROM orders, customer, nation
WHERE
    c_custkey = o_custkey
    AND c_nationkey = n_nationkey
    AND c_acctbal < 7000
    AND c_acctbal > 1000
    AND o_totalprice > 2500
    AND o_totalprice <= 15005.06
    AND c_acctbal <= o_totalprice
GROUP BY o_clerk, c_acctbal, n_name
ORDER BY total_price DESC, o_clerk, c_acctbal, n_name;

-- algebraic predicates
SELECT
    o_clerk,
    SUM(c_acctbal + 2 * o_totalprice) AS total_price,
    n_name
FROM orders, customer, nation
WHERE
    c_custkey = o_custkey
    AND c_nationkey = n_nationkey
    AND c_acctbal < 7000
    AND c_acctbal > 1000
    AND c_acctbal <= o_totalprice
GROUP BY o_clerk, n_name
ORDER BY o_clerk
LIMIT 30;

-- algebraic predicates, disjucntion
SELECT
    o_clerk,
    SUM(c_acctbal + 3.54 * o_totalprice) AS total_price,
    n_name
FROM orders, customer, nation
WHERE
    c_custkey = o_custkey
    AND c_custkey > 5000
    AND c_nationkey = n_nationkey
    AND n_nationkey IN (1, 2, 4, 5, 3, 10)
    AND c_acctbal < 7000
    AND o_totalprice > 1000
    AND c_acctbal <= o_totalprice
GROUP BY o_clerk, n_name
ORDER BY o_clerk
LIMIT 30;

-- algebraic predicate
SELECT
    l_shipmode,
    COUNT(*) AS count
FROM orders, lineitem
WHERE
    o_orderkey = l_orderkey
    AND l_commitdate <= l_receiptdate
    AND l_shipdate <= l_commitdate
    AND l_receiptdate >= '1994-01-01'
    AND l_receiptdate <= '1995-01-01'
    AND l_extendedprice < o_totalprice
    AND l_extendedprice <= 70000
    AND o_totalprice >= 60000
GROUP BY l_shipmode
ORDER BY l_shipmode;

-- algebraic predicate
SELECT
    c_name AS name,
    c_acctbal AS account_balance
FROM orders, customer, nation
WHERE
    o_custkey > 1000
    AND c_custkey = o_custkey
    AND c_custkey <= 5527
    AND c_nationkey = n_nationkey
    AND o_orderdate BETWEEN '1998-01-01' AND '1998-01-15'
    AND o_totalprice <= c_acctbal;

-- union and/or algebraic predicate
(SELECT
    p_partkey,
    p_name
 FROM part, partsupp
 WHERE p_partkey = ps_partkey
   AND ps_availqty >= 101)
UNION ALL
(SELECT
    s_suppkey AS p_partkey,
    s_name AS p_name
 FROM partsupp, supplier
 WHERE ps_suppkey = s_suppkey
   AND ps_availqty >= 201);

--  algebraic predicate
SELECT
    l_shipmode,
    COUNT(*) AS count
FROM lineitem, orders
WHERE
    l_orderkey = o_orderkey
    AND l_extendedprice <= o_totalprice
    AND 60000 < o_totalprice
    AND l_extendedprice < 70000
    AND l_receiptdate <= '1994-12-31'
    AND '1994-01-01' <= l_receiptdate
    AND l_shipdate < l_commitdate
    AND l_commitdate < l_receiptdate
GROUP BY l_shipmode
ORDER BY l_shipmode ASC;

--  algebraic predicate
SELECT
    o_orderpriority,
    COUNT(*) AS order_count
FROM lineitem, orders
WHERE
    l_orderkey = o_orderkey
    AND l_commitdate <= l_receiptdate
    AND '1993-07-01' <= o_orderdate
    AND o_orderdate <= '1993-09-30'
GROUP BY o_orderpriority
ORDER BY o_orderpriority ASC;

-- union and/or algebraic predicate
(SELECT
    p_brand,
    s_name AS o_clerk,
    l_shipmode
 FROM lineitem, part, supplier
 WHERE
    l_partkey = p_partkey
    AND p_container = 'LG CAN'
    AND l_shipdate >= '1995-01-02'
    AND l_suppkey < 14000
    AND l_partkey < 15000
    AND l_extendedprice <= s_acctbal
 ORDER BY o_clerk ASC
 LIMIT 10)
UNION ALL
(SELECT
    p_brand,
    o_clerk,
    l_shipmode
 FROM lineitem, orders, part
 WHERE
    l_orderkey = o_orderkey
    AND l_partkey = p_partkey
    AND p_container = 'LG CAN'
    AND l_suppkey < 10000
    AND l_partkey < 10000
    AND l_extendedprice <= p_retailprice
    AND o_orderdate <= l_shipdate
    AND '1994-01-02' <= o_orderdate
    AND '1995-01-02' <= l_shipdate
 ORDER BY o_clerk ASC
 LIMIT 5);

-- algebraic predicate
SELECT
    o_orderkey AS l_orderkey,
    ps_availqty AS l_linenumber
FROM lineitem, orders, partsupp
WHERE
    l_partkey = ps_partkey
    AND l_suppkey = ps_suppkey
    AND l_linenumber = ps_availqty
    AND l_orderkey = o_orderkey
    AND o_orderdate <= l_shipdate
    AND l_shipdate <= l_commitdate
    AND l_commitdate <= l_receiptdate
    AND '1990-01-01' <= o_orderdate
    AND '1994-01-02' <= l_receiptdate
ORDER BY l_orderkey ASC
LIMIT 7;

-- algebraic predicate
SELECT
    s_name,
    COUNT(*) AS numwait
FROM lineitem, nation, orders, supplier
WHERE
    l_orderkey = o_orderkey
    AND l_suppkey = s_suppkey
    AND n_nationkey = s_nationkey
    AND o_orderstatus = 'F'
    AND l_commitdate <= l_receiptdate
GROUP BY s_name
ORDER BY numwait DESC, s_name ASC
LIMIT 100;

-- algebraic predicate
SELECT
    l_returnflag,
    l_linestatus,
    SUM(l_quantity) AS sum_qty,
    SUM(l_extendedprice) AS sum_base_price,
    SUM(l_extendedprice * (1 - l_discount)) AS sum_disc_price,
    SUM(l_extendedprice * (-l_discount * l_tax - l_discount + l_tax + 1)) AS sum_charge,
    AVG(l_quantity) AS avg_qty,
    AVG(l_extendedprice) AS avg_price,
    AVG(l_discount) AS avg_disc,
    COUNT(*) AS count_order
FROM lineitem
WHERE
    l_shipdate <= l_receiptdate
    AND l_receiptdate <= l_commitdate
GROUP BY l_returnflag, l_linestatus
ORDER BY l_returnflag ASC, l_linestatus ASC;

-- union
(SELECT
    s_suppkey,
    s_name
 FROM nation, supplier
 WHERE
    n_nationkey = s_nationkey
    AND n_name = 'GERMANY')
UNION ALL
(SELECT
    c_custkey AS s_suppkey,
    c_name AS s_name
 FROM customer, orders
 WHERE
    c_custkey = o_custkey
    AND o_orderpriority = '1-URGENT');

(SELECT
    c_custkey AS key,
    c_name AS name
 FROM customer, nation
 WHERE
    c_nationkey = n_nationkey
    AND n_name = 'UNITED STATES')
UNION ALL
(SELECT
    l_partkey AS key,
    p_name AS name
 FROM lineitem, part
 WHERE
    l_partkey = p_partkey
    AND l_quantity > 35);

-- union
(SELECT
    s_suppkey AS c_custkey,
    s_name AS c_name
 FROM nation, supplier
 WHERE
    n_nationkey = s_nationkey
    AND n_name = 'CANADA')
UNION ALL
(SELECT
    c_custkey,
    c_name
 FROM customer, nation
 WHERE
    c_nationkey = n_nationkey
    AND n_name = 'UNITED STATES')
UNION ALL
(SELECT
    l_partkey AS c_custkey,
    p_name AS c_name
 FROM lineitem, part
 WHERE
    l_partkey = p_partkey
    AND l_quantity > 20);

-- union
(SELECT
    o_orderkey,
    l_shipdate AS o_orderdate
 FROM lineitem, orders
 WHERE
    l_orderkey = o_orderkey
    AND o_orderdate <= '1993-12-31'
    AND 20 < l_quantity
    AND 1000 < l_extendedprice)
UNION ALL
(SELECT
    o_orderkey,
    o_orderdate
 FROM customer, orders
 WHERE
    c_custkey = o_custkey
    AND c_name LIKE '%0001248%'
    AND o_orderdate >= '1997-01-01');

-- union
(SELECT
    n_name AS name,
    SUM(s_acctbal) AS total_price
 FROM nation, supplier
 WHERE
    n_nationkey = s_nationkey
    AND n_name LIKE '%UNITED%'
 GROUP BY n_name
 ORDER BY name DESC)
UNION ALL
(SELECT
    o_clerk AS name,
    SUM(l_extendedprice) AS total_price
 FROM lineitem, orders
 WHERE
    l_orderkey = o_orderkey
    AND o_orderdate <= '1995-01-01'
 GROUP BY o_clerk
 ORDER BY total_price DESC, name DESC
 LIMIT 10);

-- union
(SELECT
    l_orderkey AS key,
    l_extendedprice AS price,
    l_partkey AS s_key
 FROM lineitem
 WHERE
    l_quantity > 30
    AND l_shipdate >= '1994-01-01'
    AND l_shipdate <= '1994-12-31')
UNION ALL
(SELECT
    p_partkey AS key,
    p_retailprice AS price,
    s_suppkey AS s_key
 FROM part, partsupp, supplier
 WHERE
    p_partkey = ps_partkey
    AND ps_suppkey = s_suppkey
    AND ps_supplycost < 100);

-- union
(SELECT
    c_custkey AS order_id,
    COUNT(*) AS total
 FROM customer, orders
 WHERE
    c_custkey = o_custkey
    AND o_orderdate >= '1995-01-01'
 GROUP BY c_custkey
 ORDER BY total ASC, order_id DESC
 LIMIT 10)
UNION ALL
(SELECT
    l_orderkey AS order_id,
    AVG(l_quantity) AS total
 FROM lineitem, orders
 WHERE
    l_orderkey = o_orderkey
    AND o_orderdate <= '1996-06-30'
 GROUP BY l_orderkey
 ORDER BY total DESC, order_id ASC
 LIMIT 10);

-- union and/or algebraic predicate
(SELECT
    s_name AS name,
    s_acctbal AS account_balance
 FROM lineitem, nation, orders, supplier
 WHERE
    l_orderkey = o_orderkey
    AND l_suppkey = s_suppkey
    AND n_nationkey = s_nationkey
    AND n_name = 'ARGENTINA'
    AND o_orderdate >= '1998-01-01'
    AND o_orderdate <= '1998-01-05'
    AND s_acctbal <= o_totalprice
    AND 30000 < o_totalprice
    AND s_acctbal < 50000)
UNION ALL
(SELECT
    c_name AS name,
    c_acctbal AS account_balance
 FROM customer, nation, orders
 WHERE
    c_nationkey = n_nationkey
    AND c_custkey = o_custkey
    AND n_name = 'INDIA'
    AND c_mktsegment = 'FURNITURE'
    AND o_orderdate >= '1998-01-01'
    AND o_orderdate <= '1998-01-05'
    AND o_totalprice <= c_acctbal);

-- FULL OUTER JOIN
SELECT
    n_name,
    r_comment
FROM nation
FULL OUTER JOIN region
    ON n_regionkey = r_regionkey
   AND r_name = 'AFRICA';


-- RIGHT OUTER JOIN
SELECT
    n_name,
    c_comment
FROM nation
RIGHT OUTER JOIN customer
    ON c_nationkey = n_nationkey
   AND c_acctbal < 1000;


-- union, with FULL OUTER JOIN + RIGHT OUTER JOIN
SELECT
    n_name,
    r_comment
FROM nation
FULL OUTER JOIN region
    ON n_regionkey = r_regionkey
   AND r_name = 'AFRICA'

UNION ALL

SELECT
    n_name,
    c_comment
FROM nation
RIGHT OUTER JOIN customer
    ON c_nationkey = n_nationkey
   AND c_acctbal < 1000;


-- union, with chained OUTER JOINs
SELECT
    n_name,
    r_comment,
    c_acctbal
FROM nation
FULL OUTER JOIN region
    ON n_regionkey = r_regionkey
   AND r_name = 'AFRICA'
LEFT OUTER JOIN customer
    ON c_nationkey = n_nationkey
   AND c_mktsegment = 'BUILDING'

UNION ALL

SELECT
    c_name,
    o_comment,
    l_discount
FROM orders
RIGHT OUTER JOIN customer
    ON c_custkey = o_custkey
   AND c_acctbal < 1000
RIGHT OUTER JOIN lineitem
    ON o_orderkey = l_orderkey
   AND l_extendedprice > 7000
   AND o_orderstatus = 'F';


-- Chained RIGHT OUTER JOINs
SELECT
    c_name,
    o_comment,
    l_discount
FROM orders
RIGHT OUTER JOIN customer
    ON c_custkey = o_custkey
   AND c_acctbal < 1000
RIGHT OUTER JOIN lineitem
    ON o_orderkey = l_orderkey
   AND l_extendedprice > 7000
   AND o_orderstatus = 'F';

-- nep
SELECT l_shipmode, SUM(l_extendedprice) AS revenue
FROM lineitem
WHERE l_shipdate >= '1994-01-01'
  AND l_quantity < 24
  AND l_returnflag <> 'R'
GROUP BY l_shipmode
LIMIT 100;

-- nep
SELECT l_shipmode, COUNT(*) AS count
FROM lineitem
WHERE l_quantity > 20
  AND l_quantity <> 25
GROUP BY l_shipmode
ORDER BY l_shipmode;

-- nep
SELECT l_shipmode, SUM(l_extendedprice) AS revenue
FROM lineitem
WHERE l_shipdate < '1994-01-01'
  AND l_quantity < 24
  AND l_linenumber <> 4
  AND l_returnflag <> 'R'
GROUP BY l_shipmode
LIMIT 100;

-- nep
SELECT l_shipmode, SUM(l_extendedprice) AS revenue
FROM lineitem
WHERE l_quantity < 24
  AND l_shipdate <> '1994-01-02'
  AND l_shipmode NOT LIKE '%AIR%'
GROUP BY l_shipmode
LIMIT 100;

-- nep
SELECT s_name, COUNT(*) AS numwait
FROM supplier, lineitem, orders, nation
WHERE s_suppkey = l_suppkey
  AND o_orderkey = l_orderkey
  AND o_orderstatus = 'F'
  AND s_nationkey = n_nationkey
  AND n_name <> 'GERMANY'
GROUP BY s_name
ORDER BY numwait DESC, s_name
LIMIT 100;

-- nep
SELECT c_name, o_orderdate, o_totalprice, SUM(l_quantity)
FROM customer, orders, lineitem
WHERE c_phone LIKE '27-_%'
  AND c_custkey = o_custkey
  AND o_orderkey = l_orderkey
  AND c_name <> 'Customer#000060217'
GROUP BY c_name, o_orderdate, o_totalprice
ORDER BY o_orderdate, o_totalprice DESC
LIMIT 100;

-- nep
SELECT ps_comment, SUM(ps_supplycost * ps_availqty) AS value
FROM partsupp, supplier, nation
WHERE ps_suppkey = s_suppkey
  AND s_nationkey = n_nationkey
  AND n_name = 'ARGENTINA'
  AND ps_comment NOT LIKE '%regular%dependencies%'
  AND s_acctbal <> 2177.90
GROUP BY ps_comment
ORDER BY value DESC
LIMIT 100;

-- nep
SELECT *
FROM partsupp, supplier, nation
WHERE ps_suppkey = s_suppkey
  AND s_nationkey = n_nationkey
  AND n_name = 'ARGENTINA'
  AND ps_comment <> 'dependencies'
  AND ps_comment <> 'hello world regular mina dependencies';

-- disjunction/ nep (range disjunctions may be extracted as point valued neps)

  select n_name, c_acctbal from nation, customer WHERE n_nationkey = c_nationkey and 
  n_nationkey IN (1, 2, 3, 5, 4, 13, 14, 15) and c_acctbal < 7000 and c_acctbal > 1000 ORDER BY c_acctbal;

select n_name, c_acctbal from nation, customer where n_nationkey = c_nationkey and c_nationkey > 3 and 
  n_nationkey < 20 and c_nationkey != 10 and c_acctbal < 7000 LIMIT 200;


select sum(l_extendedprice) as revenue from lineitem 
  where l_shipdate >= date '1994-01-01' and l_shipdate < date '1994-01-01' + interval '1' year 
  and (l_quantity < 10 or l_quantity between 24 and 42 or l_quantity >= 50);


select avg(ps_supplycost) as cost from part, partsupp where p_partkey = ps_partkey 
  and (p_brand = 'Brand#52' or p_brand = 'Brand#12');


select p_size, ps_suppkey, count(*) as low_line_count from part. partsupp where 
  p_partkey = ps_partkey and p_brand IN ('Brand#52', 'Brand#34', 'Brand#15') and p_container IN ('WRAP BOX', 'MED BOX') 
  GROUP BY p_size, ps_suppkey  ORDER BY ps_suppkey desc LIMIT 30);


select n_name, s_acctbal, ps_availqty  from supplier, partsupp, nation where 
  ps_suppkey=s_suppkey AND ps_supplycost < 50 and s_nationkey=n_nationkey and (n_regionkey = 1 or n_regionkey =3) ORDER BY n_name;

