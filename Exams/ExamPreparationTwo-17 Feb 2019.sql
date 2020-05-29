CREATE DATABASE School
USE School

USE Master
DROP DATABASE School
--1--
CREATE TABLE Students(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(30) NOT NULL,
MiddleName NVARCHAR(25),
Lastname NVARCHAR(30) NOT NULL,
Age INT NOT NULL CHECK (Age >0),
[Address] NVARCHAR(50),
Phone CHAR(10),

)

CREATE TABLE Subjects (
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(20) NOT NULL,
Lessons INT NOT NULL CHECK (Lessons>0),

)

CREATE TABLE StudentsSubjects (
Id INT PRIMARY KEY IDENTITY,
StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL,
Grade DECIMAL(15,2) NOT NULL CHECK (Grade >= 2 AND Grade <= 6),
)

CREATE TABLE Exams(
Id INT PRIMARY KEY IDENTITY,
[Date] DATETIME,
SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL
)

CREATE TABLE StudentsExams(
StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
ExamId INT FOREIGN KEY REFERENCES Exams(Id) NOT NULL,
Grade DECIMAL(15,2) NOT NULL CHECK (Grade >= 2 AND Grade <= 6),
PRIMARY KEY (StudentId, ExamId)
)

CREATE TABLE Teachers(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(20) NOT NULL,
LastName NVARCHAR(20) NOT NULL,
[Address] NVARCHAR(20) NOT NULL,
Phone CHAR(10),
SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL
)

CREATE TABLE StudentsTeachers(
StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
TeacherId INT FOREIGN KEY REFERENCES Teachers(Id) NOT NULL
PRIMARY KEY (StudentId, TeacherId)
)
--2--
INSERT INTO Teachers VALUES
('Ruthanne','Bamb','84948 Mesta Junction', '3105500146',6),
('Gerrard','Lowin','370 Talisman Plaza', '3324874824',2),
('Merrile','Lambdin','81 Dahle Plaza', '4373065154',5),
('Bert','Ivie','2 Gateway Circle', '4409584510',4)

INSERT INTO Subjects VALUES
('Geometry',12),
('Health', 10),
('Drama', 7),
('Sports',9)
--3--
UPDATE StudentsSubjects
SET Grade = 6.00
WHERE SubjectId IN (1,2) AND Grade >=5.50
--4--
DELETE FROM StudentsTeachers
WHERE TeacherId IN (SELECT Id FROM Teachers WHERE Phone LIKE '%72%')
DELETE FROM Teachers
WHERE Phone LIKE '%72%'
--5--
SELECT FirstName, Lastname, Age
FROM Students
WHERE Age >=12
ORDER BY FirstName, Lastname
--6--
SELECT   s.FirstName, s.Lastname, COUNT(t.Id) AS TeachersCount
FROM     Students AS s
		 JOIN StudentsTeachers AS st
ON		 st.StudentId = s.Id
		 JOIN Teachers AS t
ON		 t.Id = st.TeacherId
GROUP BY s.FirstName, s.Lastname
--7--
SELECT CONCAT(s.FirstName,+ ' ',+ s.Lastname) AS [Full Name]
FROM		Students AS s
			LEFT JOIN StudentsExams AS sx
ON			sx.StudentId = s.Id
			LEFT JOIN Exams AS e
ON			e.Id = sx.ExamId
			LEFT JOIN Subjects AS sb
ON			sb.Id = e.SubjectId
WHERE		sx.Grade IS NULL
ORDER BY	[Full Name]
--8--
SELECT TOP (10) s.FirstName AS [First Name], s.Lastname AS [Last Name], FORMAT(AVG(se.Grade),'N2') AS Grade
FROM		Students AS s
			JOIN StudentsExams AS se
			ON se.StudentId = s.Id
			JOIN Exams AS e
			ON e.Id = se.ExamId
GROUP BY FirstName, Lastname
ORDER BY FORMAT(AVG(se.Grade),'N2') DESC, FirstName ASC, Lastname ASC
--9--
SELECT CONCAT(s.FirstName,+' '+ s.MiddleName,+' ', s.Lastname) AS [Full Name]
FROM		Students AS s
			LEFT JOIN StudentsSubjects AS ss
ON			ss.StudentId = s.Id
			LEFT JOIN Subjects AS sb
ON			sb.Id = ss.SubjectId
WHERE		ss.StudentId IS NULL
ORDER BY	[Full Name]
--10--
SELECT s.[Name], AVG(ss.Grade) AS AverageGrade
FROM Subjects AS s
JOIN StudentsSubjects AS ss
ON ss.SubjectId = s.Id
GROUP BY [Name], s.Id
ORDER BY s.Id 
--11--
CREATE FUNCTION udf_ExamGradesToUpdate(@studentId INT, @grade DECIMAL(15,2))
RETURNS NVARCHAR(MAX)
AS BEGIN
DECLARE @studentExist INT = (SELECT TOP(1) StudentId FROM StudentsExams WHERE StudentId = @studentId)
IF(@studentExist IS NULL)
	BEGIN
		RETURN 'The student with provided id does not exist in the school!';
	END

	DECLARE @biggestGrade DECIMAL(15,2) = @grade + 0.50;
	DECLARE @count INT = (SELECT Count(Grade) FROM StudentsExams WHERE StudentId = @studentId AND Grade >= @grade AND Grade <= @biggestGrade);
	IF(@grade > 6)
	BEGIN
		RETURN 'Grade cannot be above 6.00!';
	END
	DECLARE @firstname NVARCHAR(30) = (SELECT FirstName FROM Students WHERE Id = @studentId)
	RETURN  CONCAT('You have to update'+' ',@count, + ' ','grades for the student'+' ', @firstname);
END
--12--
CREATE PROC usp_ExcludeFromSchool (@StudentId INT)
AS BEGIN
DECLARE @currentStudent INT = (SELECT Id FROM Students WHERE Id = @StudentId)
IF @currentStudent IS NULL
BEGIN
RAISERROR('This school has no student with the provided id!', 16, 1)
RETURN 
END
DELETE FROM StudentsExams
WHERE StudentId = @currentStudent
DELETE FROM StudentsSubjects
WHERE StudentId = @currentStudent
DELETE FROM StudentsTeachers
WHERE StudentId = @currentStudent
DELETE FROM Students
WHERE Id = @currentStudent
END

EXEC usp_ExcludeFromSchool 301
EXEC usp_ExcludeFromSchool 1
SELECT COUNT(*) FROM Students
