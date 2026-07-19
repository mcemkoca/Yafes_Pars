-- =============================================================================
-- Validation 035: Export job lifecycle (migration 048)
-- =============================================================================
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [YafesPars];
GO

PRINT 'Validating: 035__validate_export_job_lifecycle.sql';
GO

-- Tables exist
IF OBJECT_ID(N'import.ExportJob', N'U') IS NULL
    THROW 55100, 'import.ExportJob table missing.', 1;

IF OBJECT_ID(N'import.ExportJobFile', N'U') IS NULL
    THROW 55101, 'import.ExportJobFile table missing.', 1;

-- FK: ExportJobFile → ExportJob
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_ExportJobFile_Job'
      AND parent_object_id = OBJECT_ID(N'import.ExportJobFile')
)
    THROW 55102, 'FK_ExportJobFile_Job missing.', 1;

-- Indexes
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_ExportJob_Tenant_Status'
      AND object_id = OBJECT_ID(N'import.ExportJob')
)
    THROW 55103, 'IX_ExportJob_Tenant_Status index missing.', 1;

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_ExportJob_Tenant_Type_Period'
      AND object_id = OBJECT_ID(N'import.ExportJob')
)
    THROW 55104, 'IX_ExportJob_Tenant_Type_Period index missing.', 1;

-- SPs exist
IF OBJECT_ID(N'import.SP_CreateExportJob',   N'P') IS NULL
    THROW 55105, 'import.SP_CreateExportJob SP missing.', 1;

IF OBJECT_ID(N'import.SP_CompleteExportJob', N'P') IS NULL
    THROW 55106, 'import.SP_CompleteExportJob SP missing.', 1;

IF OBJECT_ID(N'import.SP_GetExportJobStatus', N'P') IS NULL
    THROW 55107, 'import.SP_GetExportJobStatus SP missing.', 1;

IF OBJECT_ID(N'import.SP_GetExportJobQueue', N'P') IS NULL
    THROW 55108, 'import.SP_GetExportJobQueue SP missing.', 1;

PRINT 'Validation 035 passed: ExportJob tables, FK, indexes, and SPs OK.';
GO
