# Repository Development Plan

This plan captures the next professionalization steps for the SSMS-first,
database-first Yafes Pars repository.

## A. Critical Findings

- The product direction is SQL Server and SSMS-first, not web-first.
- Migration order `000` through `018` must remain stable.
- Production deployment needs Azure Windows Server, SQL Server, backup, restore,
  security, and execution runbooks.
- Static quality checks should run before heavier SQL Server validation.

## B. Current Structure That Must Not Break

- `database/legacy/`
- `database/migrations/`
- `database/rollback/`
- `database/validation/`
- `md/database/`
- `database/templates/`
- `database/ssms/`
- `UML/`
- `ERD/`
- `md/trust-plan/`

## C. Azure Windows Server Target Architecture

Run SQL Server on an Azure Windows Server VM with private network access, split
data/log/tempdb/backup storage where possible, and SSMS as the operator surface.
Use Azure monitoring and off-VM backup storage.

## D. SQL Server And SSMS Deployment Plan

Keep deployment script-based. Operators use SSMS Query Editor, Results Grid,
Messages, and SQLCMD Mode. DEV can use the guarded PowerShell runner. TEST and
PROD follow the SSMS deployment runbook and execution log.

## E. Migration And Validation Plan

Preserve migrations `000` through `018`. New forward migrations start at `019`.
Validation scripts remain ordered and must be run after migrations. Rollback
scripts stay separate and manually approved.

## F. Security Hardening Plan

Use least privilege, private SQL access, restricted RDP, credential rotation,
secret storage outside Git, RBAC review, tenant isolation review, and audit log
review before production.

## G. Backup, Restore, And DR Plan

Define RPO/RTO with the business owner. Use full backups, optional differential
backups, log backups for full recovery, mandatory pre-deployment backups, and
regular restore drills.

## H. Monitoring And Maintenance Plan

Monitor SQL Server availability, backup age, SQL Agent jobs, disk space, error
logs, failed logins, and validation results. Review maintenance windows for
index/statistics work after real data volume is known.

## I. Repo File And Documentation Update List

- Add Azure Windows Server deployment guide.
- Add SSMS deployment runbook.
- Add SQL Server installation checklist.
- Add backup and restore strategy.
- Add security hardening guide.
- Add migration execution log template.
- Add environment matrix.
- Add production readiness checklist.
- Add static SQL quality gate script and CI workflow.

## J. New SQL Script Recommendations

- Add migration `019+` only for new database changes.
- Add matching validation scripts for every new domain or shared behavior.
- Add SSMS bridge scripts for new guided operator actions.
- Add report pack scripts for new executive or operational dashboards.

## K. Production Readiness Checklist

Use `md/database/production-readiness-checklist.md` as the single readiness
gate. Every exception must have an owner, reason, and expiry date.

## L. Risks And Mitigations

| Risk | Mitigation |
| --- | --- |
| Wrong environment execution | SSMS safety scripts, environment matrix, and runbook stop conditions. |
| Missing backup | Pre-deployment backup requirement and execution log evidence. |
| Unsafe SQL | Static quality gate and peer review. |
| Cross-tenant data mistakes | Tenant-required templates and RBAC/audit review. |
| Secret exposure | No-secrets policy and credential rotation. |

## M. Concrete Execution Order

1. Keep existing migration order unchanged.
2. Run static SQL quality gate.
3. Run SQL Server validation in DEV/CI.
4. Rehearse SSMS deployment in TEST.
5. Complete backup/restore drill.
6. Complete production readiness checklist.
7. Execute approved PROD release runbook.
