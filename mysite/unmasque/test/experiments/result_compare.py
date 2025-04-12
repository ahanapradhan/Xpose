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

if __name__ == '__main__':

    # Loop through all files in the folder
    gpt_agent = create_query_translator("4o")
    conn = ConnectionHelperFactory().createConnectionHelper()
    rc = ResultComparator(conn, False)

    for filename in os.listdir(qh_folder_path):
        if filename.endswith('.sql'):
            keys = filename.split('.')
            qkey = keys[0]
            qh_file_path = os.path.join(qh_folder_path, filename)
            xfe_file_path = os.path.join(xfe_folder_path, gpt_agent.give_filename(qkey))
            output_filepath = os.path.join(check_list)
            print(f"{qh_file_path} : {xfe_file_path}")

            with open(qh_file_path, 'r', encoding='utf-8') as fh:
                qh = fh.readlines()
                with open(xfe_file_path, 'r', encoding='utf-8') as fe:
                    xfe_qe = fe.readlines()

                    # Join all lines into a single SQL query
                    qh_query = ' '.join(line.strip() for line in qh if line.strip())  # removes newlines and empty lines
                    print("QH Query:")
                    print(qh_query)
                    res = conn.execute_sql_fetchall(qh_query)
                    qe_query = ' '.join(line.strip() for line in xfe_qe if line.strip())  # removes newlines and empty lines
                    print("QE Query:")
                    print(qe_query)

                    check = rc.match(qh_query, qe_query)
                    with open(output_filepath, 'a', encoding='utf-8') as fo:
                        fo.writelines(f"{qkey} {str(len(res) >= 2)} {str(check)}\n")
            break
