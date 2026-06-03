# Backup And Restore Strategy

Yafes Pars relies on SQL Server native backup and restore practices. Backups
must be planned before any production deployment.

## Objectives

| Environment | RPO target | RTO target | Notes |
| --- | --- | --- | --- |
| DEV | Best effort | Same day | Rebuild from migrations is acceptable. |
| TEST | 24 hours | Same day | Restore drills should mirror PROD. |
| PROD | Business-defined | Business-defined | Confirm with stakeholders before launch. |

RPO and RTO values above are placeholders until the business owner approves
production targets.

## Backup Types

- Full backup: baseline recovery point.
- Differential backup: optional mid-cycle recovery point.
- Transaction log backup: required when PROD uses full recovery model.
- Pre-deployment backup: mandatory before production schema changes.

## Recommended PROD Schedule

| Backup | Frequency | Retention |
| --- | --- | --- |
| Full | Daily | 14 to 35 days |
| Differential | Every 4 to 6 hours | 7 to 14 days |
| Transaction log | Every 15 to 30 minutes | 7 to 14 days |
| Pre-deployment | Before each release | Keep through warranty period |

Adjust frequency for approved RPO/RTO and database size.

## Backup Storage

- Keep backup files outside repository folders.
- Copy backup files off the SQL Server VM.
- Protect storage with private access and role-based permissions.
- Encrypt backups when the edition and policy support it.
- Monitor backup job failure and backup age.

## Restore Drill

Run a restore drill before production launch and after major release changes:

1. Restore the latest full backup to TEST or an isolated restore environment.
2. Apply differential and log backups if used.
3. Run validation scripts.
4. Open the SSMS operator dashboard.
5. Record restore start time, finish time, and validation status.

## Pre-Deployment Backup

Before a production migration:

1. Confirm no long-running critical business process is active.
2. Create a full backup.
3. Verify the backup file exists and has a recent timestamp.
4. Confirm it can be copied off the VM.
5. Record the backup name in the execution log.

## Restore Decision Path

Rollback by restore is an operational decision, not an automatic script action.
The release owner, database owner, and business owner must agree before
restoring PROD.
