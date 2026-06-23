# Restore Drill Evidence Template

Use this template before production launch and after major release changes.
The goal is to prove that a backup can be restored, validated, and opened by
the SSMS operator workflow.

## Summary

| Field | Value |
| --- | --- |
| Environment restored from |  |
| Restore target environment |  |
| Backup file(s) |  |
| Restore operator |  |
| Start time UTC |  |
| Finish time UTC |  |
| Measured RTO |  |
| Data loss window / RPO evidence |  |

## Restore Steps

| Step | Result | Notes |
| --- | --- | --- |
| Full backup restored |  |  |
| Differential backup restored, if used |  |  |
| Log backups restored, if used |  |  |
| Database consistency check completed |  |  |
| Migration/validation scripts completed |  |  |
| SSMS dashboard opened |  |  |
| Daily checklist reviewed |  |  |
| Role/permission matrix reviewed |  |  |

## Validation

| Check | Source | Result | Notes |
| --- | --- | --- | --- |
| Static quality gate | `test-sql-quality-gate.ps1 -NoReportFile` |  |  |
| SQL validations | `database/validation/001..017` |  |  |
| Operator dashboard | `05__operator_dashboard_home.sql` |  |  |
| Table catalog | `12__table_catalog_and_relationships.sql` |  |  |
| Admin role matrix | `14__admin_role_permission_matrix.sql` |  |  |

## Decision

| Field | Value |
| --- | --- |
| Restore drill accepted |  |
| Blocking issues |  |
| Follow-up owner |  |
| Next drill date |  |
