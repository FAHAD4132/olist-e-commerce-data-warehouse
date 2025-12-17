/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: Gold.dim_customers
-- =============================================================================
IF OBJECT_ID('Gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW Gold.dim_customers;
GO

CREATE VIEW Gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY c.CustomerID) AS CustomerKey,
	c.CustomerID,
	c.FirstName,
	c.MiddleInitial,
	c.LastName,
	co.CountryName,
	co.CountryCode,
	ci.Region,
	ci.DivisionRegion,
	ci.States,
	ci.StatesCode,
	ci.CityName,
	ci.County,
	c.Addres,
	c.StreetNumber,
	c.DirectionalPrefix,
	c.StreetName,
	c.StreetType,
	ci.Zipcode,
	ci.Latitude,
	ci.Longitude
FROM Silver.crm_customers c
LEFT JOIN Silver.mdm_cities ci
ON c.CityID = ci.CityID
LEFT JOIN Silver.mdm_countries co
ON ci.CountryID = co.CountryID;
GO

-- =============================================================================
-- Create Dimension: Gold.dim_products
-- =============================================================================
IF OBJECT_ID('Gold.dim_products', 'V') IS NOT NULL
    DROP VIEW Gold.dim_products;
GO

CREATE VIEW Gold.dim_products AS
SELECT
	ROW_NUMBER() OVER (ORDER BY p.ProductID) AS ProductKey,
	p.ProductID,
	c.CategoryName,
	p.ProductName,
	p.Class,
	p.Resistant,
	p.IsAllergic,
	p.ModifyDate,
	p.VitalityDays,
	p.Price
FROM Silver.erp_products p
LEFT JOIN Silver.erp_categories c
ON p.CategoryID = c.CategoryID;
GO

-- =============================================================================
-- Create Dimension: Gold.dim_employees
-- =============================================================================
IF OBJECT_ID('Gold.dim_employees', 'V') IS NOT NULL
    DROP VIEW Gold.dim_employees;
GO

CREATE VIEW Gold.dim_employees AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY e.EmployeeID) AS EmployeeKey,
	e.EmployeeID,
	e.FirstName,
	e.MiddleInitial,
	e.LastName,
	e.Gender,
	e.EmploymentStatusCheck,
	co.CountryName,
	co.CountryCode,
	ci.Region,
	ci.DivisionRegion,
	ci.States,
	ci.StatesCode,
	ci.CityName,
	ci.County,
	e.BirthDate,
	e.HireDate,
	e.CurrentAge,
	e.YearsOfService,
	ci.Zipcode,
	ci.Latitude,
	ci.Longitude
FROM Silver.erp_employees e
LEFT JOIN Silver.mdm_cities ci
ON e.CityID = ci.CityID
LEFT JOIN Silver.mdm_countries co
ON ci.CountryID = co.CountryID;
GO

-- =============================================================================
-- Create Fact Table: Gold.fact_sales
-- =============================================================================
IF OBJECT_ID('Gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW Gold.fact_sales;
GO

CREATE VIEW Gold.fact_sales AS
SELECT 
	s.SalesID,
	e.EmployeeKey,
	c.CustomerKey,
	p.ProductKey,
	s.TransactionNumber,
	s.IsDateEstimated,
	s.SalesDate,
	s.Quantity,
	s.Discount,
	s.TotalPrice
FROM Silver.erp_sales s
LEFT JOIN Gold.dim_employees e
ON s.SalesPersonID = e.EmployeeID
LEFT JOIN Gold.dim_customers c
ON s.CustomerID = c.CustomerID
LEFT JOIN Gold.dim_products p
ON s.ProductID = p.ProductID;
GO
