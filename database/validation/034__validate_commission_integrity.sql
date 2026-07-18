-- =============================================================================
-- Validation 034: Commission domain integrity (migration 046)
-- =============================================================================
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [YafesPars];
GO

PRINT 'Validating: 034__validate_commission_integrity.sql';
GO

-- FK: contract_id → policy.Contract
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_Commissions_Contract'
      AND parent_object_id = OBJECT_ID(N'finance.Commissions')
)
    THROW 53401, 'FK_Commissions_Contract missing.', 1;

-- FK: broker_person_id → person.NaturalPerson
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_Commissions_BrokerPerson'
      AND parent_object_id = OBJECT_ID(N'finance.Commissions')
)
    THROW 53402, 'FK_Commissions_BrokerPerson missing.', 1;

-- FK: broker_institution_id → institution.Institution
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_Commissions_BrokerInstitution'
      AND parent_object_id = OBJECT_ID(N'finance.Commissions')
)
    THROW 53403, 'FK_Commissions_BrokerInstitution missing.', 1;

-- FK: finance.LedgerEntry.commission_id → finance.Commissions
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_LedgerEntry_Commission'
      AND parent_object_id = OBJECT_ID(N'finance.LedgerEntry')
)
    THROW 53404, 'FK_LedgerEntry_Commission missing.', 1;

-- Composite index for FSMA export query path
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Commissions_Tenant_Date'
      AND object_id = OBJECT_ID(N'finance.Commissions')
)
    THROW 53405, 'IX_Commissions_Tenant_Date index missing.', 1;

-- FK support index for LedgerEntry.commission_id
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_LedgerEntry_Commission'
      AND object_id = OBJECT_ID(N'finance.LedgerEntry')
)
    THROW 53406, 'IX_LedgerEntry_Commission index missing.', 1;

-- SP_FsmaExport should still exist
IF OBJECT_ID(N'reporting.SP_FsmaExport', N'P') IS NULL
    THROW 53407, 'reporting.SP_FsmaExport SP missing.', 1;

PRINT 'Validation 034 passed: commission FK constraints, indexes, SP_FsmaExport OK.';
GO
