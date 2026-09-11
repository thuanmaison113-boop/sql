import sqlite3
import os
from datetime import datetime
from pathlib import Path


# ============================================================
# CONFIGURATION
# ============================================================

# ------------------------------------------------------------
# SOURCE DATABASE
# ------------------------------------------------------------
SOURCE_DB = Path(
    r"D:\datashare\NHAP HANG - MASTER DATA\inventory_database\container\inbound_outbound_shared.sqlite3"
)


# ------------------------------------------------------------
# HISTORICAL BACKUP FOLDER
# ------------------------------------------------------------
BACKUP_DIR = Path(
    r"D:\DONE\BACKUP DATABASE"
)


# ------------------------------------------------------------
# LATEST DATABASE
# This file will always be replaced with the newest version.
# ------------------------------------------------------------
LATEST_DB = Path(
    r"D:\OneDrive - MAISON RMI\inventory_database_111_onedrive\container\pbi_supplier.sqlite3"
)


# ============================================================
# SQLITE BACKUP FUNCTION
# ============================================================

def sqlite_backup(source, destination):
    """
    Create a consistent SQLite backup using SQLite's
    built-in backup API.

    This is safer than simply copying the .sqlite3 file,
    especially when the source database is being used.
    """

    source_conn = sqlite3.connect(
        str(source),
        timeout=60
    )

    destination_conn = sqlite3.connect(
        str(destination),
        timeout=60
    )

    try:
        with destination_conn:
            source_conn.backup(destination_conn)

    finally:
        destination_conn.close()
        source_conn.close()


# ============================================================
# MAIN BACKUP PROCESS
# ============================================================

def main():

    print()
    print("=" * 70)
    print("        INVENTORY SQLITE DATABASE BACKUP")
    print("=" * 70)
    print()

    # --------------------------------------------------------
    # 1. Check source database
    # --------------------------------------------------------

    if not SOURCE_DB.exists():

        raise FileNotFoundError(
            f"Source database was not found:\n\n{SOURCE_DB}"
        )

    print(f"Source database:")
    print(f"  {SOURCE_DB}")
    print()


    # --------------------------------------------------------
    # 2. Create backup folder if it doesn't exist
    # --------------------------------------------------------

    BACKUP_DIR.mkdir(
        parents=True,
        exist_ok=True
    )


    # --------------------------------------------------------
    # 3. Create timestamp
    #
    # Example:
    # 20260911_112035
    # = YYYYMMDD_HHMMSS
    # --------------------------------------------------------

    timestamp = datetime.now().strftime(
        "%Y%m%d_%H%M%S"
    )


    # --------------------------------------------------------
    # 4. Historical backup filename
    #
    # Example:
    # inventory_20260911_112035.db
    # --------------------------------------------------------

    backup_file = (
        BACKUP_DIR /
        f"inventory_{timestamp}.db"
    )


    print("Creating historical backup...")
    print(f"  {backup_file}")
    print()


    # --------------------------------------------------------
    # 5. Create historical backup
    # --------------------------------------------------------

    sqlite_backup(
        SOURCE_DB,
        backup_file
    )


    print("SUCCESS:")
    print(f"  Historical backup created.")
    print()


    # --------------------------------------------------------
    # 6. Make sure destination folder exists
    # --------------------------------------------------------

    LATEST_DB.parent.mkdir(
        parents=True,
        exist_ok=True
    )


    # --------------------------------------------------------
    # 7. Create temporary database
    #
    # We DON'T directly overwrite pbi_supplier.sqlite3.
    #
    # First create a complete new database:
    #
    # pbi_supplier.tmp.sqlite3
    #
    # Then replace the old file.
    # --------------------------------------------------------

    temp_file = (
        LATEST_DB.parent /
        "pbi_supplier.tmp.sqlite3"
    )


    # Remove old temporary file if it exists

    if temp_file.exists():

        try:
            temp_file.unlink()

        except PermissionError:

            raise PermissionError(
                f"Cannot remove temporary file:\n{temp_file}\n\n"
                f"It may be open by another program."
            )


    # --------------------------------------------------------
    # 8. Create new latest database
    # --------------------------------------------------------

    print("Creating latest database...")
    print(f"  {temp_file}")
    print()

    sqlite_backup(
        SOURCE_DB,
        temp_file
    )


    # --------------------------------------------------------
    # 9. Replace old pbi_supplier.sqlite3
    # --------------------------------------------------------

    print("Replacing latest database...")

    try:

        os.replace(
            temp_file,
            LATEST_DB
        )

    except PermissionError:

        # Clean up temporary file

        if temp_file.exists():
            temp_file.unlink()

        raise PermissionError(
            f"\nCannot replace:\n"
            f"{LATEST_DB}\n\n"
            f"The file may currently be open or locked "
            f"by Power BI, DBeaver, another application, "
            f"or OneDrive."
        )


    print()
    print("SUCCESS:")
    print(f"  Latest database updated.")
    print(f"  {LATEST_DB}")
    print()


    # --------------------------------------------------------
    # 10. Verify files
    # --------------------------------------------------------

    print("Verifying...")

    if not backup_file.exists():

        raise RuntimeError(
            "Historical backup was not created correctly."
        )


    if not LATEST_DB.exists():

        raise RuntimeError(
            "Latest database was not created correctly."
        )


    # Get file sizes

    backup_size = backup_file.stat().st_size
    latest_size = LATEST_DB.stat().st_size


    print()
    print("Verification:")
    print(
        f"  Historical backup : "
        f"{backup_size:,} bytes"
    )

    print(
        f"  Latest database   : "
        f"{latest_size:,} bytes"
    )


    # --------------------------------------------------------
    # 11. Final result
    # --------------------------------------------------------

    print()
    print("=" * 70)
    print("BACKUP COMPLETED SUCCESSFULLY")
    print("=" * 70)
    print()

    print("Historical backup:")
    print(f"  {backup_file}")
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
        print("BACKUP FAILED")
        print("=" * 70)
        print()
        print(error)
        print()

        input("Press Enter to close...")