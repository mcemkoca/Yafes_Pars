SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [YafesPars];
GO

PRINT 'Running migration: 014__add_triggers.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'014__add_triggers.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'014__add_triggers.sql',
            N'SUCCESS'
        );
    END;

    COMMIT TRANSACTION;
    PRINT 'Trigger phase registered. Root audit triggers are created in 011__create_audit_domain.sql.';
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
