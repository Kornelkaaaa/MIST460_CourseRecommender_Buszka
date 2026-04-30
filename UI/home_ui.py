import streamlit as st


def home_ui():
    st.title("🌸 Welcome to the Course Recommender! 🌸")
    st.markdown("*( ´ ▽ ` )ﾉ  hi there! so glad you're here~*")

    st.markdown(
        """
        ### ✨ What is this app?

        The **Course Recommender** is a cute little tool that helps WVU students plan their schedule and explore careers.
        Pick a job you're dreaming about and we'll suggest the courses that will help you get there 💼💖

        Behind the scenes, it uses **OpenAI embeddings** to understand your job description and a **GPT-4o** academic
        advisor to rank and explain why each course is a good match.
        """
    )

    st.markdown("---")

    st.markdown("### 🎀 What can you do here?")

    col1, col2 = st.columns(2)

    with col1:
        st.markdown(
            """
            **🔐 Validate User Credentials**
            Log in with your student account ♡

            **📚 Course Sections**
            See when and where a course is offered

            **🌷 Course Prerequisites**
            What you need to take *before* a course
            """
        )

    with col2:
        st.markdown(
            """
            **✅ Met the Prerequisites?**
            Check if you're ready to enroll

            **💖 Job → Course Recommendations**
            Pick a job, get GPT-ranked course picks!
            """
        )

    st.markdown("---")

    st.markdown(
        """
        ### 🌟 How to get started

        1. 🔐 Head to **Validate User Credentials** and log in (so we know who you are!)
        2. 💖 Try **Get Course Recommendations for Selected Job** — pick a job you'd love and let the magic happen ✨
        3. 🌷 Use **Course Prerequisites** and **Met the Prerequisites?** to plan ahead

        > 💡 *Tip: pick a functionality from the sidebar on the left ⬅️*
        """
    )

    st.markdown("---")

    st.caption("WVU MIST 460 — Spring 2026  •  ʚ♡ɞ")
