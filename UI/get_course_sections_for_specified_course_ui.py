import streamlit as st

from fetch_data import fetch_data

def get_course_sections_for_specified_course_ui():
    st.header("📚 Course Sections ✨")
    st.markdown("*ฅ^•ﻌ•^ฅ  let's find your class~*")

    subject_code = st.text_input("🌸 Subject Code (e.g., MIST):")
    course_number = st.text_input("🔢 Course Number (e.g., 460):")

    if st.button("💫 Fetch Course Sections 💫"):
        input_params = {}
        if subject_code.strip():
            input_params["subject_code"] = subject_code.strip()
        if course_number.strip():
            input_params["course_number"] = course_number.strip()

        df = fetch_data("get_course_sections_for_specified_course/", input_params)

        if df is not None and not df.empty:
            st.markdown("### 🎀 Here are your sections! 🎀")
            st.dataframe(df, use_container_width=True, hide_index=True)
        else:
            st.info("😿 No sections found~ check the subject code and course number, please!")
