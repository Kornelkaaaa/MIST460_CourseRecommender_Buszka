import streamlit as st

with st.sidebar:
    st.title("Course Recommender System")

    #drop down for course recommendation fucntionalities
    api_end_point = st.selectbox(
        "Select a course recommendation functionality"
        [
            "Get Course Sections for Specific Course",
            "Get Course Prerequisites"
        ]
    )

    #if api_end_point == "Get Course Sections for Specific Course":
     #   get_course_sections_for_specified_course_ui()
    #elif api_end_point == "Get Course Prerequisites"
    #    get_course_prerequisites_ui()


    #TO DO create api for procHasStudentMetPrerequeiesForCOurse
    #add procValidateUser proc
    #create api py for procValidetUser proc