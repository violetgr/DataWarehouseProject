/*
===============================================================================================================
DDL Script:Create Gold Views
===============================================================================================================
Script Purpose:
              This script creates views for the Gold layer in the data warehouse.
              The Gold layer represents the final dimension and fact tables (Star Schema)
              
              Each view performs transformations and combines data from the Silver layer
              to produce a clean, enriched, and business-ready dataset.
Usage:
             - These views can be queried directly for analytics and reporting.
===============================================================================================================
*/
--=============================================================================================================
--Create gold.dim_Customers
--=============================================================================================================
IF OBJECT_ID('gold.dim_Customers','v') IS NOT NULL
	DROP VIEW gold.dim_Customers;
	GO
CREATE VIEW gold.dim_Customers AS
SELECT
ROW_NUMBER() OVER(ORDER BY cst_id) AS cutomer_key,
ci.cst_id AS Customer_id,
ci.cst_key AS Customer_Key,
ci.cst_firstname AS First_Name,
ci.cst_lastname AS Last_Name,
la.cntry AS Country,
ci.cst_marital_status AS Marital_Status,
CASE WHEN ci.cst_gndr !='n/a' THEN ci.cst_gndr --CRM is the Master for gender Info
	 ELSE COALESCE(ca.gen,'n/a')
END Gender,
ca.bdate AS Birthdate,
ci.cst_create_Data AS Create_Date

FROM silver.crm_Cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.Cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.Cid
GO
--=============================================================================================================
--Create gold.dim_Products
--=============================================================================================================
IF OBJECT_ID('gold.dim_products','v') IS NOT NULL
	DROP VIEW gold.dim_products;
	GO
CREATE VIEW gold.dim_products AS
SELECT
ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt,pn.prd_key) AS Product_Key,
pn.prd_id AS Product_id,
pn.prd_key AS Product_Number,
pn.prd_nm AS Product_Name,
pn.cat_id AS Category_id,
pc.cat AS Category,
pc.subcat AS Subcategory,
pc.maintenance,
pn.prd_cost AS Cost,
pn.prd_line AS Product_Line,
pn.prd_start_dt AS Start_Date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL --Filter out all historical data
GO
--=============================================================================================================
--Create gold.fact_sales
--=============================================================================================================
IF OBJECT_ID('gold.fact_sales','v') IS NOT NULL
	DROP VIEW gold.fact_sales;
	GO
CREATE VIEW gold.fact_sales AS
SELECT
sd.sls_Ord_num AS order_number,
pr.product_key,
cu.Customer_Key,
sd.sls_order_dt AS order_date,
sd.sls_ship_dt AS shipping_date,
sd.sls_due_dt AS due_date,
sd.sls_sales AS sales_amount,
sd.sls_quantity AS quantity,
sd.sls_price AS price
FROM silver.crm_sales_detailes sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_Customers cu
ON sd.sls_cust_id = cu.Customer_id
