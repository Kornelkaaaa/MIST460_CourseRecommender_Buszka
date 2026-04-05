import streamlit as st
from fetch_data import fetch_data

def has_student_met_prerequisites_for_course_ui():
    
    st.header("Has Student Met Prerequisites for Course")

    # Student ID is pre-filled from session state and disabled
    # so the student can only check their own prerequisites
    student_id  = st.text_input("Student ID", value=st.session_state.app_user_id, disabled=True)
    
    # Input fields for the course the student wants to check
    subject_code = st.text_input("Enter Subject Code (e.g., CS)")
    course_number = st.text_input("Enter Course Number (e.g., 101)")

    # Only run the check when the button is clicked
    if st.button("Check If Student Has Met Prerequisites"):
        
        # Build the parameters dictionary for the API request
        # Only include values that are not empty
        input_params = {}
        if student_id:
            input_params["student_id"] = student_id
        if subject_code.strip():
            input_params["subject_code"] = subject_code.strip()
        if course_number.strip():
            input_params["course_number"] = course_number.strip()

        # Call the backend API to check prerequisites
        # Returns a DataFrame with any unmet prerequisites
        df = fetch_data("has_student_met_prerequisites_for_course/", input_params)

        if df is not None:
            if df.empty:
                # Empty result means all prerequisites have been met
                # (matches the stored procedure logic where no rows = all met)
                st.success("The student has met the prerequisites for the specified course.")
            else:
                # Rows returned means these prerequisites are still missing
                # Display them in a table so the student knows what they need
                st.warning("The student has NOT met the prerequisites for the specified course. Missing prerequisites:")
                st.dataframe(df, use_container_width=True, hide_index=True)
        else:
            # None means the API returned no data at all
            # This happens when the course itself has no prerequisites
            st.info("No course prerequisites found for the specified course.")