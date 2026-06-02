# Dashboard Workflow

## Purpose

The dashboard is the SSMS home screen. It returns shortcut grids, health
signals, and next actions without changing data.

## Main Script

Use:

```text
database/ssms/05__operator_dashboard_home.sql
```

## How To Read The Result Sets

- `Operator shortcuts`: script catalog with safety mode and purpose.
- `Current operating context`: server, database, tenant, and login.
- `Health signals`: quick operational status.
- `Recommended next actions`: suggested next SSMS tabs.

## Shortcut Safety Modes

- `READ_ONLY`: safe to run without changing data.
- `BACKUP_REQUIRED`: run only after backup path is configured.
- `DRY_RUN_FIRST`: run preview before insert/update.
- `REVIEW_BEFORE_COMMIT`: review preview grids before executing.
- `ROLLBACK_DEFAULT`: changes are rolled back unless commit is explicitly enabled.

## Info Tips

- Treat the dashboard as a control panel, not as a data entry form.
- Use the shortcut file names to open scripts in new SSMS tabs.
- Keep `TENANT_CODE` consistent across all open tabs.
