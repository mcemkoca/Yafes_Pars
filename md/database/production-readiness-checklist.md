# Production Readiness Checklist

Use this checklist before declaring Yafes Pars ready for a production SQL Server
environment.

## Repository

- [ ] Migration order `000` through `018` is unchanged.
- [ ] Any new migrations start at `019`.
- [ ] Static SQL quality gate passes.
- [ ] SQL Server validation workflow passes.
- [ ] SSMS workbench validation workflow passes.
- [ ] README links to deployment, security, backup, and runbook documents.
- [ ] Table reconciliation `89 vs 108` is accepted or has an approved exception.
- [ ] No secrets, tokens, connection strings, backups, or production data are in
  the repository.

## Database

- [ ] Schemas, constraints, indexes, triggers, views, procedures, seed data, and
  DEV sample data validations pass in DEV.
- [ ] TEST rehearsal has been completed without manual script edits.
- [ ] `018__seed_demo_data.sql` is excluded from PROD.
- [ ] Tenant-aware query and mutation paths are reviewed.
- [ ] RBAC seed data is reviewed.
- [ ] Access review evidence template is completed for the target environment.
- [ ] Audit triggers are reviewed.

## Operations

- [ ] Azure Windows Server target architecture is approved.
- [ ] SQL Server installation checklist is complete.
- [ ] Backup and restore strategy is approved.
- [ ] Restore drill has been completed.
- [ ] Restore drill evidence template is completed.
- [ ] DEV restore evidence has been reviewed as a baseline.
- [ ] SSMS deployment runbook has been rehearsed in TEST.
- [ ] Migration execution log template is used for TEST and PROD.
- [ ] Monitoring owner is assigned.

## Security

- [ ] SQL Server network access is private and restricted.
- [ ] RDP access is restricted.
- [ ] SQL logins and Windows groups follow least privilege.
- [ ] Secrets are stored outside Git.
- [ ] Credential rotation process is documented.
- [ ] Production support access is auditable.

## Go-Live Decision

Go-live is ready only when all mandatory repository, database, operations, and
security checks are complete or have an approved exception.
