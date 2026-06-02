SET NOCOUNT ON;
GO

USE [YafesPars];
GO

/*
    WARNING:
    This rollback is destructive. It drops project objects inside YafesPars.
    It is intended for disposable development or test environments only.

    To run it, change @ConfirmDropObjects from 0 to 1.
*/
DECLARE @ConfirmDropObjects BIT = 0;

IF @ConfirmDropObjects <> 1
    THROW 59001, 'Rollback blocked. Set @ConfirmDropObjects = 1 only for disposable environments.', 1;

PRINT 'Use rollback_000__drop_database.sql for a full disposable rebuild.';
PRINT 'Object-level rollback is intentionally guarded and not expanded for production use.';
GO
