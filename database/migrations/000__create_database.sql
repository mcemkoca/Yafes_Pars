SET NOCOUNT ON;
GO

USE [master];
GO

PRINT 'Running migration: 000__create_database.sql';
GO

IF DB_ID(N'YafesPars') IS NULL
BEGIN
    CREATE DATABASE [YafesPars];
    PRINT 'Database created: YafesPars';
END
ELSE
BEGIN
    PRINT 'Database already exists: YafesPars';
END;
GO

PRINT 'Migration completed successfully.';
GO
