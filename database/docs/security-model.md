# Security Model

The database core will include tenant-aware infrastructure and RBAC-friendly
tables:

- `core.Tenant`
- `core.AppUser`
- `core.Role`
- `core.Permission`
- `core.RolePermission`
- `core.UserRole`

Business root tables should include `tenant_id`. Audit tables should preserve
who changed what, when possible, without storing application secrets.

## Core RBAC Tables

- `core.Tenant` stores tenant identity, legal name, display name, VAT number,
  country, default language, and active state.
- `core.AppUser` stores tenant-scoped application users and authentication
  subject metadata.
- `core.Role` supports tenant-specific roles and system-level roles.
- `core.Permission` stores permission codes by module.
- `core.RolePermission` maps permissions to roles.
- `core.UserRole` maps users to roles.

`core.AppUser.person_id` is intentionally nullable and not constrained during
the core migration because `person.Person` is created later in the migration
sequence.

## Tenant Isolation

Root business tables include `tenant_id`, including person, institution, risk
object, contract, claim, document, and task records. Cross-domain references
that can enforce tenant consistency do so through composite constraints, such as
claim-to-contract.

## Audit

`audit.AuditLog` records root entity changes from SQL triggers for key tables.
Application-layer audit can later enrich these rows with user id and correlation
id context.
