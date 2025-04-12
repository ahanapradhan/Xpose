(Select c_customer_id as customer_id, c_first_name as customer_first_name, c_last_name as customer_last_name, c_preferred_cust_flag as customer_preferred_cust_flag
 From catalog_sales, catalog_sales1, customer, date_dim, date_dim1, store_sales, store_sales1, web_sales, web_sales1
 Where catalog_sales1.cs1_sold_date_sk = date_dim1.d1_date_sk
 and date_dim1.d1_date_sk = store_sales1.ss1_sold_date_sk
 and store_sales1.ss1_sold_date_sk = web_sales1.ws1_sold_date_sk
 and catalog_sales.cs_bill_customer_sk = catalog_sales1.cs1_bill_customer_sk
 and catalog_sales1.cs1_bill_customer_sk = customer.c_customer_sk
 and customer.c_customer_sk = store_sales.ss_customer_sk
 and store_sales.ss_customer_sk = store_sales1.ss1_customer_sk
 and store_sales1.ss1_customer_sk = web_sales.ws_bill_customer_sk
 and web_sales.ws_bill_customer_sk = web_sales1.ws1_bill_customer_sk
 and catalog_sales.cs_sold_date_sk = date_dim.d_date_sk
 and date_dim.d_date_sk = store_sales.ss_sold_date_sk
 and store_sales.ss_sold_date_sk = web_sales.ws_sold_date_sk
 and date_dim.d_year = 2001
 and date_dim1.d1_year = 2002
 and store_sales1.ss1_ext_list_price <= 159.99
 and store_sales1.ss1_ext_wholesale_cost >= 10.01
 and store_sales1.ss1_ext_discount_amt >= -29.99
 and store_sales1.ss1_ext_sales_price <= 99.99
 and catalog_sales1.cs1_ext_list_price >= 110.01
 and catalog_sales1.cs1_ext_wholesale_cost <= 79.99
 and catalog_sales1.cs1_ext_discount_amt <= 49.99
 and catalog_sales1.cs1_ext_sales_price >= 20.01
 and store_sales.ss_ext_list_price >= 75.01
 and store_sales.ss_ext_wholesale_cost <= 64.989
 and store_sales.ss_ext_discount_amt <= 34.99
 and store_sales.ss_ext_sales_price >= 25.01
 and web_sales.ws_ext_list_price >= 75.01
 and web_sales.ws_ext_wholesale_cost <= 64.989
 and web_sales.ws_ext_discount_amt <= 34.99
 and web_sales.ws_ext_sales_price >= 25.01
 and web_sales1.ws1_ext_list_price <= 159.99
 and web_sales1.ws1_ext_wholesale_cost >= 10.01
 and web_sales1.ws1_ext_discount_amt >= -29.99
 and web_sales1.ws1_ext_sales_price <= 99.99
 and catalog_sales.cs_ext_list_price between 0.01 and 133.33
 and catalog_sales.cs_ext_wholesale_cost between 6.67 and 139.99
 and catalog_sales.cs_ext_discount_amt between -23.33 and 109.99
 and catalog_sales.cs_ext_sales_price between -49.99 and 83.33
 Order By customer_id asc, customer_first_name asc, customer_last_name asc, customer_preferred_cust_flag asc);




Consider the following SQL query:
(Select c_customer_id as customer_id,
c_first_name as customer_first_name,
c_last_name as customer_last_name,
c_preferred_cust_flag as customer_preferred_cust_flag
 From catalog_sales c1, customer, date_dim, date_dim d1, web_sales
 Where c1.cs_bill_customer_sk = customer.c_customer_sk
 and customer.c_customer_sk = web_sales.ws_bill_customer_sk
 and c1.cs_sold_date_sk = d1.d_date_sk
 and date_dim.d_date_sk = web_sales.ws_sold_date_sk
 and d1.d_year = 2002
 and date_dim.d_year = 2001
 and web_sales.ws_ext_discount_amt <= 22482.89
 and web_sales.ws_ext_sales_price >= -7533.89
 and web_sales.ws_ext_wholesale_cost <= 25413.29
 and web_sales.ws_ext_list_price >= -5291.54
 Group By c_customer_id
 Order By customer_id asc, customer_first_name asc, customer_last_name asc, customer_preferred_cust_flag asc
 Limit 100)
 UNION ALL
 (Select c_customer_id as customer_id, c_first_name as customer_first_name, c_last_name as customer_last_name, c_preferred_cust_flag as customer_preferred_cust_flag
 From customer, date_dim, date_dim d1, web_sales, web_sales w1
 Where customer.c_customer_sk = web_sales.ws_bill_customer_sk
 and web_sales.ws_bill_customer_sk = w1.ws1_bill_customer_sk
 and d1.d_date_sk = w1.ws1_sold_date_sk
 and date_dim.d_date_sk = web_sales.ws_sold_date_sk
 and web_sales.ws_ext_discount_amt <= web_sales.ws_ext_list_price
 and web_sales.ws_ext_wholesale_cost <= web_sales.ws_ext_list_price
 and d1.d_year = 2002
 and date_dim.d_year = 2001
 and web_sales.ws_ext_sales_price >= 3440.25
 and web_sales.ws_ext_list_price >= -2147480420.48
 and web_sales.ws_ext_wholesale_cost <= 2147483647.87
 Group By c_customer_id
 Order By customer_id asc, customer_first_name asc, customer_last_name asc, customer_preferred_cust_flag asc
 Limit 100)
 UNION ALL
 (Select c_customer_id as customer_id, c_first_name as customer_first_name, c_last_name as customer_last_name, c_preferred_cust_flag as customer_preferred_cust_flag
 From catalog_sales, catalog_sales c1, customer, date_dim, date_dim1
 Where catalog_sales.cs_bill_customer_sk = c1.cs_bill_customer_sk
 and c1.cs_bill_customer_sk = customer.c_customer_sk
 and catalog_sales.cs_sold_date_sk = date_dim.d_date_sk
 and c1.cs_sold_date_sk = d1.d_date_sk
 and d1.d_year = 2002
 and date_dim.d_year = 2001
 and catalog_sales.cs_ext_discount_amt <= 1347.49
 and catalog_sales.cs_ext_sales_price >= -41.43
 and catalog_sales.cs_ext_wholesale_cost <= 1567.15
 and catalog_sales.cs_ext_list_price >= 481.05
 Group By c_customer_id
 Order By customer_id asc, customer_first_name asc, customer_last_name asc, customer_preferred_cust_flag asc
 Limit 100)
 UNION ALL
 (Select c_customer_id as customer_id, c_first_name as customer_first_name, c_last_name as customer_last_name, c_preferred_cust_flag as customer_preferred_cust_flag
 From catalog_sales, customer, date_dim, date_dim d1, store_sales s1
 Where catalog_sales.cs_bill_customer_sk = customer.c_customer_sk
 and customer.c_customer_sk = s1.ss_customer_sk
 and d1.d_date_sk = s1.ss_sold_date_sk
 and catalog_sales.cs_sold_date_sk = date_dim.d_date_sk
 and d1.d_year = 2002
 and date_dim.d_year = 2001
 and catalog_sales.cs_ext_discount_amt <= 16739.99
 and catalog_sales.cs_ext_sales_price >= -5524.19
 and catalog_sales.cs_ext_wholesale_cost <= 19513.79
 and catalog_sales.cs_ext_list_price >= -4065.29
 Group By c_customer_id
 Order By customer_id asc, customer_first_name asc, customer_last_name asc, customer_preferred_cust_flag asc
 Limit 100)
 UNION ALL
 (Select c_customer_id as customer_id, c_first_name as customer_first_name, c_last_name as customer_last_name, c_preferred_cust_flag as customer_preferred_cust_flag
 From customer, date_dim, date_dim d1, store_sales, web_sales w1
 Where customer.c_customer_sk = store_sales.ss_customer_sk
 and store_sales.ss_customer_sk = w1.ws1_bill_customer_sk
 and d1.d_date_sk = w1.ws1_sold_date_sk
 and date_dim.d_date_sk = store_sales.ss_sold_date_sk
 and store_sales.ss_ext_discount_amt <= store_sales.ss_ext_list_price
 and d1.d_year = 2002
 and date_dim.d_year = 2001
 and store_sales.ss_ext_sales_price >= -567.19
 and store_sales.ss_ext_wholesale_cost <= 9529.59
 and store_sales.ss_ext_list_price >= -2147483156.87
 Group By c_customer_id
 Order By customer_id asc, customer_first_name asc, customer_last_name asc, customer_preferred_cust_flag asc
 Limit 100)
 UNION ALL
 (Select c_customer_id as customer_id, c_first_name as customer_first_name, c_last_name as customer_last_name, c_preferred_cust_flag as customer_preferred_cust_flag
 From catalog_sales c1, customer, date_dim, date_dim d1, store_sales
 Where c1.cs_bill_customer_sk = customer.c_customer_sk
 and customer.c_customer_sk = store_sales.ss_customer_sk
 and c1.cs_sold_date_sk = d1.d_date_sk
 and date_dim.d_date_sk = store_sales.ss_sold_date_sk
 and store_sales.ss_ext_discount_amt <= store_sales.ss_ext_list_price
 and d1.d_year = 2002
 and date_dim.d_year = 2001
 and store_sales.ss_ext_sales_price >= 214.2
 and store_sales.ss_ext_wholesale_cost <= 4505.84
 and store_sales.ss_ext_list_price >= -2147481075.92
 Group By c_customer_id
 Order By customer_id asc, customer_first_name asc, customer_last_name asc, customer_preferred_cust_flag asc
 Limit 100)
 UNION ALL
 (Select c_customer_id as customer_id, c_first_name as customer_first_name, c_last_name as customer_last_name, c_preferred_cust_flag as customer_preferred_cust_flag
 From customer, date_dim, date_dim d1, store_sales, store_sales s1
 Where customer.c_customer_sk = store_sales.ss_customer_sk
 and store_sales.ss_customer_sk = s1.ss_customer_sk
 and d1.d_date_sk = s1.ss_sold_date_sk
 and date_dim.d_date_sk = store_sales.ss_sold_date_sk
 and store_sales.ss_ext_discount_amt <= store_sales.ss_ext_list_price
 and d1.d_year = 2002
 and date_dim.d_year = 2001
 and store_sales.ss_ext_sales_price >= -3530.91
 and store_sales.ss_ext_wholesale_cost <= 15253.63
 and store_sales.ss_ext_list_price >= -2147483601.31
 Group By c_customer_id
 Order By customer_id asc, customer_first_name asc, customer_last_name asc, customer_preferred_cust_flag asc
 Limit 100)
 UNION ALL
 (Select c_customer_id as customer_id, c_first_name as customer_first_name, c_last_name as customer_last_name, c_preferred_cust_flag as customer_preferred_cust_flag
 From catalog_sales, customer, date_dim, date_dim d1, web_sales w1
 Where catalog_sales.cs_bill_customer_sk = customer.c_customer_sk
 and customer.c_customer_sk = w1.ws_bill_customer_sk
 and d1.d_date_sk = w1.ws_sold_date_sk
 and catalog_sales.cs_sold_date_sk = date_dim.d_date_sk
 and d1.d_year = 2002
 and date_dim.d_year = 2001
 and catalog_sales.cs_ext_discount_amt <= 1469.87
 and catalog_sales.cs_ext_sales_price >= -70.55
 and catalog_sales.cs_ext_wholesale_cost <= 1679.03
 and catalog_sales.cs_ext_list_price >= 489.25
 Group By c_customer_id
 Order By customer_id asc, customer_first_name asc, customer_last_name asc, customer_preferred_cust_flag asc
 Limit 100)
 UNION ALL
 (Select c_customer_id as customer_id, c_first_name as customer_first_name, c_last_name as customer_last_name, c_preferred_cust_flag as customer_preferred_cust_flag
 From customer, date_dim, date_dim d1, store_sales s1, web_sales
 Where customer.c_customer_sk = s1.ss_customer_sk
 and s1.ss_customer_sk = web_sales.ws_bill_customer_sk
 and d1.d_date_sk = s1.ss_sold_date_sk
 and date_dim.d_date_sk = web_sales.ws_sold_date_sk
 and d1.d_year = 2002
 and date_dim.d_year = 2001
 and web_sales.ws_ext_discount_amt <= 3973.59
 and web_sales.ws_ext_sales_price >= -958.39
 and web_sales.ws_ext_wholesale_cost <= 5124.79
 and web_sales.ws_ext_list_price >= -505.59
 Group By c_customer_id
 Order By customer_id asc, customer_first_name asc, customer_last_name asc, customer_preferred_cust_flag asc
 Limit 100);

 You have to refine this query to implement some meaningful logic. In the end, describe the business logic in English natural language, and also give the refined SQL.
 Perform refinement using the following rules:
 1. Try to identify if any CTE can be derived, where a CTE has more than 1 table in its from clause. Consider possibility of multiple instances of a CTE.
 2. If predicates in the WHERE clause of a subquery looks bogus, i.e. they use constants that does not seem to map to anything meaningful,
 consider formulating scalar polynomial function (linear function) out of those attributes for a predicate.
 3. Order by clause makes sense to on the outer most query.
 4. In any subquery (or CTE), group by attributes must appear in the corresponding projections.
 5. All the tables in the above query must be used in your query.
