/*
    Yafes Pars SSMS Workbench - Table Catalog And Relationships

    INFO TIP:
    This read-only script lists the real table catalog, column profile, and
    foreign-key relationship map from SQL Server metadata. Use it as the SSMS
    replacement for a drag/drop planning board before creating migrations.

    Enable SQLCMD Mode before running.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE "DEV-BE-BROKER"

SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

IF DB_NAME() NOT LIKE N'%DEV%'
    THROW 52899, 'Current database name must contain DEV.', 1;

DECLARE @TenantCode NVARCHAR(80) = N'$(TENANT_CODE)';

PRINT 'INFO TIP: This script reads sys metadata only. It does not change data.';

PRINT '01 - Schema summary';
SELECT
    s.name AS schema_name,
    COUNT(DISTINCT t.object_id) AS table_count,
    COUNT(DISTINCT v.object_id) AS view_count,
    COUNT(DISTINCT p.object_id) AS procedure_count,
    CASE s.name
        WHEN N'core' THEN N'Tenant, users, RBAC, migration ledger'
        WHEN N'ref' THEN N'Shared reference data'
        WHEN N'person' THEN N'Customer identity and contact records'
        WHEN N'institution' THEN N'Insurers, banks, brokers, companies'
        WHEN N'risk' THEN N'Insurable objects and object subtypes'
        WHEN N'policy' THEN N'Contracts, versions, parties, objects'
        WHEN N'coverage' THEN N'Coverage catalog and packages'
        WHEN N'claim' THEN N'Claims and claim workflow'
        WHEN N'document' THEN N'Document metadata and links'
        WHEN N'tasking' THEN N'Operational task queue'
        WHEN N'audit' THEN N'Audit and change history'
        ELSE N'Other'
    END AS domain_summary,
    N'INFO TIP: Open Object Explorer by schema when table count is high.' AS info_tip
FROM sys.schemas s
LEFT JOIN sys.tables t
    ON t.schema_id = s.schema_id
LEFT JOIN sys.views v
    ON v.schema_id = s.schema_id
LEFT JOIN sys.procedures p
    ON p.schema_id = s.schema_id
WHERE s.name IN (N'core', N'ref', N'person', N'institution', N'risk', N'policy', N'coverage', N'claim', N'document', N'tasking', N'audit')
GROUP BY s.name
ORDER BY
    CASE s.name
        WHEN N'core' THEN 10
        WHEN N'ref' THEN 20
        WHEN N'person' THEN 30
        WHEN N'institution' THEN 40
        WHEN N'risk' THEN 50
        WHEN N'policy' THEN 60
        WHEN N'coverage' THEN 70
        WHEN N'claim' THEN 80
        WHEN N'document' THEN 90
        WHEN N'tasking' THEN 100
        WHEN N'audit' THEN 110
        ELSE 999
    END;

PRINT '02 - Full table catalog';
SELECT
    ROW_NUMBER() OVER (ORDER BY s.name, t.name) AS table_order,
    s.name AS schema_name,
    t.name AS table_name,
    CONCAT(s.name, N'.', t.name) AS full_table_name,
    SUM(CASE WHEN c.name = N'tenant_id' THEN 1 ELSE 0 END) AS has_tenant_id,
    SUM(CASE WHEN c.name = N'is_deleted' THEN 1 ELSE 0 END) AS has_soft_delete,
    COUNT(c.column_id) AS column_count,
    COALESCE(fk_in.inbound_fk_count, 0) AS referenced_by_count,
    COALESCE(fk_out.outbound_fk_count, 0) AS references_count,
    N'INFO TIP: Use this catalog before deciding whether a new table is really needed.' AS info_tip
FROM sys.tables t
INNER JOIN sys.schemas s
    ON s.schema_id = t.schema_id
INNER JOIN sys.columns c
    ON c.object_id = t.object_id
OUTER APPLY (
    SELECT COUNT_BIG(*) AS inbound_fk_count
    FROM sys.foreign_keys fk
    WHERE fk.referenced_object_id = t.object_id
) AS fk_in
OUTER APPLY (
    SELECT COUNT_BIG(*) AS outbound_fk_count
    FROM sys.foreign_keys fk
    WHERE fk.parent_object_id = t.object_id
) AS fk_out
WHERE s.name IN (N'core', N'ref', N'person', N'institution', N'risk', N'policy', N'coverage', N'claim', N'document', N'tasking', N'audit')
GROUP BY s.name, t.name, t.object_id, fk_in.inbound_fk_count, fk_out.outbound_fk_count
ORDER BY s.name, t.name;

PRINT '03 - Foreign key relationship map';
SELECT
    parent_schema.name AS from_schema,
    parent_table.name AS from_table,
    parent_column.name AS from_column,
    referenced_schema.name AS to_schema,
    referenced_table.name AS to_table,
    referenced_column.name AS to_column,
    fk.name AS fk_name,
    CASE
        WHEN parent_column.name = N'tenant_id' THEN N'Tenant isolation'
        WHEN parent_table.name LIKE N'%Link%' THEN N'Entity link'
        WHEN parent_table.name LIKE N'%Party%' THEN N'Party role link'
        WHEN parent_table.name LIKE N'%Object%' THEN N'Object relation'
        ELSE N'Domain relation'
    END AS relationship_type,
    N'INFO TIP: Use FK map before drag/drop diagram changes.' AS info_tip
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc
    ON fkc.constraint_object_id = fk.object_id
INNER JOIN sys.tables parent_table
    ON parent_table.object_id = fk.parent_object_id
INNER JOIN sys.schemas parent_schema
    ON parent_schema.schema_id = parent_table.schema_id
INNER JOIN sys.columns parent_column
    ON parent_column.object_id = parent_table.object_id
   AND parent_column.column_id = fkc.parent_column_id
INNER JOIN sys.tables referenced_table
    ON referenced_table.object_id = fk.referenced_object_id
INNER JOIN sys.schemas referenced_schema
    ON referenced_schema.schema_id = referenced_table.schema_id
INNER JOIN sys.columns referenced_column
    ON referenced_column.object_id = referenced_table.object_id
   AND referenced_column.column_id = fkc.referenced_column_id
WHERE parent_schema.name IN (N'core', N'ref', N'person', N'institution', N'risk', N'policy', N'coverage', N'claim', N'document', N'tasking', N'audit')
ORDER BY parent_schema.name, parent_table.name, fk.name, fkc.constraint_column_id;

PRINT '04 - Operator-safe root table list';
SELECT
    root_order,
    root_domain,
    full_table_name,
    operator_use,
    safe_entry_script,
    info_tip
FROM (VALUES
    (10, N'Core', N'core.Tenant', N'Tenant context and isolation boundary', N'05__operator_dashboard_home.sql', N'Never guess tenant_id; resolve by tenant_code.'),
    (20, N'Person', N'person.Person', N'Customer identity root', N'06__query_library_shortcuts.sql', N'Use search procedure before bridge templates.'),
    (30, N'Institution', N'institution.Institution', N'Insurer/bank/intermediary root', N'06__query_library_shortcuts.sql', N'Institution identifiers are key for policy quality.'),
    (40, N'Risk/Object', N'risk.InsurableObject', N'Insured object root', N'06__query_library_shortcuts.sql', N'Do not create a generic Object table.'),
    (50, N'Policy', N'policy.Contract', N'Policy/contract root', N'03__create_renewal_tasks.sql', N'Policy links person, institution, risk, coverage, and claims.'),
    (60, N'Claim', N'claim.Claim', N'Claim file root', N'06__query_library_shortcuts.sql', N'Claim creation must verify policy and coverage.'),
    (70, N'Document', N'document.Document', N'Document metadata root', N'08__data_editing_guardrails.sql', N'Use soft-delete guardrails for document changes.'),
    (80, N'Task', N'tasking.Task', N'Operator work queue root', N'10__daily_operator_checklist.sql', N'Tasks drive daily operations.'),
    (90, N'Audit', N'audit.AuditLog', N'Change history root', N'04__admin_security_audit_queries.sql', N'Read-only operational evidence.')
) AS roots(root_order, root_domain, full_table_name, operator_use, safe_entry_script, info_tip)
ORDER BY root_order;

PRINT '05 - Candidate table backlog for 019+ planning';
SELECT
    priority,
    candidate_domain,
    candidate_tables,
    decision_needed,
    migration_rule,
    info_tip
FROM (VALUES
    (N'P1', N'Finance/Commission', N'Commission, PaymentLedger, ClaimReserve, BrokerStatement', N'Confirm accounting model and reporting owner.', N'New forward migration 019+ only', N'Claim currently has paid/reserved fields, not a full ledger.'),
    (N'P1', N'Import/Export Staging', N'ImportBatch, ImportRow, ImportValidationIssue, ExportJob', N'Define CSV/Excel onboarding flow.', N'New forward migration 019+ only', N'Useful after table catalog and operator templates are stable.'),
    (N'P2', N'Entity Notes', N'Note, NoteLink, NoteType', N'Decide overlap with task comments and audit.', N'New forward migration 019+ only', N'Keep notes separate from compliance audit.'),
    (N'P2', N'Product Templates', N'ProductTemplate, RatingRule, ClauseTemplate', N'Define product owner workflow.', N'New forward migration 019+ only', N'Coverage packages already cover basic product grouping.'),
    (N'P3', N'Reinsurance', N'ReinsuranceContract, ReinsuranceShare', N'Defer until broker workflow requires it.', N'New forward migration 019+ only', N'Low priority unless business process needs it.')
) AS backlog(priority, candidate_domain, candidate_tables, decision_needed, migration_rule, info_tip)
ORDER BY priority, candidate_domain;
GO

