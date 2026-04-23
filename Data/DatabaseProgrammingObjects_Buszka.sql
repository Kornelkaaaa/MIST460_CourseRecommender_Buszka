USE MIST460_RDB_Buszka;
GO


IF OBJECT_ID('procRegisterStudent') is NOT NULL
    DROP PROCEDURE procRegisterStudent;

IF OBJECT_ID('procGetCourseSectionsForSpecifiedCourse') is NOT NULL
    DROP PROCEDURE procGetCourseSectionsForSpecifiedCourse;

IF OBJECT_ID('fnGetSemesterFromMonth') is NOT NULL
    DROP FUNCTION fnGetSemesterFromMonth;

IF OBJECT_ID('procGetCoursePrerequisites') is NOT NULL
    DROP PROCEDURE procGetCoursePrerequisites;

IF OBJECT_ID('procHasStudentMetPrerequisitesForCourse') IS NOT NULL
    DROP PROCEDURE dbo.procHasStudentMetPrerequisitesForCourse;

IF OBJECT_ID('procEnrollStudentInSection') IS NOT NULL
    DROP PROCEDURE procEnrollStudentInSection;

IF OBJECT_ID('fnGetStudentCompletedCourses') is NOT NULL
    DROP FUNCTION fnGetStudentCompletedCourses;

-- NOTE : idk if we need this one
IF OBJECT_ID('procGetStudentID') is NOT NULL
    DROP PROCEDURE procGetStudentID;

IF OBJECT_ID('fnGetStudentCourseHistory') is NOT NULL
    DROP FUNCTION fnGetStudentCourseHistory;

IF OBJECT_ID('fnGradePointsFromLetterGrade') is NOT NULL
    DROP FUNCTION fnGradePointsFromLetterGrade;

IF OBJECT_ID('trgDecreaseSectionSeats') is NOT NULL
    DROP TRIGGER trgDecreaseSectionSeats;

If OBJECT_ID('procGetAllCourses') is NOT NULL
    DROP PROCEDURE procGetAllCourses;

IF OBJECT_ID('procInsertChunk') IS NOT NULL
    DROP PROCEDURE procInsertChunk;

IF OBJECT_ID('procValidateUser') IS NOT NULL
    DROP PROCEDURE procValidateUser;

If OBJECT_ID('procGetAllJobs') is NOT NULL
    DROP PROCEDURE procGetAllJobs;

IF OBJECT_ID('fnGetCourseRecommendationsForSelectedJob') IS NOT NULL
    DROP FUNCTION fnGetCourseRecommendationsForSelectedJob;

IF OBJECT_ID('procGetCourseRecommendationsForJobDescription') IS NOT NULL
    DROP PROCEDURE procGetCourseRecommendationsForJobDescription;

IF OBJECT_ID('fnGradePointsFromLetterGrade') IS NOT NULL
    DROP FUNCTION fnGradePointsFromLetterGrade;

if OBJECT_ID('fnGetCoursePrerequisites') is NOT NULL
    DROP FUNCTION fnGetCoursePrerequisites;

GO

CREATE or ALTER PROCEDURE procGetAllJobs
AS
BEGIN
    SELECT JobTitle, JobDescription
    FROM Job;
END;
GO

CREATE or alter PROCEDURE procGetCourseRecommendationsForJobDescription
(
    @JobDescription vector(1536),
    @semester nvarchar(12) = null,
    @year int = null
)
as
BEGIN
    SELECT courseID, Evidence, Distance, title, subjectCode, courseNumber, courseDescription, SectionID, CRN, SectionNumber, SectionSemester, SectionYear, RemainingOpenings
    FROM fnGetCourseRecommendationsForSelectedJob(@JobDescription) AS Recommendations
    JOIN Course C on Recommendations.CourseID = C.CourseID
    join Section S on C.CourseID = S.CourseID
    where S.SectionSemester = IsNull(@semester, S.SectionSemester)
    and S.SectionYear = IsNull(@year, S.SectionYear)
    order by Distance ASC;
END;
-- professor have diffrent but lowkey this is the same funcionality

GO
CREATE or ALTER FUNCTION fnGetCourseRecommendationsForSelectedJob
(
    @JobDescriptionEmbedding VECTOR(1536)
)
RETURNS @RecommendedCourses TABLE
(
    CourseID INT,
    Evidence NVARCHAR(MAX),
    Distance FLOAT
)
AS
BEGIN
    INSERT into @RecommendedCourses (CourseID, Evidence, Distance)
    select top 5 
        CourseID, 
        MIN(CourseChunk) as Evidence,
        MIN(VectorDistance('cosine', @JobDescriptionEmbedding, ChunkEmbedding)) as Distance -- smaller distance means more similar
    from Chunks
    GROUP by CourseID -- we need min bc group by course and we want the most similar chunk as evidence for each course, so we take the min distance and corresponding chunk for each course
    ORDER by Distance ASC; -- order by similarity (most similar first)

    return;
END;

/*
declare @embedding vector(1536);
set @embedding = (select top 1 ChunkEmbedding from Chunks);
SELECT * FROM dbo.fnGetCourseRecommendationsForSelectedJob(@embedding);
*/

GO


CREATE OR ALTER PROCEDURE procGetAllCourses
AS
BEGIN
    SELECT CourseID, SubjectCode, CourseNumber, Title, CourseDescription
    FROM Course;
END;
GO

create or alter procedure procInsertChunk
(
    @CourseChunk NVARCHAR(MAX),
    @ChunkEmbedding VECTOR(1536),
    @CourseID INT
)
AS
BEGIN
    INSERT INTO Chunks (CourseChunk, ChunkEmbedding, CourseID)
    VALUES (@CourseChunk, @ChunkEmbedding, @CourseID);
END;
GO

-- select * from chunks

-- Need days / times for sections, Location

-- Database Programming Objects (Stored Procedures, User-Defined Functions UDF -> Scalar, Table-valued, Triggers)

-- 1. What are the sections of a specific course (optional entry) offered this semester (spring 2026)?

-- scalar function to get a semester base on month number
CREATE OR ALTER FUNCTION dbo.fnGetSemesterFromMonth()
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
-- select dbo.fnGetSemesterFromMonth() as CurrentSemester;
GO

-- Inputs: SubjectCode and CourseNumber (Course)
-- Conditions: Offered in Spring 2026 (Section)
-- Output: SectionID, InstructorName, SeatsAvailable (Section + Instructor)
create or alter procedure procGetCourseSectionsForSpecifiedCourse
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
    where S.SectionSemester = dbo.fnGetSemesterFromMonth()
    and S.SectionYear = Year(GetDate())
    and C.SubjectCode = ISNULL(@SubjectCode, C.SubjectCode)
    and C.CourseNumber = ISNULL(@CourseNumber, C.CourseNumber)

end;

/*
execute procGetCourseSectionsForSpecifiedCourse
    @SubjectCode = 'MIST',
    @CourseNumber = '460';
*/

go




-- 2. What are the prerequisites for a specific course (optional entry)?

--Input: CourseID
--Output: CourseID, CourseName, PrerequisiteCourseName, MinGradeRequired
--Conditions: Looks up the course (C) and all prerequisite mappings in CoursePrerequisite (CP), Joins CoursePrerequisite.PrerequisiteID to Course.CourseID to get the full details of each prerequisite course, Filters results to only show prerequisites for the specified @CourseID.

GO

CREATE OR ALTER PROCEDURE dbo.procGetCoursePrerequisites
(
    @SubjectCode  VARCHAR(30)   = NULL,
    @CourseNumber VARCHAR(30)  
)
as
BEGIN
    IF (@SubjectCode IS NULL AND @CourseNumber IS NOT NULL)
    BEGIN
        RAISERROR('Both @SubjectCode and @CourseNumber must be provided together, or both left NULL.', 16, 1); --I used AI to help me solve this edge case. 
        RETURN;
    END;
    SELECT
        prereq.Title 'MainCourseTitle', 
        prereq.SubjectCode 'MainCourseSubjectCode', 
        prereq.CourseNumber 'MainCourseNumber', 
        prereq.Title 'PrerequisiteTitle',
        prereq.SubjectCode 'PrerequisiteSubjectCode',
        prereq.CourseNumber 'PrerequisiteCourseNumber',
        CP.MinGradeRequired 'MinGradeRequired'
            FROM CoursePrerequisite CP
        JOIN Course MainCourse ON CP.CourseID = MainCourse.CourseID
        JOIN Course prereq ON CP.PrerequisiteID = prereq.CourseID
    WHERE
        --(@SubjectCode IS NULL OR c.SubjectCode = @SubjectCode)
        MainCourse.SubjectCode = IsNull(@SubjectCode, MainCourse.SubjectCode)
        AND MainCourse.CourseNumber = @CourseNumber;
END;
GO

-- Usage:
-- EXEC procGetCoursePrerequisites @SubjectCode = 'MIST', @CourseNumber = '460'; GO

CREATE or alter function fnGetCoursePrerequisites
(
    @SubjectCode  VARCHAR(30)   = NULL,
    @CourseNumber VARCHAR(30)  
)
RETURNS @Prerequisites table
(
    Title NVARCHAR(100),
    SubjectCode NVARCHAR(10),
    CourseNumber NVARCHAR(10),
    MinGradeRequired NCHAR(2)
)
AS
BEGIN
    insert into @Prerequisites
    (Title, SubjectCode, CourseNumber, MinGradeRequired)
    SELECT
        prereq.Title, prereq.SubjectCode, prereq.CourseNumber, CP.MinGradeRequired
            FROM CoursePrerequisite CP
        JOIN Course MainCourse ON CP.CourseID = MainCourse.CourseID
        JOIN Course prereq ON CP.PrerequisiteID = prereq.CourseID
    WHERE
        MainCourse.SubjectCode = IsNull(@SubjectCode, MainCourse.SubjectCode)
        AND MainCourse.CourseNumber = @CourseNumber;

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

 --CTE -> Common Table Expression -> recursive CTE to find all prerequisites for a course (including indirect ones) and then check if the student has completed them with the required grades.

create or alter function fnGetStudentCourseHistory
(
    @StudentID int
)
returns @CourseHistory table
(
    SubjectCode nvarchar(10),
    CourseNumber nvarchar(10),
    Grade nchar(2)
)
AS
BEGIN
    insert into @CourseHistory
    (SubjectCode, CourseNumber, Grade)
    select 
        C.SubjectCode, 
        C.CourseNumber, 
        RS.LetterGrade
    from Registration R
        join RegistrationSection RS on R.RegistrationID = RS.RegistrationID
        join Section S on RS.SectionID = S.SectionID
        join Course C on S.CourseID = C.CourseID
    where R.StudentID = @StudentID;

    return;
END;
-- select * from fnGetStudentCourseHistory(3);

-- Encapsulate logic inside a stored procedure that 
-- checks if the student has met the prerequisites for a course.
go

create or alter function fnGradePointsFromLetterGrade
(
	@LetterGrade nchar(2)
)
returns int
as
begin
	declare @GradePoints int;
	
	set @GradePoints = case @LetterGrade
		when 'A' then 4
		when 'B' then 3
		when 'C' then 2
		when 'D' then 1
		else 0
	end;

	return @GradePoints;
end;

GO
-- subquery - IN, NOT IN, EXISTS, NOT EXISTS
-- IN non - correlated subquery - returns all the prerequisites for the course 
-- EXIST correlated subquery - checks if there is a record in the student's course history that matches each prerequisite and meets the minimum grade requirement. If any prerequisite does not have a matching record in the student's course history, the procedure will return those prerequisites, indicating that the student has not met all the prerequisites for the course.
-- =============================================
-- Procedure: procHasStudentMetPrerequisitesForCourse
-- Purpose: Checks if a student has completed all prerequisites
--          for a specific course with the required minimum grade.
--          Returns ONLY the prerequisites that have NOT been met.
--          If no rows are returned, the student has met all prerequisites.
-- Parameters:
--    @StudentID    - The ID of the student to check
--    @SubjectCode  - The subject code of the course (e.g., 'MIST')
--    @CourseNumber  - The course number (e.g., '460')
CREATE OR ALTER PROCEDURE procHasStudentMetPrerequisitesForCourse
    @StudentID INT,
    @SubjectCode VARCHAR(30),
    @CourseNumber VARCHAR(30)
AS
BEGIN
SELECT 
-- Step 1: Get all prerequisites for the given course
--         and LEFT JOIN with the student's course history
--         to see what they have completed so far.
    Prerequisites.SubjectCode 'PrerequisiteSubjectCode', 
    Prerequisites.CourseNumber 'PrerequisiteCourseNumber', 
    Prerequisites.MinGradeRequired as 'MinimumGradeRequired',
    
    -- If the student has no matching record, show 'Not Completed'
    IsNull(CAST(History.Grade AS NVARCHAR(20)), 'Not Completed') as 'StudentGrade'

FROM fnGetCoursePrerequisites(@SubjectCode, @CourseNumber) AS Prerequisites

-- LEFT JOIN keeps all prerequisites even if the student
-- has not taken the course yet (History columns will be NULL)
    LEFT JOIN fnGetStudentCourseHistory(@StudentID) AS History
            ON Prerequisites.SubjectCode = History.SubjectCode
            AND Prerequisites.CourseNumber = History.CourseNumber

-- Step 2: Use NOT EXISTS (correlated subquery) to filter out
--         prerequisites the student has already passed.
--         Only prerequisites that are NOT met will remain.
WHERE NOT EXISTS (
    SELECT 1
    FROM fnGetStudentCourseHistory(@StudentID) AS History
    -- Match the prerequisite course with the student's course history
    WHERE Prerequisites.SubjectCode = History.SubjectCode
        AND Prerequisites.CourseNumber = History.CourseNumber
        -- Check if the student's grade meets or exceeds the minimum grade required for the prerequisite
        AND dbo.fnGradePointsFromLetterGrade(History.Grade)
            >= dbo.fnGradePointsFromLetterGrade(Prerequisites.MinGradeRequired)
);
END;
GO
-- double negative logic - NOT EXISTS to find any prerequisites that the student has not met. If the result set is empty, it means the student has met all prerequisites. If there are records returned, those represent the prerequisites that have not been met by the student.
----- Usage: 
-- EXEC procHasStudentMetPrerequisitesForCourse @StudentID = 1, @SubjectCode = 'MIST', @CourseNumber = '460'; GO
-- EXEC procHasStudentMetPrerequisitesForCourse @StudentID = 2, @SubjectCode = 'MIST', @CourseNumber = '460'; GO
-- EXEC procHasStudentMetPrerequisitesForCourse @StudentID = 3, @SubjectCode = 'MIST', @CourseNumber = '460'; GO


-- know the triggers 
create or alter TRIGGER trgDecreaseSectionSeats
ON RegistrationSection
AFTER INSERT -- triggering event
AS
BEGIN -- trigger action -- logic to execute when the trigger is fired
    -- Decrease the RemainingOpenings in the Section table by 1 for the corresponding SectionID
    UPDATE Section
    SET RemainingOpenings = RemainingOpenings - 1
    FROM Section S
    JOIN inserted I ON S.SectionID = I.SectionID;
END;

go


create procedure procEnrollStudentInSection
(
    @RegistrationID int,
    @SectionID int
)
as
begin
    insert into RegistrationSection (RegistrationID, SectionID)
    values (@RegistrationID, @SectionID); -- this should trigger the decrease in RemainingOpenings for SectionID = 1
end;
-- EXEC procEnrollStudentInSection @RegistrationID = 1, @SectionID = 1;
go

/**
select * from Section
GO
select * from Course
GO
select * from Student
GO
select * from AppUser
go
**/

CREATE OR ALTER PROCEDURE procGetStudentID
(
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100),
    @StudentID INT OUTPUT
)
AS
BEGIN
    SELECT @StudentID = S.StudentID
    FROM Student S
    INNER JOIN AppUser as A ON S.StudentID = A.AppUserID
    WHERE A.FirstName = @FirstName
      AND A.LastName = @LastName
      AND A.Email = @Email
      AND S.StudentID = A.AppUserID
      AND UserRole = 'Student';
END
GO
--select * from Registration;
go
-- EXEC procGetStudentID @FirstName = 'Michael', @LastName = 'Jordan', @Email ='mjordan@wvu.edu'
-- 1. Create a stored procedure to register a student (procRegisterStudent) that takes student details as input and inserts a new record into the Student table. 
CREATE or ALTER PROCEDURE dbo.procRegisterStudent
(
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100),
    @RegistrationSemester NVARCHAR(12) = NULL,
    @RegistrationYear INT = Null
)
AS
BEGIN

    DECLARE @StudentID INT;
    -- i assumed that student do not know thier student id but idk is easy to change too
    EXEC dbo.procGetStudentID 
        @FirstName = @FirstName, 
        @LastName = @LastName,
        @Email = @Email,
        @StudentID = @StudentID OUTPUT;

    IF @StudentID IS NULL
    BEGIN
        RAISERROR('Student not found.', 16, 1);
        RETURN;
    END;

    IF @RegistrationSemester IS NULL
        SET @RegistrationSemester = dbo.fnGetSemesterFromMonth();

    IF @RegistrationYear IS NULL
        SET @RegistrationYear = YEAR(GETDATE());

    INSERT INTO Registration (StudentID, RegistrationDate, RegistrationSemester, RegistrationYear)
    VALUES (@StudentID, GETDATE(), @RegistrationSemester, @RegistrationYear)
END
GO
-- EXEC dbo.procRegisterStudent @FirstName = 'Michael', @LastName = 'Jordan', @Email = 'mjordan@wvu.edu', @RegistrationSemester = 'Spring', @RegistrationYear = 2026;
-- EXEC dbo.procRegisterStudent @FirstName = 'Alex', @LastName = 'Kim', @Email = 'akim@wvu.edu', @RegistrationSemester = 'Spring', @RegistrationYear = 2026;
-- 

--2. Insert Registration record / data for student 3 2026
-- EXEC dbo.procRegisterStudent @FirstName = 'Alex', @LastName = 'Kim', @Email = 'akim@wvu.edu', @RegistrationSemester = 'Spring', @RegistrationYear = 2026;

--3. Enroll student in a section of MIST 460 using the procEnrollStudentInSection procedure and verify that the RemainingOpenings for that section decreases by 1.
-- EXEC procEnrollStudentInSection @RegistrationID = 16, @SectionID = 17;
-- it is working :)

create or alter procedure procValidateUser
(@username nvarchar(320), @password nvarchar(100))
as
begin
	select AppUserID 'AppUserID', 
    Firstname + ' ' + Lastname as Fullname
	from AppUser
	where Email = @username and
		PasswordHash = CONVERT(VARBINARY(64), @password, 1)
end;

/*
execute procValidateUser
@username = 'mjordan@wvu.edu', 
@password = '0x01';

select AppUserID, Firstname, LastName, Email, PasswordHash
from AppUser
*/

--- Logic for enrolling a student in a course section (Input -> Creating / Inserting; Updating -> Delete / Insert)
-- Write down the steps you would take to enroll a student in a course section, including any checks you would perform

-- Register a student for a semester - procRegisterStudent
-- Before enrolling, validate ALL of the following:
-- Check if section Exists & Has Available Seats
-- Check course prerequisites - procGetCoursePrerequisites
-- Check for Duplicate Enrollment\
-- Check time conflicts 
-- Check credit hour limits
-- check Student Status if is Active
-- Enroll student in a course section (with automatic seat count update) - procEnrollStudentInSection + trgDecreaseSectionSeats

