/*
    Yafes Pars SSMS Workbench - Operator Dashboard Home

    INFO TIP:
    Run this file first during daily work. It does not change data.
    It gives the operator one Results Grid with shortcuts, one grid with health
    signals, and one grid with recommended next actions.

    Enable SQLCMD Mode before running.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE "DEV-BE-BROKER"

SET NOCOUNT ON;
GO

USE [master];
GO

DECLARE @TargetDatabase SYSNAME = N'$(YAFES_SQL_DATABASE)';
DECLARE @ServerName NVARCHAR(256) = LOWER(CONVERT(NVARCHAR(256), @@SERVERNAME));
DECLARE @MachineName NVARCHAR(256) = LOWER(CONVERT(NVARCHAR(256), SERVERPROPERTY('MachineName')));

IF @TargetDatabase NOT LIKE N'%DEV%'
    THROW 52100, 'Target database name must contain DEV.', 1;

IF @ServerName LIKE N'%prod%' OR @ServerName LIKE N'%production%' OR @ServerName LIKE N'%prd%' OR @ServerName LIKE N'%live%'
    THROW 52101, 'Connected server name suggests production/live.', 1;

IF @MachineName LIKE N'%prod%' OR @MachineName LIKE N'%production%' OR @MachineName LIKE N'%prd%' OR @MachineName LIKE N'%live%'
    THROW 52102, 'Connected machine name suggests production/live.', 1;

IF DB_ID(@TargetDatabase) IS NULL
    THROW 52103, 'Target DEV database does not exist.', 1;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

DECLARE @TenantCode NVARCHAR(80) = N'$(TENANT_CODE)';
DECLARE @TenantId UNIQUEIDENTIFIER;

SELECT @TenantId = tenant_id
FROM core.Tenant
WHERE tenant_code = @TenantCode;

IF @TenantId IS NULL
    THROW 52104, 'Tenant code was not found.', 1;

PRINT 'INFO TIP: Keep this dashboard open in SSMS. Open listed shortcut scripts in new tabs.';

PRINT '01 - Operator shortcuts';
SELECT
    shortcut_order,
    shortcut_group,
    action_name,
    ssms_file,
    safety_mode,
    info_tip
FROM (VALUES
    (10, N'Start', N'Open-first safety check', N'database/ssms/00__open_first_safety_check.sql', N'READ_ONLY', N'Confirms DEV database and non-production-like server names.'),
    (20, N'Start', N'Run migrations and validations', N'database/ssms/01__run_all_dev_migrations_sqlcmd.sql', N'BACKUP_REQUIRED', N'Use only after setting backup path in the generated all-in-one script.'),
    (25, N'Architecture', N'Working logic map', N'database/ssms/11__schema_working_logic_map.sql', N'READ_ONLY', N'Domain groups, subheadings, control flow, and board cards for planning.'),
    (26, N'Architecture', N'Table catalog and FK map', N'database/ssms/12__table_catalog_and_relationships.sql', N'READ_ONLY', N'Real SQL Server table catalog, column profile, and relationship map.'),
    (27, N'Architecture', N'Visual workflow board', N'database/ssms/13__visual_workflow_board.sql', N'READ_ONLY', N'SSMS grid-based node, edge, subheading, and template-route board.'),
    (30, N'Operate', N'Operations dashboard', N'database/ssms/02__operations_dashboard.sql', N'READ_ONLY', N'Daily customer, policy, claim, task, coverage, and lookup overview.'),
    (40, N'Operate', N'Renewal task runner', N'database/ssms/03__create_renewal_tasks.sql', N'DRY_RUN_FIRST', N'Keep DRY_RUN = 1 until candidate list is approved.'),
    (50, N'Control', N'Admin/security/audit checks', N'database/ssms/04__admin_security_audit_queries.sql', N'READ_ONLY', N'RBAC, audit trigger, audit log, and integrity control checks.'),
    (55, N'Control', N'Role/permission matrix', N'database/ssms/14__admin_role_permission_matrix.sql', N'READ_ONLY', N'User-friendly RBAC matrix, least-privilege checks, and admin handoff rows.'),
    (60, N'Operate', N'Query library shortcuts', N'database/ssms/06__query_library_shortcuts.sql', N'READ_ONLY', N'Common search and inspection queries for operators.'),
    (70, N'Edit', N'Data entry bridge templates', N'database/ssms/07__data_entry_bridge_templates.sql', N'REVIEW_BEFORE_COMMIT', N'Procedure-based create templates with previews and output IDs.'),
    (80, N'Edit', N'Data editing guardrails', N'database/ssms/08__data_editing_guardrails.sql', N'ROLLBACK_DEFAULT', N'Update patterns that preview changes and roll back by default.'),
    (90, N'Report', N'Graph/report pack', N'database/ssms/09__graph_report_pack.sql', N'READ_ONLY', N'Grid-friendly trend, bar, and export-ready report datasets.'),
    (100, N'Control', N'Daily operator checklist', N'database/ssms/10__daily_operator_checklist.sql', N'READ_ONLY', N'Morning and end-of-day checklist result sets.'),
    (110, N'Control', N'Monitoring and job readiness', N'database/ssms/15__monitoring_and_job_readiness.sql', N'READ_ONLY', N'DEV health, backlog, backup, and SQL Agent readiness grids.'),
    (115, N'Finance', N'Finance ledger cockpit', N'database/ssms/19__finance_ledger_cockpit.sql', N'READ_ONLY', N'Chart of accounts, trial balance, P&L summary, claim cost, and reserve evolution.'),
    (120, N'Control', N'Delivery gap register', N'database/ssms/16__delivery_gap_register.sql', N'READ_ONLY', N'Commit review closure, open delivery gaps, and next SSMS actions.'),
    (130, N'Control', N'Remaining work cockpit', N'database/ssms/17__remaining_work_cockpit.sql', N'READ_ONLY', N'Owner decisions, evidence handoff, 019+ intake, edge bridge ranking, and SQL Agent promotion.')
) AS s(shortcut_order, shortcut_group, action_name, ssms_file, safety_mode, info_tip)
ORDER BY shortcut_order;

PRINT '02 - Current operating context';
SELECT
    @@SERVERNAME AS server_name,
    SERVERPROPERTY('MachineName') AS machine_name,
    DB_NAME() AS database_name,
    @TenantCode AS tenant_code,
    @TenantId AS tenant_id,
    SUSER_SNAME() AS login_name,
    SYSUTCDATETIME() AS checked_at_utc,
    N'INFO TIP: If tenant_code or database_name is unexpected, stop before editing data.' AS info_tip;

PRINT '03 - Health signals';
SELECT
    signal_name,
    signal_value,
    signal_status,
    info_tip
FROM (
    SELECT
        N'Latest migration' AS signal_name,
        COALESCE(MAX(migration_name), N'NOT FOUND') AS signal_value,
        CASE WHEN COUNT_BIG(*) >= 17 THEN N'OK' ELSE N'CHECK' END AS signal_status,
        N'Expected ledger count is 17 tracked migrations; source files are 19 through 018 because 000 and 001 bootstrap the database and schemas.' AS info_tip
    FROM core.SchemaMigration
    UNION ALL
    SELECT
        N'Open tasks',
        CONVERT(NVARCHAR(40), COUNT_BIG(*)),
        CASE WHEN COUNT_BIG(*) <= 50 THEN N'OK' ELSE N'REVIEW' END,
        N'High volume can indicate renewal or claims follow-up backlog.'
    FROM tasking.Task
    WHERE tenant_id = @TenantId
      AND is_deleted = 0
      AND task_status_code IN (N'OPEN', N'IN_PROGRESS', N'WAITING')
    UNION ALL
    SELECT
        N'Renewal candidates next 60 days',
        CONVERT(NVARCHAR(40), COUNT_BIG(*)),
        CASE WHEN COUNT_BIG(*) = 0 THEN N'OK' ELSE N'ACTION' END,
        N'Run 03__create_renewal_tasks.sql with DRY_RUN = 1.'
    FROM policy.Contract
    WHERE tenant_id = @TenantId
      AND is_deleted = 0
      AND contract_status_code = N'ACTIVE'
      AND end_date BETWEEN CONVERT(DATE, SYSUTCDATETIME()) AND DATEADD(DAY, 60, CONVERT(DATE, SYSUTCDATETIME()))
    UNION ALL
    SELECT
        N'Claims open',
        CONVERT(NVARCHAR(40), COUNT_BIG(*)),
        CASE WHEN COUNT_BIG(*) <= 25 THEN N'OK' ELSE N'REVIEW' END,
        N'Use the query library to inspect open claims by handler.'
    FROM claim.Claim
    WHERE tenant_id = @TenantId
      AND is_deleted = 0
      AND claim_status_code NOT IN (N'CLOSED', N'CANCELLED')
) AS h
ORDER BY signal_name;

PRINT '04 - Recommended next actions';
SELECT
    priority,
    recommended_action,
    open_script,
    info_tip
FROM (VALUES
    (1, N'Run daily checklist', N'database/ssms/10__daily_operator_checklist.sql', N'Fastest way to confirm readiness before data entry.'),
    (2, N'Review working logic map', N'database/ssms/11__schema_working_logic_map.sql', N'Use before deciding table changes or explaining the model to a new operator.'),
    (3, N'Open table catalog and FK map', N'database/ssms/12__table_catalog_and_relationships.sql', N'Use before adding a migration or designing a drag/drop board.'),
    (4, N'Open visual workflow board', N'database/ssms/13__visual_workflow_board.sql', N'Use node/edge and template-route grids as the SSMS-safe visual board.'),
    (5, N'Review role/permission matrix', N'database/ssms/14__admin_role_permission_matrix.sql', N'Use before assigning users or preparing access evidence.'),
    (6, N'Open operations dashboard', N'database/ssms/02__operations_dashboard.sql', N'Keep this tab pinned in SSMS for daily operations.'),
    (7, N'Use data entry bridge for creates', N'database/ssms/07__data_entry_bridge_templates.sql', N'Avoid direct INSERT unless a template explicitly documents it.'),
    (8, N'Use editing guardrails for updates', N'database/ssms/08__data_editing_guardrails.sql', N'Preview and rollback by default; commit only after row count is correct.'),
    (9, N'Export report pack if needed', N'database/ssms/09__graph_report_pack.sql', N'Result sets are designed for Excel/Power BI copy-out.'),
    (10, N'Review monitoring and job readiness', N'database/ssms/15__monitoring_and_job_readiness.sql', N'Use before DBA handoff or environment evidence planning.'),
    (11, N'Review unfinished delivery gaps', N'database/ssms/16__delivery_gap_register.sql', N'Use after PR or commit review to decide the next SSMS work item.'),
    (12, N'Open remaining work cockpit', N'database/ssms/17__remaining_work_cockpit.sql', N'Use to turn open gaps into owner evidence, 019+ decisions, and DBA handoff actions.')
) AS a(priority, recommended_action, open_script, info_tip)
ORDER BY priority;
GO
