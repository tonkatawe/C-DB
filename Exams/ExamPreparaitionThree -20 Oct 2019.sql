CREATE DATABASE [Service]
USE Service

CREATE TABLE Users(
Id INT PRIMARY KEY IDENTITY,
Username NVARCHAR(30) UNIQUE NOT NULL,
[Password] NVARCHAR(50) NOT NULL,
[Name] NVARCHAR(50), 
Birthdate DATETIME,
Age INT CHECK ( Age >=14 AND Age <=110),
Email NVARCHAR(50) NOT NULL
)
CREATE TABLE Departments(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) NOT NULL,
)

CREATE TABLE Employees(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(25),
LastName NVARCHAR(25),
Birthdate DATETIME,
Age INT CHECK ( Age >=18 AND Age <=110),
DepartmentId INT FOREIGN KEY REFERENCES Departments(Id)
)

CREATE TABLE Categories(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) NOT NULL,
DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL
)

CREATE TABLE [Status](
Id INT PRIMARY KEY IDENTITY,
[Label] NVARCHAR(30) NOT NULL
)

CREATE TABLE Reports(
Id INT PRIMARY KEY IDENTITY,
CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
StatusId INT FOREIGN KEY REFERENCES [Status](Id) NOT NULL,
OpenDate DATETIME NOT NULL,
CloseDate DATETIME,
[Description] NVARCHAR(200) NOT NULL,
UserId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
)
use Service
--2-- INSERT
INSERT INTO Employees (FirstName, LastName,Birthdate, DepartmentId)
VALUES 
('Marlo','O''Malley','1958-9-21',1),
('Niki','Stanaghan','1969-11-26',4),
('Ayrton','Senna','1960-03-21',9),
('Ronnie','Peterson','1944-02-14',9),
('Giovanna','Amati','1959-07-20',5)

INSERT INTO Reports (CategoryId, StatusId,OpenDate, CloseDate, [Description],UserId, EmployeeId)
VALUES
(1,1,'2017-04-13',NULL,'Stuck Road on Str.133',6,2),
(6,3,'2015-09-05','2015-12-06','Charity trail running',3,5),
(14,2,'2015-09-07',NULL,'Falling bricks on Str.58',5,2),
(4,3,'2017-07-03','2017-07-06','Cut off streetlight on Str.11',1,1)
--3--
UPDATE Reports
SET CloseDate = GETDATE()
WHERE CloseDate IS NULL;
--4--
--niki kostov--
delete from Reports
where statusId = 4
-----------------------
DELETE FROM Reports
WHERE StatusId IN (SELECT Id FROM Reports WHERE Id = 4)
DELETE FROM [Status]
WHERE Id = 4
--5--
SELECT [Description],FORMAT([OpenDate],'dd-MM-yyyy') AS OpenDate  FROM Reports
WHERE EmployeeId IS NULL
ORDER BY Reports.OpenDate ASC, [Description] ASC
--6--
SELECT [Description], c.[Name] AS CategoryName 
FROM Reports AS R
JOIN Categories AS c
ON  c.Id=r.CategoryId
ORDER BY [Description], c.[Name]
--7--

-- VARIANT 1
SELECT TOP(5) c.Name, COUNT(*) As ReportsNumber
FROM Reports AS r
JOIN Categories AS c ON c.Id = r.CategoryId
GROUP BY CategoryId, c.Name
ORDER BY ReportsNumber DESC, Name ASC
-- VARIANT 2 
SELECT TOP(5) Name,
	(SELECT COUNT(*) FROM Reports WHERE CategoryId = c.Id) AS ReportsNumber
FROM Categories AS c
ORDER BY ReportsNumber DESC, Name ASC

--8--
SELECT Username, c.Name As CategoryName FROM Reports AS r
JOIN Users AS u
ON u.Id = r.UserId
JOIN Categories AS c
ON c.Id = r.CategoryId
WHERE  DATEPART(month,r.OpenDate) = DATEPART(month,u.Birthdate)
AND DATEPART(day, r.OpenDate) = DATEPART(day, u.Birthdate)
ORDER By Username ASC, c.Name

--9--
-- variant 1
SELECT FirstName + ' ' + LastName As FullName,
(SELECT COUNT(DISTINCT UserId) FROM Reports Where EmployeeId = e.Id) AS UserCount
FROM Employees as e
ORDER BY UserCount DESC, FullName ASC

--variant 2
SELECT CONCAT(e.FirstName, + ' ', e.LastName) AS FullName, COUNT(u.Id) AS UsersCount
FROM Users AS u
LEFT JOIN Reports As r
ON r.UserId = u.Id
JOIN Employees AS e
ON e.Id = r.EmployeeId
GROUP BY e.Id, CONCAT(e.FirstName, + ' ', e.LastName)
ORDER BY COUNT(u.id) DESC, FullName ASC

--10--
SELECT ISNULL(e.FirstName +' '+ e.LastName, 'None') AS Employy, 
	   ISNULL(d.[Name],'None') AS Department, 
	   ISNULL(c.[Name], 'None') AS Category, 
	   r.[Description],
       FORMAT(r.OpenDate, 'dd.MM.yyyy') AS OpenDate, 
	   s.[Label] AS [Status],
	   ISNULL(u.[Name], 'None') AS [User]
FROM Reports AS r
LEFT JOIN Employees AS e ON e.Id = r.EmployeeId
LEFT JOIN Categories AS c ON c.Id = r.CategoryId
LEFT JOIN Departments AS d ON d.Id = e.DepartmentId
LEFT JOIN [Status] AS s ON s.Id = r.StatusId
LEFT JOIN Users AS u ON u.Id = r.UserId
ORDER BY e.FirstName DESC, e.LastName DESC, Department ASC, Category ASC, [Description] ASC, OpenDate ASC, [Status] ASC, [User] ASC
--11--
GO
CREATE FUNCTION udf_HoursToComplete(@StartDate DATETIME, @EndDate DATETIME) 
RETURNS INT AS 
 BEGIN
     IF(@StartDate IS NULL) RETURN 0;
	 IF(@EndDate IS NULL) RETURN 0
	 RETURN DATEDIFF(hour, @StartDate, @EndDate )
    END
--12--
go
CREATE PROC usp_AssignEmployeeToReport(@EmployeeId INT, @ReportId INT)
AS BEGIN
DECLARE @EmployyDepartmentId INT =
(SELECT DepartmentId FROM Employees WHERE Id = @EmployeeId);
DECLARE @ReportDepartmentId INT =
(SELECT c.DepartmentId FROM Reports AS r
JOIN Categories AS c ON c.Id = r.CategoryId WHERE r.Id = @ReportId)

IF (@EmployyDepartmentId != @ReportDepartmentId)
THROW 50000, 'Employee doesn''t belong to the appropriate department!',1
UPDATE Reports
SET EmployeeId = @EmployeeId
WHERE Id = @ReportId
END