CREATE DATABASE Airport
USE Airport
--1--
CREATE TABLE Planes(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL,
	Seats INT NOT NULL,
	[Range] INT NOT NULL
)

CREATE TABLE Flights(
	Id INT PRIMARY KEY IDENTITY,
	DepartureTime DATETIME,
	ArrivalTime DATETIME,
	Origin NVARCHAR(50) NOT NULL,
	Destination NVARCHAR(50) NOT NULL,
	PlaneId INT FOREIGN KEY REFERENCES Planes(Id) NOT NULL
)

CREATE TABLE Passengers(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	Age INT NOT NULL,
	[Address] NVARCHAR(30) NOT NULL,
	PassportId CHAR(11) NOT NULL
)

CREATE TABLE LuggageTypes(
	Id INT PRIMARY KEY IDENTITY,
	[Type] NVARCHAR(30) NOT NULL
)

CREATE TABLE Luggages(
	Id INT PRIMARY KEY IDENTITY,
	LuggageTypeId INT FOREIGN KEY REFERENCES LuggageTypes(Id) NOT NULL,
	PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL
)

CREATE TABLE Tickets(
	Id INT PRIMARY KEY IDENTITY,
	PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL,
	FlightId INT FOREIGN KEY REFERENCES Flights(Id) NOT NULL,
	LuggageId INT FOREIGN KEY REFERENCES Luggages(Id) NOT NULL,
	Price DECIMAL(18,2) NOT NULL
)
--2--
INSERT INTO Planes VALUES
('Airbus 336', 112, 5132),
('Airbus 330', 432, 5325),
('Boeing 369', 231, 2355),
('Stelt 297', 254, 2143),
('Boeing 338', 165, 5111),
('Airbus 558', 387, 1342),
('Boeing 128', 345, 5541)

INSERT INTO LuggageTypes VALUES
('Crossbody Bag'),
('School Backpack'),
('Shoulder Bag')
--3--
UPDATE Tickets
SET Price += Price*0.13
WHERE FlightId IN (SELECT Id FROM Flights WHERE Destination = 'Carlsbad')
--4--
DELETE FROM Tickets
WHERE FlightId IN (SELECT Id FROM Flights WHERE Destination = 'Ayn Halagim')
DELETE FROM Flights
Where Destination = 'Ayn Halagim'
--5--
SELECT *
FROM Planes
WHERE [Name] LIKE '%tr%'
ORDER BY Id ASC, [Name] ASC, Seats ASC, [Range] ASC
--6--
SELECT FlightId, SUM(Price) AS Price
FROM Tickets
GROUP BY FlightId
ORDER BY Price DESC, FlightId ASC
--7--
SELECT CONCAT(p.FirstName, + ' ', + p.LastName) AS [Full Name], f.Origin, f.Destination
FROM	Passengers AS p
		JOIN Tickets AS t
ON		t.PassengerId = p.Id
		JOIN Flights AS f
ON		t.FlightId = f.Id
ORDER BY [Full Name] ASC, Origin ASC, Destination ASC
--8--
SELECT FirstName AS [First Name], LastName AS [Last Name], Age
FROM Passengers AS p
	 LEFT JOIN Tickets AS t
ON	 t.PassengerId = p.Id
WHERE t.Id IS NULL
ORDER BY Age DESC, [First Name] ASC, [Last Name] ASC
--9--
SELECT CONCAT(p.FirstName,+' ',+ p.LastName) AS [Full Name], pl.[Name] AS [Plane Name], CONCAT(f.Origin, + ' - ',+ f.Destination) AS Trip, lt.[Type] AS [Luggage Type]
FROM	Passengers AS p
		JOIN Tickets AS t
ON		t.PassengerId = p.Id
		JOIN Flights AS f
ON		t.FlightId = f.Id
		JOIN Planes AS pl
ON		f.PlaneId = pl.Id
		JOIN Luggages AS l
ON		t.LuggageId = l.Id
		JOIN LuggageTypes AS lt
ON		l.LuggageTypeId = lt.Id
ORDER BY [Full Name] ASC, [Plane Name] ASC, Origin ASC, Destination ASC, lt.Type ASC
--10--
SELECT pl.[Name], pl.Seats, COUNT(p.Id) AS [Passengers Count]
FROM	Planes AS pl
	LEFT	JOIN Flights AS f
ON		f.PlaneId = pl.Id
	LEFT	JOIN Tickets AS t
ON		t.FlightId = f.Id
	LEFT	JOIN Passengers AS p
ON		p.Id = t.PassengerId
GROUP BY pl.[Name], pl.Seats
ORDER BY COUNT(t.PassengerId) DESC, pl.[Name] ASC, pl.Seats ASC
--11--
CREATE FUNCTION udf_CalculateTickets(@origin NVARCHAR(50), @destination NVARCHAR(50), @peopleCount INT)
RETURNS NVARCHAR(120)
AS BEGIN
	IF(@peopleCount <= 0)
	BEGIN
		RETURN 'Invalid people count!';
	END

	DECLARE @flightId INT = (SELECT TOP(1) Id FROM Flights Where Origin = @origin AND Destination = @destination);
	IF (@flightId IS NULL)
	BEGIN
	RETURN 'Invalid flight!';
	END
    DECLARE @result NVARCHAR(120)
	DECLARE @pricePerPerson DECIMAL(18,2) = (SELECT TOP(1) Price FROM Tickets As t WHERE t.FlightId = @flightId);
		    DECLARE @totalPrice DECIMAL(18,2)= @pricePerPerson*@peopleCount;
			    RETURN  CONCAT('Total price'+' ',@totalPrice);
END
--12--
CREATE PROC usp_CancelFlights
AS
BEGIN
	UPDATE Flights
	SET DepartureTime= NULL, ArrivalTime = NULL
	WHERE DATEDIFF(SECOND, DepartureTime, ArrivalTime) > 0
END
