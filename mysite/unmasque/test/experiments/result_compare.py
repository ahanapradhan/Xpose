import os
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../..')))

from mysite.unmasque.src.core.result_comparator import ResultComparator
from mysite.unmasque.src.util.ConnectionFactory import ConnectionHelperFactory
from text_to_sql import create_query_translator

# Set your folder path here
qh_folder_path = '../tpcds-queries'
xfe_folder_path = '../gpt_sql'
check_list = './xfe_checklist.txt'
conn = ConnectionHelperFactory().createConnectionHelper()
conn.config.schema = conn.config.user_schema
conn.data_schema = conn.config.user_schema
conn.schema = conn.config.user_schema
print(conn.config.user_schema)
print(conn.data_schema)
print(conn.schema)
print(conn.config.schema)


def do_for_a_pair():
    # Join all lines into a single SQL query
    qh_query = ' '.join(line.strip() for line in qh if line.strip())  # removes newlines and empty lines
    print("QH Query:")
    print(qh_query)
    try:
        conn.begin_transaction()
        res1 = conn.execute_sql_fetchall(qh_query)
    except Exception as e:
        print(f"{str(e)}")
        return [0], "QH Error"
    finally:
        conn.rollback_transaction()

    # print(res1)
    qe_query = ' '.join(line.strip() for line in xfe_qe if line.strip())  # removes newlines and empty lines
    print("QE Query:")
    print(qe_query)
    try:
        conn.begin_transaction()
        check1 = rc.match(qh_query, qe_query)
    except Exception as e:
        print(f"{str(e)}")
        check1 = "Error"
    finally:
        conn.rollback_transaction()
    return res1, check1


if __name__ == '__main__':

    # Loop through all files in the folder
    gpt_agent = create_query_translator("4o")
    conn.connectUsingParams()
    rc = ResultComparator(conn, False)

    y_counter = 0
    n_counter = 0
    err_counter = 0
    qh_error = 0
    output_filepath = os.path.join(check_list)

    for filename in os.listdir(qh_folder_path):
        if filename.endswith('.sql'):
            keys = filename.split('.')
            qkey = keys[0]
            qh_file_path = os.path.join(qh_folder_path, filename)
            xfe_file_path = os.path.join(xfe_folder_path, gpt_agent.give_filename(qkey))
            print(f"{qh_file_path} : {xfe_file_path}")

            with open(qh_file_path, 'r', encoding='utf-8') as fh:
                qh = fh.readlines()
                with open(xfe_file_path, 'r', encoding='utf-8') as fe:
                    xfe_qe = fe.readlines()
                    # conn.begin_transaction()
                    res, check = do_for_a_pair()
                    # conn.rollback_transaction()
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
                        fo.writelines(f"{qkey}\t\t{str(len(res) >= 2)}\t\t{str(check)}\n")

            # break
    with open(output_filepath, 'a', encoding='utf-8') as fo:
        fo.writelines(
            f"\n\nOverall Stats\nillegal QH: {qh_error}\nillegal QE: {err_counter}\nmatch: {y_counter}\nmismatch: {n_counter}\n")
    conn.closeConnection()
