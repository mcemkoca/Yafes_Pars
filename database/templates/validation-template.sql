SET NOCOUNT ON;
GO

IF OBJECT_ID('<schema>.<TableName>', 'U') IS NULL
    THROW 50001, 'Missing table: <schema>.<TableName>', 1;

PRINT 'Validation passed: <validation_name>';
GO
