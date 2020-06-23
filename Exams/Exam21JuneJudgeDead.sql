CREATE DATABASE TripService
USE TripService

CREATE TABLE Cities
(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(20) NOT NULL,
CountryCode NCHAR(2) NOT NULL
)

CREATE TABLE Hotels
(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(30) NOT NULL,
CityId INT NOT NULL FOREIGN KEY REFERENCES Cities(Id),
EmployeeCount INT NOT NULL,
BaseRate DECIMAL(15,2)
)

CREATE TABLE Rooms
(
Id INT PRIMARY KEY IDENTITY,
Price DECIMAL(15,2) NOT NULL,
[Type] NVARCHAR(20) NOT NULL,
Beds INT NOT NULL,
HotelId INT FOREIGN KEY REFERENCES Hotels(Id) NOT NULL
)

CREATE TABLE Trips
(
Id INT PRIMARY KEY IDENTITY,
RoomId INT FOREIGN KEY REFERENCES Rooms(Id),
BookDate DATETIME  NOT NULL,
ArrivalDate DATETIME  NOT NULL,
ReturnDate DATETIME NOT NULL,
CancelDate DATETIME,
CHECK(BookDate < ArrivalDate),
CHECK(ArrivalDate < ReturnDate)
)

CREATE TABLE Accounts
(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(50) NOT NULL,
MiddleName NVARCHAR(20),
LastName NVARCHAR(50) NOT NULL,
CityId INT NOT NULL FOREIGN KEY REFERENCES Cities(Id),
BirthDate DATETIME NOT NULL,
Email NVARCHAR(100) UNIQUE NOT NULL
)

CREATE TABLE AccountsTrips
(
AccountId INT FOREIGN KEY REFERENCES Accounts(Id) NOT NULL,
TripId INT FOREIGN KEY REFERENCES Trips(Id) NOT NULL,
Luggage INT CHECK (Luggage >=0) NOT NULL
PRIMARY KEY(AccountId, TripId)
)


--Problem 2
INSERT INTO Accounts (FirstName, MiddleName,LastName,CityId,BirthDate,	Email) VALUES
('John', 'Smith', 'Smith',34,'1975-07-21','j_smith@gmail.com'),
('Gosho',NULL, 'Petrov', 11, '1978-05-16','g_petrov@gmail.com'),
('Ivan', 'Petrovich', 'Pavlov', '59', '1849-09-26',	'i_pavlov@softuni.bg'),
('Friedrich', 'Wilhelm', 'Nietzsche', 2, '1844-10-15', 'f_nietzsche@softuni.bg')

INSERT INTO Trips (RoomId, BookDate, ArrivalDate, ReturnDate, CancelDate) VALUES
(101, '2015-04-12',	'2015-04-14', '2015-04-20',	'2015-02-02'),
(102, '2015-07-07',	'2015-07-15', '2015-07-22',	'2015-04-29'),
(103, '2013-07-17',	'2013-07-23', '2013-07-24',	NULL),
(104, '2012-03-17',	'2012-03-31', '2012-04-01',	'2012-01-10'),
(109, '2017-08-07',	'2017-08-28', '2017-08-29',	NULL)

--Problem 3
select * from Rooms
WHERE Id=5 OR Id=7 OR Id=9

UPDATE Rooms
SET Price  += Price*0.14
WHERE Id=5 OR Id=7 OR Id=

--Problem 4
--Delete all of Account ID 47’s account’s trips from the mapping table.
GO

DELETE FROM AccountsTrips
WHERE AccountId IN (SELECT Id FROM Accounts WHERE Id = 47)
DELETE FROM Accounts
Where Id = 47

--Problem 5
SELECT FirstName, LastName,	FORMAT(BirthDate, 'MM-dd-yyyy') AS BirthDate,	c.[Name] AS Hometown,	Email
FROM Accounts AS a
JOIN Cities AS c ON a.CityId = c.Id
WHERE Email LIKE 'e%'
ORDER BY Hometown
--Problem 6

select * from Cities
select * from Hotels
SELECT c.[Name] AS City, COUNT(c.Id) AS Hotels
FROM Hotels AS h
JOIN Cities AS c ON c.Id = h.CityId
GROUP BY c.Name
ORDER BY Hotels DESC
--problem 7 - 
SELECT atr.AccountId AS AccountId, 
CONCAT(ac.FirstName,+ ' ', ac.LastName) AS FullName,
MAX(DATEDIFF(day, tr.ArrivalDate, tr.ReturnDate)) AS LongestTrip,
MIN(DATEDIFF(day, tr.ArrivalDate, tr.ReturnDate)) AS ShortestTrip
FROM Accounts AS ac
JOIN AccountsTrips AS atr ON atr.AccountId = ac.Id
JOIN Trips AS tr ON tr.Id = atr.TripId
WHERE tr.CancelDate IS  NULL AND ac.MiddleName IS  NULL
GROUP BY atr.AccountId, FirstName, LastName
ORDER BY LongestTrip DESC, ShortestTrip ASC

--Problem 8
SELECT TOP(10)
c.Id,
c.[Name] AS City,
c.CountryCode AS Country,
COUNT(a.Id) As Accounts
FROM Cities AS c
JOIN Accounts AS a ON c.Id = a.CityId
GROUP BY c.Id, c.[Name], c.CountryCode
ORDER BY Accounts DESC
--Problem 9

SELECT
a.Id,
a.Email,
c.Name AS City,
COUNT(*) AS Trips
FROM Accounts As a
JOIN AccountsTrips AS act ON a.Id=act.AccountId
JOIN Trips AS t ON act.TripId=t.Id
JOIN Rooms As r ON t.RoomId=r.Id
JOIN Hotels AS h ON r.HotelId=h.Id
JOIN Cities AS c ON h.CityId = c.Id
WHERE (a.CityId = h.CityId)
GROUP BY a.Id, a.Email, c.Name
ORDER BY Trips DESC, a.Id
--10
SELECT
t.Id,
CONCAT(FirstName,' ', IIF(MiddleName IS NULL, '', MiddleName + ' '), LastName) AS [Full Name],
c.Name AS [From],
hotelCities.[Name] AS [To],
IIF(t.CancelDate IS NULL, CONVERT(VARCHAR(50), DATEDIFF( DAY, ArrivalDate, ReturnDate)) + ' days', 'Canceled') AS Duration
FROM Trips AS t
JOIN AccountsTrips AS act ON act.TripId=t.Id
JOIN Accounts AS a ON act.AccountId=a.Id
JOIN Cities AS c ON a.CityId=c.Id
JOIN Rooms AS r ON t.RoomId=r.Id
JOIN Hotels AS h ON r.HotelId=h.Id
JOIN Cities AS hotelCities ON h.CityId=hotelCities.Id
ORDER BY [Full Name], t.Id
--11
GO
CREATE  FUNCTION udf_GetAvailableRoom(@HotelId INT, @Date DATETIME2, @People INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
DECLARE @answer NVARCHAR(MAX) = 'No rooms available'
DECLARE @mostExpensiveRoom DECIMAL(18,4) = (
                                            SELECT
                                            MAX(Price)
                                            FROM Hotels AS h
                                            JOIN Rooms As r ON r.HotelId=h.Id
                                            JOIN Trips AS t ON t.RoomId=r.Id
                                            WHERE h.Id = @HotelId
                                            GROUP BY h.Id
                                            )
IF(@mostExpensiveRoom IS NULL )
            BEGIN
                RETURN @answer
            END
DECLARE @arrivalDate DATETIME2 = (
                        SELECT TOP(1) ArrivalDate FROM Hotels AS h
                        JOIN Rooms As r ON r.HotelId=h.Id
                        JOIN Trips AS t ON t.RoomId=r.Id
                        WHERE h.Id = @HotelId AND r.Price = @mostExpensiveRoom)
DECLARE @retturnDate DATETIME2 = (
                        SELECT TOP(1) ReturnDate FROM Hotels AS h
                        JOIN Rooms As r ON r.HotelId=h.Id
                        JOIN Trips AS t ON t.RoomId=r.Id
                        WHERE h.Id = @HotelId AND r.Price = @mostExpensiveRoom)
DECLARE @cancelDate DATETIME2 = (
                        SELECT TOP(1) CancelDate FROM Hotels AS h
                        JOIN Rooms As r ON r.HotelId=h.Id
                        JOIN Trips AS t ON t.RoomId=r.Id
                        WHERE h.Id = @HotelId AND r.Price = @mostExpensiveRoom)
IF((@Date >= @arrivalDate AND @Date <= @retturnDate) AND @cancelDate IS NULL)
            BEGIN
                RETURN @answer
            END
DECLARE @roomId INT = (
                        SELECT TOP(1) RoomId FROM Hotels AS h
                        JOIN Rooms As r ON r.HotelId=h.Id
                        JOIN Trips AS t ON t.RoomId=r.Id
                        WHERE h.Id = @HotelId AND r.Price = @mostExpensiveRoom
                        )
DECLARE @roomType NVARCHAR(50) = (
                        SELECT TOP(1) r.Type FROM Hotels AS h
                        JOIN Rooms As r ON r.HotelId=h.Id
                        JOIN Trips AS t ON t.RoomId=r.Id
                        WHERE h.Id = @HotelId AND r.Price = @mostExpensiveRoom
                        )
DECLARE @countOfBeds INT = (
                        SELECT TOP(1) r.Beds FROM Hotels AS h
                        JOIN Rooms As r ON r.HotelId=h.Id
                        JOIN Trips AS t ON t.RoomId=r.Id
                        WHERE h.Id = @HotelId AND r.Price = @mostExpensiveRoom
                        )
DECLARE @hotelBaseRate DECIMAL(18,4) = (
                                        SELECT TOP(1) h.BaseRate FROM Hotels AS h
                                        JOIN Rooms As r ON r.HotelId=h.Id
                                        JOIN Trips AS t ON t.RoomId=r.Id
                                        WHERE h.Id = @HotelId AND r.Price = @mostExpensiveRoom
                                        )
IF(@countOfBeds < @People)
BEGIN
RETURN @answer
END
DECLARE @totalCost DECIMAL(18,2) = (@hotelBaseRate + @mostExpensiveRoom)*@People
RETURN CONCAT('Room ' , @roomId, ': ', @roomType, ' (', @countOfBeds, ' beds) - $', @totalCost)
END
GO
SELECT dbo.udf_GetAvailableRoom(112, '2011-12-17', 2)
SELECT dbo.udf_GetAvailableRoom(112, '2015-07-26', 333)
----------------------------------------------------------------------------------------
--12
GO
CREATE PROCEDURE usp_SwitchRoom(@TripId INT , @TargetRoomId INT)
AS
BEGIN
DECLARE @answer VARCHAR(500);
IF(@TargetRoomId NOT IN(SELECT RoomId FROM Trips AS t
                                        JOIN Rooms AS r ON t.RoomId=r.Id
                                        JOIN Hotels As h ON r.HotelId=h.Id
                                        WHERE t.Id = @TripId))                     
THROW 55002, 'Target room is in another hotel!', 1
DECLARE @countOfBeds INT = (
                            SELECT Beds FROM Trips AS t
                            JOIN Rooms AS r ON t.RoomId=r.Id
                            JOIN Hotels As h ON r.HotelId=h.Id
                            WHERE t.Id = 10
                            )
IF(@TargetRoomId = (SELECT RoomId FROM Trips AS t
                                        JOIN Rooms AS r ON t.RoomId=r.Id
                                        JOIN Hotels As h ON r.HotelId=h.Id
                                        WHERE t.Id = @TripId))
BEGIN
        IF(@countOfBeds < ???)-- How to check "for all the trip’s accounts"????
        THROW 55012, 'Not enough beds in target room!', 1
END                
        UPDATE Trips
        SET RoomId = @TargetRoomId
        WHERE id = @TripId
END
GO

--11--
CREATE FUNCTION udf_GetAvailableRoom(@HotelId, @Date, @People)
RETURNS NVARCHAR(MAX)
BEGIN
DECLARE @alreadyOccupiedRoom DATETIME = (SELECT t.BookDate FROM Accounts as a 
JOIN AccountsTrips AS act ON a.Id = act.AccountId  
JOIN Trips AS t ON t.Id = act.TripId
WHERE BookDate IS NULL)
IF(@startValue IS NULL)
BEGIN
RETURN 0
END
DECLARE @endValue DATETIME = (SELECT CloseDate FROM Reports WHERE CloseDate = @EndDate )
IF(@endValue IS NULL)
BEGIN
RETURN 0
END
--12--

DECLARE @hoursPassed BIT = DATEDIFF(HOUR, @StartDate,  @EndDate)
RETURN @hoursPassed
END



