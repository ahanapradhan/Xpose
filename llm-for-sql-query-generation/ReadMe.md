# SQL Query Generator using LLM

This project uses a Large Language Model (LLM) to generate SQL queries from natural language prompts. It utilizes the `infly/inf-rl-qwen-coder-32b-2746` model via Hugging Face's Transformers library and supports TPC-H benchmark question prompts and schema.

---


## 🚀 Model Used

- **Model**: [`infly/inf-rl-qwen-coder-32b-2746`](https://huggingface.co/infly/inf-rl-qwen-coder-32b-2746)
- **Architecture**: Causal Language Model
- **Framework**: PyTorch + Hugging Face Transformers

---

## 📦 Requirements

Install dependencies using:

```bash
pip install torch transformers

```

## 📜 Description

The script reads natural language prompts (`Q_1.txt` to `Q_22.txt`) and a database schema (`tpch_schema.txt`), and then uses the LLM to generate optimized SQL queries for each input. The output queries are saved in the `llm_gen_query/` folder.

---

## 📂 Input Files

- **Natural Language Prompts**  
  Located in `tpch_original_prompt/` folder with names:  
  `Q_1.txt`, `Q_2.txt`, ..., `Q_22.txt`.

- **Database Schema**  
  File: `tpch_schema.txt`  
  This schema is appended to the prompt to guide the model.

---

## 🧠 How It Works

For each input file:

1. Reads the natural language question.
2. Reads the schema file.
3. Constructs a complete prompt with clear instructions for SQL generation.
4. Tokenizes and sends the prompt to the LLM.
5. Decodes and saves the generated SQL to the `llm_gen_query/` folder.
