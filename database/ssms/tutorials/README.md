# Yafes Pars SSMS Tutorials

This folder is the operator manual for working safely inside SQL Server
Management Studio.

## Tutorial Map

1. `01_quick_start.md` - first-run setup and daily startup.
2. `02_dashboard_workflow.md` - how to use the SSMS dashboard and shortcuts.
3. `03_query_and_search.md` - searching customers, policies, claims, tasks, and lookups.
4. `04_data_entry_bridge.md` - guided create actions through stored procedures.
5. `05_data_editing_guardrails.md` - safe update patterns with rollback by default.
6. `06_reports_and_graphs.md` - report grids, text bars, and export guidance.
7. `07_security_audit.md` - RBAC, audit, and data quality checks.
8. `08_troubleshooting.md` - common SSMS errors and fixes.

## Operator Rule

When in doubt, run the read-only scripts first:

1. `00__open_first_safety_check.sql`
2. `05__operator_dashboard_home.sql`
3. `10__daily_operator_checklist.sql`

Only then use data entry or editing scripts.
