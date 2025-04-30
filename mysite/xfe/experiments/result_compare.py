import os
import sys
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../..')))
from mysite.xfe.experiments.utils import give_conn, load_config, BENCHMARK_SQL, XFE_DIR, \
    readline_ignoring_comments, MODEL, TEXT_TYPE
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../..')))
from mysite.xfe.experiments.text_to_sql import create_text2SQL_agent

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../..')))

from mysite.unmasque.src.core.result_comparator import ResultComparator

# Set your folder path here
config = load_config()
qh_folder_path = f"../{config[BENCHMARK_SQL]}"
xfe_folder_path = f"../{config[XFE_DIR]}"
check_list = './xfe_checklist.txt'


def get_result_set(con, query):
    try:
        con.begin_transaction()
        rows, _ = con.execute_sql_fetchall(query)
        con.rollback_transaction()       # or con.commit_transaction()
    except Exception:
        con.rollback_transaction()
        rows = []
    return set(frozenset(rows))



def jaccard_similarity_from_results(con, qh_query, qe_query):
    # Execute both queries
    result1 = get_result_set(con, qh_query)
    result2 = get_result_set(con, qe_query)

    # Compute Jaccard similarity
    intersection = result1 & result2
    union = result1 | result2

    if not union:
        return 1.0  # Consider identical when both are empty
    return round(len(intersection) / len(union), 2)

def do_for_a_pair(rcomp: ResultComparator):
    # Join all lines into a single SQL query
    con = rcomp.connectionHelper
    jsim = 1
    qh_query = ' '.join(line.strip() for line in qh if line.strip())  # removes newlines and empty lines
    print("QH Query:")
    print(qh_query)
    try:
        con.begin_transaction()
        res1 = con.execute_sql_fetchall(qh_query)
    except Exception as e:
        print(f"{str(e)}")
        return [0], "QH Error",0
    finally:
        con.rollback_transaction()

    qe_query = ' '.join(line.strip() for line in xfe_qe if line.strip())  # removes newlines and empty lines
    print("QE Query:")
    print(qe_query)
    try:
        con.begin_transaction()
        check1 = rcomp.match(qh_query, qe_query)
    except Exception as e:
        print(f"{str(e)}")
        check1 = "Error"
        jsim = 0
    finally:
        con.rollback_transaction()

    if jsim:
        jsim = jaccard_similarity_from_results(con, qh_query, qe_query)
    return res1, check1, jsim



if __name__ == '__main__':

    # Loop through all files in the folder
    gpt_agent = create_text2SQL_agent(config[MODEL])
    # conn = give_conn()
    # conn.connectUsingParams()
    #
    # rc = ResultComparator(conn, False)
    y_counter = 0
    n_counter = 0
    err_counter = 0
    qh_error = 0
    output_filepath = os.path.join(check_list)

    with open(output_filepath, 'a', encoding='utf-8') as fo:
        fo.writelines(f"QID\t\t FIT-result\t\tO/P_Match?\tO/P_Jaccard_Sim\n")

    for filename in os.listdir(qh_folder_path):
        if filename.endswith('.sql'):
            keys = filename.split('.')
            qkey = keys[0]
            qh_file_path = os.path.join(qh_folder_path, filename)
            xfe_file_path = os.path.join(xfe_folder_path, gpt_agent.give_filename(qkey))
            print(f"{qh_file_path} : {xfe_file_path}")

            qh = readline_ignoring_comments(qh_file_path)
            xfe_qe = readline_ignoring_comments(xfe_file_path)
            conn = give_conn()
            conn.connectUsingParams()
            rc = ResultComparator(conn, False)
            res, check, sim = do_for_a_pair(rc)
            conn.autocommit = True
            # Each command is independent and errors won’t block future queries.

            conn.closeConnection()
            if check == "Error":
                err_counter = err_counter + 1
            elif check == "QH Error":
                print(f"Check QH for {qkey}")
                qh_error = qh_error + 1
            elif not check:
                n_counter = n_counter + 1
            else:
                y_counter = y_counter + 1
            with open(output_filepath, 'a', encoding='utf-8') as fo:
                fo.writelines(f"{qkey}\t\t{str(len(res) >= 2)}\t\t{str(check)}\t\t{str(sim)}\n")


            # break
    with open(output_filepath, 'a', encoding='utf-8') as fo:
        fo.writelines(
            f"\n\nOverall Stats({config[TEXT_TYPE]}) \nillegal QH: {qh_error}\nillegal QE: {err_counter}\nmatch: {y_counter}\nmismatch: {n_counter}\n")

    conn.closeConnection()
