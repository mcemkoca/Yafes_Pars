# Database tools

This folder contains guarded helpers for running the Yafes Pars SQL Server DEV database workflow.

## Static quality gate

Run the static quality gate before heavier SQL Server execution:

```powershell
.\database\tools\test-sql-quality-gate.ps1
```

In CI, use `-NoReportFile` to avoid writing local execution artifacts:

```powershell
.\database\tools\test-sql-quality-gate.ps1 -NoReportFile
```

Use `-StrictStyle` when you want style advisories such as `SET XACT_ABORT ON`
to become blocking failures.

The gate checks:

- protected migration order `000` through `018`
- protected validation order `001` through `017`
- unsupported non-SQL Server syntax
- destructive SQL patterns outside rollback scripts
- forbidden `Object` table naming
- SSMS operator conventions for info tips, SQLCMD guards, and tenant context
- required production readiness documentation

## Required variables

Set these environment variables before running the migration runner:

```powershell
$env:YAFES_SQL_SERVER="YOUR_DEV_SQL_SERVER"
$env:YAFES_SQL_DATABASE="YafesPars_Dev"
$env:YAFES_SQL_USER="YOUR_SQL_USER"
$env:YAFES_SQL_PASSWORD="YOUR_SQL_PASSWORD"

.\database\tools\run-dev-migrations.ps1
```

Optional:

- `YAFES_SQL_BACKUP_DIR`: SQL Server-visible backup directory. Defaults to the run log folder.
- `YAFES_SQL_SECRET_FILE`: path to a local, uncommitted `KEY=VALUE` file containing the required variables.

Never commit real secrets, passwords, tokens, or connection strings.

## Safety checks

`run-dev-migrations.ps1` stops before DB changes when:

- `YAFES_SQL_DATABASE` does not contain `DEV`.
- `YAFES_SQL_SERVER`, verified server name, or machine name suggests production.
- Any required connection variable is missing.
- Any migration or validation file in the expected sequence is missing.
- Unsafe migration operations are detected.
- The target database cannot be verified.
- The pre-migration backup cannot be created.
- Any migration or validation script fails.

The runner executes migrations `000` through `018` in strict numeric order, then validations `001` through `017`.

## Backup behavior

Before migrations run, the target DEV database must already exist so the runner can create a pre-migration backup.

Backup filename format:

```text
YafesPars_Dev_PreMigration_YYYYMMDD_HHMMSS.bak
```

If SQL Server cannot write the backup path or the SQL account lacks backup permission, the runner stops and does not execute migrations.

## Logs

Every run creates:

```text
database/execution-logs/YYYYMMDD_HHMMSS/
```

The folder contains prepared scripts, one log per migration, one log per validation, backup logs, and `final-report.md`.

The runner prepares temporary copies of the SQL files with the configured DEV database name. Original migration and validation files are not modified.

## CI validation

GitHub Actions uses `.github/workflows/sql-server-validation.yml` and
`run-ci-sql-validation.ps1` to start a SQL Server Developer container, create
`YafesPars_DEV`, run migrations `000` through `018`, run validations `001`
through `017`, and upload execution logs.

The workflow generates a masked, short-lived SQL Server container password for
each run. No static SQL Server password is stored in the repository.

`.github/workflows/database-quality-gate.yml` runs the static gate without a SQL
Server container so documentation, SSMS, template, and migration structure
problems are caught quickly.

## SSMS fallback

If `sqlcmd` is not installed, the runner creates:

```text
database/execution-logs/YYYYMMDD_HHMMSS/ssms-dev-migrations.sql
```

Open that file in SSMS, enable `Query > SQLCMD Mode`, set the SQLCMD variables at the top, and run it only against a verified DEV target.

You can generate only the manual SSMS script with:

```powershell
.\database\tools\run-dev-migrations.ps1 -GenerateSsmsScriptOnly
```

## Rollback notes

Rollback is not automatic. Use scripts under `database/rollback/` only after reviewing their guard variables and confirming the target is DEV.
