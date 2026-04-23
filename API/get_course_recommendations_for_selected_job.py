from datetime import datetime
from pprint import pprint
from langchain_openai import OpenAIEmbeddings
from streamlit import json
import pprint
import json
from API.get_db_connection import get_db_connection


def get_course_recommendations_for_selected_job(job_description: str) -> str:

    year_value = datetime.now().year
    semester_value = "spring"
    user_query = f"Based on the following job description, recommend relevant courses from our database offered in {semester_value} {year_value} that would help someone prepare for this job: {job_description}"

    # use the OpenAIEmbeddings model to generate course recommendations based on the user query
    embedding_model = OpenAIEmbeddings(model="text-embedding-3-small")
    

    job_description_embedding = embedding_model.embed_query(user_query)

    #print("\nJob Description Embedding:")
    #pprint.pprint(job_description_embedding)

    conn = get_db_connection()
    cursor = conn.cursor(as_dict=True)
    
    cursor.execute("EXEC procGetCourseRecommendationsForJobDescription %s, %s, %s", (json.dumps(job_description_embedding), semester_value, year_value))

    semantic_search_results = cursor.fetchall()


#if __name__ == "__main__":
#   sample_job_description = "We are looking for a data analyst with experience in SQL, Python, and data visualization tools to analyze large datasets and provide insights to drive business decisions."
#   get_course_recommendations_for_selected_job(sample_job_description)

#the secoud openAI model is a generatie model
generative_model = OpenAIEmbeddings(model="gpt-4o-mini", temperature=0) #or gpt-4
    # Generate a human-readable response based on the semantic search results