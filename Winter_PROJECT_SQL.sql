CREATE DATABASE WinterProject

USE WinterProject

CREATE TABLE dbo.SeniorityLevel
( 
Id int IDENTITY (1,1) NOT NULL,
Name nvarchar(100) NOT NULL,
CONSTRAINT [PK_SeniorityLevel] PRIMARY KEY CLUSTERED ([ID] ASC)
)


INSERT INTO dbo.SeniorityLevel
VALUES ('Junior'),('Intermediate'),('Senor'),('Lead'),('Project Manager'),('Division Manager'),('Office manager'),('CEO'),('CTO'),('CIO')

SELECT * FROM dbo.SeniorityLevel


CREATE TABLE dbo.Location 
(
Id int IDENTITY (1,1) NOT NULL,
CountryName nvarchar(100) NULL,
Continent nvarchar(100) NULL,
Region nvarchar(100) NULL,
CONSTRAINT [PK_Location] PRIMARY KEY CLUSTERED ([ID] ASC)
)


CREATE OR ALTER PROCEDURE dbo.Location_Insert
AS
BEGIN 
	INSERT INTO dbo.Location (CountryName, Continent, Region)
	SELECT CountryName, Continent, Region
	FROM WideWorldImporters.[Application].[Countries]
END

EXEC dbo.Location_Insert

SELECT * FROM dbo.Location 


CREATE TABLE dbo.Department
(
ID int IDENTITY (1,1) NOT NULL,
Name nvarchar(100) NOT NULL,
CONSTRAINT [PK_Department] PRIMARY KEY CLUSTERED ([ID] ASC)
)

INSERT INTO dbo.Department (Name)
VALUES ('Personal Banking & Operations'),('Digital Banking Department'),('Retail Banking & Marketing Department'),('Wealth Management & Third Party Products'),('International Banking Division & DFB'),
('Treasury'),('Information Technology'),('Corporate Communications'),('Support Services & Branch Expansion'),('Human Resources')

SELECT * FROM dbo.Department


CREATE TABLE dbo.Employee
(
ID int IDENTITY (1,1) NOT NULL,
FirstName nvarchar(100) NOT NULL,
LastName nvarchar(100) NOT NULL,
LocationId int NOT NULL,
SeniorityLevelId int NOT NULL,
DepartmentId int NOT NULL,
CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED ([ID] ASC)
)

ALTER TABLE dbo.Employee WITH CHECK
ADD CONSTRAINT FK_Employee_SeniorityLevel FOREIGN KEY ([SenioritylevelID])
REFERENCES dbo.SeniorityLevel (ID)


ALTER TABLE dbo.Employee WITH CHECK
ADD CONSTRAINT FK_Employee_Location FOREIGN KEY ([LocationID])
REFERENCES dbo.Location (ID)


ALTER TABLE dbo.Employee WITH CHECK
ADD CONSTRAINT FK_Employee_Department FOREIGN KEY ([DepartmentID])
REFERENCES dbo.Department (ID)


SELECT * FROM WideWorldImporters.Application.People 

INSERT INTO dbo.Employee (FirstName,LastName,LocationID,SeniorityLevelID,DepartmentID)
SELECT LEFT(FullName, CHARINDEX(' ', FullName) -1) AS FirstName,
SUBSTRING(FullName, CHARINDEX(' ',FullName) +1, LEN(FullName)) AS LastName,
NTILE(190) OVER (ORDER BY PersonID) as LocatonID,
NTILE(10) OVER(ORDER BY PersonID ) AS SeniorityLevelID,
NTILE(10) OVER (ORDER BY PersonID) as DepartmentID
FROM WideWorldImporters.Application.People

SELECT * FROM dbo.Employee



CREATE TABLE dbo.Salary
(
ID bigint IDENTITY (1,1) NOT NULL,
EmployeeId int NOT NULL,
Month smallint NOT NULL,
Year smallint NOT NULL,
GrossAmount decimal(18,2) NOT NULL,
NetAmount decimal(18,2) NOT NULL,
RegularWorkAmount decimal(18,2) NOT NULL,
BonusAmount decimal(18,2) NOT NULL,
OvertimeAmount decimal(18,2) NOT NULL,
VacationDays smallint NOT NULL,
SickLeaveDays smallint NOT NULL,
CONSTRAINT [PK_Salary] PRIMARY KEY CLUSTERED ([ID] ASC)
)

ALTER TABLE dbo.Salary WITH CHECK
ADD CONSTRAINT FK_Salary_Employee FOREIGN KEY ([EmployeeID])
REFERENCES dbo.Employee (ID)

SELECT * FROM dbo.Employee

SELECT * FROM dbo.Salary



/*
SELECT TOP (DATEDIFF(MONTH, @FromDate, @ToDate)+1) 
Month = MONTH(DATEADD(MONTH, number, @FromDate)),
Year  = YEAR(DATEADD(MONTH, number, @FromDate))
FROM [master].dbo.spt_values 
WHERE [type] = N'P' ORDER BY number;


DECLARE @FromDate DATETIME, @ToDate DATETIME
SET @FromDate = '2001-01-15'
SET @ToDate = '2020-12-31'
*/


CREATE VIEW dbo.MonthYear AS

SELECT TOP (DATEDIFF(MONTH, '2001-01-15', '2020-12-31')+1)
MONTH(DATEADD(MONTH, number, '2001-01-15')) as Month,YEAR(DATEADD(MONTH, number,'2001-01-15')) as Year 
FROM [master].dbo.spt_values 
WHERE [type] = N'P' ORDER BY number


CREATE VIEW dbo.Employees AS
SELECT ID AS EmployeeID FROM dbo.Employee


SELECT E.EmployeeID,M.Month,M.Year
FROM dbo.MonthYear AS M
CROSS JOIN dbo.Employees AS E
ORDER BY EmployeeID

 

SELECT E.EmployeeID,M.Month,M.Year,FLOOR(RAND(CHECKSUM(NEWID()))*(60000-30000+1)+30000) AS GrossAmount
FROM dbo.MonthYear AS M
CROSS JOIN dbo.Employees AS E
ORDER BY EmployeeID


CREATE TABLE #GrossAmount (
ID int IDENTITY (1,1) NOT NULL,
EmployeeID int NOT NULL,
Month smallint NOT NULL,
Year smallint NOT NULL,
GrossAmount int NOT NULL
)



INSERT INTO #GrossAmount
SELECT E.EmployeeID, M.Month, M.Year, FLOOR(RAND(CHECKSUM(NEWID()))*(60000-30000+1)+30000) AS GrossAmount
FROM dbo.MonthYear AS M
CROSS JOIN dbo.Employees AS E
ORDER BY EmployeeID


SELECT * FROM #GrossAmount

--------------
WITH Cte AS 
(
SELECT EmployeeID, Month, Year,
	GrossAmount
	,(GrossAmount*0.9) AS NetAmount
	,(grossAmount*0.9)*0.8 as RegularWorkAmount
	,(CASE WHEN Month % 2 <> 0 then (grossAmount*0.9) - ((grossAmount*0.9)*0.8) ELSE 0 END) AS BonusAmount
FROM #GrossAmount
) 
SELECT *, 
		(CASE WHEN Month % 2 = 0 THEN  (NetAmount - RegularWorkAmount) ELSE 0 END)  AS OvertimeAmount
FROM Cte

-------------

CREATE TABLE  #Salary(
EmployeeID int NOT NULL,
Month smallint NOT NULL,
Year smallint NOT NULL,
GrossAmount decimal(18,2) NOT NULL,
NetAmount decimal(18,2) NOT NULL,
RegularWorkAmount decimal(18,2) NOT NULL,
BonusAmount decimal(18,2) NOT NULL,
OverTimeAmount decimal(18,2) NOT NULL
)

----------------------------------------------------

WITH Cte AS 
(
SELECT EmployeeID, Month, Year,
	GrossAmount
	,(GrossAmount*0.9) AS NetAmount
	,(grossAmount*0.9)*0.8 AS RegularWorkAmount
	,(CASE WHEN Month % 2 <> 0 THEN (grossAmount*0.9) - ((grossAmount*0.9)*0.8) ELSE 0 END) AS BonusAmount
FROM #GrossAmount
), 
cte2 AS (
SELECT *, 
		(CASE WHEN Month % 2 = 0 then  (NetAmount - RegularWorkAmount) ELSE 0 END)  AS OvertimeAmount
FROM Cte
)


INSERT INTO #Salary (
	EmployeeID, 
	Month, 
	Year,
	GrossAmount,
	 NetAmount,
	RegularWorkAmount,
	BonusAmount,
	OverTimeAmount)

 SELECT * FROM Cte2

 ------------------------------



SELECT * FROM #Salary


SELECT * ,FLOOR(RAND(CHECKSUM(NEWID()))*(15-10+1)+10) AS VacationDays, 
		  FLOOR(RAND(CHECKSUM(NEWID()))*(1-10+1)+10) AS SickLeaveDays
FROM #Salary



CREATE TABLE #Salary1 (
EmployeeId int NOT NULL,
Month smallint NOT NULL,
Year smallint NOT NULL,
GrossAmount decimal(18,2) NOT NULL,
NetAmount decimal(18,2) NOT NULL,
RegularWorkAmount decimal(18,2) NOT NULL,
BonusAmount decimal(18,2) NOT NULL,
OvertimeAmount decimal(18,2) NOT NULL,
VacationDays smallint NOT NULL,
SickLeaveDays smallint NOT NULL)

INSERT INTO  #Salary1 (EmployeeID, Month, Year, GrossAmount, NetAmount, RegularWorkAmount, BonusAmount, OverTimeAmount, VacationDays, SickLeaveDays)
SELECT * ,FLOOR(RAND(CHECKSUM(NEWID()))*(15-10+1)+10) as VacationDays, 
		  FLOOR(RAND(CHECKSUM(NEWID()))*(1-5+1)+3) AS SickLeaveDays
FROM #Salary


SELECT * FROM #Salary1


SELECT * FROM #Salary1

INSERT INTO dbo.Salary ( EmployeeId, Month, Year, GrossAmount, NetAmount, RegularWorkAmount, BonusAmount, OvertimeAmount, VacationDays, SickLeaveDays)
SELECT * FROM #Salary1

SELECT * FROM dbo.Salary


UPDATE dbo.Salary
SET VacationDays = 0
WHERE Month NOT IN (7,12)



SELECT * FROM dbo.salary 
WHERE NetAmount <> (regularWorkAmount + BonusAmount + OverTimeAmount)



