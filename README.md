# Yafes Pars

Yafes Pars is a SQL Server and SSMS-first insurance core database platform.

The current priority is the database core. Backend, API, and frontend work should
start only after the migration discipline, validation scripts, tenant model,
audit model, seed data, and documentation are stable.

## Scope

- Customer and person management
- Institution and insurance company management
- Insurable object management
- Policy and contract management
- Policy versioning
- Coverage management
- Claim management
- Document metadata
- Task and reminder tracking
- Tenant, user, role, and permission foundation
- Audit logging

## Repository Layout

- `database/legacy/`: preserved legacy SQL files for traceability.
- `database/migrations/`: ordered SSMS-compatible migration scripts.
- `database/rollback/`: rollback scripts kept separate from forward migrations.
- `database/validation/`: SSMS validation scripts for table, constraint, index,
  trigger, seed, and business rule checks.
- `database/docs/`: architecture, setup, domain model, data dictionary, naming,
  migration, ERD, and security documentation.
- `database/templates/`: reusable SQL templates for future migrations.
- `UML/` and `ERD/`: existing visual model artifacts.
- `trust plan/`: historical planning, packages, experiments, and generated
  application material.

## SSMS Execution Model

Run migrations manually from SQL Server Management Studio in filename order.
Validation scripts should be run after the related migrations and again after a
full database build.

Planned migration order:

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

## Database Standards

- Target Microsoft SQL Server only.
- Use T-SQL syntax and SSMS-compatible batches.
- Use `GO` separators correctly around batch-scoped objects.
- Prefer idempotent scripts where practical.
- Use schemas: `core`, `ref`, `person`, `institution`, `risk`, `policy`,
  `coverage`, `claim`, `document`, `tasking`, and `audit`.
- Use PascalCase table names.
- Use snake_case column names.
- Do not create a table named `Object`; use `risk.InsurableObject`.
- Add validation scripts for every major migration.
- Preserve legacy SQL content instead of deleting it.

## Current Status

The repository has been reorganized into a professional database project layout.
The initial SSMS-compatible migration base creates the database, domain schemas,
migration tracking table, tenant foundation, application users, roles,
permissions, role assignment tables, and the first person domain migration.
The institution domain migration adds tenant-aware company, identifier, address,
and role tables.
The risk migration refactors the legacy object model to `risk.InsurableObject`
and subtype tables without creating an `Object` table.
The policy migration creates `policy.Contract`, `policy.ContractVersion`,
parties, insured object links, takeover metadata, and policy lookup tables.
The coverage migration replaces legacy coverage naming with
`coverage.Coverage`, domain mapping, and package tables.
The claim migration creates tenant-aware claims linked to policies, coverages,
people, and insurable objects.
The document migration stores file metadata, versions, links, and storage
references without storing binary file content in SQL Server.
The task migration creates tenant-aware tasks, comments, reminders, statuses,
and priorities.
