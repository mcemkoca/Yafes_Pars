# Environment Readiness Report — 2026-07-19

**Owner:** Deuterium12{MCK}  
**Status:** DEV — READY | TEST — PENDING | PROD — BLOCKED

---

## Executive Summary

The Yafes Pars system is feature-complete at the repository level. All database
migrations, MCP tools, bridge templates, and CI gates are in place. The only
remaining release gates are environment-side evidence items that require real
SQL Server access outside this repository.

---

## Environment Status Matrix

| Environment | Migration Execution | Access Review | Restore Drill | SQL Agent | Overall |
|---|---|---|---|---|---|
| DEV | ✅ VERIFIED | ✅ VERIFIED | ✅ VERIFIED | 🔶 PENDING DBA | READY |
| TEST | 🔶 PENDING | 🔶 PENDING | 🔶 PENDING | 🔶 PENDING DBA | BLOCKED |
| PROD | ⛔ NOT YET | ⛔ NOT YET | ⛔ NOT YET | ⛔ NOT YET | NOT STARTED |

---

## DEV Evidence (Completed)

| Evidence Item | Report | Date | Status |
|---|---|---|---|
| Migration execution | `md/reports/dev-validation-evidence-2026-06-04.md` | 2026-06-04 | ✅ VERIFIED |
| Access review | `md/reports/access-review-evidence-dev-2026-06-04.md` | 2026-06-04 | ✅ VERIFIED |
| Restore drill | `md/reports/restore-drill-evidence-dev-2026-06-04.md` | 2026-06-04 | ✅ VERIFIED |
| Backend build / unit tests | CI: `backend-build.yml` | Continuous | ✅ GREEN |
| SQL quality gate | CI: `ssms-workbench-validation.yml` | Continuous | ✅ GREEN |
| Write-flow integration | CI: SQL Server container | Continuous | ✅ GREEN |

---

## TEST Environment — Pending Items

Templates and runbooks are ready. All items require environment access.

| Item | Template/Script | Blocker | Status |
|---|---|---|---|
| Run guarded migrations | `database/tools/run-dev-migrations.ps1` (adapt for TEST) | TEST SQL Server access | PENDING |
| Access review | `md/database/access-review-evidence-template.md` | Named DBA + TEST access | PENDING |
| Restore drill | `md/restore/test-restore-drill-plan.md` | TEST backup files + restore target | PENDING |
| SQL Agent job creation | `database/ssms/18__sql_agent_job_setup.sql` | DBA approval + TEST SQLServerAgent | PENDING DBA |

---

## PROD Environment — Blocked

PROD execution is blocked until TEST evidence is complete.

| Gate | Requirement | Status |
|---|---|---|
| TEST evidence complete | All TEST items signed off | BLOCKED on TEST |
| Change-management window | CM approval required for PROD migration | NOT STARTED |
| Named signatories | Two signatories for restore drill | NOT ARRANGED |
| PROD restore drill | Isolated restore target (not PROD itself) | NOT STARTED |

---

## Repository Readiness (All Done)

| Area | Item | PR | Status |
|---|---|---|---|
| Database | Migrations 000–048 (49 total) | Various | ✅ |
| Database | Validations 001–017 (17 total) | Various | ✅ |
| Database | 22 SSMS bridge templates | #97, #99, this session | ✅ |
| Database | SQL Agent setup + security fix | PR #99 | ✅ |
| MCP | 33 tool classes, all `[McpServerToolType]` | Various | ✅ |
| MCP | RenewalTools (4 tools) | Pre-existing | ✅ |
| MCP | PremiumCalculatorTools (4 tools) | Pre-existing | ✅ |
| MCP | LegacyImportTools (3 tools) | PR #99 | ✅ |
| MCP | ImportTools / ExportJobTools | Pre-existing | ✅ |
| CI | Backend build + unit tests | CI | ✅ |
| CI | SQL Server write-flow integration | CI | ✅ |
| CI | SSMS workbench validation (manifest, scripts, controls) | CI | ✅ |
| Manifest | `ssmsScripts` contract fixed (`{ count, items }`) | PR #99 | ✅ |
| Docs | Access-review templates | Pre-existing | ✅ |
| Docs | Restore drill plans | Pre-existing | ✅ |
| Docs | MCP gap analysis | PR #99 | ✅ |

---

## SQL Agent DBA Approval Package

Script: `database/ssms/18__sql_agent_job_setup.sql`

**Jobs to create:**

| Job | Schedule | SP Called | Tenant |
|---|---|---|---|
| `YafesPars_DailyMarkOverdueInvoices` | Daily 06:00 | `finance.SP_MarkOverdueInvoices` | N/A |
| `YafesPars_DailyRenewalTasks` | Daily 07:00 | `tasking.SP_CreateRenewalTasks` | SQLCMD var |
| `YafesPars_WeeklyFsmaPortfolioCheck` | Monday 08:00 | Inline SELECT | N/A |

**Security notes:**
- Script aborts if `YAFES_SQL_DATABASE` does not contain DEV, TEST, or ACC (RAISERROR level 16 + LOG).
- Job 2 uses `sp_executesql` with SQLCMD variable for tenant lookup — no hard-coded database names.
- All jobs idempotent: skip if already exists.
- Requires `sysadmin` or `SQLAgentOperatorRole`.

**DBA sign-off required before running on TEST/PROD.**

---

## Next Release Gates (in order)

1. DBA reviews and approves `18__sql_agent_job_setup.sql` → signs `md/reports/sql-agent-dba-approval.md`
2. Run migrations on TEST + collect evidence → `md/reports/test-migration-evidence.md`
3. Run access review on TEST → `md/reports/access-review-evidence-test.md`
4. Run restore drill on TEST → `md/reports/test-restore-drill-report.md`
5. Repeat steps 2–4 for PROD with two signatories
6. Merge PROD evidence into production readiness checklist
