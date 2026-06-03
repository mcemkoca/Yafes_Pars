/*
    Yafes Pars SSMS Workbench - Schema Working Logic Map

    INFO TIP:
    This read-only script explains how the database works as domain groups,
    subheadings, control points, and operator entry scripts. Use it before
    designing new tables or deciding whether a new migration is needed.

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
    THROW 52799, 'Current database name must contain DEV.', 1;

DECLARE @TenantCode NVARCHAR(80) = N'$(TENANT_CODE)';

PRINT 'INFO TIP: This map is read-only and is designed for SSMS Results Grid review.';

PRINT '01 - Domain groups and subheadings';
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
    domain_order,
    domain_group,
    subheading,
    schema_name,
    COALESCE(tc.table_count, 0) AS table_count,
    working_logic,
    ssms_entry_point,
    info_tip
FROM (VALUES
    (10, N'Core', N'Tenant, users, RBAC, migration ledger', N'core', N'Sets identity, tenant isolation, role permissions, and schema migration tracking.', N'04__admin_security_audit_queries.sql', N'Use this first when access, tenant, or migration state is unclear.'),
    (20, N'Reference', N'Languages, statuses, lookup standards', N'ref', N'Provides shared lookup values used by people, contact details, and domain scripts.', N'06__query_library_shortcuts.sql', N'Lookup values should be selected from grids, not typed from memory.'),
    (30, N'Person', N'Natural/legal identity, contacts, relations', N'person', N'Owns customer identity, addresses, phones, email, bank accounts, licenses, and relationships.', N'07__data_entry_bridge_templates.sql', N'Create people through stored procedures and copy IDs from search grids.'),
    (40, N'Institution', N'Insurers, banks, brokers, identifiers', N'institution', N'Owns company/institution identity, roles, identifiers, and addresses.', N'06__query_library_shortcuts.sql', N'Institution IDs feed policy company and broker workflows.'),
    (50, N'Risk/Object', N'Vehicle, real estate, loan, person risk, thing, activity', N'risk', N'Replaces the unsafe generic Object table name with risk.InsurableObject and subtype tables.', N'06__query_library_shortcuts.sql', N'Use risk.InsurableObject for all insured object relationships.'),
    (60, N'Policy', N'Contract, versions, parties, objects, takeovers', N'policy', N'Connects persons, institutions, insurable objects, status, versions, and renewal dates.', N'03__create_renewal_tasks.sql', N'Policy is the central operational hub for renewals and claims.'),
    (70, N'Coverage', N'Coverage catalog, domain maps, packages', N'coverage', N'Groups coverage definitions and package composition by contract domain.', N'09__graph_report_pack.sql', N'Review package rules before adding new product behavior.'),
    (80, N'Claim', N'Claims, parties, objects, circumstances, payment method', N'claim', N'Connects policy events to claim status, handlers, related parties, covered objects, and paid/reserved amounts.', N'06__query_library_shortcuts.sql', N'Claims should always be inspected with tenant and policy context.'),
    (90, N'Document', N'Metadata, links, versions, storage keys', N'document', N'Stores document metadata and external storage references without keeping binaries in SQL Server.', N'08__data_editing_guardrails.sql', N'Document delete is soft-delete and should be previewed.'),
    (100, N'Task', N'Tasks, comments, reminders, priority/status', N'tasking', N'Owns operational follow-up, renewal tasks, comments, reminders, and daily queues.', N'10__daily_operator_checklist.sql', N'Tasks are the operator work queue.'),
    (110, N'Audit', N'Audit log and change details', N'audit', N'Captures root entity changes for review, compliance, and troubleshooting.', N'04__admin_security_audit_queries.sql', N'Audit is read-only for operators.')
) AS m(domain_order, domain_group, subheading, schema_name, working_logic, ssms_entry_point, info_tip)
LEFT JOIN table_counts tc
    ON tc.schema_name = m.schema_name
ORDER BY domain_order;

PRINT '02 - Working flow with control points';
SELECT
    flow_order,
    source_group,
    target_group,
    relationship_type,
    control_point,
    info_tip
FROM (VALUES
    (10, N'Core', N'All domains', N'Tenant and RBAC context', N'TENANT_CODE and role permissions', N'Every operator script starts by confirming the tenant/database context.'),
    (20, N'Reference', N'Person/Policy/Claim/Task', N'Lookup selection', N'Seed validation and lookup grids', N'Codes should come from validated lookup tables.'),
    (30, N'Person', N'Policy', N'Policy holder, insured, broker, manager', N'policy.ContractParty', N'Copy person_id from search before create/edit.'),
    (40, N'Institution', N'Policy', N'Insurer/bank/intermediary', N'policy.Contract.institution_id', N'Institution role and identifier quality affects policy reporting.'),
    (50, N'Risk/Object', N'Policy', N'Insurable object attached to contract', N'policy.ContractObject', N'Use risk subtype tables for object details.'),
    (60, N'Policy', N'Coverage', N'Coverage package by domain', N'coverage.CoveragePackageItem', N'Coverage report pack checks product/package composition.'),
    (70, N'Policy', N'Claim', N'Claim opened against policy/coverage', N'claim.Claim.contract_id', N'Claim creation must verify policy and tenant.'),
    (80, N'Policy/Claim/Risk', N'Document', N'Document metadata link', N'document.DocumentLink', N'SQL stores metadata; file storage remains external.'),
    (90, N'Policy/Claim/Document', N'Task', N'Operational follow-up', N'tasking.Task.related_entity_id', N'Renewal and claim actions become queue items.'),
    (100, N'Root domains', N'Audit', N'Change logging', N'audit.AuditLog', N'Audit trail is used after edits and release operations.')
) AS f(flow_order, source_group, target_group, relationship_type, control_point, info_tip)
ORDER BY flow_order;

PRINT '03 - Ready-made board cards for future drag/drop planning';
SELECT
    card_order,
    board_lane,
    card_title,
    subitems,
    current_state,
    recommended_next_action,
    info_tip
FROM (VALUES
    (10, N'Foundation', N'Core', N'Tenant | AppUser | Role | Permission | SchemaMigration', N'Implemented', N'Keep access review in SSMS audit scripts.', N'Foundation cards should stay locked in future visual planning.'),
    (20, N'Foundation', N'Reference', N'Language | PersonType | PhoneType | ProfessionalStatus | SocialType | Title', N'Implemented', N'Expand only through lookup seed migrations.', N'Reference data controls dropdown-like operator choices.'),
    (30, N'Customer', N'Person', N'Person | NaturalPerson | LegalPerson | Address | Phone | Email | BankAccount | Relations', N'Implemented', N'Add more create bridges where operators need speed.', N'Person is usually the first search step.'),
    (40, N'Customer', N'Institution', N'Institution | Role | Identifier | Address', N'Implemented', N'Add insurer/bank quality checks.', N'Institution feeds policy company/broker workflows.'),
    (50, N'Insurance Core', N'Risk/Object', N'InsurableObject | Vehicle | RealEstate | Loan | Person | Thing | Activity | 26 lookups', N'Implemented', N'Expose more subtype search templates.', N'This is the largest domain by table count.'),
    (60, N'Insurance Core', N'Policy', N'Contract | Version | Party | Object | Takeover | Status | Domain | Type', N'Implemented', N'Add renewal and endorsement templates.', N'Policy is the central operating record.'),
    (70, N'Insurance Core', N'Coverage', N'Coverage | Domain | Package | PackageItem', N'Implemented', N'Add package comparison report.', N'Coverage maps product logic to policies and claims.'),
    (80, N'Operations', N'Claim', N'Claim | Party | Object | Circumstance | Status | PaymentMethod', N'Implemented', N'Add claim reserve/payment expansion after finance model.', N'Claim has payment fields but no full ledger yet.'),
    (90, N'Operations', N'Document', N'Document | Link | Version | Type', N'Implemented', N'Add document upload bridge metadata template.', N'Keep binaries outside SQL Server.'),
    (100, N'Operations', N'Task', N'Task | Comment | Reminder | Priority | Status', N'Implemented', N'Add task assignment and SLA reports.', N'Task is the daily queue.'),
    (110, N'Control', N'Audit', N'AuditLog | EntityChangeSet', N'Implemented', N'Add audit drill-down shortcuts.', N'Use after guarded edits.'),
    (120, N'Backlog', N'Finance/Commission', N'Commission | Ledger | Payment | Reserve | Statement', N'Candidate 019+', N'Design with accounting owner before migration.', N'Do not invent financial ledger columns without approval.'),
    (130, N'Backlog', N'Entity Notes', N'Note | NoteLink | NoteType', N'Candidate 019+', N'Decide whether task comments already cover enough.', N'Notes should not duplicate audit or task comments.'),
    (140, N'Backlog', N'Import/Export Staging', N'ImportBatch | ImportRow | ExportJob | ValidationIssue', N'Candidate 019+', N'Design after operator import workflow is known.', N'Good fit for bulk customer/policy onboarding.'),
    (150, N'Backlog', N'Product Templates', N'ProductTemplate | RatingRule | ClauseTemplate', N'Candidate 019+', N'Design after coverage package behavior is tested.', N'Keep product rules separate from demo-only UI concepts.')
) AS b(card_order, board_lane, card_title, subitems, current_state, recommended_next_action, info_tip)
ORDER BY card_order;

PRINT '04 - Recommended SSMS entry points';
SELECT
    entry_order,
    operator_question,
    open_script,
    expected_result,
    info_tip
FROM (VALUES
    (10, N'Where do I start today?', N'05__operator_dashboard_home.sql', N'Shortcuts and health signals', N'Keep this tab open.'),
    (20, N'How does the database fit together?', N'11__schema_working_logic_map.sql', N'Domain map and board cards', N'Use before changing schema.'),
    (25, N'How do I see the visual board structure in SSMS?', N'13__visual_workflow_board.sql', N'Node, edge, subheading, and template-route grids', N'Use this as the SSMS-safe version of the visual/mind-map idea.'),
    (30, N'Which tables and relationships exist?', N'12__table_catalog_and_relationships.sql', N'Table catalog and FK map', N'Use before adding a migration.'),
    (40, N'How do I find IDs safely?', N'06__query_library_shortcuts.sql', N'Search grids', N'Copy IDs from Results Grid.'),
    (50, N'How do I create data?', N'07__data_entry_bridge_templates.sql', N'Preview-first create templates', N'Keep execute flag off until reviewed.'),
    (60, N'How do I edit data?', N'08__data_editing_guardrails.sql', N'Before/after grids and rollback default', N'Commit only after row count is right.'),
    (70, N'How do I report?', N'09__graph_report_pack.sql', N'Chart-ready result sets', N'Copy chart_axis/chart_value to Excel or BI.')
) AS e(entry_order, operator_question, open_script, expected_result, info_tip)
ORDER BY entry_order;
GO
