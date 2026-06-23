# Table Reconciliation: Legacy 89 vs Current 108

Use this document before removing, merging, or adding tables. The current
migration source is the production design authority.

Short rule: legacy 89 is comparison history; current 108 is the active model.

## Source Of Truth

| Source | Count | Status |
| --- | ---: | --- |
| `database/legacy/schema.sql` | 89 | Legacy comparison source only. |
| `database/migrations/000..018` | 108 | Active SQL Server source of truth. |

Decision: do not reduce the active model to 89 tables. The 108-table model is
intentional because it adds tenant/RBAC/audit foundations, document/tasking
operations, clearer coverage structures, and safer risk/object naming.

## Current Schema Counts

| Schema | Tables | Role |
| --- | ---: | --- |
| `core` | 7 | Tenant, users, roles, permissions, migration ledger. |
| `ref` | 6 | Shared lookup standards. |
| `person` | 16 | Natural/legal identity, contact data, relations. |
| `institution` | 6 | Insurers, banks, brokers, identifiers, addresses. |
| `risk` | 33 | Insurable objects and subtype detail. |
| `policy` | 17 | Contracts, versions, parties, objects, takeovers. |
| `coverage` | 4 | Coverage catalog, domains, packages. |
| `claim` | 8 | Claim root, parties, objects, circumstances. |
| `document` | 4 | Documents, links, versions, storage metadata. |
| `tasking` | 5 | Tasks, comments, reminders, priority/status. |
| `audit` | 2 | Audit log and entity change details. |

## Rename And Split Decisions

| Legacy table or idea | Current table or decision | Decision |
| --- | --- | --- |
| `Object` | `risk.InsurableObject` | Renamed to avoid unsafe generic table naming. |
| `ObjectType` | `risk.InsurableObjectType` | Renamed for clarity. |
| `ObjectVehicle` | `risk.InsurableVehicle` | Kept with safer naming. |
| `ObjectRealEstate` | `risk.InsurableRealEstate` | Kept with safer naming. |
| `ObjectRealEstate_BurglaryProtection` | `risk.InsurableRealEstateBurglaryProtection` | Kept and normalized naming. |
| `ObjectLoan` | `risk.InsurableLoan` | Kept with safer naming. |
| `ObjectPerson` | `risk.InsurablePerson` | Kept with safer naming. |
| `ObjectThing` | `risk.InsurableThing` | Kept with safer naming. |
| `ObjectActivity` | `risk.InsurableActivity` | Kept with safer naming. |
| `ObjectPersonSubtype` | `risk.InsurablePersonSubtype` | Kept with safer naming. |
| `ObjectThingSubtype` | `risk.InsurableThingSubtype` | Kept with safer naming. |
| `ObjectActivitySubtype` | `risk.InsurableActivitySubtype` | Kept with safer naming. |
| `Person_PersonType` | `person.PersonPersonType` | Kept with SQL Server-friendly naming. |
| `PersonRelation_Person` | `person.PersonRelationPerson` | Kept with SQL Server-friendly naming. |
| `EconomicActivity_Nacebel` | `person.EconomicActivityNacebel` | Kept with SQL Server-friendly naming. |
| `Contract_Object` | `policy.ContractObject` | Kept with SQL Server-friendly naming. |
| `Contract_Party` | `policy.ContractParty` | Kept with SQL Server-friendly naming. |
| `ContractVersion_Object` | `policy.ContractVersionObject` | Kept with SQL Server-friendly naming. |
| `Claim_Circumstance` | `claim.ClaimCircumstance` | Kept with SQL Server-friendly naming. |
| `Claim_Object` | `claim.ClaimObject` | Kept with SQL Server-friendly naming. |
| `Claim_Party` | `claim.ClaimParty` | Kept with SQL Server-friendly naming. |
| `lookup_coverage` | `coverage.Coverage` | Reworked into the coverage schema. |
| `coverage_domain` | `coverage.CoverageDomain` | Reworked into the coverage schema. |
| `NatureType` | Not carried forward as a table | Needs owner confirmation before any future migration. |

## Additions Beyond Legacy 89

| Area | Added tables | Reason |
| --- | --- | --- |
| Tenant and security | `core.Tenant`, `core.AppUser`, `core.Role`, `core.Permission`, `core.RolePermission`, `core.UserRole`, `core.SchemaMigration` | Required for multi-tenant operation, RBAC, and migration traceability. |
| Documents | `document.DocumentType`, `document.Document`, `document.DocumentLink`, `document.DocumentVersion` | Required for policy, claim, person, institution, and risk document handling. |
| Tasking | `tasking.TaskStatus`, `tasking.TaskPriority`, `tasking.Task`, `tasking.TaskComment`, `tasking.TaskReminder` | Required for daily operator workflow and renewal/claim follow-up. |
| Audit | `audit.AuditLog`, `audit.EntityChangeSet` | Required for guarded edits and support/audit evidence. |
| Coverage packages | `coverage.CoveragePackage`, `coverage.CoveragePackageItem` | Required for reusable insurance package structure. |

## Working Rule

1. Keep the current 108-table migration line protected.
2. Use `12__table_catalog_and_relationships.sql` before planning any table
   change.
3. Use `13__visual_workflow_board.sql` to review domain routes and readiness.
4. Add new schema changes only as forward migration `019+`.
5. Do not delete or merge tables only because the legacy package had fewer
   tables.

## Open Owner Decisions

| Topic | Current position | Required owner decision |
| --- | --- | --- |
| `NatureType` | Not implemented as a current table. | Confirm whether it belongs to policy, risk, or lookup scope. |
| Finance/commission | Not implemented yet. | Approve accounting flow before `019+` design. |
| Import/export staging | Not implemented yet. | Approve onboarding/import process before `019+` design. |
| Product templates | Not implemented yet. | Confirm product/rating ownership before `019+` design. |
