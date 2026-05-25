-- =============================================================
-- AssureManager Database Creation Script
-- Belgian Insurance Management System
-- =============================================================
-- Run this first on your SQL Server instance
-- 
-- Usage: sqlcmd -S localhost -i 01_create_database.sql
-- =============================================================

SET NOCOUNT ON;
GO

PRINT '======================================================';
PRINT ' AssureManagerDB - Database Creation';
PRINT '======================================================';
GO

USE master;
GO

-- Drop database if exists (use with caution!)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'AssureManagerDB')
BEGIN
    PRINT 'Dropping existing AssureManagerDB...';
    ALTER DATABASE AssureManagerDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AssureManagerDB;
    PRINT 'Existing database dropped.';
END
GO

-- Create database
PRINT 'Creating AssureManagerDB...';
CREATE DATABASE AssureManagerDB
    COLLATE Latin1_General_CI_AS;
GO

-- Set database options
ALTER DATABASE AssureManagerDB SET RECOVERY SIMPLE;
ALTER DATABASE AssureManagerDB SET AUTO_SHRINK OFF;
ALTER DATABASE AssureManagerDB SET AUTO_CREATE_STATISTICS ON;
ALTER DATABASE AssureManagerDB SET AUTO_UPDATE_STATISTICS ON;
GO

-- Create filegroups for large tables (optional optimization)
ALTER DATABASE AssureManagerDB ADD FILEGROUP FG_DATA;
ALTER DATABASE AssureManagerDB ADD FILEGROUP FG_INDEXES;
GO

USE AssureManagerDB;
GO

PRINT '';
PRINT '======================================================';
PRINT ' AssureManagerDB created successfully!';
PRINT ' Collation: Latin1_General_CI_AS';
PRINT '======================================================';
GO
