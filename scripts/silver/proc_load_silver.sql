--EXEC silver.load_silver;
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME,@END_time DATETIME,@batch_start_time DATETIME,@batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time= GETDATE();
		PRINT'==========================================================';
		PRINT'Loading Silver Layer';
		PRINT'==========================================================';
		PRINT'----------------------------------------------------------';
		PRINT'Loading CRM Tables';
		PRINT'----------------------------------------------------------';

		--Loading silver.crm_Cust_info
		SET @start_time= GETDATE();
		PRINT'<<Truncating Table: silver.crm_Cust_info';
		TRUNCATE TABLE silver.crm_Cust_info;
		PRINT'<<Inserting Table: silver.crm_Cust_info';
		INSERT INTO silver.crm_Cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_Data
			)
			SELECT
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,

			CASE WHEN UPPER(cst_marital_status) = 'S' THEN 'Single'
					WHEN UPPER(cst_marital_status) = 'M' THEN 'Married'
					ELSE 'n/a'
			END cst_material_status,
			CASE WHEN UPPER(cst_gndr) = 'F' THEN 'Female'
					WHEN UPPER(cst_gndr) = 'M' THEN 'Male'
					ELSE 'n/a'
			END cst_gndr,
			cst_create_Data
			FROM
			(SELECT
			*,
			ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_data DESC) AS flag_last
			FROM bronze.crm_Cust_info
			)t 
			WHERE flag_last = 1
			SET @END_time=GETDATE();
			PRINT'Loading Duration:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ 'Seconds'
			PRINT'------------------------------'


		--Loading Silver.crm_prd_info
		SET @start_time= GETDATE();
		PRINT'<<Truncating Table:Silver.crm_prd_info';
		TRUNCATE TABLE Silver.crm_prd_info;
		PRINT'<<Inserting Table:Silver.crm_prd_info';
		INSERT INTO Silver.crm_prd_info(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
			)
			SELECT 
			prd_id,
			REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
			SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
			prd_nm,
			ISNULL(prd_cost,0) AS prd_cost,
			CASE UPPER(TRIM(prd_line))
				 WHEN 'M' THEN 'Mountain'
				 WHEN 'R' THEN 'Road'
				 WHEN 'S' THEN 'Other Sales'
				 WHEN 'T' THEN 'Touring'
				ELSE 'n/a'
			END prd_line,
			CAST(prd_start_dt AS DATE) AS prd_start_dt,
			CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
			FROM bronze.crm_prd_info
			SET @END_time=GETDATE();
			PRINT'Loading Duration:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ 'Seconds'
			PRINT'------------------------------'

		--Loading Silver.crm_prd_info
		SET @start_time= GETDATE();
		PRINT'<<Truncating Table:silver.crm_sales_detailes';
		TRUNCATE TABLE silver.crm_sales_detailes;
		PRINT'<<Inserting Table:silver.crm_sales_detailes';
		INSERT INTO silver.crm_sales_detailes(
			sls_Ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
			)  
			SELECT
			sls_Ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE WHEN sls_order_dt =0 OR LEN(sls_order_dt) !=8 THEN NULL
					ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END sls_order_dt,
			CASE WHEN sls_ship_dt =0 OR LEN(sls_ship_dt) !=8 THEN NULL
					ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END sls_ship_dt,
			CASE WHEN sls_due_dt =0 OR LEN(sls_due_dt) !=8 THEN NULL
					ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END sls_due_dt,
			CASE WHEN sls_sales IS NULL OR sls_sales<=0 OR sls_sales!= sls_quantity * ABS(sls_price)
					THEN sls_quantity * ABS(sls_price)
					ELSE sls_sales
			END AS sls_sales,
			sls_quantity,
			CASE WHEN sls_price IS NULL OR sls_price <= 0
					THEN sls_sales / NULLIF(sls_quantity,0)
					ELSE sls_price
			END sls_price
			FROM bronze.crm_sales_detailes
			SET @END_time=GETDATE();
			PRINT'Loading Duration:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ 'Seconds'
			PRINT'------------------------------'


		--Loading silver.erp_cust_az12
		SET @start_time= GETDATE();
		PRINT'<<Truncating Table:silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT'<<Inserting Table:silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12(
			cid,bdate,gen
			)
			SELECT 
			CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
				 ELSE cid
			END Cid,
			CASE WHEN bdate> GETDATE() THEN NULL
				 ELSE bdate
			END bdate,
			CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
				 WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
				 ELSE 'n/a'
			END  gen
			FROM bronze.erp_cust_az12
			SET @END_time=GETDATE();
			PRINT'Loading Duration:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ 'Seconds'
			PRINT'------------------------------'

		--Loading silver.erp_loc_a101
		SET @start_time= GETDATE();
		PRINT'<<Truncating Table:silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT'<<Inserting Table:silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101(
			Cid,
			cntry
			)
			SELECT
			REPLACE(Cid,'-','') Cid,
			CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				 WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
				 WHEN UPPER(TRIM(cntry)) IN ('UNITED KINGDOM','US') THEN 'US'
				 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
				 ELSE TRIM(cntry)
			END  cntry
			FROM bronze.erp_loc_a101
			SET @END_time=GETDATE();
			PRINT'Loading Duration:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ 'Seconds'
			PRINT'------------------------------'

		--Loading Silver.erp_px_cat_g1v2
		SET @start_time= GETDATE();
		PRINT'<<Truncating Table:Silver.erp_px_cat_g1v2';
		TRUNCATE TABLE Silver.erp_px_cat_g1v2;
		PRINT'<<Inserting Table:Silver.erp_px_cat_g1v2';
		INSERT INTO Silver.erp_px_cat_g1v2(
			id,
			cat,
			subcat,
			maintenance
			)
			SELECT
			id,
			cat,
			subcat,
			maintenance
			FROM bronze.erp_px_cat_g1v2
			SET @END_time=GETDATE();
			PRINT'Loading Duration:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ 'Seconds'
			PRINT'------------------------------'


			SET @batch_end_time = GETDATE();
			PRINT'======================================================================================================';
			PRINT'Loading Silver Layer is Completed';
			PRINT'Total Loading Duration:' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR)+ 'Seconds';
			PRINT'=======================================================================================================';
	END TRY
	BEGIN CATCH
			PRINT'==============================================================================';
			PRINT'ERROR OCCURED DURING LOADING SILVER LAYER'
			PRINT 'Error message' +ERROR_MESSAGE();
			PRINT 'Error message' +CAST(ERROR_NUMBER() AS NVARCHAR);
			PRINT 'Error message' +CAST(ERROR_STATE() AS NVARCHAR);
			PRINT'==============================================================================';
	END CATCH
END
