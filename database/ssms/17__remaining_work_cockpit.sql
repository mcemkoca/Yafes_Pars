/*
    Yafes Pars SSMS Workbench - Remaining Work Cockpit

    INFO TIP:
    This read-only cockpit turns unfinished delivery items into SSMS result
    grids that an operator, DBA, or business owner can close with evidence.
    It does not create tables, jobs, users, tokens, or production data.

    Enable SQLCMD Mode before running.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_DEV"
:setvar TENANT_CODE "DEV-BE-BROKER"
:setvar REVIEW_OWNER "Mustafa"

SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

IF DB_NAME() NOT LIKE N'%DEV%'
    THROW 52499, 'Current database name must contain DEV.', 1;

DECLARE @TenantCode NVARCHAR(80) = N'$(TENANT_CODE)';
DECLARE @ReviewOwner NVARCHAR(120) = N'$(REVIEW_OWNER)';
DECLARE @TenantId UNIQUEIDENTIFIER;

SELECT @TenantId = tenant_id
FROM core.Tenant
WHERE tenant_code = @TenantCode;

IF @TenantId IS NULL
    THROW 52400, 'TENANT_CODE was not found. Check SQLCMD variables before continuing.', 1;

PRINT '01 - Remaining work cockpit context';
SELECT
    DB_NAME() AS database_name,
    @@SERVERNAME AS server_name,
    SERVERPROPERTY('MachineName') AS machine_name,
    @TenantCode AS tenant_code,
    @TenantId AS tenant_id,
    @ReviewOwner AS review_owner,
    SYSUTCDATETIME() AS checked_at_utc,
    N'INFO TIP: This screen coordinates closure work; it is not a migration or job creation script.' AS info_tip;

PRINT '02 - Workstream closure board';
SELECT
    priority,
    workstream,
    current_state,
    closure_owner,
    next_ssms_or_owner_action,
    evidence_or_decision_needed,
    stop_condition,
    info_tip
FROM (VALUES
    (N'P0', N'Token hygiene', N'OWNER_ACTION_REQUIRED', N'GitHub/account owner', N'Rotate or revoke shared token outside the repository.', N'Owner confirms rotation date and scope.', N'Token remains active or copied into any project file.', N'INFO TIP: Never paste tokens into SQL, markdown, commits, issue comments, or SSMS result exports.'),
    (N'P1', N'TEST/PROD migration evidence', N'READY_FOR_ENV_OWNER', N'DBA/deployer', N'Run approved migration and validation process in target environment.', N'Signed migration execution log plus validation output.', N'Target environment is not refreshed or owner has not approved execution window.', N'INFO TIP: DEV success is proven; TEST/PROD evidence must be produced on the real target.'),
    (N'P1', N'TEST/PROD access review', N'READY_FOR_ACCESS_OWNER', N'Security/access owner', N'Run role matrix review and attach sign-off.', N'Operator/admin/auditor/deployer role evidence.', N'Logins or role mapping are not approved by environment owner.', N'INFO TIP: Use 14__admin_role_permission_matrix.sql as the SSMS evidence source.'),
    (N'P1', N'TEST/PROD restore drill', N'READY_FOR_DBA', N'DBA', N'Run backup verification and restore drill on approved infrastructure.', N'VERIFYONLY, restored DB validation, and sign-off.', N'No approved restore target or backup path exists.', N'INFO TIP: DEV restore evidence helps process design, but it does not replace target evidence.'),
    (N'P2', N'Finance ledger and commission', N'OWNER_DECISION_REQUIRED', N'Business/accounting owner', N'Answer the 019+ decision intake before schema design.', N'Approved accounting flow and ledger ownership.', N'Commission/payment ownership is unclear.', N'INFO TIP: Claim paid/reserved fields exist; full ledger tables remain intentionally uncreated.'),
    (N'P2', N'Import/export staging', N'OWNER_DECISION_REQUIRED', N'Operations/product owner', N'Approve file formats, validation ownership, and export consumers.', N'Import contract and error handling decision.', N'Source files or ownership are unknown.', N'INFO TIP: Add staging tables only after the import contract is real.'),
    (N'P2', N'Department bridge edge workflows', N'RANKING_REQUIRED', N'Department owner', N'Rank next non-task workflow by real frequency and risk.', N'Top workflow plus expected stored procedure contract.', N'Workflow is rare, cosmetic, or not procedure-safe.', N'INFO TIP: Core create/link/close/task workflows are already procedure-backed.'),
    (N'P3', N'SQL Agent jobs', N'DBA_HANDOFF_READY', N'DBA/infrastructure owner', N'Approve job owners, schedules, alert targets, and output paths.', N'Signed SQL Agent promotion plan.', N'SQL Agent is disabled or job owner is not approved.', N'INFO TIP: Current scripts observe readiness; they do not create jobs.')
) AS w(priority, workstream, current_state, closure_owner, next_ssms_or_owner_action, evidence_or_decision_needed, stop_condition, info_tip)
ORDER BY
    CASE priority WHEN N'P0' THEN 0 WHEN N'P1' THEN 1 WHEN N'P2' THEN 2 ELSE 3 END,
    workstream;

PRINT '03 - Environment evidence handoff';
SELECT
    evidence_order,
    target_environment,
    evidence_area,
    open_script_or_template,
    required_artifact,
    done_condition,
    info_tip
FROM (VALUES
    (10, N'TEST', N'Migration execution', N'md/database/migration-execution-log-template.md', N'Start/end time, executor, backup path, migration/validation status.', N'TEST owner signs successful execution.', N'INFO TIP: Attach the generated SQL output, not a screenshot-only summary.'),
    (20, N'TEST', N'Access review', N'database/ssms/14__admin_role_permission_matrix.sql', N'Role grid export plus exception notes.', N'Access owner signs role mapping.', N'INFO TIP: Any excessive permission should become a tracked exception.'),
    (30, N'TEST', N'Restore drill', N'md/database/restore-drill-evidence-template.md', N'Backup verify, restore target, validation output.', N'DBA signs restore evidence.', N'INFO TIP: Restore evidence must include where the restored DB lived.'),
    (40, N'PROD', N'Migration execution', N'md/database/migration-execution-log-template.md', N'Approved release window and execution log.', N'Production owner signs release evidence.', N'INFO TIP: Do not run DEV helper scripts directly against production.'),
    (50, N'PROD', N'Access review', N'database/ssms/14__admin_role_permission_matrix.sql', N'Production login and role evidence.', N'Production access owner signs review.', N'INFO TIP: Auditor/deployer separation must be explicit.'),
    (60, N'PROD', N'Restore drill', N'md/database/restore-drill-evidence-template.md', N'Production backup verification and restore test record.', N'DBA signs recoverability evidence.', N'INFO TIP: The restore target can be isolated, but evidence must reference the production backup chain.')
) AS e(evidence_order, target_environment, evidence_area, open_script_or_template, required_artifact, done_condition, info_tip)
ORDER BY evidence_order;

PRINT '04 - Owner decision intake for 019+ candidates';
SELECT
    candidate_order,
    candidate_area,
    business_question,
    minimum_decisions_before_design,
    candidate_tables,
    recommended_output,
    stop_condition,
    info_tip
FROM (VALUES
    (10, N'Finance/Commission', N'Which events create payable commission, ledger movement, reserve change, or broker statement lines?', N'Accounting owner, posting lifecycle, reversal rules, currency/VAT rules, reporting owner.', N'finance.Commission | finance.PaymentLedger | claim.ClaimReserve | finance.BrokerStatement', N'Owner-approved 019+ entity contract and stored procedure list.', N'Payment/commission ownership is still informal.', N'INFO TIP: Start from claim paid/reserved data, but do not overload claim.Claim as a ledger.'),
    (20, N'Import/Export Staging', N'Which CSV/Excel/API files enter the system, who fixes invalid rows, and who consumes exports?', N'File formats, validation severity, retry process, export destination, retention rules.', N'staging.ImportBatch | staging.ImportRow | staging.ImportValidationIssue | staging.ExportJob', N'Import contract plus validation grid design.', N'Source file examples are not approved.', N'INFO TIP: Staging should protect core tables from dirty onboarding data.'),
    (30, N'Product Templates', N'Who owns product/rating templates and how do they relate to coverage packages?', N'Product owner, rating rule lifecycle, clause versioning, rollout approval.', N'product.ProductTemplate | product.RatingRule | product.ClauseTemplate', N'Product owner workflow and read-only reporting first.', N'Coverage package behavior has not been validated by users.', N'INFO TIP: Keep product rules separate from demo visual concepts.'),
    (40, N'Entity Notes', N'Do task comments and audit already cover operational notes, or is a cross-entity note model required?', N'Note owner, note visibility, retention, relation to audit, relation to task comments.', N'note.Note | note.NoteLink | note.NoteType', N'Decision to implement, defer, or reject notes.', N'Notes would duplicate task comments or audit log.', N'INFO TIP: Notes are useful only if they solve a real cross-entity workflow.')
) AS d(candidate_order, candidate_area, business_question, minimum_decisions_before_design, candidate_tables, recommended_output, stop_condition, info_tip)
ORDER BY candidate_order;

PRINT '05 - Next bridge workflow ranking queue';
SELECT
    rank_slot,
    candidate_action,
    current_supported_alternative,
    procedure_contract_needed,
    risk_if_done_directly,
    owner_ranking_question,
    info_tip
FROM (VALUES
    (10, N'ASSIGN_CLAIM_HANDLER', N'Use editing guardrails after claim lookup.', N'claim.SP_AssignClaimHandler with tenant and user/person validation.', N'Wrong handler, cross-tenant assignment, weak audit context.', N'How often does claim reassignment happen per week?', N'INFO TIP: Build only if reassignment is frequent enough to deserve a guided action.'),
    (20, N'ADD_DOCUMENT_VERSION_METADATA', N'Use document tables through approved import/storage process.', N'document.SP_AddDocumentVersionMetadata with storage key validation.', N'Broken document version chain or orphaned storage pointer.', N'Are operators adding versions manually or only through integration?', N'INFO TIP: Do not pretend the database stores binary files if storage is external.'),
    (30, N'LINK_DOCUMENT_TO_ENTITY', N'Use document relationship inspection before any link work.', N'document.SP_LinkDocumentToEntity with supported entity type validation.', N'Document linked to wrong customer, policy, claim, or task.', N'Which entity links are most common and user-visible?', N'INFO TIP: This is a good candidate after document ownership is confirmed.'),
    (40, N'UPDATE_POLICY_VERSION_STATUS', N'Use policy version grids and editing guardrails.', N'policy.SP_UpdateContractVersionStatus with allowed transition rules.', N'Invalid policy lifecycle state or renewal confusion.', N'Who owns version status changes and approvals?', N'INFO TIP: Add only after lifecycle statuses are accepted by business users.'),
    (50, N'CREATE_IMPORT_BATCH', N'No staging tables yet; owner approval required.', N'staging.SP_CreateImportBatch after 019+ tables exist.', N'Dirty import data contaminates core domain tables.', N'Which import source must be supported first?', N'INFO TIP: This waits for the import/export 019+ decision.')
) AS b(rank_slot, candidate_action, current_supported_alternative, procedure_contract_needed, risk_if_done_directly, owner_ranking_question, info_tip)
ORDER BY rank_slot;

PRINT '06 - SQL Agent promotion board';
SELECT
    job_order,
    job_blueprint,
    current_source,
    proposed_schedule,
    required_owner_decision,
    promotion_blocker,
    info_tip
FROM (VALUES
    (10, N'YafesPars_DEV_DailyValidation', N'database/tools/run-ci-sql-validation.ps1 and validation scripts', N'Daily after backup window in TEST; release window in PROD.', N'DBA approves job owner, database target, output path, and alert recipient.', N'SQL Agent unavailable or output path not approved.', N'INFO TIP: Keep job creation outside this script until infrastructure owner signs off.'),
    (20, N'YafesPars_BackupVerify', N'md/database/backup-restore-strategy.md', N'After each scheduled full backup.', N'DBA approves VERIFYONLY command, retention, and failure alert.', N'Backup path or retention policy missing.', N'INFO TIP: Backup success without verification is not enough evidence.'),
    (30, N'YafesPars_RestoreDrill_Reminder', N'md/database/restore-drill-evidence-template.md', N'Monthly or before major release.', N'DBA approves isolated restore target and validation owner.', N'No restore target is available.', N'INFO TIP: This can be a reminder job or external ticket automation.'),
    (40, N'YafesPars_DeliveryGapDigest', N'database/ssms/16__delivery_gap_register.sql and this cockpit', N'Weekly during implementation phase.', N'Owner approves recipient list and digest format.', N'No owner for unresolved gaps.', N'INFO TIP: A digest should point to SSMS evidence, not replace it.')
) AS j(job_order, job_blueprint, current_source, proposed_schedule, required_owner_decision, promotion_blocker, info_tip)
ORDER BY job_order;

PRINT '07 - Closure gates before release';
SELECT
    gate_order,
    release_gate,
    current_control,
    pass_condition,
    fail_condition,
    info_tip
FROM (VALUES
    (10, N'Local quality gate', N'database/tools/test-sql-quality-gate.ps1 -NoReportFile', N'0 failures and 0 warnings.', N'Any missing SSMS script, manifest drift, or protected artifact.', N'INFO TIP: Run before every push.'),
    (20, N'Clean SQL Server validation', N'GitHub SQL Server validation plus local DEV container when needed.', N'All migrations, validations, and seed checks pass.', N'Any migration/validation failure or unsafe DEV guard issue.', N'INFO TIP: Container success proves syntax against SQL Server, not TEST/PROD approval.'),
    (30, N'SSMS demo synchronization', N'database/ssms/demo/index.html and workbench-manifest.json', N'Demo shows the same script list, shortcut count, and bridge actions.', N'Manifest count mismatch or stale scenario text.', N'INFO TIP: Demo remains visual; real execution is SSMS SQLCMD Mode.'),
    (40, N'Owner decision closure', N'This cockpit and 16__delivery_gap_register.sql', N'Each owner-required row has signed evidence or approved deferral.', N'P0/P1 owner rows remain unsigned.', N'INFO TIP: External blockers should be explicit, not hidden in generic TODOs.'),
    (50, N'019+ design readiness', N'12__table_catalog_and_relationships.sql plus section 04 here', N'Owner-approved entity contract exists.', N'Tables are designed without a business owner.', N'INFO TIP: Forward migrations are easy to add after decisions are real.')
) AS g(gate_order, release_gate, current_control, pass_condition, fail_condition, info_tip)
ORDER BY gate_order;
GO
