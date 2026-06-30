-- =============================================================================
-- Validation 031: premium hesaplama motoru doğrulama
-- =============================================================================
USE [YafesPars];
GO

-- 031-001: finance.TariffRate tablosu
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID(N'finance') AND name = N'TariffRate')
BEGIN
    RAISERROR (N'[031-001] finance.TariffRate tablosu bulunamadi.', 16, 1);
    RETURN;
END;

-- 031-002: SP_GetTariffRates
IF NOT EXISTS (SELECT 1 FROM sys.procedures p JOIN sys.schemas s ON s.schema_id = p.schema_id
               WHERE s.name = N'finance' AND p.name = N'SP_GetTariffRates')
BEGIN
    RAISERROR (N'[031-002] finance.SP_GetTariffRates bulunamadi.', 16, 1);
    RETURN;
END;

-- 031-003: SP_UpsertTariffRate
IF NOT EXISTS (SELECT 1 FROM sys.procedures p JOIN sys.schemas s ON s.schema_id = p.schema_id
               WHERE s.name = N'finance' AND p.name = N'SP_UpsertTariffRate')
BEGIN
    RAISERROR (N'[031-003] finance.SP_UpsertTariffRate bulunamadi.', 16, 1);
    RETURN;
END;

-- 031-004: SP_CalculatePremium
IF NOT EXISTS (SELECT 1 FROM sys.procedures p JOIN sys.schemas s ON s.schema_id = p.schema_id
               WHERE s.name = N'finance' AND p.name = N'SP_CalculatePremium')
BEGIN
    RAISERROR (N'[031-004] finance.SP_CalculatePremium bulunamadi.', 16, 1);
    RETURN;
END;

-- 031-005: SP_GetPremiumSummary
IF NOT EXISTS (SELECT 1 FROM sys.procedures p JOIN sys.schemas s ON s.schema_id = p.schema_id
               WHERE s.name = N'finance' AND p.name = N'SP_GetPremiumSummary')
BEGIN
    RAISERROR (N'[031-005] finance.SP_GetPremiumSummary bulunamadi.', 16, 1);
    RETURN;
END;

-- 031-006: CHECK constraint base_rate_pct
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_TR_BaseRate')
BEGIN
    RAISERROR (N'[031-006] CK_TR_BaseRate CHECK constraint bulunamadi.', 16, 1);
    RETURN;
END;

PRINT 'Validation 031 OK: premium hesaplama motoru dogrulandi.';
GO
