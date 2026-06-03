# SSMS Corporate Dashboard Plan

## Objective

Create a full corporate operator experience inside SQL Server Management Studio
without turning the product into a web application. The dashboard must preserve
SSMS Query Editor, Results Grid, Messages, SQLCMD Mode, and script-based
operations.

## Dashboard Principles

- SSMS remains the primary interface.
- Every workflow starts with DEV context verification.
- Read-only dashboards are separate from mutation scripts.
- Data entry goes through stored procedure bridges.
- Data editing uses rollback-by-default guardrails.
- Every result set includes clear labels and `info_tip` guidance where useful.
- Operators copy IDs from Results Grid instead of typing GUIDs.
- Reports return chart-ready grids for Excel/Power BI export.

## Dashboard Areas

| Area | Script | Purpose |
| --- | --- | --- |
| Home | `05__operator_dashboard_home.sql` | Shortcuts, context, health, next actions. |
| Architecture | `11__schema_working_logic_map.sql` | Domain groups, subheadings, control flow, and board cards. |
| Catalog | `12__table_catalog_and_relationships.sql` | Full table catalog, root tables, and foreign-key relationship map. |
| Visual Board | `13__visual_workflow_board.sql` | SSMS-safe node, edge, subheading, and template-route grids. |
| Daily | `10__daily_operator_checklist.sql` | PASS/REVIEW/ACTION checklist. |
| Operations | `02__operations_dashboard.sql` | Customer, policy, claim, document, task, coverage overview. |
| Search | `06__query_library_shortcuts.sql` | Find records and copy IDs. |
| Entry | `07__data_entry_bridge_templates.sql` | Preview-first create actions. |
| Edit | `08__data_editing_guardrails.sql` | Rollback-by-default updates. |
| Reports | `09__graph_report_pack.sql` | Chart/export-ready result sets. |
| Audit | `04__admin_security_audit_queries.sql` | RBAC, audit, trigger, and integrity checks. |
| Admin | `14__admin_role_permission_matrix.sql` | Role coverage, permission matrix, user assignments, least-privilege checks, and handoff rows. |

## Shortcut Model

SSMS cannot provide native clickable app-style buttons inside Results Grid.
The dashboard therefore returns a shortcut catalog with:

- shortcut order
- group
- action name
- script path
- safety mode
- info tip

Operators open the listed script in a new SSMS tab.

## User-Friendly Flow

1. Open dashboard home.
2. Review the working logic map when learning or planning changes.
3. Open the visual workflow board to review node/edge and template-route grids.
4. Open the table catalog before creating new tables or bridge flows.
5. Run daily checklist.
6. Search record and copy IDs.
7. Use bridge template for creates.
8. Use guardrail template for updates.
9. Review role/permission matrix before access changes.
10. Run audit checks.
11. Export report pack grids when needed.

## Future Enhancements

- Add stored procedures for more guided create/edit actions.
- Extend `13__visual_workflow_board.sql` with owner-approved department routes
  after real operator usage is observed.
- Add specialized report packs by department.
- Add TEST/PROD access-review evidence from `14__admin_role_permission_matrix.sql`.
- Add SQL Agent job monitoring result sets.
- Add standard SSMS registered-server instructions.
- Add Power BI template consuming report pack exports.
- Extend the production readiness checklist with real restore drill evidence,
  monitoring owners, and SQL Agent maintenance jobs after DEV/TEST execution is
  validated.

## Corporate Readiness Links

- `../database/ssms-deployment-runbook.md`
- `../database/environment-matrix.md`
- `../database/production-readiness-checklist.md`
- `../database/migration-execution-log-template.md`
