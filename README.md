# Yafes Pars

[![SQL Server validation](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/sql-server-validation.yml/badge.svg)](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/sql-server-validation.yml)
[![Database quality gate](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/database-quality-gate.yml/badge.svg)](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/database-quality-gate.yml)
[![SSMS workbench validation](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/ssms-workbench-validation.yml/badge.svg)](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/ssms-workbench-validation.yml)
[![Backend build](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/backend-build.yml/badge.svg)](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/backend-build.yml)

Yafes Pars is an SSMS-first SQL Server insurance operations platform for broker,
policy, claim, risk, customer, document, task, security, and audit workflows.
The product is designed around a disciplined database core and a practical
operator workbench inside SQL Server Management Studio.

This is not a web-first application. The primary user experience is SSMS Query
Editor, Results Grid, Messages, SQLCMD Mode, guided scripts, safe bridge
templates, and production-ready database governance.

## Executive Overview

Yafes Pars provides a controlled corporate foundation for insurance operations:
tenant-aware data design, ordered SQL Server migrations, role-based access
control, audit trails, validation packs, operator dashboards, guided data entry,
guarded editing, report grids, and deployment runbooks.

The current database scope contains 108 SQL Server tables across 11 domain
schemas. The active migration line is protected from `000` through `018`; future
schema work must continue as forward-only migrations from `019+`.

## Client Value

| Value | What It Means |
| --- | --- |
| SSMS-native operations | Business users and technical operators can work in the familiar SQL Server Management Studio environment. |
| Lower operational risk | DEV checks, SQLCMD variables, rollback defaults, dry-run modes, and info tips reduce accidental changes. |
| Clear domain model | Customers, institutions, risks, policies, coverage, claims, documents, tasks, RBAC, and audit are separated by schema. |
| Better onboarding | Tutorials, query shortcuts, bridge templates, and working-logic maps guide users step by step. |
| Enterprise readiness | CI validation, security policy, production runbooks, backup guidance, and release checklists are included. |

## Platform Highlights

| Capability | Status | Client Benefit |
| --- | --- | --- |
| SQL Server database core | Complete through migration `018` | Stable foundation for DEV validation and controlled rollout. |
| SSMS operator workbench | Available | Users can start from one dashboard and move through safe workflows. |
| Working logic map | Available | Domain groups, subheadings, control points, and planning cards are visible from SSMS. |
| Table catalog and FK map | Available | Real SQL Server metadata supports planning before new tables are added. |
| Validation and quality gate | Available | CI checks protect syntax, order, safety, documentation, and SSMS conventions. |
| Production readiness pack | Available | Azure Windows Server, SQL Server, SSMS deployment, backup, and security guidance are documented. |
| .NET backend foundation | Available | Integration layer exists, but it remains secondary to the database-first product surface. |

## Architecture Snapshot

| Layer | Scope |
| --- | --- |
| Core | Tenant isolation, users, roles, permissions, and migration ledger. |
| Reference | Languages, titles, contact types, statuses, and shared lookup standards. |
| Customer | Natural persons, legal persons, contact details, bank accounts, licenses, and relations. |
| Institution | Insurers, banks, brokers, company roles, identifiers, and addresses. |
| Risk/Object | Insurable objects, vehicles, real estate, loans, persons, things, activities, and risk lookups. |
| Policy | Contracts, versions, parties, objects, domains, statuses, takeovers, and renewal flow. |
| Coverage | Coverage definitions, domain mapping, packages, and package items. |
| Claim | Claims, parties, objects, circumstances, status, payment method, paid and reserved amounts. |
| Document | Document metadata, links, versions, external storage keys, and soft-delete support. |
| Tasking | Tasks, comments, reminders, priority, status, and daily operator queues. |
| Audit | Audit logs and entity change sets for traceability. |

## SSMS Operator Workbench

Open scripts from `database/ssms/` in SQL Server Management Studio. For files
that use `:setvar` or `:r`, enable `Query > SQLCMD Mode`.

Recommended operator flow:

1. `00__open_first_safety_check.sql` - confirm DEV database and safe server context.
2. `05__operator_dashboard_home.sql` - keep this open as the SSMS home tab.
3. `11__schema_working_logic_map.sql` - review domain groups, subheadings, and planning cards.
4. `12__table_catalog_and_relationships.sql` - inspect the real table catalog and FK map.
5. `10__daily_operator_checklist.sql` - run the morning and end-of-day checklist.
6. `02__operations_dashboard.sql` - review customer, policy, claim, task, coverage, and lookup grids.
7. `06__query_library_shortcuts.sql` - search records and copy IDs from Results Grid.
8. `07__data_entry_bridge_templates.sql` - create data through preview-first bridge templates.
9. `08__data_editing_guardrails.sql` - update data with before/after grids and rollback default.
10. `09__graph_report_pack.sql` - produce chart-ready and export-ready report grids.
11. `03__create_renewal_tasks.sql` - run renewal generation in `DRY_RUN = 1` mode first.
12. `04__admin_security_audit_queries.sql` - review RBAC, audit, trigger, and integrity controls.

Detailed SSMS tutorials are available in `database/ssms/tutorials/`.

## Visual Demo

A local SSMS-style visual demo is available for walkthroughs and client review:

```powershell
cd database/ssms/demo
python -m http.server 3000 --bind 127.0.0.1
```

Then open `http://127.0.0.1:3000/`.

The demo is visual only. The real operating model remains SSMS scripts,
SQLCMD Mode, and SQL Server Results Grid.

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

Run the static quality gate before migration execution:

```powershell
./database/tools/test-sql-quality-gate.ps1 -NoReportFile
```

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

## Repository Map

| Path | Purpose |
| --- | --- |
| `database/migrations/` | Ordered forward-only SQL Server migrations. |
| `database/validation/` | Post-migration validation and integrity checks. |
| `database/ssms/` | SSMS operator dashboard, query library, bridge templates, guardrails, tutorials, and visual demo. |
| `database/tools/` | Guarded local and CI migration runners. |
| `database/docs/` | Architecture, security, ERD, data dictionary, Azure/SSMS runbooks, and production readiness standards. |
| `backend/` | Optional .NET 8 API foundation and tests. |
| `.github/workflows/` | CI workflows for SQL Server and backend checks. |
| `.github/` | Dependabot, CODEOWNERS, pull request template, and repository standards. |

## Production Readiness

Production planning is documented for Azure Windows Server, SQL Server, SSMS
deployment, backup/restore, security hardening, environment separation, and
release evidence:

- `database/docs/azure-windows-server-deployment.md`
- `database/docs/ssms-deployment-runbook.md`
- `database/docs/sql-server-installation-checklist.md`
- `database/docs/backup-restore-strategy.md`
- `database/docs/security-hardening.md`
- `database/docs/environment-matrix.md`
- `database/docs/production-readiness-checklist.md`
- `database/docs/repository-development-plan.md`

Use `database/docs/migration-execution-log-template.md` for TEST and PROD
deployment records.

## Backend Foundation

The backend is an optional .NET 8 integration layer:

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
in `SECURITY.md`. Do not commit credentials, database backups, connection
strings, or production data.

Dependency updates are managed through Dependabot for GitHub Actions and NuGet.

## Current Delivery Status

| Area | Status |
| --- | --- |
| Database core | Complete through protected migration `018`. |
| Validation coverage | Complete for the current database scope. |
| SSMS workbench | Dashboard, daily checklist, query library, bridge templates, guardrails, working logic map, table catalog, tutorials, and report pack are available. |
| Visual demo | SSMS-style local demo available under `database/ssms/demo/`. |
| Production pack | Azure, SQL Server, SSMS deployment, backup/restore, security, environment, readiness, and execution log documents are available. |
| Backend/API | Optional integration foundation available; not the primary operator surface. |
| DEV SQL Server execution | Must be confirmed in an environment with `sqlcmd` or SSMS access to the target SQL Server instance. |
