import os
import subprocess
from datetime import datetime

import pandas as pd
import pyodbc

# --------------------------------
# Config
# --------------------------------
repo = r"D:\DONE\newinbound"

conn = pyodbc.connect("DSN=pbi_supplier")

# --------------------------------
# Export directly to Git repo
# --------------------------------
df = pd.read_sql(
    "SELECT * FROM data_tool_inbound_online",
    conn
)

csv_path = os.path.join(repo, "source.csv")
df.to_csv(csv_path, index=False)

conn.close()

print(f"Saved: {csv_path}")

# --------------------------------
# Git
# --------------------------------
subprocess.run(["git", "add", "."], cwd=repo, check=True)

msg = "Update data " + datetime.now().strftime("%Y-%m-%d %H:%M")

# Commit only if there are changes
status = subprocess.run(
    ["git", "status", "--porcelain"],
    cwd=repo,
    capture_output=True,
    text=True
)

if status.stdout.strip():
    subprocess.run(["git", "commit", "-m", msg], cwd=repo, check=True)
    subprocess.run(["git", "push"], cwd=repo, check=True)
    print("GitHub updated successfully.")
else:
    print("No changes detected.")