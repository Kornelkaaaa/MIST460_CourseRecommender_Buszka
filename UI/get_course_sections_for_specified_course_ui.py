import streamlit as st

from fetch_data import fetch_data

def get_course_sections_for_specified_course_ui():
    st.header("Get Course Sections for Specified Course")

    subject_code = st.text_input("Enter Subject Code (e.g., MIST):")
    course_number = st.text_input("Enter Course Number (e.g., 460):")

    if st.button("Fetch Course Sections"):
        input_params = {} 
        if subject_code.strip(): # Only add to input_params if it's not empty after stripping whitespace
            input_params["subject_code"] = subject_code.strip()
        if course_number.strip(): # Only add to input_params if it's not empty after stripping whitespace
            input_params["course_number"] = course_number.strip()

        df = fetch_data("get_course_sections_for_specified_course/", input_params)

        if df is not None and not df.empty:
            st.dataframe(df, use_container_width=True, hide_index=True)
        else:
            st.info("No course sections found for the specified course. Please check the subject code and course number and try again.")