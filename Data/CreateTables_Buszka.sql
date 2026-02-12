use master

--create database MIST460_RDB_Buszka

use MIST460_RDB_Buszka
GO

--Drop tables if they exist to avoid errors when running the script multiple times
if object_id('Student') is not null
    drop table Student

if object_id('AppUser') is not null
    drop table AppUser



GO

create table AppUser
(
    AppUserID int identity(1,1) 
        CONSTRAINT PK_AppUser primary key,
    FirstName NVARCHAR(50) not null,
    LastName NVARCHAR(50) not null,
    Email VARCHAR(100) not null,
        CONSTRAINT UK_AppUser_Email UNIQUE(Email),
    PhoneNumber NVARCHAR(20) null,
    PasswordHash VARBINARY(255) not null,
    UserRole NVARCHAR(20) not null
        CONSTRAINT CK_AppUser_UserRole CHECK (UserRole IN ('Student', 'Advisor', 'Alum'))
);
GO

create table Student
(
    StudentID int identity(1,1) 
        CONSTRAINT PK_Student primary key
        CONSTRAINT FK_Student_AppUser foreign key references AppUser(AppUserID),
    TotalCreteditsCompleted int not null
        CONSTRAINT DF_Student_CreditsCompleted default 0,
    GraduationYear NVARCHAR(25) not null,
    OverallGPA decimal(3,2) not null
        CONSTRAINT DF_Student_OverallGPA default 0.00,
    MajorGPA decimal(3,2) not null
        CONSTRAINT DF_Student_MajorGPA default 0.00
);
GO
