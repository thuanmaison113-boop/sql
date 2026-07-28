import os
import pyodbc
import pandas as pd
folder = r"D:\DONE\exdata"
os.makedirs(folder, exist_ok=True)
conn = pyodbc.connect("DSN=pbi_supplier")
df = pd.read_sql("SELECT * FROM data_tool_inbound_online", conn)
csv_path = os.path.join(folder, "source.csv")
df.to_csv(csv_path, index=False)
conn.close()
print(f"CSV saved to: {csv_path}")