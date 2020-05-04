--04--
INSERT INTO Towns(Id, [Name]) VALUES
(1, 'Sofia'),
(2, 'Plovdiv'),
(3, 'Varna')

INSERT INTO Minions(Id, [Name], Age, TownId) VALUES
(1, 'Kevin', 22, 1),
(2, 'Bob', 15, 3),
(3, 'Steward', NULL, 2)
DELETE FROM Minions
DROP TABLE Minions
DROP TABLE Towns
--07--
CREATE TABLE People (
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(200) NOT NULL,
	Picture VARBINARY(MAX) CHECK (DATALENGTH(Picture) > 1024 * 1024 * 2),
	Height DECIMAL(3, 2),
	[Weight] DECIMAL (5, 2),
	Gender CHAR(1) CHECK (Gender = 'm' OR Gender = 'f') NOT NULL,
	Birthdate DATE NOT NULL,
	Biography NVARCHAR(MAX)
)

INSERT INTO People ([Name], Picture, Height, [Weight], Gender, Birthdate, Biography) VALUES
('Pesho Marinov', NULL, 1.80, 55.23, 'm', Convert(DateTime,'19820626',112), 'Skilled worker'),
('Ivan Dimov', NULL, 1.75, 75.55, 'm', Convert(DateTime,'19850608',112), 'Basketball player'),
('Todorka Peneva', NULL, 1.66, 48.55, 'f', Convert(DateTime,'19900606',112), 'Model'),
('Dilyana Ivanova', NULL, 1.77, 52.22, 'f', Convert(DateTime,'19920705',112), 'Fashion guru'),
('Todor Stamatov', NULL, 1.88, 98.25, 'm', Convert(DateTime,'19870706',112), 'Master')
--08--
CREATE TABLE Users(
Id BIGINT PRIMARY KEY IDENTITY,
Username VARCHAR(30) UNIQUE NOT NULL,
[Password] VARCHAR(26) NOT NULL,
ProfilePicture VARBINARY (MAX)
CHECK(DATALENGTH(ProfilePicture) <= 921600),
LastLoginTime DATETIME2,
IsDeleted BIT
)
INSERT INTO Users (Username, [Password], ProfilePicture, LastLoginTime, IsDeleted) VALUES
('Pesho','123', NULL,NULL, 0),
('Stamat','123', NULL,NULL, 0),
('Kircho','123', NULL,NULL, 0),
('Natasha','123', NULL,NULL, 1),
('Evlampii','123', NULL,NULL, 1)
SELECT * FROM Users
--09--
ALTER TABLE Users
DROP CONSTRAINT PK__Users__3214EC07BF95B45A
ALTER TABLE Users
ADD CONSTRAINT PK_CompositeUsersAndId
PRIMARY KEY (Id, Username)
--10--
ALTER TABLE Users
ADD CONSTRAINT PasswordLength CHECK (LEN(Password) >= 5)
--11--
ALTER TABLE Users
ADD DEFAULT GETDATE() FOR LastLoginTime
--12--
ALTER TABLE Users
DROP CONSTRAINT PK_CompositeUsersAndId

ALTER TABLE Users
ADD CONSTRAINT PK_Id
PRIMARY KEY (Id)
--13--
CREATE DATABASE Movies
CREATE TABLE Directors(
Id INT PRIMARY KEY IDENTITY,
DirectorName NVARCHAR(80) NOT NULL,
Notes NVARCHAR (max)
)
	INSERT INTO Directors VALUES 
	('Stamat', NULL),
	('Goshko', 'Alababala'),
	('Vangel', 'OyEa'),
	('Toni', 'He is the BoSs'),
	('Stoiko', NULL)

CREATE TABLE Genres(
Id INT PRIMARY KEY IDENTITY,
GenreName NVARCHAR(100) NOT NULL UNIQUE,
Notes NVARCHAR(MAX)
)
INSERT INTO Genres  VALUES
	('Porno', 'DeepThroat'),
	('Comedy', NULL),
	('Action', 'NOT ANOTHER TEEN MOVIE'),
	('Fantasy', NULL),
	('Horrar', 'SAW 789')
CREATE TABLE Categories(
Id INT PRIMARY KEY IDENTITY,
CategoryName NVARCHAR(50) NOT NULL,
Notes NVARCHAR(MAX)
)
	INSERT INTO Categories  VALUES
	('Adults', 'f*cking'),
	('Teen', NULL),
	('Boring','Oyea'),
	('fourth', 'I''imagening how somemody staring my profile.. ha ha'),
	('TheLast', NULL)
CREATE TABLE Movies (
	Id INT PRIMARY KEY IDENTITY,
	Title NVARCHAR(MAX) NOT NULL,
	DirectorId INT FOREIGN KEY REFERENCES Directors(Id),
	CopyrightYear INT NOT NULL,
	[Length] TIME,
	GenreId INT FOREIGN KEY REFERENCES Genres(Id),
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id),
	Rating DECIMAL(2,1),
	Notes NVARCHAR(MAX)
)
	INSERT INTO Movies VALUES
	('Captain America', 1, 1988, '1:22:00', 1, 5, 9.5, 'Superhero'),
	('Mean Machine', 1, 1998, '1:40:00', 2, 4, 8.0, 'Prison'),
	('Little Cow', 2, 2007, '1:35:55', 3, 3, 2.3, 'Agro'),
	('Smoked Almonds', 5, 2013, '2:22:25', 4, 2, 7.8, 'Whiskey in the Jar'),
	('I''m very mad!', 4, 2018, '1:30:02', 5, 1, 9.9, 'Rating 10 not supported') 

--14--
CREATE DATABASE CarRental
USE CarRental

CREATE TABLE Categories (
Id INT PRIMARY KEY IDENTITY,
CategoryName NVARCHAR (80) NOT NULL,
DailyRate INT NOT NULL,
WeeklyRate INT  NOT NULL,
MonthlyRate INT  NOT NULL,
WeekendRate INT  NOT NULL
)

CREATE TABLE Cars (
Id INT PRIMARY KEY IDENTITY,
PlateNumber NVARCHAR(30) NOT NULL UNIQUE,
Manufacturer NVARCHAR(80) NOT NULL,
Model NVARCHAR(80) NOT NULL,
CarYear INT NOT NULL,
CategoryId INT FOREIGN KEY REFERENCES Categories(Id),
Doors INT,
Picture VARBINARY(MAX),
Condition NVARCHAR(MAX) NOT NULL,
Available BIT NOT NULL
)

CREATE TABLE Employees (
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(50) NOT NULL,
LastName NVARCHAR (50) NOT NULL,
Title NVARCHAR (50),
Notes NVARCHAR (MAX)
)

CREATE TABLE Customers (
Id INT PRIMARY KEY IDENTITY,
DriverLicenceNumber BIGINT NOT NULL UNIQUE,
FullName NVARCHAR(120) NOT NULL,
[Address] NVARCHAR(120) NOT NULL,
City NVARCHAR(50) NOT NULL,
ZIPCode INT,
Notes NVARCHAR(MAX)
)

CREATE TABLE RentalOrders (
Id INT PRIMARY KEY IDENTITY,
EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
CustumoerId INT FOREIGN KEY REFERENCES Customers(Id),
CarId INT FOREIGN KEY REFERENCES Cars(Id),
TankLevel DECIMAL(5,2) NOT NULL,
KilometrageStart BIGINT NOT NULL,
KilometrageEnd BIGINT NOT NULL,
TotaLKilometrage AS KilometrageEnd - KilometrageStart,
StartDate DATE NOT NULL,
EndDate DATE NOT NULL,
TotalDays AS DATEDIFF(DAY, StartDate, EndDate),
RateApplied INT NOT NULL,
TaxRate DECIMAL (5,2) NOT NULL,
OrderStatys BIT NOT NULL,
Notes NVARCHAR(MAX)
)

INSERT INTO Categories VALUES 
('Sport', 3,2,4,6),
('ForKids', 6,6,6,5),
('ForRetire', 2,4,5,1)

INSERT INTO Cars VALUES
('CB9021KH', 'Opel', 'Corsa', 1982,2,5,NULL,'Good',1),
('CB9221KH', 'Lada', 'Niva', 1946,1,5,NULL,'Good',1),
('CB9321KH', 'Opel', 'Zafira', 1999,3,5,NULL,'Good',1)

INSERT INTO Employees VALUES
('Gosho', 'Goshov', NULL, NULL),
('Pencho', 'Totkov', NULL, NULL),
('Fracil', 'Mindjev', NULL, NULL)

INSERT INTO Customers VALUES
(382123, 'Pencho Menchev', 'Nevada', 'Las Vegas', NULL, NULL),
(123521, 'Fracil Fruckov', 'Nadejda', 'Sofia', NULL, NULL),
(412421, 'Kanalin Colov', 'Liulin 8', 'Sofia', NULL, NULL)

INSERT INTO RentalOrders VALUES
(1, 2, 3, 45.221, 228866, 339944, '2007-08-08', '2007-08-10', 250, 150,1,NULL),
(2, 3, 1, 50.32, 11111, 1111123, '2009-09-06', '2009-09-28', 1500,200, 0, NULL),
(2, 2, 1, 18.123, 121212, 161819, '2017-05-08', '2017-06-09', 850,300, 0, NULL)

--15--
CREATE DATABASE Hotel
USE Hotel
CREATE TABLE Employees (
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR (30) NOT NULL,
LastName NVARCHAR (30) NOT NULL,
Title NVARCHAR (30),
Notes NVARCHAR (MAX)
)

CREATE TABLE Customers (
AccountNumber INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR (30) NOT NULL,
LastName NVARCHAR (30) NOT NULL,
PhoneNumber BIGINT NOT NULL UNIQUE,
EmergencyName NVARCHAR(30) NOT NULL,
EmergencyNumber INT NOT NULL,
Notes NVARCHAR (MAX)
)

CREATE TABLE RoomStatus (
RoomStatus NVARCHAR(30) PRIMARY KEY NOT NULL,
Notes NVARCHAR (MAX)
)

CREATE TABLE RoomTypes (
RoomType NVARCHAR(10) PRIMARY KEY NOT NULL,
Notes NVARCHAR(MAX)
)

CREATE TABLE BedTypes (
BedType NVARCHAR(10) PRIMARY KEY NOT NULL,
Notes NVARCHAR(MAX)
)

CREATE TABLE Rooms (
RoomNumber INT PRIMARY KEY NOT NULL,
RoomType NVARCHAR(10) FOREIGN KEY REFERENCES RoomTypes(RoomType),
BedType NVARCHAR(10) FOREIGN KEY REFERENCES BedTypes(BedType),
Rate INT NOT NULL,
RoomStatus BIT NOT NULL,
Notes NVARCHAR(MAX)
)

CREATE TABLE Payments (
Id INT PRIMARY KEY IDENTITY,
EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
PaymentDate DATE NOT NULL,
AccountNumber INT FOREIGN KEY REFERENCES Customers(AccountNumber) NOT NULL,
FirstDateOccupied DATE NOT NULL,
LastDateOccupied DATE NOT NULL,
TotalDays AS DATEDIFF(DAY, FirstDateOccupied, LastDateOccupied), 
AmountCharged DECIMAL(7,2) NOT NULL,
TaxRate DECIMAL (7,2) NOT NULL,
TaxAmount AS AmountCharged*TaxRate,
PaymentTotal AS AmountCharged + AmountCharged*TaxRate,
Notes NVARCHAR (MAX)
)

CREATE TABLE Occupancies (
Id INT PRIMARY KEY IDENTITY,
EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
DateOccupied DATE NOT NULL,
AccountNumber INT FOREIGN KEY REFERENCES Customers(AccountNumber),
RoomNumber INT FOREIGN KEY REFERENCES Rooms(RoomNumber),
RateApplied INT,
PhoneCharge DECIMAL(5,2),
Notes NVARCHAR(MAX)
)

INSERT INTO Employees VALUES
('Gosho', 'Penchev', NULL, NULL),
('Stefan', 'Goshev', NULL, NULL),
('Pencho', 'Denchev', NULL, NULL)

INSERT INTO Customers VALUES
('Pesho','Goshov', 08273829, 'Help', 911, NULL),
('Misho','Doshkov', 548794, 'Meow', 166, NULL),
('Kraicho','Gergov', 8798413, 'DJAFF', 112, NULL)

INSERT INTO RoomStatus VALUES
('Mac', NULL),
('Trac', NULL),
('Frac', NULL)

INSERT INTO RoomTypes VALUES
('Double', NULL),
('Triple', NULL),
('Queen', NULL)

INSERT INTO BedTypes VALUES 
('Big', NULL),
('KING', NULL),
('Baby', NULL)

INSERT INTO Rooms VALUES
(12,'Double','Big',1,0,NULL),
(3,'Triple','KING',8,0,NULL),
(22,'Queen','Baby',6,1,NULL)

INSERT INTO Payments(EmployeeId, PaymentDate, AccountNumber, FirstDateOccupied, LastDateOccupied, AmountCharged, TaxRate) VALUES
(1, '2011-11-25', 2, '2017-11-30', '2017-12-04', 250.0, 0.2),
(3, '2014-06-03', 3, '2014-06-06', '2014-06-09', 340.0, 0.2),
(3, '2016-02-25', 2, '2016-02-27', '2016-03-04', 500.0, 0.2)

INSERT INTO Occupancies(EmployeeId, DateOccupied, AccountNumber, RoomNumber, RateApplied, PhoneCharge) VALUES
(2, '2011-02-04', 3, 12, 70.0, 12.54),
(2, '2015-04-09', 1, 3, 40.0, 11.22),
(3, '2012-06-08', 2, 22, 110.0, 10.05)
--16--
CREATE DATABASE SoftUni
USE SoftUni

CREATE TABLE Towns(
Id INT PRIMARY KEY IDENTITY(1,1),
[Name] NVARCHAR(30) NOT NULL,
)

CREATE TABLE Addresses (
Id INT PRIMARY KEY IDENTITY(1,1),
AddressText NVARCHAR(130),
TownId INT FOREIGN KEY REFERENCES Towns(Id),
)

CREATE TABLE Departments (
Id INT PRIMARY KEY IDENTITY(1,1),
Name NVARCHAR(130) NOT NULL,
)

CREATE TABLE Employees (
Id INT PRIMARY KEY IDENTITY(1,1),
FirstName NVARCHAR(30) NOT NULL,
MiddleName NVARCHAR(30) NOT NULL,
LastName NVARCHAR(30) NOT NULL,
JobTitle NVARCHAR(30),
DepartmentId INT FOREIGN KEY REFERENCES Departments(Id),
HireDate DATE NOT NULL,
Salary DECIMAL(7,2) NOT NULL,
AddressId INT FOREIGN KEY REFERENCES Addresses(Id),
)
--17--
USE MASTER
DROP DATABASE SoftUni
--redy--

--18--
USE SOFTUNI
INSERT INTO Towns VALUES
('Sofia'),
('Plovdiv'),
('Varna'),
('Burgas')

INSERT Departments VALUES
('Engineering'),
('Sales'),
('Marketing'),
('Software Development'),
('Quality Assurance')

INSERT INTO Employees(FirstName, MiddleName, LastName, JobTitle, DepartmentId, HireDate, Salary ) VALUES
('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, '2013-02-01', 3500.00),
('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, '2004-03-02', 4000.00),
('Maria', 'Petrova', 'Ivanova', 'Intern', 5, '2016-08-28', 525.25),
('Georgi', 'Teziev', 'Ivanov', 'CEO', 2, '2007-12-09', 3000.00),
('Peter', 'Pan', 'Pan', 'Intern', 3, '2016-08-28', 599.88)
--19--
SELECT * FROM Towns
SELECT * FROM Departments
SELECT * FROM Employees
--20--
SELECT * FROM Towns
ORDER BY [Name]
SELECT * FROM Departments
ORDER BY [Name]
SELECT * FROM Employees
ORDER BY Salary DESC
--21--