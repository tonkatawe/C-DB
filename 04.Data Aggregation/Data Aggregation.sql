--1--
SELECT COUNT(*) AS [Count]
FROM WizzardDeposits
--2--
SELECT MAX(MagicWandSize) 
AS LongestMagicWand
FROM WizzardDeposits
--3--
SELECT DepositGroup, MAX(MagicWandSize) AS LongestMagicWand
FROM WizzardDeposits
GROUP BY DepositGroup
--4--
SELECT TOP (2) DepositGroup
FROM WizzardDeposits
GROUP BY DepositGroup
ORDER BY AVG(MagicWandSize)
--5--
SELECT DepositGroup, SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
GROUP BY DepositGroup
--6--
SELECT * FROM WizzardDeposits
SELECT DepositGroup, SUM(DepositAmount) AS TotalSum 
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup
--7--
SELECT DepositGroup, SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
HAVING MagicWandCreator = 'Ollivander family' AND SUM(DepositAmount) < 150000
ORDER BY TotalSum DESC
--8--
SELECT DepositGroup, MagicWandCreator, MIN(DepositCharge) AS MinDepositCharge
FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
ORDER BY MagicWandCreator,DepositGroup ASC
--9--
SELECT e.AgeGroup, COUNT(e.AgeGroup) AS WizardCount FROM (
SELECT CASE
	WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
	WHEN Age BETWEEN 11 AND 20 THEN '[11-20]'
	WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
	WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
	WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
	WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
	WHEN Age >=61 THEN '[61+]'
END AS AgeGroup
FROM WizzardDeposits
) AS e
GROUP BY e.AgeGroup
--10--
SELECT DISTINCT LEFT(FirstName,1) AS FirstLetter
FROM WizzardDeposits
WHERE DepositGroup = 'Troll Chest'
GROUP BY FirstName
--11--
SELECT DepositGroup, IsDepositExpired, AVG(DepositInterest) AS AverageInterest
FROM WizzardDeposits
WHERE DepositStartDate > '01/01/1985'
GROUP BY DepositGroup, IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired ASC
--12--
SELECT SUM(e.Diff) AS [SumDifference]
FROM(
SELECT DepositAmount - LEAD(DepositAmount) OVER(ORDER BY Id) AS Diff
FROM WizzardDeposits)
AS e
--13--
USE Softuni
SELECT DepartmentID, SUM(Salary) AS TotalSalary
FROM Employees
GROUP BY DepartmentID
ORDER BY DepartmentID
--14--
SELECT DepartmentID, MIN(Salary) AS MinimumSalary
FROM Employees
WHERE HireDate > 01/01/2000 AND DepartmentID IN (2,5,7)
GROUP BY DepartmentID
HAVING DepartmentID IN (2,5,7)
--15--
SELECT *
INTO MyTable 
FROM Employees
WHERE Salary >30000
DELETE FROM MyTable
WHERE ManagerID = 42
UPDATE MyTable
SET Salary = Salary+5000
WHERE DepartmentID=1
SELECT DepartmentID, AVG(Salary) AS AverageSalary
FROM MyTable
GROUP BY DepartmentID
--16--
SELECT DepartmentID, MAX(Salary) As MaxSalary
FROM Employees
GROUP BY DepartmentID
HAVING MAX(Salary)<30000 OR Max(Salary)> 70000
--17--
SELECT Count(Salary) AS [Count]
FROM Employees
GROUP BY ManagerID
HAVING ManagerID IS NULL
--18--
SELECT DISTINCT DepartmentID, Salary FROM(
SELECT DepartmentId, Salary,
DENSE_RANK() OVER(PARTITION BY DepartmentID ORDER BY Salary DESC) AS Ranked
FROM Employees) 
AS e
WHERE e.Ranked =3
--19--
SELECT TOP(10) FirstName, LastName, DepartmentID
FROM Employees AS e
WHERE Salary > (SELECT AVG(Salary) FROM Employees WHERE DepartmentID = e.DepartmentID)
ORDER BY DepartmentID