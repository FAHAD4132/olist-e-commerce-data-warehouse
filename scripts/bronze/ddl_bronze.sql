/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

IF OBJECT_ID ('bronze.crm_customers', 'U') IS NOT NULL
	DROP TABLE bronze.crm_customers;
GO
  
CREATE TABLE bronze.crm_customers (
	customer_id NVARCHAR(50), 
	customer_unique_id NVARCHAR(50), 
	customer_zip_code_prefix NVARCHAR(50), 
	customer_city NVARCHAR(50), 
	customer_state NVARCHAR(50)
);
GO
  
IF OBJECT_ID ('bronze.crm_geolocation', 'U') IS NOT NULL
	DROP TABLE bronze.crm_geolocation;
GO
  
CREATE TABLE bronze.crm_geolocation (
	geolocation_zip_code_prefix NVARCHAR(50),
	geolocation_lat FLOAT,
	geolocation_lng FLOAT,
	geolocation_city NVARCHAR(50),
	geolocation_state NVARCHAR(50)
);
GO
  
IF OBJECT_ID ('bronze.crm_order_reviews', 'U') IS NOT NULL
	DROP TABLE bronze.crm_order_reviews;
GO
  
CREATE TABLE bronze.crm_order_reviews (
    review_id CHAR(32) NOT NULL,
    order_id CHAR(32) NOT NULL,
    review_score INT NULL,
    review_comment_title VARCHAR(255) NULL,
    review_comment_message VARCHAR(8000) NULL,
    review_creation_date DATETIME NULL,
    review_answer_timestamp DATETIME NULL
);
GO

IF OBJECT_ID ('bronze.erp_order_items', 'U') IS NOT NULL
	DROP TABLE bronze.erp_order_items;
GO
  
CREATE TABLE bronze.erp_order_items (
	order_id NVARCHAR(50),
	order_item_id INT,
	product_id NVARCHAR(50),
	seller_id NVARCHAR(50),
	shipping_limit_date DATETIME,
	price FLOAT,
	freight_value FLOAT
);
GO

IF OBJECT_ID ('bronze.erp_order_payments', 'U') IS NOT NULL
	DROP TABLE bronze.erp_order_payments;
GO
  
CREATE TABLE bronze.erp_order_payments (
	order_id NVARCHAR(50),
	payment_sequential INT,
	payment_type NVARCHAR(50),
	payment_installments INT,
	payment_value FLOAT
);
GO

IF OBJECT_ID ('bronze.erp_orders', 'U') IS NOT NULL
	DROP TABLE bronze.erp_orders;
GO
  
CREATE TABLE bronze.erp_orders (
	order_id NVARCHAR(50),
	customer_id NVARCHAR(50),
	order_status NVARCHAR(50),
	order_purchase_timestamp DATETIME,
	order_approved_at DATETIME,
	order_delivered_carrier_date DATETIME,
	order_delivered_customer_date DATETIME,
	order_estimated_delivery_date DATETIME
);
GO

IF OBJECT_ID ('bronze.erp_product_category_name_translation', 'U') IS NOT NULL
	DROP TABLE bronze.erp_product_category_name_translation;
GO
  
CREATE TABLE bronze.erp_product_category_name_translation (
	product_category_name NVARCHAR(50),
	product_category_name_english NVARCHAR(50)
);
GO
  
IF OBJECT_ID ('bronze.erp_products', 'U') IS NOT NULL
	DROP TABLE bronze.erp_products;
GO
  
CREATE TABLE bronze.erp_products (
	product_id NVARCHAR(50),
	product_category_name NVARCHAR(50),
	product_name_lenght INT,
	product_description_lenght INT,
	product_photos_qty INT,
	product_weight_g INT,
	product_length_cm INT,
	product_height_cm INT,
	product_width_cm INT
);
GO

IF OBJECT_ID ('bronze.erp_sellers', 'U') IS NOT NULL
	DROP TABLE bronze.erp_sellers;
GO
  
CREATE TABLE bronze.erp_sellers (
	seller_id NVARCHAR(50),
	seller_zip_code_prefix NVARCHAR(50),
	seller_city NVARCHAR(50),
	seller_state NVARCHAR(50)
);
GO
