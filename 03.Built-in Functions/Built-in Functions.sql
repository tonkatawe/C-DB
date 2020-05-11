USE SoftUni
--1--
SELECT FirstName, LastName
FROM Employees
WHERE FirstName LIKE 'SA%'
--2--
SELECT FirstName, LastName
FROM Employees
WHERE LastName LIKE '%ei%'
--3--
SELECT FirstName
FROM Employees
WHERE DepartmentID IN (3,10) AND DATEPART(YEAR, HireDate) BETWEEN 1995 AND 2005
--4--
SELECT FirstName, LastName
FROM Employees
WHERE JobTitle NOT LIKE '%engineer%'
--5--
SELECT [Name]
FROM Towns
WHERE LEN([NAME]) IN (5,6)
ORDER BY [NAME] ASC
--6--
SELECT TownID, [Name]
FROM Towns
WHERE [Name] LIKE '[mkbe]%'
ORDER BY [Name] ASC
--7--
SELECT TownID, [Name]
FROM Towns
WHERE [NAME] NOT LIKE '[rbd]%'
ORDER BY [Name] ASC
--8--
CREATE VIEW V_EmployeesHiredAfter2000 AS
SELECT FirstName, LastName
FROM Employees
WHERE DATEPART(YEAR, HireDate)>2000
--9--
SELECT FirstName, LastName
FROM Employees
WHERE LEN(LastName)=5
--10--
SELECT EmployeeID, FirstName, LastName, Salary,
DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS [Rank]
FROM Employees
WHERE Salary BETWEEN 10000 AND 50000
ORDER BY Salary DESC
--11--
SELECT* FROM(SELECT EmployeeID, FirstName, LastName, Salary,
DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS [Rank]
FROM Employees
WHERE Salary BETWEEN 10000 AND 50000
)
AS MyTable
WHERE MyTable.Rank=2
ORDER BY MyTable.Salary DESC
--12--
USE Geography
SELECT CountryName, IsoCode
FROM Countries
WHERE CountryName LIKE '%a%a%a%'
ORDER BY IsoCode ASC
--13--
SELECT PeakName,RiverName, LOWER(PeakName + SUBSTRING(RiverName,2,LEN(RiverName))) AS Mix
FROM Peaks, Rivers
WHERE RIGHT(PeakName,1) = LEFT(RiverName,1)
ORDER BY Mix
--14--
USE Diablo

SELECT TOP (50) [Name], FORMAT([Start],'yyyy-MM-dd') AS [Start]
FROM Games
WHERE DATEPART(YEAR,[Start]) IN (2011,2012)
ORDER BY [Start], [Name]
--15--
SELECT Username, SUBSTRING(Email,CHARINDEX('@',Email,1) +1, LEN(Email)) AS [Email Provider]
FROM Users
ORDER BY [Email Provider], Username
--16--
SELECT Username, IpAddress
FROM Users
WHERE IpAddress LIKE '___.1_%._%.___'
ORDER BY Username
--17--
SELECT [Name],
CASE
WHEN DATEPART(HOUR,Start)>=0 AND DATEPART(HOUR,Start)<12 THEN 'Morning'
WHEN DATEPART(HOUR,Start)>=12 AND DATEPART(HOUR,Start)<18 THEN 'Afternoon'
WHEN DATEPART(HOUR,Start)>=18 AND DATEPART(HOUR,Start)<24 THEN 'Evening'
END AS [Part of the Day],
CASE 
WHEN Duration<=3 THEN 'Extra Short'
WHEN Duration BETWEEN 4 AND 6 THEN 'Short'
WHEN Duration >6 THEN 'Long'
WHEN Duration IS NULL THEN 'Extra Long'
END AS Duration
FROM Games
ORDER BY [Name],[Duration],[Part of the Day]
--18--
