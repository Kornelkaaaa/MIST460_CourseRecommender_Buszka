import streamlit as st
from fetch_data import fetch_data

def get_course_prerequisites_ui():

    st.header("🌷 Course Prerequisites ♡")
    st.markdown("*(◕‿◕✿)  what do you need to take first?*")

    subject_code = st.text_input("🌸 Subject Code (e.g., CS)")
    course_number = st.text_input("🔢 Course Number (e.g., 101)")

    if st.button("💕 Fetch Prerequisites 💕"):
        input_params = {}
        if subject_code.strip():
            input_params["subject_code"] = subject_code.strip()
        if course_number.strip():
            input_params["course_number"] = course_number.strip()

        df = fetch_data("get_course_prerequisites/", input_params)

        if df is not None and not df.empty:
            st.markdown("### 🎀 Prerequisites for your course! 🎀")
            st.dataframe(df, use_container_width=True, hide_index=True)
        else:
            st.info("🌸 No prerequisites found~ you're free to enroll, yay! ✨")
