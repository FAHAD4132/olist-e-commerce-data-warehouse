/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'Silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'Silver' Tables
===============================================================================
*/

IF OBJECT_ID ('Silver.crm_customers', 'U') IS NOT NULL
	DROP TABLE Silver.crm_customers;
GO
  
CREATE TABLE Silver.crm_customers (
	CustomerID		  INT,
	FirstName		  VARCHAR(50),
	MiddleInitial	  VARCHAR(5),
	LastName		  VARCHAR(50),
	CityID			  INT,
	Addres			  VARCHAR(100),
	StreetNumber	  INT,
	DirectionalPrefix VARCHAR(10),
	StreetName		  VARCHAR(50),
	StreetType		  VARCHAR(15),
	DWHCreateDate	  DATETIME2 DEFAULT GETDATE()
);
GO
  
IF OBJECT_ID ('Silver.mdm_cities', 'U') IS NOT NULL
	DROP TABLE Silver.mdm_cities;
GO
  
CREATE TABLE Silver.mdm_cities (
	CityID		   INT,
	CityName	   VARCHAR(50),
	Zipcode		   VARCHAR(10),
	CountryID	   INT,
	Region		   VARCHAR(50),
	DivisionRegion VARCHAR(50),
	States		   VARCHAR(50),
	StatesCode	   VARCHAR(10),
    County		   VARCHAR(50),
    Latitude	   FLOAT,
    Longitude	   FLOAT,
	DWHCreateDate  DATETIME2 DEFAULT GETDATE()
);
GO
  
IF OBJECT_ID ('Silver.mdm_countries', 'U') IS NOT NULL
	DROP TABLE Silver.mdm_countries;
GO
  
CREATE TABLE Silver.mdm_countries (
	CountryID     INT,
	CountryName   VARCHAR(50),
	CountryCode	  VARCHAR(10),
	DWHCreateDate DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID ('Silver.erp_categories', 'U') IS NOT NULL
	DROP TABLE Silver.erp_categories;
GO
  
CREATE TABLE Silver.erp_categories (
	CategoryID    INT,
	CategoryName  VARCHAR(50),
	DWHCreateDate DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID ('Silver.erp_employees', 'U') IS NOT NULL
	DROP TABLE Silver.erp_employees;
GO
  
CREATE TABLE Silver.erp_employees (
	EmployeeID			  INT,
	FirstName			  VARCHAR(50),
	MiddleInitial		  VARCHAR(5),
	LastName			  VARCHAR(50),
	BirthDate			  DATETIME,
	CurrentAge			  INT,
	Gender				  VARCHAR(15),
	CityID				  INT,
	HireDate			  DATETIME,
	YearsOfService		  INT,
    EmploymentStatusCheck VARCHAR(50),
	DWHCreateDate		  DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID ('Silver.erp_products', 'U') IS NOT NULL
	DROP TABLE Silver.erp_products;
GO
  
CREATE TABLE Silver.erp_products (
	ProductID	  INT,
	ProductName	  VARCHAR(100),
	Price		  DECIMAL(10,4),
	CategoryID	  INT,
	Class		  VARCHAR(15),
	ModifyDate    DATETIME2(3),
	Resistant 	  VARCHAR(20),
	IsAllergic	  VARCHAR(20),
	VitalityDays  DECIMAL(10, 1),
	DWHCreateDate DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID ('Silver.erp_sales', 'U') IS NOT NULL
	DROP TABLE Silver.erp_sales;
GO
  
CREATE TABLE Silver.erp_sales (
	SalesID			  INT,
	SalesPersonID	  INT,
	CustomerID		  INT,
	ProductID		  INT,
	Quantity		  INT,
	Discount		  DECIMAL(10,2),
	TotalPrice		  DECIMAL(10,2),
	SalesDate		  DATETIME2(3),
	TransactionNumber VARCHAR(30),
	IsDateEstimated   VARCHAR(5),
	DWHCreateDate	  DATETIME2 DEFAULT GETDATE()
);
GO
