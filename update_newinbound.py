import shutil
from pathlib import Path
# Source and destination folders
source_folder = Path(r"D:\DONE\exdata")
destination_folder = Path(r"D:\DONE\newinbound")
# Create destination if it doesn't exist
destination_folder.mkdir(parents=True, exist_ok=True)
# Copy all CSV files
count = 0
for csv_file in source_folder.glob("*.csv"):
    shutil.copy2(csv_file, destination_folder / csv_file.name)
    print(f"Copied: {csv_file.name}")
    count += 1
print(f"\nDone! {count} CSV file(s) copied.")