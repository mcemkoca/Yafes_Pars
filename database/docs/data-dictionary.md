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

## ref.Language

Reference table for supported language codes and localized labels.

## ref.Title

Reference table for person titles.

## ref.PhoneType

Reference table for phone number categories.

## ref.SocialType

Reference table for social media link categories.

## ref.ProfessionalStatus

Reference table for natural or legal person professional status values.

## ref.PersonType

Reference table for person classification values.

## person.Person

Tenant-aware root person table for natural and legal persons. Includes dossier,
language, nationality, management person references, audit columns, and soft
delete state.

## person.NaturalPerson

Subtype table for individual people, including name, birth, identity document,
gender, marital status, and title fields.

## person.LegalPerson

Subtype table for organizations modeled as persons, including incorporation,
closing date, and legal form.

## person.Address

Stores person postal addresses with role, country, primary flag, audit columns,
and soft delete state.

## person.Phone

Stores phone numbers with type, primary flag, audit columns, and soft delete
state.

## person.Email

Stores email addresses with primary flag, audit columns, and soft delete state.

## person.PersonRelation

Tenant-aware relationship header table for family, business, or other person
relations.

## person.PersonRelationPerson

Join table connecting relation records to the from and to persons.
