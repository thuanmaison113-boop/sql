import sqlite3
import os
from pathlib import Path


# ============================================================
# CONFIGURATION
# ============================================================

# SOURCE DATABASE
SOURCE_DB = Path(
    r"D:\datashare\NHAP HANG - MASTER DATA\inventory_database\container\inbound_outbound_shared.sqlite3"
)

# LATEST DATABASE
# This file will always be replaced with the newest version.
LATEST_DB = Path(
    r"D:\OneDrive - MAISON RMI\pbi_supplier.sqlite3"
)


# ============================================================
# SQLITE BACKUP FUNCTION
# ============================================================

def sqlite_backup(source, destination):
    """
    Create a consistent SQLite database copy using SQLite's
    built-in backup API. This is safer than copying the file
    directly while the source database may be in use.
    """
    source_conn = sqlite3.connect(str(source), timeout=60)
    destination_conn = sqlite3.connect(str(destination), timeout=60)

    try:
        with destination_conn:
            source_conn.backup(destination_conn)
    finally:
        destination_conn.close()
        source_conn.close()


# ============================================================
# REFRESH LATEST DATABASE
# ============================================================

def main():
    print()
    print("=" * 70)
    print("        INVENTORY SQLITE DATABASE REFRESH")
    print("=" * 70)
    print()

    # 1. Check source database
    if not SOURCE_DB.exists():
        raise FileNotFoundError(
            f"Source database was not found:\n\n{SOURCE_DB}"
        )

    print("Source database:")
    print(f"  {SOURCE_DB}")
    print()

    # 2. Make sure destination folder exists
    LATEST_DB.parent.mkdir(parents=True, exist_ok=True)

    # 3. Create a temporary database first
    temp_file = LATEST_DB.parent / "pbi_supplier.tmp.sqlite3"

    if temp_file.exists():
        try:
            temp_file.unlink()
        except PermissionError:
            raise PermissionError(
                f"Cannot remove temporary file:\n{temp_file}\n\n"
                "It may be open by another program."
            )

    # 4. Create the refreshed database
    print("Creating latest database...")
    print(f"  {temp_file}")
    print()

    sqlite_backup(SOURCE_DB, temp_file)

    # 5. Replace the existing latest database
    print("Replacing latest database...")

    try:
        os.replace(temp_file, LATEST_DB)
    except PermissionError:
        if temp_file.exists():
            temp_file.unlink()

        raise PermissionError(
            f"\nCannot replace:\n{LATEST_DB}\n\n"
            "The file may currently be open or locked by Power BI, "
            "DBeaver, another application, or OneDrive."
        )

    # 6. Verify the latest database
    if not LATEST_DB.exists():
        raise RuntimeError("Latest database was not created correctly.")

    latest_size = LATEST_DB.stat().st_size

    print()
    print("Verification:")
    print(f"  Latest database: {latest_size:,} bytes")
    print()
    print("=" * 70)
    print("LATEST DATABASE UPDATED SUCCESSFULLY")
    print("=" * 70)
    print()
    print("Latest database:")
    print(f"  {LATEST_DB}")
    print()


# ============================================================
# ERROR HANDLING
# ============================================================

if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print()
        print("=" * 70)
        print("DATABASE UPDATE FAILED")
        print("=" * 70)
        print()
        print(error)
        print()
        input("Press Enter to close...")
