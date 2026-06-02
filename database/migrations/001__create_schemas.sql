SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [YafesPars];
GO

PRINT 'Running migration: 001__create_schemas.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF SCHEMA_ID(N'core') IS NULL
        EXEC(N'CREATE SCHEMA core AUTHORIZATION dbo;');

    IF SCHEMA_ID(N'ref') IS NULL
        EXEC(N'CREATE SCHEMA ref AUTHORIZATION dbo;');

    IF SCHEMA_ID(N'person') IS NULL
        EXEC(N'CREATE SCHEMA person AUTHORIZATION dbo;');

    IF SCHEMA_ID(N'institution') IS NULL
        EXEC(N'CREATE SCHEMA institution AUTHORIZATION dbo;');

    IF SCHEMA_ID(N'risk') IS NULL
        EXEC(N'CREATE SCHEMA risk AUTHORIZATION dbo;');

    IF SCHEMA_ID(N'policy') IS NULL
        EXEC(N'CREATE SCHEMA policy AUTHORIZATION dbo;');

    IF SCHEMA_ID(N'coverage') IS NULL
        EXEC(N'CREATE SCHEMA coverage AUTHORIZATION dbo;');

    IF SCHEMA_ID(N'claim') IS NULL
        EXEC(N'CREATE SCHEMA claim AUTHORIZATION dbo;');

    IF SCHEMA_ID(N'document') IS NULL
        EXEC(N'CREATE SCHEMA document AUTHORIZATION dbo;');

    IF SCHEMA_ID(N'tasking') IS NULL
        EXEC(N'CREATE SCHEMA tasking AUTHORIZATION dbo;');

    IF SCHEMA_ID(N'audit') IS NULL
        EXEC(N'CREATE SCHEMA audit AUTHORIZATION dbo;');

    COMMIT TRANSACTION;
    PRINT 'Migration completed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;
GO
