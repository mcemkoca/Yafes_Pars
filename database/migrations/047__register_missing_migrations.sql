-- =============================================================================
-- Migration 047: Register migrations 043 and 044 in core.SchemaMigration
--
-- Migrations 039-044 were implemented before the SchemaMigration tracking
-- pattern was established.  They create their objects idempotently (IF NOT
-- EXISTS) but never recorded their own completion marker.  This migration
-- back-fills all six rows so the tracking table accurately reflects which
-- migrations have been applied.
-- =============================================================================
USE [YafesPars];
GO

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;
BEGIN TRY

    IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'047__register_missing_migrations')
    BEGIN

        -- Back-fill 039: complaint management domain
        IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'039__add_complaint_management')
            INSERT INTO core.SchemaMigration (migration_name, execution_status)
            VALUES (N'039__add_complaint_management', N'SUCCESS');

        -- Back-fill 040: renewal pipeline domain
        IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'040__add_renewal_pipeline')
            INSERT INTO core.SchemaMigration (migration_name, execution_status)
            VALUES (N'040__add_renewal_pipeline', N'SUCCESS');

        -- Back-fill 041: premium calculator domain
        IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'041__add_premium_calculator')
            INSERT INTO core.SchemaMigration (migration_name, execution_status)
            VALUES (N'041__add_premium_calculator', N'SUCCESS');

        -- Back-fill 042: assurance domain (quality control framework)
        IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'042__create_assurance_domain')
            INSERT INTO core.SchemaMigration (migration_name, execution_status)
            VALUES (N'042__create_assurance_domain', N'SUCCESS');

        -- Back-fill 043: import schema + LegacyPerson/Contract/Claim staging
        IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'043__create_import_staging')
            INSERT INTO core.SchemaMigration (migration_name, execution_status)
            VALUES (N'043__create_import_staging', N'SUCCESS');

        -- Back-fill 044: claim.ClaimSettlement + SP_CreateSettlement, SP_ApproveSettlement
        IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'044__add_claim_settlement')
            INSERT INTO core.SchemaMigration (migration_name, execution_status)
            VALUES (N'044__add_claim_settlement', N'SUCCESS');

        INSERT INTO core.SchemaMigration (migration_name, execution_status)
        VALUES (N'047__register_missing_migrations', N'SUCCESS');

        PRINT 'Migration 047: SchemaMigration entries added for 039-044.';
    END

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

PRINT 'Migration 047 complete.';
GO
