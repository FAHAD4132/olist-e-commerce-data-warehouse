/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'Grocery_Sales_Data_Warehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'Bronze', 'Silver', and 'Gold'.
	
WARNING:
    Running this script will drop the entire 'Grocery_Sales_Data_Warehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'Grocery_Sales_Data_Warehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Grocery_Sales_Data_Warehouse')
BEGIN
    ALTER DATABASE Grocery_Sales_Data_Warehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Grocery_Sales_Data_Warehouse;
END;
GO

-- Create the 'Grocery_Sales_Data_Warehouse' database
CREATE DATABASE Grocery_Sales_Data_Warehouse;
GO

USE Grocery_Sales_Data_Warehouse;
GO

-- Create Schemas
CREATE SCHEMA Bronze;
GO

CREATE SCHEMA Silver;
GO

CREATE SCHEMA Gold;
GO
