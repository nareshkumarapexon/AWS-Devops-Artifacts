import csv
from datetime import datetime


def csv_to_sql(csv_file, table_name):
    current_timestamp = datetime.now() 
    timestamp_string = current_timestamp.isoformat()
    print(timestamp_string)

    with open(csv_file, mode='r', newline='', encoding='utf-8') as file:
        f = open(table_name+".txt", "a") # Open in append mode
        reader = csv.reader(file)
        
        # Extract column names from first row
        columns = next(reader)
        sql = f"INSERT INTO {table_name} ({', '.join(columns)}) VALUES \n"
        f.write(sql)
        for row in reader:
            # Escape single quotes in values
            values = ["NULL" if v == "" else f"'{v.replace('\'','\'\'')}'" for v in row]
            
            sql = f"({', '.join(values)}),\n"
            #sql = sql.replace("NULL","'"+timestamp_string+"'")
            index_of_null = sql.find("NULL")
            #print(sql)
            f.write(sql)

    f.close()




# ---------- RUN ----------
csv_to_sql("hcp_master_table(in) 1.csv ", "hcp_master_table")
