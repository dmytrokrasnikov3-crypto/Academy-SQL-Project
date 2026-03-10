USE Academy;
GO

IF OBJECT_ID('Groups', 'U') IS NOT NULL DROP TABLE Groups;
IF OBJECT_ID('Departments', 'U') IS NOT NULL DROP TABLE Departments;
IF OBJECT_ID('Faculties', 'U') IS NOT NULL DROP TABLE Faculties;
IF OBJECT_ID('Teachers', 'U') IS NOT NULL DROP TABLE Teachers;
GO

USE Academy;
GO

ALTER TABLE Faculties
ADD Dean NVARCHAR(MAX) NOT NULL DEFAULT 'No Dean' CHECK (Dean <> '');

ALTER TABLE Teachers
ADD IsAssistant BIT NOT NULL DEFAULT 0,
    IsProfessor BIT NOT NULL DEFAULT 0,
    Position NVARCHAR(MAX) NOT NULL DEFAULT 'Lecturer' CHECK (Position <> '');
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

INSERT INTO Faculties (Name, Dean) VALUES 
(N'Computer Science', N'James Smith'),
(N'Software Engineering', N'Linda Brown');

INSERT INTO Departments (Name, Financing) VALUES 
(N'Software Development', 15000),
(N'Cybersecurity', 9000),
(N'Artificial Intelligence', 30000);

INSERT INTO Groups (Name, Rating, Year) VALUES 
(N'СПР 514', 5, 3), 
(N'СПР 513', 3, 2),
(N'PR-511', 4, 5);

INSERT INTO Teachers (Name, Surname, Position, Salary, Premium, EmploymentDate, IsAssistant, IsProfessor) VALUES 
(N'John', N'Doe', N'Professor', 1100, 200, '1995-03-10', 0, 1),
(N'Jane', N'Smith', N'Assistant', 500, 150, '2010-05-20', 1, 0),
(N'Mike', N'Ross', N'Professor', 1200, 500, '1999-12-01', 0, 1);
GO

