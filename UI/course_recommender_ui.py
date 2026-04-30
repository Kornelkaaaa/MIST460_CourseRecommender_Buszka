import streamlit as st

st.set_page_config(
    page_title="Course Recommender (｡♥‿♥｡)",
    page_icon="🌸",
    layout="centered",
)

from kawaii_style import apply_kawaii_style
from get_course_sections_for_specified_course_ui import get_course_sections_for_specified_course_ui
from get_course_prerequisites_ui import get_course_prerequisites_ui
from has_student_met_prerequisites_for_course_ui import has_student_met_prerequisites_for_course_ui
from validate_user_ui import validate_user_ui
from get_course_recommendations_for_selected_job import get_course_recommendations_for_selected_job_ui

apply_kawaii_style()

with st.sidebar:
    st.markdown("## 🌸 Course Recommender 🌸")
    st.markdown("✨ *pick something cute to do!* ✨")

    api_end_point = st.selectbox(
        "🎀 Select a functionality:",
        [
            "🔐 Validate User Credentials",
            "📚 Get Course Sections for Specified Course",
            "🌷 Get Course Prerequisites",
            "✅ Has Student Met Prerequisites for Course",
            "💖 Get Course Recommendations for Selected Job",
        ],
    )

    st.markdown("---")

if api_end_point == "📚 Get Course Sections for Specified Course":
    get_course_sections_for_specified_course_ui()
elif api_end_point == "🌷 Get Course Prerequisites":
    get_course_prerequisites_ui()
elif api_end_point == "✅ Has Student Met Prerequisites for Course":
    has_student_met_prerequisites_for_course_ui()
elif api_end_point == "🔐 Validate User Credentials":
    validate_user_ui()
elif api_end_point == "💖 Get Course Recommendations for Selected Job":
    get_course_recommendations_for_selected_job_ui()
