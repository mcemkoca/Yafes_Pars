-- =============================================================================
-- Validation 028: üretim hazırlık SP'lerini doğrula
-- =============================================================================
USE [YafesPars];
GO

-- 028-001: SP_ProductionReadinessCheck var mı?
IF NOT EXISTS (
    SELECT 1 FROM sys.procedures p
    JOIN sys.schemas s ON s.schema_id = p.schema_id
    WHERE s.name = N'core' AND p.name = N'SP_ProductionReadinessCheck'
)
BEGIN
    RAISERROR (N'[028-001] core.SP_ProductionReadinessCheck bulunamadi.', 16, 1);
    RETURN;
END;

-- 028-002: SP_PurgeDemoData var mı?
IF NOT EXISTS (
    SELECT 1 FROM sys.procedures p
    JOIN sys.schemas s ON s.schema_id = p.schema_id
    WHERE s.name = N'core' AND p.name = N'SP_PurgeDemoData'
)
BEGIN
    RAISERROR (N'[028-002] core.SP_PurgeDemoData bulunamadi.', 16, 1);
    RETURN;
END;

-- 028-003: SystemSetting 'environment' değeri var mı?
IF NOT EXISTS (SELECT 1 FROM core.SystemSetting WHERE setting_key = N'environment')
BEGIN
    RAISERROR (N'[028-003] SystemSetting environment anahtari bulunamadi.', 16, 1);
    RETURN;
END;

-- 028-004: SchemaMigration tablosu dolu mu? (en az 30 migration)
DECLARE @migration_count INT = (SELECT COUNT(*) FROM core.SchemaMigration WHERE execution_status = N'SUCCESS');
IF @migration_count < 30
BEGIN
    RAISERROR (N'[028-004] Yeterli migration kaydi yok (beklenen >= 30, mevcut: %d).', 16, 1, @migration_count);
    RETURN;
END;

PRINT 'Validation 028 OK: uretim hazirlik SP''leri dogrulandi.';
GO
