# Migration Strategy

Migrations are ordered T-SQL files designed to run from SQL Server Management
Studio.

## Rules

- Use Microsoft SQL Server syntax only.
- Use `GO` batch separators where required.
- Use `SET NOCOUNT ON;` and `SET XACT_ABORT ON;`.
- Use transaction blocks around ordinary DDL where practical.
- Separate `CREATE OR ALTER VIEW`, `CREATE OR ALTER PROCEDURE`, and
  `CREATE OR ALTER TRIGGER` batches when SQL Server requires it.
- Add validation scripts for major migrations.
- Preserve legacy SQL in `database/legacy/`.

## Tracking

The migration base will include `core.SchemaMigration` so applied scripts can be
tracked with name, checksum, execution time, user, status, and error message.
