import streamlit as st
from fetch_data import fetch_data, fetch_text

def get_job_title(record):
    return f"💼 {record['JobTitle']}"


def get_course_recommendations_for_selected_job_ui():
    st.title("💖 Course Recommendations for Your Dream Job 💖")
    st.markdown("*(づ｡◕‿‿◕｡)づ  pick a job and we'll find your perfect classes~*")

    parameters_for_jobs_dropdown = {}

    df = fetch_data("get_all_jobs/", parameters_for_jobs_dropdown)

    if df is None or df.empty:
        st.warning("😿 Couldn't load jobs right now. Please refresh the page in a moment~")
        st.stop()

    selected_job = st.selectbox(
        "🌸 Select a job",
        options=df.to_dict(orient="records"),
        format_func=get_job_title,
    )

    st.markdown(f"### ✨ You picked: **{selected_job['JobTitle']}** ✨")

    parameters_for_course_recommendations = {}

    parameters_for_course_recommendations["job_description"] = st.text_area(
        "📝 Job description (feel free to edit~)",
        value=selected_job['JobDescription'],
        height=200,
    )

    if st.button("🌟 Get Course Recommendations 🌟"):

        with st.spinner("🌸 Generating cute recommendations... please wait 10-20 seconds~ (◕‿◕✿)"):
            recomendations_data_response = fetch_text(
                "get_course_recommendations_for_selected_job/",
                parameters_for_course_recommendations,
            )

        if recomendations_data_response and recomendations_data_response.strip():
            st.balloons()
            st.subheader("🎀 Recommended Courses just for you! 🎀")
            st.markdown(recomendations_data_response, unsafe_allow_html=True)
        else:
            st.info("😿 No recommendations found for the selected job. Try another one!")
