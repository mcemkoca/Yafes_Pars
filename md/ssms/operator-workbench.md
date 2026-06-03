# SSMS Operator Workbench

This folder is the SSMS-first operational interface for Yafes Pars. It is built
for users who work inside SQL Server Management Studio and need clear shortcuts,
safe data entry, guided updates, report grids, tutorials, and info tips.

Open these files in SQL Server Management Studio and enable `Query > SQLCMD Mode`
for scripts that contain `:setvar` or `:r`.

## Operator Start Here

1. `00__open_first_safety_check.sql`
2. `05__operator_dashboard_home.sql`
3. `11__schema_working_logic_map.sql`
4. `12__table_catalog_and_relationships.sql`
5. `10__daily_operator_checklist.sql`
6. `02__operations_dashboard.sql`

Keep `05__operator_dashboard_home.sql` open as the SSMS home tab. It returns
shortcut grids, health signals, and recommended next actions.

## Script Catalog

| File | Mode | Purpose |
| --- | --- | --- |
| `00__open_first_safety_check.sql` | Read-only | Confirms DEV database and non-production-like server names. |
| `01__run_all_dev_migrations_sqlcmd.sql` | Read-only handoff | Confirms DEV context and explains how to generate/open the real all-in-one SSMS migration script. |
| `02__operations_dashboard.sql` | Read-only | Tenant-aware customer, institution, risk, policy, claim, document, task, coverage, and lookup dashboard. |
| `03__create_renewal_tasks.sql` | Dry-run first | Runs `tasking.SP_CreateRenewalTasks`; default should remain dry-run until approved. |
| `04__admin_security_audit_queries.sql` | Read-only | RBAC, audit, trigger, and integrity checks. |
| `05__operator_dashboard_home.sql` | Read-only | SSMS home dashboard with shortcuts, health, context, and next actions. |
| `06__query_library_shortcuts.sql` | Read-only | Search and inspection library for operators. |
| `07__data_entry_bridge_templates.sql` | Preview first | Procedure-based create actions with preview and output IDs. |
| `08__data_editing_guardrails.sql` | Rollback default | Guided updates with before/after grids and explicit commit switch. |
| `09__graph_report_pack.sql` | Read-only | Chart-ready grids, text bars, and export catalog. |
| `10__daily_operator_checklist.sql` | Read-only | Morning/end-of-day checklist with PASS/REVIEW/ACTION signals. |
| `11__schema_working_logic_map.sql` | Read-only | Domain groups, subheadings, control points, and planning board cards. |
| `12__table_catalog_and_relationships.sql` | Read-only | Full SQL Server table catalog, column profile, root tables, and FK map. |

## Supporting Assets

| Path | Purpose |
| --- | --- |
| `md/ssms/tutorials/` | Step-by-step SSMS user guides for every main workflow. |
| `md/ssms/templates.md` | Copy-friendly query, search, update, and report patterns. |
| `database/ssms/demo/` | Local visual demo of the SSMS-style operator workbench. |
| `md/ssms/dashboard-plan.md` | Corporate dashboard architecture and future roadmap. |
| `database/ssms/11__schema_working_logic_map.sql` | SSMS result-set map for how the business domains work together. |
| `database/ssms/12__table_catalog_and_relationships.sql` | Metadata-driven table and relationship catalog for planning. |

## Production Runbooks

The SSMS workbench is supported by production planning documents under
`md/database/`:

- `ssms-deployment-runbook.md`
- `azure-windows-server-deployment.md`
- `sql-server-installation-checklist.md`
- `backup-restore-strategy.md`
- `security-hardening.md`
- `environment-matrix.md`
- `production-readiness-checklist.md`

## Safety Modes

- `READ_ONLY`: no data changes.
- `BACKUP_REQUIRED`: only after backup path is configured.
- `DRY_RUN_FIRST`: preview result first, then execute.
- `REVIEW_BEFORE_COMMIT`: review preview grids before action.
- `ROLLBACK_DEFAULT`: rolls back unless a commit variable is explicitly enabled.

## Required SSMS Behavior

1. Connect only to a DEV SQL Server instance.
2. Do not use production or live servers.
3. Set `YAFES_SQL_DATABASE` at the top of each script.
4. Ensure the database value contains `DEV`.
5. Enable `Query > SQLCMD Mode` before running any script with `:setvar` or `:r`.
6. Run the open-first safety check.
7. Use query library results to copy IDs into bridge templates.
8. Keep data editing scripts in rollback/default preview mode until reviewed.

## Demo Boundary

The local demo is visual only. Real work must be done in SSMS with SQLCMD Mode
enabled against a DEV database. Migration execution uses a generated
`database/execution-logs/<run-id>/ssms-dev-migrations.sql` file created by
`database/tools/run-dev-migrations.ps1 -GenerateSsmsScriptOnly`; generated
execution-log files are not committed.

## Info Tip Standard

Every operator script should include:

- an `INFO TIP` header
- SQLCMD variables at the top
- tenant context checks for tenant-scoped scripts
- clear result-set names
- `info_tip` columns where helpful
- rollback/dry-run defaults for any mutation

The working interface is SSMS Query Editor, Results Grid, and Messages, not a
web application.
