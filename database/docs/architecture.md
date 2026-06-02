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
