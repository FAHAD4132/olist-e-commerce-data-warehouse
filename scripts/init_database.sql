/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'Fecom_Inc_Data_Warehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'Bronze', 'Silver', and 'Gold'.
	
WARNING:
    Running this script will drop the entire 'Fecom_Inc_Data_Warehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'Fecom_Inc_Data_Warehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Fecom_Inc_Data_Warehouse')
BEGIN
    ALTER DATABASE Fecom_Inc_Data_Warehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Fecom_Inc_Data_Warehouse;
END;
GO

-- Create the 'Fecom_Inc_Data_Warehouse' database
CREATE DATABASE Fecom_Inc_Data_Warehouse;
GO

USE Fecom_Inc_Data_Warehouse;
GO

-- Create Schemas
CREATE SCHEMA Bronze;
GO

CREATE SCHEMA Silver;
GO

CREATE SCHEMA Gold;
GO
