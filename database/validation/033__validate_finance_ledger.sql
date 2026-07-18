-- =============================================================================
-- Validation 033: Finance double-entry ledger
-- =============================================================================
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [YafesPars];
GO

PRINT 'Validating: 033__validate_finance_ledger.sql';
GO

-- Tables
IF OBJECT_ID(N'finance.LedgerAccount', N'U') IS NULL
    THROW 53301, 'finance.LedgerAccount table missing.', 1;

IF OBJECT_ID(N'finance.LedgerEntry', N'U') IS NULL
    THROW 53302, 'finance.LedgerEntry table missing.', 1;

-- Seeded accounts
IF NOT EXISTS (SELECT 1 FROM finance.LedgerAccount WHERE account_code = N'7000')
    THROW 53303, 'finance.LedgerAccount seed row 7000 (Premie-inkomen) missing.', 1;

IF NOT EXISTS (SELECT 1 FROM finance.LedgerAccount WHERE account_code = N'9000')
    THROW 53304, 'finance.LedgerAccount seed row 9000 (Technische reserve) missing.', 1;

-- Stored procedures
IF OBJECT_ID(N'finance.SP_PostLedgerEntry', N'P') IS NULL
    THROW 53305, 'finance.SP_PostLedgerEntry SP missing.', 1;

IF OBJECT_ID(N'finance.SP_GetLedgerBalance', N'P') IS NULL
    THROW 53306, 'finance.SP_GetLedgerBalance SP missing.', 1;

IF OBJECT_ID(N'finance.SP_GetLedgerByContract', N'P') IS NULL
    THROW 53307, 'finance.SP_GetLedgerByContract SP missing.', 1;

IF OBJECT_ID(N'finance.SP_GetClaimCostSummary', N'P') IS NULL
    THROW 53308, 'finance.SP_GetClaimCostSummary SP missing.', 1;

-- Constraints
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'CK_LedgerAccount_Type'
      AND parent_object_id = OBJECT_ID(N'finance.LedgerAccount')
)
    THROW 53309, 'CK_LedgerAccount_Type constraint missing.', 1;

IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'CK_LedgerEntry_Source'
      AND parent_object_id = OBJECT_ID(N'finance.LedgerEntry')
)
    THROW 53310, 'CK_LedgerEntry_Source constraint missing.', 1;

-- Indexes
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_LedgerEntry_Tenant_Date'
      AND object_id = OBJECT_ID(N'finance.LedgerEntry')
)
    THROW 53311, 'IX_LedgerEntry_Tenant_Date index missing.', 1;

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_LedgerEntry_Account_Date'
      AND object_id = OBJECT_ID(N'finance.LedgerEntry')
)
    THROW 53312, 'IX_LedgerEntry_Account_Date index missing.', 1;

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_LedgerEntry_Reversal'
      AND object_id = OBJECT_ID(N'finance.LedgerEntry')
)
    THROW 53313, 'IX_LedgerEntry_Reversal index missing.', 1;

PRINT 'Validation 033 passed: finance.LedgerAccount + LedgerEntry tables, seed, SPs, constraints, indexes OK.';
GO
