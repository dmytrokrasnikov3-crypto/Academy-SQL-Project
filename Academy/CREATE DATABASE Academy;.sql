CREATE DATABASE Academy;
GO
USE Academy;
GO

CREATE TABLE Faculties (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> '')
);

CREATE TABLE Departments (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Financing MONEY NOT NULL DEFAULT 0 CHECK (Financing >= 0),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> ''),
    FacultyId INT NOT NULL,
    CONSTRAINT FK_Departments_Faculties FOREIGN KEY (FacultyId) REFERENCES Faculties(Id)
);

CREATE TABLE Groups (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(10) NOT NULL UNIQUE CHECK (Name <> ''),
    Year INT NOT NULL CHECK (Year BETWEEN 1 AND 5),
    DepartmentId INT NOT NULL,
    CONSTRAINT FK_Groups_Departments FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

CREATE TABLE Curators (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL CHECK (Name <> ''),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname <> '')
);

CREATE TABLE GroupsCurators (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CuratorId INT NOT NULL,
    GroupId INT NOT NULL,
    CONSTRAINT FK_GroupsCurators_Curators FOREIGN KEY (CuratorId) REFERENCES Curators(Id),
    CONSTRAINT FK_GroupsCurators_Groups FOREIGN KEY (GroupId) REFERENCES Groups(Id)
);

CREATE TABLE Students (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL CHECK (Name <> ''),
    Rating INT NOT NULL CHECK (Rating BETWEEN 0 AND 5),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname <> '')
);

CREATE TABLE GroupsStudents (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    GroupId INT NOT NULL,
    StudentId INT NOT NULL,
    CONSTRAINT FK_GroupsStudents_Groups FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    CONSTRAINT FK_GroupsStudents_Students FOREIGN KEY (StudentId) REFERENCES Students(Id)
);

CREATE TABLE Subjects (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> '')
);

CREATE TABLE Teachers (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    IsProfessor BIT NOT NULL DEFAULT 0,
    Name NVARCHAR(MAX) NOT NULL CHECK (Name <> ''),
    Salary MONEY NOT NULL CHECK (Salary > 0),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname <> '')
);

CREATE TABLE Lectures (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Date] DATE NOT NULL CHECK ([Date] <= GETDATE()),
    SubjectId INT NOT NULL,
    TeacherId INT NOT NULL,
    CONSTRAINT FK_Lectures_Subjects FOREIGN KEY (SubjectId) REFERENCES Subjects(Id),
    CONSTRAINT FK_Lectures_Teachers FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE GroupsLectures (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    GroupId INT NOT NULL,
    LectureId INT NOT NULL,
    CONSTRAINT FK_GroupsLectures_Groups FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    CONSTRAINT FK_GroupsLectures_Lectures FOREIGN KEY (LectureId) REFERENCES Lectures(Id)
);



SELECT Building
FROM Departments
GROUP BY Building
HAVING SUM(Financing) > 100000;

SELECT g.Name
FROM Groups g
JOIN Departments d ON g.DepartmentId = d.Id
JOIN GroupsLectures gl ON g.Id = gl.GroupId
JOIN Lectures l ON gl.LectureId = l.Id
WHERE g.Year = 5 
    AND d.Name = N'Software Development'
    AND DATEPART(week, l.[Date]) = DATEPART(week, GETDATE())
    AND DATEPART(year, l.[Date]) = DATEPART(year, GETDATE())GROUP BY g.Name
HAVING COUNT(gl.LectureId) > 10;

SELECT g.Name
FROM Groups g
JOIN GroupsStudents gs ON g.Id = gs.GroupId
JOIN Students s ON gs.StudentId = s.Id
GROUP BY g.Name
HAVING AVG(CAST(s.Rating AS FLOAT)) > (
    SELECT AVG(CAST(s2.Rating AS FLOAT))
    FROM Groups g2
    JOIN GroupsStudents gs2 ON g2.Id = gs2.GroupId
    JOIN Students s2 ON gs2.StudentId = s2.Id
    WHERE g2.Name = N'D221'
);

SELECT Surname, Name
FROM Teachers
WHERE Salary > (
    SELECT AVG(Salary)
    FROM Teachers
    WHERE IsProfessor = 1
);

SELECT g.Name
FROM Groups g
JOIN GroupsCurators gc ON g.Id = gc.GroupId
GROUP BY g.Name
HAVING COUNT(gc.CuratorId) > 1;


SELECT g.Name
FROM Groups g
JOIN GroupsStudents gs ON g.Id = gs.GroupId
JOIN Students s ON gs.StudentId = s.Id
GROUP BY g.Name
HAVING AVG(CAST(s.Rating AS FLOAT)) < (
    SELECT MIN(AvgRating)
    FROM (
        SELECT AVG(CAST(s2.Rating AS FLOAT)) AS AvgRating
        FROM Groups g2
        JOIN GroupsStudents gs2 ON g2.Id = gs2.GroupId
        JOIN Students s2 ON gs2.StudentId = s2.Id
        WHERE g2.Year = 5
        GROUP BY g2.Id
    ) AS FifthYearRatings
);

SELECT f.Name
FROM Faculties f
JOIN Departments d ON f.Id = d.FacultyId
GROUP BY f.Name
HAVING SUM(d.Financing) > (
    SELECT SUM(d2.Financing)
    FROM Faculties f2
    JOIN Departments d2 ON f2.Id = d2.FacultyId
    WHERE f2.Name = N'Computer Science'
);

SELECT sub.Name AS SubjectName, t.Name + ' ' + t.Surname AS TeacherName
FROM Lectures l
JOIN Subjects sub ON l.SubjectId = sub.Id
JOIN Teachers t ON l.TeacherId = t.Id
GROUP BY sub.Name, t.Name, t.Surname
HAVING COUNT(l.Id) = (
    SELECT MAX(LectureCount)
    FROM (
        SELECT COUNT(Id) AS LectureCount
        FROM Lectures
        WHERE SubjectId = sub.Id
        GROUP BY TeacherId
    ) AS MaxLectures
);


SELECT TOP 1 s.Name
FROM Subjects s
LEFT JOIN Lectures l ON s.Id = l.SubjectId
GROUP BY s.Name
ORDER BY COUNT(l.Id) ASC;

SELECT 
    (SELECT COUNT(DISTINCT gs.StudentId) 
    FROM GroupsStudents gs 
    JOIN Groups g ON gs.GroupId = g.Id 
    JOIN Departments d ON g.DepartmentId = d.Id 
    WHERE d.Name = N'Software Development') AS StudentCount,
    (SELECT COUNT(DISTINCT l.SubjectId) 
    FROM Lectures l 
    JOIN GroupsLectures gl ON l.Id = gl.LectureId
    JOIN Groups g ON gl.GroupId = g.Id
    JOIN Departments d ON g.DepartmentId = d.Id 
    WHERE d.Name = N'Software Development') AS SubjectCount;


