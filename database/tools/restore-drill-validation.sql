-- =============================================================================
-- Restore Drill Validation Script
--
-- Run AFTER restoring a backup to a clean validation environment.
-- Validates structural integrity: table counts, migration state, SP presence,
-- and basic row-count sanity checks.
--
-- !! NEVER run against the primary DEV/TEST/PROD instance !!
-- This script is for the restored copy only.
-- =============================================================================
SET NOCOUNT ON;
GO

USE [YafesPars];
GO

PRINT 'Restore Drill Validation — ' + CONVERT(NVARCHAR, SYSUTCDATETIME(), 126);
PRINT 'Server: ' + @@SERVERNAME;
PRINT 'Database: ' + DB_NAME();
GO

-- -------------------------------------------------------------------------
-- 01. Schema migration state
-- -------------------------------------------------------------------------
PRINT '01 - Schema migration state';

SELECT
    migration_name,
    execution_status,
    executed_at_utc
FROM core.SchemaMigration
ORDER BY migration_name;
GO

DECLARE @migration_count INT;
SELECT @migration_count = COUNT(*) FROM core.SchemaMigration WHERE execution_status = N'SUCCESS';
PRINT 'SUCCESS migrations: ' + CAST(@migration_count AS NVARCHAR);

IF @migration_count < 48
    PRINT 'WARNING: Fewer migrations than expected (48). Validate missing entries.';
ELSE
    PRINT 'OK: Migration count >= 48.';
GO

-- -------------------------------------------------------------------------
-- 02. Core table presence
-- -------------------------------------------------------------------------
PRINT '02 - Core table presence';

SELECT
    t.name                                        AS table_name,
    s.name                                        AS schema_name,
    p.rows                                        AS row_count
FROM sys.tables t
INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
INNER JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0,1)
ORDER BY s.name, t.name;
GO

DECLARE @table_count INT;
SELECT @table_count = COUNT(*) FROM sys.tables;
PRINT 'Total tables: ' + CAST(@table_count AS NVARCHAR);

IF @table_count < 140
    PRINT 'WARNING: Table count below expected (140+). Check migration completeness.';
ELSE
    PRINT 'OK: Table count >= 140.';
GO

-- -------------------------------------------------------------------------
-- 03. Key SPs present
-- -------------------------------------------------------------------------
PRINT '03 - Critical stored procedures';

SELECT
    SCHEMA_NAME(o.schema_id) AS schema_name,
    o.name                   AS procedure_name,
    o.modify_date            AS last_modified
FROM sys.objects o
WHERE o.type = 'P'
  AND SCHEMA_NAME(o.schema_id) IN (
    N'person', N'policy', N'claim', N'risk', N'import', N'tasking', N'finance'
  )
ORDER BY SCHEMA_NAME(o.schema_id), o.name;
GO

-- -------------------------------------------------------------------------
-- 04. Tenant and user sanity
-- -------------------------------------------------------------------------
PRINT '04 - Tenant and user row counts';

SELECT
    'core.Tenant'  AS table_name, COUNT(*) AS row_count FROM core.Tenant
UNION ALL
SELECT
    'core.AppUser' AS table_name, COUNT(*) AS row_count FROM core.AppUser
UNION ALL
SELECT
    'core.AppRole' AS table_name, COUNT(*) AS row_count FROM core.AppRole;
GO

-- -------------------------------------------------------------------------
-- 05. FK integrity spot-check
-- -------------------------------------------------------------------------
PRINT '05 - FK integrity spot-check (orphan detection)';

SELECT
    'ExportJobFile orphans' AS check_name,
    COUNT(*) AS orphan_count
FROM import.ExportJobFile f
WHERE NOT EXISTS (
    SELECT 1 FROM import.ExportJob j WHERE j.job_id = f.job_id
);

SELECT
    'UserRole orphan users' AS check_name,
    COUNT(*) AS orphan_count
FROM core.UserRole ur
WHERE NOT EXISTS (
    SELECT 1 FROM core.AppUser u WHERE u.user_id = ur.user_id
);
GO

PRINT 'Restore Drill Validation — COMPLETE.';
PRINT 'Review row counts above against pre-backup baseline before signing off.';
GO
