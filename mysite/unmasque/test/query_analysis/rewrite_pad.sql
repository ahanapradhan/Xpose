WITH customer_base
    AS  (SELECT c_customer_id                       customer_id,
                c_first_name                        customer_first_name,
                c_last_name                         customer_last_name,
                c_preferred_cust_flag               customer_preferred_cust_flag
                ,
                c_birth_country
                customer_birth_country,
                c_login                             customer_login,
                c_email_address                     customer_email_address,
                c_customer_sk
        FROM customer
        GROUP  BY c_customer_id,
                   c_first_name,
                   c_last_name,
                   c_preferred_cust_flag,
                   c_birth_country,
                   c_login,
                   c_email_address,
				c_customer_sk),
    t_s_firstyear
    AS (SELECT Sum(( ( ss_ext_list_price - ss_ext_wholesale_cost
                        - ss_ext_discount_amt
                      )
                      +
                          ss_ext_sales_price ) / 2) ss_year_total,
               ss_customer_sk,
               d_year                                       dyear
       FROM store_sales, date_dim
       WHERE ss_sold_date_sk = d_date_sk
       and d_year = 2001
       GROUP BY ss_customer_sk, dyear),
    t_c_firstyear
    AS (SELECT Sum(( ( cs_ext_list_price - cs_ext_wholesale_cost
                        - cs_ext_discount_amt
                      )
                      +
                          cs_ext_sales_price ) / 2) cs_year_total,
               cs_bill_customer_sk,
               d_year                                       dyear
       FROM catalog_sales, date_dim
       WHERE cs_sold_date_sk = d_date_sk
       and d_year = 2001
       GROUP BY cs_bill_customer_sk, dyear),
    t_w_firstyear
    AS (SELECT Sum(( ( ws_ext_list_price - ws_ext_wholesale_cost
                        - ws_ext_discount_amt
                      )
                      +
                          ws_ext_sales_price ) / 2) ws_year_total,
               ws_bill_customer_sk,
               d_year                                       dyear
       FROM web_sales, date_dim
       WHERE ws_sold_date_sk = d_date_sk
       and d_year = 2001
       GROUP BY ws_bill_customer_sk, dyear),
    t_s_secyear
    AS (SELECT Sum(( ( ss_ext_list_price - ss_ext_wholesale_cost
                        - ss_ext_discount_amt
                      )
                      +
                          ss_ext_sales_price ) / 2) ss_year_total,
               ss_customer_sk,
               d_year                                       dyear
       FROM store_sales, date_dim
       WHERE ss_sold_date_sk = d_date_sk
       and d_year = 2001+1
       GROUP BY ss_customer_sk, dyear),
    t_c_secyear
    AS (SELECT Sum(( ( cs_ext_list_price - cs_ext_wholesale_cost
                        - cs_ext_discount_amt
                      )
                      +
                          cs_ext_sales_price ) / 2) cs_year_total,
               cs_bill_customer_sk,
               d_year                                       dyear
       FROM catalog_sales, date_dim
       WHERE cs_sold_date_sk = d_date_sk
       and d_year = 2001+1
       GROUP BY cs_bill_customer_sk, dyear),
    t_w_secyear
    AS (SELECT Sum(( ( ws_ext_list_price - ws_ext_wholesale_cost
                        - ws_ext_discount_amt
                      )
                      +
                          ws_ext_sales_price ) / 2) ws_year_total,
               ws_bill_customer_sk,
               d_year                                       dyear
       FROM web_sales, date_dim
       WHERE ws_sold_date_sk = d_date_sk
       and d_year = 2001+1
       GROUP BY ws_bill_customer_sk, dyear)
SELECT customer_id,
               customer_first_name,
               customer_last_name,
               customer_preferred_cust_flag
FROM   t_s_firstyear,
       t_s_secyear,
       t_c_firstyear,
       t_c_secyear,
       t_w_firstyear,
       t_w_secyear,
       customer_base
WHERE c_customer_sk = t_s_firstyear.ss_customer_sk
and   c_customer_sk = t_c_firstyear.cs_bill_customer_sk
and   c_customer_sk = t_w_firstyear.ws_bill_customer_sk
and   c_customer_sk = t_s_secyear.ss_customer_sk
and   c_customer_sk = t_c_secyear.cs_bill_customer_sk
and   c_customer_sk = t_w_secyear.ws_bill_customer_sk
AND t_s_firstyear.ss_year_total > 0
AND t_c_firstyear.cs_year_total > 0
AND t_w_firstyear.ws_year_total > 0
--and t_c_secyear.cs_year_total / t_c_firstyear.cs_year_total > t_s_secyear.ss_year_total / t_s_firstyear.ss_year_total
--and t_c_secyear.cs_year_total / t_c_firstyear.cs_year_total > t_w_secyear.ws_year_total / t_w_firstyear.ws_year_total
ORDER  BY customer_id,
          customer_first_name,
          customer_last_name,
          customer_preferred_cust_flag
LIMIT 100;






