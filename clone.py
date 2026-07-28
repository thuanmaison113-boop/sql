import os
import subprocess
# Change these
repo_url = "https://github.com/thuanmaison113-boop/newinbound.git"
destination = r"D:\DONE"
# Create destination folder if it doesn't exist
os.makedirs(destination, exist_ok=True)
# Clone the repository
subprocess.run(
    ["git", "clone", repo_url],
    cwd=destination,
    check=True
)
print("Repository cloned successfully!")