/*
    Yafes Pars SSMS Workbench - Delivery Gap Register

    INFO TIP:
    Use this read-only screen after commit or PR review. It turns the delivery
    backlog into SSMS Results Grid rows: what is closed, what is superseded by
    the SSMS-first direction, what is blocked by environment evidence, and what
    requires owner approval before migration 019+.

    Enable SQLCMD Mode before running.
    This script is read-only.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE "DEV-BE-BROKER"
:setvar REVIEW_OWNER "Mustafa"

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [master];
GO

DECLARE @TargetDatabase SYSNAME = N'$(YAFES_SQL_DATABASE)';
DECLARE @ServerName NVARCHAR(256) = LOWER(CONVERT(NVARCHAR(256), @@SERVERNAME));
DECLARE @MachineName NVARCHAR(256) = LOWER(CONVERT(NVARCHAR(256), SERVERPROPERTY('MachineName')));

IF @TargetDatabase NOT LIKE N'%DEV%'
    THROW 52160, 'Target database name must contain DEV.', 1;

IF @ServerName LIKE N'%prod%' OR @ServerName LIKE N'%production%' OR @ServerName LIKE N'%prd%' OR @ServerName LIKE N'%live%'
    THROW 52161, 'Connected server name suggests production/live.', 1;

IF @MachineName LIKE N'%prod%' OR @MachineName LIKE N'%production%' OR @MachineName LIKE N'%prd%' OR @MachineName LIKE N'%live%'
    THROW 52162, 'Connected machine name suggests production/live.', 1;

IF DB_ID(@TargetDatabase) IS NULL
    THROW 52163, 'Target DEV database does not exist.', 1;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

DECLARE @TenantCode NVARCHAR(80) = N'$(TENANT_CODE)';
DECLARE @ReviewOwner NVARCHAR(120) = N'$(REVIEW_OWNER)';
DECLARE @TenantId UNIQUEIDENTIFIER;

SELECT @TenantId = tenant_id
FROM core.Tenant
WHERE tenant_code = @TenantCode;

IF @TenantId IS NULL
    THROW 52164, 'Tenant code was not found.', 1;

DECLARE @DomainTableCount INT = (
    SELECT COUNT_BIG(*)
    FROM sys.tables t
    JOIN sys.schemas s
        ON s.schema_id = t.schema_id
    WHERE s.name IN (
        N'core', N'ref', N'person', N'institution', N'risk', N'policy',
        N'coverage', N'claim', N'document', N'tasking', N'audit'
    )
);

DECLARE @MigrationCount INT = (
    SELECT COUNT_BIG(*)
    FROM core.SchemaMigration
);

PRINT 'INFO TIP: This register is read-only. Use it to decide the next SSMS work item before opening edit or migration scripts.';

PRINT '01 - Delivery review context';
SELECT
    @@SERVERNAME AS server_name,
    SERVERPROPERTY('MachineName') AS machine_name,
    DB_NAME() AS database_name,
    @TenantCode AS tenant_code,
    @TenantId AS tenant_id,
    @ReviewOwner AS review_owner,
    @DomainTableCount AS current_domain_table_count,
    @MigrationCount AS applied_migration_count,
    SYSUTCDATETIME() AS checked_at_utc,
    N'INFO TIP: If database_name or tenant_code is unexpected, stop before planning schema or data-entry work.' AS info_tip;

PRINT '02 - Current implementation signals';
WITH Signals AS (
    SELECT
        10 AS signal_order,
        N'Domain table count' AS signal_name,
        CONVERT(NVARCHAR(40), @DomainTableCount) AS observed_value,
        N'108' AS expected_value,
        CASE WHEN @DomainTableCount >= 108 THEN N'OK' ELSE N'REVIEW' END AS signal_status,
        N'INFO TIP: The active migration model is the source of truth; do not downsize to the old 89-table package.' AS info_tip
    UNION ALL
    SELECT
        20,
        N'Migration ledger count',
        CONVERT(NVARCHAR(40), @MigrationCount),
        N'17 tracked ledger rows; 19 source files through 018',
        CASE WHEN @MigrationCount >= 17 THEN N'OK' ELSE N'REVIEW' END,
        N'INFO TIP: 000 and 001 bootstrap the database and schemas before the ledger exists; new schema work starts at migration 019+ only.'
    UNION ALL
    SELECT
        30,
        N'Procedure bridge coverage',
        CONVERT(NVARCHAR(40), COUNT_BIG(*)),
        N'14 required procedures',
        CASE WHEN COUNT_BIG(*) >= 14 THEN N'OK' ELSE N'REVIEW' END,
        N'INFO TIP: Bridge scripts should call stored procedures instead of direct table INSERTs.'
    FROM sys.procedures p
    JOIN sys.schemas s
        ON s.schema_id = p.schema_id
    WHERE CONCAT(s.name, N'.', p.name) IN (
        N'person.SP_CreateNaturalPerson',
        N'person.SP_SearchPerson',
        N'institution.SP_SearchInstitution',
        N'risk.SP_SearchVehicle',
        N'risk.SP_CreateVehicleObject',
        N'policy.SP_CreateContract',
        N'policy.SP_CreateContractVersion',
        N'policy.SP_AddContractParty',
        N'policy.SP_AddContractObject',
        N'claim.SP_CreateClaim',
        N'claim.SP_CloseClaim',
        N'tasking.SP_CreateTask',
        N'tasking.SP_AddTaskComment',
        N'tasking.SP_AddTaskReminder'
    )
    UNION ALL
    SELECT
        40,
        N'Finance ledger tables',
        CONVERT(NVARCHAR(40), COUNT_BIG(*)),
        N'0 until owner-approved 019+ design',
        CASE WHEN COUNT_BIG(*) = 0 THEN N'OWNER_DECISION' ELSE N'IMPLEMENTED' END,
        N'INFO TIP: Do not invent accounting tables before commission/payment ownership is confirmed.'
    FROM sys.tables t
    JOIN sys.schemas s
        ON s.schema_id = t.schema_id
    WHERE CONCAT(s.name, N'.', t.name) IN (
        N'finance.Commission',
        N'finance.PaymentLedger',
        N'finance.BrokerStatement',
        N'claim.ClaimReserve'
    )
    UNION ALL
    SELECT
        50,
        N'Import/export staging tables',
        CONVERT(NVARCHAR(40), COUNT_BIG(*)),
        N'0 until import contract is approved',
        CASE WHEN COUNT_BIG(*) = 0 THEN N'OWNER_DECISION' ELSE N'IMPLEMENTED' END,
        N'INFO TIP: Add staging only after source file formats and validation ownership are agreed.'
    FROM sys.tables t
    JOIN sys.schemas s
        ON s.schema_id = t.schema_id
    WHERE CONCAT(s.name, N'.', t.name) IN (
        N'staging.ImportBatch',
        N'staging.ImportRow',
        N'staging.ImportValidationIssue',
        N'staging.ExportJob'
    )
)
SELECT
    signal_order,
    signal_name,
    observed_value,
    expected_value,
    signal_status,
    info_tip
FROM Signals
ORDER BY signal_order;

DECLARE @RequiredProcedure TABLE (
    procedure_order INT NOT NULL,
    procedure_name SYSNAME NOT NULL,
    workflow_name NVARCHAR(120) NOT NULL,
    operator_action NVARCHAR(180) NOT NULL,
    info_tip NVARCHAR(400) NOT NULL
);

INSERT INTO @RequiredProcedure (
    procedure_order,
    procedure_name,
    workflow_name,
    operator_action,
    info_tip
)
VALUES
    (10, N'person.SP_CreateNaturalPerson', N'Customer onboarding', N'CREATE_NATURAL_PERSON', N'INFO TIP: Search first, then create only when no existing person matches.'),
    (20, N'risk.SP_CreateVehicleObject', N'Vehicle risk onboarding', N'CREATE_VEHICLE_OBJECT', N'INFO TIP: Creates risk.InsurableObject plus risk.InsurableVehicle before policy link.'),
    (30, N'policy.SP_CreateContract', N'Policy creation', N'CREATE_POLICY', N'INFO TIP: Confirm institution and holder IDs before execute mode.'),
    (40, N'policy.SP_CreateContractVersion', N'Policy versioning', N'CREATE_POLICY_VERSION', N'INFO TIP: Use after policy root exists and dates are reviewed.'),
    (50, N'policy.SP_AddContractParty', N'Policy party link', N'ADD_POLICY_PARTY', N'INFO TIP: The procedure validates tenant ownership of the person and policy.'),
    (60, N'policy.SP_AddContractObject', N'Policy object link', N'ADD_POLICY_OBJECT', N'INFO TIP: Use output object IDs from vehicle/object bridge.'),
    (70, N'claim.SP_CreateClaim', N'Claim opening', N'CREATE_CLAIM', N'INFO TIP: Handler email resolves to tenant-owned person_id.'),
    (80, N'claim.SP_CloseClaim', N'Claim closure', N'CLOSE_CLAIM', N'INFO TIP: Amount, method, updater, and tenant checks run inside the procedure.'),
    (90, N'tasking.SP_CreateTask', N'Task creation', N'CREATE_TASK', N'INFO TIP: Creates a tenant-owned task with optional related entity validation.'),
    (100, N'tasking.SP_AddTaskComment', N'Task collaboration', N'ADD_TASK_COMMENT', N'INFO TIP: Adds a comment only after task tenant ownership is confirmed.'),
    (110, N'tasking.SP_AddTaskReminder', N'Task reminder', N'ADD_TASK_REMINDER', N'INFO TIP: Adds a future IN_APP, EMAIL, or SMS reminder to an open task.');

PRINT '03 - Procedure-backed bridge readiness';
SELECT
    rp.procedure_order,
    rp.workflow_name,
    rp.operator_action,
    rp.procedure_name,
    CASE WHEN OBJECT_ID(rp.procedure_name, N'P') IS NULL THEN N'MISSING' ELSE N'READY' END AS readiness_status,
    N'database/ssms/07__data_entry_bridge_templates.sql' AS open_script,
    rp.info_tip
FROM @RequiredProcedure rp
ORDER BY rp.procedure_order;

PRINT '04 - Delivery gap register';
SELECT
    priority,
    area,
    current_status,
    ssms_owner_action,
    open_script_or_doc,
    stop_condition,
    info_tip
FROM (VALUES
    (N'P0', N'Token hygiene', N'EXTERNAL_ACTION_REQUIRED', N'Rotate or revoke any coordination token that was shared outside the credential manager.', N'GitHub account/security settings', N'Token owner confirms rotation.', N'INFO TIP: Credentials must never be stored in Git, docs, SQL files, or chat transcripts used as evidence.'),
    (N'P1', N'TEST/PROD execution evidence', N'WAITING_ENVIRONMENT', N'Run approved migration/validation evidence after target environments are refreshed.', N'md/database/migration-execution-log-template.md', N'TEST/PROD owner signs execution evidence.', N'INFO TIP: DEV validation exists; TEST/PROD evidence is environment-owned.'),
    (N'P1', N'TEST/PROD access evidence', N'WAITING_ENVIRONMENT', N'Run role/permission review and attach sign-off for operator, admin, auditor, and deployer.', N'database/ssms/14__admin_role_permission_matrix.sql', N'Access owner signs review evidence.', N'INFO TIP: Use SSMS result grids as source evidence.'),
    (N'P1', N'TEST/PROD restore drill', N'WAITING_ENVIRONMENT', N'Run restore drill and record VERIFYONLY, restored DB validation, and dashboard check.', N'md/database/restore-drill-evidence-template.md', N'DBA signs restore evidence.', N'INFO TIP: DEV restore evidence is not a substitute for target environment proof.'),
    (N'P2', N'Finance ledger and commission', N'OWNER_DECISION_REQUIRED', N'Design accounting flow before adding migration 019+ tables.', N'database/ssms/12__table_catalog_and_relationships.sql', N'Business owner approves ledger entities and ownership.', N'INFO TIP: Claim paid/reserved fields exist, but full ledger/commission model is intentionally not invented yet.'),
    (N'P2', N'Import/export staging', N'OWNER_DECISION_REQUIRED', N'Confirm source file formats, validation issue ownership, and export consumers before 019+.', N'database/ssms/12__table_catalog_and_relationships.sql', N'Import contract and validation ownership are approved.', N'INFO TIP: Add staging with forward-only migration after business rules are known.'),
    (N'P2', N'Department bridge coverage', N'PARTIAL_REMAINING', N'Task creation, task comments, and task reminders are now covered; add the next edge workflow by real department frequency.', N'database/ssms/07__data_entry_bridge_templates.sql', N'Owner ranks next high-frequency non-task workflow.', N'INFO TIP: Core daily create/link/close/task workflows are covered; edge actions should be prioritized.'),
    (N'P3', N'SQL Agent jobs', N'WAITING_INFRASTRUCTURE', N'Promote monitoring blueprints to approved jobs after owners, schedules, and alerts are confirmed.', N'database/ssms/15__monitoring_and_job_readiness.sql', N'DBA approves job names, owners, schedules, and output location.', N'INFO TIP: The current script observes jobs and gives handoff rows; it does not create jobs.')
) AS g(priority, area, current_status, ssms_owner_action, open_script_or_doc, stop_condition, info_tip)
ORDER BY
    CASE priority WHEN N'P0' THEN 0 WHEN N'P1' THEN 1 WHEN N'P2' THEN 2 ELSE 3 END,
    area;

PRINT '05 - Listed commit review closure';
SELECT
    commit_order,
    commit_ref,
    commit_title,
    current_product_position,
    closure_status,
    ssms_evidence
FROM (VALUES
    (10, N'da97249', N'feat: add backend API foundation', N'Optional integration layer remains useful, but SSMS is the primary product surface.', N'KEPT_AS_SUPPORTING_LAYER', N'Backend route inventory is included in the workbench manifest.'),
    (20, N'8388c8a', N'feat: add frontend admin panel foundation', N'Web admin panel direction was superseded by SSMS-first workbench.', N'SUPERSEDED', N'Active operator files are under database/ssms.'),
    (30, N'dcf3b85', N'docs: add final progress report', N'Delivery reporting was centralized under md/reports.', N'CLOSED', N'md/reports/final-progress-report.md'),
    (40, N'528edbd', N'refactor: replace web panel with ssms workbench', N'Current product baseline.', N'CLOSED', N'05 through 16 SSMS workbench files.'),
    (50, N'2890826', N'docs: add ssms visual demo', N'Preview retained only as a non-persistent SSMS-style visual aid.', N'CLOSED_WITH_BOUNDARY', N'database/ssms/demo/index.html'),
    (60, N'fd35cd3', N'docs: improve ssms visual demo usability', N'Superseded by productized controls and manifest synchronization.', N'CLOSED', N'Workbench buttons, tabs, and manifest checks are wired.'),
    (70, N'4a9ca3a', N'chore: professionalize repository governance', N'Governance remains active through policies and quality gates.', N'CLOSED', N'SECURITY.md and CI checks.'),
    (80, N'92bad73', N'feat: add corporate ssms operator workbench', N'Active operator direction.', N'CLOSED', N'05__operator_dashboard_home.sql'),
    (90, N'73fcb17', N'ci: split ssms workbench validation', N'Active CI lane.', N'CLOSED', N'.github/workflows/ssms-workbench-validation.yml'),
    (100, N'd99167b', N'feat: add ssms production readiness gate', N'DEV gate is active; TEST/PROD evidence remains environment-owned.', N'PARTIAL_EXTERNAL', N'Production readiness docs plus gap register P1 rows.'),
    (110, N'1280f20', N'feat: add ssms logic map and table catalog', N'Active planning base; 019+ items require owner approval.', N'CLOSED_WITH_BACKLOG', N'11, 12, 13, and this gap register.'),
    (120, N'6e347e9', N'chore: centralize docs and clean legacy artifacts', N'Docs are under md; legacy package is comparison input only.', N'CLOSED', N'md/README.md and md/mustafaplan.md'),
    (130, N'43efb6b', N'fix: enforce ssms sqlcmd dev execution contract', N'Active safety contract.', N'CLOSED', N'Every SSMS script has SQLCMD and DEV guards.'),
    (140, N'c6dcd23', N'fix: show ssms migration handoff in demo', N'Active handoff model.', N'CLOSED', N'01__run_all_dev_migrations_sqlcmd.sql'),
    (150, N'96aedc1', N'feat: add ssms visual workflow board', N'Active SSMS-native visual board.', N'CLOSED', N'13__visual_workflow_board.sql'),
    (160, N'3d33c43', N'feat: productize ssms demo controls', N'Preview controls are wired; real execution remains SSMS.', N'CLOSED_WITH_BOUNDARY', N'database/ssms/demo/index.html'),
    (170, N'becf7e8', N'feat: shift workbench preview to product language', N'Product language is active, with preview boundary preserved.', N'CLOSED', N'README and operator workbench docs.')
) AS c(commit_order, commit_ref, commit_title, current_product_position, closure_status, ssms_evidence)
ORDER BY commit_order;

PRINT '06 - Recommended next SSMS actions';
SELECT
    action_order,
    action_group,
    open_script_or_doc,
    action_mode,
    recommended_action,
    info_tip
FROM (VALUES
    (10, N'Control', N'database/ssms/16__delivery_gap_register.sql', N'READ_ONLY', N'Run this after PR/commit review to keep open items visible.', N'INFO TIP: This is the source screen for unfinished delivery items.'),
    (20, N'Daily data entry', N'database/ssms/07__data_entry_bridge_templates.sql', N'PREVIEW_FIRST', N'Continue core bridge workflows for person, vehicle object, policy, policy links, claims, and tasks.', N'INFO TIP: Keep EXECUTE_ACTION = 0 until preview grids are correct.'),
    (30, N'Access evidence', N'database/ssms/14__admin_role_permission_matrix.sql', N'READ_ONLY', N'Use result sets as access-review source evidence.', N'INFO TIP: TEST/PROD sign-off still belongs to the environment owner.'),
    (40, N'Monitoring evidence', N'database/ssms/15__monitoring_and_job_readiness.sql', N'READ_ONLY', N'Review observed SQL Agent state and DBA handoff rows.', N'INFO TIP: Do not create jobs from SSMS until DBA runbook is approved.'),
    (50, N'019+ planning', N'database/ssms/12__table_catalog_and_relationships.sql', N'READ_ONLY', N'Review real table catalog before finance/import/product/entity-note design.', N'INFO TIP: New schema changes must be forward-only migration 019+ after owner approval.')
) AS a(action_order, action_group, open_script_or_doc, action_mode, recommended_action, info_tip)
ORDER BY action_order;
GO
