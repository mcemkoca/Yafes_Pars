-- =============================================================================
-- Validation 026: operasyonel dashboard SP'lerini doğrula
-- =============================================================================
USE [YafesPars];
GO

-- 026-001: SP_OperationalDashboard var mı?
IF NOT EXISTS (
    SELECT 1 FROM sys.procedures p
    JOIN sys.schemas s ON s.schema_id = p.schema_id
    WHERE s.name = N'reporting' AND p.name = N'SP_OperationalDashboard'
)
BEGIN
    RAISERROR (N'[026-001] reporting.SP_OperationalDashboard bulunamadi.', 16, 1);
    RETURN;
END;

-- 026-002: SP_TenantHealthScore var mı?
IF NOT EXISTS (
    SELECT 1 FROM sys.procedures p
    JOIN sys.schemas s ON s.schema_id = p.schema_id
    WHERE s.name = N'reporting' AND p.name = N'SP_TenantHealthScore'
)
BEGIN
    RAISERROR (N'[026-002] reporting.SP_TenantHealthScore bulunamadi.', 16, 1);
    RETURN;
END;

-- 026-003: SP_RecentActivity var mı?
IF NOT EXISTS (
    SELECT 1 FROM sys.procedures p
    JOIN sys.schemas s ON s.schema_id = p.schema_id
    WHERE s.name = N'reporting' AND p.name = N'SP_RecentActivity'
)
BEGIN
    RAISERROR (N'[026-003] reporting.SP_RecentActivity bulunamadi.', 16, 1);
    RETURN;
END;

PRINT 'Validation 026 OK: operasyonel dashboard SP''leri dogrulandi.';
GO
