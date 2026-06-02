SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [YafesPars];
GO

PRINT 'Running migration: 002__create_core_infrastructure.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'core.SchemaMigration', N'U') IS NULL
    BEGIN
        CREATE TABLE core.SchemaMigration (
            migration_id INT IDENTITY(1,1) NOT NULL,
            migration_name NVARCHAR(255) NOT NULL,
            checksum NVARCHAR(128) NULL,
            executed_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_SchemaMigration_executed_at_utc DEFAULT SYSUTCDATETIME(),
            executed_by SYSNAME NOT NULL
                CONSTRAINT DF_SchemaMigration_executed_by DEFAULT SUSER_SNAME(),
            execution_status NVARCHAR(20) NOT NULL,
            error_message NVARCHAR(MAX) NULL,
            CONSTRAINT PK_SchemaMigration PRIMARY KEY (migration_id),
            CONSTRAINT UQ_SchemaMigration_migration_name UNIQUE (migration_name),
            CONSTRAINT CK_SchemaMigration_execution_status
                CHECK (execution_status IN (N'SUCCESS', N'FAILED'))
        );
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'002__create_core_infrastructure.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'002__create_core_infrastructure.sql',
            N'SUCCESS'
        );
    END;

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
