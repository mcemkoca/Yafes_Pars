# ERD Notes

Existing legacy ERD images remain under `ERD/`. The SQL Server migration set now
uses schema-qualified domain tables, so new ERD documentation is maintained in:

- `database/docs/erd-mermaid.md`

## Domain Split

- `core`: tenants, users, roles, permissions.
- `person`: natural/legal persons, contacts, relations, bank and license data.
- `institution`: insurers, brokers, banks, identifiers, addresses.
- `risk`: insurable object root plus vehicle, real estate, loan, person, thing,
  and activity subtypes.
- `policy`: contracts, versions, parties, objects, version objects, takeovers.
- `coverage`: coverages, domain mappings, packages, package items.
- `claim`: claims, claim parties, claim objects, claim circumstances.
- `document`: metadata-only documents, links, versions.
- `tasking`: tasks, comments, reminders.
- `audit`: audit log and per-column change sets.

## Legacy Mapping Notes

- Legacy `Object` is mapped to `risk.InsurableObject`.
- Legacy `ObjectVehicle` is mapped to `risk.InsurableVehicle`.
- Legacy `ObjectRealEstate` is mapped to `risk.InsurableRealEstate`.
- Legacy `Contract_Object` is mapped to `policy.ContractObject`.
- Legacy `ContractVersion_Object` is mapped to `policy.ContractVersionObject`.
- Legacy `Claim_Object` is mapped to `claim.ClaimObject`.
- Legacy `lookup_coverage` is mapped to `coverage.Coverage`.
- Legacy `coverage_domain` is mapped to `coverage.CoverageDomain`.

## Diagram Strategy

The full model is too large for one practical diagram. Use one high-level
cross-domain ERD for navigation, then domain-level diagrams in
`erd-mermaid.md` for implementation detail.
