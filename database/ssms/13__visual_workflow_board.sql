/*
    Yafes Pars SSMS Workbench - Visual Workflow Board

    INFO TIP:
    This read-only script turns the visual/mind-map idea into SSMS-friendly
    Results Grid datasets. It gives operators domain cards, subheading cards,
    node/edge rows, template routes, and readiness gaps without pretending SSMS
    has native drag/drop UI behavior.

    Enable SQLCMD Mode before running.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE "DEMO-BE-BROKER"
:setvar FOCUS_DOMAIN "ALL"

SET NOCOUNT ON;
GO

USE [master];
GO

DECLARE @TargetDatabase SYSNAME = N'$(YAFES_SQL_DATABASE)';
DECLARE @ServerName NVARCHAR(256) = LOWER(CONVERT(NVARCHAR(256), @@SERVERNAME));
DECLARE @MachineName NVARCHAR(256) = LOWER(CONVERT(NVARCHAR(256), SERVERPROPERTY('MachineName')));

IF @TargetDatabase NOT LIKE N'%DEV%'
    THROW 52900, 'Target database name must contain DEV.', 1;

IF @ServerName LIKE N'%prod%' OR @ServerName LIKE N'%production%' OR @ServerName LIKE N'%prd%' OR @ServerName LIKE N'%live%'
    THROW 52901, 'Connected server name suggests production/live.', 1;

IF @MachineName LIKE N'%prod%' OR @MachineName LIKE N'%production%' OR @MachineName LIKE N'%prd%' OR @MachineName LIKE N'%live%'
    THROW 52902, 'Connected machine name suggests production/live.', 1;

IF DB_ID(@TargetDatabase) IS NULL
    THROW 52903, 'Target DEV database does not exist.', 1;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

IF DB_NAME() NOT LIKE N'%DEV%'
    THROW 52904, 'Current database name must contain DEV.', 1;

DECLARE @TenantCode NVARCHAR(80) = N'$(TENANT_CODE)';
DECLARE @FocusDomain NVARCHAR(80) = UPPER(NULLIF(N'$(FOCUS_DOMAIN)', N''));

IF @FocusDomain IS NULL
    SET @FocusDomain = N'ALL';

DECLARE @ActualTableCount INT;

SELECT @ActualTableCount = COUNT(*)
FROM sys.tables t
INNER JOIN sys.schemas s
    ON s.schema_id = t.schema_id
WHERE s.name IN (N'core', N'ref', N'person', N'institution', N'risk', N'policy', N'coverage', N'claim', N'document', N'tasking', N'audit');

DECLARE @Domain TABLE (
    domain_order INT NOT NULL PRIMARY KEY,
    board_lane NVARCHAR(80) NOT NULL,
    domain_group NVARCHAR(80) NOT NULL,
    schema_name SYSNAME NOT NULL,
    display_title NVARCHAR(120) NOT NULL,
    primary_tables NVARCHAR(500) NOT NULL,
    operator_goal NVARCHAR(500) NOT NULL,
    ssms_entry_point NVARCHAR(180) NOT NULL,
    info_tip NVARCHAR(500) NOT NULL
);

INSERT INTO @Domain (
    domain_order,
    board_lane,
    domain_group,
    schema_name,
    display_title,
    primary_tables,
    operator_goal,
    ssms_entry_point,
    info_tip
)
VALUES
    (10, N'Foundation', N'Core', N'core', N'Tenant and access foundation', N'Tenant | AppUser | Role | Permission | SchemaMigration', N'Confirm tenant, role, and migration state before work starts.', N'04__admin_security_audit_queries.sql', N'Core cards should be locked before daily work.'),
    (20, N'Foundation', N'Reference', N'ref', N'Lookup standards', N'Language | Title | PhoneType | SocialType | ProfessionalStatus | PersonType', N'Give operators controlled dropdown-like choices in SSMS grids.', N'06__query_library_shortcuts.sql', N'Codes should be copied from lookup grids, not typed from memory.'),
    (30, N'Customer', N'Person', N'person', N'Customer identity', N'Person | NaturalPerson | LegalPerson | Address | Phone | Email | BankAccount | DriverLicense | Relations', N'Find, create, and relate customers with preview-first bridges.', N'07__data_entry_bridge_templates.sql', N'Person is normally the first search step in operator work.'),
    (40, N'Customer', N'Institution', N'institution', N'Company and institution identity', N'Institution | InstitutionIdentifier | InstitutionAddress | Role lookups', N'Keep insurers, banks, brokers, and companies consistent.', N'06__query_library_shortcuts.sql', N'Institution identifiers drive policy quality and reporting.'),
    (50, N'Insurance Core', N'Risk/Object', N'risk', N'Insurable object model', N'InsurableObject | Vehicle | RealEstate | Loan | Person | Thing | Activity | object lookups', N'Attach concrete insured objects to policies without unsafe generic naming.', N'06__query_library_shortcuts.sql', N'Use risk.InsurableObject as the root for insured objects.'),
    (60, N'Insurance Core', N'Policy', N'policy', N'Policy and contract hub', N'Contract | ContractVersion | ContractParty | ContractObject | ContractTakeover | statuses', N'Connect customers, institutions, risks, coverage, renewals, and claims.', N'03__create_renewal_tasks.sql', N'Policy is the central operating record.'),
    (70, N'Insurance Core', N'Coverage', N'coverage', N'Coverage package model', N'Coverage | CoverageDomain | CoveragePackage | CoveragePackageItem', N'Group coverage definitions and package composition by domain.', N'09__graph_report_pack.sql', N'Coverage maps product logic to policies and claims.'),
    (80, N'Operations', N'Claim', N'claim', N'Claim workflow', N'Claim | ClaimParty | ClaimObject | ClaimCircumstance | status/payment lookups', N'Open and inspect claim files with policy, object, party, and payment context.', N'06__query_library_shortcuts.sql', N'Claims should always be reviewed with tenant and policy context.'),
    (90, N'Operations', N'Document', N'document', N'Document metadata', N'Document | DocumentLink | DocumentVersion | DocumentType', N'Link external documents without storing binaries in SQL Server.', N'08__data_editing_guardrails.sql', N'Keep document binaries outside SQL Server.'),
    (100, N'Operations', N'Task', N'tasking', N'Operator work queue', N'Task | TaskComment | TaskReminder | TaskStatus | TaskPriority', N'Drive daily follow-up, renewal work, comments, reminders, and queues.', N'10__daily_operator_checklist.sql', N'Tasks are the daily operator cockpit.'),
    (110, N'Control', N'Audit', N'audit', N'Audit and evidence trail', N'AuditLog | EntityChangeSet', N'Review changes after guarded edits and release actions.', N'04__admin_security_audit_queries.sql', N'Audit is read-only operational evidence.');

DECLARE @Subheading TABLE (
    domain_order INT NOT NULL,
    subheading_order INT NOT NULL,
    subheading NVARCHAR(120) NOT NULL,
    table_group NVARCHAR(700) NOT NULL,
    safe_action NVARCHAR(220) NOT NULL,
    template_route NVARCHAR(180) NOT NULL,
    info_tip NVARCHAR(500) NOT NULL,
    PRIMARY KEY (domain_order, subheading_order)
);

INSERT INTO @Subheading (
    domain_order,
    subheading_order,
    subheading,
    table_group,
    safe_action,
    template_route,
    info_tip
)
VALUES
    (10, 10, N'Tenant boundary', N'core.Tenant', N'Open dashboard context and confirm tenant_code.', N'05__operator_dashboard_home.sql', N'Never guess tenant_id. Resolve it from tenant_code.'),
    (10, 20, N'Access control', N'core.AppUser | core.Role | core.Permission | core.RolePermission | core.UserRole', N'Run admin/security audit before granting or testing access.', N'04__admin_security_audit_queries.sql', N'Least privilege must be proven in DEV/TEST.'),
    (10, 30, N'Migration ledger', N'core.SchemaMigration', N'Compare expected migrations with execution evidence.', N'01__run_all_dev_migrations_sqlcmd.sql', N'Migrations are generated as all-in-one SSMS scripts.'),
    (20, 10, N'Person lookup choices', N'ref.Language | ref.Title | ref.PersonType | ref.ProfessionalStatus', N'Use lookup grids before creating person data.', N'06__query_library_shortcuts.sql', N'Lookup values are seed-controlled.'),
    (20, 20, N'Contact lookup choices', N'ref.PhoneType | ref.SocialType', N'Copy valid codes from Results Grid.', N'06__query_library_shortcuts.sql', N'Avoid free-text codes in bridge templates.'),
    (30, 10, N'Identity roots', N'person.Person | person.NaturalPerson | person.LegalPerson', N'Find existing person first, then use create bridge if needed.', N'07__data_entry_bridge_templates.sql', N'Duplicate identity is more expensive than slow search.'),
    (30, 20, N'Contact details', N'person.Address | person.Phone | person.Email | person.SocialMedia', N'Preview create/edit actions and verify row count.', N'08__data_editing_guardrails.sql', N'Contacts are tenant-scoped and soft-delete aware.'),
    (30, 30, N'Financial and legal detail', N'person.BankAccount | person.DriverLicense | person.EconomicActivity', N'Use guarded templates and validate owner identity.', N'07__data_entry_bridge_templates.sql', N'Treat bank/license data as sensitive operational data.'),
    (30, 40, N'Relations', N'person.PersonRelation | person.PersonRelationPerson | person.PersonPersonType', N'Build relations only after both person IDs are verified.', N'06__query_library_shortcuts.sql', N'Copy IDs from search grids.'),
    (40, 10, N'Institution roots', N'institution.Institution | institution.InstitutionRole', N'Search by name/identifier before creating.', N'06__query_library_shortcuts.sql', N'Institutions feed policy company and broker fields.'),
    (40, 20, N'Institution identifiers', N'institution.InstitutionIdentifier | institution.InstitutionIdentifierType', N'Validate identifiers before policy linking.', N'08__data_editing_guardrails.sql', N'Identifier quality affects reporting and duplicate checks.'),
    (40, 30, N'Institution addresses', N'institution.InstitutionAddress | institution.InstitutionAddressRole', N'Preview edits and keep old address evidence.', N'08__data_editing_guardrails.sql', N'Use address roles rather than duplicate institution rows.'),
    (50, 10, N'Object root', N'risk.InsurableObject | risk.InsurableObjectType', N'Create/find root object before subtype details.', N'06__query_library_shortcuts.sql', N'This replaces any unsafe generic Object table idea.'),
    (50, 20, N'Vehicle risk', N'risk.InsurableVehicle | VehicleType | UsageType | FuelType | DriveType | LicensePlateType', N'Use lookup-guided templates for vehicle fields.', N'07__data_entry_bridge_templates.sql', N'Vehicle details should not be created as free text.'),
    (50, 30, N'Real estate risk', N'risk.InsurableRealEstate | ConstructionType | RoofType | OccupancyLevel | BurglaryProtectionType', N'Preview subtype fields before linking to policy.', N'07__data_entry_bridge_templates.sql', N'Real estate has many lookup-driven controls.'),
    (50, 40, N'Loan/person/thing/activity risk', N'risk.InsurableLoan | risk.InsurablePerson | risk.InsurableThing | risk.InsurableActivity', N'Choose subtype intentionally before policy object link.', N'06__query_library_shortcuts.sql', N'Subtype choice determines later reporting.'),
    (60, 10, N'Contract root', N'policy.Contract | policy.ContractDomain | policy.ContractType | policy.ContractStatus', N'Confirm policy root before versions, parties, objects, claims.', N'06__query_library_shortcuts.sql', N'Contract is the central operating row.'),
    (60, 20, N'Versions and status', N'policy.ContractVersion | policy.ContractVersionStatus | policy.DurationType | policy.Periodicity', N'Use timeline grids before endorsement or renewal work.', N'03__create_renewal_tasks.sql', N'Versions should preserve history.'),
    (60, 30, N'Parties and objects', N'policy.ContractParty | policy.ContractObject | policy.ContractVersionObject | policy.ContractPartyRole', N'Copy person/object IDs from search grids before linking.', N'07__data_entry_bridge_templates.sql', N'Links are safer than direct free-text edits.'),
    (60, 40, N'Takeovers and collection', N'policy.ContractTakeover | policy.CollectionMethod | policy.TakeoverDirection | policy.TakeoverSourceType', N'Use guarded review for operational edge cases.', N'08__data_editing_guardrails.sql', N'Takeover data often needs audit evidence.'),
    (70, 10, N'Coverage catalog', N'coverage.Coverage | coverage.CoverageDomain', N'Review package rules before adding new product behavior.', N'09__graph_report_pack.sql', N'Coverage controls reporting dimensions.'),
    (70, 20, N'Coverage packages', N'coverage.CoveragePackage | coverage.CoveragePackageItem', N'Compare package rows before migration 019+ product work.', N'09__graph_report_pack.sql', N'Package composition should be reported before edited.'),
    (80, 10, N'Claim root', N'claim.Claim | claim.ClaimStatus | claim.ClaimPaymentMethod', N'Find policy and tenant before opening or editing claim.', N'06__query_library_shortcuts.sql', N'Claim has payment fields but not a full ledger yet.'),
    (80, 20, N'Claim participants', N'claim.ClaimParty | claim.ClaimPartyRole | claim.ClaimObject', N'Copy person/object IDs from search grids.', N'07__data_entry_bridge_templates.sql', N'Claim parties and objects must match policy context.'),
    (80, 30, N'Claim facts', N'claim.ClaimCircumstance | claim.ClaimCircumstanceType', N'Use guarded edits and audit review for sensitive facts.', N'08__data_editing_guardrails.sql', N'Circumstances should be reviewed after edit.'),
    (90, 10, N'Document root', N'document.Document | document.DocumentType', N'Create metadata only; keep binary storage external.', N'07__data_entry_bridge_templates.sql', N'SQL Server should store metadata and storage keys only.'),
    (90, 20, N'Document links and versions', N'document.DocumentLink | document.DocumentVersion', N'Preview link/version changes before commit.', N'08__data_editing_guardrails.sql', N'Document links connect policy, claim, person, or task context.'),
    (100, 10, N'Task root', N'tasking.Task | tasking.TaskStatus | tasking.TaskPriority', N'Use daily checklist and operations dashboard for queue work.', N'10__daily_operator_checklist.sql', N'Tasks are the operator action list.'),
    (100, 20, N'Task collaboration', N'tasking.TaskComment | tasking.TaskReminder', N'Add comments/reminders through guided patterns.', N'07__data_entry_bridge_templates.sql', N'Comments should not replace audit evidence.'),
    (110, 10, N'Audit evidence', N'audit.AuditLog | audit.EntityChangeSet', N'Review after guarded edits, releases, and permission changes.', N'04__admin_security_audit_queries.sql', N'Audit rows are evidence, not operator work items.');

DECLARE @TemplateRoute TABLE (
    route_order INT NOT NULL PRIMARY KEY,
    domain_group NVARCHAR(80) NOT NULL,
    action_type NVARCHAR(40) NOT NULL,
    ssms_file NVARCHAR(180) NOT NULL,
    template_mode NVARCHAR(80) NOT NULL,
    operator_rule NVARCHAR(500) NOT NULL,
    info_tip NVARCHAR(500) NOT NULL
);

INSERT INTO @TemplateRoute (
    route_order,
    domain_group,
    action_type,
    ssms_file,
    template_mode,
    operator_rule,
    info_tip
)
VALUES
    (10, N'All', N'START', N'05__operator_dashboard_home.sql', N'READ_ONLY', N'Open this first and keep it pinned.', N'The dashboard is the SSMS home surface.'),
    (20, N'All', N'LEARN', N'11__schema_working_logic_map.sql', N'READ_ONLY', N'Review domain groups and control points before changes.', N'Use this before explaining the system to a new user.'),
    (30, N'All', N'VISUAL_BOARD', N'13__visual_workflow_board.sql', N'READ_ONLY', N'Use node/edge grids as the SSMS equivalent of a mind-map board.', N'Rows can be copied to Excel, Power BI, or a future visual renderer.'),
    (40, N'All', N'CATALOG', N'12__table_catalog_and_relationships.sql', N'READ_ONLY', N'Inspect real table and FK metadata before adding tables.', N'The catalog is the source of truth for table count.'),
    (50, N'All', N'FIND_ID', N'06__query_library_shortcuts.sql', N'READ_ONLY', N'Search first and copy IDs from Results Grid.', N'Never type GUIDs from memory.'),
    (60, N'Person', N'CREATE', N'07__data_entry_bridge_templates.sql', N'REVIEW_BEFORE_COMMIT', N'Use stored procedure bridge patterns for create actions.', N'Preview input rows and output IDs.'),
    (70, N'Policy', N'CREATE', N'07__data_entry_bridge_templates.sql', N'REVIEW_BEFORE_COMMIT', N'Create links only after person, institution, and object IDs are verified.', N'Bridge sequence matters more than screen speed.'),
    (80, N'Claim', N'CREATE', N'07__data_entry_bridge_templates.sql', N'REVIEW_BEFORE_COMMIT', N'Open claim work from verified policy context.', N'Claim workflow starts from policy context.'),
    (90, N'All', N'EDIT', N'08__data_editing_guardrails.sql', N'ROLLBACK_DEFAULT', N'Preview before/after rows and keep rollback default until approved.', N'Commit only after row count is correct.'),
    (100, N'All', N'REPORT', N'09__graph_report_pack.sql', N'READ_ONLY', N'Use chart_axis, chart_series, and chart_value grids for reports.', N'Export grids to Excel or BI when needed.'),
    (110, N'All', N'AUDIT', N'04__admin_security_audit_queries.sql', N'READ_ONLY', N'Review RBAC, triggers, audit rows, and integrity controls.', N'Run after guarded changes.');

PRINT 'INFO TIP: Visual Workflow Board is read-only. It is the SSMS-safe equivalent of the provided mind-map/board idea.';

PRINT '01 - Visual board operating context';
SELECT
    @@SERVERNAME AS server_name,
    DB_NAME() AS database_name,
    @TenantCode AS tenant_code,
    @FocusDomain AS focus_domain,
    @ActualTableCount AS actual_sql_server_table_count,
    108 AS current_source_table_count,
    89 AS legacy_zip_reference_table_count,
    CASE
        WHEN @ActualTableCount = 108 THEN N'OK'
        ELSE N'REVIEW'
    END AS table_count_status,
    N'INFO TIP: Current migrations define 108 tables. The old 89-table visual reference should be treated as comparison input, not the source of truth.' AS info_tip;

PRINT '02 - Domain board lanes and cards';
WITH table_counts AS (
    SELECT
        s.name AS schema_name,
        COUNT_BIG(*) AS table_count
    FROM sys.schemas s
    INNER JOIN sys.tables t
        ON t.schema_id = s.schema_id
    WHERE s.name IN (N'core', N'ref', N'person', N'institution', N'risk', N'policy', N'coverage', N'claim', N'document', N'tasking', N'audit')
    GROUP BY s.name
)
SELECT
    d.board_lane,
    d.domain_order,
    d.domain_group,
    d.schema_name,
    d.display_title,
    COALESCE(tc.table_count, 0) AS table_count,
    d.primary_tables,
    d.operator_goal,
    d.ssms_entry_point,
    d.info_tip
FROM @Domain d
LEFT JOIN table_counts tc
    ON tc.schema_name = d.schema_name
WHERE @FocusDomain = N'ALL'
   OR UPPER(d.domain_group) = @FocusDomain
   OR UPPER(d.schema_name) = @FocusDomain
   OR UPPER(d.board_lane) = @FocusDomain
ORDER BY
    CASE d.board_lane
        WHEN N'Foundation' THEN 10
        WHEN N'Customer' THEN 20
        WHEN N'Insurance Core' THEN 30
        WHEN N'Operations' THEN 40
        WHEN N'Control' THEN 50
        ELSE 999
    END,
    d.domain_order;

PRINT '03 - Domain subheading cards';
SELECT
    d.board_lane,
    d.domain_group,
    s.subheading_order,
    s.subheading,
    s.table_group,
    s.safe_action,
    s.template_route,
    s.info_tip
FROM @Subheading s
INNER JOIN @Domain d
    ON d.domain_order = s.domain_order
WHERE @FocusDomain = N'ALL'
   OR UPPER(d.domain_group) = @FocusDomain
   OR UPPER(d.schema_name) = @FocusDomain
   OR UPPER(d.board_lane) = @FocusDomain
ORDER BY d.domain_order, s.subheading_order;

PRINT '04 - Mind map nodes for SSMS grid or future renderer';
WITH nodes AS (
    SELECT
        0 AS sort_order,
        CAST(N'ROOT' AS NVARCHAR(120)) AS node_id,
        CAST(NULL AS NVARCHAR(120)) AS parent_node_id,
        CAST(N'ROOT' AS NVARCHAR(40)) AS node_type,
        CAST(N'Yafes Pars SSMS Workbench' AS NVARCHAR(180)) AS display_label,
        CAST(N'Visual Workflow Board' AS NVARCHAR(120)) AS node_group,
        CAST(N'05__operator_dashboard_home.sql' AS NVARCHAR(180)) AS open_script,
        CAST(N'Start here, then open the board/catalog/query routes.' AS NVARCHAR(500)) AS info_tip
    UNION ALL
    SELECT
        d.domain_order,
        CONCAT(N'DOMAIN_', d.schema_name),
        N'ROOT',
        N'DOMAIN',
        d.display_title,
        d.board_lane,
        d.ssms_entry_point,
        d.info_tip
    FROM @Domain d
    UNION ALL
    SELECT
        1000 + (s.domain_order * 10) + s.subheading_order,
        CONCAT(N'SUB_', d.schema_name, N'_', CONVERT(NVARCHAR(20), s.subheading_order)),
        CONCAT(N'DOMAIN_', d.schema_name),
        N'SUBHEADING',
        s.subheading,
        d.domain_group,
        s.template_route,
        s.info_tip
    FROM @Subheading s
    INNER JOIN @Domain d
        ON d.domain_order = s.domain_order
)
SELECT
    node_id,
    parent_node_id,
    node_type,
    display_label,
    node_group,
    open_script,
    info_tip
FROM nodes
WHERE @FocusDomain = N'ALL'
   OR node_id = N'ROOT'
   OR UPPER(node_group) = @FocusDomain
   OR node_id LIKE CONCAT(N'%_', LOWER(@FocusDomain), N'%')
ORDER BY sort_order, node_id;

PRINT '05 - Mind map edges and control points';
SELECT
    edge_order,
    from_node_id,
    to_node_id,
    relationship_label,
    control_point,
    recommended_script,
    info_tip
FROM (VALUES
    (10, N'ROOT', N'DOMAIN_core', N'Starts with tenant/security context', N'TENANT_CODE and roles', N'05__operator_dashboard_home.sql', N'Every operator route needs context first.'),
    (20, N'DOMAIN_core', N'DOMAIN_ref', N'Provides validated lookup choices', N'Seed validation', N'06__query_library_shortcuts.sql', N'Lookups act like SSMS dropdown inputs.'),
    (30, N'DOMAIN_ref', N'DOMAIN_person', N'Feeds identity/contact choices', N'Lookup code copy', N'07__data_entry_bridge_templates.sql', N'Create with bridge templates after lookup review.'),
    (40, N'DOMAIN_person', N'DOMAIN_policy', N'Person becomes policy party', N'policy.ContractParty', N'06__query_library_shortcuts.sql', N'Copy person_id from search grids.'),
    (50, N'DOMAIN_institution', N'DOMAIN_policy', N'Institution becomes insurer/bank/broker', N'policy.Contract.institution_id', N'06__query_library_shortcuts.sql', N'Validate institution identifier quality.'),
    (60, N'DOMAIN_risk', N'DOMAIN_policy', N'Risk object attaches to contract', N'policy.ContractObject', N'07__data_entry_bridge_templates.sql', N'Use subtype tables for object detail.'),
    (70, N'DOMAIN_policy', N'DOMAIN_coverage', N'Policy uses coverage packages', N'coverage.CoveragePackageItem', N'09__graph_report_pack.sql', N'Report package composition before product changes.'),
    (80, N'DOMAIN_policy', N'DOMAIN_claim', N'Claim opens against policy', N'claim.Claim.contract_id', N'06__query_library_shortcuts.sql', N'Verify policy and tenant before claim work.'),
    (90, N'DOMAIN_claim', N'DOMAIN_document', N'Claim can link documents', N'document.DocumentLink', N'08__data_editing_guardrails.sql', N'Keep binaries external.'),
    (100, N'DOMAIN_policy', N'DOMAIN_tasking', N'Renewals become tasks', N'tasking.Task.related_entity_id', N'03__create_renewal_tasks.sql', N'Dry-run renewal generation first.'),
    (110, N'DOMAIN_claim', N'DOMAIN_tasking', N'Claim follow-up becomes tasks', N'tasking.Task.related_entity_id', N'10__daily_operator_checklist.sql', N'Queue work should be visible daily.'),
    (120, N'DOMAIN_tasking', N'DOMAIN_audit', N'Guarded edits create review trail', N'audit.AuditLog', N'04__admin_security_audit_queries.sql', N'Review audit after commits.')
) AS e(edge_order, from_node_id, to_node_id, relationship_label, control_point, recommended_script, info_tip)
WHERE @FocusDomain = N'ALL'
   OR UPPER(from_node_id) LIKE CONCAT(N'%', @FocusDomain, N'%')
   OR UPPER(to_node_id) LIKE CONCAT(N'%', @FocusDomain, N'%')
ORDER BY edge_order;

PRINT '06 - Ready template routes';
SELECT
    route_order,
    domain_group,
    action_type,
    ssms_file,
    template_mode,
    operator_rule,
    info_tip
FROM @TemplateRoute
WHERE @FocusDomain = N'ALL'
   OR UPPER(domain_group) = @FocusDomain
   OR domain_group = N'All'
ORDER BY route_order;

PRINT '07 - Visual idea readiness and gaps';
SELECT
    readiness_order,
    capability,
    current_status,
    implementation_rule,
    next_action,
    info_tip
FROM (VALUES
    (10, N'SSMS-native dashboard', N'READY', N'Use Results Grid shortcut rows from 05 and this file.', N'Keep scripts read-only unless action requires bridge/guardrail.', N'Fits real SSMS behavior.'),
    (20, N'Mind-map style groups', N'READY', N'Use result sets 02, 03, 04, and 05 as node/card data.', N'Demo should mirror these rows visually.', N'Visual renderer is optional; SSMS grid remains source.'),
    (30, N'Prepared table cards', N'READY', N'Use table catalog 12 and domain card rows here.', N'Add owner-approved 019+ candidates only after table comparison.', N'Current source model has 108 tables.'),
    (40, N'Drag/drop behavior', N'SSMS_ADAPTED', N'Replace native drag/drop with choose-route, preview, execute/rollback workflow.', N'Use query library plus bridge templates.', N'SSMS cannot safely behave like a web canvas for data changes.'),
    (50, N'89 vs 108 table reconciliation', N'OPEN', N'Treat old 89-table package as reference and current migrations as source of truth.', N'Compare names before removing or adding any table.', N'Do not downsize the model only to match an old visual count.'),
    (60, N'Every-table bridge coverage', N'PARTIAL', N'High-frequency create/edit paths have templates; lower-frequency tables need prioritization.', N'Add bridge coverage by operator workflow priority.', N'Coverage should follow real daily usage.')
) AS r(readiness_order, capability, current_status, implementation_rule, next_action, info_tip)
ORDER BY readiness_order;
GO
