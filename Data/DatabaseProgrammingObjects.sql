USE MIST460_RDB_Buszka;
GO
-- 1. What are the sections of a specific course (optional entry) offered this semester (spring 2026)?
CREATE PROCEDURE GetCourseSectionsBySemester
    @Semester   NVARCHAR(12) = N'Spring',
    @Year       INT          = 2026,  --idk if this should be a default or not, but it is required or should be paramaetr :(
    @CourseID   INT          = NULL  
AS
BEGIN
    SELECT  s.SectionID,
            s.SectionNumber,
            s.CRN,
            s.SectionSemester,
            s.SectionYear,
            s.RemainingOpenings,
            s.SectionAverageRating,
            c.SubjectCode,
            c.CourseNumber,
            c.Title,
            i.FirstName + ' ' + i.LastName AS InstructorName
    FROM    Section s
    JOIN    Course     c ON s.CourseID     = c.CourseID
    JOIN    Instructor i ON s.InstructorID = i.InstructorID
    WHERE   s.SectionSemester = @Semester
      AND   s.SectionYear     = @Year
      AND   (@CourseID IS NULL OR s.CourseID = @CourseID);
END;
GO
-- Usage:
-- All sections this semester:        EXEC GetCourseSectionsBySemester; GO
-- Specific course:                   EXEC GetCourseSectionsBySemester @CourseID = 1; GO 
-- Different semester:                EXEC GetCourseSectionsBySemester @semester = 'Fall', @year = 2025; GO


-- 2. Wheat are the prequisites for a specific course (optional entry)?
CREATE PROCEDURE GetCoursePrerequisites
    @CourseID INT
AS
BEGIN
    SELECT  c.CourseID,
            c.SubjectCode + ' ' + c.CourseNumber AS Course,
            c.Title,
            prereq.SubjectCode + ' ' + prereq.CourseNumber AS PrerequisiteCourse,
            prereq.Title AS PrerequisiteTitle,
            cp.MinGrade
    FROM    Course as c
    JOIN    CoursePrereq cp    ON c.CourseID = cp.CourseID
    JOIN    Course prereq      ON cp.PrereqCourseID = prereq.CourseID
    WHERE   c.CourseID = @CourseID;
END;
GO

-- Usage:
-- EXEC GetCoursePrerequisites @CourseID = 2; GO