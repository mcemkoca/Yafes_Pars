# Database

This folder contains the SQL Server and SSMS-first database project for Yafes
Pars.

## Folders

- `legacy/`: original SQL files retained for comparison and traceability.
- `migrations/`: ordered forward migrations.
- `rollback/`: rollback scripts kept outside the forward path.
- `validation/`: SSMS scripts that verify expected database objects and rules.
- `md/database/`: human-readable database architecture and operating documentation.
- `templates/`: reusable T-SQL templates.

## Working Rule

Every major database change should include:

1. A migration script.
2. A validation script.
3. Documentation updates.
4. A focused commit.

Production lookup seed data and optional demo data must remain separate.

## Build Status

The database folder now contains ordered migrations from `000` through `018`,
validation scripts for each major phase, guarded rollback scripts, and reusable
SQL templates. Human-readable database documentation lives in `md/database/`.

## Evidence Documents

- `table-reconciliation-89-vs-108.md`: explains why the current model has 108
  tables while the old legacy reference had 89.
- `access-review-evidence-template.md`: records role, permission, user, and
  least-privilege review evidence.
- `restore-drill-evidence-template.md`: records backup restore proof, timing,
  and validation results.
