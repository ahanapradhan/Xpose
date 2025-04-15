import os
import re
from pdfminer.high_level import extract_text

from mysite.unmasque.test.experiments.utils import load_config, TEXT_DIR

# === Config ===
config = load_config()
pdf_path = "tpc-ds_v2.1.0.pdf"
output_dir = f"../{config[TEXT_DIR]}"

# === Create output folder if it doesn't exist ===
os.makedirs(output_dir, exist_ok=True)

# === Extract all text from the PDF ===
full_text = extract_text(pdf_path)

# === Regex pattern to find query descriptions before substitution parameters ===
query_pattern = re.compile(
    r'(B\.(\d+)\s+query\d+\.tpl\s*)(.*?)(?=Qualification Substitution Parameters:)',
    re.DOTALL
)

matches = query_pattern.findall(full_text)

# === Save each description to separate file ===
for _, qnum, desc in matches:
    qnum_int = int(qnum)
    cleaned_desc = ' '.join(desc.strip().split())

    filename = f"query{qnum_int}.txt"
    filepath = os.path.join(output_dir, filename)

    with open(filepath, "w", encoding="utf-8") as f:
        f.write(cleaned_desc)

print(f"✅ Saved {len(matches)} descriptions to folder: {output_dir}")
