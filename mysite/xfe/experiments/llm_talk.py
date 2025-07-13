from abc import abstractmethod

import tiktoken
from openai import OpenAI

O3_MINI = 'o3-mini'
GPT_4O = 'gpt-4o'
ROLE = "role"
USER = "user"
CONTENT = "content"


class TalkToLLM:

    def __init__(self, name):
        self.name = name
        self.client = None

    @abstractmethod
    def count_tokens(self, text):
        pass

    @abstractmethod
    def doJob(self, text):
        # gets API Key from environment variable OPENAI_API_KEY
        self.client = OpenAI()

    def _remove_comments_from_reply(self, reply):
        rlines = reply.strip().splitlines()
        nlines = [line for line in rlines if not line.strip().startswith('--')]
        new_lines1 = [line for line in nlines if not line.strip().startswith('```')]
        answer = ' '.join(line.strip() for line in new_lines1 if line.strip())
        return answer


class TalkToGptO3Mini(TalkToLLM):
    def __init__(self):
        super().__init__(O3_MINI)

    def count_tokens(self, text):
        raise NotImplementedError

    def doJob(self, text):
        super().doJob(text)
        response = self.client.chat.completions.create(
            model=self.name,
            messages=[
                {
                    ROLE: USER,
                    CONTENT: f"{text}",
                },
            ]
        )
        reply = response.choices[0].message.content
        answer = self._remove_comments_from_reply(reply)
        print(answer)
        return answer


class TalkToGpt4O(TalkToLLM):

    def __init__(self):
        super().__init__(GPT_4O)

    def count_tokens(self, text):
        encoding = tiktoken.encoding_for_model(self.name)
        tokens = encoding.encode(text)
        return len(tokens)

    def doJob(self, text):
        super().doJob(text)
        response = self.client.chat.completions.create(
            model=self.name,
            messages=[
                {
                    ROLE: USER,
                    CONTENT: f"{text}",
                },
            ], temperature=0, stream=False
        )
        reply = response.choices[0].message.content
        answer = self._remove_comments_from_reply(reply)
        print(answer)
        return answer
