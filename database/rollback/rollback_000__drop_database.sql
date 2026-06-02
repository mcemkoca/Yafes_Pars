SET NOCOUNT ON;
GO

USE [master];
GO

/*
    WARNING:
    This rollback is destructive. It drops the entire YafesPars database.
    It is intended for disposable development or test environments only.

    To run it, change @ConfirmDropDatabase from 0 to 1.
*/
DECLARE @ConfirmDropDatabase BIT = 0;

IF @ConfirmDropDatabase <> 1
    THROW 59000, 'Rollback blocked. Set @ConfirmDropDatabase = 1 only for disposable environments.', 1;

IF DB_ID(N'YafesPars') IS NOT NULL
BEGIN
    ALTER DATABASE [YafesPars] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [YafesPars];
    PRINT 'Dropped database: YafesPars';
END
ELSE
BEGIN
    PRINT 'Database does not exist: YafesPars';
END;
GO
