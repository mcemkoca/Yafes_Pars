/*
    Yafes Pars SSMS Workbench - Run DEV Migrations And Validations

    Enable SQLCMD Mode before running.

    This script launches the generated all-in-one SSMS script. The generated
    script performs DEV safety checks, requires a timestamped backup path, runs
    migrations 000-018, then validations 001-017.

    Before running:
    1. Open database/execution-logs/20260602_124216/ssms-dev-migrations.sql.
    2. Set YAFES_SQL_DATABASE to your DEV database name.
    3. Set YAFES_SQL_BACKUP_PATH to a real SQL Server writable .bak path.
    4. Confirm Query > SQLCMD Mode is enabled.
*/
:ON ERROR EXIT

:r ..\execution-logs\20260602_124216\ssms-dev-migrations.sql
