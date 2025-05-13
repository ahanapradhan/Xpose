import csv

# Replace 'your_file.csv' with the path to your CSV file
filename = 'your_file.csv'

with open(filename, mode='r', newline='', encoding='utf-8') as file:
    reader = csv.reader(file)
    for row in reader:
        # Ensure the row has at least 3 fields
        if len(row) < 3:
            continue
        try:
            # Convert the 3rd field to a number
            value = float(row[2])
            if value > 40000:
                print(row[1])  # Print the 2nd field
        except ValueError:
            # Skip rows where the 3rd field is not a number
            continue
