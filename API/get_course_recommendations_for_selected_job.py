from datetime import datetime
from itertools import chain
from pprint import pprint
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
import pprint
import json
from format_contex import format_context
from get_db_connection import get_db_connection
from find_current_semester import find_current_semester

from langchain_core.prompts import ChatPromptTemplate

def get_course_recommendations_for_selected_job(job_description: str) -> str:

    year_value = datetime.now().year
    semester_value = find_current_semester()
    user_query = f"Based on the following job description, recommend relevant courses from our database offered in {semester_value} {year_value} that would help someone prepare for this job: {job_description}"

    #1. use the OpenAIEmbeddings model to generate a vector embedding for the user query (job description)
    # use the OpenAIEmbeddings model to generate course recommendations based on the user query
    embedding_model = OpenAIEmbeddings(model="text-embedding-3-small")
    
    #2. create an embedding for the user query (job description) using the OpenAIEmbeddings model
    job_description_embedding = embedding_model.embed_query(user_query)

    pprint.pprint(job_description_embedding)

    #print("\nJob Description Embedding:")
    #pprint.pprint(job_description_embedding)

    conn = get_db_connection()
    cursor = conn.cursor(as_dict=True)
    
    cursor.execute("EXEC procGetCourseRecommendationsForSelectedJob %s, %s, %s", (json.dumps(job_description_embedding), semester_value, year_value))

    #semantic_search_results = cursor.fetchall()
    semantically_similar_courses = cursor.fetchall()
    course_count = len(semantically_similar_courses)
    semantic_results_for_context = format_context(semantically_similar_courses)

    cursor.close()
    conn.close()


    pprint.pprint(semantic_results_for_context)
        #if __name__ == "__main__":
        #   sample_job_description = "We are looking for a data analyst with experience in SQL, Python, and data visualization tools to analyze large datasets and provide insights to drive business decisions."
        #   get_course_recommendations_for_selected_job(sample_job_description)

    #the secoud openAI model is a generatie model
    generative_model = ChatOpenAI(model="gpt-4o", temperature=0) #deterministic output for testing we want the same oputput for the same input for the same input every time we run the code

    prompt = ChatPromptTemplate.from_messages([
        (
        "system",
                """
                You are an expert academic advisor helping students identify courses 
                that align with a target job description.

                You will be given:
                - A user query describing a job or career goal
                - A set of retrieved course records, each with a title, description, 
                and a cosine distance score (lower = better match)

                Your task:
                1. For each retrieved course, assess whether it genuinely prepares a 
                student for the stated job role based solely on the course description.
                2. If a course is a strong match, explain specifically which skills or 
                topics in the description align with the job requirements.
                3. Be honest about weak matches rather than forcing a justification.
                4. Rank the courses from most to least relevant in your response.
                5. Do not invent course content, prerequisites, or outcomes not stated 
                in the provided descriptions.
                6. If none of the retrieved courses are a good fit, say so clearly and 
                suggest the student speak with an advisor directly.
                """
        ),
        (
        "human",
                """
                User Query:
                {user_query}

                Retrieved Courses ({course_count} results, ranked by relevance):
                {context}

                Please provide your course recommendations, ranked from best to worst fit.
                Cite the match score and specific evidence from each description to justify 
                your reasoning. Flag any course with a distance score above 0.4 as a weak match.
                """

        )
    ]
    )
    chain = prompt | generative_model 

    response = chain.invoke({
        "user_query": user_query,
        "context": semantic_results_for_context,
        "course_count": course_count
    })
    return response.content