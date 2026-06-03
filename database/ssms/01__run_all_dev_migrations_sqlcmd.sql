/*
    Yafes Pars SSMS Workbench - DEV Migration Handoff

    INFO TIP:
    This checked-in file is a read-only SSMS preflight and handoff. The actual
    all-in-one SSMS migration script must be generated with:

        .\database\tools\run-dev-migrations.ps1 -GenerateSsmsScriptOnly

    Then open the generated `database/execution-logs/<run-id>/ssms-dev-migrations.sql`
    file in SSMS, enable Query > SQLCMD Mode, verify variables, and run only
    against a DEV database. Generated execution-log scripts are intentionally
    not committed to Git.

    Enable SQLCMD Mode before running this preflight.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar YAFES_SQL_BACKUP_PATH "C:\SqlBackups\YafesPars_Dev_PreMigration_YYYYMMDD_HHMMSS.bak"

SET NOCOUNT ON;
GO

USE [master];
GO

DECLARE @TargetDatabase SYSNAME = N'$(YAFES_SQL_DATABASE)';
DECLARE @BackupPath NVARCHAR(4000) = N'$(YAFES_SQL_BACKUP_PATH)';
DECLARE @ServerName NVARCHAR(256) = LOWER(CONVERT(NVARCHAR(256), @@SERVERNAME));
DECLARE @MachineName NVARCHAR(256) = LOWER(CONVERT(NVARCHAR(256), SERVERPROPERTY('MachineName')));

IF @TargetDatabase NOT LIKE N'%DEV%'
    THROW 52005, 'Target database name must contain DEV.', 1;

IF @ServerName LIKE N'%prod%' OR @ServerName LIKE N'%production%' OR @ServerName LIKE N'%prd%' OR @ServerName LIKE N'%live%'
    THROW 52006, 'Connected server name suggests production/live.', 1;

IF @MachineName LIKE N'%prod%' OR @MachineName LIKE N'%production%' OR @MachineName LIKE N'%prd%' OR @MachineName LIKE N'%live%'
    THROW 52007, 'Connected machine name suggests production/live.', 1;

IF @BackupPath LIKE N'%YYYYMMDD%' OR @BackupPath LIKE N'%HHMMSS%'
    PRINT 'INFO TIP: Set a real timestamped YAFES_SQL_BACKUP_PATH in the generated SSMS script before execution.';

SELECT
    @@SERVERNAME AS server_name,
    SERVERPROPERTY('MachineName') AS machine_name,
    @TargetDatabase AS target_database,
    DB_ID(@TargetDatabase) AS target_database_id,
    @BackupPath AS backup_path_template,
    CASE
        WHEN DB_ID(@TargetDatabase) IS NULL THEN N'ACTION'
        ELSE N'READY'
    END AS readiness_status,
    CASE
        WHEN DB_ID(@TargetDatabase) IS NULL THEN N'Create the DEV database first or let the guarded runner prepare it, then generate the SSMS script.'
        ELSE N'Generate ssms-dev-migrations.sql, open it in SSMS, enable SQLCMD Mode, verify variables, and run against DEV only.'
    END AS next_action,
    N'INFO TIP: This file does not run migrations. It prevents stale committed execution-log references.' AS info_tip;
GO
