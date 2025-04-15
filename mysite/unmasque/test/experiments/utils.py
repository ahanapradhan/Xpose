
import configparser

from mysite.unmasque.src.util.ConnectionFactory import ConnectionHelperFactory


def give_conn():
    conn = ConnectionHelperFactory().createConnectionHelper()
    conn.config.schema = conn.config.user_schema
    conn.data_schema = conn.config.user_schema
    conn.schema = conn.config.user_schema
    print(conn.config.user_schema)
    print(conn.data_schema)
    print(conn.schema)
    print(conn.config.schema)
    return conn


def load_config():
    config = configparser.ConfigParser()
    config.read('./config.ini')

    # Get the selected text_type from [source]
    text_type = config['source']['text_type']

    # Load the section that matches the text_type
    if text_type not in config:
        raise ValueError(f"Section [{text_type}] not found in config.")

    text_dir = config[text_type][TEXT_DIR]
    xfe_dir = config[text_type][XFE_DIR]

    return {
        BENCHMARK_SQL: config['source'][BENCHMARK_SQL],
        'text_type': text_type,
        TEXT_DIR: text_dir,
        XFE_DIR: xfe_dir
    }


BENCHMARK_SQL = 'benchmark_sql'
XFE_DIR = 'xfe_dir'
TEXT_DIR = 'text_dir'
