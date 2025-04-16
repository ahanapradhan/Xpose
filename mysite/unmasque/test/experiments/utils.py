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
    text_type = config[SOURCE][TEXT_TYPE]

    # Load the section that matches the text_type
    if text_type not in config:
        raise ValueError(f"Section [{text_type}] not found in config.")

    text_dir = config[text_type][TEXT_DIR]
    xfe_dir = config[text_type][XFE_DIR]
    model = config[SOURCE][MODEL]
    constants = True if config[text_type][CONSTANTS] == 'y' else False

    return {
        BENCHMARK_SQL: config[SOURCE][BENCHMARK_SQL],
        TEXT_TYPE: text_type,
        TEXT_DIR: text_dir,
        XFE_DIR: xfe_dir,
        MODEL: model,
        CONSTANTS: constants
    }


def readline_ignoring_comments(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    new_lines = [line for line in lines if not line.strip().startswith('--')]
    return new_lines


BENCHMARK_SQL = 'benchmark_sql'
XFE_DIR = 'xfe_dir'
TEXT_DIR = 'text_dir'
MODEL = 'model'
SOURCE = 'source'
TEXT_TYPE = 'text_type'
FOUR_O = '4o'
O_THREE = 'o3'
pdf_path = "tpc-ds_v2.1.0.pdf"
ORIGINAL = 'original'
LLM = 'llm'
CONSTANTS = 'constants'
