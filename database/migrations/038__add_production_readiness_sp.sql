-- =============================================================================
-- Migration 038: üretim hazırlık kontrol SP'si
-- PROD ortamında tehlikeli işlemleri engelleyen ve hazırlık durumunu raporlayan SP.
-- =============================================================================
USE [YafesPars];
GO

BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'038__add_production_readiness_sp')
        INSERT INTO core.SchemaMigration (migration_name, execution_status)
        VALUES (N'038__add_production_readiness_sp', N'SUCCESS');
COMMIT TRANSACTION;
GO

-- SP: Üretim hazırlık kontrolü — tüm migration ve validation durumlarını özetler.
CREATE OR ALTER PROCEDURE core.SP_ProductionReadinessCheck
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    DECLARE @environment    NVARCHAR(100) = (SELECT setting_value FROM core.SystemSetting WHERE setting_key = N'environment');
    DECLARE @demo_seeded    NVARCHAR(10)  = (SELECT setting_value FROM core.SystemSetting WHERE setting_key = N'demo_data_seeded');
    DECLARE @migration_count INT = (SELECT COUNT(*) FROM core.SchemaMigration WHERE execution_status = N'SUCCESS');
    DECLARE @tenant_count   INT = (SELECT COUNT(*) FROM core.Tenant WHERE is_active = 1);
    DECLARE @user_count     INT = (SELECT COUNT(*) FROM core.AppUser WHERE is_active = 1);
    DECLARE @active_contracts INT = (SELECT COUNT(*) FROM policy.Contract WHERE is_deleted = 0 AND contract_status_code = N'ACTIVE');
    DECLARE @open_claims    INT = (SELECT COUNT(*) FROM claim.Claim WHERE is_deleted = 0 AND claim_status_code NOT IN (N'CLOSED', N'REJECTED', N'PAID'));
    DECLARE @overdue_invoices INT = (SELECT COUNT(*) FROM finance.Invoices WHERE StatusCode IN (N'OVERDUE', N'PENDING') AND DueDate < CAST(GETUTCDATE() AS DATE));

    -- Güvenlik kontrolleri
    DECLARE @is_prod BIT = CASE WHEN @environment = N'PROD' THEN 1 ELSE 0 END;
    DECLARE @demo_warning BIT = CASE WHEN @demo_seeded = N'1' AND @is_prod = 1 THEN 1 ELSE 0 END;

    -- Hazırlık puanı
    DECLARE @readiness_issues INT = 0;
    IF @is_prod = 0              SET @readiness_issues = @readiness_issues + 1; -- PROD ayarı yok
    IF @demo_warning = 1         SET @readiness_issues = @readiness_issues + 2; -- Demo data PROD'da
    IF @tenant_count = 0         SET @readiness_issues = @readiness_issues + 1; -- Tenant yok
    IF @migration_count < 30     SET @readiness_issues = @readiness_issues + 1; -- Migrasyon eksik

    SELECT
        @environment        AS Environment,
        @migration_count    AS AppliedMigrations,
        @tenant_count       AS ActiveTenants,
        @user_count         AS ActiveUsers,
        @active_contracts   AS ActiveContracts,
        @open_claims        AS OpenClaims,
        @overdue_invoices   AS OverdueInvoices,
        @is_prod            AS IsProduction,
        @demo_seeded        AS DemoDataSeeded,
        @demo_warning       AS DemoWarning,
        @readiness_issues   AS ReadinessIssues,
        CASE
            WHEN @readiness_issues = 0 THEN N'READY'
            WHEN @readiness_issues <= 2 THEN N'WARNING'
            ELSE                             N'NOT_READY'
        END                 AS ReadinessStatus,
        GETUTCDATE()        AS CheckedAtUtc;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

-- SP: Demo veri temizleme kilidi — PROD'da demo data silinmesini engeller (onay gerektirir).
-- @confirm_token geçerliyse devam eder; bu token üretimde ortam değişkeninden alınmalıdır.
CREATE OR ALTER PROCEDURE core.SP_PurgeDemoData
    @confirm_token NVARCHAR(100)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    DECLARE @environment NVARCHAR(100) = (SELECT setting_value FROM core.SystemSetting WHERE setting_key = N'environment');
    DECLARE @demo_seeded NVARCHAR(10)  = (SELECT setting_value FROM core.SystemSetting WHERE setting_key = N'demo_data_seeded');

    IF @demo_seeded <> N'1'
    BEGIN
        SELECT N'Demo verisi bulunamadı veya zaten temizlendi.' AS Result, 0 AS RowsPurged;
        RETURN;
    END

    IF @confirm_token <> N'PURGE-DEMO-DATA-CONFIRM'
        THROW 60100, N'confirm_token geçersiz. Devam için: PURGE-DEMO-DATA-CONFIRM', 1;

    DECLARE @rows_affected INT = 0;

    -- Demo audit kayıtlarını temizle (source_system = 'DEMO_SEED')
    DELETE FROM audit.AuditLog WHERE source_system = N'DEMO_SEED';
    SET @rows_affected = @rows_affected + @@ROWCOUNT;

    UPDATE core.SystemSetting
    SET setting_value = N'0', updated_at_utc = SYSUTCDATETIME()
    WHERE setting_key = N'demo_data_seeded';

    SELECT
        N'Demo audit kayıtları temizlendi.' AS Result,
        @rows_affected AS RowsPurged;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

PRINT 'Migration 038 tamamlandi: uretim hazirlik SP''leri.';
GO
