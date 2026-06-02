# SSMS Workbench

This folder is the SSMS-first operational interface for Yafes Pars.

Open these files in SQL Server Management Studio and enable `Query > SQLCMD Mode`
for scripts that contain `:setvar` or `:r`.

## Files

- `00__open_first_safety_check.sql`: verifies the connected server/database is
  DEV and shows engine context.
- `01__run_all_dev_migrations_sqlcmd.sql`: launches the generated all-in-one
  DEV migration and validation script from SSMS SQLCMD Mode.
- `02__operations_dashboard.sql`: SSMS result-grid dashboard for tenants,
  persons, institutions, risks, policies, claims, documents, tasks, coverage,
  validation readiness, and lookup health.
- `03__create_renewal_tasks.sql`: SSMS runner for
  `tasking.SP_CreateRenewalTasks`.
- `04__admin_security_audit_queries.sql`: RBAC, audit, trigger, and integrity
  review queries.

## Required SSMS behavior

1. Connect only to a DEV SQL Server instance.
2. Do not use production or live servers.
3. Set `YAFES_SQL_DATABASE` at the top of each script.
4. Ensure the value contains `DEV`.
5. Run `00__open_first_safety_check.sql`.
6. Run migrations/validation only after backup readiness is confirmed.

The working interface is SSMS Query Editor and Results Grid, not a web UI.
