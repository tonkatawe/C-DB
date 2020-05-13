--1--
CREATE TABLE Persons
(
PersonID INT IDENTITY,
FirstName NVARCHAR(100) NOT NULL,
Salary MONEY NOT NULL,
PassportID INT NOT NULL
)

CREATE TABLE Passports
(
PassportID INT PRIMARY KEY,
PassportNumber NVARCHAR(100) NOT NULL
)

INSERT INTO Persons
(FirstName, Salary, PassportID)
VALUES
('Roberto', 43300.00, 102),
('Tom', 56100.00, 103),
('Yana', 60200.00, 101)

INSERT INTO Passports
(PassportID, PassportNumber)
VALUES
(101, 'N34FG21B'),
(102, 'K65LO4R7'),
(103, 'ZE657QP2')


ALTER TABLE Persons
ADD CONSTRAINT PK_Persons PRIMARY KEY (PersonID),
CONSTRAINT FK_Persons_Passports FOREIGN KEY (PassportID) REFERENCES Passports (PassportID)

--2--

CREATE TABLE Manufacturers(
ManufacturerID INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(30) NOT NULL,
EstablishedOn DATE NOT NULL
)

CREATE TABLE Models(
ModelID INT PRIMARY KEY NOT NULL,
[Name] VARCHAR(30) NOT NULL,
ManufacturerID INT NOT NULL
)


INSERT INTO Manufacturers ([Name],EstablishedOn)
VALUES
('BMW','07/03/1916'),
('Tesla', '01/01/2003'),
('Lada', '01/05/1966')

ALTER TABLE Models
ADD CONSTRAINT FK_Models_Manifacturers FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID)

INSERT INTO Models (ModelID,[Name],ManufacturerID) 
VALUES
(101,'X1',1),
(102,'i6',1),
(103,'Model S',2),
(104,'Model X',2),
(105,'Model 3',2),
(106,'Nova',3)

--3--
CREATE TABLE Students (
StudentID INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(30) NOT NULL
)
CREATE TABLE Exams(
ExamID INT PRIMARY KEY,
[Name] NVARCHAR(30) NOT NULL)
INSERT INTO Students ([Name])
VALUES
('Mila'),
('Toni'),
('Ron')

INSERT INTO Exams (ExamID, [Name])
VALUES
(101,'SpringMVC'),
(102,'Neo4j'),
(103,'Oracle 11g')

CREATE TABLE StudentsExams(
StudentID INT NOT NULL,
ExamID INT NOT NULL,

CONSTRAINT FK_StudentsExams_Students FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
CONSTRAINT FK_StudentsExams_Exams FOREIGN KEY (ExamID) REFERENCES Exams (ExamID),
CONSTRAINT PK_StudentsExams PRIMARY KEY (StudentID,ExamID)
)
--4--
CREATE TABLE Teachers(
TeacherID INT PRIMARY KEY,
[Name] NVARCHAR (50),
ManagerID INT,
CONSTRAINT FK_Teachers FOREIGN KEY (ManagerID) REFERENCES Teachers(TeacherID)
)

INSERT INTO Teachers (TeacherID,[Name],ManagerID)
VALUES
(101, 'John', NULL),
(102, 'Maya', 106),
(103, 'Silvia', 106),
(104, 'Ted', 105),
(105, 'Mark', 101),
(106, 'Greta', 101)
--5--
CREATE TABLE Orders
(
OrderID INT PRIMARY KEY,
CustomerID INT
)

CREATE TABLE Customers
(
CustomerID INT PRIMARY KEY,
Name VARCHAR(50),
Birthday DATE,
CityID INT
)

CREATE TABLE Cities
(
CityID INT PRIMARY KEY,
Name VARCHAR(50)
)

CREATE TABLE OrderItems
(
OrderID INT,
ItemID INT,
CONSTRAINT PK_OrderItems PRIMARY KEY (OrderID, ItemID)
)

CREATE TABLE Items
(
ItemID INT PRIMARY KEY,
Name VARCHAR(50),
ItemTypeID INT
)

CREATE TABLE ItemTypes
(
ItemTypeID INT PRIMARY KEY,
Name VARCHAR(50)
)

ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)

ALTER TABLE Customers
ADD CONSTRAINT FK_Customers_Cities FOREIGN KEY (CityID) REFERENCES Cities (CityID)

ALTER TABLE OrderItems
ADD
CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderID) REFERENCES Orders (OrderID),
CONSTRAINT FK_OrderItems_Items FOREIGN KEY (ItemID) REFERENCES Items (ItemID)

ALTER TABLE Items
ADD CONSTRAINT FK_Items_ItemTypes FOREIGN KEY (ItemTypeID) REFERENCES ItemTypes (ItemTypeID)
--6--
CREATE TABLE Students
(
StudentID INT PRIMARY KEY,
StudentNumber INT,
StudentName NVARCHAR(100),
MajorID INT
)

CREATE TABLE Agenda
(
StudentID INT,
SubjectID INT,
CONSTRAINT PK_Agenda PRIMARY KEY (StudentID, SubjectID)
)

CREATE TABLE Subjects
(
SubjectID INT PRIMARY KEY,
SubjectName NVARCHAR(100)
)

CREATE TABLE Majors
(
MajorID INT PRIMARY KEY,
Name NVARCHAR(100)
)

CREATE TABLE Payments
(
PaymentID INT PRIMARY KEY,
PaymentDate DATE,
PaymentAmount MONEY,
StudentID INT
)

ALTER TABLE Students
ADD CONSTRAINT FK_Students_Majors FOREIGN KEY (MajorID) REFERENCES Majors (MajorID)

ALTER TABLE Payments
ADD CONSTRAINT FK_Payments_Students FOREIGN KEY (StudentID) REFERENCES Students (StudentID)

ALTER TABLE Agenda
ADD CONSTRAINT FK_Agenda_Students FOREIGN KEY (StudentID) REFERENCES Students (StudentID),
CONSTRAINT FK_Agenda_Subjects FOREIGN KEY (SubjectID) REFERENCES Subjects (SubjectID)
--9--
USE Geography
SELECT m.MountainRange, p.PeakName, p.Elevation 
FROM Mountains AS m --//First Execute this
JOIN Peaks AS p --//First Execute This.. 
ON p.MountainId = m.Id
WHERE m.MountainRange = 'Rila'
ORDER BY p.Elevation DESC