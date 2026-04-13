import pymssql
from typing import Optional
from get_db_connection import get_db_connection


def get_course_sections_for_specified_course(
    subject_code: Optional[str] = None,
    course_number: Optional[str] = None,
    ): 
        conn = get_db_connection()
        #cursor = conn.cursor() # Create a cursor object to execute SQL queries
        cursor = conn.cursor(as_dict=True)
        #cursor.execute("{CALL procGetCourseSectionsForSpecifiedCourse (?, ?)}", (subject_code, course_number)) # Execute the stored procedure with parameters
        cursor.callproc("procGetCourseSectionsForSpecifiedCourse", (subject_code, course_number))
        #rows = cursor.fetchall() # Fetch all results
        
        try:
            rows = cursor.fetchall()
        except pymssql.Error:
            rows = []

        conn.close() # Close the database connection if you want close may cost issues 
        
        #convert rows to list of dictionaries

        results = [
                {
                "SubjectCode": row["SubjectCode"],
                "CourseNumber": row["CourseNumber"],
                "SectionNumber": row["SectionNumber"],
                "SectionSemester": row["SectionSemester"],
                "SectionYear": row["SectionYear"],
                "RemainingOpenings": row["RemainingOpenings"],
                "InstructorName": row["InstructorName"],
                }
            for row in rows
        ]


        return {"data": results} # Return the results as a list of tuples
