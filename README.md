# 🌸 Course Recommender System 🌸

A super cute WVU course recommendation app that pairs a FastAPI backend with a Streamlit frontend. Given a job description, it uses OpenAI embeddings + a SQL Server vector search to surface relevant courses, then asks GPT-4o to rank and justify the matches. ♡(◡‿◡✿)

The frontend has a kawaii pastel theme — pink/lavender gradients, rounded chunky buttons, dashed borders, balloon confetti on success, and emojis sprinkled across every screen.

## ✨ Features

- 🔐 **Validate user credentials** — student login check
- 📚 **Get course sections for a specified course**
- 🌷 **Get course prerequisites**
- ✅ **Check if a student has met prerequisites for a course**
- 💖 **Get course recommendations for a selected job** — semantic search over course descriptions using OpenAI embeddings, ranked and explained by GPT-4o

## 🎀 Project Structure

```
.
├── API/                        FastAPI backend
│   ├── course_recommender_apis.py     Route definitions
│   ├── get_all_jobs.py
│   ├── get_course_recommendations_for_selected_job.py
│   ├── get_course_sections_for_specified_course.py
│   ├── get_course_prerequisites.py
│   ├── has_student_met_prerequisites_for_course.py
│   ├── validate_user.py
│   ├── get_db_connection.py           SQL Server connection helper
│   ├── format_contex.py
│   ├── find_current_semester.py
│   └── requirements.txt
└── UI/                         Streamlit frontend (kawaii theme ♡)
    ├── .streamlit/
    │   └── config.toml                Pastel pink/lavender theme
    ├── kawaii_style.py                Shared CSS injection (fonts, buttons, gradients)
    ├── course_recommender_ui.py       Main app (sidebar router)
    ├── fetch_data.py                  HTTP client for the API
    ├── get_course_recommendations_for_selected_job.py
    ├── get_course_sections_for_specified_course_ui.py
    ├── get_course_prerequisites_ui.py
    ├── has_student_met_prerequisites_for_course_ui.py
    └── validate_user_ui.py
```

## 🌟 Prerequisites

- Python 3.12
- SQL Server access (with the project's stored procedures installed: `procGetAllJobs`, `procGetCourseRecommendationsForSelectedJob`, etc.)
- An OpenAI API key

## 🌸 Setup

1. **Clone and create a virtual environment**

   ```bash
   python -m venv .venv
   .venv\Scripts\activate           # Windows
   # source .venv/bin/activate      # macOS / Linux
   ```

2. **Install dependencies**

   ```bash
   pip install -r API/requirements.txt
   ```

3. **Set environment variables**

   Create a `.env` file in the project root with your DB and OpenAI credentials:

   ```
   OPENAI_API_KEY=sk-...
   DB_SERVER=your-server.database.windows.net
   DB_NAME=your-db-name
   DB_USER=your-username
   DB_PASSWORD=your-password
   ```

   (Match the variable names that `API/get_db_connection.py` actually reads.)

   > 💡 **Note:** these secrets only need to live on the **API** side — the Streamlit UI never touches the database or OpenAI directly, so no Streamlit secrets file is required.

## 💕 Running Locally

You need **two** terminals — one for the API, one for the UI.

**Terminal 1 — start the FastAPI backend:**

```bash
cd API
uvicorn course_recommender_apis:app --reload --port 8000
```

The API will be available at `http://localhost:8000`. Visit `http://localhost:8000/docs` for the interactive Swagger UI.

**Terminal 2 — start the Streamlit frontend:**

```bash
cd UI
streamlit run course_recommender_ui.py
```

The UI opens at `http://localhost:8501` and loads the kawaii theme automatically from `UI/.streamlit/config.toml`. 🌷

> **Note:** `UI/fetch_data.py` has a `FASTAPI_BASE_URL` constant that points the UI at the backend. By default it points at the deployed Azure URL — switch it to `http://localhost:8000` when running locally.

## ☁️ Deployment

The API is deployed to Azure App Service at:

```
https://mist460-api-buszka.azurewebsites.net
```

To use the deployed API, set `FASTAPI_BASE_URL` in `UI/fetch_data.py` to that URL.

## 🎀 Customizing the Kawaii Theme

The cuteness comes from two places:

- **`UI/.streamlit/config.toml`** — Streamlit's built-in theme variables (colors, font family). Tweak `primaryColor`, `backgroundColor`, etc. to recolor the whole app.
- **`UI/kawaii_style.py`** — custom CSS injection (Google Fonts, button gradients, dashed borders, sidebar style). Edit the `KAWAII_CSS` string to change shapes, shadows, or fonts.

Each individual UI file (e.g. `validate_user_ui.py`) controls its own emojis and copy. Swap a 🌸 for a 🐰, change the cute message at the top — all easy.

## 🌷 Endpoints

| Method | Path | Description |
| --- | --- | --- |
| GET | `/` | Health check / welcome message |
| GET | `/get_all_jobs/` | List all jobs available for recommendations |
| GET | `/get_course_recommendations_for_selected_job/?job_description=...` | Get GPT-ranked course recommendations for a job description |
| GET | `/get_course_sections_for_specified_course/?subject_code=...&course_number=...` | List sections for a specific course |
| GET | `/get_course_prerequisites/?subject_code=...&course_number=...` | List a course's prerequisites |
| GET | `/has_student_met_prerequisites_for_course/?student_id=...&subject_code=...&course_number=...` | Check whether a student has met prerequisites |
| GET | `/validate_user/?username=...&password=...` | Validate user credentials |

## 💫 Tech Stack

- **Backend:** FastAPI, Uvicorn, pymssql, LangChain, OpenAI (GPT-4o + `text-embedding-3-small`)
- **Frontend:** Streamlit, Requests, Pandas + custom CSS (Quicksand & Mochiy Pop One fonts)
- **Database:** SQL Server with stored procedures and vector similarity search

## 🌸 Course

WVU MIST 460 — Spring 2026
