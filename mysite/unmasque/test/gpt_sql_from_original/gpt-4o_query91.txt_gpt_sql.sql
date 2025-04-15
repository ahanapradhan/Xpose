SELECT cc.cc_name AS call_center_name, cc.cc_manager AS manager, SUM(cr.cr_return_amount) AS total_returns FROM catalog_returns cr JOIN call_center cc ON cr.cr_call_center_sk = cc.cc_call_center_sk JOIN customer c ON cr.cr_refunded_customer_sk = c.c_customer_sk JOIN customer_demographics cd ON cr.cr_refunded_cdemo_sk = cd.cd_demo_sk JOIN household_demographics hd ON cr.cr_refunded_hdemo_sk = hd.hd_demo_sk JOIN customer_address ca ON cr.cr_refunded_addr_sk = ca.ca_address_sk JOIN date_dim d ON cr.cr_returned_date_sk = d.d_date_sk WHERE d.d_month_seq = ? AND ( (cd.cd_gender = 'M' AND cd.cd_education_status = 'Unknown') OR (cd.cd_gender = 'F' AND cd.cd_education_status = 'Advanced Degree') ) AND hd.hd_buy_potential = ? AND ca.ca_gmt_offset = ? GROUP BY cc.cc_name, cc.cc_manager;
