import streamlit as st
import requests
import pandas as pd
from typing import Optional


FASTAPI_BASE_URL = "http://localhost:8000" #Change this to the actual URL of your FastAPIserver URL


def fetch_data(endpoint:str, input_params:dict, method: str ="GET") -> Optional[pd.DataFrame]:
    
    if method == "GET":
        response = requests.get(f"{FASTAPI_BASE_URL}/{endpoint}", params=input_params)

    if response.status_code == 200:
        payload = response.json() # Extract the JSON payload from the response
        rows = payload.get("data", []) # Extract the list of rows from the response
        df = pd.DataFrame(rows) # Convert the list of rows into a DataFrame
        return df
    else:
        st.error(f"Error fetching data: {response.status_code} - {response.text}")
        return None  # Return None to indicate failure