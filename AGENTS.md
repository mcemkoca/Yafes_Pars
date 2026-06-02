# AGENTS.md

## Mission

Transform Yafes Pars into a production-grade SQL Server and SSMS-first
insurance core database platform.

The first priority is the database core. Do not start backend or frontend work
until the migration system, validation scripts, tenant model, audit model, seed
data, and database documentation are in place.

## Autonomous Workflow

- Work task by task without waiting for approval unless a production database or
  destructive external operation is involved.
- Keep changes scoped to the active task.
- Preserve legacy SQL for traceability.
- After each completed task:
  - Update files.
  - Check SQL Server syntax and naming consistency.
  - Add or update validation scripts.
  - Add or update documentation.
  - Commit with a clear message.
  - Push the completed commit when credentials are available.

## Safety Rules

- Never run destructive operations against a production database.
- Do not execute `DROP`, destructive migrations, or data deletion on a real
  external database unless explicitly instructed for a disposable environment.
- Generate and validate scripts in the repository.
- Do not store secrets, tokens, passwords, or credentials in files.

## SQL Server Rules

- Use Microsoft SQL Server T-SQL.
- Make scripts executable from SQL Server Management Studio.
- Use `SET NOCOUNT ON;`, `SET XACT_ABORT ON;`, and `GO` consistently.
- Use `TRY/CATCH` with transactions for migration bodies where appropriate.
- Use `THROW` or `RAISERROR` consistently for validation failures.
- Avoid PostgreSQL, MySQL, SQLite, or ORM-specific syntax.
- Prefer idempotent scripts where practical.

## Schema Standards

Use these domain schemas:

- `core`: tenant, user, role, permission, migration tracking
- `ref`: lookup and reference data
- `person`: people and customers
- `institution`: companies, banks, insurers, and partners
- `risk`: insurable objects
- `policy`: contracts, policies, versions, parties, and object links
- `coverage`: coverages and packages
- `claim`: claim files and claim-related data
- `document`: document metadata
- `tasking`: tasks and reminders
- `audit`: audit logs and change sets

## Naming Standards

- Schema names: lowercase domain names.
- Table names: PascalCase singular.
- Column names: snake_case.
- Primary keys: `PK_<Table>`.
- Foreign keys: `FK_<FromTable>_<ToTable>_<Purpose>`.
- Unique constraints: `UQ_<Table>_<ColumnOrBusinessKey>`.
- Check constraints: `CK_<Table>_<Rule>`.
- Indexes: `IX_<Table>_<ColumnList>`.
- Defaults: `DF_<Table>_<Column>`.
- Triggers: `TR_<Table>_<Action>`.
- Views: `VW_<Domain>_<Name>`.
- Stored procedures: `SP_<Domain>_<Action>`.

## Domain Rules

- Add `tenant_id` to business root tables.
- Add audit columns where appropriate:
  - `created_at_utc`
  - `updated_at_utc`
  - `created_by_user_id`
  - `updated_by_user_id`
  - `is_deleted`
- Keep contract versioning as a first-class concept.
- Do not use a table named `Object`; use `risk.InsurableObject`.
- Keep production lookup seed data separate from optional demo data.
- Store document metadata in SQL Server, not file binaries by default.

## Quality Checklist

- SQL Server syntax only.
- SSMS batch boundaries are valid.
- Schema, table, column, constraint, index, trigger, view, and stored procedure
  names follow the project standards.
- Foreign key columns have supporting indexes.
- Major migrations have validation scripts.
- Seed scripts are idempotent.
- Documentation reflects domain or migration changes.
- Legacy SQL remains preserved.
