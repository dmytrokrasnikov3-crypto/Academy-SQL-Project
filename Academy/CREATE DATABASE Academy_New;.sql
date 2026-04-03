CREATE DATABASE Academy_New;
GO
USE Academy_New;
GO

CREATE TABLE Teachers (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL,
    Surname NVARCHAR(MAX) NOT NULL
);

CREATE TABLE Subjects (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE LectureRooms (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Building INT NOT NULL,
    Name NVARCHAR(10) NOT NULL
);

CREATE TABLE Deans (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TeacherId INT NOT NULL UNIQUE,
    CONSTRAINT FK_Deans_Teachers FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE Heads (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TeacherId INT NOT NULL UNIQUE,
    CONSTRAINT FK_Heads_Teachers FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE Curators (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TeacherId INT NOT NULL UNIQUE,
    CONSTRAINT FK_Curators_Teachers FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE Assistants (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TeacherId INT NOT NULL UNIQUE,
    CONSTRAINT FK_Assistants_Teachers FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE Faculties (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Building INT NOT NULL,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    DeanId INT NOT NULL,
    CONSTRAINT FK_Faculties_Deans FOREIGN KEY (DeanId) REFERENCES Deans(Id)
);

CREATE TABLE Departments (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Building INT NOT NULL,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    FacultyId INT NOT NULL,
    HeadId INT NOT NULL,
    CONSTRAINT FK_Departments_Faculties FOREIGN KEY (FacultyId) REFERENCES Faculties(Id),
    CONSTRAINT FK_Departments_Heads FOREIGN KEY (HeadId) REFERENCES Heads(Id)
);

CREATE TABLE Groups (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(10) NOT NULL UNIQUE,
    Year INT NOT NULL,
    DepartmentId INT NOT NULL,
    CONSTRAINT FK_Groups_Departments FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

CREATE TABLE GroupsCurators (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    CuratorId INT NOT NULL,
    GroupId INT NOT NULL,
    CONSTRAINT FK_GroupsCurators_Curators FOREIGN KEY (CuratorId) REFERENCES Curators(Id),
    CONSTRAINT FK_GroupsCurators_Groups FOREIGN KEY (GroupId) REFERENCES Groups(Id)
);

-- 5. Лекції та розклад
CREATE TABLE Lectures (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    SubjectId INT NOT NULL,
    TeacherId INT NOT NULL,
    CONSTRAINT FK_Lectures_Subjects FOREIGN KEY (SubjectId) REFERENCES Subjects(Id),
    CONSTRAINT FK_Lectures_Teachers FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE GroupsLectures (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    GroupId INT NOT NULL,
    LectureId INT NOT NULL,
    CONSTRAINT FK_GroupsLectures_Groups FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    CONSTRAINT FK_GroupsLectures_Lectures FOREIGN KEY (LectureId) REFERENCES Lectures(Id)
);

CREATE TABLE Schedules (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Class INT NOT NULL,
    DayOfWeek INT NOT NULL,
    Week INT NOT NULL,
    LectureId INT NOT NULL,
    LectureRoomId INT NOT NULL,
    CONSTRAINT FK_Schedules_Lectures FOREIGN KEY (LectureId) REFERENCES Lectures(Id),
    CONSTRAINT FK_Schedules_LectureRooms FOREIGN KEY (LectureRoomId) REFERENCES LectureRooms(Id)
);



SELECT DISTINCT lr.Name 
FROM LectureRooms lr
JOIN Schedules s ON lr.Id = s.LectureRoomId
JOIN Lectures l ON s.LectureId = l.Id
JOIN Teachers t ON l.TeacherId = t.Id
WHERE t.Name = 'Edward' AND t.Surname = 'Hopper';

SELECT DISTINCT t.Surname 
FROM Teachers t
JOIN Assistants a ON t.Id = a.TeacherId
JOIN Lectures l ON t.Id = l.TeacherId
JOIN GroupsLectures gl ON l.Id = gl.LectureId
JOIN Groups g ON gl.GroupId = g.Id
WHERE g.Name = 'F505';

SELECT DISTINCT sub.Name 
FROM Subjects sub
JOIN Lectures l ON sub.Id = l.SubjectId
JOIN Teachers t ON l.TeacherId = t.Id
JOIN GroupsLectures gl ON l.Id = gl.LectureId
JOIN Groups g ON gl.GroupId = g.Id
WHERE t.Name = 'Alex' AND t.Surname = 'Carmack' AND g.Year = 5;

SELECT Surname FROM Teachers
WHERE Id NOT IN (
    SELECT l.TeacherId FROM Lectures l
    JOIN Schedules s ON l.Id = s.LectureId
    WHERE s.DayOfWeek = 1
);

SELECT Name, Building FROM LectureRooms
WHERE Id NOT IN (
    SELECT LectureRoomId FROM Schedules 
    WHERE DayOfWeek = 3 AND Week = 2 AND Class = 3
);

SELECT DISTINCT t.Name + ' ' + t.Surname AS FullName
FROM Teachers t
JOIN Deans d ON t.Id = d.TeacherId
JOIN Faculties f ON f.DeanId = d.Id
WHERE f.Name = 'Computer Science'
AND t.Id NOT IN (
    SELECT c.TeacherId FROM Curators c
    JOIN GroupsCurators gc ON c.Id = gc.CuratorId
    JOIN Groups g ON gc.GroupId = g.Id
    JOIN Departments dep ON g.DepartmentId = dep.Id
    WHERE dep.Name = 'Software Development'
);


SELECT Building FROM Faculties
UNION
SELECT Building FROM Departments
UNION
SELECT Building FROM LectureRooms;

SELECT t.Name + ' ' + t.Surname AS FullName
FROM Teachers t
LEFT JOIN Deans d ON t.Id = d.TeacherId
LEFT JOIN Heads h ON t.Id = h.TeacherId
LEFT JOIN Curators c ON t.Id = c.TeacherId
LEFT JOIN Assistants a ON t.Id = a.TeacherId
GROUP BY t.Name, t.Surname, d.Id, h.Id, c.Id, a.Id
ORDER BY 
    CASE 
        WHEN d.Id IS NOT NULL THEN 1
        WHEN h.Id IS NOT NULL THEN 2
        WHEN c.Id IS NOT NULL THEN 4
        WHEN a.Id IS NOT NULL THEN 5
        ELSE 3
    END;

SELECT DISTINCT DayOfWeek 
FROM Schedules s
JOIN LectureRooms lr ON s.LectureRoomId = lr.Id
WHERE lr.Building = 6 AND lr.Name IN ('A311', 'A104');