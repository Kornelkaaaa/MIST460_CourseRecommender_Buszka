from typing import Optional
from fastapi import FastAPI
from API.get_course_sections_for_specified_course_ui import get_course_sections_for_specified_course
from get_course_prerequisites_ui import get_course_prerequisites

#
app = FastAPI()

@app.get("/get_course_sections_for_specified_course/")
#This endpoint allows a client (browser, app, or Postman) to request all available sections for a specific course.
def get_course_sections_for_specified_course_endpoint(subject_code: Optional[str] = None, course_number: Optional[str] = None):
    return get_course_sections_for_specified_course(subject_code, course_number)

@app.get("/get_course_prerequisites/")
#if we will not add _enpoint the function will never stop run itselt and never reach to get_course_prerequisites.py
def get_course_prerequisites_endpoint(subject_code: Optional[str] = None, course_number: Optional[str] = None,):
    return get_course_prerequisites(subject_code, course_number)

""""
HOW IT WORKS:
    1. User sends a GET request like:
       /get_course_sections_for_specified_course?subject_code=CS&course_number=220

    2. FastAPI automatically extracts query parameters and passes them
       into this function.

    3. This function calls your helper function:
       get_course_sections_for_specified_course()

    4. That function likely:
       - Connects to a database
       - Runs a SQL query
       - Returns matching course sections

    5. The result is returned as JSON automatically by FastAPI.
"""
