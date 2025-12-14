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
    EXEC Bronze.LoadBronze;
===============================================================================
*/
CREATE OR ALTER PROCEDURE Bronze.LoadBronze AS
BEGIN
	DECLARE StartTime DATETIME, EndTime DATETIME, @BatchStartTime DATETIME, @BatchEndTime DATETIME; 
	BEGIN TRY
		SET @BatchStartTime = GETDATE();
		PRINT '================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';

		SET StartTime = GETDATE();
		PRINT '>> Truncating Table: crm_customers';
		TRUNCATE TABLE Bronze.crm_customers;
		PRINT '>> Inserting Data Into: crm_customers';
		BULK INSERT Bronze.crm_customers
		FROM 'C:\Users\Dell\OneDrive\Desktop\Grocery Sales\crm\customers.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			CODEPAGE = '65001',
			TABLOCK
		);
		SET EndTime = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, StartTime, EndTime) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		PRINT '------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------';

		SET StartTime = GETDATE();
		PRINT '>> Truncating Table: erp_categories';
		TRUNCATE TABLE Bronze.erp_categories;
		PRINT '>> Inserting Data Into: erp_categories';
		BULK INSERT Bronze.erp_categories
		FROM 'C:\Users\Dell\OneDrive\Desktop\Grocery Sales\erp\categories.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			TABLOCK
		);
		SET EndTime = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, StartTime, EndTime) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET StartTime = GETDATE();
		PRINT '>> Truncating Table: erp_employees';
		TRUNCATE TABLE Bronze.erp_employees;
		PRINT '>> Inserting Data Into: erp_employees';
		BULK INSERT Bronze.erp_employees
		FROM 'C:\Users\Dell\OneDrive\Desktop\Grocery Sales\erp\employees.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			CODEPAGE = '65001',
			TABLOCK
		);
		SET EndTime = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, StartTime, EndTime) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET StartTime = GETDATE();
		PRINT '>> Truncating Table: erp_products';
		TRUNCATE TABLE Bronze.erp_products;
		PRINT '>> Inserting Data Into: erp_products';
		BULK INSERT Bronze.erp_products
		FROM 'C:\Users\Dell\OneDrive\Desktop\Grocery Sales\erp\products.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			CODEPAGE = '65001',
			FORMAT = 'CSV'
		);
		SET EndTime = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, StartTime, EndTime) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET StartTime = GETDATE();
		PRINT '>> Truncating Table: erp_sales';
		TRUNCATE TABLE Bronze.erp_sales;
		PRINT '>> Inserting Data Into: erp_sales';
		BULK INSERT Bronze.erp_sales
		FROM 'C:\Users\Dell\OneDrive\Desktop\Grocery Sales\erp\sales.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			TABLOCK
		);
		SET EndTime = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, StartTime, EndTime) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		PRINT '------------------------------------------------';
		PRINT 'Loading MDM Tables';
		PRINT '------------------------------------------------';

		SET StartTime = GETDATE();
		PRINT '>> Truncating Table: mdm_cities';
		TRUNCATE TABLE Bronze.mdm_cities;
		PRINT '>> Inserting Data Into: mdm_cities';
		BULK INSERT Bronze.mdm_cities
		FROM 'C:\Users\Dell\OneDrive\Desktop\Grocery Sales\mdm\cities.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			CODEPAGE = '65001',
			TABLOCK
		);
		SET EndTime = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, StartTime, EndTime) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET StartTime = GETDATE();
		PRINT '>> Truncating Table: mdm_countries';
		TRUNCATE TABLE Bronze.mdm_countries;
		PRINT '>> Inserting Data Into: mdm_countries';
		BULK INSERT Bronze.mdm_countries
		FROM 'C:\Users\Dell\OneDrive\Desktop\Grocery Sales\mdm\countries.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			CODEPAGE = '65001',
			TABLOCK
		);
		SET EndTime = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, StartTime, EndTime) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET StartTime = GETDATE();
		PRINT '>> Truncating Table: mdm_zipcodes';
		TRUNCATE TABLE Bronze.mdm_zipcodes;
		PRINT '>> Inserting Data Into: mdm_zipcodes';
		BULK INSERT Bronze.mdm_zipcodes
		FROM 'C:\Users\Dell\OneDrive\Desktop\Grocery Sales\mdm\zipcodes.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			TABLOCK
		);
		SET EndTime = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, StartTime, EndTime) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET @BatchEndTime = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @BatchStartTime, @BatchEndTime) AS NVARCHAR) + ' seconds';
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
