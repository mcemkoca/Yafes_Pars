SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [YafesPars];
GO

PRINT 'Running migration: 012__add_constraints.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = N'FK_InsurableLoan_Periodicity'
          AND parent_object_id = OBJECT_ID(N'risk.InsurableLoan')
    )
    BEGIN
        ALTER TABLE risk.InsurableLoan
            ADD CONSTRAINT FK_InsurableLoan_Periodicity
            FOREIGN KEY (interest_periodicity_code)
            REFERENCES policy.Periodicity (periodicity_code);
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = N'FK_InsurableLoan_DurationType'
          AND parent_object_id = OBJECT_ID(N'risk.InsurableLoan')
    )
    BEGIN
        ALTER TABLE risk.InsurableLoan
            ADD CONSTRAINT FK_InsurableLoan_DurationType
            FOREIGN KEY (duration_type_code)
            REFERENCES policy.DurationType (duration_type_code);
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = N'FK_InsurableObject_AppUser_CreatedBy'
          AND parent_object_id = OBJECT_ID(N'risk.InsurableObject')
    )
    BEGIN
        ALTER TABLE risk.InsurableObject
            ADD CONSTRAINT FK_InsurableObject_AppUser_CreatedBy
            FOREIGN KEY (created_by_user_id)
            REFERENCES core.AppUser (user_id);
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = N'FK_InsurableObject_AppUser_UpdatedBy'
          AND parent_object_id = OBJECT_ID(N'risk.InsurableObject')
    )
    BEGIN
        ALTER TABLE risk.InsurableObject
            ADD CONSTRAINT FK_InsurableObject_AppUser_UpdatedBy
            FOREIGN KEY (updated_by_user_id)
            REFERENCES core.AppUser (user_id);
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = N'FK_ContractVersion_AppUser_CreatedBy'
          AND parent_object_id = OBJECT_ID(N'policy.ContractVersion')
    )
    BEGIN
        ALTER TABLE policy.ContractVersion
            ADD CONSTRAINT FK_ContractVersion_AppUser_CreatedBy
            FOREIGN KEY (created_by_user_id)
            REFERENCES core.AppUser (user_id);
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = N'FK_ContractVersion_AppUser_UpdatedBy'
          AND parent_object_id = OBJECT_ID(N'policy.ContractVersion')
    )
    BEGIN
        ALTER TABLE policy.ContractVersion
            ADD CONSTRAINT FK_ContractVersion_AppUser_UpdatedBy
            FOREIGN KEY (updated_by_user_id)
            REFERENCES core.AppUser (user_id);
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'012__add_constraints.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'012__add_constraints.sql',
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
