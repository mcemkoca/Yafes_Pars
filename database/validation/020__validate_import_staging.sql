SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.tables
    WHERE schema_id = SCHEMA_ID(N'import') AND name = N'PolicyImport'
)
    THROW 51990, 'import.PolicyImport tabel ontbreekt.', 1;

IF NOT EXISTS (
    SELECT 1 FROM sys.procedures
    WHERE schema_id = SCHEMA_ID(N'import') AND name = N'SP_ValidateImportBatch'
)
    THROW 51991, 'import.SP_ValidateImportBatch ontbreekt.', 1;

PRINT 'Validatie 020: import staging OK.';
GO
