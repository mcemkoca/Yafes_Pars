# Architecture

Yafes Pars is designed as a SQL Server database core for an insurance platform.

The architecture is database-first and organized by domain schemas. Core SaaS
infrastructure is separated from insurance business domains so tenant, user,
role, permission, migration, and audit concerns remain explicit.

## Primary Schemas

- `core`
- `ref`
- `person`
- `institution`
- `risk`
- `policy`
- `coverage`
- `claim`
- `document`
- `tasking`
- `audit`

Detailed domain notes will be expanded as each migration is created.

## Core Infrastructure

The first infrastructure layer creates migration tracking, tenant identity,
application users, roles, permissions, and role assignment tables. This provides
the foundation for SaaS tenant isolation and RBAC-aware backend work later.

## Domain Flow

The build order follows dependency direction:

1. Core schemas and migration tracking.
2. Tenant, user, role, and permission foundation.
3. Person and institution domains.
4. Risk objects through `risk.InsurableObject`.
5. Policy contracts and contract versions.
6. Coverage and claim domains.
7. Document metadata and task/reminder domains.
8. Audit logging, constraints, indexes, triggers, views, procedures, and seed
   data.

Backend/API work should consume this database model after SSMS validation passes.
