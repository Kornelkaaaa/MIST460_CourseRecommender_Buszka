-- 1. What are the sections of a specific course (optional entry) offered this semester (spring 2026)?
CREATE PROCEDURE GetCourseSectionsBySemester
    @semester VARCHAR(20) = 'Spring',
    @year INT = 2026,
    @course_id VARCHAR(20) = NULL  -- optional filter by course
AS
BEGIN
    SELECT s.section_id, s.section_number, s.semester, s.year
    FROM Sections s
    WHERE s.semester = @semester
      AND s.year = @year
      AND (@course_id IS NULL OR s.course_id = @course_id);
END;
GO
-- Usage:
-- All sections this semester:        EXEC GetCourseSectionsBySemester; GO
-- Specific course:                   EXEC GetCourseSectionsBySemester @course_id = 1; GO 
-- Different semester:                EXEC GetCourseSectionsBySemester @semester = 'Fall', @year = 2025; GO


-- 2. Wheat are the prequisites for a specific course (optional entry)?
CREATE PROCEDURE GetCoursePrerequisites
    @course_id VARCHAR(20)
AS
BEGIN
    SELECT c.course_id, c.course_name, p.prerequisite_course_id
    FROM Courses c
    JOIN Prerequisites p ON c.course_id = p.course_id
    WHERE c.course_id = @course_id;
END;
GO

-- Usage:
-- EXEC GetCoursePrerequisites @course_id = 1; GO