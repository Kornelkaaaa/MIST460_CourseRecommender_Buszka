from typing import Optional

import pymssql
from get_db_connection import get_db_connection

def has_student_met_prerequisites_for_course(
    student_id: int,
    subject_code:str,
    course_number: str,
):
    conn = get_db_connection()
    #cursor = conn.cursor() # Create a cursor object to execute SQL queries
    cursor = conn.cursor(as_dict=True)

    #cursor.execute("{CALL procHasStudentMetPrerequisitesForCourse (?, ?, ?)}", (student_id, subject_code, course_number)) # Execute the stored procedure with parameters
    
    #cursor.callproc("procHasStudentMetPrerequisitesForCourse", (student_id, subject_code, course_number))
    
    cursor.execute("EXEC procHasStudentMetPrerequisitesForCourse %s, %s, %s", (student_id, subject_code, course_number))

    #rows = cursor.fetchall() # Fetch all results
    try:
        rows = cursor.fetchall()
    except pymssql.Error:
        rows = []

    conn.close() # Close the database connection if you want close may cost issues
        
    results = [
        {
            "PrerequisiteSubjectCode": row["PrerequisiteSubjectCode"],
            "PrerequisiteCourseNumber": row["PrerequisiteCourseNumber"],
            "MinimumGradeRequired": row["MinimumGradeRequired"],
            "StudentGrade": row["StudentGrade"]
        }
        for row in rows
    ]
    return {"data": results}