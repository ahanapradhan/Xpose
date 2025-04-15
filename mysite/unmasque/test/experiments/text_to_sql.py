import os
import sys
from abc import abstractmethod

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../..')))

import tiktoken
from openai import OpenAI

from mysite.unmasque.src.util.ConnectionFactory import ConnectionHelperFactory
from mysite.unmasque.src.util.constants import OK

TPCDS_Schema = """CREATE TABLE call_center(cc_call_center_sk INTEGER, cc_call_center_id VARCHAR, cc_rec_start_date DATE, cc_rec_end_date DATE, cc_closed_date_sk INTEGER, cc_open_date_sk INTEGER, cc_name VARCHAR, cc_class VARCHAR, cc_employees INTEGER, cc_sq_ft INTEGER, cc_hours VARCHAR, cc_manager VARCHAR, cc_mkt_id INTEGER, cc_mkt_class VARCHAR, cc_mkt_desc VARCHAR, cc_market_manager VARCHAR, cc_division INTEGER, cc_division_name VARCHAR, cc_company INTEGER, cc_company_name VARCHAR, cc_street_number VARCHAR, cc_street_name VARCHAR, cc_street_type VARCHAR, cc_suite_number VARCHAR, cc_city VARCHAR, cc_county VARCHAR, cc_state VARCHAR, cc_zip VARCHAR, cc_country VARCHAR, cc_gmt_offset DECIMAL(5,2), cc_tax_percentage DECIMAL(5,2));
CREATE TABLE catalog_page(cp_catalog_page_sk INTEGER, cp_catalog_page_id VARCHAR, cp_start_date_sk INTEGER, cp_end_date_sk INTEGER, cp_department VARCHAR, cp_catalog_number INTEGER, cp_catalog_page_number INTEGER, cp_description VARCHAR, cp_type VARCHAR);
CREATE TABLE catalog_returns(cr_returned_date_sk INTEGER, cr_returned_time_sk INTEGER, cr_item_sk INTEGER, cr_refunded_customer_sk INTEGER, cr_refunded_cdemo_sk INTEGER, cr_refunded_hdemo_sk INTEGER, cr_refunded_addr_sk INTEGER, cr_returning_customer_sk INTEGER, cr_returning_cdemo_sk INTEGER, cr_returning_hdemo_sk INTEGER, cr_returning_addr_sk INTEGER, cr_call_center_sk INTEGER, cr_catalog_page_sk INTEGER, cr_ship_mode_sk INTEGER, cr_warehouse_sk INTEGER, cr_reason_sk INTEGER, cr_order_number INTEGER, cr_return_quantity INTEGER, cr_return_amount DECIMAL(7,2), cr_return_tax DECIMAL(7,2), cr_return_amt_inc_tax DECIMAL(7,2), cr_fee DECIMAL(7,2), cr_return_ship_cost DECIMAL(7,2), cr_refunded_cash DECIMAL(7,2), cr_reversed_charge DECIMAL(7,2), cr_store_credit DECIMAL(7,2), cr_net_loss DECIMAL(7,2));
CREATE TABLE catalog_sales(cs_sold_date_sk INTEGER, cs_sold_time_sk INTEGER, cs_ship_date_sk INTEGER, cs_bill_customer_sk INTEGER, cs_bill_cdemo_sk INTEGER, cs_bill_hdemo_sk INTEGER, cs_bill_addr_sk INTEGER, cs_ship_customer_sk INTEGER, cs_ship_cdemo_sk INTEGER, cs_ship_hdemo_sk INTEGER, cs_ship_addr_sk INTEGER, cs_call_center_sk INTEGER, cs_catalog_page_sk INTEGER, cs_ship_mode_sk INTEGER, cs_warehouse_sk INTEGER, cs_item_sk INTEGER, cs_promo_sk INTEGER, cs_order_number INTEGER, cs_quantity INTEGER, cs_wholesale_cost DECIMAL(7,2), cs_list_price DECIMAL(7,2), cs_sales_price DECIMAL(7,2), cs_ext_discount_amt DECIMAL(7,2), cs_ext_sales_price DECIMAL(7,2), cs_ext_wholesale_cost DECIMAL(7,2), cs_ext_list_price DECIMAL(7,2), cs_ext_tax DECIMAL(7,2), cs_coupon_amt DECIMAL(7,2), cs_ext_ship_cost DECIMAL(7,2), cs_net_paid DECIMAL(7,2), cs_net_paid_inc_tax DECIMAL(7,2), cs_net_paid_inc_ship DECIMAL(7,2), cs_net_paid_inc_ship_tax DECIMAL(7,2), cs_net_profit DECIMAL(7,2));
CREATE TABLE customer(c_customer_sk INTEGER, c_customer_id VARCHAR, c_current_cdemo_sk INTEGER, c_current_hdemo_sk INTEGER, c_current_addr_sk INTEGER, c_first_shipto_date_sk INTEGER, c_first_sales_date_sk INTEGER, c_salutation VARCHAR, c_first_name VARCHAR, c_last_name VARCHAR, c_preferred_cust_flag VARCHAR, c_birth_day INTEGER, c_birth_month INTEGER, c_birth_year INTEGER, c_birth_country VARCHAR, c_login VARCHAR, c_email_address VARCHAR, c_last_review_date_sk INTEGER);
CREATE TABLE customer_address(ca_address_sk INTEGER, ca_address_id VARCHAR, ca_street_number VARCHAR, ca_street_name VARCHAR, ca_street_type VARCHAR, ca_suite_number VARCHAR, ca_city VARCHAR, ca_county VARCHAR, ca_state VARCHAR, ca_zip VARCHAR, ca_country VARCHAR, ca_gmt_offset DECIMAL(5,2), ca_location_type VARCHAR);
CREATE TABLE customer_demographics(cd_demo_sk INTEGER, cd_gender VARCHAR, cd_marital_status VARCHAR, cd_education_status VARCHAR, cd_purchase_estimate INTEGER, cd_credit_rating VARCHAR, cd_dep_count INTEGER, cd_dep_employed_count INTEGER, cd_dep_college_count INTEGER);
CREATE TABLE date_dim(d_date_sk INTEGER, d_date_id VARCHAR, d_date DATE, d_month_seq INTEGER, d_week_seq INTEGER, d_quarter_seq INTEGER, d_year INTEGER, d_dow INTEGER, d_moy INTEGER, d_dom INTEGER, d_qoy INTEGER, d_fy_year INTEGER, d_fy_quarter_seq INTEGER, d_fy_week_seq INTEGER, d_day_name VARCHAR, d_quarter_name VARCHAR, d_holiday VARCHAR, d_weekend VARCHAR, d_following_holiday VARCHAR, d_first_dom INTEGER, d_last_dom INTEGER, d_same_day_ly INTEGER, d_same_day_lq INTEGER, d_current_day VARCHAR, d_current_week VARCHAR, d_current_month VARCHAR, d_current_quarter VARCHAR, d_current_year VARCHAR);
CREATE TABLE household_demographics(hd_demo_sk INTEGER, hd_income_band_sk INTEGER, hd_buy_potential VARCHAR, hd_dep_count INTEGER, hd_vehicle_count INTEGER);
CREATE TABLE income_band(ib_income_band_sk INTEGER, ib_lower_bound INTEGER, ib_upper_bound INTEGER);
CREATE TABLE inventory(inv_date_sk INTEGER, inv_item_sk INTEGER, inv_warehouse_sk INTEGER, inv_quantity_on_hand INTEGER);
CREATE TABLE item(i_item_sk INTEGER, i_item_id VARCHAR, i_rec_start_date DATE, i_rec_end_date DATE, i_item_desc VARCHAR, i_current_price DECIMAL(7,2), i_wholesale_cost DECIMAL(7,2), i_brand_id INTEGER, i_brand VARCHAR, i_class_id INTEGER, i_class VARCHAR, i_category_id INTEGER, i_category VARCHAR, i_manufact_id INTEGER, i_manufact VARCHAR, i_size VARCHAR, i_formulation VARCHAR, i_color VARCHAR, i_units VARCHAR, i_container VARCHAR, i_manager_id INTEGER, i_product_name VARCHAR);
CREATE TABLE promotion(p_promo_sk INTEGER, p_promo_id VARCHAR, p_start_date_sk INTEGER, p_end_date_sk INTEGER, p_item_sk INTEGER, p_cost DECIMAL(15,2), p_response_target INTEGER, p_promo_name VARCHAR, p_channel_dmail VARCHAR, p_channel_email VARCHAR, p_channel_catalog VARCHAR, p_channel_tv VARCHAR, p_channel_radio VARCHAR, p_channel_press VARCHAR, p_channel_event VARCHAR, p_channel_demo VARCHAR, p_channel_details VARCHAR, p_purpose VARCHAR, p_discount_active VARCHAR);
CREATE TABLE reason(r_reason_sk INTEGER, r_reason_id VARCHAR, r_reason_desc VARCHAR);
CREATE TABLE ship_mode(sm_ship_mode_sk INTEGER, sm_ship_mode_id VARCHAR, sm_type VARCHAR, sm_code VARCHAR, sm_carrier VARCHAR, sm_contract VARCHAR);
CREATE TABLE store(s_store_sk INTEGER, s_store_id VARCHAR, s_rec_start_date DATE, s_rec_end_date DATE, s_closed_date_sk INTEGER, s_store_name VARCHAR, s_number_employees INTEGER, s_floor_space INTEGER, s_hours VARCHAR, s_manager VARCHAR, s_market_id INTEGER, s_geography_class VARCHAR, s_market_desc VARCHAR, s_market_manager VARCHAR, s_division_id INTEGER, s_division_name VARCHAR, s_company_id INTEGER, s_company_name VARCHAR, s_street_number VARCHAR, s_street_name VARCHAR, s_street_type VARCHAR, s_suite_number VARCHAR, s_city VARCHAR, s_county VARCHAR, s_state VARCHAR, s_zip VARCHAR, s_country VARCHAR, s_gmt_offset DECIMAL(5,2), s_tax_percentage DECIMAL(5,2));
CREATE TABLE store_returns(sr_returned_date_sk INTEGER, sr_return_time_sk INTEGER, sr_item_sk INTEGER, sr_customer_sk INTEGER, sr_cdemo_sk INTEGER, sr_hdemo_sk INTEGER, sr_addr_sk INTEGER, sr_store_sk INTEGER, sr_reason_sk INTEGER, sr_ticket_number INTEGER, sr_return_quantity INTEGER, sr_return_amt DECIMAL(7,2), sr_return_tax DECIMAL(7,2), sr_return_amt_inc_tax DECIMAL(7,2), sr_fee DECIMAL(7,2), sr_return_ship_cost DECIMAL(7,2), sr_refunded_cash DECIMAL(7,2), sr_reversed_charge DECIMAL(7,2), sr_store_credit DECIMAL(7,2), sr_net_loss DECIMAL(7,2));
CREATE TABLE store_sales(ss_sold_date_sk INTEGER, ss_sold_time_sk INTEGER, ss_item_sk INTEGER, ss_customer_sk INTEGER, ss_cdemo_sk INTEGER, ss_hdemo_sk INTEGER, ss_addr_sk INTEGER, ss_store_sk INTEGER, ss_promo_sk INTEGER, ss_ticket_number INTEGER, ss_quantity INTEGER, ss_wholesale_cost DECIMAL(7,2), ss_list_price DECIMAL(7,2), ss_sales_price DECIMAL(7,2), ss_ext_discount_amt DECIMAL(7,2), ss_ext_sales_price DECIMAL(7,2), ss_ext_wholesale_cost DECIMAL(7,2), ss_ext_list_price DECIMAL(7,2), ss_ext_tax DECIMAL(7,2), ss_coupon_amt DECIMAL(7,2), ss_net_paid DECIMAL(7,2), ss_net_paid_inc_tax DECIMAL(7,2), ss_net_profit DECIMAL(7,2));
CREATE TABLE time_dim(t_time_sk INTEGER, t_time_id VARCHAR, t_time INTEGER, t_hour INTEGER, t_minute INTEGER, t_second INTEGER, t_am_pm VARCHAR, t_shift VARCHAR, t_sub_shift VARCHAR, t_meal_time VARCHAR);
CREATE TABLE warehouse(w_warehouse_sk INTEGER, w_warehouse_id VARCHAR, w_warehouse_name VARCHAR, w_warehouse_sq_ft INTEGER, w_street_number VARCHAR, w_street_name VARCHAR, w_street_type VARCHAR, w_suite_number VARCHAR, w_city VARCHAR, w_county VARCHAR, w_state VARCHAR, w_zip VARCHAR, w_country VARCHAR, w_gmt_offset DECIMAL(5,2));
CREATE TABLE web_page(wp_web_page_sk INTEGER, wp_web_page_id VARCHAR, wp_rec_start_date DATE, wp_rec_end_date DATE, wp_creation_date_sk INTEGER, wp_access_date_sk INTEGER, wp_autogen_flag VARCHAR, wp_customer_sk INTEGER, wp_url VARCHAR, wp_type VARCHAR, wp_char_count INTEGER, wp_link_count INTEGER, wp_image_count INTEGER, wp_max_ad_count INTEGER);
CREATE TABLE web_returns(wr_returned_date_sk INTEGER, wr_returned_time_sk INTEGER, wr_item_sk INTEGER, wr_refunded_customer_sk INTEGER, wr_refunded_cdemo_sk INTEGER, wr_refunded_hdemo_sk INTEGER, wr_refunded_addr_sk INTEGER, wr_returning_customer_sk INTEGER, wr_returning_cdemo_sk INTEGER, wr_returning_hdemo_sk INTEGER, wr_returning_addr_sk INTEGER, wr_web_page_sk INTEGER, wr_reason_sk INTEGER, wr_order_number INTEGER, wr_return_quantity INTEGER, wr_return_amt DECIMAL(7,2), wr_return_tax DECIMAL(7,2), wr_return_amt_inc_tax DECIMAL(7,2), wr_fee DECIMAL(7,2), wr_return_ship_cost DECIMAL(7,2), wr_refunded_cash DECIMAL(7,2), wr_reversed_charge DECIMAL(7,2), wr_account_credit DECIMAL(7,2), wr_net_loss DECIMAL(7,2));
CREATE TABLE web_sales(ws_sold_date_sk INTEGER, ws_sold_time_sk INTEGER, ws_ship_date_sk INTEGER, ws_item_sk INTEGER, ws_bill_customer_sk INTEGER, ws_bill_cdemo_sk INTEGER, ws_bill_hdemo_sk INTEGER, ws_bill_addr_sk INTEGER, ws_ship_customer_sk INTEGER, ws_ship_cdemo_sk INTEGER, ws_ship_hdemo_sk INTEGER, ws_ship_addr_sk INTEGER, ws_web_page_sk INTEGER, ws_web_site_sk INTEGER, ws_ship_mode_sk INTEGER, ws_warehouse_sk INTEGER, ws_promo_sk INTEGER, ws_order_number INTEGER, ws_quantity INTEGER, ws_wholesale_cost DECIMAL(7,2), ws_list_price DECIMAL(7,2), ws_sales_price DECIMAL(7,2), ws_ext_discount_amt DECIMAL(7,2), ws_ext_sales_price DECIMAL(7,2), ws_ext_wholesale_cost DECIMAL(7,2), ws_ext_list_price DECIMAL(7,2), ws_ext_tax DECIMAL(7,2), ws_coupon_amt DECIMAL(7,2), ws_ext_ship_cost DECIMAL(7,2), ws_net_paid DECIMAL(7,2), ws_net_paid_inc_tax DECIMAL(7,2), ws_net_paid_inc_ship DECIMAL(7,2), ws_net_paid_inc_ship_tax DECIMAL(7,2), ws_net_profit DECIMAL(7,2));
CREATE TABLE web_site(web_site_sk INTEGER, web_site_id VARCHAR, web_rec_start_date DATE, web_rec_end_date DATE, web_name VARCHAR, web_open_date_sk INTEGER, web_close_date_sk INTEGER, web_class VARCHAR, web_manager VARCHAR, web_mkt_id INTEGER, web_mkt_class VARCHAR, web_mkt_desc VARCHAR, web_market_manager VARCHAR, web_company_id INTEGER, web_company_name VARCHAR, web_street_number VARCHAR, web_street_name VARCHAR, web_street_type VARCHAR, web_suite_number VARCHAR, web_city VARCHAR, web_county VARCHAR, web_state VARCHAR, web_zip VARCHAR, web_country VARCHAR, web_gmt_offset DECIMAL(5,2), web_tax_percentage DECIMAL(5,2));
"""

conn = ConnectionHelperFactory().createConnectionHelper()
conn.config.schema = conn.config.user_schema
conn.data_schema = conn.config.user_schema
conn.schema = conn.config.user_schema
print(conn.config.user_schema)
print(conn.data_schema)
print(conn.schema)
print(conn.config.schema)


def create_query_translator(gpt_model):
    if gpt_model == "o3":
        return GptO3MiniTranslator()
    elif gpt_model == "4o":
        return Gpt4OTranslator()
    else:
        raise ValueError("Model not supported!")


class Translator:
    def __init__(self, name):
        self.name = name
        self.working_dir_path = "../gpt_sql/"
        self.output_filename = "gpt_sql.sql"
        self.qfolder_path = '../gpt_text'
        self.client = None

    @abstractmethod
    def count_tokens(self, text):
        pass

    @abstractmethod
    def doJob(self, text):
        # gets API Key from environment variable OPENAI_API_KEY
        self.client = OpenAI()

    def give_filename(self, qkey):
        return f"{self.name}_{qkey}_{self.output_filename}"

    def post_process(self, reply):
        rlines = reply.strip().splitlines()
        nlines = [line for line in rlines if not line.strip().startswith('--')]
        new_lines1 = [line for line in nlines if not line.strip().startswith('```')]
        qe_query = ' '.join(line.strip() for line in new_lines1 if line.strip())
        if not len(qe_query.strip()):
            return qe_query, ""
        try:
            conn.connectUsingParams()
            conn.begin_transaction()
            conn.execute_sql_fetchall(f"EXPLAIN {qe_query}")
            return qe_query, ""
        except Exception as e:
            print(f"Particular error: {str(e)}")
            print(f"Query: {qe_query}")
            return qe_query, str(e)
        finally:
            conn.rollback_transaction()
            conn.closeConnection()

    def doJob_loop(self, question, qkey, sql, append=False):
        sql_text = " ".join(sql)
        original_question = f"{question} {sql_text}\n\n Consider the following schema while formulating SQL.\n " \
                            f"Schema: \"{TPCDS_Schema}\""
        print(original_question)
        reply = self.doJob(original_question)
        check, problem = self.post_process(reply)
        num = 0
        cutoff = 20
        while True:
            next_question = f"{original_question}\nYou formulated the following query:\t" \
                            f"\"{check}\"\n The query has the following error:\n" \
                            f"\"{problem}\". \nFix it.\n"
            print(next_question)
            reply = self.doJob(next_question)
            check, problem = self.post_process(reply)
            num = num + 1
            if not len(problem) or num >= cutoff:
                break

        working_dir = self.working_dir_path
        if not os.path.exists(working_dir):
            os.makedirs(working_dir)
        outfile = f"{working_dir}{self.give_filename(qkey)}"
        orig_out = sys.stdout
        mode = 'a' if append else 'w'
        f = open(outfile, mode)
        sys.stdout = f
        print(check)
        sys.stdout = orig_out
        f.close()
        mode_name = 'appended' if mode == 'a' else 'written'
        print(f"Text {mode_name} into {outfile}")
        return check


class GptO3MiniTranslator(Translator):
    def __init__(self):
        super().__init__("o3-mini")

    def count_tokens(self, text):
        raise NotImplementedError

    def doJob(self, text):
        super().doJob(text)
        response = self.client.chat.completions.create(
            model=self.name,
            messages=[
                {
                    "role": "user",
                    "content": f"{text}",
                },
            ]
        )
        reply = response.choices[0].message.content
        # print(reply)
        return reply


class Gpt4OTranslator(Translator):

    def __init__(self):
        super().__init__("gpt-4o")

    def count_tokens(self, text):
        encoding = tiktoken.encoding_for_model(self.name)
        tokens = encoding.encode(text)
        return len(tokens)

    def doJob(self, text):
        super().doJob(text)
        response = self.client.chat.completions.create(
            model=self.name,
            messages=[
                {
                    "role": "user",
                    "content": f"{text}",
                },
            ], temperature=0, stream=False
        )
        reply = response.choices[0].message.content
        # print(reply)
        # c_token = self.count_tokens(text)
        # print(f"\n-- Prompt Token count = {c_token}\n")
        return reply


if __name__ == '__main__':
    if len(sys.argv) < 2:
        model_name = '4o'
        print("Using gpt-4o")
    else:
        model_name = sys.argv[1]

    translator = create_query_translator(model_name)

    prompt = "You are an expert in SQL. " \
             "Formulate SQL query that suits the following natural language text description in English." \
             "Only give the SQL, do not add any explanation. " \
             "Please ensure the SQL query is correct and optimized. Text: "
    for filename in os.listdir(translator.qfolder_path):
        if filename.endswith('.txt') and filename == 'gpt-4o_query1_gpt_text.txt':
            keys = filename.split("_")
            key = keys[1]
            file_path = os.path.join(translator.qfolder_path, filename)

            # Read lines from the file
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()

            new_lines = [line for line in lines if not line.strip().startswith('--')]
            q_sql = new_lines
            output1 = translator.doJob_loop(prompt, key, q_sql)
            print(output1)
            # Write the updated content back to the file
            with open(file_path, 'w', encoding='utf-8') as f:
                f.writelines(lines)

            print(f"Processed: {filename}")
