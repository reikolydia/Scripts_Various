import os
import re
import shutil
import subprocess
import sys
import tempfile

def find_and_sort_split_files(folder, base_name):
    pattern = re.compile(rf"^{re.escape(base_name)}-(\d+)\.csv$")
    matched_files = []

    for f in os.listdir(folder):
        m = pattern.match(f)
        if m:
            index = int(m.group(1))
            matched_files.append((index, f))

    matched_files.sort(key=lambda x: x[0])
    return [filename for _, filename in matched_files]

def insert_lines_to_splits(folder, base_name, top_line, bottom_line):
    split_files = find_and_sort_split_files(folder, base_name)
    for i, split_file in enumerate(split_files):
        split_path = os.path.join(folder, split_file)

        with open(split_path, 'r', encoding='utf-8') as f:
            content = f.readlines()

        content.insert(0, '\n')
        content.insert(0, top_line)

        if i == len(split_files) -1 and bottom_line:
            content.append(bottom_line)

        with open(split_path, 'w', encoding='utf-8', newline='') as f:
            f.writelines(content)

def clean_csv(file_path, temp_path):
    with open(file_path, 'r', encoding='utf-8') as infile:
        lines = infile.readlines()

    if len(lines) > 4:
        top_line = lines[0]
        bottom_line = lines[-1]
        cleaned_lines = lines[2:-2]
    else:
        top_line = ''
        bottom_line = ''
        cleaned_lines = []

    with open(temp_path, 'w', encoding='utf-8', newline='') as outfile:
        outfile.writelines(cleaned_lines)
    
    return top_line, bottom_line

def split_large_csv_files(folder):
    threshold_kb = 19999
    split_chunk_kb = 19000
    qsv_binary = "qsvlite"  # or full path

    for filename in os.listdir(folder):
        if filename.lower().endswith('.csv'):
            filepath = os.path.join(folder, filename)
            size_bytes = os.path.getsize(filepath)
            size_kb = size_bytes / 1024

            if size_kb > threshold_kb:
                print(f"Processing {filename} ({size_kb:.2f} KB)...")
                temp_file = os.path.join(folder, f"_cleaned_{filename}")
                top_line, bottom_line = clean_csv(filepath, temp_file)

                # Create isolated temp directory for output files
                with tempfile.TemporaryDirectory(dir=folder) as temp_output_dir:
                    base_name = os.path.splitext(filename)[0]

                    # Construct qsv command respecting order:
                    cmd = [
                        qsv_binary, "split",
                        "--kb-size", str(split_chunk_kb),
                        temp_output_dir,
                        temp_file,
                        "--filename", f"{base_name}-{{}}.csv"
                    ]

                    try:
                        subprocess.run(cmd, check=True)
                        print(f"Split complete for {filename}")

                        # Insert lines inside temp output folder
                        insert_lines_to_splits(temp_output_dir, base_name, top_line, bottom_line)

                        # Move split files from temp output dir to main folder
                        for f in os.listdir(temp_output_dir):
                            shutil.move(os.path.join(temp_output_dir, f), os.path.join(folder, f))

                        print(f"Moved split files and inserted header/footer for {filename}")

                    except subprocess.CalledProcessError as e:
                        print(f"Error splitting {filename}: {e}")

                if os.path.exists(temp_file):
                    os.remove(temp_file)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python split_csv_folder.py <folder_path>")
        sys.exit(1)

    folder_path = sys.argv[1]
    split_large_csv_files(folder_path)
