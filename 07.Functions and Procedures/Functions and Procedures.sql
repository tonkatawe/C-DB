USE SoftUni
--1--
CREATE OR ALTER PROCEDURE usp_GetEmployeesSalaryAbove35000 AS
SELECT FirstName, LastName
FROM Employees AS e
WHERE e.Salary >35000

EXEC usp_GetEmployeesSalaryAbove35000
--2--
CREATE OR ALTER PROC usp_GetEmployeesSalaryAboveNumber @Salaries DECIMAL(18,4)
AS
SELECT FirstName, LastName
FROM Employees AS e
WHERE e.Salary >= @Salaries

EXEC usp_GetEmployeesSalaryAboveNumber 48100
--3--
CREATE PROC usp_GetTownsStartingWith (@input VARCHAR(50)) AS
BEGIN
SELECT [Name]
FROM Towns
WHERE [Name] LIKE @input + '%'
END
--4--
CREATE PROC usp_GetEmployeesFromTown (@TownAsInput NVARCHAR(50)) AS
SELECT FirstName, LastName
FROM Employees AS e
JOIN Addresses AS a
ON e.AddressID = a.AddressID
JOIN Towns AS t
ON a.TownID = t.TownID
WHERE t.[Name] = @TownAsInput

EXEC usp_GetEmployeesFromTown Sofia
--5--
CREATE FUNCTION ufn_GetSalaryLevel(@salary INT(18,4))  
RETURNS NVARCHAR(50)   
AS   
 BEGIN  
    DECLARE @result NVARCHAR(50);  
     IF (@salary < 30000)   
        SET @result = 'Low'
	ELSE IF (@salary >=30000 AND @salary<=50000)
		SET @result = 'Average'
	ELSE
		SET @result = 'High'
    RETURN @result   
END; 
--6--
CREATE PROC usp_EmployeesBySalaryLevel (@salaryLevel NVARCHAR(50)) AS
SELECT FirstName, LastName 
FROM Employees 
WHERE  dbo.ufn_GetSalaryLevel(Salary) = @salaryLevel
EXEC usp_EmployeesBySalaryLevel 'Low'
--7--
CREATE FUNCTION ufn_IsWordComprised(@setOfLetters VARCHAR(MAX), @word VARCHAR(MAX))
RETURNS BIT AS
BEGIN
	DECLARE @WordLength INT = LEN(@word)
	DECLARE @Index INT = 1

	WHILE (@Index <= @WordLength)
	BEGIN
		IF (CHARINDEX(SUBSTRING(@word, @Index, 1), @setOfLetters) = 0)
		BEGIN
			RETURN 0
		END

		SET @Index += 1
	END

	RETURN 1
END
--8--
CREATE PROCEDURE usp_DeleteEmployeesFromDepartment (@departmentId INT) AS
BEGIN

DELETE FROM EmployeesProjects
WHERE EmployeeID IN(SELECT EmployeeID FROM Employees WHERE DepartmentID = @departmentId)

ALTER TABLE Departments
ALTER COLUMN ManagerID INT

UPDATE Employees
SET ManagerID = NULL
WHERE ManagerID IN(SELECT EmployeeID FROM Employees WHERE DepartmentID = @departmentId)

UPDATE Departments
SET ManagerID = NULL
WHERE ManagerID IN (SELECT EmployeeID FROM Employees WHERE DepartmentID = @departmentId)

DELETE FROM Employees
WHERE DepartmentID = @departmentId

DELETE FROM Departments
WHERE DepartmentID = @departmentId

SELECT COUNT(*)
FROM Employees
WHERE DepartmentID = @departmentId
END
--9--
USE Bank

CREATE PROC usp_GetHoldersFullName
AS
SELECT CONCAT(ah.FirstName,+' ',+ah.LastName) AS [Full Name]
FROM AccountHolders AS ah

EXEC usp_GetHoldersFullName
--10--
SELECT * FROM Accounts

CREATE PROC usp_GetHoldersWithBalanceHigherThan (@input DECIMAL(18,4)) AS
SELECT FirstName AS [First Name], LastName AS [Last Name]
FROM AccountHolders AS ah
JOIN Accounts AS a
ON ah.Id = a.AccountHolderId
GROUP BY ah.FirstName, ah.LastName
HAVING SUM(a.Balance) >  @input
ORDER BY ah.FirstName ASC

--11--
CREATE FUNCTION ufn_CalculateFutureValue (@sum DECIMAL(18,4), @interest FLOAT, @years INT)
RETURNS DECIMAL(18,4)
BEGIN
RETURN @sum*POWER((1+@interest),@years)
END
SELECT dbo.ufn_CalculateFutureValue(1000, 0.10, 5)
--12--
CREATE PROC usp_CalculateFutureValueForAccount (@accountId INT, @interest FLOAT) AS
SELECT TOP (1)
				ah.Id AS [Account Id], 
				ah.FirstName AS [First Name], 
				ah.LastName AS [Last Name], 
				a.Balance AS [Current Balance],
				dbo.ufn_CalculateFutureValue(a.Balance, @interest, 5) AS [Balance in 5 years]
FROM			AccountHolders AS ah
				JOIN Accounts AS a
ON				ah.Id = a.AccountHolderId

EXEC usp_CalculateFutureValueForAccount 1, 0.1
--13--
CREATE FUNCTION ufn_CashInUsersGames (@gameName VARCHAR(50)) 
RETURNS TABLE
AS
RETURN(SELECT SUM(e.Cash) AS [SumCash] 
FROM(
SELECT g.Id,ug.Cash, ROW_NUMBER() OVER(ORDER BY ug.Cash DESC) AS [RowNumber]
FROM UsersGames AS ug
JOIN Games AS g
ON g.Id = ug.GameId
WHERE g.Name = @gameName
) AS e
WHERE e.RowNumber %2=1
)