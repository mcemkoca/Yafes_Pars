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
