-- =============================================================================
-- Validation 030: yenileme pipeline tablo ve SP doğrulama
-- =============================================================================
USE [YafesPars];
GO

-- 030-001: policy.RenewalQueue tablosu
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID(N'policy') AND name = N'RenewalQueue')
BEGIN
    RAISERROR (N'[030-001] policy.RenewalQueue tablosu bulunamadi.', 16, 1);
    RETURN;
END;

-- 030-002: SP_GetRenewalQueue
IF NOT EXISTS (SELECT 1 FROM sys.procedures p JOIN sys.schemas s ON s.schema_id = p.schema_id
               WHERE s.name = N'policy' AND p.name = N'SP_GetRenewalQueue')
BEGIN
    RAISERROR (N'[030-002] policy.SP_GetRenewalQueue bulunamadi.', 16, 1);
    RETURN;
END;

-- 030-003: SP_ProcessRenewal
IF NOT EXISTS (SELECT 1 FROM sys.procedures p JOIN sys.schemas s ON s.schema_id = p.schema_id
               WHERE s.name = N'policy' AND p.name = N'SP_ProcessRenewal')
BEGIN
    RAISERROR (N'[030-003] policy.SP_ProcessRenewal bulunamadi.', 16, 1);
    RETURN;
END;

-- 030-004: SP_GetRenewalMetrics
IF NOT EXISTS (SELECT 1 FROM sys.procedures p JOIN sys.schemas s ON s.schema_id = p.schema_id
               WHERE s.name = N'policy' AND p.name = N'SP_GetRenewalMetrics')
BEGIN
    RAISERROR (N'[030-004] policy.SP_GetRenewalMetrics bulunamadi.', 16, 1);
    RETURN;
END;

-- 030-005: UNIQUE constraint op contract_id
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'policy.RenewalQueue') AND name = N'UQ_RQ_Contract')
BEGIN
    RAISERROR (N'[030-005] UQ_RQ_Contract unique constraint bulunamadi.', 16, 1);
    RETURN;
END;

PRINT 'Validation 030 OK: yenileme pipeline tablo ve SP''leri dogrulandi.';
GO
