SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.procedures
    WHERE schema_id = SCHEMA_ID(N'audit') AND name = N'SP_QueryAuditLog'
)
    THROW 55001, 'audit.SP_QueryAuditLog ontbreekt.', 1;

IF NOT EXISTS (
    SELECT 1 FROM sys.procedures
    WHERE schema_id = SCHEMA_ID(N'audit') AND name = N'SP_GetEntityHistory'
)
    THROW 55002, 'audit.SP_GetEntityHistory ontbreekt.', 1;

IF NOT EXISTS (
    SELECT 1 FROM sys.procedures
    WHERE schema_id = SCHEMA_ID(N'audit') AND name = N'SP_GdprDataAccessReport'
)
    THROW 55003, 'audit.SP_GdprDataAccessReport ontbreekt.', 1;

PRINT 'Validatie 025: audit SP''leri OK.';
GO
