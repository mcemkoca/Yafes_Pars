SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.procedures
    WHERE schema_id = SCHEMA_ID(N'finance') AND name = N'SP_MarkOverdueInvoices'
)
    THROW 52000, 'finance.SP_MarkOverdueInvoices ontbreekt.', 1;

PRINT 'Validatie 021: SP_MarkOverdueInvoices OK.';
GO
