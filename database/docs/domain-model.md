# Domain Model

The platform is organized around these insurance core domains:

- Person and customer management
- Institution management
- Insurable objects
- Policies and contracts
- Contract versions
- Coverages
- Claims
- Documents
- Tasks and reminders
- Audit and compliance

Contract versioning is a core domain concept and must remain explicit.

## Person Domain

The person domain uses `person.Person` as the tenant-aware root. Natural and
legal persons are split into `person.NaturalPerson` and `person.LegalPerson`.
Contact data is represented by address, phone, email, social media, bank
account, and driver license tables.

Legacy join table names are normalized to PascalCase:

- `Person_PersonType` becomes `person.PersonPersonType`.
- `PersonRelation_Person` becomes `person.PersonRelationPerson`.

## Institution Domain

The institution domain uses `institution.Institution` as the tenant-aware root
for insurers, banks, brokers, and partner companies. Identifiers and addresses
are modeled as child tables with type and role lookup tables.

## Risk Domain

The legacy object domain is refactored to `risk.InsurableObject` and subtype
tables. No table is named `Object`; subtypes use `InsurableVehicle`,
`InsurableRealEstate`, `InsurableLoan`, `InsurablePerson`, `InsurableThing`, and
`InsurableActivity`.

## Policy Domain

The policy domain uses `policy.Contract` as the tenant-aware root and
`policy.ContractVersion` as the lifecycle history model. Parties link to
`person.Person`; insured objects link to `risk.InsurableObject`.

## Coverage Domain

The coverage domain replaces legacy `lookup_coverage` and `coverage_domain`
tables with schema-qualified `coverage.Coverage` and
`coverage.CoverageDomain`. Coverage packages allow reusable bundles per policy
domain.

## Claim Domain

The claim domain uses `claim.Claim` as the tenant-aware root. Claims link to
`policy.Contract`, optional `coverage.Coverage`, claim parties, claim objects,
and circumstance types.

## Document Domain

Documents are represented as metadata records with storage provider and storage
key fields. Binary file content is intentionally stored outside SQL Server.
Documents can be versioned and linked to people, institutions, policies, claims,
or risk objects.

## Task Domain

Tasks are tenant-aware operational records that can point to a person,
institution, policy, claim, risk object, or document. Comments and reminders are
modeled as child tables.
