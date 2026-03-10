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

SELECT T.Name, T.Surname, G.Name AS GroupName
FROM Teachers AS T, Groups AS G;

SELECT DISTINCT F.Name
FROM Faculties AS F
JOIN Departments AS D ON F.Id = D.FacultyId
WHERE D.Financing > F.Financing;

SELECT C.Surname, G.Name AS GroupName
FROM Curators AS C
JOIN GroupsCurators AS GC ON C.Id = GC.CuratorId
JOIN Groups AS G ON GC.GroupId = G.Id;

SELECT DISTINCT T.Surname
FROM Teachers AS T
JOIN Lectures AS L ON T.Id = L.TeacherId
JOIN GroupsLectures AS GL ON L.Id = GL.LectureId
JOIN Groups AS G ON GL.GroupId = G.Id
WHERE G.Name = 'P107';

SELECT DISTINCT T.Surname, F.Name AS FacultyName
FROM Teachers AS T
JOIN Lectures AS L ON T.Id = L.TeacherId
JOIN GroupsLectures AS GL ON L.Id = GL.LectureId
JOIN Groups AS G ON GL.GroupId = G.Id
JOIN Departments AS D ON G.DepartmentId = D.Id
JOIN Faculties AS F ON D.FacultyId = F.Id;

SELECT D.Name AS DepartmentName, G.Name AS GroupName
FROM Departments AS D
JOIN Groups AS G ON D.Id = G.DepartmentId;

SELECT S.Name AS SubjectName
FROM Subjects AS S
JOIN Lectures AS L ON S.Id = L.SubjectId
JOIN Teachers AS T ON L.TeacherId = T.Id
WHERE T.Name = 'Samantha' AND T.Surname = 'Adams';

SELECT DISTINCT D.Name AS DepartmentName
FROM Departments AS D
JOIN Groups AS G ON D.Id = G.DepartmentId
JOIN GroupsLectures AS GL ON G.Id = GL.GroupId
JOIN Lectures AS L ON GL.LectureId = L.Id
JOIN Subjects AS S ON L.SubjectId = S.Id
WHERE S.Name = N'Теорія баз даних';

SELECT G.Name AS GroupName
FROM Groups AS G
JOIN Departments AS D ON G.DepartmentId = D.Id
JOIN Faculties AS F ON D.FacultyId = F.Id
WHERE F.Name = N'Комп''ютерні науки';

SELECT G.Name AS GroupName, F.Name AS FacultyName
FROM Groups AS G
JOIN Departments AS D ON G.DepartmentId = D.Id
JOIN Faculties AS F ON D.FacultyId = F.Id
WHERE G.Year = 5;

SELECT T.Surname, S.Name AS SubjectName, G.Name AS GroupName
FROM Teachers AS T
JOIN Lectures AS L ON T.Id = L.TeacherId
JOIN Subjects AS S ON L.SubjectId = S.Id
JOIN GroupsLectures AS GL ON L.Id = GL.LectureId
JOIN Groups AS G ON GL.GroupId = G.Id
WHERE L.LectureRoom = 'B103';

