/*
============================================================================================
Quality Checks
============================================================================================
Script Purpose:
This script performs various quality checks for data consistency, accuracy,
and standardization across the 'silver' schema. It includes checks for:
- Null or duplicate primary keys.
- Unwanted Ses in string fields.
- Data staneledization and consistency.
- Invalid date ranges and orders.
- Data consistency between related fields.

Usage Notes:
- Run these checks after data loading Silver Layer.
- Investigate and resolve any discrepancies found during the checks.
============================================================================================
*/
============================================================================================
SELECT cst_id, COUNT(*) 
FROM silver.crm_Cust_info 
GROUP BY cst_id 
HAVING COUNT(*) > 1;
