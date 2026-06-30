-- =============================================================================
-- Validation 027: tenant yönetim SP'lerini doğrula
-- =============================================================================
USE [YafesPars];
GO

-- 027-001: SP_GetTenants var mı?
IF NOT EXISTS (
    SELECT 1 FROM sys.procedures p
    JOIN sys.schemas s ON s.schema_id = p.schema_id
    WHERE s.name = N'core' AND p.name = N'SP_GetTenants'
)
BEGIN
    RAISERROR (N'[027-001] core.SP_GetTenants bulunamadi.', 16, 1);
    RETURN;
END;

-- 027-002: SP_DeactivateTenant var mı?
IF NOT EXISTS (
    SELECT 1 FROM sys.procedures p
    JOIN sys.schemas s ON s.schema_id = p.schema_id
    WHERE s.name = N'core' AND p.name = N'SP_DeactivateTenant'
)
BEGIN
    RAISERROR (N'[027-002] core.SP_DeactivateTenant bulunamadi.', 16, 1);
    RETURN;
END;

-- 027-003: SP_GetSystemSettings var mı?
IF NOT EXISTS (
    SELECT 1 FROM sys.procedures p
    JOIN sys.schemas s ON s.schema_id = p.schema_id
    WHERE s.name = N'core' AND p.name = N'SP_GetSystemSettings'
)
BEGIN
    RAISERROR (N'[027-003] core.SP_GetSystemSettings bulunamadi.', 16, 1);
    RETURN;
END;

-- 027-004: SP_UpsertSystemSetting var mı?
IF NOT EXISTS (
    SELECT 1 FROM sys.procedures p
    JOIN sys.schemas s ON s.schema_id = p.schema_id
    WHERE s.name = N'core' AND p.name = N'SP_UpsertSystemSetting'
)
BEGIN
    RAISERROR (N'[027-004] core.SP_UpsertSystemSetting bulunamadi.', 16, 1);
    RETURN;
END;

-- 027-005: SP_TenantIsolationCheck var mı?
IF NOT EXISTS (
    SELECT 1 FROM sys.procedures p
    JOIN sys.schemas s ON s.schema_id = p.schema_id
    WHERE s.name = N'core' AND p.name = N'SP_TenantIsolationCheck'
)
BEGIN
    RAISERROR (N'[027-005] core.SP_TenantIsolationCheck bulunamadi.', 16, 1);
    RETURN;
END;

PRINT 'Validation 027 OK: tenant yönetim SP''leri dogrulandi.';
GO
