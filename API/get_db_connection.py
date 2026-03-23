#get_db_connection

import pyodbc
import os
from dotenv import load_dotenv

load_dotenv()

def get_db_connection():

    server = os.getenv('DB_SERVER')
    database = os.getenv('DB_NAME')
    user = os.getenv('DB_USER')
    password = os.getenv('DB_PASSWORD')
    driver = os.getenv('DB_DRIVER')

    connection_string = f"DRIVER={os.getenv('DB_DRIVER')};SERVER={os.getenv('DB_SERVER')};DATABASE={os.getenv('DB_NAME')};UID={os.getenv('DB_USER')};PWD={os.getenv('DB_PASSWORD')};Encrypt=yes;TrustServerCertificate=yes;Connection Timeout=30;"
    
    return pyodbc.connect(connection_string) 

