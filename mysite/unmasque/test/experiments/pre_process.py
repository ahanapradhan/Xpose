import os

# Set your folder path here
folder_path = '../gpt_sql'

# Loop through all files in the folder
for filename in os.listdir(folder_path):
    if filename.endswith('.sql'):
        file_path = os.path.join(folder_path, filename)

        # Read lines from the file
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        # Remove the first line if it's a comment
        # if lines and lines[-1].strip().startswith('--'):
        #    lines = lines[1:]
        # Filter out lines that start with --
        new_lines = [line for line in lines if not line.strip().startswith('--')]
        new_lines1 = [line for line in new_lines if not line.strip().startswith('```')]

        # Write the cleaned content back to the file
        with open(file_path, 'w', encoding='utf-8') as f:
            f.writelines(new_lines1)

        print(f"Processed: {filename}")
