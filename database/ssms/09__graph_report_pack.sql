/*
    Yafes Pars SSMS Workbench - Graph And Report Pack

    INFO TIP:
    SSMS does not render native dashboard charts in Query Editor, so this pack
    returns chart-ready datasets and simple text bars. Copy result grids to
    Excel, Power BI, or SSMS reports when visual charts are needed.

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
    THROW 52599, 'Current database name must contain DEV.', 1;

DECLARE @TenantCode NVARCHAR(80) = N'$(TENANT_CODE)';
DECLARE @TenantId UNIQUEIDENTIFIER;

SELECT @TenantId = tenant_id
FROM core.Tenant
WHERE tenant_code = @TenantCode;

IF @TenantId IS NULL
    THROW 52500, 'Tenant code was not found.', 1;

PRINT 'INFO TIP: Every result set includes chart_axis/chart_value fields where practical.';

PRINT '01 - Policy portfolio by domain';
WITH domain_counts AS (
    SELECT
        contract_domain_code,
        COUNT_BIG(*) AS policy_count
    FROM policy.Contract
    WHERE tenant_id = @TenantId
      AND is_deleted = 0
    GROUP BY contract_domain_code
),
scaled AS (
    SELECT
        contract_domain_code,
        policy_count,
        MAX(policy_count) OVER () AS max_policy_count
    FROM domain_counts
)
SELECT
    contract_domain_code AS chart_axis,
    policy_count AS chart_value,
    REPLICATE(N'#', CASE WHEN max_policy_count = 0 THEN 0 ELSE CONVERT(INT, CEILING(policy_count * 30.0 / max_policy_count)) END) AS text_bar,
    N'INFO TIP: Use this to spot portfolio concentration by domain.' AS info_tip
FROM scaled
ORDER BY policy_count DESC, contract_domain_code;

PRINT '02 - Claims by status';
WITH claim_counts AS (
    SELECT
        claim_status_code,
        COUNT_BIG(*) AS claim_count
    FROM claim.Claim
    WHERE tenant_id = @TenantId
      AND is_deleted = 0
    GROUP BY claim_status_code
),
scaled AS (
    SELECT
        claim_status_code,
        claim_count,
        MAX(claim_count) OVER () AS max_claim_count
    FROM claim_counts
)
SELECT
    claim_status_code AS chart_axis,
    claim_count AS chart_value,
    REPLICATE(N'#', CASE WHEN max_claim_count = 0 THEN 0 ELSE CONVERT(INT, CEILING(claim_count * 30.0 / max_claim_count)) END) AS text_bar,
    N'INFO TIP: High open/in-progress counts may need handler review.' AS info_tip
FROM scaled
ORDER BY claim_count DESC, claim_status_code;

PRINT '03 - Task due aging';
SELECT
    aging_bucket AS chart_axis,
    COUNT_BIG(*) AS chart_value,
    REPLICATE(N'#', CONVERT(INT, COUNT_BIG(*))) AS text_bar,
    N'INFO TIP: Overdue and due-today tasks are operator priority.' AS info_tip
FROM (
    SELECT
        CASE
            WHEN due_at_utc IS NULL THEN N'No due date'
            WHEN due_at_utc < SYSUTCDATETIME() THEN N'Overdue'
            WHEN CONVERT(DATE, due_at_utc) = CONVERT(DATE, SYSUTCDATETIME()) THEN N'Due today'
            WHEN due_at_utc < DATEADD(DAY, 7, SYSUTCDATETIME()) THEN N'Next 7 days'
            ELSE N'Later'
        END AS aging_bucket
    FROM tasking.Task
    WHERE tenant_id = @TenantId
      AND is_deleted = 0
      AND task_status_code IN (N'OPEN', N'IN_PROGRESS', N'WAITING')
) AS bucketed
GROUP BY aging_bucket
ORDER BY
    CASE aging_bucket
        WHEN N'Overdue' THEN 1
        WHEN N'Due today' THEN 2
        WHEN N'Next 7 days' THEN 3
        WHEN N'Later' THEN 4
        ELSE 5
    END;

PRINT '04 - Renewal calendar next 90 days';
SELECT
    CONVERT(CHAR(7), end_date, 120) AS chart_axis,
    COUNT_BIG(*) AS chart_value,
    MIN(end_date) AS first_end_date,
    MAX(end_date) AS last_end_date,
    N'INFO TIP: Run renewal dry-run before creating tasks for these policies.' AS info_tip
FROM policy.Contract
WHERE tenant_id = @TenantId
  AND is_deleted = 0
  AND contract_status_code = N'ACTIVE'
  AND end_date BETWEEN CONVERT(DATE, SYSUTCDATETIME()) AND DATEADD(DAY, 90, CONVERT(DATE, SYSUTCDATETIME()))
GROUP BY CONVERT(CHAR(7), end_date, 120)
ORDER BY chart_axis;

PRINT '05 - Coverage package matrix';
SELECT
    cp.contract_domain_code,
    cp.package_code,
    COUNT(cpi.coverage_code) AS coverage_count,
    SUM(CASE WHEN cpi.is_mandatory = 1 THEN 1 ELSE 0 END) AS mandatory_count,
    SUM(CASE WHEN cpi.is_mandatory = 0 THEN 1 ELSE 0 END) AS optional_count,
    N'INFO TIP: Use this before changing package contents or product rules.' AS info_tip
FROM coverage.CoveragePackage cp
LEFT JOIN coverage.CoveragePackageItem cpi
    ON cpi.coverage_package_id = cp.coverage_package_id
WHERE cp.is_active = 1
GROUP BY cp.contract_domain_code, cp.package_code
ORDER BY cp.contract_domain_code, cp.package_code;

PRINT '06 - Export catalog';
SELECT
    export_name,
    intended_consumer,
    recommended_source_script,
    info_tip
FROM (VALUES
    (N'Portfolio summary', N'Operations lead', N'09__graph_report_pack.sql result sets 01 and 04', N'Copy to Excel or BI for trend charts.'),
    (N'Open claims review', N'Claims handler', N'06__query_library_shortcuts.sql section 05', N'Filter by handler after export if needed.'),
    (N'Task backlog', N'Team lead', N'09__graph_report_pack.sql section 03', N'Focus overdue and due-today buckets first.'),
    (N'Coverage catalog', N'Product owner', N'09__graph_report_pack.sql section 05', N'Useful for package review sessions.')
) AS exports(export_name, intended_consumer, recommended_source_script, info_tip)
ORDER BY export_name;
GO
