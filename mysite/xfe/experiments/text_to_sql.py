import os
import sys
from abc import abstractmethod

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../..')))

from mysite.xfe.experiments.llm_talk import TalkToGpt4O, TalkToGptO3Mini

from mysite.xfe.experiments.utils import give_conn, load_config, \
    XFE_DIR, TEXT_DIR, MODEL, O_THREE, FOUR_O, readline_ignoring_comments

TPCH_Schema = """CREATE TABLE region (r_regionkey INTEGER PRIMARY KEY, r_name CHAR(25), r_comment VARCHAR(152));
CREATE TABLE nation (n_nationkey INTEGER PRIMARY KEY, n_name CHAR(25), n_regionkey INTEGER REFERENCES region(r_regionkey), n_comment VARCHAR(152));
CREATE TABLE supplier (s_suppkey INTEGER PRIMARY KEY, s_name CHAR(25), s_address VARCHAR(40), s_nationkey INTEGER REFERENCES nation(n_nationkey), s_phone CHAR(15), s_acctbal DECIMAL(15,2), s_comment VARCHAR(101));
CREATE TABLE part (p_partkey INTEGER PRIMARY KEY, p_name VARCHAR(55), p_mfgr CHAR(25), p_brand CHAR(10), p_type VARCHAR(25), p_size INTEGER, p_container CHAR(10), p_retailprice DECIMAL(15,2), p_comment VARCHAR(23));
CREATE TABLE partsupp (ps_partkey INTEGER REFERENCES part(p_partkey), ps_suppkey INTEGER REFERENCES supplier(s_suppkey), ps_availqty INTEGER, ps_supplycost DECIMAL(15,2), ps_comment VARCHAR(199), PRIMARY KEY (ps_partkey, ps_suppkey));
CREATE TABLE customer (c_custkey INTEGER PRIMARY KEY, c_name VARCHAR(25), c_address VARCHAR(40), c_nationkey INTEGER REFERENCES nation(n_nationkey), c_phone CHAR(15), c_acctbal DECIMAL(15,2), c_mktsegment CHAR(10), c_comment VARCHAR(117));
CREATE TABLE orders (o_orderkey INTEGER PRIMARY KEY, o_custkey INTEGER REFERENCES customer(c_custkey), o_orderstatus CHAR(1), o_totalprice DECIMAL(15,2), o_orderdate DATE, o_orderpriority CHAR(15), o_clerk CHAR(15), o_shippriority INTEGER, o_comment VARCHAR(79));
CREATE TABLE lineitem (l_orderkey INTEGER REFERENCES orders(o_orderkey), l_partkey INTEGER REFERENCES part(p_partkey), l_suppkey INTEGER REFERENCES supplier(s_suppkey), l_linenumber INTEGER, l_quantity DECIMAL(15,2), l_extendedprice DECIMAL(15,2), l_discount DECIMAL(15,2), l_tax DECIMAL(15,2), l_returnflag CHAR(1), l_linestatus CHAR(1), l_shipdate DATE, l_commitdate DATE, l_receiptdate DATE, l_shipinstruct CHAR(25), l_shipmode CHAR(10), l_comment VARCHAR(44), PRIMARY KEY (l_orderkey, l_linenumber));
"""

config = load_config()


class Text2SQLTranslator:
    def __init__(self, name):
        self.name = name
        self.working_dir_path = f"../{config[XFE_DIR]}/"
        self.qfolder_path = f"../{config[TEXT_DIR]}/"
        self.output_filename = "gpt_sql_tpch.sql"
        self.client = None
        self.loop_cutoff = 5

    def give_filename(self, qkey):
        return f"{self.name}_Q{qkey}_{self.output_filename}"

    def post_process(self, qe_query):
        conn = give_conn()
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
        original_question = f"{question} \"{sql_text}\"\n\n Consider the following schema while formulating SQL.\n " \
                            f"Schema: \"{TPCH_Schema}\""
        print(original_question)
        reply = self.doJob(original_question)
        check, problem = self.post_process(reply)
        num = 0
        while len(problem) and num < self.loop_cutoff:
            next_question = f"{original_question}\nYou formulated the following query:\t" \
                            f"\"{check}\"\n The query has the following error:\n" \
                            f"\"{problem}\". \nFix it.\n"
            print(next_question)
            reply = self.doJob(next_question)
            check, problem = self.post_process(reply)
            num = num + 1

        self._write_to_file(append, check, qkey)
        return check

    def _write_to_file(self, append, check, qkey):
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

    @abstractmethod
    def doJob(self, next_question):
        pass


class GptO3MiniText2SQLTranslator(TalkToGptO3Mini, Text2SQLTranslator):
    def __init__(self):
        TalkToGptO3Mini.__init__(self)
        Text2SQLTranslator.__init__(self, self.name)


class Gpt4OText2SQLTranslator(TalkToGpt4O, Text2SQLTranslator):

    def __init__(self):
        TalkToGpt4O.__init__(self)
        Text2SQLTranslator.__init__(self, self.name)


def create_text2SQL_agent(gpt_model):
    if gpt_model == O_THREE:
        return GptO3MiniText2SQLTranslator()
    elif gpt_model == FOUR_O:
        return Gpt4OText2SQLTranslator()
    else:
        raise ValueError("Model not supported!")


if __name__ == '__main__':

    translator = create_text2SQL_agent(config[MODEL])

    prompt = "You are an expert in SQL. " \
             "Formulate SQL query that suits the following natural language text description in English." \
             "Only give the SQL, do not add any explanation. " \
             "Do not keep any place-holder parameter in the query." \
             "Use valid data values as query constants, if the text does not mention them." \
             "Please ensure the SQL query is correct and optimized. Text: "
    for filename in os.listdir(translator.qfolder_path):
        if filename.endswith('.txt'):
            key = filename.split('_')[1].split('.')[0]
            file_path = os.path.join(translator.qfolder_path, filename)
            q_sql = readline_ignoring_comments(file_path)
            output1 = translator.doJob_loop(prompt, key, q_sql)
            # print(output1)
            print(f"Processed: {filename}")
