/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'Silver' schema tables from the 'Bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.LoadSilver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE Silver.LoadSilver AS
BEGIN
    DECLARE @StartTime DATETIME, @EndTime DATETIME, @BatchStartTime DATETIME, @BatchEndTime DATETIME; 
    BEGIN TRY
        SET @BatchStartTime = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';

		-- Loading Silver.crm_customers
        SET @StartTime = GETDATE();
        PRINT '>> Truncating Table: Silver.crm_customers';
        TRUNCATE TABLE Silver.crm_customers;
        PRINT '>> Inserting Data Into: Silver.crm_customers';
        INSERT INTO Silver.crm_customers (
	        CustomerID,
	        FirstName,
	        MiddleInitial,
	        LastName,
	        CityID,
	        Addres,
	        StreetNumber,
	        DirectionalPrefix,
	        StreetName,
	        StreetType
        )
        SELECT
	        CASE 
		        WHEN ISNUMERIC(CustomerID) = 0 THEN 'n/a'
		        WHEN CAST(CustomerID AS INT) < 0 THEN ABS(CAST(CustomerID AS INT))
		        ELSE CAST(CustomerID AS INT)
	        END AS CustomerID,
	        CASE 
		        WHEN FirstName IS NULL OR TRIM(FirstName) = '' THEN 'n/a' 
		        ELSE dbo.ToProperCase(FirstName)
	        END AS FirstName,
	        CASE 
		        WHEN MiddleInitial IS NULL OR TRIM(MiddleInitial) = '' THEN 'n/a' 
		        WHEN LEN(TRIM(MiddleInitial)) > 1 OR (TRIM(MiddleInitial) <> '' AND TRIM(MiddleInitial) NOT LIKE '[A-Z]') THEN 'n/a'
		        ELSE UPPER(TRIM(MiddleInitial))
	        END AS MiddleInitial,
	        CASE 
		        WHEN LastName IS NULL OR TRIM(LastName) = '' THEN 'n/a' 
		        ELSE dbo.ToProperCase(LastName)
	        END AS LastName,
	        CASE 
		        WHEN ISNUMERIC(CityID) = 0 THEN 'n/a'
		        WHEN CAST(CityID AS INT) < 0 THEN ABS(CAST(CityID AS INT))
		        ELSE CAST(CityID AS INT)
	        END AS CityID,
	        CASE 
		        WHEN Addres IS NULL OR TRIM(Addres) = '' THEN 'n/a' 
		        ELSE TRIM(Addres)
	        END AS Addres,
	        CAST(LEFT(Addres, CHARINDEX(' ', Addres + ' ') - 1) AS INT) AS StreetNumber,
                CASE 
                    WHEN Addres LIKE '% East' OR Addres LIKE 'East %' OR Addres LIKE '% East %' THEN 'East'
                    WHEN Addres LIKE '% West' OR Addres LIKE 'West %' OR Addres LIKE '% West %' THEN 'West'
                    WHEN Addres LIKE '% North' OR Addres LIKE 'North %' OR Addres LIKE '% North %' THEN 'North'
                    WHEN Addres LIKE '% South' OR Addres LIKE 'South %' OR Addres LIKE '% South %' THEN 'South'
                    ELSE ''
                END as DirectionalPrefix,
                TRIM(REPLACE(SUBSTRING(Addres, CHARINDEX(' ', Addres) + 1, LEN(Addres) - CHARINDEX(' ', Addres) - (CHARINDEX(' ', REVERSE(TRIM(Addres))) - 1)), 
                        CASE 
                            WHEN Addres LIKE '% East' OR Addres LIKE 'East %' OR Addres LIKE '% East %' THEN 'East'
                            WHEN Addres LIKE '% West' OR Addres LIKE 'West %' OR Addres LIKE '% West %' THEN 'West'
                            WHEN Addres LIKE '% North' OR Addres LIKE 'North %' OR Addres LIKE '% North %' THEN 'North'
                            WHEN Addres LIKE '% South' OR Addres LIKE 'South %' OR Addres LIKE '% South %' THEN 'South'
                            ELSE ''
                        END, '')) AS StreetName,
                CASE 
                    WHEN RIGHT(Addres, CHARINDEX(' ', REVERSE(TRIM(Addres))) - 1) IN ('Blvd.', 'Blvd', 'Boulevard') THEN 'Boulevard'
                    WHEN RIGHT(Addres, CHARINDEX(' ', REVERSE(TRIM(Addres))) - 1) IN ('St.', 'St', 'Street') THEN 'Street'
                    WHEN RIGHT(Addres, CHARINDEX(' ', REVERSE(TRIM(Addres))) - 1) IN ('Ave.', 'Ave', 'Avenue') THEN 'Avenue'
                    WHEN RIGHT(Addres, CHARINDEX(' ', REVERSE(TRIM(Addres))) - 1) IN ('Rd.', 'Rd', 'Road') THEN 'Road'
                    WHEN RIGHT(Addres, CHARINDEX(' ', REVERSE(TRIM(Addres))) - 1) IN ('Dr.', 'Dr', 'Drive') THEN 'Drive'
                    WHEN RIGHT(Addres, CHARINDEX(' ', REVERSE(TRIM(Addres))) - 1) IN ('Fwy.', 'Fwy', 'Freeway') THEN 'Freeway'
                    WHEN RIGHT(Addres, CHARINDEX(' ', REVERSE(TRIM(Addres))) - 1) IN ('Pkwy.', 'Pkwy', 'Parkway') THEN 'Parkway'
                    WHEN RIGHT(Addres, CHARINDEX(' ', REVERSE(TRIM(Addres))) - 1) IN ('Way') THEN 'Way'
                    ELSE RIGHT(Addres, CHARINDEX(' ', REVERSE(TRIM(Addres))) - 1)
                END AS StreetType
        FROM Bronze.crm_customers
        WHERE CustomerID IS NOT NULL AND ISNUMERIC(CustomerID) = 1;
        SET @EndTime = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        PRINT '------------------------------------------------';
		PRINT 'Loading MDM Tables';
		PRINT '------------------------------------------------';

        -- Loading Silver.mdm_cities
        SET @StartTime = GETDATE();
        PRINT '>> Truncating Table: Silver.mdm_cities';
        TRUNCATE TABLE Silver.mdm_cities;
        PRINT '>> Inserting Data Into: Silver.mdm_cities';
        WITH CityFallback AS (
            -- Get the Median valid Zipcode for every City name to use as a backup
            SELECT T.City, T.Default_Zip FROM (
                SELECT 
                    City,
                    Zipcode,
                    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY Zipcode) OVER (PARTITION BY City) AS Default_Zip,
                    ROW_NUMBER() OVER (PARTITION BY City ORDER BY (SELECT NULL)) AS rn
                FROM Bronze.mdm_zipcodes
            ) AS T WHERE T.rn = 1
        ),
        CityNameFix AS (
            SELECT
                CityID,
	            CASE 
		            WHEN CityName IS NULL OR TRIM(CityName) = '' THEN 'n/a'
		            WHEN CityName = 'St. Louis' THEN 'Saint Louis'
                    WHEN CityName = 'St. Paul' THEN 'Saint Paul'
                    WHEN CityName = 'St. Petersburg' THEN 'Saint Petersburg'
                    WHEN CityName = 'Colorado' THEN 'Colorado City'
		            ELSE dbo.ToProperCase(CityName)
	            END AS CityName,
	            Zipcode,
	            CountryID
            FROM Bronze.mdm_cities
        ),
        ZipcodeFix AS (
            SELECT
                c.CityID,
	            -- CLEANING CITY NAMES
                -- If the Zipcode exists in the master list, trust the Master City Name.
                -- Otherwise, keep the original Source City Name.
                CASE 
                    WHEN z.Zipcode IS NOT NULL THEN z.City 
                    ELSE c.CityName 
                END AS CityName,
	            -- CLEANING ZIPCODES
                -- If the Zipcode exists in the master list, keep it.
                -- If the Zipcode is invalid (NULL in join), use the fallback Zip based on the City Name.
                CASE 
                    WHEN z.Zipcode IS NOT NULL THEN c.Zipcode
                    ELSE fb.Default_Zip 
                END AS Zipcode,
	            c.CountryID
            FROM CityNameFix AS c
            LEFT JOIN Bronze.mdm_zipcodes AS z
            ON TRIM(c.Zipcode) = TRIM(z.Zipcode)
            LEFT JOIN CityFallback AS fb
            ON TRIM(c.CityName) = TRIM(fb.City)
        )
        INSERT INTO Silver.mdm_cities (
	        CityID,
	        CityName,
	        Zipcode,
	        CountryID,
	        Region,
	        DivisionRegion,
	        States,
            StatesCode,
            County,
            Latitude,
            Longitude
        )
        SELECT
	        CASE 
		        WHEN ISNUMERIC(f.CityID) = 0 THEN 'n/a'
		        WHEN CAST(f.CityID AS INT) < 0 THEN ABS(CAST(f.CityID AS INT))
		        ELSE CAST(f.CityID AS INT)
	        END AS CityID,
	        f.CityName,
	        f.Zipcode,
	        CASE 
		        WHEN ISNUMERIC(f.CountryID) = 0 THEN 'n/a'
		        WHEN CAST(f.CountryID AS INT) < 0 THEN ABS(CAST(f.CountryID AS INT))
		        ELSE CAST(f.CountryID AS INT)
	        END AS CountryID,
	        CASE
                WHEN z.States IN ('NY', 'NJ', 'PA', 'VT', 'RI', 'NH', 'MA', 'ME', 'CT')                                                 THEN 'Northeast'
                WHEN z.States IN ('IL', 'IN', 'MI', 'OH', 'WI', 'IA', 'KS', 'MN', 'MO', 'NE', 'ND', 'SD')                               THEN 'Midwest'
                WHEN z.States IN ('AZ', 'CO', 'ID', 'MT', 'NV', 'NM', 'UT', 'WY', 'AK', 'CA', 'HI', 'OR', 'WA')                         THEN 'West'
                WHEN z.States IN ('DE', 'DC', 'FL', 'GA', 'MD', 'NC', 'SC', 'VA', 'WV', 'AL', 'KY', 'MS', 'TN', 'AR', 'LA', 'OK', 'TX') THEN 'South'
                ELSE 'Unknown'
            END AS Region,
            CASE 
                -- Northeast
                WHEN z.States IN ('VT', 'RI', 'NH', 'MA', 'ME', 'CT')                   THEN 'New England'
                WHEN z.States IN ('NY', 'NJ', 'PA')                                     THEN 'Mid-Atlantic'
                -- Midwest
                WHEN z.States IN ('IL', 'IN', 'MI', 'OH', 'WI')                   THEN 'East North Central'
                WHEN z.States IN ('IA', 'KS', 'MN', 'MO', 'NE', 'ND', 'SD')             THEN 'West North Central'
                -- West
                WHEN z.States IN ('AZ', 'CO', 'ID', 'MT', 'NV', 'NM', 'UT', 'WY')       THEN 'Mountain'
                WHEN z.States IN ('AK', 'CA', 'HI', 'OR', 'WA')                         THEN 'Pacific'
                -- South
                WHEN z.States IN ('DE', 'DC', 'FL', 'GA', 'MD', 'NC', 'SC', 'VA', 'WV') THEN 'South Atlantic'
                WHEN z.States IN ('AL','KY', 'MS', 'TN')                                THEN 'East South Central'
                WHEN z.States IN ('AR', 'LA', 'OK', 'TX')                               THEN 'West South Central'
                ELSE 'Unknown' 
            END AS DivisionRegion,
            CASE z.States
                -- Northeast
                --===========================
                -- New England
                WHEN 'MA' THEN 'Massachusetts'
                WHEN 'RI' THEN 'Rhode Island'
                WHEN 'NH' THEN 'New Hampshire'
                WHEN 'ME' THEN 'Maine'
                WHEN 'VT' THEN 'Vermont'
                WHEN 'CT' THEN 'Connecticut'
                -- Mid-Atlantic
                WHEN 'NY' THEN 'New York'
                WHEN 'NJ' THEN 'New Jersey'
                WHEN 'PA' THEN 'Pennsylvania'
                -- Midwest
                --===========================
                -- East North Central
                WHEN 'IL' THEN 'Illinois'
                WHEN 'IN' THEN 'Indiana'
                WHEN 'MI' THEN 'Michigan'
                WHEN 'OH' THEN 'Ohio'
                WHEN 'WI' THEN 'Wisconsin'
                -- West North Central
                WHEN 'IA' THEN 'Iowa'
                WHEN 'MN' THEN 'Minnesota'
                WHEN 'SD' THEN 'South Dakota'
                WHEN 'ND' THEN 'North Dakota'
                WHEN 'MO' THEN 'Missouri'
                WHEN 'KS' THEN 'Kansas'
                WHEN 'NE' THEN 'Nebraska'
                -- West
                --===========================
                -- Mountain
                WHEN 'AZ' THEN 'Arizona'
                WHEN 'CO' THEN 'Colorado'
                WHEN 'ID' THEN 'Idaho'
                WHEN 'MT' THEN 'Montana'
                WHEN 'NV' THEN 'Nevada'
                WHEN 'NM' THEN 'New Mexico'
                WHEN 'UT' THEN 'Utah'
                WHEN 'WY' THEN 'Wyoming'
                -- Pacific
                WHEN 'AK' THEN 'Alaska'
                WHEN 'CA' THEN 'California'
                WHEN 'HI' THEN 'Hawaii'
                WHEN 'OR' THEN 'Oregon'
                WHEN 'WA' THEN 'Washington'
                -- South
                --===========================
                -- South Atlantic
                WHEN 'DE' THEN 'Delaware'
                WHEN 'DC' THEN 'District of Columbia'
                WHEN 'FL' THEN 'Florida'
                WHEN 'GA' THEN 'Georgia'
                WHEN 'MD' THEN 'Maryland'
                WHEN 'NC' THEN 'North Carolina'
                WHEN 'SC' THEN 'South Carolina'
                WHEN 'VA' THEN 'Virginia'
                WHEN 'WV' THEN 'West Virginia'
                -- East South Central
                WHEN 'AL' THEN 'Alabama'
                WHEN 'KY' THEN 'Kentucky'
                WHEN 'MS' THEN 'Mississippi'
                WHEN 'TN' THEN 'Tennessee'
                -- West South Central
                WHEN 'AR' THEN 'Arkansas'
                WHEN 'LA' THEN 'Louisiana'
                WHEN 'OK' THEN 'Oklahoma'
                WHEN 'TX' THEN 'Texas'
                -- Territories and Freely Associated States
                --===========================
                WHEN 'PR' THEN 'Puerto Rico'                    -- Territory
                WHEN 'VI' THEN 'U.S. Virgin Islands'            -- Territory
                WHEN 'AS' THEN 'American Samoa'                 -- Territory
                WHEN 'GU' THEN 'Guam'                           -- Territory
                WHEN 'MP' THEN 'Northern Mariana Islands'       -- Territory
                WHEN 'PW' THEN 'Palau'                          -- Freely Associated State
                WHEN 'FM' THEN 'Federated States of Micronesia' -- Freely Associated State
                WHEN 'MH' THEN 'Marshall Islands'               -- Freely Associated State
                ELSE 'Unknown'
            END AS States,
            z.States AS StatesCode,
            z.County,
            z.Latitude,
            z.Longitude
        FROM ZipcodeFix AS f
        LEFT JOIN Bronze.mdm_zipcodes AS z
            ON TRIM(f.Zipcode) = TRIM(z.Zipcode)
        WHERE CityID IS NOT NULL AND ISNUMERIC(CityID) = 1;
        SET @EndTime = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Loading Silver.mdm_countries
        SET @StartTime = GETDATE();
        PRINT '>> Truncating Table: Silver.mdm_countries';
        TRUNCATE TABLE Silver.mdm_countries;
        PRINT '>> Inserting Data Into: Silver.mdm_countries';
        INSERT INTO Silver.mdm_countries (
	        CountryID,
	        CountryName,
	        CountryCode
        )
        SELECT
            CASE 
		        WHEN ISNUMERIC(CountryID) = 0 THEN 'n/a'
		        WHEN CAST(CountryID AS INT) < 0 THEN ABS(CAST(CountryID AS INT))
		        ELSE CAST(CountryID AS INT)
	        END AS CountryID,
	        CASE 
		        WHEN CountryName IS NULL OR TRIM(CountryName) = '' THEN 'n/a'
		        WHEN CountryName = 'Eire' THEN 'Ireland'
                WHEN CountryName = 'Burma' THEN 'Myanmar'
                WHEN CountryName = 'Swaziland' THEN 'Eswatini'
                WHEN CountryName = 'Czech Republic' THEN 'Czechia'
                WHEN CountryName = 'Macedonia' THEN 'North Macedonia'
                WHEN CountryName = 'Falklands' OR CountryName = 'Malvinas' THEN 'Falkland Islands'
                WHEN CountryName = 'Ivory Coast' THEN 'Côte d''Ivoire'
                WHEN CountryName = 'Cape Verde' THEN 'Cabo Verde'
                WHEN CountryName = 'Trinidad' THEN 'Trinidad and Tobago'
                WHEN CountryName = 'Virgin Islands' THEN 'U.S. Virgin Islands'
		        ELSE dbo.ToProperCase(CountryName)
	        END AS CountryName,
	        CASE CountryName
                WHEN 'Armenia' THEN 'AM'
                WHEN 'Canada' THEN 'CA'
                WHEN 'Belize' THEN 'BZ'
                WHEN 'Uganda' THEN 'UG'
                WHEN 'Thailand' THEN 'TH'
                WHEN 'Tunisia' THEN 'TN'
                WHEN 'Montserrat' THEN 'MS'
                WHEN 'Iraq' THEN 'IQ'
                WHEN 'Slovakia' THEN 'SK'
                WHEN 'Germany' THEN 'DE'
                WHEN 'Mauritania' THEN 'MR'
                WHEN 'Israel' THEN 'IL'
                WHEN 'Panama' THEN 'PA'
                WHEN 'Kazakhstan' THEN 'KZ'
                WHEN 'Swaziland' THEN 'SZ'
                WHEN 'Eswatini' THEN 'SZ' 
                WHEN 'Malawi' THEN 'MW'
                WHEN 'Malta' THEN 'MT'
                WHEN 'Czech Republic' THEN 'CZ'
                WHEN 'Czechia' THEN 'CZ' 
                WHEN 'Mauritius' THEN 'MU'
                WHEN 'Luxembourg' THEN 'LU'
                WHEN 'Macedonia' THEN 'MK'
                WHEN 'North Macedonia' THEN 'MK'
                WHEN 'Haiti' THEN 'HT'
                WHEN 'Saint Helena' THEN 'SH'
                WHEN 'Austria' THEN 'AT'
                WHEN 'Bahrain' THEN 'BH'
                WHEN 'Denmark' THEN 'DK'
                WHEN 'Zambia' THEN 'ZM'
                WHEN 'Paraguay' THEN 'PY'
                WHEN 'Oman' THEN 'OM'
                WHEN 'Honduras' THEN 'HN'
                WHEN 'Congo' THEN 'CG'
                WHEN 'United States' THEN 'US'
                WHEN 'Comoros' THEN 'KM'
                WHEN 'Macao' THEN 'MO'
                WHEN 'Uruguay' THEN 'UY'
                WHEN 'Moldova' THEN 'MD'
                WHEN 'Vatican City' THEN 'VA'
                WHEN 'Liechtenstein' THEN 'LI'
                WHEN 'Guatemala' THEN 'GT'
                WHEN 'Bermuda' THEN 'BM'
                WHEN 'Sudan' THEN 'SD'
                WHEN 'Guinea' THEN 'GN'
                WHEN 'Cape Verde' THEN 'CV'
                WHEN 'Cabo Verde' THEN 'CV'
                WHEN 'Liberia' THEN 'LR'
                WHEN 'Libya' THEN 'LY'
                WHEN 'Tuvalu' THEN 'TV'
                WHEN 'Kenya' THEN 'KE'
                WHEN 'Finland' THEN 'FI'
                WHEN 'Azerbaijan' THEN 'AZ'
                WHEN 'Aruba' THEN 'AW'
                WHEN 'San Marino' THEN 'SM'
                WHEN 'Italy' THEN 'IT'
                WHEN 'Djibouti' THEN 'DJ'
                WHEN 'Isle of Man' THEN 'IM'
                WHEN 'Dominica' THEN 'DM'
                WHEN 'Virgin Islands' THEN 'VI'
                WHEN 'U.S. Virgin Islands' THEN 'VI'
                WHEN 'Benin' THEN 'BJ'
                WHEN 'South Georgia' THEN 'GS'
                WHEN 'Grenada' THEN 'GD'
                WHEN 'Philippines' THEN 'PH'
                WHEN 'Cook Islands' THEN 'CK'
                WHEN 'Guyana' THEN 'GY'
                WHEN 'Lesotho' THEN 'LS'
                WHEN 'Somalia' THEN 'SO'
                WHEN 'Lebanon' THEN 'LB'
                WHEN 'Greece' THEN 'GR'
                WHEN 'Samoa' THEN 'WS'
                WHEN 'Estonia' THEN 'EE'
                WHEN 'Argentina' THEN 'AR'
                WHEN 'Namibia' THEN 'NA'
                WHEN 'Suriname' THEN 'SR'
                WHEN 'Algeria' THEN 'DZ'
                WHEN 'Portugal' THEN 'PT'
                WHEN 'Serbia' THEN 'RS'
                WHEN 'France' THEN 'FR'
                WHEN 'Tonga' THEN 'TO'
                WHEN 'Jamaica' THEN 'JM'
                WHEN 'South Korea' THEN 'KR'
                WHEN 'Egypt' THEN 'EG'
                WHEN 'American Samoa' THEN 'AS'
                WHEN 'Cameroon' THEN 'CM'
                WHEN 'Gibraltar' THEN 'GI'
                WHEN 'Bhutan' THEN 'BT'
                WHEN 'Falklands' THEN 'FK'
                WHEN 'Malvinas' THEN 'FK'
                WHEN 'Falkland Islands' THEN 'FK'
                WHEN 'Yemen' THEN 'YE'
                WHEN 'Latvia' THEN 'LV'
                WHEN 'Togo' THEN 'TG'
                WHEN 'Albania' THEN 'AL'
                WHEN 'Kiribati' THEN 'KI'
                WHEN 'Hungary' THEN 'HU'
                WHEN 'Bulgaria' THEN 'BG'
                WHEN 'Gabon' THEN 'GA'
                WHEN 'Nigeria' THEN 'NG'
                WHEN 'Barbados' THEN 'BB'
                WHEN 'Montenegro' THEN 'ME'
                WHEN 'Kyrgyzstan' THEN 'KG'
                WHEN 'Tajikistan' THEN 'TJ'
                WHEN 'Western Sahara' THEN 'EH'
                WHEN 'Uzbekistan' THEN 'UZ'
                WHEN 'Nicaragua' THEN 'NI'
                WHEN 'Bolivia' THEN 'BO'
                WHEN 'Romania' THEN 'RO'
                WHEN 'Slovenia' THEN 'SI'
                WHEN 'Seychelles' THEN 'SC'
                WHEN 'Puerto Rico' THEN 'PR'
                WHEN 'Cyprus' THEN 'CY'
                WHEN 'Ghana' THEN 'GH'
                WHEN 'Pakistan' THEN 'PK'
                WHEN 'Réunion' THEN 'RE'
                WHEN 'Croatia' THEN 'HR'
                WHEN 'Venezuela' THEN 'VE'
                WHEN 'Antarctica' THEN 'AQ'
                WHEN 'Colombia' THEN 'CO'
                WHEN 'Singapore' THEN 'SG'
                WHEN 'Tanzania' THEN 'TZ'
                WHEN 'Iran' THEN 'IR'
                WHEN 'Saudi Arabia' THEN 'SA'
                WHEN 'El Salvador' THEN 'SV'
                WHEN 'Malaysia' THEN 'MY'
                WHEN 'Vietnam' THEN 'VN'
                WHEN 'Norway' THEN 'NO'
                WHEN 'Afghanistan' THEN 'AF'
                WHEN 'Indonesia' THEN 'ID'
                WHEN 'Morocco' THEN 'MA'
                WHEN 'New Caledonia' THEN 'NC'
                WHEN 'Nepal' THEN 'NP'
                WHEN 'Belgium' THEN 'BE'
                WHEN 'Eire' THEN 'IE'
                WHEN 'Ireland' THEN 'IE'
                WHEN 'Jersey' THEN 'JE'
                WHEN 'Cambodia' THEN 'KH'
                WHEN 'Timor-Leste' THEN 'TL'
                WHEN 'Micronesia' THEN 'FM'
                WHEN 'Jordan' THEN 'JO'
                WHEN 'Poland' THEN 'PL'
                WHEN 'Rwanda' THEN 'RW'
                WHEN 'Botswana' THEN 'BW'
                WHEN 'Fiji' THEN 'FJ'
                WHEN 'Netherlands' THEN 'NL'
                WHEN 'Ethiopia' THEN 'ET'
                WHEN 'Kuwait' THEN 'KW'
                WHEN 'China' THEN 'CN'
                WHEN 'Guam' THEN 'GU'
                WHEN 'Mexico' THEN 'MX'
                WHEN 'Andorra' THEN 'AD'
                WHEN 'United Kingdom' THEN 'GB'
                WHEN 'Australia' THEN 'AU'
                WHEN 'Côte d''Ivoire' THEN 'CI' 
                WHEN 'Mali' THEN 'ML'
                WHEN 'India' THEN 'IN'
                WHEN 'Cuba' THEN 'CU'
                WHEN 'Iceland' THEN 'IS'
                WHEN 'Senegal' THEN 'SN'
                WHEN 'Sweden' THEN 'SE'
                WHEN 'Vanuatu' THEN 'VU'
                WHEN 'Bangladesh' THEN 'BD'
                WHEN 'Madagascar' THEN 'MG'
                WHEN 'French Guiana' THEN 'GF'
                WHEN 'Japan' THEN 'JP'
                WHEN 'Eritrea' THEN 'ER'
                WHEN 'Mozambique' THEN 'MZ'
                WHEN 'Bahamas' THEN 'BS'
                WHEN 'Sierra Leone' THEN 'SL'
                WHEN 'Taiwan' THEN 'TW'
                WHEN 'Martinique' THEN 'MQ'
                WHEN 'Zimbabwe' THEN 'ZW'
                WHEN 'Brazil' THEN 'BR'
                WHEN 'Syria' THEN 'SY'
                WHEN 'Gambia' THEN 'GM'
                WHEN 'Belarus' THEN 'BY'
                WHEN 'South Africa' THEN 'ZA'
                WHEN 'Trinidad' THEN 'TT'
                WHEN 'Trinidad and Tobago' THEN 'TT'
                WHEN 'Guinea-Bissau' THEN 'GW'
                WHEN 'Angola' THEN 'AO'
                WHEN 'Peru' THEN 'PE'
                WHEN 'Saint Lucia' THEN 'LC'
                WHEN 'Spain' THEN 'ES'
                WHEN 'Lithuania' THEN 'LT'
                WHEN 'Sri Lanka' THEN 'LK'
                WHEN 'Ukraine' THEN 'UA'
                WHEN 'Nauru' THEN 'NR'
                WHEN 'Niue' THEN 'NU'
                WHEN 'Pitcairn' THEN 'PN'
                WHEN 'Guadeloupe' THEN 'GP'
                WHEN 'Burkina Faso' THEN 'BF'
                WHEN 'Costa Rica' THEN 'CR'
                WHEN 'Switzerland' THEN 'CH'
                WHEN 'Hong Kong' THEN 'HK'
                WHEN 'Georgia' THEN 'GE'
                WHEN 'Guernsey' THEN 'GG'
                WHEN 'Qatar' THEN 'QA'
                WHEN 'North Korea' THEN 'KP'
                WHEN 'Burundi' THEN 'BI'
                WHEN 'New Zealand' THEN 'NZ'
                WHEN 'Palau' THEN 'PW'
                WHEN 'Chile' THEN 'CL'
                WHEN 'Turkey' THEN 'TR'
                WHEN 'Anguilla' THEN 'AI'
                WHEN 'Russia' THEN 'RU'
                WHEN 'Ecuador' THEN 'EC'
                WHEN 'Monaco' THEN 'MC'
                WHEN 'Myanmar' THEN 'MM'
                WHEN 'Burma' THEN 'MM'
                WHEN 'Greenland' THEN 'GL'
                WHEN 'Niger' THEN 'NE'
                WHEN 'Mayotte' THEN 'YT'
                WHEN 'Mongolia' THEN 'MN'
                ELSE CASE WHEN CountryCode IS NULL OR LEN(CountryCode) <> 2 OR CountryCode NOT LIKE '[A-Z][A-Z]' THEN 'n/a' ELSE UPPER(CountryCode) END
            END AS CountryCode
        FROM Bronze.mdm_countries
        WHERE CountryID IS NOT NULL AND ISNUMERIC(CountryID) = 1;
        SET @EndTime = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        PRINT '------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------';

        -- Loading Silver.erp_categories
        SET @StartTime = GETDATE();
        PRINT '>> Truncating Table: Silver.erp_categories';
        TRUNCATE TABLE Silver.erp_categories;
        PRINT '>> Inserting Data Into: Silver.erp_categories';
        INSERT INTO Silver.erp_categories (
	        CategoryID,
            CategoryName
        )
        SELECT
            CASE 
	            WHEN ISNUMERIC(CategoryID) = 0 THEN 'n/a'
	            WHEN CAST(CategoryID AS INT) < 0 THEN ABS(CAST(CategoryID AS INT))
	            ELSE CAST(CategoryID AS INT)
            END AS CategoryID,
            CASE ABS(CAST(CategoryID AS INT))
                WHEN 1  THEN 'Confections'            WHEN 15 THEN 'Paper & Disposable'
                WHEN 2  THEN 'Shell fish'             WHEN 16 THEN 'Cleaning Supplies'
                WHEN 3  THEN 'Cereals'                WHEN 17 THEN 'Apparel & Uniforms'
                WHEN 4  THEN 'Dairy'                  WHEN 18 THEN 'Hardware & Tools'
                WHEN 5  THEN 'Beverages'              WHEN 19 THEN 'Seasonings & Spices'
                WHEN 6  THEN 'Seafood'                WHEN 20 THEN 'Prepared Foods'
                WHEN 7  THEN 'Meat'                   WHEN 21 THEN 'Snacks & Chips'
                WHEN 8  THEN 'Grain Products'         WHEN 22 THEN 'Condiments & Sauces'
                WHEN 9  THEN 'Poultry'                WHEN 23 THEN 'Baking Supplies'
                WHEN 10 THEN 'Produce'                WHEN 24 THEN 'Frozen Foods'
                WHEN 11 THEN 'Kitchenware & Cookware' WHEN 25 THEN 'Canned & Preserved'
                WHEN 12 THEN 'Tableware & Serveware'  WHEN 26 THEN 'Health & Beauty'
                WHEN 13 THEN 'Packaging & Storage'    WHEN 27 THEN 'Miscellaneous'
                WHEN 14 THEN 'Non-Food Items'
                ELSE dbo.ToProperCase(TRIM(CategoryName))
            END AS CategoryName
        FROM Bronze.erp_categories
        WHERE CategoryID IS NOT NULL AND ISNUMERIC(CategoryID) = 1
        UNION ALL
        SELECT * FROM (
            VALUES 
                (12, 'Tableware & Serveware'),
                (13, 'Packaging & Storage'),
                (14, 'Non-Food Items'),
                (15, 'Paper & Disposable'),
                (16, 'Cleaning Supplies'),
                (17, 'Apparel & Uniforms'),
                (18, 'Hardware & Tools'),
                (19, 'Seasonings & Spices'),
                (20, 'Prepared Foods'),
                (21, 'Snacks & Chips'),
                (22, 'Condiments & Sauces'),
                (23, 'Baking Supplies'),
                (24, 'Frozen Foods'),
                (25, 'Canned & Preserved'),
                (26, 'Health & Beauty'),
                (27, 'Miscellaneous')
        ) AS NewCategories(CategoryID, CategoryName)
        ORDER BY CategoryID;
        SET @EndTime = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Loading Silver.erp_products
        SET @StartTime = GETDATE();
        PRINT '>> Truncating Table: Silver.erp_products';
        TRUNCATE TABLE Silver.erp_products;
        PRINT '>> Inserting Data Into: Silver.erp_products';
        INSERT INTO Silver.erp_products (
	        ProductID,
            ProductName,
            Price,
            CategoryID,
            Class,
            ModifyDate,
            Resistant,
            IsAllergic,
            VitalityDays
        )
        SELECT
            CASE 
	            WHEN ISNUMERIC(ProductID) = 0 THEN 'n/a'
	            WHEN CAST(ProductID AS INT) < 0 THEN ABS(CAST(ProductID AS INT))
	            ELSE CAST(ProductID AS INT)
            END AS ProductID,
            CASE 
	            WHEN ProductName IS NULL THEN 'n/a'
	            ELSE dbo.ToProperCase(ProductName)
            END AS ProductName,
            CASE 
	            WHEN Price  < 0 THEN ABS(Price)
	            ELSE Price
            END AS Price,
            CASE 
	            WHEN ISNUMERIC(CategoryID) = 0 THEN 'n/a'
	            -- Confections 
                WHEN ProductName IN ('Assorted Desserts', 'Isomalt', 'Cinnamon Buns Sticky', 'Pecan Raisin - Tarts') OR 
                     ProductName LIKE 'Pastry%'  OR ProductName LIKE '%Macaroon%' OR 
                     ProductName LIKE 'Cookies%' OR ProductName LIKE '%Muffin -%' OR
                    (ProductName LIKE '%Chocolate%' AND ProductName NOT LIKE 'Hot%' AND ProductName NOT LIKE 'Sponge%') OR
                    (ProductName LIKE 'Cake%' AND ProductName NOT LIKE '%Box%') 
                     THEN 1
                -- Shell fish
                WHEN ProductName LIKE 'Crab%Dungeness%' OR ProductName LIKE '%Mussels%' OR
                     ProductName LIKE 'Scallop%'        OR ProductName LIKE '%Scampi%' OR
                     ProductName LIKE 'Shrimp%'
                     THEN 2
                -- Cereals
                WHEN ProductName LIKE '%Cornflakes%' OR ProductName LIKE '%Kellogs%' 
                     THEN 3
                -- Dairy
                WHEN ProductName LIKE 'Butter%' OR ProductName LIKE 'Cheese -%' OR
                     ProductName LIKE '%Milk%'  OR ProductName LIKE '%Yoghurt%' OR
                     ProductName LIKE '%Yogurt%'
                     THEN 4
                -- Beverages
                WHEN ProductName IN ('Campari', 'Cassis', 'Creme De Banane - Marie', 'Bacardi Breezer - Tropical', 
                                     'Brandy - Bar', 'Grenadine', 'Hersey Shakes', 'Hot Chocolate - Individual', 
                                     'Island Oasis - Mango Daiquiri', 'Jagermeister', 'Jolt Cola - Electric Blue', 
                                     'Langers - Ruby Red Grapfruit', 'Lime Cordial - Roses', 'Pernod', 'Remy Red', 
                                     'Sherry - Dry', 'Smirnoff Green Apple Twist', 'Sobe - Tropical Energy', 'Tia Maria') OR
                     ProductName LIKE 'Tea %'    OR ProductName LIKE '% Tea %' OR
                     ProductName LIKE '% Tea'    OR ProductName LIKE '%ML%' OR
                     ProductName LIKE 'Beer%'    OR ProductName LIKE '%Water,%' OR
                     ProductName LIKE 'Coffee%'  OR ProductName LIKE '%Water %' OR
                     ProductName LIKE 'Juice%'   OR ProductName LIKE 'Nantu%' OR
                     ProductName LIKE '%Ocean%'  OR ProductName LIKE 'Rum%' OR
                     ProductName LIKE 'Wine%'    OR ProductName LIKE '%Soda%' OR
                     ProductName LIKE '% Berry%' OR ProductName LIKE '%Soda%' 
                     THEN 5
                -- Seafood
                WHEN ProductName LIKE 'Halibut%'  OR ProductName LIKE 'Salmon%' OR
                     ProductName LIKE '%Fillet%'  OR ProductName LIKE 'Squid%' OR
                     ProductName LIKE '%Grouper%' OR ProductName LIKE 'Fish%' OR
                     ProductName LIKE 'Clam%'     OR ProductName LIKE 'Sardines%' OR
                     ProductName LIKE 'Sole%'     OR ProductName LIKE '%Sea%Bass%' OR
                     ProductName LIKE 'Barramundi%' 
                     THEN 6
                -- Meat
                WHEN ProductName LIKE 'Lamb %'  OR ProductName LIKE 'Pork%' OR
                     ProductName LIKE 'Rabbit%' OR ProductName LIKE 'Sausage%' OR
                     ProductName LIKE 'Veal%'   OR
                    (ProductName LIKE 'Beef%' AND ProductName NOT LIKE '%Wellington%') 
                     THEN 7
                -- Grain Products
                WHEN ProductName IN ('Beans - Kidney, Red Dry', 'Corn Meal', 'Lentils - Red, Dry', 'Peas - Pigeon, Dry') OR
                     ProductName LIKE 'Bagel%' OR ProductName LIKE 'Bread%' OR ProductName LIKE 'Rice%' OR
                    (ProductName LIKE 'Pasta%' AND ProductName NOT LIKE '%Cheese%') 
                     THEN 8
                -- Poultry
                WHEN ProductName LIKE 'Duck%'   OR ProductName LIKE '%Fowl%' OR
                     ProductName LIKE 'Turkey%' OR
                    (ProductName LIKE 'Chicken %' AND ProductName NOT LIKE '%Soup%')
                     THEN 9
                -- Produce
                WHEN ProductName LIKE '%Artichokes%' OR ProductName LIKE '%Beets%' OR 
                     ProductName LIKE '%Currants%'   OR ProductName LIKE '%berries%' OR 
                     ProductName LIKE '%Cattail%'    OR ProductName LIKE '%Durian%' OR 
                     ProductName LIKE '%Eggplant%'   OR ProductName LIKE '%Apples%' OR
                     ProductName LIKE '%Grapes%'     OR ProductName LIKE 'Kiwi%' OR
                     ProductName LIKE '%Lettuce%'    OR ProductName LIKE '%Loquat%' OR
                     ProductName LIKE '%Mangoes%'    OR ProductName LIKE 'Zucchini%' OR
                     ProductName LIKE 'Nut%'         OR ProductName LIKE 'Onions%' OR
                     ProductName LIKE '%Oranges%'    OR ProductName LIKE 'Papayas%' OR
                     ProductName LIKE '%Pears%'      OR ProductName LIKE 'Pomello%' OR
                     ProductName LIKE 'Rambutan%'    OR ProductName LIKE 'Salsify%' OR
                     ProductName LIKE 'Seedlings%'   OR ProductName LIKE 'Spinach%' OR
                     ProductName LIKE 'Sprouts%'     OR ProductName LIKE 'Sunflower%' OR
                     ProductName LIKE 'Thyme%'       OR ProductName LIKE 'Tomato%' OR
                     ProductName LIKE 'Turnip%'      OR ProductName LIKE 'Watercress%' OR
                    (ProductName LIKE 'Garlic%'    AND ProductName NOT LIKE '%Paste%') OR
                    (ProductName LIKE 'Banana%'    AND ProductName NOT LIKE '%Leaves%') OR
                    (ProductName LIKE 'Potatoes%'  AND ProductName     LIKE '%Idaho%') OR
                    (ProductName LIKE 'Beans%'     AND ProductName NOT LIKE '%Kidney%') OR
                    (ProductName LIKE '%Apricots%' AND ProductName     LIKE '%Fresh%')
                     THEN 10
                -- Kitchenware & Cookware
                WHEN ProductName LIKE '%Cheese%Cloth%' OR ProductName LIKE '% Pan %'
                     THEN 11
                -- Tableware & Serveware
                WHEN ProductName LIKE '%Table%' OR ProductName LIKE '%Sword%Pick%'  OR
                     ProductName LIKE 'Napkin%' OR ProductName LIKE '%Placemat%' OR
                     ProductName LIKE '%Tray%'  OR ProductName LIKE '%Skirt%'
                     THEN 12
                -- Packaging & Storage
                WHEN ProductName LIKE '%Box%Window%' OR ProductName LIKE '%Liners%' OR
                     ProductName LIKE 'Pail%'        OR ProductName LIKE '%Truffle%Cups%' OR
                     ProductName LIKE '%Vaccum%Bag%'
                     THEN 13
                -- Non-Food Items
                WHEN ProductName IN ('Dc Hikiage Hira Huba')
                     THEN 14
                -- Paper & Disposable
                WHEN ProductName LIKE '%Foam%'    OR ProductName LIKE '%Garbag%Bag%' OR
                     ProductName LIKE '%Cup%oz%'  OR ProductName LIKE '%Gloves%Disposable%' OR
                     ProductName LIKE '%Plastic%' OR 
                    (ProductName LIKE '%Paper%'  AND ProductName NOT LIKE '%Banana%') OR
                    (ProductName LIKE '%Napkin%' AND ProductName NOT LIKE '%Starched%')
                     THEN 15
                -- Cleaning Supplies
                WHEN ProductName LIKE '%Broom%'     OR ProductName LIKE 'Ecolab%' OR
                     ProductName LIKE '%Mophandle%' OR ProductName LIKE '%Trigger%'
                     THEN 16
                -- Apparel & Uniforms
                WHEN ProductName LIKE '%Hat%' OR ProductName LIKE '%Pants%'
                     THEN 17
                -- Hardware & Tools
                WHEN ProductName LIKE '%Hinge%' OR ProductName LIKE '%Thermometer%' 
                     THEN 18
                -- Seasonings & Spices
                WHEN ProductName LIKE '%Seed'          OR ProductName LIKE '%Paprika%' OR
                     ProductName LIKE '%Onion%Powder%' OR ProductName LIKE '%Wasabi%Powder%' OR
                     ProductName LIKE '%Bay%'          OR ProductName LIKE '%Cumin%' OR
                     ProductName LIKE '%Oregano%'      OR ProductName LIKE '%Rosemary%Dry%' OR
                     ProductName LIKE '%Wiberg%'       OR ProductName LIKE '%Sage%Ground%' OR
                     ProductName LIKE '%Otomegusa%'    OR
                    (ProductName LIKE '%Pepper%' AND ProductName NOT LIKE '%Soup%')
                     THEN 19
                -- Prepared Foods
                WHEN ProductName IN ('Pasta - Cheese / Spinach Bauletti', 'Pate - Cognac', 'Potatoes - Instant, Mashed', 
                                     'Quiche Assorted', 'Tofu - Firm', 'Tuna - Salad Premix', 'Vol Au Vents' ) OR 
                     ProductName LIKE 'Appetizer%' OR ProductName LIKE '%Wellington%' OR
                     ProductName LIKE 'Berry%'     OR ProductName LIKE '%Chicken - Soup%' OR
                     ProductName LIKE 'Chinese%'   OR ProductName LIKE '%Longos%' OR
                    (ProductName LIKE '%Crab%' AND ProductName NOT LIKE '%Dungeness%') OR
                    (ProductName LIKE '%Wrap%' AND ProductName NOT LIKE '%Muffin%')
                     THEN 20
                -- Snacks & Chips
                WHEN ProductName LIKE '%Bar%Granola%' OR ProductName LIKE 'Chips%' OR
                     ProductName LIKE 'Crackers%'
                     THEN 21
                -- Condiments & Sauces
                WHEN ProductName LIKE 'Sauce%'             OR ProductName LIKE '%Paste%' OR 
                     ProductName LIKE 'Vinegar%'           OR ProductName LIKE 'Puree%' OR 
                     ProductName LIKE 'Ketchup%'           OR ProductName LIKE 'Mayonnaise%' OR 
                     ProductName LIKE '%Mustard%Prepared%' OR ProductName LIKE '%Oil%Safflower%' OR 
                     ProductName LIKE '%Bouq%'             OR ProductName LIKE '%Olive%Spread%' OR 
                     ProductName LIKE '%Hickory%Smoke%'    OR ProductName LIKE '%Browning%Caramel%'
                     THEN 22
                -- Baking Supplies
                WHEN ProductName IN ('Vanilla Beans', 'Sugar - Fine', 'Extract - Lemon', 'Flavouring - Orange', 'Pie Filling - Cherry', 
                                     'Cream Of Tartar', 'Sponge Cake Mix - Chocolate', 'Tart Shells - Sweet, 4') OR 
                      ProductName LIKE 'Flour%'       OR ProductName LIKE '%Dough%' OR
                      ProductName LIKE '%Muffin%b%'   OR ProductName LIKE 'Fond%' OR
                      ProductName LIKE '%Shortening%' OR ProductName LIKE 'Coco%' OR
                      ProductName LIKE 'Baking%'      OR ProductName LIKE '%Yeast%'
                     THEN 23
                -- Frozen Foods
                WHEN ProductName LIKE '%Ice%Cream%' OR
                    (ProductName LIKE '%Frozen%' AND ProductName NOT LIKE '%Mussels%')
                     THEN 24
                -- Canned & Preserved
                WHEN ProductName LIKE '%Canned%' OR ProductName LIKE '%Figs%' OR
                     ProductName LIKE 'Olives%'  OR ProductName LIKE 'Sauerkraut%' OR
                     ProductName LIKE 'Soup %'   OR ProductName LIKE '%Dried%' OR
                    (ProductName LIKE 'Beans - Kidney%' AND ProductName NOT LIKE '%Dry%') OR
                    (ProductName LIKE 'Apricots%'       AND ProductName NOT LIKE '%Fresh%')
                     THEN 25
                -- Health & Beauty
                WHEN ProductName LIKE '%Bandage%'
                     THEN 26
                -- Miscellaneous
                WHEN ProductName IN ('Ice - Clear, 300 Lb For Carving', 'Banana - Leaves', 'Lambcasing')
                     THEN 27

                WHEN CAST(CategoryID AS INT) < 0 THEN ABS(CAST(CategoryID AS INT))
                ELSE CAST(CategoryID AS INT)
            END AS CategoryID,
            CASE 
                WHEN Class IS NULL THEN 'Unknown'
                WHEN TRIM(Class) NOT IN ('Low','Medium','High') THEN 'Unknown'
                ELSE TRIM(Class)
            END AS Class,
            ModifyDate,
            CASE 
                WHEN Resistant IS NULL OR Resistant = '' THEN 'Unknown'
                WHEN TRIM(Resistant) NOT IN ('Durable','Weak','Unknown') THEN 'Unknown'
                ELSE TRIM(Resistant)
            END AS Resistant,
            CASE 
                WHEN IsAllergic IS NULL OR IsAllergic = '' THEN 'Unknown'
                WHEN TRIM(IsAllergic) NOT IN ('True','False','Unknown') THEN 'Unknown'
                ELSE TRIM(IsAllergic)
            END AS IsAllergic,
            CASE 
                WHEN ISNUMERIC(VitalityDays) = 0 THEN 0
                WHEN VitalityDays < 0 THEN 0
                WHEN VitalityDays > 365 THEN 365
                ELSE CAST(VitalityDays AS INT)
            END AS VitalityDays
        FROM Bronze.erp_products
        WHERE ProductID IS NOT NULL AND ISNUMERIC(ProductID) = 1;
        SET @EndTime = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Loading Silver.erp_employees
        SET @StartTime = GETDATE();
        PRINT '>> Truncating Table: Silver.erp_employees';
        TRUNCATE TABLE Silver.erp_employees;
        PRINT '>> Inserting Data Into: Silver.erp_employees';
        INSERT INTO Silver.erp_employees (
	        EmployeeID,
            FirstName,
            MiddleInitial,
            LastName,
            BirthDate,
            CurrentAge,
            Gender,
            CityID,
            HireDate,
            YearsOfService,
            EmploymentStatusCheck
        )
        SELECT
            CASE 
	            WHEN ISNUMERIC(EmployeeID) = 0 THEN 'n/a'
	            WHEN CAST(EmployeeID AS INT) < 0 THEN ABS(CAST(EmployeeID AS INT))
	            ELSE CAST(EmployeeID AS INT)
            END AS EmployeeID,
            CASE 
	            WHEN FirstName IS NULL OR TRIM(FirstName) = '' THEN 'n/a' 
	            ELSE dbo.ToProperCase(FirstName)
            END AS FirstName,
            CASE 
	            WHEN MiddleInitial IS NULL OR TRIM(MiddleInitial) = '' THEN 'n/a' 
	            WHEN LEN(TRIM(MiddleInitial)) > 1 OR (TRIM(MiddleInitial) <> '' AND TRIM(MiddleInitial) NOT LIKE '[A-Z]') THEN 'n/a'
	            ELSE UPPER(TRIM(MiddleInitial))
            END AS MiddleInitial,
            CASE 
		        WHEN LastName IS NULL OR TRIM(LastName) = '' THEN 'n/a' 
		        ELSE dbo.ToProperCase(LastName)
	        END AS LastName,
            CASE 
		        WHEN BirthDate > HireDate THEN  HireDate
		        ELSE BirthDate
	        END AS BirthDate,
            DATEDIFF(YEAR, BirthDate, GETDATE()) AS CurrentAge,
            CASE 
                WHEN TRIM(Gender) = 'M'  THEN 'Male'
                WHEN TRIM(Gender) = 'F'  THEN 'Female'
                WHEN TRIM(Gender) IN ('Male', 'Female')  THEN TRIM(Gender)
                ELSE 'n/a'
            END AS Gender,
            CASE 
		        WHEN ISNUMERIC(CityID) = 0 THEN 'n/a'
		        WHEN CAST(CityID AS INT) < 0 THEN ABS(CAST(CityID AS INT))
		        ELSE CAST(CityID AS INT)
	        END AS CityID,
            CASE 
		        WHEN BirthDate > HireDate THEN  BirthDate
		        ELSE HireDate
	        END AS HireDate,
            DATEDIFF(YEAR, HireDate, GETDATE()) AS YearsOfService,
            CASE 
                WHEN DATEDIFF(YEAR, BirthDate, HireDate) < 16 THEN 'Hired Under Legal Age'
                WHEN DATEDIFF(YEAR, BirthDate, GETDATE()) > 80 THEN 'Over 80 Years Old'
                WHEN DATEDIFF(YEAR, HireDate, GETDATE()) > 50 THEN 'Over 50 Years Service'
                ELSE 'Normal'
            END AS EmploymentStatusCheck
        FROM Bronze.erp_employees
        WHERE EmployeeID IS NOT NULL AND ISNUMERIC(EmployeeID) = 1;
        SET @EndTime = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Loading Silver.erp_sales
        SET @StartTime = GETDATE();
        PRINT '>> Truncating Table: Silver.erp_sales';
        TRUNCATE TABLE Silver.erp_sales;
        PRINT '>> Inserting Data Into: Silver.erp_sales';
        INSERT INTO Silver.erp_sales (
	        SalesID,
            SalesPersonID,
            CustomerID,
            ProductID,
            Quantity,
            Discount,
            TotalPrice,
            SalesDate,
            TransactionNumber,
            IsDateEstimated
        )
        SELECT
            CASE 
	            WHEN ISNUMERIC(s.SalesID) = 0 THEN 'n/a'
	            WHEN CAST(s.SalesID AS INT) < 0 THEN ABS(CAST(s.SalesID AS INT))
	            ELSE CAST(s.SalesID AS INT)
            END AS SalesID,
            CASE 
	            WHEN ISNUMERIC(s.SalesPersonID) = 0 THEN 'n/a'
	            WHEN CAST(s.SalesPersonID AS INT) < 0 THEN ABS(CAST(s.SalesPersonID AS INT))
	            ELSE CAST(s.SalesPersonID AS INT)
            END AS SalesPersonID,
            CASE 
	            WHEN ISNUMERIC(s.CustomerID) = 0 THEN 'n/a'
	            WHEN CAST(s.CustomerID AS INT) < 0 THEN ABS(CAST(s.CustomerID AS INT))
	            ELSE CAST(s.CustomerID AS INT)
            END AS CustomerID,
            CASE 
	            WHEN ISNUMERIC(s.ProductID) = 0 THEN 'n/a'
	            WHEN CAST(s.ProductID AS INT) < 0 THEN ABS(CAST(s.ProductID AS INT))
	            ELSE CAST(s.ProductID AS INT)
            END AS ProductID,
            CASE 
                WHEN s.Quantity <= 0 THEN 1
                ELSE s.Quantity
            END AS Quantity,
            CASE 
                WHEN s.Discount < 0 THEN 0
                WHEN s.Discount > 1 THEN 1
                ELSE ROUND(s.Discount, 2)
            END AS Discount,
            p.Price * s.Quantity * (1 - s.Discount) AS TotalPrice,
            CASE 
                WHEN s.SalesDate IS NULL THEN '1900-01-01 00:00:00.000'
                ELSE s.SalesDate
            END AS SalesDate,
            TRIM(s.TransactionNumber) AS TransactionNumber,
            CASE 
                WHEN s.SalesDate IS NULL THEN 'Yse'
                ELSE 'No'
            END AS IsDateEstimated
        FROM Bronze.erp_sales AS s
        INNER JOIN Bronze.erp_products AS p 
        ON s.ProductID = p.ProductID
        WHERE SalesID IS NOT NULL AND ISNUMERIC(SalesID) = 1;
        SET @EndTime = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        SET @BatchEndTime = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @BatchStartTime, @BatchEndTime) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
		
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END
