# Data Dictionary

This document will track tables, columns, keys, constraints, and domain notes as
the migration set is built.

## Status

Initial repository structure and core infrastructure are in place. Domain tables
will be documented when their migrations are added.

## core.SchemaMigration

Tracks migration execution metadata, including migration name, optional
checksum, execution timestamp, executing user, status, and error message.

## core.Tenant

Stores tenant identity and default settings. Business root tables should refer
to this table through `tenant_id`.

## core.AppUser

Stores users per tenant, including email, display name, authentication provider,
external subject id, active state, and login timestamps.

## core.Role

Stores tenant-scoped and system roles.

## core.Permission

Stores permission codes by module for RBAC authorization.

## core.RolePermission

Maps roles to permissions.

## core.UserRole

Maps users to roles.
