from get_db_connection import get_db_connection
import pymssql

def get_all_jobs():

    conn = get_db_connection()
    cursor = conn.cursor(as_dict=True)

    # Execute the stored procedure
    cursor.callproc("procGetAllJobs")

    # Fetch results
    try:
        rows = cursor.fetchall()
    except pymssql.Error:
        rows = []

    cursor.close()
    conn.close()

    # Convert to list of dicts
    results = [
        {"JobTitle": row["JobTitle"], "JobDescription": row["JobDescription"]}
        for row in rows
    ]
    return {"data": results}
