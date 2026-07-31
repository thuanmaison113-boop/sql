import os
import subprocess
from datetime import datetime

import pandas as pd
import pyodbc

# -------------------------------------------------
# Configuration
# -------------------------------------------------
REPO = r"D:\DONE\newinbound"
CONNECTION_STRING = "DSN=pbi_supplier"

TABLE_NAME = "data_tool_inbound_online"
OUTPUT_FILE = "source.csv"


def run_git(command):
    """Run a git command and display the output."""
    print(f"\n> {' '.join(command)}")

    result = subprocess.run(
        command,
        cwd=REPO,
        capture_output=True,
        text=True,
    )

    if result.stdout:
        print(result.stdout)

    if result.stderr:
        print(result.stderr)

    if result.returncode != 0:
        raise RuntimeError(
            f"Git command failed: {' '.join(command)}"
        )


def export_data():
    print("Connecting to database...")

    with pyodbc.connect(CONNECTION_STRING) as conn:
        print(f"Exporting {TABLE_NAME}...")

        df = pd.read_sql_query(
            f"SELECT * FROM {TABLE_NAME}",
            conn,
        )

        output = os.path.join(REPO, OUTPUT_FILE)
        df.to_csv(output, index=False)

        print(f"Saved: {output}")


def push_to_github():
    commit_message = f"Update data {datetime.now():%Y-%m-%d %H:%M}"

    run_git(["git", "add", "."])
    run_git(["git", "commit", "--allow-empty", "-m", commit_message])

    # Refresh remote information
    run_git(["git", "fetch", "origin"])

    # Publish latest generated files
    run_git(["git", "push", "--force", "origin", "main"])


def main():
    print("=" * 60)
    print("NEW INBOUND EXPORT")
    print("=" * 60)

    export_data()
    push_to_github()

    print("\nSUCCESS - GitHub updated successfully.")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print("\nFAILED")
        print(e)