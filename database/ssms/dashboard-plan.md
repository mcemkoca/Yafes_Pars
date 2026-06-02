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
| Daily | `10__daily_operator_checklist.sql` | PASS/REVIEW/ACTION checklist. |
| Operations | `02__operations_dashboard.sql` | Customer, policy, claim, document, task, coverage overview. |
| Search | `06__query_library_shortcuts.sql` | Find records and copy IDs. |
| Entry | `07__data_entry_bridge_templates.sql` | Preview-first create actions. |
| Edit | `08__data_editing_guardrails.sql` | Rollback-by-default updates. |
| Reports | `09__graph_report_pack.sql` | Chart/export-ready result sets. |
| Audit | `04__admin_security_audit_queries.sql` | RBAC, audit, trigger, and integrity checks. |

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
2. Run daily checklist.
3. Search record and copy IDs.
4. Use bridge template for creates.
5. Use guardrail template for updates.
6. Run audit checks.
7. Export report pack grids when needed.

## Future Enhancements

- Add stored procedures for more guided create/edit actions.
- Add specialized report packs by department.
- Add SQL Agent job monitoring result sets.
- Add standard SSMS registered-server instructions.
- Add Power BI template consuming report pack exports.
- Extend the production readiness checklist with real restore drill evidence,
  monitoring owners, and SQL Agent maintenance jobs after DEV/TEST execution is
  validated.

## Corporate Readiness Links

- `../docs/ssms-deployment-runbook.md`
- `../docs/environment-matrix.md`
- `../docs/production-readiness-checklist.md`
- `../docs/migration-execution-log-template.md`
