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

CREATE OR ALTER PROCEDURE dbo.GetCoursePrerequisites
(
    @CourseID     INT           = NULL,
    @SubjectCode  VARCHAR(10)   = NULL,
    @CourseNumber VARCHAR(10)   = NULL
)
as
BEGIN
    SELECT prereq.Title, prereq.SubjectCode, prereq.CourseNumber
    FROM CoursePrerequisite AS cp
    JOIN Course AS prereq ON cp.PrerequisiteID = prereq.CourseID
    JOIN Course AS mainCourse ON cp.CourseID = mainCourse.CourseID
    WHERE mainCourse.SubjectCode = ISNULL(@SubjectCode, mainCourse.SubjectCode)
    AND mainCourse.CourseNumber = @CourseNumber
END;
GO

-- Usage:
-- EXEC GetCoursePrerequisites @SubjectCode = 'MIST', @CourseNumber = '460'; GO

CREATE or alter function fnGetCoursePrerequisites
(
    @SubjectCode  VARCHAR(10)   = NULL,
    @CourseNumber VARCHAR(10)   = NULL
)
RETURNS @Prerequisites table
(
    Title NVARCHAR(200),
    SubjectCode NVARCHAR(10),
    CourseNumber NVARCHAR(10)
)
AS
BEGIN
    insert into @Prerequisites
    (Title, SubjectCode, CourseNumber)
    select prereq.Title, prereq.SubjectCode, prereq.CourseNumber
    from CoursePrerequisite AS cp
    JOIN Course AS prereq ON cp.PrerequisiteID = prereq.CourseID
    JOIN Course AS mainCourse ON cp.CourseID = mainCourse.CourseID
    WHERE mainCourse.SubjectCode = ISNULL(@SubjectCode, mainCourse.SubjectCode)
    AND mainCourse.CourseNumber = @CourseNumber

    return;
END;
GO
-- Usage:
-- SELECT * FROM dbo.fnGetCoursePrerequisites('MIST', '460');GO
--3. Has spceific student completed the prerequisites for a specific course?
-- We need small module ?so less line maybe other store pocedures which can we use in future

-- Find all the courses that spectied student has taken
create or alter FUNCTION fnGetStudentCompletedCourses
(
    @StudentID int
)
returns @CourseHistory table
(
    SubjectCode nvarchar(10),
    CourseNumber nvarchar(10),
    Grade nchar(2)
)
as 
BEGIN
    insert into @CourseHistory
    (SubjectCode, CourseNumber, Grade)
    select 
        C.SubjectCode, 
        C.CourseNumber, 
        rs.LetterGrade
    from Registration R
    join RegistrationSection rs on R.RegistrationID = rs.RegistrationID
    join Section S on rs.SectionID = S.SectionID
    join Course C on S.CourseID = C.CourseID
    where R.StudentID = @StudentID;

    return;
END;
GO
-- Usage:
-- select * from fnGetStudentCompletedCourses(@StudentID = 1);

-- DECLARE @firstGrade nchar(2), @secondGrade nchar(2);
-- set @firstGrade = 'B';
-- set @secondGrade = 'C';
-- print(ASCII(@firstGrade));
-- print(ASCII(@secondGrade));
-- if(@firstGrade >= @secondGrade)
--     print "First grade is higher or equal to second grade";
-- else
--     print "First grade is lower than second grade"; 
-- go
 
 --Has specific student completed all prerequisites for a specific course?
 -- just make a lot of details and use other store procedure

 --azure account. set up an azure sql servier database, create me as user -> run objects, setects