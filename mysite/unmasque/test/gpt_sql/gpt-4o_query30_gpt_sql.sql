WITH indiana_returns AS (
    SELECT 
        sr_customer_sk,
        SUM(sr_return_amt) AS total_return_amt
    FROM 
        store_returns
    JOIN 
        sales ON sr_item_sk = s_item_sk
    JOIN 
        date_dim ON s_sold_date_sk = d_date_sk
    WHERE 
        d_year = 2000
        AND s_state = 'IN'
    GROUP BY 
        sr_customer_sk
),
average_return AS (
    SELECT 
        AVG(total_return_amt) AS avg_return_amt
    FROM 
        indiana_returns
)
SELECT 
    c_customer_id,
    c_first_name,
    c_last_name,
    c_salutation,
    c_preferred_cust_flag,
    c_birth_day,
    c_birth_month,
    c_birth_year,
    c_birth_country,
    c_login,
    c_email_address,
    c_last_review_date,
    ir.total_return_amt
FROM 
    indiana_returns ir
JOIN 
    customer c ON ir.sr_customer_sk = c_customer_sk
CROSS JOIN 
    average_return ar
WHERE 
    ir.total_return_amt > 1.2 * ar.avg_return_amt
ORDER BY 
    c_customer_id, c_first_name, c_last_name
LIMIT 100;


