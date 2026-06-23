# SSMS Deployment Runbook

This runbook describes a controlled SSMS-first deployment for Yafes Pars.

## Required Access

- Approved Windows login or SQL login for the target environment.
- Permission to create or alter database objects for deployment.
- Permission to create backups before changes.
- Access to the release branch or approved release artifact.
- Access to the execution log template.

Do not paste passwords, tokens, or connection strings into repository files or
shared tickets.

## Pre-Deployment Checks

1. Confirm the environment name and database name.
2. Confirm the latest approved commit or release tag.
3. Confirm the backup destination is writable by SQL Server.
4. Run the static quality gate:

```powershell
.\database\tools\test-sql-quality-gate.ps1
```

5. In SSMS, connect to the target SQL Server instance.
6. Open `database/ssms/00__open_first_safety_check.sql`.
7. Enable `Query > SQLCMD Mode` when the script requires SQLCMD variables.
8. Run the safety check and save the Results Grid/Messages output.

## DEV Deployment

DEV can use the guarded runner when `sqlcmd` is installed:

```powershell
$env:YAFES_SQL_SERVER = "localhost,1433"
$env:YAFES_SQL_DATABASE = "YafesPars_DEV"
$env:YAFES_SQL_USER = "sa"
$env:YAFES_SQL_PASSWORD = "<dev-password>"
$env:YAFES_SQL_BACKUP_DIR = "C:\SqlBackups"

.\database\tools\run-dev-migrations.ps1
```

If `sqlcmd` is not available, generate the SSMS script:

```powershell
.\database\tools\run-dev-migrations.ps1 -GenerateSsmsScriptOnly
```

Open the generated script in SSMS, enable SQLCMD Mode, verify variables, and
run only against a DEV database.

## TEST Deployment

1. Restore or create the TEST database.
2. Take a pre-deployment backup.
3. Execute migrations in strict order.
4. Execute validations in strict order.
5. Run the SSMS dashboard and daily checklist.
6. Capture test sign-off in the execution log.

TEST should rehearse the exact PROD procedure without using production data
unless the data is sanitized and approved.

## PROD Deployment

1. Confirm change approval and maintenance window.
2. Confirm rollback decision path and restore owner.
3. Take a full pre-deployment backup.
4. Verify the backup can be listed and copied off the VM.
5. Execute only approved migration scripts.
6. Do not execute demo data scripts.
7. Execute validation scripts.
8. Run production health checks from the SSMS workbench.
9. Record finish time, validation status, and next monitoring window.

## Post-Deployment Checks

- `core.SchemaMigration` contains the expected applied scripts.
- Required schemas exist.
- Validation scripts pass.
- Operator dashboard opens with no blocking errors.
- RBAC and audit checks return expected records.
- Backup job status is healthy.
- SQL Server Error Log has no deployment-related critical errors.

## Stop Conditions

Stop the deployment and escalate when:

- The target database or server name is not the approved environment.
- The pre-deployment backup fails.
- A migration fails.
- A validation script fails.
- Unexpected destructive SQL is found.
- Production data would be exposed to DEV or TEST.
