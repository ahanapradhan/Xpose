import os

# Set your folder path here
folder_path = '../tpcds-queries'

# Loop through all files in the folder
for filename in os.listdir(folder_path):
    if filename.endswith('.sql'):
        file_path = os.path.join(folder_path, filename)

        # Read lines from the file
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        # Remove the first line if it's a comment
        if lines and lines[0].strip().startswith('--'):
            lines = lines[1:]

        # Write the updated content back to the file
        with open(file_path, 'w', encoding='utf-8') as f:
            f.writelines(lines)

        print(f"Processed: {filename}")
