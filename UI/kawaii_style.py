import streamlit as st

KAWAII_CSS = """
<style>
@import url('https://fonts.googleapis.com/css2?family=Quicksand:wght@400;500;600;700&family=Mochiy+Pop+One&display=swap');

html, body, [class*="css"] {
    font-family: 'Quicksand', sans-serif !important;
}

h1, h2, h3, h4 {
    font-family: 'Mochiy Pop One', 'Quicksand', sans-serif !important;
    color: #d6336c !important;
    text-shadow: 1px 1px 0 #ffe0ec;
}

.stApp {
    background:
        radial-gradient(circle at 10% 20%, #ffe0ec 0%, transparent 40%),
        radial-gradient(circle at 90% 80%, #e0d6ff 0%, transparent 40%),
        linear-gradient(135deg, #fff5fa 0%, #fde7f3 100%);
}

section[data-testid="stSidebar"] {
    background: linear-gradient(180deg, #ffd6e7 0%, #e6d6ff 100%) !important;
    border-right: 3px dashed #ff8fb1;
}

section[data-testid="stSidebar"] h1,
section[data-testid="stSidebar"] h2,
section[data-testid="stSidebar"] h3 {
    color: #b3326c !important;
}

div.stButton > button {
    background: linear-gradient(135deg, #ff8fb1 0%, #ffb6d1 100%);
    color: white !important;
    border: 2px solid #ff6fa1;
    border-radius: 999px;
    padding: 0.5rem 1.5rem;
    font-weight: 700;
    font-family: 'Quicksand', sans-serif;
    box-shadow: 0 4px 0 #ff6fa1, 0 6px 12px rgba(255, 143, 177, 0.4);
    transition: all 0.15s ease;
}

div.stButton > button:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 0 #ff6fa1, 0 8px 16px rgba(255, 143, 177, 0.5);
    background: linear-gradient(135deg, #ffa0c1 0%, #ffc6dc 100%);
    color: white !important;
}

div.stButton > button:active {
    transform: translateY(2px);
    box-shadow: 0 2px 0 #ff6fa1, 0 3px 6px rgba(255, 143, 177, 0.4);
}

input, textarea, select, .stTextInput input, .stTextArea textarea {
    border-radius: 16px !important;
    border: 2px solid #ffb6d1 !important;
    background-color: #fff !important;
}

.stTextInput input:focus, .stTextArea textarea:focus {
    border-color: #ff6fa1 !important;
    box-shadow: 0 0 0 3px rgba(255, 143, 177, 0.25) !important;
}

div[data-baseweb="select"] > div {
    border-radius: 16px !important;
    border: 2px solid #ffb6d1 !important;
    background-color: #fff !important;
}

.stAlert {
    border-radius: 18px !important;
    border: 2px dashed #ff8fb1 !important;
}

div[data-testid="stDataFrame"] {
    border-radius: 18px;
    overflow: hidden;
    border: 2px solid #ffb6d1;
    background: #fff;
}

[data-testid="stMarkdownContainer"] p {
    color: #5b3a52;
}

.kawaii-header {
    text-align: center;
    padding: 1rem;
    margin-bottom: 1rem;
    background: linear-gradient(135deg, #ffe0ec 0%, #e6d6ff 100%);
    border-radius: 24px;
    border: 2px dashed #ff8fb1;
}
</style>
"""


def apply_kawaii_style():
    st.markdown(KAWAII_CSS, unsafe_allow_html=True)
