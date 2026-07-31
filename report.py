import os
import subprocess
from datetime import datetime

import pandas as pd
import pyodbc

# -------------------------------------------------
# Configuration
# -------------------------------------------------
REPO = r"D:\DONE\report"
CONNECTION_STRING = "DSN=pbi_supplier"

REPORTS = {
    "data_tool_outbound_report": "outbound.csv",
    "data_tool_inbound_report": "inbound.csv",
}


def run_git(command):
    """Run a git command and display its output."""
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
        raise RuntimeError(f"Git command failed: {' '.join(command)}")


def export_reports():
    print("Connecting to database...")

    with pyodbc.connect(CONNECTION_STRING) as conn:
        for table, filename in REPORTS.items():
            print(f"Exporting {table}...")

            df = pd.read_sql_query(
                f"SELECT * FROM {table}",
                conn,
            )

            output = os.path.join(REPO, filename)
            df.to_csv(output, index=False)

            print(f"Saved: {output}")


def push_to_github():
    message = f"Update data {datetime.now():%Y-%m-%d %H:%M}"

    run_git(["git", "add", "."])
    run_git(["git", "commit", "--allow-empty", "-m", message])

    # Overwrite remote only if nobody else has updated it
    run_git(["git", "push", "--force-with-lease", "origin", "main"])


def main():
    print("=" * 60)
    print("REPORT EXPORT")
    print("=" * 60)

    export_reports()
    push_to_github()

    print("\nSUCCESS - GitHub updated.")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print("\nFAILED")
        print(e)
