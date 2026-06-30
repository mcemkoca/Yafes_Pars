SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.schemas WHERE name = N'reporting'
)
    THROW 54030, 'Schema reporting ontbreekt.', 1;

IF NOT EXISTS (
    SELECT 1 FROM sys.procedures
    WHERE schema_id = SCHEMA_ID(N'reporting') AND name = N'SP_FsmaExport'
)
    THROW 54031, 'reporting.SP_FsmaExport ontbreekt.', 1;

PRINT 'Validatie 024: reporting.SP_FsmaExport OK.';
GO
