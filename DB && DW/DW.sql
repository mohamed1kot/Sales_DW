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
	SalesOrderNumber nvarchar(20) NOT NULL,
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
	CustomerPONumber nvarchar(25) NULL,
	OrderDate datetime NULL,
	DueDate datetime NULL,
	ShipDate datetime NULL
) ON [PRIMARY];
GO

------------Dim_CreditCard-------------

CREATE Table Sales_DW.dbo.Dim_CreditCard
(
	CreditCardID int NOT NULL PRIMARY KEY,
	CardType nvarchar(20) NOT NULL,
	CardNumber nvarchar(20) NOT NULL,
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
    MonthName nvarchar(20) NOT NULL,   
    CalendarQuarter TINYINT NOT NULL,   
    CalendarYear SMALLINT NOT NULL,    
    DayOfWeek TINYINT NOT NULL,         
    DayNameOfWeek nvarchar(20) NOT NULL, 
    WeekOfYear TINYINT NOT NULL,        
    IsWeekend BIT NOT NULL             
);
go

------------Dim_Territory-------------

CREATE Table Sales_DW.dbo.Dim_Territory
(
	TerritoryID int not null Primary key,
	Name nvarchar(20) NOT NULL,
	CountryRegionCode nvarchar(5) NOT NULL,
	"Group" nvarchar(20) NOT NULL,
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
	Description nvarchar(50) NOT NULL,
	DiscountPct float NOT NULL,
	Type nvarchar(50) NOT NULL,
	Category nvarchar(50) NOT NULL,
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
	Name nvarchar(50) NOT NULL,
	ProductNumber nvarchar(10) NOT NULL,
	Color nvarchar(30),
	SafetyStockLevel int NOT NULL,
	ReorderPoint int NOT NULL,
	StandardCost Float NOT NULL,
	ListPrice Float NOT NULL,
	Size nvarchar(5),
	SizeUnitMeasureCode nvarchar(5),
	Weight float,
	WeightUnitMeasureCode nvarchar(5),
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
	Name nvarchar(20) NOT NULL
)
Go

---------------Dim_Product_Photos---------------------

Create Table Sales_DW.dbo.Dim_Product_Photos
(
	ProductID int NOT NULL,
	product_PhotoID int NOT NULL,
	Small_image Varbinary(MAX) NULL,
	Small_image_name nvarchar(50) NOT NULL,
	Large_image Varbinary(MAX) NULL,
	Large_image_name nvarchar(50) NOT NULL,

	Primary key(ProductID,product_PhotoID)
)
go

--------------Dim_currency-----------------------

Create Table Sales_DW.dbo.Dim_currency
(
	CurrencyRateID int not null Primary key,
	From_Currency nvarchar(50) NOT NULL,
	To_Currency nvarchar(50) NOT NULL,
	AverageRate Float NOT NULL,
	EndOfDayRate Float NOT NULL
)
go

-----------Dim_Store--------------

create Table Sales_DW.dbo.Dim_Store
(
	storeId int NOT NULL Primary Key,
	store_name nvarchar(50) NOT NULL
)
go

-------------Dim_ShipMethods-------------------

Create table Sales_DW.dbo.Dim_ShipMethods
(
	ShipMethodID int NOT NULL Primary Key,
	ShipMethod nvarchar(50) NOT NULL,
	ShipBase Float NOT NULL,
	ShipRate Float NOT NULL
)
go

-----------------Dim_person-----------------

Create table Sales_DW.dbo.Dim_person
(
	SalesPersonID INT NOT NULL Primary Key,
	Title nvarchar(20),
	FullName nvarchar(50) NOT NULL,
	JobTitle nvarchar(50) NOT NULL,
	PhoneNumber nvarchar(50) NOT NULL,
	PhoneNumberType nvarchar(50) NOT NULL,
	EmailAddress nvarchar(50) NOT NULL,
	AddressLine1 nvarchar(50) NOT NULL,
	City nvarchar(50) NOT NULL,
	StateProvinceName nvarchar(50) NOT NULL,
	PostalCode nvarchar(50) NOT NULL,
	CountryRegionName nvarchar(50) NOT NULL,
	TerritoryName nvarchar(50)
)
go
----------------Dim_status-----------------

Create Table Sales_DW.dbo.Dim_Statuses
(
	StatusID INT NOT NULL Primary Key,
	Status nvarchar(20) NOT NULL
)
go


-----------------initial_inserts------------------------

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
FROM AdventureWorks2016.Production.Product;
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
FROM AdventureWorks2016.Sales.vSalesPerson
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
from AdventureWorks2016.Sales.SalesOrderDetail AS D
left join AdventureWorks2016.Sales.SalesOrderHeader AS H ON D.SalesOrderID=H.SalesOrderID
left join AdventureWorks2016.Sales.Customer  AS C ON C.CustomerID = H.CustomerID
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
FROM AdventureWorks2016.Sales.CreditCard
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
FROM AdventureWorks2016.Sales.SalesOrderHeader;    
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
FROM AdventureWorks2016.Sales.SalesTerritory
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
from AdventureWorks2016.Sales.SpecialOfferProduct as P
left join AdventureWorks2016.Sales.SpecialOffer as s 
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
from AdventureWorks2016.Production.ProductSubcategory
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
From AdventureWorks2016.Production.ProductProductPhoto as PP
left join AdventureWorks2016.Production.ProductPhoto as P
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
FROM AdventureWorks2016.Sales.CurrencyRate as R
left join AdventureWorks2016.Sales.Currency as C
ON c.CurrencyCode = R.ToCurrencyCode
left join AdventureWorks2016.Sales.Currency as f
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
from AdventureWorks2016.Sales.store
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
From AdventureWorks2016.Purchasing.ShipMethod
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
---------------- Foreign Keys -------------------------------


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
