SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.tables
    WHERE schema_id = SCHEMA_ID(N'finance') AND name = N'Commissions'
)
    THROW 51970, 'finance.Commissions tabel ontbreekt.', 1;

IF NOT EXISTS (
    SELECT 1 FROM sys.procedures
    WHERE schema_id = SCHEMA_ID(N'finance') AND name = N'SP_RecordCommission'
)
    THROW 51971, 'finance.SP_RecordCommission ontbreekt.', 1;

IF NOT EXISTS (
    SELECT 1 FROM sys.views
    WHERE schema_id = SCHEMA_ID(N'reporting') AND name = N'VW_CommissionReport'
)
    THROW 51972, 'reporting.VW_CommissionReport view ontbreekt.', 1;

PRINT 'Validatie 018: commissie tabellen OK.';
GO
