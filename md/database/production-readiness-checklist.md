# Production Readiness Checklist

Use this checklist before declaring Yafes Pars ready for a production SQL Server
environment. Items marked ✅ are verified in the current repository state.

## Repository

- ✅ Migration order `000` through `018` is unchanged (49 migrations total, up to `048`)
- ✅ Any new migrations start at `019`
- ✅ Static SQL quality gate passes (CI green)
- ✅ SQL Server validation workflow passes (CI green)
- ✅ SSMS workbench validation workflow passes (CI green)
- ✅ Backend build and integration tests pass (CI green)
- ✅ README links to deployment, security, backup, and runbook documents
- ✅ Table reconciliation `89 vs 108 vs 144` accepted (`md/database/table-reconciliation-89-vs-108.md`)
- ✅ No secrets, tokens, connection strings, backups, or production data in the repository

## Database Schema

- ✅ 15 domain schemas: core, ref, person, institution, risk, policy, coverage, claim, document, tasking, audit, finance, import, communication, assurance
- ✅ 144 tables (49 migrations)
- ✅ Schemas, constraints, indexes, triggers, views, procedures, seed data validated in DEV
- ✅ Tenant-aware query and mutation paths verified (all SP bridges include tenant_id check)
- ✅ RBAC seed data reviewed (4 roles, permission matrix in `14__admin_role_permission_matrix.sql`)
- ✅ Audit triggers verified (`011__create_audit_domain.sql`)
- [ ] TEST rehearsal completed without manual script edits → `md/reports/test-migration-evidence.md`
- [ ] `018__seed_demo_data.sql` excluded from PROD run

## MCP Tools (Backend)

- ✅ 33 MCP tool classes, all `[McpServerToolType]` (see `md/reports/mcp-gap-analysis.md`)
- ✅ Renewal pipeline tools: GetRenewalQueue, ProcessRenewal, SendRenewalNotices, GetRenewalMetrics
- ✅ Premium calculator tools: CalculatePremium, GetPremiumSummary, GetTariffRates, UpsertTariffRate
- ✅ Legacy import tools: ImportLegacyPersons, GetLegacyImportSummary, GetLegacyImportErrors
- ✅ Export job tools: StageImportRows, ValidateImportBatch, GetImportBatchStatus (+ bridge actions)
- ✅ JWT tenant-scoped reads; production JWT authority/audience required

## SSMS Bridge Templates

- ✅ 22 PREVIEW_FIRST bridge actions in `07__data_entry_bridge_templates.sql`
- ✅ Full write coverage: person, legal person, policy, version, party, object, vehicle, real estate, coverage item, claim, settlement, reserve, task, comment, reminder, document, payment, payment plan, export job
- ✅ DEV guard (DB_NAME LIKE '%DEV%') on all SSMS scripts

## Operations

- ✅ Azure Windows Server deployment architecture documented
- ✅ SQL Server installation checklist documented
- ✅ Backup and restore strategy documented
- ✅ DEV restore drill completed (`md/reports/restore-drill-evidence-dev-2026-06-04.md`)
- ✅ DEV access review completed (`md/reports/access-review-evidence-dev-2026-06-04.md`)
- ✅ SSMS deployment runbook available (`md/database/ssms-deployment-runbook.md`)
- ✅ Migration execution log template available
- ✅ SQL Agent setup script hardened (`18__sql_agent_job_setup.sql`)
- [ ] SQL Agent DBA approval signed → `md/reports/sql-agent-dba-approval.md`
- [ ] TEST restore drill completed → `md/reports/test-restore-drill-report.md`
- [ ] TEST access review signed → `md/reports/access-review-evidence-test.md`
- [ ] TEST migration evidence collected → `md/reports/test-migration-evidence.md`
- [ ] Monitoring owner assigned
- [ ] `15__monitoring_and_job_readiness.sql` reviewed in TEST

## Security

- ✅ No environment files, tokens, or secrets in repository (artifact policy CI gate)
- ✅ Credential rotation process documented (`md/database/security-hardening.md`)
- [ ] SQL Server network access private and restricted on TEST/PROD
- [ ] RDP access restricted on TEST/PROD
- [ ] SQL logins and Windows groups follow least privilege (TEST evidence)
- [ ] Secrets stored outside Git (verified in target environment)
- [ ] Production support access auditable (two-signatory drill evidence)

## PROD-Specific Gates (after TEST passes)

- [ ] PROD access review with two signatories → `md/reports/access-review-evidence-prod.md`
- [ ] PROD restore drill with two signatories → `md/reports/prod-restore-drill-report.md`
- [ ] Change management approval for PROD migration window
- [ ] `018__seed_demo_data.sql` explicitly excluded from PROD migration run
- [ ] PROD SQL Agent jobs created after DBA approval

## Go-Live Decision

Go-live is ready only when:
1. All repository checks ✅
2. TEST evidence complete (migration + access review + restore drill)
3. SQL Agent DBA approval signed
4. PROD evidence complete (access review + restore drill, two signatories each)
5. Change management window approved
