SELECT 
    cc_call_center_id,
    cc_name,
    cc_manager,
    SUM(cr_return_amt_inc_tax - cr_net_loss) AS total_returns_loss
FROM
    call_center
JOIN
    catalog_returns ON cr_call_center_sk = cc_call_center_sk
JOIN
    customer ON cr_returning_customer_sk = c_customer_sk
JOIN
    customer_demographics ON c_current_cdemo_sk = cd_demo_sk
JOIN
    household_demographics ON c_current_hdemo_sk = hd_demo_sk
JOIN
    time_dim ON cr_returned_date_sk = t_time_sk
JOIN
    date_dim ON t_date_sk = d_date_sk
WHERE
    d_year = 1999
    AND d_month = 12
    AND ((cd_marital_status = 'M' AND cd_education_status = 'Unknown') 
         OR (cd_marital_status = 'W' AND cd_education_status = 'Advanced Degree'))
    AND hd_buy_potential = 'Unknown'
    AND cc_gmt_offset = -7
GROUP BY 
    cc_call_center_id, cc_name, cc_manager
ORDER BY 
    total_returns_loss DESC;


