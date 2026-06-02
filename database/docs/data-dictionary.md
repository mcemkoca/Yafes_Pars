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

## institution.Institution

Tenant-aware root table for insurers, banks, brokers, partners, and other
companies. Includes institution code, display name, legal name, VAT number,
country, active state, audit columns, and soft delete state.

## institution.InstitutionRole

Reference table for institution roles in policy, claim, or operational context.

## institution.InstitutionIdentifierType

Reference table for external identifier types such as KBO, VAT, FSMA, or
internal company codes.

## institution.InstitutionIdentifier

Stores typed external identifiers for institutions with validity dates.

## institution.InstitutionAddressRole

Reference table for address roles such as head office, billing, or postal
address.

## institution.InstitutionAddress

Stores institution addresses with role, country, primary flag, audit columns,
and soft delete state.

## risk.InsurableObject

Tenant-aware root table for insurable risks. Replaces the legacy `Object` table.
Includes type, description, status, date range, audit columns, and soft delete
state.

## risk.InsurableVehicle

Vehicle subtype for make, model, chassis, plate, financing, valuation, and
technical vehicle attributes.

## risk.InsurableRealEstate

Real estate subtype for risk address, construction details, occupancy, ABEX
index fields, insured capital, and burglary protection links.

## risk.InsurableLoan

Loan subtype for credit or financing risks. Periodicity and duration type codes
are stored before policy lookup tables are created.

## risk.InsurablePerson

Person or group subtype for insured people, worker groups, employee groups, and
family-style risk objects.

## risk.InsurableThing

Movable thing subtype for equipment, valuables, goods, or other tangible risks.

## risk.InsurableActivity

Activity subtype for event or activity-based risks.

## policy.Contract

Tenant-aware policy or contract root table. Includes contract number, domain,
type, status, company, handling company, date range, audit columns, and soft
delete state.

## policy.ContractVersion

First-class version table for contract lifecycle changes. Version numbers are
unique per contract and effective date ranges are validated.

## policy.ContractParty

Maps people to contracts through contract party roles.

## policy.ContractObject

Maps contracts to `risk.InsurableObject` records with object status and primary
flags.

## policy.ContractVersionObject

Maps contract versions to the contract objects active in that version.

## policy.ContractTakeover

Stores incoming, outgoing, or internal takeover metadata for a contract version.

## coverage.Coverage

Reference table for core insurance coverages and localized labels.

## coverage.CoverageDomain

Maps coverages to policy contract domains.

## coverage.CoveragePackage

Groups coverages into reusable packages by contract domain.

## coverage.CoveragePackageItem

Maps coverages into packages with mandatory flags and sort order.

## claim.Claim

Tenant-aware claim root table linked to `policy.Contract`. Includes coverage,
status, handler, incident and reported dates, closed date, paid and reserved
amounts, payment method, audit columns, and soft delete state.

## claim.ClaimParty

Maps people to claims by claim party role.

## claim.ClaimObject

Maps claims to `risk.InsurableObject` records.

## claim.ClaimCircumstance

Maps claims to circumstance type records.

## document.Document

Stores file metadata only. Includes tenant, owner entity type/id, document type,
file metadata, storage provider/key, checksum, language, upload user/time, and
soft delete state.

## document.DocumentType

Reference table for document categories such as ID cards, policy documents,
claim photos, invoices, and signed contracts.

## document.DocumentLink

Allows one document to be linked to additional entities beyond its primary
owner.

## document.DocumentVersion

Stores file metadata for each version of a document. No binary file content is
stored in SQL Server by default.
