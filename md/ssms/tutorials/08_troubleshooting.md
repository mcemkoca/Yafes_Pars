# Troubleshooting

## SQLCMD Variables Not Working

Enable `Query > SQLCMD Mode` in SSMS. Scripts with `:setvar` or `:r` require it.

## Target Database Error

The workbench refuses database names that do not contain `DEV`. Confirm the
connection and `YAFES_SQL_DATABASE`.

## Tenant Not Found

Check `TENANT_CODE` at the top of the script. Run the operations dashboard to
list available tenants.

## Lookup Missing

Run `06__query_library_shortcuts.sql` and inspect the lookup helper result set.
Use only active lookup values.

## Edit Did Not Commit

Most edit templates roll back by default. Set `COMMIT_CHANGES = 1` only after
reviewing the preview.

## Migration Backup Error

The SQL Server service account must be able to write to the backup path.
Use a real timestamped `.bak` path and rerun.

## Info Tips

- Read the Messages panel as well as Results Grid.
- Copy IDs from grids instead of typing them.
- Keep one tab per task: dashboard, search, edit, audit.
