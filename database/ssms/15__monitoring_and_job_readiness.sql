/*
    Yafes Pars SSMS Workbench - Monitoring And Job Readiness

    INFO TIP:
    Use this read-only screen to review DEV database health, operator backlog,
    backup visibility, and SQL Server Agent readiness from SSMS Results Grid.
    It does not create jobs. It shows what exists and what should be scheduled.

    Enable SQLCMD Mode before running.
    This script is read-only.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE "DEV-BE-BROKER"
:setvar BACKUP_WARNING_HOURS "24"
:setvar OVERDUE_TASK_WARNING_COUNT "10"

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [master];
GO

DECLARE @TargetDatabase SYSNAME = N'$(YAFES_SQL_DATABASE)';
DECLARE @ServerName NVARCHAR(256) = LOWER(CONVERT(NVARCHAR(256), @@SERVERNAME));
DECLARE @MachineName NVARCHAR(256) = LOWER(CONVERT(NVARCHAR(256), SERVERPROPERTY('MachineName')));

IF @TargetDatabase NOT LIKE N'%DEV%'
    THROW 52150, 'Target database name must contain DEV.', 1;

IF @ServerName LIKE N'%prod%' OR @ServerName LIKE N'%production%' OR @ServerName LIKE N'%prd%' OR @ServerName LIKE N'%live%'
    THROW 52151, 'Connected server name suggests production/live.', 1;

IF @MachineName LIKE N'%prod%' OR @MachineName LIKE N'%production%' OR @MachineName LIKE N'%prd%' OR @MachineName LIKE N'%live%'
    THROW 52152, 'Connected machine name suggests production/live.', 1;

IF DB_ID(@TargetDatabase) IS NULL
    THROW 52153, 'Target DEV database does not exist.', 1;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

DECLARE @TenantCode NVARCHAR(80) = N'$(TENANT_CODE)';
DECLARE @TenantId UNIQUEIDENTIFIER;
DECLARE @BackupWarningHours INT = TRY_CONVERT(INT, N'$(BACKUP_WARNING_HOURS)');
DECLARE @OverdueTaskWarningCount BIGINT = TRY_CONVERT(BIGINT, N'$(OVERDUE_TASK_WARNING_COUNT)');

IF @BackupWarningHours IS NULL OR @BackupWarningHours < 1 OR @BackupWarningHours > 168
    THROW 52154, 'BACKUP_WARNING_HOURS must be between 1 and 168.', 1;

IF @OverdueTaskWarningCount IS NULL OR @OverdueTaskWarningCount < 0
    THROW 52155, 'OVERDUE_TASK_WARNING_COUNT must be zero or greater.', 1;

SELECT @TenantId = tenant_id
FROM core.Tenant
WHERE tenant_code = @TenantCode;

IF @TenantId IS NULL
    THROW 52156, 'Tenant code was not found.', 1;

PRINT 'INFO TIP: This script reads monitoring signals only. Create SQL Agent jobs through an approved DBA runbook.';

PRINT '01 - Monitoring context';
SELECT
    @@SERVERNAME AS server_name,
    SERVERPROPERTY('MachineName') AS machine_name,
    DB_NAME() AS database_name,
    @TenantCode AS tenant_code,
    @TenantId AS tenant_id,
    SUSER_SNAME() AS login_name,
    SYSUTCDATETIME() AS checked_at_utc,
    N'INFO TIP: If database_name or tenant_code is unexpected, stop before using any edit script.' AS info_tip;

PRINT '02 - Database readiness signals';
SELECT
    DB_NAME() AS database_name,
    DATABASEPROPERTYEX(DB_NAME(), 'Status') AS database_status,
    DATABASEPROPERTYEX(DB_NAME(), 'Recovery') AS recovery_model,
    DATABASEPROPERTYEX(DB_NAME(), 'Updateability') AS updateability,
    DATABASEPROPERTYEX(DB_NAME(), 'UserAccess') AS user_access,
    DATABASEPROPERTYEX(DB_NAME(), 'IsReadCommittedSnapshotOn') AS read_committed_snapshot,
    (SELECT TOP (1) actual_state_desc FROM sys.database_query_store_options) AS query_store_actual_state,
    (SELECT COUNT_BIG(*) FROM core.SchemaMigration) AS migration_ledger_count,
    (SELECT MAX(migration_name) FROM core.SchemaMigration) AS latest_migration,
    CASE
        WHEN (SELECT COUNT_BIG(*) FROM core.SchemaMigration) >= 17 THEN N'OK'
        ELSE N'REVIEW'
    END AS readiness_status,
    N'INFO TIP: Query Store OFF can be acceptable in DEV, but TEST/PROD should decide this explicitly.' AS info_tip;

PRINT '03 - Tenant operations monitoring';
WITH Signals AS (
    SELECT
        10 AS signal_order,
        N'Open tasks' AS signal_name,
        COUNT_BIG(*) AS signal_value,
        CASE WHEN COUNT_BIG(*) <= 50 THEN N'OK' ELSE N'REVIEW' END AS signal_status,
        N'Use daily checklist and renewal runner if task count is high.' AS info_tip
    FROM tasking.Task
    WHERE tenant_id = @TenantId
      AND is_deleted = 0
      AND task_status_code IN (N'OPEN', N'IN_PROGRESS', N'WAITING')
    UNION ALL
    SELECT
        20,
        N'Overdue tasks',
        COUNT_BIG(*),
        CASE WHEN COUNT_BIG(*) <= @OverdueTaskWarningCount THEN N'OK' ELSE N'ACTION' END,
        N'Overdue tasks should be reviewed before new data entry starts.'
    FROM tasking.Task
    WHERE tenant_id = @TenantId
      AND is_deleted = 0
      AND task_status_code IN (N'OPEN', N'IN_PROGRESS', N'WAITING')
      AND due_at_utc < SYSUTCDATETIME()
    UNION ALL
    SELECT
        30,
        N'Open claims',
        COUNT_BIG(*),
        CASE WHEN COUNT_BIG(*) <= 25 THEN N'OK' ELSE N'REVIEW' END,
        N'Use query library and claim close bridge for reviewed claim closure.'
    FROM claim.Claim
    WHERE tenant_id = @TenantId
      AND is_deleted = 0
      AND claim_status_code NOT IN (N'CLOSED', N'CANCELLED')
    UNION ALL
    SELECT
        40,
        N'Renewal candidates next 60 days',
        COUNT_BIG(*),
        CASE WHEN COUNT_BIG(*) = 0 THEN N'OK' ELSE N'ACTION' END,
        N'Run 03__create_renewal_tasks.sql with DRY_RUN = 1.'
    FROM policy.Contract
    WHERE tenant_id = @TenantId
      AND is_deleted = 0
      AND contract_status_code = N'ACTIVE'
      AND end_date BETWEEN CONVERT(DATE, SYSUTCDATETIME()) AND DATEADD(DAY, 60, CONVERT(DATE, SYSUTCDATETIME()))
    UNION ALL
    SELECT
        50,
        N'Audit events last 24h',
        COUNT_BIG(*),
        N'INFO',
        N'Use audit query script when change volume is unexpected.'
    FROM audit.AuditLog
    WHERE tenant_id = @TenantId
      AND changed_at_utc >= DATEADD(HOUR, -24, SYSUTCDATETIME())
)
SELECT
    signal_order,
    signal_name,
    signal_value,
    signal_status,
    info_tip
FROM Signals
ORDER BY signal_order;

PRINT '04 - SQL Agent job blueprint';
SELECT
    job_order,
    expected_job_name,
    recommended_schedule,
    purpose,
    owner_role,
    info_tip
FROM (VALUES
    (10, N'Yafes DEV - Daily database quality gate', N'Daily before business hours', N'Run SQL quality and SSMS asset checks from controlled automation.', N'DBA / DevOps', N'INFO TIP: Keep report output outside source control unless sanitized.'),
    (20, N'Yafes DEV - Backup recency monitor', N'Hourly', N'Report missing or stale full backup evidence.', N'DBA', N'INFO TIP: TEST/PROD require an approved backup chain.'),
    (30, N'Yafes DEV - Operator backlog monitor', N'Business hours', N'Surface overdue tasks, open claims, and renewal candidates.', N'Operations lead', N'INFO TIP: Use as a notification source, not as an automatic data editor.'),
    (40, N'Yafes DEV - Restore drill reminder', N'Monthly', N'Remind the owner to run restore-drill evidence.', N'DBA / Release owner', N'INFO TIP: Restore proof stays in evidence reports.'),
    (50, N'Yafes DEV - Access review reminder', N'Monthly', N'Remind admin owner to record role and permission evidence.', N'Security owner', N'INFO TIP: Use 14__admin_role_permission_matrix.sql as source evidence.')
) AS j(job_order, expected_job_name, recommended_schedule, purpose, owner_role, info_tip)
ORDER BY job_order;

DECLARE @AgentMessages TABLE (
    message_order INT NOT NULL,
    message_status NVARCHAR(20) NOT NULL,
    message_text NVARCHAR(400) NOT NULL,
    info_tip NVARCHAR(400) NOT NULL
);

DECLARE @AgentJobs TABLE (
    job_name SYSNAME NOT NULL,
    enabled TINYINT NULL,
    schedule_name SYSNAME NULL,
    last_run_at DATETIME NULL,
    last_run_status NVARCHAR(30) NULL
);

BEGIN TRY
    IF DB_ID(N'msdb') IS NULL
    BEGIN
        INSERT INTO @AgentMessages (message_order, message_status, message_text, info_tip)
        VALUES (10, N'REVIEW', N'msdb is not available on this SQL Server instance.', N'INFO TIP: SQL Agent readiness cannot be reviewed without msdb.');
    END;
    ELSE
    BEGIN
        INSERT INTO @AgentJobs (job_name, enabled, schedule_name, last_run_at, last_run_status)
        EXEC sys.sp_executesql N'
            SELECT
                j.name AS job_name,
                j.enabled,
                MAX(s.name) AS schedule_name,
                MAX(msdb.dbo.agent_datetime(NULLIF(h.run_date, 0), NULLIF(h.run_time, 0))) AS last_run_at,
                CASE MAX(COALESCE(h.run_status, -1))
                    WHEN 0 THEN N''FAILED''
                    WHEN 1 THEN N''SUCCESS''
                    WHEN 2 THEN N''RETRY''
                    WHEN 3 THEN N''CANCELLED''
                    WHEN 4 THEN N''IN_PROGRESS''
                    ELSE N''NO_HISTORY''
                END AS last_run_status
            FROM msdb.dbo.sysjobs j
            LEFT JOIN msdb.dbo.sysjobschedules js
                ON js.job_id = j.job_id
            LEFT JOIN msdb.dbo.sysschedules s
                ON s.schedule_id = js.schedule_id
            LEFT JOIN msdb.dbo.sysjobhistory h
                ON h.job_id = j.job_id
               AND h.step_id = 0
            WHERE j.name LIKE N''Yafes%''
               OR j.name LIKE N''%Yafes%''
            GROUP BY j.name, j.enabled;';

        INSERT INTO @AgentMessages (message_order, message_status, message_text, info_tip)
        VALUES (20, N'OK', N'msdb SQL Agent tables were readable.', N'INFO TIP: Empty job list means the DBA still needs to create approved jobs.');
    END;
END TRY
BEGIN CATCH
    INSERT INTO @AgentMessages (message_order, message_status, message_text, info_tip)
    VALUES (30, N'REVIEW', ERROR_MESSAGE(), N'INFO TIP: Ask DBA to grant read access or run this script with an approved admin login.');
END CATCH;

PRINT '05 - SQL Agent observed Yafes jobs';
SELECT
    job_name,
    enabled,
    schedule_name,
    last_run_at,
    last_run_status,
    CASE
        WHEN enabled = 1 THEN N'OK'
        WHEN enabled = 0 THEN N'REVIEW'
        ELSE N'INFO'
    END AS job_status,
    N'INFO TIP: Expected job names are in result set 04.' AS info_tip
FROM @AgentJobs
UNION ALL
SELECT
    N'NO_YAFES_AGENT_JOB_FOUND',
    NULL,
    NULL,
    NULL,
    N'NO_HISTORY',
    N'REVIEW',
    N'INFO TIP: No matching SQL Agent job was found. Use result set 04 as the DBA handoff.'
WHERE NOT EXISTS (SELECT 1 FROM @AgentJobs)
ORDER BY job_name;

PRINT '06 - SQL Agent read access messages';
SELECT
    message_order,
    message_status,
    message_text,
    info_tip
FROM @AgentMessages
ORDER BY message_order;

DECLARE @BackupSignals TABLE (
    database_name SYSNAME NOT NULL,
    backup_finish_date DATETIME NULL,
    backup_type CHAR(1) NULL,
    hours_since_backup INT NULL,
    backup_size_bytes NUMERIC(20,0) NULL
);

BEGIN TRY
    INSERT INTO @BackupSignals (database_name, backup_finish_date, backup_type, hours_since_backup, backup_size_bytes)
    EXEC sys.sp_executesql N'
        SELECT TOP (1)
            database_name,
            backup_finish_date,
            type AS backup_type,
            DATEDIFF(HOUR, backup_finish_date, GETDATE()) AS hours_since_backup,
            backup_size AS backup_size_bytes
        FROM msdb.dbo.backupset
        WHERE database_name = @DatabaseName
        ORDER BY backup_finish_date DESC;',
        N'@DatabaseName SYSNAME',
        @DatabaseName = N'$(YAFES_SQL_DATABASE)';
END TRY
BEGIN CATCH
    INSERT INTO @BackupSignals (database_name, backup_finish_date, backup_type, hours_since_backup, backup_size_bytes)
    VALUES (DB_NAME(), NULL, NULL, NULL, NULL);
END CATCH;

PRINT '07 - Backup recency signal';
SELECT
    database_name,
    backup_finish_date,
    backup_type,
    hours_since_backup,
    backup_size_bytes,
    CASE
        WHEN backup_finish_date IS NULL THEN N'REVIEW'
        WHEN hours_since_backup <= @BackupWarningHours THEN N'OK'
        ELSE N'ACTION'
    END AS backup_status,
    N'INFO TIP: DEV proof exists, but TEST/PROD backup evidence must be collected from approved infrastructure.' AS info_tip
FROM @BackupSignals
UNION ALL
SELECT
    DB_NAME(),
    NULL,
    NULL,
    NULL,
    NULL,
    N'REVIEW',
    N'INFO TIP: No backup row found for this database in msdb.'
WHERE NOT EXISTS (SELECT 1 FROM @BackupSignals);

PRINT '08 - Monitoring handoff actions';
SELECT
    action_order,
    owner,
    action_name,
    open_asset,
    readiness_rule,
    info_tip
FROM (VALUES
    (10, N'Operator', N'Open daily checklist', N'database/ssms/10__daily_operator_checklist.sql', N'Run at start and end of day.', N'INFO TIP: Checklist is the quickest user-facing control surface.'),
    (20, N'Admin', N'Review role matrix', N'database/ssms/14__admin_role_permission_matrix.sql', N'Run before monthly access evidence.', N'INFO TIP: Access evidence remains environment-specific.'),
    (30, N'DBA', N'Create approved SQL Agent jobs', N'Result set 04', N'Only after DEV/TEST schedule and owner approval.', N'INFO TIP: This script does not create jobs.'),
    (40, N'DBA', N'Run restore drill', N'md/database/restore-drill-evidence-template.md', N'Before go-live and after major release changes.', N'INFO TIP: Use DEV evidence as baseline only.'),
    (50, N'Release owner', N'Update production checklist', N'md/database/production-readiness-checklist.md', N'After TEST/PROD evidence is collected.', N'INFO TIP: Do not mark environment-dependent checks complete from DEV-only proof.')
) AS a(action_order, owner, action_name, open_asset, readiness_rule, info_tip)
ORDER BY action_order;
GO
