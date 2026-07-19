-- =============================================================================
-- Restore Drill Validation Script
--
-- Run AFTER restoring a backup to a clean validation environment.
-- Validates structural integrity: table counts, migration state, SP presence,
-- and basic row-count sanity checks.
--
-- IMPORTANT: Do NOT switch the database context here. The caller must already
-- be connected to the restored copy (e.g. YafesPars_RestoreDrill).
-- Using `USE [YafesPars]` would re-target the source DB if it is present on
-- the same server, defeating the drill.
-- See md/restore/test-restore-drill-plan.md for connection instructions.
--
-- !! NEVER run against the primary DEV/TEST/PROD instance !!
-- =============================================================================
SET NOCOUNT ON;
GO

PRINT 'Restore Drill Validation — ' + CONVERT(NVARCHAR, SYSUTCDATETIME(), 126);
PRINT 'Server: ' + @@SERVERNAME;
PRINT 'Database: ' + DB_NAME();
GO

-- Safety: confirm we are NOT on the source database name
IF DB_NAME() NOT LIKE N'%RestoreDrill%' AND DB_NAME() NOT LIKE N'%Restore%' AND DB_NAME() NOT LIKE N'%Drill%'
BEGIN
    PRINT 'WARNING: Database name does not contain RestoreDrill/Restore/Drill.';
    PRINT 'Connect explicitly to the restored copy before running this script.';
    PRINT 'Aborting to avoid validating the wrong database.';
    THROW 55200, 'Run this script while connected to the restored database, not the source.', 1;
END;
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
    s.name                                        AS schema_name,
    t.name                                        AS table_name,
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
-- 04. Tenant and user sanity (core.Role — not core.AppRole)
-- -------------------------------------------------------------------------
PRINT '04 - Tenant and user row counts';

SELECT 'core.Tenant'  AS table_name, COUNT(*) AS row_count FROM core.Tenant
UNION ALL
SELECT 'core.AppUser' AS table_name, COUNT(*) AS row_count FROM core.AppUser
UNION ALL
SELECT 'core.Role'    AS table_name, COUNT(*) AS row_count FROM core.Role;
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
