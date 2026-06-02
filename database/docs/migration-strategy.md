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

## Initial Migration Base

- `000__create_database.sql` creates `YafesPars` when it does not exist.
- `001__create_schemas.sql` creates the required domain schemas.
- `002__create_core_infrastructure.sql` creates `core.SchemaMigration`.
- `001__validate_core_infrastructure.sql` validates schemas and migration
  tracking objects.
- `003__create_person_domain.sql` creates person and contact tables from the
  legacy person domain under the `person` schema and lookup tables under `ref`.
- `002__validate_person_domain.sql` validates the person migration.
- `004__create_institution_domain.sql` creates tenant-aware institution,
  identifier, address, and lookup tables.
- `003__validate_institution_domain.sql` validates the institution migration.
- `005__create_object_domain.sql` creates the refactored risk domain using
  `risk.InsurableObject` instead of the legacy `Object` table name.
- `004__validate_risk_domain.sql` validates the risk migration and checks that
  forbidden `Object` tables were not created.
- `006__create_contract_domain.sql` creates the policy contract, version,
  party, object, takeover, and lookup tables.
- `005__validate_policy_domain.sql` validates the policy migration.
- `007__create_coverage_domain.sql` creates coverage, domain mapping, package,
  package item tables, and core coverage seed rows.
- `006__validate_coverage_domain.sql` validates the coverage migration.
- `008__create_claim_domain.sql` creates tenant-aware claim, party, object,
  circumstance, status, role, and payment method tables.
- `007__validate_claim_domain.sql` validates the claim migration.
- `009__create_document_domain.sql` creates document metadata, link, version,
  and type tables without storing file binaries in SQL Server.
- `008__validate_document_domain.sql` validates the document migration.
- `010__create_task_domain.sql` creates task, comment, reminder, status, and
  priority tables.
- `009__validate_task_domain.sql` validates the task migration.
- `011__create_audit_domain.sql` creates audit tables and minimal audit triggers
  for key root tables.
- `010__validate_audit_domain.sql` validates the audit migration.
- `012__add_constraints.sql` adds cross-domain constraints that depend on
  multiple prior domains.
- `011__validate_constraints_exist.sql` validates cross-domain constraints.
- `013__add_indexes.sql` creates missing FK-supporting indexes from SQL Server
  catalog metadata and adds dashboard/reporting indexes.
- `012__validate_indexes.sql` validates FK index coverage and reporting indexes.
- `014__add_triggers.sql` registers the trigger phase; root audit triggers are
  created by `011__create_audit_domain.sql`.
- `013__validate_triggers.sql` validates root audit trigger existence.
- `015__add_views.sql` creates reporting and dashboard views.
- `014__validate_views.sql` validates view existence.
- `016__add_stored_procedures.sql` creates tenant-aware search, create, close,
  and audit lookup stored procedures.
- `015__validate_stored_procedures.sql` validates stored procedure existence.
- `017__seed_lookup_data.sql` seeds production lookup/reference data and core
  RBAC permissions and system roles.
- `016__validate_seed_data.sql` validates required seed data.
