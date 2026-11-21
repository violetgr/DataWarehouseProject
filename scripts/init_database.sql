--create Database 'DataWarehouse'

USE master;
GO
--Drop and Recreate the 'DataWarehouse' dataset
IF EXISTS (SELECT 1 FROM sys.databases WHERE name='DataWarehouse')
BEGIN
     ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
     DROP DATABASE DataWarehouse;
END;
GO
--CREATE THE 'DataWarehouse' DATABASE

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

--Create Schemas

CREATE SCHEMA bronze;
GO
CREATE SCHEMA Silver;
GO
CREATE SCHEMA Gold;
GO
