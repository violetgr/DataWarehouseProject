/*
========================================================================================================================
Quality Checks
========================================================================================================================
Script Purpose:
tests
This script performs quality checks to validate the integrity, consistency
and accuracy of the Gold Layer. These checks ensure:
    -uniqueness of surrogate keys in dimension tables.
    -Referential integrity between fact and dimention tables.
    -validation ofrelationships in the gold model for analytical purpose.


Usage Notes:

- Run these checks after data loading Silver layer
- Investigate and resolve any discrepancies found during the checks
the checks.
*/
