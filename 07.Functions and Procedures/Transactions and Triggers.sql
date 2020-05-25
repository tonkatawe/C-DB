USE Bank
--14--
CREATE TABLE Logs (
LogId INT PRIMARY KEY IDENTITY,
AccountId INT FOREIGN KEY REFERENCES Accounts(Id),
OldSum DECIMAL(15,2),
NewSum DECIMAL(15,2)
)

CREATE TRIGGER tr_SumChange
ON Accounts
FOR UPDATE
AS
DECLARE @newSum DECIMAL(15,2) = (SELECT Balance FROM inserted)
DECLARE @oldSum DECIMAL(15,2) = (SELECT Balance FROM deleted)
DECLARE @account INT = (SELECT Id FROM inserted)

INSERT INTO Logs (AccountId, OldSum, NewSum) VALUES
(@account, @oldSum, @newSum)
--15--
CREATE TABLE NotificationEmails (
Id INT PRIMARY KEY IDENTITY,
Recipient  INT FOREIGN KEY REFERENCES Accounts(Id),
[Subject]  NVARCHAR(180),
Body NVARCHAR(MAX)
)

CREATE TRIGGER tr_CreateNewMail
ON Logs
FOR INSERT
AS
DECLARE @accountId INT = (SELECT TOP(1) AccountId FROM inserted)
DECLARE @oldSum DECIMAL(15,2) = (SELECT OldSum FROM inserted)
DECLARE @newSum DECIMAL(15,2) = (SELECT NewSum FROM inserted)

INSERT INTO NotificationEmails (Recipient, [Subject], Body) VALUES
(
@accountId,
'Balance change for account: ' + CAST(@accountId AS VARCHAR(50)),
'On' + CONVERT(VARCHAR(50),GETDATE(),103) + 'your balance was changed from' + CAST(@oldSum AS VARCHAR(50))+ 'to' + CAST(@newSum AS VARCHAR(50))
)
--16--
CREATE PROC usp_DepositMoney (@accountId INT, @moneyAmount DECIMAL(15,4))
AS
BEGIN
DECLARE @account INT = (SELECT Id FROM Accounts WHERE Id=@accountId)
IF(@account IS NOT NULL AND @moneyAmount>0)
BEGIN
UPDATE Accounts
SET Balance += @moneyAmount
WHERE Id = @accountId
END
END

EXEC usp_DepositMoney 1, 10
--17--
USE Bank

CREATE PROC usp_WithdrawMoney (@AccountId INT, @MoneyAmount DECIMAL (18,4))
AS
BEGIN TRANSACTION
DECLARE @Account INT = (SELECT Id FROM Accounts WHERE Id = @AccountId)
IF (@Account IS NULL OR @MoneyAmount <0)
BEGIN
ROLLBACK
RAISERROR ('Not proper Account Id or Sum',16,1)
RETURN
END
DECLARE @CurrSum DECIMAL(18,4) = (SELECT Balance FROM Accounts WHERE Id = @AccountId)
IF (@CurrSum - @MoneyAmount <0)
BEGIN
ROLLBACK
RAISERROR('Insufficients funds',16,2)
RETURN
END
UPDATE Accounts
SET Balance -=@MoneyAmount
WHERE Id = @AccountId
COMMIT

EXEC usp_WithdrawMoney 5, 25
--18-- 
CREATE PROC usp_TransferMoney(@senderId INT, @receiverId INT, @amount DECIMAL(15,4)) AS
BEGIN
EXEC usp_WithdrawMoney @senderId,@amount
EXEC usp_DepositMoney @receiverId,@amount
END
--20--
USE Diablo

DECLARE @User VARCHAR(MAX) = 'Stamat'
DECLARE @GameName VARCHAR(MAX) = 'Safflower'
DECLARE @UserId INT = (SELECT Id FROM Users WHERE Username = @User)
DECLARE @GameId INT = (SELECT Id FROM Games WHERE Name = @GameName)
DECLARE @UserMoney DECIMAL = (SELECT Cash FROM UsersGames WHERE UserId = @UserId AND GameId = @GameId)
DECLARE @ItemsBulkPrice DECIMAL
DECLARE @UserGameId INT = (SELECT Id FROM UsersGames WHERE UserId = @UserId AND GameId = @GameId)

BEGIN TRAN--11 to 12
		SET @ItemsBulkPrice = (SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 11 AND 12)
		IF (@UserMoney - @ItemsBulkPrice >= 0)
		BEGIN
			INSERT UserGameItems
			SELECT i.Id, @UserGameId FROM Items AS i
			WHERE i.id IN (Select Id FROM Items WHERE MinLevel BETWEEN 11 AND 12)
			UPDATE UsersGames
			SET Cash = Cash - @ItemsBulkPrice
			WHERE GameId = @GameId AND UserId = @UserId
			COMMIT
		END
		ELSE
		BEGIN
			ROLLBACK
		END
			

SET @UserMoney = (SELECT Cash FROM UsersGames WHERE UserId = @UserId AND GameId = @GameId)
BEGIN TRAN--19 to 21
		SET @ItemsBulkPrice = (SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 19 AND 21)
		IF (@UserMoney - @ItemsBulkPrice >= 0)
		BEGIN
			INSERT UserGameItems
			SELECT i.Id, @UserGameId FROM Items AS i
			WHERE i.id IN (Select Id FROM Items WHERE MinLevel BETWEEN 19 AND 21)
			UPDATE UsersGames
			SET Cash = Cash - @ItemsBulkPrice
			WHERE GameId = @GameId AND UserId = @UserId
			COMMIT
		END
		ELSE
		BEGIN
			ROLLBACK
		END

 SELECT Name AS 'Item Name' FROM Items
 WHERE Id IN (SELECT ItemId FROM UserGameItems WHERE UserGameId = @UserGameId)
ORDER BY [Item Name]
--21--
USE SoftUni

CREATE PROC usp_AssignProject (@emloyeeId INT, @projectID INT) AS
BEGIN TRANSACTION
DECLARE @employee INT= (SELECT EmployeeID FROM Employees WHERE EmployeeID = @emloyeeId)
DECLARE @project INT =(SELECT ProjectID FROM Projects WHERE ProjectID = @projectID)
IF (@emloyeeId IS NULL OR @projectID IS NULL)
BEGIN
ROLLBACK
RAISERROR ('Not existing employee or project', 16,1)
RETURN
END
DECLARE @projectCount INT= (SELECT COUNT(ProjectID) FROM EmployeesProjects WHERE EmployeeID = @emloyeeId)
IF (@projectCount>3)
BEGIN
ROLLBACK
RAISERROR ('The employee has too many projects!',16,2)
RETURN
END
INSERT INTO EmployeesProjects (EmployeeID, ProjectID) VALUES
(@emloyeeId, @projectID)
COMMIT
--22--
CREATE TABLE Deleted_Employees (
EmployeeId INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(50),
LastName VARCHAR(50),
MiddleName VARCHAR(50),
JobTitle VARCHAR(50),
DepartmentId INT,
Salary DECIMAL(15,2)
)


CREATE TRIGGER tr_DeletedEmployees
ON Employees
FOR DELETE
AS
INSERT INTO Deleted_Employees (FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary) 
SELECT FirstName, LastName, MiddleName, JobTitle, DepartmentID, Salary FROM deleted
