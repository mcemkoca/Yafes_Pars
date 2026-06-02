# ERD Notes

Existing ERD images are retained in the repository under `ERD/`.

As the database is migrated into domain schemas, this document will record
mapping notes between legacy diagrams and new schema-qualified tables.

## Legacy Mapping Notes

- Legacy `Object` is mapped to `risk.InsurableObject`.
- Legacy `ObjectVehicle` is mapped to `risk.InsurableVehicle`.
- Legacy `ObjectRealEstate` is mapped to `risk.InsurableRealEstate`.
- Legacy `Contract_Object` is mapped to `policy.ContractObject`.
- Legacy `ContractVersion_Object` is mapped to `policy.ContractVersionObject`.
- Legacy `Claim_Object` is mapped to `claim.ClaimObject`.
- Legacy `lookup_coverage` is mapped to `coverage.Coverage`.
- Legacy `coverage_domain` is mapped to `coverage.CoverageDomain`.
