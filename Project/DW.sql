USE [master];
GO

IF Exists(Select name from sys.databases where name ='Sales_DW')
Begin
	Drop Database Sales_DW
End

CREATE DATABASE Sales_DW;
GO

ALTER DATABASE Sales_DW
SET RECOVERY SIMPLE,
    ANSI_NULLS ON,
    ANSI_PADDING ON,
    ANSI_WARNINGS ON,
    ARITHABORT ON,
    CONCAT_NULL_YIELDS_NULL ON,
    QUOTED_IDENTIFIER ON,
    NUMERIC_ROUNDABORT OFF,	
    PAGE_VERIFY CHECKSUM,
    ALLOW_SNAPSHOT_ISOLATION OFF;
GO

USE Sales_DW;
GO

---------FactSales-------------

CREATE TABLE Sales_DW.dbo.FactSales(
	OrderDetailID int NOT NULL Primary Key,
	SalesOrderID int not null, 
	SalesPersonID int,
	StatusID INT NOT NULL,
	ProductID int NOT NULL,
	StoreID int,
	shipMethodID INT,
	CustomerID int NOT NULL,
	CurrencyID int,
	personID int ,
	TerritoryID int ,
	CreditCardID int,
	SpecialOfferID int NOT NULL,
	OrderDateKey int NOT NULL,
	DueDateKey int NOT NULL,
	ShipDateKey int NOT NULL,
	SalesOrderNumber varchar(20) NOT NULL,
	RevisionNumber tinyint NOT NULL,
	OrderQuantity smallint NOT NULL,
	UnitPrice float NOT NULL,
	ExtendedAmount float NOT NULL,
	DiscountAmount float NOT NULL,
	ProductStandardCost Float NOT NULL,
	UnitPriceDiscount Float NOT NULL,
	subtotal float NOT NULL,
	TaxAmt Float NOT NULL,
	Freight Float NOT NULL,
	TotalDue float NOT NULL,
	CustomerPONumber varchar(25) NULL,
	OrderDate datetime NULL,
	DueDate datetime NULL,
	ShipDate datetime NULL
) ON [PRIMARY];
GO

------------Dim_CreditCard-------------

CREATE Table Sales_DW.dbo.Dim_CreditCard
(
	CreditCardID int NOT NULL PRIMARY KEY,
	CardType varchar(20) NOT NULL,
	CardNumber varchar(20) NOT NULL,
	ExpMonth int NOT NULL,
	ExpYear int
)
go

-------------------Dim_Date-----------------

CREATE TABLE Sales_DW.dbo.Dim_Date (
    DateKey INT PRIMARY KEY,            
    FullDate DATE NOT NULL,           
    Day TINYINT NOT NULL,               
    Month TINYINT NOT NULL,            
    MonthName VARCHAR(20) NOT NULL,   
    CalendarQuarter TINYINT NOT NULL,   
    CalendarYear SMALLINT NOT NULL,    
    DayOfWeek TINYINT NOT NULL,         
    DayNameOfWeek VARCHAR(20) NOT NULL, 
    WeekOfYear TINYINT NOT NULL,        
    IsWeekend BIT NOT NULL             
);
go

------------Dim_Territory-------------

CREATE Table Sales_DW.dbo.Dim_Territory
(
	TerritoryID int not null Primary key,
	Name varchar(20) NOT NULL,
	CountryRegionCode varchar(5) NOT NULL,
	"Group" varchar(20) NOT NULL,
	SalesYTD money NOT NULL,
	SalesLastYear money NOT NULL,
	CostYTD money NOT NULL,
	CostLastYear money NOT NULL
);
go

--------------Dim_Offers-----------------

Create Table Sales_DW.dbo.Dim_Offers
(
	SpecialOfferID int not NULL,
	ProductID int not NULL,
	Description varchar(50) NOT NULL,
	DiscountPct Decimal NOT NULL,
	Type varchar(50) NOT NULL,
	Category varchar(50) NOT NULL,
	MinQty int not NULL ,
	MaxQty int,

	Primary key(SpecialOfferID, ProductID)
)
go

-------------Dim_Product-----------------

Create Table Sales_DW.dbo.Dim_Product
(
	id int not null IDENTITY(1,1) Primary Key,
	ProductID int NOT NULL,
	Name varchar(50) NOT NULL,
	ProductNumber varchar(10) NOT NULL,
	Color varchar(30),
	SafetyStockLevel int NOT NULL,
	ReorderPoint int NOT NULL,
	StandardCost Float NOT NULL,
	ListPrice Float NOT NULL,
	Size varchar(5),
	SizeUnitMeasureCode varchar(5),
	Weight float,
	WeightUnitMeasureCode varchar(5),
	DaysToManufacture int not null,
	ProductSubcategoryID int,
	ProductModelID int,
	StartDate DATETIME,
    	EndDate DATETIME,
    	IsCurrent BIT
)
go

--------------ProductSubcategory----------------------
Create Table Sales_DW.dbo.ProductSubcategory
(
	ProductSubcategoryID int NOT NULL Primary Key,
	Name Varchar(20) NOT NULL
)
Go

---------------Dim_Product_Photos---------------------

Create Table Sales_DW.dbo.Dim_Product_Photos
(
	ProductID int NOT NULL,
	product_PhotoID int NOT NULL,
	Small_image Varbinary(MAX) NOT NULL,
	Small_image_name varchar(50) NOT NULL,
	Large_image Varbinary(MAX) NOT NULL,
	Large_image_name varchar(50) NOT NULL,

	Primary key(ProductID,product_PhotoID)
)
go

--------------Dim_currency-----------------------

Create Table Sales_DW.dbo.Dim_currency
(
	CurrencyRateID int not null Primary key,
	From_Currency varchar(50) NOT NULL,
	To_Currency varchar(50) NOT NULL,
	AverageRate Float NOT NULL,
	EndOfDayRate Float NOT NULL
)
go

-----------Dim_Store--------------

create Table Sales_DW.dbo.Dim_Store
(
	storeId int NOT NULL Primary Key,
	store_name Varchar(50) NOT NULL
)
go

-------------Dim_ShipMethods-------------------

Create table Sales_DW.dbo.Dim_ShipMethods
(
	ShipMethodID int NOT NULL Primary Key,
	ShipMethod varchar(50) NOT NULL,
	ShipBase Float NOT NULL,
	ShipRate Float NOT NULL
)
go

-----------------Dim_person-----------------
Create table Sales_DW.dbo.Dim_person
(
	SalesPersonID INT NOT NULL Primary Key,
	Title varchar(20),
	FullName varchar(50) NOT NULL,
	JobTitle varchar(50) NOT NULL,
	PhoneNumber varchar(50) NOT NULL,
	PhoneNumberType varchar(50) NOT NULL,
	EmailAddress varchar(50) NOT NULL,
	AddressLine1 varchar(50) NOT NULL,
	City varchar(50) NOT NULL,
	StateProvinceName varchar(50) NOT NULL,
	PostalCode varchar(50) NOT NULL,
	CountryRegionName varchar(50) NOT NULL,
	TerritoryName varchar(50)
)
go

Create Table Sales_DW.dbo.Dim_Statuses
(
	StatusID INT NOT NULL Primary Key,
	Status varchar(20) NOT NULL
)
go

-----------------initial_inserts------------------------

Set IDENTITY_INSERT Sales_DW.dbo.Dim_Product ON;
INSERT INTO Sales_DW.dbo.Dim_Product
(
	ProductID,
	Name,
    ProductNumber,
    Color,
    SafetyStockLevel,
    ReorderPoint,
    StandardCost,
    ListPrice,
    Size,
    SizeUnitMeasureCode,
    Weight,
    WeightUnitMeasureCode,
    DaysToManufacture,
    ProductSubcategoryID,
    ProductModelID,
    StartDate,
    EndDate,
    IsCurrent
)
SELECT
	ProductID,
    Name,
    ProductNumber,
    Color,
    SafetyStockLevel,
    ReorderPoint,
    StandardCost,
    ListPrice,
    Size,
    SizeUnitMeasureCode,
    Weight,
    WeightUnitMeasureCode,
    DaysToManufacture,
    ProductSubcategoryID,
    ProductModelID,
    GETDATE() AS StartDate,
    NULL AS EndDate,
    1 AS IsCurrent
FROM Sales_OLTP.Production.Product;
Set IDENTITY_INSERT Sales_DW.dbo.Dim_Product OFF;
go
----------------------------------------------

insert into Sales_DW.dbo.Dim_person
(
	SalesPersonID,
	Title,
	FullName,
	JobTitle,
	PhoneNumber,
	PhoneNumberType,
	EmailAddress,
	AddressLine1,
	City,
	StateProvinceName,
	PostalCode,
	CountryRegionName,
	TerritoryName
)
SELECT 
	BusinessEntityID AS SalesPersonID,
	Title,
	CONCAT(FirstName, ' ', MiddleName + '. ', LastName) AS FullName,
	JobTitle,
	PhoneNumber,
	PhoneNumberType,
	EmailAddress,
	AddressLine1,
	City,
	StateProvinceName,
	PostalCode,
	CountryRegionName,
	TerritoryName
FROM Sales_OLTP.Sales.vSalesPerson
go

Insert into Sales_DW.dbo.FactSales
(
	OrderDetailID,
	SalesOrderID,
	SalesPersonID,
	StatusID,
	ProductID,
	StoreID,
	personID,
	TerritoryID,
	CustomerID,
	CurrencyID,
	shipMethodID,
	CreditCardID,
	SpecialOfferID,
	OrderDateKey,
	DueDateKey,
	ShipDateKey,
	SalesOrderNumber,
	RevisionNumber,
	OrderQuantity,
	UnitPrice,
	UnitPriceDiscount,
	ExtendedAmount,
	DiscountAmount,
	ProductStandardCost,
	subtotal,
	TaxAmt,
	Freight,
	totalDue,
	CustomerPONumber,
	OrderDate,
	DueDate,
	ShipDate
)
select  
	D.SalesOrderDetailID as OrderDetailID,
	D.SalesOrderID,
	h.SalesPersonID,
	h.Status as StatusID,
	ProductID,
	C.StoreID,
	C.personID,
	C.TerritoryID,
    H.CustomerID AS CustomerID,
    CurrencyRateID AS CurrencyID,
	ShipMethodID,
	H.CreditCardID,
	D.SpecialOfferID,
    CONVERT(INT, FORMAT(OrderDate, 'yyyyMMdd')) AS OrderDateKey,
    CONVERT(INT, FORMAT(DueDate, 'yyyyMMdd')) AS DueDateKey,
    CONVERT(INT, FORMAT(ShipDate, 'yyyyMMdd')) AS ShipDateKey,
    SalesOrderNumber,
    RevisionNumber,
    OrderQty AS OrderQuantity,
    UnitPrice,
	UnitPriceDiscount,
    LineTotal AS ExtendedAmount,
    LineTotal - ( OrderQty *  UnitPrice) AS DiscountAmount,
    UnitPrice *  OrderQty AS ProductStandardCost,
	SubTotal,
    TaxAmt,
    Freight,
	TotalDue,
    PurchaseOrderNumber AS CustomerPONumber,
    OrderDate,
    DueDate,
    ShipDate
from Sales_OLTP.Sales.SalesOrderDetail AS D
left join Sales_OLTP.Sales.SalesOrderHeader AS H ON D.SalesOrderID=H.SalesOrderID
left join Sales_OLTP.Sales.Customer  AS C ON C.CustomerID = H.CustomerID
go

--------------------------------------------

insert into Sales_DW.dbo.Dim_CreditCard
(
	CreditCardID,
	CardType,
	CardNumber,
	ExpMonth,
	ExpYear
)
SELECT 
	CreditCardID,
	CardType,
	CardNumber,
	ExpMonth,
	ExpYear
FROM Sales_OLTP.Sales.CreditCard
go

------------------------------------------------

INSERT INTO Sales_DW.dbo.Dim_Date
(
	DateKey,
	FullDate,
	Day,
	Month,
	MonthName,
	CalendarQuarter,
	CalendarYear,
	DayOfWeek,
	DayNameOfWeek,
	WeekOfYear,
	IsWeekend
)
SELECT DISTINCT 
    CONVERT(INT, FORMAT(OrderDate, 'yyyyMMdd')) AS DateKey,   
    OrderDate AS FullDate,                                     
    DAY(OrderDate) AS Day,                                    
    MONTH(OrderDate) AS Month,                                 
    DATENAME(MONTH, OrderDate) AS MonthName,                  
    DATEPART(QUARTER, OrderDate) AS CalendarQuarter,           
    YEAR(OrderDate) AS CalendarYear,                           
    DATEPART(WEEKDAY, OrderDate) AS DayOfWeek,    
    DATENAME(WEEKDAY, OrderDate) AS DayNameOfWeek,           
    DATEPART(WEEK, OrderDate) AS WeekOfYear,               
    CASE 
        WHEN DATEPART(WEEKDAY, OrderDate) IN (1, 7) THEN 1   
        ELSE 0
    END AS IsWeekend
FROM Sales_OLTP.Sales.SalesOrderHeader;    
go

------------------------------------------------

insert into Sales_DW.dbo.Dim_Territory
(
	TerritoryID,
	Name,
	CountryRegionCode,
	"Group",
	SalesYTD,
	SalesLastYear,
	CostYTD,
	CostLastYear
)
SELECT
	TerritoryID,
	Name,
	CountryRegionCode,
	"Group",
	SalesYTD,
	SalesLastYear,
	CostYTD,
	CostLastYear
FROM Sales_OLTP.Sales.SalesTerritory
go

------------------------------------------------

insert into Sales_DW.dbo.Dim_Offers
(
	SpecialOfferID,
	ProductID,
	Description,
	DiscountPct,
	Type,
	Category,
	MinQty,
	MaxQty
)
SELECT 
	p.SpecialOfferID,
	P.ProductID,
	s.Description,
	s.DiscountPct,
	s.Type,
	s.Category,
	s.MinQty,
	MaxQty
from Sales_OLTP.Sales.SpecialOfferProduct as P
left join Sales_OLTP.Sales.SpecialOffer as s 
ON s.SpecialOfferID = p.SpecialOfferID
go

------------------------------------------------

insert into Sales_DW.dbo.ProductSubcategory
(
	ProductSubcategoryID,
	Name
)
SELECT 
	ProductSubcategoryID,
	Name
from Sales_OLTP.Production.ProductSubcategory
go

------------------------------------------------

insert into Sales_DW.dbo.Dim_Product_Photos
(
	ProductID,
	product_PhotoID,
	Small_image,
	Small_image_name,
	Large_image,
	Large_image_name
)
SELECT 
	ProductID,
	pp.ProductPhotoID,
	ThumbNailPhoto as Small_image,
	ThumbnailPhotoFileName as Small_image_name,
	LargePhoto as Large_image,
	LargePhotoFileName as Large_image_name
From Sales_OLTP.Production.ProductProductPhoto as PP
left join Sales_OLTP.Production.ProductPhoto as P
ON p.ProductPhotoID = pp.ProductPhotoID
Order by ProductID
go

------------------------------------------------

insert into Sales_DW.dbo.Dim_currency
(
	CurrencyRateID,
	From_Currency,
	To_Currency,
	AverageRate,
	EndOfDayRate
)
Select
	CurrencyRateID,
	f.Name as From_Currency,
	C.Name as To_Currency,
	AverageRate,
	EndOfDayRate
FROM Sales_OLTP.Sales.CurrencyRate as R
left join Sales_OLTP.Sales.Currency as C
ON c.CurrencyCode = R.ToCurrencyCode
left join Sales_OLTP.Sales.Currency as f
ON f.CurrencyCode = R.FromCurrencyCode
go

------------------------------------------------

insert into Sales_DW.dbo.Dim_Store
(
	storeId,
	store_name
)
Select
	BusinessEntityID as storeId,
	Name as store_name
from Sales_OLTP.Sales.store
go

------------------------------------------------

insert into Sales_DW.dbo.Dim_ShipMethods
(
	ShipMethodID,
	ShipMethod,
	ShipBase,
	ShipRate
)
Select
	ShipMethodID,
	Name as ShipMethod,
	ShipBase,
	ShipRate
From Sales_OLTP.Purchasing.ShipMethod
go

INSERT INTO Sales_DW.dbo.Dim_Statuses (StatusID, [Status])
SELECT 1, 'In process' 
UNION ALL
SELECT 2, 'Approved'
UNION ALL
SELECT 3, 'Backordered'
UNION ALL
SELECT 4, 'Rejected'
UNION ALL
SELECT 5, 'Shipped'
UNION ALL
SELECT 6, 'Cancelled';
go
-----------------------------------------------
Alter Table Sales_DW.dbo.FactSales
ADD CONSTRAINT FK_Dim_status Foreign Key(StatusID)
References Sales_DW.dbo.Dim_Statuses(StatusID)

Alter Table Sales_DW.dbo.FactSales
ADD CONSTRAINT FK_Dim_Product Foreign Key(ProductID)
References Sales_DW.dbo.Dim_Product(ProductID)

Alter Table Sales_DW.dbo.FactSales
ADD CONSTRAINT FK_Dim_Credit Foreign Key(CreditCardID)
References Sales_DW.dbo.Dim_CreditCard(CreditCardID)

Alter Table Sales_DW.dbo.FactSales
ADD CONSTRAINT FK_Dim_Currency Foreign Key(CurrencyID)
References Sales_DW.dbo.Dim_currency(CurrencyRateID)

Alter Table Sales_DW.dbo.FactSales
ADD CONSTRAINT FK_Dim_Territory Foreign Key(TerritoryID)
References Sales_DW.dbo.Dim_Territory(TerritoryID)

Alter Table Sales_DW.dbo.FactSales
ADD CONSTRAINT FK_Dim_Store Foreign Key(StoreID)
References Sales_DW.dbo.Dim_Store(StoreID)

Alter Table Sales_DW.dbo.FactSales
ADD CONSTRAINT FK_Dim_ship Foreign Key(shipMethodID)
References Sales_DW.dbo.Dim_ShipMethods(ShipMethodID)

Alter Table Sales_DW.dbo.Dim_Product
ADD CONSTRAINT FK_Dim_subProduct Foreign Key(ProductSubcategoryID)
References Sales_DW.dbo.ProductSubcategory(ProductSubcategoryID)

Alter Table Sales_DW.dbo.Dim_Product_Photos
ADD CONSTRAINT FK_Dim_Product_image Foreign Key(ProductID)
References Sales_DW.dbo.Dim_Product(ProductID)

Alter Table Sales_DW.dbo.FactSales
ADD CONSTRAINT FK_Dim_Person Foreign Key(SalesPersonID)
References Sales_DW.dbo.Dim_person(SalesPersonID)
go

--------------------------indexs-------------------------------------

CREATE NONCLUSTERED INDEX IX_FactSales_SalesOrderID ON Sales_DW.dbo.FactSales(SalesOrderID);
GO
CREATE NONCLUSTERED INDEX IX_FactSales_SalesPersonID ON Sales_DW.dbo.FactSales(SalesPersonID);
GO
CREATE NONCLUSTERED INDEX IX_FactSales_StatusID ON Sales_DW.dbo.FactSales(StatusID);
GO
CREATE NONCLUSTERED INDEX IX_FactSales_ProductID ON Sales_DW.dbo.FactSales(ProductID);
GO
CREATE NONCLUSTERED INDEX IX_FactSales_StoreID ON Sales_DW.dbo.FactSales(StoreID);
GO
CREATE NONCLUSTERED INDEX IX_FactSales_shipMethodID ON Sales_DW.dbo.FactSales(shipMethodID);
GO
CREATE NONCLUSTERED INDEX IX_FactSales_CustomerID ON Sales_DW.dbo.FactSales(CustomerID);
GO
CREATE NONCLUSTERED INDEX IX_FactSales_CurrencyID ON Sales_DW.dbo.FactSales(CurrencyID);
GO
CREATE NONCLUSTERED INDEX IX_FactSales_PersonID ON Sales_DW.dbo.FactSales(PersonID);
GO
CREATE NONCLUSTERED INDEX IX_FactSales_TerritoryID ON Sales_DW.dbo.FactSales(TerritoryID);
GO
CREATE NONCLUSTERED INDEX IX_FactSales_CreditCardID ON Sales_DW.dbo.FactSales(CreditCardID);
GO
CREATE NONCLUSTERED INDEX IX_FactSales_SpecialOfferID ON Sales_DW.dbo.FactSales(SpecialOfferID);
GO
CREATE NONCLUSTERED INDEX IX_FactSales_OrderDateKey ON Sales_DW.dbo.FactSales(OrderDateKey);
GO
