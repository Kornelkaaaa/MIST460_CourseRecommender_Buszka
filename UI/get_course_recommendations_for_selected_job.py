import streamlit as st
from fetch_data import fetch_data, fetch_text

def get_job_title(record):
    return record['JobTitle']


def get_course_recommendations_for_selected_job_ui():
    st.title("Course Recommendations for Selected Job")

    parameters_for_jobs_dropdown = {}

    df = fetch_data("get_all_jobs/", parameters_for_jobs_dropdown)

    selected_job = st.selectbox("Select a job", options=df.to_dict(orient="records"),
                                format_func=get_job_title)
    
    st.write(f"You selected: {selected_job['JobTitle']}")

    parameters_for_course_recommendations = {}

    parameters_for_course_recommendations["job_description"] = st.text_area("Job description", value=selected_job['JobDescription'], height=200)

    if st.button("Get Course Recommendations"):

        #recomendations_data_response = fetch_text("get_course_recommendations_for_selected_job/", parameters_for_course_recommendations)
        
        #if recomendations_data_response:
        
        with st.spinner("Generating course recommendations... this can take 10-20 seconds."):
            recomendations_data_response = fetch_text("get_course_recommendations_for_selected_job/", parameters_for_course_recommendations)

        if recomendations_data_response and recomendations_data_response.strip():
            st.subheader("Recommended Courses:")
            st.markdown(recomendations_data_response, unsafe_allow_html=True)  # Render the HTML content in the response
        else:
            st.info("No course recommendations found for the selected job.")