from typing import Optional
from get_db_connection import get_db_connection

def get_course_prerequisites(
    subject_code: Optional[str] = None,
    course_number: Optional[str] = None,
):
    conn = get_db_connection()
    cursor = conn.cursor() # Create a cursor object to execute SQL queries
    cursor.execute("{CALL procGetCoursePrerequisites (?, ?)}", (subject_code, course_number)) # Execute the stored procedure with parameters
    rows = cursor.fetchall() # Fetch all results
    conn.close() # Close the database connection if you want close may cost issues 
        
        #convert rows to list of dictionaries

    results = [
        {
            "MainCourseTitle": row.MainCourseTitle,
            "MainCourseSubjectCode": row.MainCourseSubjectCode,
            "MainCourseNumber": row.MainCourseNumber,
            "PrerequisiteTitle": row.PrerequisiteTitle,
            "PrerequisiteSubjectCode": row.PrerequisiteSubjectCode,
            "PrerequisiteCourseNumber": row.PrerequisiteCourseNumber,
            "MinGradeRequired": row.MinGradeRequired
        }
        for row in rows
    ]

    return {"data": results}
