import os
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../..')))

from mysite.unmasque.test.experiments.utils import give_conn, load_config, BENCHMARK_SQL, \
    XFE_DIR
from mysite.unmasque.test.experiments.text_to_sql import create_text2SQL_agent

# Set your folder path here
config = load_config()
qh_folder_path = f"../{config[BENCHMARK_SQL]}"
xfe_folder_path = f"../{config[XFE_DIR]}"
check_list = './sql_validlist.txt'


def do_for_a_pair():
    # Join all lines into a single SQL query
    qh_query = ' '.join(line.strip() for line in qh if line.strip())  # removes newlines and empty lines
    print("QH Query:")
    print(qh_query)
    try:
        conn.begin_transaction()
        conn.execute_sql_fetchall(f"EXPLAIN {qh_query}")
    except Exception as e:
        print(f"{str(e)}")
        return "QH Error"
    finally:
        conn.rollback_transaction()

    qe_query = ' '.join(line.strip() for line in xfe_qe if line.strip())  # removes newlines and empty lines
    print("QE Query:")
    print(qe_query)
    try:
        conn.begin_transaction()
        conn.execute_sql_fetchall(f"EXPLAIN {qe_query}")
        check1 = True
    except Exception as e:
        print(f"{str(e)}")
        check1 = "Error"
    finally:
        conn.rollback_transaction()
    return check1


if __name__ == '__main__':

    # Loop through all files in the folder
    gpt_agent = create_text2SQL_agent("4o")
    conn = give_conn()
    conn.connectUsingParams()

    err_counter = 0
    qh_error = 0
    output_filepath = os.path.join(check_list)

    for filename in os.listdir(qh_folder_path):
        if filename.endswith('.sql') and filename == 'query1.sql':
            keys = filename.split('.')
            qkey = keys[0]
            qh_file_path = os.path.join(qh_folder_path, filename)
            xfe_file_path = os.path.join(xfe_folder_path, gpt_agent.give_filename(qkey))
            print(f"{qh_file_path} : {xfe_file_path}")

            with open(qh_file_path, 'r', encoding='utf-8') as fh:
                qh = fh.readlines()
                with open(xfe_file_path, 'r', encoding='utf-8') as fe:
                    xfe_qe = fe.readlines()
                    check = do_for_a_pair()
                    if check == "Error":
                        err_counter = err_counter + 1
                    elif check == "QH Error":
                        print(f"Check QH for {qkey}")
                        qh_error = qh_error + 1
                    else:  # check = True
                        pass
                    with open(output_filepath, 'a', encoding='utf-8') as fo:
                        fo.writelines(f"{qkey}\t\t\t\t{str(check)}\n")

            # break
    with open(output_filepath, 'a', encoding='utf-8') as fo:
        fo.writelines(
            f"\n\nOverall Stats\nillegal QH: {qh_error}\nillegal QE: {err_counter}\n\n")
    conn.closeConnection()
