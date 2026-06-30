SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.schemas WHERE name = N'communication'
)
    THROW 53030, 'Schema communication ontbreekt.', 1;

IF NOT EXISTS (
    SELECT 1 FROM sys.tables
    WHERE schema_id = SCHEMA_ID(N'communication') AND name = N'EmailLog'
)
    THROW 53031, 'communication.EmailLog ontbreekt.', 1;

IF NOT EXISTS (
    SELECT 1 FROM sys.procedures
    WHERE schema_id = SCHEMA_ID(N'communication') AND name = N'SP_LogEmail'
)
    THROW 53032, 'communication.SP_LogEmail ontbreekt.', 1;

-- FK naar core.Tenant moet bestaan.
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE parent_object_id = OBJECT_ID(N'communication.EmailLog')
      AND name = N'FK_EL_Tenant'
)
    THROW 53033, 'FK_EL_Tenant op communication.EmailLog ontbreekt.', 1;

PRINT 'Validatie 023: communication.EmailLog + SP_LogEmail OK.';
GO
