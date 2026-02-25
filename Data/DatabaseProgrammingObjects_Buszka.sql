USE MIST460_RDB_Buszka;
GO

-- Need days / times for sections, Location

-- Database Programming Objects (Stored Procedures, User-Defined Functions UDF -> Scalar, Table-valued, Triggers)

-- 1. What are the sections of a specific course (optional entry) offered this semester (spring 2026)?

-- scalar function to get a semester base on month number
CREATE OR ALTER FUNCTION dbo.GetSemesterFromMonth()
returns nvarchar(20)
AS
BEGIN
    declare @MonthNumber int = month(getdate());
    declare @Semester nvarchar(20);

    if @MonthNumber in (1, 2, 3, 4, 5)
        set @Semester = N'Spring';
    else if @MonthNumber in (6, 7)
        set @Semester = N'Summer';
    else
        set @Semester = N'Fall';

    return @Semester;
END;
-- select dbo.GetSemesterFromMonth() as CurrentSemester;
GO

-- Inputs: SubjectCode and CourseNumber (Course)
-- Conditions: Offered in Spring 2026 (Section)
-- Output: SectionID, InstructorName, SeatsAvailable (Section + Instructor)
create or alter procedure GetCourseSectionsForSpecifiedCourse
(
    @SubjectCode nvarchar(10) = null,
    @CourseNumber nvarchar(10) = null
)
AS
begin
    select
        C.SubjectCode, 
        C.CourseNumber, 
        C.Title, 
        S.SectionID, 
        S.CRN, 
        S.SectionNumber, 
        S.SectionSemester, 
        S.SectionYear, 
        S.RemainingOpenings,
        I.FirstName + ' ' + I.LastName AS InstructorName
    from Section S  
        inner join Course C on S.CourseID = C.CourseID
        inner join Instructor I on S.InstructorID = I.InstructorID
    where S.SectionSemester = dbo.GetSemesterFromMonth()
    and S.SectionYear = Year(GetDate())
    and C.SubjectCode = ISNULL(@SubjectCode, C.SubjectCode)
    and C.CourseNumber = ISNULL(@CourseNumber, C.CourseNumber)

end;

/*
execute GetCourseSectionsForSpecifiedCourse
    @SubjectCode = 'MIST',
    @CourseNumber = '460';
*/

go




-- 2. What are the prerequisites for a specific course (optional entry)?

--Input: CourseID
--Output: CourseID, CourseName, PrerequisiteCourseName, MinGradeRequired
--Conditions: Looks up the course (C) and all prerequisite mappings in CoursePrerequisite (CP), Joins CoursePrerequisite.PrerequisiteID to Course.CourseID to get the full details of each prerequisite course, Filters results to only show prerequisites for the specified @CourseID.

CREATE or alter PROCEDURE GetCoursePrerequisites
    @CourseID INT
AS
BEGIN
    SELECT  c.CourseID,
            c.SubjectCode + ' ' + c.CourseNumber AS Course,
            c.Title,
            prereq.SubjectCode + ' ' + prereq.CourseNumber AS PrerequisiteCourse,
            prereq.Title AS PrerequisiteTitle,
            cp.MinGradeRequired
    FROM    Course as c
    JOIN    CoursePrerequisite cp    ON c.CourseID = cp.CourseID
    JOIN    Course prereq      ON cp.PrerequisiteID = prereq.CourseID
    WHERE   c.CourseID = @CourseID;
END;
GO

-- Usage:
-- EXEC GetCoursePrerequisites @CourseID = 4; GO

--3. Has spceific student completed the prerequisites for a specific course?
-- We need small module ?so less line maybe other store pocedures which can we use in future
CREATE OR ALTER PROCEDURE CheckStudentPrerequisites
    @StudentID  INT,
    @CourseID   INT
AS
BEGIN
    SELECT  
        prereq.SubjectCode + ' ' + prereq.CourseNumber AS PrerequisiteCourse,
        prereq.Title                                   AS PrerequisiteTitle,
        cp.MinGradeRequired                                    AS RequiredMinGrade,
        rs.LetterGrade                                 AS StudentGrade,
        CASE 
            WHEN rs.LetterGrade IS NULL THEN 'Not Completed'
            WHEN rs.LetterGrade IN ('A', 'B', 'C', 'D', 'F') 
             AND rs.LetterGrade <= cp.MinGradeRequired          THEN 'Completed'
            ELSE 'Not Completed'
        END AS PrerequisiteStatus

    FROM CoursePrerequisite as cp
    --The Course table is joined TWICE — once for the main course, once for the prerequisite:
    JOIN Course as prereq  ON cp.PrerequisiteID = prereq.CourseID

    -- Find the section for the prereq course
    LEFT JOIN Section as s  ON s.CourseID = prereq.CourseID

    -- Find if the student was enrolled in that section
    LEFT JOIN RegistrationSection as rs  ON rs.SectionID = s.SectionID AND rs.EnrollmentStatus = 'Completed'

    -- Link back to the student
    LEFT JOIN Registration as r  ON rs.RegistrationID = r.RegistrationID AND r.StudentID = @StudentID

    WHERE cp.CourseID = @CourseID;
END;
GO

-- Usage:
-- EXEC CheckStudentPrerequisites @StudentID = 1, @CourseID = 2


