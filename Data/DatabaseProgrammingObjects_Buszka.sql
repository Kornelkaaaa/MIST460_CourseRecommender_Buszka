USE MIST460_RDB_Buszka;
GO

IF OBJECT_ID('procGetCourseSectionsForSpecifiedCourse') is NOT NULL
    DROP PROCEDURE procGetCourseSectionsForSpecifiedCourse;

IF OBJECT_ID('fnGetSemesterFromMonth') is NOT NULL
    DROP FUNCTION fnGetSemesterFromMonth;

IF OBJECT_ID('procGetCoursePrerequisites') is NOT NULL
    DROP PROCEDURE procGetCoursePrerequisites;

IF OBJECT_ID('fnGetCoursePrerequisites') is NOT NULL
    DROP FUNCTION fnGetCoursePrerequisites;

IF OBJECT_ID('fnGetStudentCourseHistory') is NOT NULL
    DROP FUNCTION fnGetStudentCourseHistory;

IF OBJECT_ID('fnGradePointsFromLetterGrade') is NOT NULL
    DROP FUNCTION fnGradePointsFromLetterGrade;

IF OBJECT_ID('trgDecreaseSectionSeats') is NOT NULL
    DROP TRIGGER trgDecreaseSectionSeats;

GO

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
        prereq.Title, prereq.SubjectCode, prereq.CourseNumber, CP.MinGradeRequired
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

CREATE OR ALTER PROCEDURE procHasStudentMetPrerequisitesForCourse
    @StudentID INT,
    @SubjectCode VARCHAR(30),
    @CourseNumber VARCHAR(30)
AS
BEGIN
/*
SELECT Prerequisites.SubjectCode, Prerequisites.CourseNumber, Prerequisites.MinGradeRequired, History.Grade
FROM fnGetCoursePrerequisites(@SubjectCode, @CourseNumber) AS Prerequisites
LEFT JOIN fnGetStudentCourseHistory(@StudentID) AS History
    ON Prerequisites.SubjectCode = History.SubjectCode
    AND Prerequisites.CourseNumber = History.CourseNumber
    AND dbo.fnGradePointsFromLetterGrade(History.Grade)
        >= dbo.fnGradePointsFromLetterGrade(Prerequisites.MinGradeRequired);
*/
SELECT Prerequisites.SubjectCode, Prerequisites.CourseNumber, Prerequisites.MinGradeRequired
FROM fnGetCoursePrerequisites(@SubjectCode, @CourseNumber) AS Prerequisites
WHERE NOT EXISTS (
    SELECT 1
    FROM fnGetStudentCourseHistory(@StudentID) AS History
    WHERE Prerequisites.SubjectCode = History.SubjectCode
        AND Prerequisites.CourseNumber = History.CourseNumber
        AND dbo.fnGradePointsFromLetterGrade(History.Grade)
            >= dbo.fnGradePointsFromLetterGrade(Prerequisites.MinGradeRequired)
);
END;
GO

----- Usage: 
-- EXEC procHasStudentMetPrerequisitesForCourse @StudentID = 1, @SubjectCode = 'MIST', @CourseNumber = '460'; GO



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

select *
from Registration;