from transformers import AutoTokenizer, AutoModelForCausalLM
import torch
import os


model_name = "infly/inf-rl-qwen-coder-32b-2746"

tokenizer = AutoTokenizer.from_pretrained(model_name, trust_remote_code=True)

model = AutoModelForCausalLM.from_pretrained(
    model_name,
    trust_remote_code=True,
    device_map="auto",        
    torch_dtype=torch.float16 
)

prompt_dir = "tpch_original_prompt/Q_" # folder
schema_file = "tpch_schema.txt"
output_dir = "llm_gen_query/Q_"
os.makedirs(output_dir, exist_ok=True)

gen_prompt = (
    "You are an expert in SQL. "
    "Formulate SQL query that suits the following natural language text description in English. "
    "Only give the SQL, do not add any explanation. "
    "Do not keep any place-holder parameter in the query. "
    "Use valid data values as query constants, if the text does not mention them. "
    "Please ensure the SQL query is correct and optimized. Text: "
)

print("execution start")
for i in range(1, 23):
    prompt_file = prompt_dir + str(i) + ".txt"
    output_file =  output_dir + str(i) + ".txt"
    
    
    with open(prompt_file, "r", encoding="utf-8") as f:
        query_prompt = f.read().strip()
    with open(schema_file, "r", encoding="utf-8") as f:
        schema = f.read().strip()
    full_prompt = f"{query_prompt} \nbelow is database schema \n {schema} \n {gen_prompt}  "

    inputs = tokenizer(full_prompt, return_tensors="pt").to(model.device)
    outputs = model.generate(**inputs, max_new_tokens=3000)
    generated_text = tokenizer.decode(outputs[0], skip_special_tokens=True)
    
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(generated_text)
    print(f"Generated output saved to: {output_file}")
