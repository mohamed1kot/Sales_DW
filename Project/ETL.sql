USE [master];
GO

-----------------SCD------------------------

IF EXISTS(SELECT 1 FROM Sales_DW.dbo.Dim_Product)
BEGIN
    SELECT
        ol.ProductID,
        ol.Name,
        ol.ProductNumber,
        ol.Color,
        ol.SafetyStockLevel,
        ol.ReorderPoint,
        ol.StandardCost,
        ol.ListPrice,
        ol.Size,
        ol.SizeUnitMeasureCode,
        ol.Weight,
        ol.WeightUnitMeasureCode,
        ol.DaysToManufacture,
        ol.ProductSubcategoryID,
        ol.ProductModelID
    INTO #temp_Products
    FROM Sales_OLTP.Production.Product ol
    left JOIN Sales_DW.dbo.Dim_Product dp
        ON ol.ProductID = dp.ProductID
    WHERE
        (ol.Name != dp.Name OR
        ol.ProductNumber != dp.ProductNumber OR
        ol.Color != dp.Color OR
        ol.SafetyStockLevel != dp.SafetyStockLevel OR
        ol.ReorderPoint != dp.ReorderPoint OR
        ol.StandardCost != dp.StandardCost OR
        ol.ListPrice != dp.ListPrice OR
        ol.Size != dp.Size OR
        ol.SizeUnitMeasureCode != dp.SizeUnitMeasureCode OR
        ol.Weight != dp.Weight OR
        ol.WeightUnitMeasureCode != dp.WeightUnitMeasureCode OR
        ol.DaysToManufacture != dp.DaysToManufacture OR
        ol.ProductSubcategoryID != dp.ProductSubcategoryID OR
        ol.ProductModelID != dp.ProductModelID)
        AND dp.IsCurrent = 1;

    UPDATE Sales_DW.dbo.Dim_Product
    SET
        EndDate = GETDATE(),
        IsCurrent = 0
    WHERE
        ProductID IN (SELECT ProductID FROM #temp_Products)
        AND IsCurrent = 1;

    INSERT INTO Sales_DW.dbo.Dim_Product
    (
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
        ol.Name,
        ol.ProductNumber,
        ol.Color,
        ol.SafetyStockLevel,
        ol.ReorderPoint,
        ol.StandardCost,
        ol.ListPrice,
        ol.Size,
        ol.SizeUnitMeasureCode,
        ol.Weight,
        ol.WeightUnitMeasureCode,
        ol.DaysToManufacture,
        ol.ProductSubcategoryID,
        ol.ProductModelID,
        GETDATE() AS StartDate,
        NULL AS EndDate,
        1 AS IsCurrent
    FROM #temp_Products ol

    -- Clean temporary table
    DROP TABLE #temp_Products;

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
        ol.ProductID,
        ol.Name,
        ol.ProductNumber,
        ol.Color,
        ol.SafetyStockLevel,
        ol.ReorderPoint,
        ol.StandardCost,
        ol.ListPrice,
        ol.Size,
        ol.SizeUnitMeasureCode,
        ol.Weight,
        ol.WeightUnitMeasureCode,
        ol.DaysToManufacture,
        ol.ProductSubcategoryID,
        ol.ProductModelID,
        GETDATE() AS StartDate,
        NULL AS EndDate,
        1 AS IsCurrent
    FROM Sales_OLTP.Production.Product ol
    WHERE NOT EXISTS (SELECT 1 FROM Sales_DW.dbo.Dim_Product dp WHERE dp.ProductID = ol.ProductID);
	Set IDENTITY_INSERT Sales_DW.dbo.Dim_Product OFF;
END
GO

-- ****************************************
-------------------ETL---------------------
-- ****************************************

IF EXISTS(SELECT 1 FROM Sales_DW.dbo.Dim_person)
BEGIN
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
		ol.BusinessEntityID AS SalesPersonID,
		ol.Title,
		CONCAT(FirstName, ' ', MiddleName + '. ', LastName) AS FullName,
		ol.JobTitle,
		ol.PhoneNumber,
		ol.PhoneNumberType,
		ol.EmailAddress,
		ol.AddressLine1,
		ol.City,
		ol.StateProvinceName,
		ol.PostalCode,
		ol.CountryRegionName,
		ol.TerritoryName
	FROM Sales_OLTP.Sales.vSalesPerson ol
	left join Sales_DW.dbo.Dim_person db ON ol.BusinessEntityID=db.SalesPersonID
	Where NOT EXISTS (SELECT 1 FROM Sales_DW.dbo.Dim_person dp WHERE dp.SalesPersonID = ol.BusinessEntityID);
END
go

--------------------------------------

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

IF EXISTS(SELECT 1 FROM Sales_DW.dbo.Dim_CreditCard)
BEGIN
	insert into Sales_DW.dbo.Dim_CreditCard
	(
		CreditCardID,
		CardType,
		CardNumber,
		ExpMonth,
		ExpYear
	)
	SELECT 
		ol.CreditCardID,
		ol.CardType,
		ol.CardNumber,
		ol.ExpMonth,
		ol.ExpYear
	FROM Sales_OLTP.Sales.CreditCard as ol
	left join Sales_DW.dbo.Dim_CreditCard as db ON db.CreditCardID=ol.CreditCardID
	WHERE NOT EXISTS(select 1 from Sales_DW.dbo.Dim_CreditCard where db.CreditCardID=ol.CreditCardID)
END
go

------------------------------------------------

IF NOT EXISTS(SELECT 1 FROM Sales_DW.dbo.Dim_Date)
BEGIN
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
	FROM Sales_OLTP.Sales.SalesOrderHeader 
END
go

------------------------------------------------

IF EXISTS(SELECT 1 FROM Sales_DW.dbo.Dim_Territory)
BEGIN
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
		ol.TerritoryID,
		ol.Name,
		ol.CountryRegionCode,
		ol."Group",
		ol.SalesYTD,
		ol.SalesLastYear,
		ol.CostYTD,
		ol.CostLastYear
	FROM Sales_OLTP.Sales.SalesTerritory ol
	left join Sales_DW.dbo.Dim_Territory db ON db.TerritoryID=ol.TerritoryID
	where NOT EXISTS(select 1 from Sales_DW.dbo.Dim_Territory where db.TerritoryID=ol.TerritoryID)
END
go

------------------------------------------------

IF EXISTS(SELECT 1 FROM Sales_DW.dbo.Dim_Offers)
BEGIN
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
		s.MaxQty
	from Sales_OLTP.Sales.SpecialOfferProduct as P
	left join Sales_OLTP.Sales.SpecialOffer as s 
	ON s.SpecialOfferID = p.SpecialOfferID
	left join Sales_DW.dbo.Dim_Offers db ON (db.SpecialOfferID=p.SpecialOfferID AND db.ProductID=p.ProductID)
	where NOT EXISTS(select 1 from Sales_DW.dbo.Dim_Offers where (db.SpecialOfferID=p.SpecialOfferID AND db.ProductID=p.ProductID))
END
go

------------------------------------------------

IF EXISTS(SELECT 1 FROM Sales_DW.dbo.ProductSubcategory)
BEGIN
	insert into Sales_DW.dbo.ProductSubcategory
	(
		ProductSubcategoryID,
		Name
	)
	SELECT 
		ol.ProductSubcategoryID,
		ol.Name
	from Sales_OLTP.Production.ProductSubcategory ol
	left join Sales_DW.dbo.ProductSubcategory db ON db.ProductSubcategoryID=ol.ProductSubcategoryID
	Where NOT EXISTS(Select 1 from Sales_DW.dbo.ProductSubcategory where db.ProductSubcategoryID=ol.ProductSubcategoryID)
END
go

------------------------------------------------

IF EXISTS(SELECT 1 FROM Sales_DW.dbo.Dim_Product_Photos)
BEGIN
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
		pp.ProductID,
		pp.ProductPhotoID,
		ThumbNailPhoto as Small_image,
		ThumbnailPhotoFileName as Small_image_name,
		LargePhoto as Large_image,
		LargePhotoFileName as Large_image_name
	From Sales_OLTP.Production.ProductProductPhoto as PP
	left join Sales_OLTP.Production.ProductPhoto as P
	ON p.ProductPhotoID = pp.ProductPhotoID
	left join Sales_DW.dbo.Dim_Product_Photos db ON (db.ProductID=pp.ProductID AND db.product_PhotoID=pp.ProductPhotoID)
	where NOT EXISTS(select 1 from Sales_DW.dbo.Dim_Product_Photos where (db.ProductID=pp.ProductID AND db.product_PhotoID=pp.ProductPhotoID))
	Order by ProductID
END
go

------------------------------------------------

IF EXISTS(SELECT 1 FROM Sales_DW.dbo.Dim_currency)
BEGIN
	insert into Sales_DW.dbo.Dim_currency
	(
		CurrencyRateID,
		From_Currency,
		To_Currency,
		AverageRate,
		EndOfDayRate
	)
	Select
		R.CurrencyRateID,
		f.Name as From_Currency,
		C.Name as To_Currency,
		R.AverageRate,
		R.EndOfDayRate
	FROM Sales_OLTP.Sales.CurrencyRate as R
	left join Sales_OLTP.Sales.Currency as C
	ON c.CurrencyCode = R.ToCurrencyCode
	left join Sales_OLTP.Sales.Currency as f
	ON f.CurrencyCode = R.FromCurrencyCode
	left join Sales_DW.dbo.Dim_currency db ON db.CurrencyRateID=R.CurrencyRateID
	where NOT EXISTS(select 1 from Sales_DW.dbo.Dim_currency where db.CurrencyRateID=R.CurrencyRateID)
END
go

------------------------------------------------

IF EXISTS(SELECT 1 FROM Sales_DW.dbo.Dim_Store)
BEGIN
	insert into Sales_DW.dbo.Dim_Store
	(
		storeId,
		store_name
	)
	Select
		BusinessEntityID as storeId,
		Name as store_name
	from Sales_OLTP.Sales.store ol
	left join Sales_DW.dbo.Dim_Store db ON db.storeId=ol.BusinessEntityID
	where NOT EXISTS(select 1 from Sales_DW.dbo.Dim_Store where db.storeId=ol.BusinessEntityID)
END
go

------------------------------------------------

IF EXISTS(SELECT 1 FROM Sales_DW.dbo.Dim_ShipMethods)
BEGIN
	insert into Sales_DW.dbo.Dim_ShipMethods
	(
		ShipMethodID,
		ShipMethod,
		ShipBase,
		ShipRate
	)
	Select
		ol.ShipMethodID,
		ol.Name as ShipMethod,
		ol.ShipBase,
		ol.ShipRate
	From Sales_OLTP.Purchasing.ShipMethod ol
	left join Sales_DW.dbo.Dim_ShipMethods db ON db.ShipMethodID=ol.ShipMethodID
	where NOT EXISTS(select 1 from Sales_DW.dbo.Dim_ShipMethods where db.ShipMethodID=ol.ShipMethodID)
END
go