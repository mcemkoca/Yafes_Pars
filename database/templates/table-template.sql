SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

PRINT 'Running migration: <migration_name>';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('<schema>.<TableName>', 'U') IS NULL
    BEGIN
        CREATE TABLE <schema>.<TableName> (
            table_name_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_TableName_id DEFAULT NEWSEQUENTIALID(),
            created_at_utc DATETIME2(0) NOT NULL CONSTRAINT DF_TableName_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL CONSTRAINT DF_TableName_updated_at_utc DEFAULT SYSUTCDATETIME(),
            CONSTRAINT PK_TableName PRIMARY KEY (table_name_id)
        );
    END;

    COMMIT TRANSACTION;
    PRINT 'Migration completed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO
