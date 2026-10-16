-- ShopBridge local development bootstrap (SQL Server).
-- NON-DESTRUCTIVE: unlike the legacy script.sql, this does not DROP DATABASE or DROP TABLE.
-- REVIEW BEFORE EXECUTING. Intended for a fresh/disposable local SQL Server instance.
-- Re-running updates the four stored procedure definitions but preserves existing rows.
-- SQL Server 2016 SP1+ required for CREATE OR ALTER PROCEDURE.

IF DB_ID(N'db_ShopBridge') IS NULL
BEGIN
    CREATE DATABASE [db_ShopBridge];
END;
GO

USE [db_ShopBridge];
GO

IF OBJECT_ID(N'dbo.product', N'U') IS NULL
BEGIN
    -- Mirrors the original legacy schema (no PRIMARY KEY declared in script.sql).
    CREATE TABLE dbo.product
    (
        product_id INT IDENTITY(1,1) NOT NULL,
        [name] NVARCHAR(MAX) NOT NULL,
        [description] NVARCHAR(MAX) NULL,
        [price] MONEY NOT NULL
    );
END;
GO

CREATE OR ALTER PROCEDURE dbo.[list]
AS
BEGIN
    SELECT * FROM dbo.product;
END;
GO

CREATE OR ALTER PROCEDURE dbo.p_addItem
    @name NVARCHAR(MAX),
    @desc NVARCHAR(MAX),
    @price MONEY
AS
BEGIN
    INSERT INTO dbo.product ([name], [description], [price])
    VALUES (@name, @desc, @price);
END;
GO

CREATE OR ALTER PROCEDURE dbo.p_updateItem
    @product_id INT,
    @name NVARCHAR(MAX),
    @desc NVARCHAR(MAX),
    @price MONEY
AS
BEGIN
    UPDATE dbo.product
       SET [name] = @name,
           [description] = @desc,
           [price] = @price
     WHERE product_id = @product_id;
END;
GO

CREATE OR ALTER PROCEDURE dbo.p_deleteItem
    @product_id INT
AS
BEGIN
    DELETE FROM dbo.product
     WHERE product_id = @product_id;
END;
GO

-- Optional inspection:
-- SELECT TOP (10) product_id, name, description, price FROM dbo.product;
