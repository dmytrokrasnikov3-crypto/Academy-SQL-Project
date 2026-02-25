USE Academy;
GO

IF OBJECT_ID('Groups', 'U') IS NOT NULL DROP TABLE Groups;
IF OBJECT_ID('Departments', 'U') IS NOT NULL DROP TABLE Departments;
IF OBJECT_ID('Faculties', 'U') IS NOT NULL DROP TABLE Faculties;
IF OBJECT_ID('Teachers', 'U') IS NOT NULL DROP TABLE Teachers;
GO

CREATE TABLE Groups (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY, 
    Name NVARCHAR(10) NOT NULL UNIQUE CHECK (Name <> ''), 
    Rating INT NOT NULL CHECK (Rating BETWEEN 0 AND 5), 
    Year INT NOT NULL CHECK (Year BETWEEN 1 AND 5)   
);

CREATE TABLE Departments (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Financing MONEY NOT NULL DEFAULT 0 CHECK (Financing >= 0), 
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> '')
);

CREATE TABLE Faculties (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> '')
);

CREATE TABLE Teachers (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    EmploymentDate DATE NOT NULL CHECK (EmploymentDate >= '1990-01-01'), 
    Name NVARCHAR(MAX) NOT NULL CHECK (Name <> ''),
    Premium MONEY NOT NULL DEFAULT 0 CHECK (Premium >= 0),
    Salary MONEY NOT NULL CHECK (Salary > 0), 
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname <> '')
);
GO