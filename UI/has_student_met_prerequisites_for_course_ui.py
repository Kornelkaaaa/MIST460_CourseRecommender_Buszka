import streamlit as st
from fetch_data import fetch_data

def has_student_met_prerequisites_for_course_ui():

    st.header("✅ Did You Meet the Prerequisites? 🌟")
    st.markdown("*(｡◕‿◕｡)  let's check if you're ready~*")

    student_id  = st.text_input("🎓 Student ID", value=st.session_state.app_user_id, disabled=True)

    subject_code = st.text_input("🌸 Subject Code (e.g., CS)")
    course_number = st.text_input("🔢 Course Number (e.g., 101)")

    if st.button("✨ Check Prerequisites ✨"):

        input_params = {}
        if student_id:
            input_params["student_id"] = student_id
        if subject_code.strip():
            input_params["subject_code"] = subject_code.strip()
        if course_number.strip():
            input_params["course_number"] = course_number.strip()

        df = fetch_data("has_student_met_prerequisites_for_course/", input_params)

        if df is not None:
            if df.empty:
                st.success("🎉 Yay! You've met all the prerequisites! ٩(◕‿◕)۶")
            else:
                st.warning("🥺 Oopsie! You haven't met all prerequisites yet. Missing ones below ↓")
                st.dataframe(df, use_container_width=True, hide_index=True)
        else:
            st.info("🌸 No prerequisites found for this course~ you're good to go! ✨")
