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

IF OBJECT_ID ('Bronze.CRM_Fecom_Inc_Customer_List', 'U') IS NOT NULL
	DROP TABLE Bronze.CRM_Fecom_Inc_Customer_List;
GO
  
CREATE TABLE Bronze.CRM_Fecom_Inc_Customer_List (
	Customer_Trx_ID NVARCHAR(50), 
	Subscriber_ID NVARCHAR(50), 
	Subscribe_Date DATE, 
	First_Order_Date DATE, 
	Customer_Postal_Code NVARCHAR(20),
	Customer_City NVARCHAR(50),
	Customer_Country NVARCHAR(50),
	Customer_Country_Code NVARCHAR(5),
	Age INT,
	Gender NVARCHAR(10)
);
GO
  
IF OBJECT_ID ('Bronze.CRM_Fecom_Inc_Geolocations', 'U') IS NOT NULL
	DROP TABLE Bronze.CRM_Fecom_Inc_Geolocations;
GO
  
CREATE TABLE Bronze.CRM_Fecom_Inc_Geolocations (
	Geo_Postal_Code NVARCHAR(20), 
	Geo_Lat NVARCHAR(50), 
	Geo_Lon NVARCHAR(50), 
	Geolocation_City NVARCHAR(100), 
	Geo_Country NVARCHAR(100)
);
GO
  
IF OBJECT_ID ('Bronze.CRM_Fecom_Inc_Order_Reviews', 'U') IS NOT NULL
	DROP TABLE Bronze.CRM_Fecom_Inc_Order_Reviews;
GO
  
CREATE TABLE Bronze.CRM_Fecom_Inc_Order_Reviews (
	Review_ID NVARCHAR(50), 
	Order_ID NVARCHAR(50), 
	Review_Score INT, 
	Review_Comment_Title_En NVARCHAR(250), 
	Review_Comment_Message_En NVARCHAR(MAX),
	Review_Creation_Date DATETIME,
	Review_Answer_Timestamp DATETIME
);
GO

IF OBJECT_ID ('Bronze.ERP_Fecom_Inc_Order_Items', 'U') IS NOT NULL
	DROP TABLE Bronze.ERP_Fecom_Inc_Order_Items;
GO
  
CREATE TABLE Bronze.ERP_Fecom_Inc_Order_Items (
	Order_ID NVARCHAR(50), 
	Order_Item_ID INT, 
	Product_ID NVARCHAR(50), 
	Seller_ID NVARCHAR(50), 
	Shipping_Limit_Date DATETIME,
	Price DECIMAL(10,2),
	Freight_Value DECIMAL(10,2)
);
GO

IF OBJECT_ID ('Bronze.ERP_Fecom_Inc_Order_Payments', 'U') IS NOT NULL
	DROP TABLE Bronze.ERP_Fecom_Inc_Order_Payments;
GO
  
CREATE TABLE Bronze.ERP_Fecom_Inc_Order_Payments (
	Order_ID NVARCHAR(50), 
	Payment_Sequential INT, 
	Payment_Type NVARCHAR(50), 
	Payment_Installments INT, 
	Payment_Value DECIMAL(10,2)
);
GO

IF OBJECT_ID ('Bronze.ERP_Fecom_Inc_Orders', 'U') IS NOT NULL
	DROP TABLE Bronze.ERP_Fecom_Inc_Orders;
GO
  
CREATE TABLE Bronze.ERP_Fecom_Inc_Orders (
	Order_ID NVARCHAR(50), 
	Customer_Trx_ID NVARCHAR(50), 
	Order_Status NVARCHAR(20), 
	Order_Purchase_Timestamp DATETIME, 
	Order_Approved_At DATETIME,
	Order_Delivered_Carrier_Date DATETIME,
	Order_Delivered_Customer_Date DATETIME,
	Order_Estimated_Delivery_Date DATETIME
);
GO

IF OBJECT_ID ('Bronze.ERP_Fecom_Inc_Products', 'U') IS NOT NULL
	DROP TABLE Bronze.ERP_Fecom_Inc_Products;
GO
  
CREATE TABLE Bronze.ERP_Fecom_Inc_Products (
	Product_ID NVARCHAR(50), 
	Product_Category_Name NVARCHAR(50), 
	Product_Weight_Gr INT, 
	Product_Length_Cm INT, 
	Product_Height_Cm INT,
	Product_Width_Cm INT
);
GO

IF OBJECT_ID ('Bronze.ERP_Fecom_Inc_Sellers_List', 'U') IS NOT NULL
	DROP TABLE Bronze.ERP_Fecom_Inc_Sellers_List;
GO
  
CREATE TABLE Bronze.ERP_Fecom_Inc_Sellers_List (
	Seller_ID NVARCHAR(50), 
	Seller_Name NVARCHAR(50), 
	Seller_Postal_Code NVARCHAR(20), 
	Seller_City NVARCHAR(50), 
	Country_Code NVARCHAR(5),
	Seller_Country NVARCHAR(50)
);
GO
