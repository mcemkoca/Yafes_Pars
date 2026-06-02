/*
    Yafes Pars SSMS Workbench - Daily Operator Checklist

    INFO TIP:
    Run this at the beginning and end of the day. It is read-only and gives a
    simple operational checklist with PASS/REVIEW/ACTION signals.

    Enable SQLCMD Mode before running.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE "DEMO-BE-BROKER"

SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

IF DB_NAME() NOT LIKE N'%DEV%'
    THROW 52699, 'Current database name must contain DEV.', 1;

DECLARE @TenantCode NVARCHAR(80) = N'$(TENANT_CODE)';
DECLARE @TenantId UNIQUEIDENTIFIER;

SELECT @TenantId = tenant_id
FROM core.Tenant
WHERE tenant_code = @TenantCode;

IF @TenantId IS NULL
    THROW 52600, 'Tenant code was not found.', 1;

PRINT 'INFO TIP: Treat ACTION rows as same-day follow-up items.';

PRINT '01 - Daily checklist';
SELECT
    check_order,
    check_area,
    check_name,
    check_status,
    observed_value,
    info_tip
FROM (
    SELECT
        10 AS check_order,
        N'System' AS check_area,
        N'Database context' AS check_name,
        CASE WHEN DB_NAME() LIKE N'%DEV%' THEN N'PASS' ELSE N'ACTION' END AS check_status,
        DB_NAME() AS observed_value,
        N'Database name must contain DEV for operator workbench scripts.' AS info_tip
    UNION ALL
    SELECT
        20,
        N'System',
        N'Migration count',
        CASE WHEN COUNT_BIG(*) >= 19 THEN N'PASS' ELSE N'ACTION' END,
        CONVERT(NVARCHAR(40), COUNT_BIG(*)),
        N'Expected 19 migrations through 018.'
    FROM core.SchemaMigration
    UNION ALL
    SELECT
        30,
        N'Operations',
        N'Overdue tasks',
        CASE WHEN COUNT_BIG(*) = 0 THEN N'PASS' WHEN COUNT_BIG(*) <= 5 THEN N'REVIEW' ELSE N'ACTION' END,
        CONVERT(NVARCHAR(40), COUNT_BIG(*)),
        N'Open overdue tasks should be handled before new data entry.'
    FROM tasking.Task
    WHERE tenant_id = @TenantId
      AND is_deleted = 0
      AND task_status_code IN (N'OPEN', N'IN_PROGRESS', N'WAITING')
      AND due_at_utc < SYSUTCDATETIME()
    UNION ALL
    SELECT
        40,
        N'Operations',
        N'Renewal candidates next 30 days',
        CASE WHEN COUNT_BIG(*) = 0 THEN N'PASS' ELSE N'ACTION' END,
        CONVERT(NVARCHAR(40), COUNT_BIG(*)),
        N'Run renewal dry-run and create tasks after approval.'
    FROM policy.Contract
    WHERE tenant_id = @TenantId
      AND is_deleted = 0
      AND contract_status_code = N'ACTIVE'
      AND end_date BETWEEN CONVERT(DATE, SYSUTCDATETIME()) AND DATEADD(DAY, 30, CONVERT(DATE, SYSUTCDATETIME()))
    UNION ALL
    SELECT
        50,
        N'Claims',
        N'Open claims',
        CASE WHEN COUNT_BIG(*) <= 25 THEN N'PASS' ELSE N'REVIEW' END,
        CONVERT(NVARCHAR(40), COUNT_BIG(*)),
        N'Use query library section 05 for detailed claim review.'
    FROM claim.Claim
    WHERE tenant_id = @TenantId
      AND is_deleted = 0
      AND claim_status_code NOT IN (N'CLOSED', N'CANCELLED')
    UNION ALL
    SELECT
        60,
        N'Data quality',
        N'Active packages without coverage',
        CASE WHEN COUNT_BIG(*) = 0 THEN N'PASS' ELSE N'ACTION' END,
        CONVERT(NVARCHAR(40), COUNT_BIG(*)),
        N'Package definitions must contain at least one coverage item.'
    FROM coverage.CoveragePackage cp
    WHERE cp.is_active = 1
      AND NOT EXISTS (
            SELECT 1
            FROM coverage.CoveragePackageItem cpi
            WHERE cpi.coverage_package_id = cp.coverage_package_id
      )
    UNION ALL
    SELECT
        70,
        N'Data quality',
        N'Task assignee outside tenant',
        CASE WHEN COUNT_BIG(*) = 0 THEN N'PASS' ELSE N'ACTION' END,
        CONVERT(NVARCHAR(40), COUNT_BIG(*)),
        N'Assigned user tenant must match task tenant.'
    FROM tasking.Task t
    INNER JOIN core.AppUser u
        ON u.user_id = t.assigned_to_user_id
    WHERE t.assigned_to_user_id IS NOT NULL
      AND t.tenant_id <> u.tenant_id
) AS checks
ORDER BY check_order;

PRINT '02 - Morning shortcuts';
SELECT
    run_order,
    script_name,
    purpose,
    info_tip
FROM (VALUES
    (1, N'05__operator_dashboard_home.sql', N'Open cockpit and shortcuts', N'Keep this open as your home tab.'),
    (2, N'10__daily_operator_checklist.sql', N'Confirm day readiness', N'Resolve ACTION rows first.'),
    (3, N'02__operations_dashboard.sql', N'Inspect operational state', N'Use for customer/policy/claim/task overview.'),
    (4, N'06__query_library_shortcuts.sql', N'Search and inspect records', N'Use IDs from this script in bridge templates.')
) AS s(run_order, script_name, purpose, info_tip)
ORDER BY run_order;

PRINT '03 - End-of-day shortcuts';
SELECT
    run_order,
    script_name,
    purpose,
    info_tip
FROM (VALUES
    (1, N'10__daily_operator_checklist.sql', N'Re-run checks', N'Confirm no unexpected ACTION rows remain.'),
    (2, N'04__admin_security_audit_queries.sql', N'Review audit/security signals', N'Use after significant data entry sessions.'),
    (3, N'09__graph_report_pack.sql', N'Export report-ready grids', N'Copy to Excel/BI if daily summary is needed.')
) AS s(run_order, script_name, purpose, info_tip)
ORDER BY run_order;
GO
