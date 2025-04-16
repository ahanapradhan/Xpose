import os
import re
import sys
from abc import abstractmethod

from pdfminer.high_level import extract_text

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../..')))

from mysite.unmasque.test.experiments.llm_talk import TalkToGptO3Mini, TalkToGpt4O
from mysite.unmasque.test.experiments.utils import load_config, TEXT_DIR, BENCHMARK_SQL, MODEL, O_THREE, FOUR_O, \
    readline_ignoring_comments, pdf_path, TEXT_TYPE, ORIGINAL, CONSTANTS

config = load_config()


class SQL2TextTranslator:
    def __init__(self, name):
        self.name = name
        self.working_dir_path = f"../{config[TEXT_DIR]}/"
        self.output_filename = "gpt_text.txt"
        self.qfolder_path = f"../{config[BENCHMARK_SQL]}"

    @abstractmethod
    def doJob(self, text):
        pass

    def doJob_write(self, question, qkey, sql, append=False):
        print(question)
        working_dir = self.working_dir_path
        if not os.path.exists(working_dir):
            os.makedirs(working_dir)

        outfile = f"{working_dir}{self.name}_{qkey}_{self.output_filename}"

        orig_out = sys.stdout
        mode = 'a' if append else 'w'
        f = open(outfile, mode)
        sys.stdout = f
        reply = self.doJob(f"{question} {sql}")
        sys.stdout = orig_out
        f.close()
        mode_name = 'appended' if mode == 'a' else 'written'
        print(f"Text {mode_name} into {outfile}")
        return reply


class GptO3MiniSQL2TextTranslator(TalkToGptO3Mini, SQL2TextTranslator):
    def count_tokens(self, text):
        pass

    def __init__(self):
        TalkToGptO3Mini.__init__(self)
        SQL2TextTranslator.__init__(self, self.name)


class Gpt4OSQL2TextTranslator(TalkToGpt4O, SQL2TextTranslator):

    def __init__(self):
        TalkToGpt4O.__init__(self)
        SQL2TextTranslator.__init__(self, self.name)


def create_SQL2text_agent(gpt_model):
    if gpt_model == O_THREE:
        return GptO3MiniSQL2TextTranslator()
    elif gpt_model == FOUR_O:
        return Gpt4OSQL2TextTranslator()
    else:
        raise ValueError("Model not supported!")


def generate_text_from_sql():
    global prompt, filename, keys, key
    translator = create_SQL2text_agent(config[MODEL])
    prompt = "Give a high-level business description of the following SQL. " \
             "Give the descrption in a single English paragraph, suitable for a business manager. " \
             "Do not add any explanation. Put the paragraph inside double quotes. Here is the SQL:"
    for filename in os.listdir(translator.qfolder_path):
        if filename.endswith('.sql'):
            keys = filename.split(".")
            key = keys[0]
            file_path = os.path.join(translator.qfolder_path, filename)
            q_sql = readline_ignoring_comments(file_path)
            print(q_sql)
            output1 = translator.doJob_write(prompt, key, q_sql)
            print(output1)
            print(f"Processed: {filename}")


def get_text_from_documentation():
    output_dir = f"../{config[TEXT_DIR]}"
    # === Create output folder if it doesn't exist ===
    os.makedirs(output_dir, exist_ok=True)
    # === Extract all text from the PDF ===
    full_text = extract_text(pdf_path)
    query_pattern = __get_text_pattern(config[CONSTANTS])
    matches = query_pattern.findall(full_text)
    # === Save each description to separate file ===
    for _, qnum, desc, params in matches:
        cleaned_desc, qnum_int = __prepare_content(desc, params, qnum)

        textfile = f"query{qnum_int}.txt"
        print(textfile)
        filepath = os.path.join(output_dir, textfile)
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(cleaned_desc)

    print(f"✅ Saved {len(matches)} descriptions to folder: {output_dir}")


def __prepare_content(desc, params, qnum):
    qnum_int = int(qnum)
    cleaned_desc = ' '.join(desc.strip().split())
    content = f"{cleaned_desc}\n"
    if params:
        param_lines = []
        for line in params.strip().splitlines():
            line = line.strip()
            line = re.sub(r"^[•\-\*\u2022\uF0B7]+", "", line)  # Remove bullets like •, *, -, etc.
            line = re.sub(
                r'TPC Benchmark.*?Standard Specification, Version [\d\.]+ Page \d+ of \d+',
                '', line, flags=re.IGNORECASE
            )
            if line:
                param_lines.append(line.strip())
        if param_lines:
            content += "Query Constants:\n" + "\n".join(param_lines)
    return content, qnum_int


def __get_text_pattern(include_constants=False):
    if not include_constants:
        # === Regex pattern to find query descriptions before substitution parameters ===
        query_pattern = re.compile(
            r'(B\.(\d+)\s+query\d+\.tpl\s*)(.*?)(?=Qualification Substitution Parameters:)',
            re.DOTALL
        )
    else:
        # Regex pattern to capture descriptions + substitution parameters
        query_pattern = re.compile(
            r'(B\.(\d+)\s+query\d+\.tpl\s*)'  # Header with query number
            r'(.*?)'  # Description (non-greedy)
            r'(?:Qualification Substitution Parameters:\s*'  # Optional Subst section
            r'(.*?))?'  # Parameters (optional)
            r'(?=B\.\d+\s+query\d+\.tpl\s*|$)',  # Until next query or EOF
            re.DOTALL
        )
    return query_pattern


if __name__ == '__main__':
    text_type = config[TEXT_TYPE]
    if text_type == ORIGINAL:
        get_text_from_documentation()
    else:
        generate_text_from_sql()
