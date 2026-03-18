CREATE DATABASE Academy_New;
GO
USE Academy_New;
GO

CREATE TABLE Faculties (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Financing MONEY NOT NULL DEFAULT 0 CHECK (Financing >= 0),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> '')
);

CREATE TABLE Departments (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Financing MONEY NOT NULL DEFAULT 0 CHECK (Financing >= 0),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> ''),
    FacultyId INT NOT NULL,
    CONSTRAINT FK_Departments_Faculties FOREIGN KEY (FacultyId) REFERENCES Faculties(Id)
);

CREATE TABLE Subjects (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> '')
);

CREATE TABLE Teachers (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL CHECK (Name <> ''),
    Salary MONEY NOT NULL CHECK (Salary > 0),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname <> '')
);

CREATE TABLE Curators (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL CHECK (Name <> ''),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname <> '')
);

CREATE TABLE Groups (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(10) NOT NULL UNIQUE CHECK (Name <> ''),
    Year INT NOT NULL CHECK (Year BETWEEN 1 AND 5),
    DepartmentId INT NOT NULL,
    CONSTRAINT FK_Groups_Departments FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

CREATE TABLE Lectures (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    LectureRoom NVARCHAR(MAX) NOT NULL CHECK (LectureRoom <> ''),
    SubjectId INT NOT NULL,
    TeacherId INT NOT NULL,
    CONSTRAINT FK_Lectures_Subjects FOREIGN KEY (SubjectId) REFERENCES Subjects(Id),
    CONSTRAINT FK_Lectures_Teachers FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE GroupsCurators (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CuratorId INT NOT NULL,
    GroupId INT NOT NULL,
    CONSTRAINT FK_GroupsCurators_Curators FOREIGN KEY (CuratorId) REFERENCES Curators(Id),
    CONSTRAINT FK_GroupsCurators_Groups FOREIGN KEY (GroupId) REFERENCES Groups(Id)
);

CREATE TABLE GroupsLectures (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    GroupId INT NOT NULL,
    LectureId INT NOT NULL,
    CONSTRAINT FK_GroupsLectures_Groups FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    CONSTRAINT FK_GroupsLectures_Lectures FOREIGN KEY (LectureId) REFERENCES Lectures(Id)
);

USE Academy_New;
GO

ALTER TABLE Lectures 
ADD DayOfWeek INT NOT NULL DEFAULT 1;

ALTER TABLE Lectures 
ADD CONSTRAINT CHK_Lectures_DayOfWeek CHECK (DayOfWeek BETWEEN 1 AND 7);

ALTER TABLE Teachers 
ADD CONSTRAINT CHK_Teachers_Salary_New CHECK (Salary > 0);

ALTER TABLE Groups 
ADD CONSTRAINT CHK_Groups_Year_New CHECK (Year BETWEEN 1 AND 5);


SELECT COUNT(DISTINCT T.Id) AS TeachersCount
FROM Teachers T
JOIN Lectures L ON T.Id = L.TeacherId
JOIN GroupsLectures GL ON L.Id = GL.LectureId
JOIN Groups G ON GL.GroupId = G.Id
JOIN Departments D ON G.DepartmentId = D.Id
WHERE D.Name = N'Software Development';

SELECT COUNT(L.Id) AS LecturesCount
FROM Lectures L
JOIN Teachers T ON L.TeacherId = T.Id
WHERE T.Name = N'Dave' AND T.Surname = N'McQueen';

SELECT COUNT(Id) AS LecturesCount
FROM Lectures
WHERE LectureRoom = N'D201';

SELECT LectureRoom, COUNT(Id) AS LecturesCount
FROM Lectures
GROUP BY LectureRoom;

SELECT COUNT(DISTINCT GL.GroupId) AS GroupsCount
FROM GroupsLectures GL
JOIN Lectures L ON GL.LectureId = L.Id
JOIN Teachers T ON L.TeacherId = T.Id
WHERE T.Name = N'Jack' AND T.Surname = N'Underhill';

SELECT AVG(T.Salary) AS AverageSalary
FROM Teachers T
JOIN Lectures L ON T.Id = L.TeacherId
JOIN GroupsLectures GL ON L.Id = GL.LectureId
JOIN Groups G ON GL.GroupId = G.Id
JOIN Departments D ON G.DepartmentId = D.Id
JOIN Faculties F ON D.FacultyId = F.Id
WHERE F.Name = N'Computer Science';

SELECT MIN(StudentCount) AS MinStudents, MAX(StudentCount) AS MaxStudents
FROM Groups;

SELECT AVG(Financing) AS AverageFinancing
FROM Departments;

SELECT T.Name + ' ' + T.Surname AS FullName, COUNT(DISTINCT L.SubjectId) AS SubjectsCount
FROM Teachers T
JOIN Lectures L ON T.Id = L.TeacherId
GROUP BY T.Id, T.Name, T.Surname;

SELECT DayOfWeek, COUNT(Id) AS LecturesCount
FROM Lectures
GROUP BY DayOfWeek;

SELECT L.LectureRoom, COUNT(DISTINCT D.Id) AS DepartmentsCount
FROM Lectures L
JOIN GroupsLectures GL ON L.Id = GL.LectureId
JOIN Groups G ON GL.GroupId = G.Id
JOIN Departments D ON G.DepartmentId = D.Id
GROUP BY L.LectureRoom;

SELECT F.Name, COUNT(DISTINCT L.SubjectId) AS SubjectsCount
FROM Faculties F
JOIN Departments D ON F.Id = D.FacultyId
JOIN Groups G ON D.Id = G.DepartmentId
JOIN GroupsLectures GL ON G.Id = GL.GroupId
JOIN Lectures L ON GL.LectureId = L.Id
GROUP BY F.Name;

SELECT T.Name + ' ' + T.Surname AS TeacherName, L.LectureRoom, COUNT(L.Id) AS LecturesCount
FROM Teachers T
JOIN Lectures L ON T.Id = L.TeacherId
GROUP BY T.Id, T.Name, T.Surname, L.LectureRoom;