SELECT SUM(l_extendedprice * l_discount) AS potential_revenue_increase FROM lineitem WHERE EXTRACT(YEAR FROM l_shipdate) = 1995 AND l_discount BETWEEN 0.04 AND 0.06 AND l_quantity < 30;
