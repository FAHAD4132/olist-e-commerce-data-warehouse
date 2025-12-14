/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'Bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'Bronze' Tables
===============================================================================
*/

IF OBJECT_ID ('Bronze.crm_customers', 'U') IS NOT NULL
	DROP TABLE Bronze.crm_customers;
GO
  
CREATE TABLE Bronze.crm_customers (
	CustomerID	  INT,
	FirstName	  VARCHAR(50),
	MiddleInitial VARCHAR(5),
	LastName	  VARCHAR(50),
	CityID		  INT,
	Addres		  VARCHAR(100)
);
GO
  
IF OBJECT_ID ('Bronze.mdm_cities', 'U') IS NOT NULL
	DROP TABLE Bronze.mdm_cities;
GO
  
CREATE TABLE Bronze.mdm_cities (
	CityID	  INT,
	CityName  VARCHAR(50),
	Zipcode	  VARCHAR(10),
	CountryID INT
);
GO
  
IF OBJECT_ID ('Bronze.mdm_countries', 'U') IS NOT NULL
	DROP TABLE Bronze.mdm_countries;
GO
  
CREATE TABLE Bronze.mdm_countries (
	CountryID   INT,
	CountryName VARCHAR(50),
	CountryCode VARCHAR(10)
);
GO

IF OBJECT_ID ('Bronze.mdm_zipcodes', 'U') IS NOT NULL
	DROP TABLE Bronze.mdm_zipcodes;
GO
  
CREATE TABLE Bronze.mdm_zipcodes (
	Zipcode   VARCHAR(10),
	Latitude  DECIMAL(10,4),
	Longitude DECIMAL(10,4),
	City      VARCHAR(50),
	States	  VARCHAR(50),
	County	  VARCHAR(50)
);
GO

IF OBJECT_ID ('Bronze.erp_categories', 'U') IS NOT NULL
	DROP TABLE Bronze.erp_categories;
GO
  
CREATE TABLE Bronze.erp_categories (
	CategoryID   INT,
	CategoryName VARCHAR(50)
);
GO

IF OBJECT_ID ('Bronze.erp_employees', 'U') IS NOT NULL
	DROP TABLE Bronze.erp_employees;
GO
  
CREATE TABLE Bronze.erp_employees (
	EmployeeID	  INT,
	FirstName	  VARCHAR(50),
	MiddleInitial VARCHAR(5),
	LastName	  VARCHAR(50),
	BirthDate	  DATETIME,
	Gender		  VARCHAR(5),
	CityID		  INT,
	HireDate	  DATETIME
);
GO

IF OBJECT_ID ('Bronze.erp_products', 'U') IS NOT NULL
	DROP TABLE Bronze.erp_products;
GO
  
CREATE TABLE Bronze.erp_products (
	ProductID	 INT,
	ProductName	 VARCHAR(100),
	Price		 DECIMAL(10,4),
	CategoryID	 INT,
	Class		 VARCHAR(15),
	ModifyDate	 DATETIME2(3),
	Resistant	 VARCHAR(20),
	IsAllergic	 VARCHAR(20),
	VitalityDays DECIMAL(10, 1)
);
GO

IF OBJECT_ID ('Bronze.erp_sales', 'U') IS NOT NULL
	DROP TABLE Bronze.erp_sales;
GO
  
CREATE TABLE Bronze.erp_sales (
	SalesID			  INT,
	SalesPersonID	  INT,
	CustomerID		  INT,
	ProductID		  INT,
	Quantity		  INT,
	Discount		  DECIMAL(10,2),
	TotalPrice		  DECIMAL(10,2),
	SalesDate		  DATETIME2(3),
	TransactionNumber VARCHAR(30)
);
GO
