# Yafes Pars

[![SQL Server validation](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/sql-server-validation.yml/badge.svg)](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/sql-server-validation.yml)
[![Backend build](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/backend-build.yml/badge.svg)](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/backend-build.yml)

Yafes Pars is an SSMS-first SQL Server insurance core platform for broker and
policy operations. The project focuses on a disciplined database foundation:
ordered migrations, validation scripts, tenant-aware data design, auditability,
lookup seed data, and operator-ready SSMS workbench scripts.

The current product surface is SQL Server Management Studio, not a web
application. Backend/API work exists as an integration foundation and should
remain secondary until the database core is validated against a DEV SQL Server
target.

## What Is Included

- SQL Server database core for customer, institution, risk, policy, coverage,
  claim, document, tasking, RBAC, tenant, and audit domains.
- Ordered migration set from `000` through `018`.
- Validation scripts for schema, constraints, indexes, triggers, stored
  procedures, seed data, demo data, and cross-domain integrity.
- SSMS operator workbench scripts for safety checks, migrations, operational
  dashboards, renewal task generation, and security/audit checks.
- Guarded PowerShell migration runner with DEV target checks, backup preflight,
  SQL Server syntax scans, execution logs, and SSMS fallback generation.
- Optional .NET 8 backend/API foundation for future integration work.
- GitHub Actions for SQL Server validation and backend build/test checks.

## Repository Map

| Path | Purpose |
| --- | --- |
| `database/migrations/` | Ordered forward-only SQL Server migrations. |
| `database/validation/` | Post-migration validation and integrity checks. |
| `database/ssms/` | SSMS-first operator scripts and visual demo. |
| `database/tools/` | Guarded local and CI migration runners. |
| `database/docs/` | Architecture, security, ERD, data dictionary, and standards. |
| `backend/` | Optional .NET 8 API foundation and tests. |
| `.github/workflows/` | CI workflows for SQL Server and backend checks. |
| `.github/` | Dependabot, CODEOWNERS, and pull request standards. |

## SSMS Operator Flow

Open the scripts in `database/ssms/` from SQL Server Management Studio.
For scripts that use `:setvar` or `:r`, enable `Query > SQLCMD Mode`.

1. Run `00__open_first_safety_check.sql` to confirm the target is a DEV
   database and the connected server does not look like production.
2. Run `01__run_all_dev_migrations_sqlcmd.sql` after setting the database and
   backup variables in the generated all-in-one SSMS script.
3. Use `02__operations_dashboard.sql` for tenant-aware Results Grid dashboards.
4. Use `03__create_renewal_tasks.sql` in `DRY_RUN = 1` mode before inserting
   renewal tasks.
5. Use `04__admin_security_audit_queries.sql` for RBAC, audit, and data quality
   checks.

A local visual mockup of the SSMS-oriented operator experience is available at:

```powershell
cd database/ssms/demo
python -m http.server 3000 --bind 127.0.0.1
```

Then open `http://127.0.0.1:3000/`.

## Migration Order

1. `000__create_database.sql`
2. `001__create_schemas.sql`
3. `002__create_core_infrastructure.sql`
4. `003__create_person_domain.sql`
5. `004__create_institution_domain.sql`
6. `005__create_object_domain.sql`
7. `006__create_contract_domain.sql`
8. `007__create_coverage_domain.sql`
9. `008__create_claim_domain.sql`
10. `009__create_document_domain.sql`
11. `010__create_task_domain.sql`
12. `011__create_audit_domain.sql`
13. `012__add_constraints.sql`
14. `013__add_indexes.sql`
15. `014__add_triggers.sql`
16. `015__add_views.sql`
17. `016__add_stored_procedures.sql`
18. `017__seed_lookup_data.sql`
19. `018__seed_demo_data.sql`

## Local Validation

Generate an SSMS fallback script without requiring `sqlcmd`:

```powershell
./database/tools/run-dev-migrations.ps1 -GenerateSsmsScriptOnly
```

Run the guarded DEV migration workflow with `sqlcmd`:

```powershell
$env:YAFES_SQL_SERVER = "localhost,1433"
$env:YAFES_SQL_DATABASE = "YafesPars_DEV"
$env:YAFES_SQL_USER = "sa"
$env:YAFES_SQL_PASSWORD = "<dev-password>"
$env:YAFES_SQL_BACKUP_DIR = "C:\SqlBackups"

./database/tools/run-dev-migrations.ps1
```

The runner refuses non-DEV database names, production-like server names, unsafe
SQL patterns, and missing pre-migration backup configuration.

## Backend Foundation

The backend is an optional .NET 8 integration layer.

```powershell
dotnet restore backend/src/YafesPars.Api/YafesPars.Api.csproj
dotnet build backend/src/YafesPars.Api/YafesPars.Api.csproj --configuration Release
dotnet test backend/tests/YafesPars.Tests/YafesPars.Tests.csproj --configuration Release
```

Configure database access with either:

- `ConnectionStrings__YafesPars`
- `YAFES_SQL_CONNECTION_STRING`

## Security

Security policy, supported scope, and vulnerability reporting rules are defined
in [`SECURITY.md`](SECURITY.md). Do not commit credentials, database backups,
connection strings, or production data.

Dependency updates are managed through Dependabot for GitHub Actions and NuGet.

## Current Status

- Database core: complete through migration `018`.
- Validation coverage: complete for the current database scope.
- SSMS workbench: available under `database/ssms/`.
- Backend/API foundation: available, not the primary operator surface.
- Real DEV SQL Server execution: must be confirmed in an environment with
  `sqlcmd` or SSMS access to the target SQL Server instance.
