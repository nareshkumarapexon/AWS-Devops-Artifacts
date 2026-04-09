import csv
from datetime import datetime

batch_size = 100
def csv_to_sql(csv_file, table_name):
    current_timestamp = datetime.now() 
    timestamp_string = current_timestamp.isoformat()
    print(timestamp_string)
    
    with open(csv_file, mode='r', newline='', encoding='utf-8') as file:
        f = open(table_name+".txt", "a") # Open in append mode
        reader = csv.reader(file)
        
        # Extract column names from first row
        columns = next(reader)
        head_sql = f"INSERT INTO {table_name} ({', '.join(columns)}) VALUES \n"
        
        last_write = ""
        record_num = 0
        sql_y = ""

        for row in reader:
            record_num = record_num + 1

            if record_num == 1:
                f.write(head_sql)
                last_write = "h"

            if sql_y == "y":
                if record_num > batch_size:
                    if last_write == "h":
                        f.write(sql+";\n")
                    else:
                        f.write(","+sql+";\n")
                    record_num = 0
                    last_write = ""
                else:
                    if last_write == "h":
                        f.write(sql+"\n")
                    else:
                        f.write(","+sql+"\n")
                    last_write = ""

            # Escape single quotes in values
            values = ["NULL" if v == "" else f"'{v.replace('\'','\'\'')}'" for v in row]
            sql = f"({', '.join(values)})" 
            sql_y = "y"   
            
    if record_num == 0:
        f.write(head_sql)
        f.write(sql+";\n")
    else:
        f.write(","+sql+";\n")
    f.close()




# ---------- RUN ----------
csv_to_sql("healthcare_data 2.csv,"healthcare_data")
