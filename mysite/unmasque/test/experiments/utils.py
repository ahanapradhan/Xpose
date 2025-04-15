
import configparser
import os

from mysite.unmasque.src.util.ConnectionFactory import ConnectionHelperFactory
from mysite.unmasque.test.experiments.sql_to_text import GptO3MiniSQL2TextTranslator, Gpt4OSQL2TextTranslator
from mysite.unmasque.test.experiments.text_to_sql import GptO3MiniText2SQLTranslator, Gpt4OText2SQLTranslator


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


ORIGINAL = "original"
GPT = "gpt"


def create_text2SQL_agent(gpt_model):
    if gpt_model == "o3":
        return GptO3MiniText2SQLTranslator()
    elif gpt_model == "4o":
        return Gpt4OText2SQLTranslator()
    else:
        raise ValueError("Model not supported!")


def create_SQL2text_agent(gpt_model):
    if gpt_model == "o3":
        return GptO3MiniSQL2TextTranslator()
    elif gpt_model == "4o":
        return Gpt4OSQL2TextTranslator()
    else:
        raise ValueError("Model not supported!")


def load_config():
    config = configparser.ConfigParser()
    config.read('./config.ini')

    # Get the selected text_type from [source]
    text_type = config['source']['text_type']

    # Load the section that matches the text_type
    if text_type not in config:
        raise ValueError(f"Section [{text_type}] not found in config.")

    text_dir = config[text_type]['text_dir']
    xfe_dir = config[text_type]['xfe_dir']

    return {
        'benchmark_sql': config['source']['benchmark_sql'],
        'text_type': text_type,
        'text_dir': text_dir,
        'xfe_dir': xfe_dir
    }


BENCHMARK_SQL = 'benchmark_sql'
XFE_DIR = 'xfe_dir'
TEXT_DIR = 'text_dir'
