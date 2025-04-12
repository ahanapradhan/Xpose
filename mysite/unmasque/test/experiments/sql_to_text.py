import os
import sys
from abc import abstractmethod

import tiktoken
from openai import OpenAI

# gets API Key from environment variable OPENAI_API_KEY
client = OpenAI()


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
        self.working_dir_path = "../gpt_text/"
        self.output_filename = "gpt_text.txt"
        self.qfolder_path = '../tpcds-queries'

    @abstractmethod
    def count_tokens(self, text):
        pass

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


class GptO3MiniTranslator(Translator):
    def __init__(self):
        super().__init__("o3-mini")

    def count_tokens(self, text):
        raise NotImplementedError

    def doJob(self, text):
        response = client.chat.completions.create(
            model=self.name,
            messages=[
                {
                    "role": "user",
                    "content": f"{text}",
                },
            ]
        )
        reply = response.choices[0].message.content
        print(reply)
        return reply


class Gpt4OTranslator(Translator):

    def __init__(self):
        super().__init__("gpt-4o")

    def count_tokens(self, text):
        encoding = tiktoken.encoding_for_model(self.name)
        tokens = encoding.encode(text)
        return len(tokens)

    def doJob(self, text):
        response = client.chat.completions.create(
            model=self.name,
            messages=[
                {
                    "role": "user",
                    "content": f"{text}",
                },
            ], temperature=0, stream=False
        )
        reply = response.choices[0].message.content
        print(reply)
        c_token = self.count_tokens(text)
        print(f"\n-- Prompt Token count = {c_token}\n")
        return reply


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Specify LLM name!")
        exit()
    model_name = sys.argv[1]

    translator = create_query_translator(model_name)

    prompt = "Give a high-level business description of the following SQL. " \
             "Give the descrption in a single English paragraph, suitable for a business manager. " \
             "Do not add any explanation. Put the paragraph inside double quotes. Here is the SQL:"

    for filename in os.listdir(translator.qfolder_path):
        if filename.endswith('.sql'):
            keys = filename.split(".")
            key = keys[0]
            file_path = os.path.join(translator.qfolder_path, filename)

            # Read lines from the file
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()

            q_sql = lines
            output1 = translator.doJob_write(prompt, key, q_sql)
            print(output1)
            # Write the updated content back to the file
            with open(file_path, 'w', encoding='utf-8') as f:
                f.writelines(lines)

            print(f"Processed: {filename}")


