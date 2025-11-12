/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'Bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the Bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to Bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Bronze.load_Bronze;
===============================================================================
*/
CREATE OR ALTER PROCEDURE Bronze.load_Bronze AS
BEGIN
	DECLARE @Start_Time DATETIME, @End_Time DATETIME, @Batch_Start_Time DATETIME, @Batch_End_Time DATETIME; 
	BEGIN TRY
		SET @Batch_Start_Time = GETDATE();
		PRINT '================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';

		SET @Start_Time = GETDATE();
		PRINT '>> Truncating Table: CRM_Fecom_Inc_Customer_List';
		TRUNCATE TABLE Bronze.CRM_Fecom_Inc_Customer_List;
		PRINT '>> Inserting Data Into: CRM_Fecom_Inc_Customer_List';
		BULK INSERT Bronze.CRM_Fecom_Inc_Customer_List
		FROM 'C:\Users\Dell\OneDrive\Desktop\Fecom Inc. (e-Com Marketplace Orders Data)\crm\Fecom Inc Customer List.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ';',
			ROWTERMINATOR = '\n',
			CODEPAGE = '65001',
			FORMAT = 'CSV'
		);
		SET @End_Time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @Start_Time, @End_Time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET @Start_Time = GETDATE();
		PRINT '>> Truncating Table: CRM_Fecom_Inc_Geolocations';
		TRUNCATE TABLE Bronze.CRM_Fecom_Inc_Geolocations;
		PRINT '>> Inserting Data Into: CRM_Fecom_Inc_Geolocations';
		BULK INSERT Bronze.CRM_Fecom_Inc_Geolocations
		FROM 'C:\Users\Dell\OneDrive\Desktop\Fecom Inc. (e-Com Marketplace Orders Data)\crm\Fecom Inc Geolocations.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ';',
			ROWTERMINATOR = '\n',
			CODEPAGE = '65001',
			FORMAT = 'CSV'
		);
		SET @End_Time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @Start_Time, @End_Time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET @Start_Time = GETDATE();
		PRINT '>> Truncating Table: CRM_Fecom_Inc_Order_Reviews';
		TRUNCATE TABLE Bronze.CRM_Fecom_Inc_Order_Reviews;
		PRINT '>> Inserting Data Into: CRM_Fecom_Inc_Order_Reviews';
		BULK INSERT Bronze.CRM_Fecom_Inc_Order_Reviews
		FROM 'C:\Users\Dell\OneDrive\Desktop\Fecom Inc. (e-Com Marketplace Orders Data)\crm\Fecom Inc Order Reviews.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ';',
			ROWTERMINATOR = '\n',
			CODEPAGE = '65001',
			FORMAT = 'CSV'
		);
		SET @End_Time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @Start_Time, @End_Time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		PRINT '------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------';

		SET @Start_Time = GETDATE();
		PRINT '>> Truncating Table: ERP_Fecom_Inc_Order_Items';
		TRUNCATE TABLE Bronze.ERP_Fecom_Inc_Order_Items;
		PRINT '>> Inserting Data Into: ERP_Fecom_Inc_Order_Items';
		BULK INSERT Bronze.ERP_Fecom_Inc_Order_Items
		FROM 'C:\Users\Dell\OneDrive\Desktop\Fecom Inc. (e-Com Marketplace Orders Data)\erp\Fecom Inc Order Items.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ';',
			ROWTERMINATOR = '\n',
			FORMAT = 'CSV'
		);
		SET @End_Time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @Start_Time, @End_Time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET @Start_Time = GETDATE();
		PRINT '>> Truncating Table: ERP_Fecom_Inc_Order_Payments';
		TRUNCATE TABLE Bronze.ERP_Fecom_Inc_Order_Payments;
		PRINT '>> Inserting Data Into: ERP_Fecom_Inc_Order_Payments';
		BULK INSERT Bronze.ERP_Fecom_Inc_Order_Payments
		FROM 'C:\Users\Dell\OneDrive\Desktop\Fecom Inc. (e-Com Marketplace Orders Data)\erp\Fecom Inc Order Payments.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ';',
			ROWTERMINATOR = '\n',
			FORMAT = 'CSV'
		);
		SET @End_Time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @Start_Time, @End_Time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET @Start_Time = GETDATE();
		PRINT '>> Truncating Table: ERP_Fecom_Inc_Orders';
		TRUNCATE TABLE Bronze.ERP_Fecom_Inc_Orders;
		PRINT '>> Inserting Data Into: ERP_Fecom_Inc_Orders';
		BULK INSERT Bronze.ERP_Fecom_Inc_Orders
		FROM 'C:\Users\Dell\OneDrive\Desktop\Fecom Inc. (e-Com Marketplace Orders Data)\erp\Fecom Inc Orders.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ';',
			ROWTERMINATOR = '\n',
			FORMAT = 'CSV'
		);
		SET @End_Time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @Start_Time, @End_Time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET @Start_Time = GETDATE();
		PRINT '>> Truncating Table: ERP_Fecom_Inc_Products';
		TRUNCATE TABLE Bronze.ERP_Fecom_Inc_Products;
		PRINT '>> Inserting Data Into: ERP_Fecom_Inc_Products';
		BULK INSERT Bronze.ERP_Fecom_Inc_Products
		FROM 'C:\Users\Dell\OneDrive\Desktop\Fecom Inc. (e-Com Marketplace Orders Data)\erp\Fecom Inc Products.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ';',
			ROWTERMINATOR = '\n',
			FORMAT = 'CSV'
		);
		SET @End_Time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @Start_Time, @End_Time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET @Start_Time = GETDATE();
		PRINT '>> Truncating Table: ERP_Fecom_Inc_Sellers_List';
		TRUNCATE TABLE Bronze.ERP_Fecom_Inc_Sellers_List;
		PRINT '>> Inserting Data Into: ERP_Fecom_Inc_Sellers_List';
		BULK INSERT Bronze.ERP_Fecom_Inc_Sellers_List
		FROM 'C:\Users\Dell\OneDrive\Desktop\Fecom Inc. (e-Com Marketplace Orders Data)\erp\Fecom Inc Sellers List.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ';',
			ROWTERMINATOR = '\n',
			CODEPAGE = '65001',
			FORMAT = 'CSV'
		);
		SET @End_Time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @Start_Time, @End_Time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET @Batch_End_Time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @Batch_Start_Time, @Batch_End_Time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING Bronze LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END
