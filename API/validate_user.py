import pymssql
import streamlit as st
from get_db_connection import get_db_connection

def validate_user(
        username: str, 
        password: str
):
    conn = get_db_connection()
    #cursor = conn.cursor() # Create a cursor object to execute SQL queries
    cursor = conn.cursor(as_dict=True)
    #cursor.execute("{CALL procValidateUser (?, ?)}", (username, password)) # Execute the stored procedure with parameters
    cursor.callproc("procValidateUser", (username, password))
    #rows = cursor.fetchall() # Fetch the result
    try:
        rows = cursor.fetchall()
    except pymssql.Error:
        rows = []
    conn.close() # Close the database connection if you want close may cost issues

    results =[
        {
            "AppUserID": row["AppUserID"],
            "Fullname": row["Fullname"]
        }
        for row in rows
    ]
    return {"data": results}