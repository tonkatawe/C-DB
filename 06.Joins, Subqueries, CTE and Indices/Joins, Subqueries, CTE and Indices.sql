--1--
USE SoftUni

SELECT TOP 5 
	EmployeeID, JobTitle, a.AddressID, AddressText
FROM 
	Employees AS e
	JOIN Addresses AS a
ON
	e.AddressID = a.AddressID
ORDER BY e.AddressID ASC
--2--
SELECT TOP 50 FirstName, LastName, [Name] AS Town, AddressText
FROM Employees AS e
		JOIN Addresses AS a
ON		e.AddressID = a.AddressID
		JOIN Towns AS t
ON		 a.TownID = t.TownID
ORDER BY e.FirstName ASC, e.LastName ASC
--3--
SELECT EmployeeID, FirstName, LastName, d.[Name] AS DepartmentName
FROM	Employees AS e
		JOIN Departments AS d
ON		e.DepartmentID = d.DepartmentID
WHERE d.[Name] = 'Sales'
		ORDER BY e.EmployeeID ASC
--4--
SELECT TOP 5
		EmployeeID, FirstName, Salary, d.[Name] AS DepartmentName
FROM	Employees AS e
		JOIN Departments AS d
ON		e.DepartmentID = d.DepartmentID
WHERE	e.Salary > 15000
ORDER BY d.DepartmentID ASC
--5--
SELECT 
TOP			3
			e.EmployeeID, FirstName
FROM		Employees AS e
			LEFT JOIN EmployeesProjects AS ep
ON			e.EmployeeID = ep.EmployeeID
WHERE		ep.EmployeeID IS NULL
ORDER BY	e.EmployeeID
--6--
SELECT FirstName, LastName, HireDate, d.[Name] AS DeptName
FROM	Employees AS e
		JOIN Departments AS d
		ON e.DepartmentID = d.DepartmentID
		WHERE d.[Name] IN('Sales', 'Finance') AND e.HireDate > '01-01-1999'
		ORDER BY e.HireDate
--7--
SELECT TOP 5 e.EmployeeID, FirstName, p.[Name] AS ProjectName 
FROM Employees AS e
	JOIN EmployeesProjects AS ep
	ON e.EmployeeID = ep.EmployeeID
	JOIN Projects AS p
	ON ep.ProjectID = p.ProjectID
	WHERE p.StartDate > '08-13-2002' AND p.EndDate IS NULL
	ORDER BY e.EmployeeID
--8--
SELECT	 e.EmployeeID, e.FirstName,
CASE
WHEN	 p.StartDate >= '01-01-2005' THEN NULL
ELSE	 p.[Name]
END AS   ProjectName
FROM     Employees AS e
		 JOIN EmployeesProjects AS ep
ON	     e.EmployeeID = ep.EmployeeID
		 JOIN Projects AS p
ON		 ep.ProjectID = p.ProjectID
WHERE	 e.EmployeeID = 24
--9--
SELECT	 e.EmployeeID, e.FirstName, e.ManagerID, m.[FirstName] AS ManagerName
FROM	 Employees AS e
		 JOIN Employees AS m
ON		 m.EmployeeID = e.ManagerID
WHERE    e.ManagerID IN (3,7)
ORDER BY e.EmployeeID ASC
--10--
SELECT TOP  50
			e.EmployeeID, 
			CONCAT(e.FirstName, + ' ' + e.LastName) AS EmployeeName, 
			CONCAT(m.FirstName, + ' '+ m.LastName) AS ManagerName,
			d.[Name] AS DepartmentName
FROM	    Employees AS e
		    JOIN Employees AS m
ON			m.EmployeeID = e.ManagerID
			JOIN Departments AS d
ON			d.DepartmentID= e.DepartmentID
ORDER BY    e.EmployeeID
--11--
SELECT TOP 1	 
		   AVG(Salary) AS MinAverageSalary
FROM	   Employees 
GROUP BY   DepartmentID
ORDER BY   MinAverageSalary
--12--
USE Geography

SELECT c.CountryCode, m.MountainRange, p.PeakName, p.Elevation
FROM	  Countries AS c
		  JOIN MountainsCountries AS mc
ON		  mc.CountryCode = c.CountryCode
		  JOIN Mountains AS m
ON		  m.Id = mc.MountainId
		  JOIN Peaks AS p
ON		  mc.MountainId = p.MountainId
WHERE	  p.Elevation > 2835 AND c.CountryCode = 'BG'
ORDER BY  p.Elevation DESC
--13--
SELECT   c.CountryCode, COUNT(mc.MountainId) AS MountainRanges
FROM	 Countries AS c
		 JOIN MountainsCountries AS mc
ON		 mc.CountryCode = c.CountryCode
WHERE    c.CountryCode IN ('US','RU','BG')
GROUP BY c.CountryCode
--14--
SELECT TOP 5 
		   c.CountryName, r.RiverName
FROM       Countries AS c
		   LEFT   JOIN CountriesRivers AS cr
ON		   cr.CountryCode = c.CountryCode
		   LEFT  JOIN Rivers AS r
ON		   r.Id = cr.RiverId
WHERE	   c.ContinentCode = 'AF'
ORDER BY   c.CountryName
--15--
WITH	   CTE_CountriesInfo 
           (ContinentCode, CurrencyCode, CurrencyUsage) AS
(
SELECT	   c.ContinentCode, c.CurrencyCode, COUNT(c.CurrencyCode) AS [CurrencyUsage]
FROM	   Countries AS c
GROUP BY   c.ContinentCode, c.CurrencyCode
HAVING	   COUNT(c.CurrencyCode)>1) 

SELECT		e.ContinentCode, cci.CurrencyCode, cci.CurrencyUsage
FROM(
SELECT		ContinentCode, MAX(CurrencyUsage) AS MaxCurrency
FROM		CTE_CountriesInfo
GROUP BY    ContinentCode) AS e
			JOIN CTE_CountriesInfo AS cci
ON			cci.ContinentCode = e.ContinentCode AND cci.CurrencyUsage = e.MaxCurrency
--16--
SELECT   COUNT(c.CountryCode) AS [Count]
FROM     Countries AS c
		 LEFT JOIN MountainsCountries AS mc
ON		 mc.CountryCode = c.CountryCode
WHERE	 mc.MountainId IS NULL
--17--
SELECT TOP 5 c.CountryName, MAX(p.Elevation) AS HighestPeakElevation, MAX(r.Length) AS LongestRiverLength
FROM	Countries AS c
		JOIN CountriesRivers AS cr
ON		cr.CountryCode = c.CountryCode
		JOIN Rivers AS r
ON		r.Id = cr.RiverId
		JOIN MountainsCountries AS mc
ON		mc.CountryCode = c.CountryCode
		JOIN Mountains AS m
ON		m.Id = mc.MountainId
		JOIN Peaks AS p
ON		p.MountainId = m.Id
GROUP BY c.CountryName
ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC
--18--
SELECT TOP(5) c.CountryName, ISNULL(p.PeakName,'(no highest peak)') AS [Highest Peak Name], 
ISNULL(MAX(p.Elevation),0) AS [Highest Peak Elevation], ISNULL(m.MountainRange,'(no mountain)')
FROM	Countries AS c
		LEFT JOIN MountainsCountries AS mc
ON		 mc.CountryCode = c.CountryCode
		LEFT JOIN Mountains AS m
ON		m.Id = mc.MountainId
		LEFT JOIN Peaks AS p
ON		p.MountainId = m.Id
GROUP BY c.CountryName,p.PeakName,m.MountainRange
ORDER BY c.CountryName, [Highest Peak Elevation] DESC,p.PeakName