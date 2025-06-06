import zipfile
import os

# Define the path to the zip file and the target directory
zip_file_path = "tpch_original_text.zip"
extract_to = "./"  # Current directory

# Check if the zip file exists
if os.path.exists(zip_file_path):
    with zipfile.ZipFile(zip_file_path, 'r') as zip_ref:
        zip_ref.extractall(extract_to)  # Extract files to current directory
    print(f"Files extracted to {extract_to}")
else:
    print(f"{zip_file_path} does not exist.")

