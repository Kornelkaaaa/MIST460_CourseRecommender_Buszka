from get_db_connection import get_db_connection

def validate_user(
        username: str, 
        password: str
):
    conn = get_db_connection()
    cursor = conn.cursor() # Create a cursor object to execute SQL queries
    cursor.execute("{CALL procValidateUser (?, ?)}", (username, password)) # Execute the stored procedure with parameters
    rows = cursor.fetchall() # Fetch the result
    conn.close() # Close the database connection if you want close may cost issues

    results =[
        {
            "AppUserID": row.AppUserID,
            "Fullname": row.FullName
        }
        for row in rows
    ]
    return {"data": results}