# SQL Agent Job Setup — DBA Approval Package

**Script:** `database/ssms/18__sql_agent_job_setup.sql`  
**Status:** PENDING DBA SIGN-OFF  
**Owner:** Deuterium12{MCK}

---

## Summary

Three SQL Server Agent jobs for automated daily/weekly operations. Script is
idempotent — skips any job that already exists. DEV guard aborts with RAISERROR
if `YAFES_SQL_DATABASE` does not contain DEV, TEST, or ACC.

---

## Jobs Requested

### Job 1 — YafesPars_DailyMarkOverdueInvoices

| Field | Value |
|---|---|
| Schedule | Daily 06:00 (server local time) |
| SP Called | `finance.SP_MarkOverdueInvoices @dry_run = 0` |
| Database | `$(YAFES_SQL_DATABASE)` (SQLCMD variable) |
| Subsystem | TSQL |
| On Success | Quit with success |
| On Fail | Quit with failure |
| Tenant scope | All tenants in database |
| Side effects | Sets PENDING invoices with past due date to OVERDUE |
| Reversible? | No — status change is logged in audit trail |

### Job 2 — YafesPars_DailyRenewalTasks

| Field | Value |
|---|---|
| Schedule | Daily 07:00 (server local time) |
| SP Called | `tasking.SP_CreateRenewalTasks @tenant_id = <resolved>, @days_ahead = 60, @dry_run = 0` |
| Database | `$(YAFES_SQL_DATABASE)` (SQLCMD variable) |
| Subsystem | TSQL |
| On Success | Quit with success |
| On Fail | Quit with failure |
| Tenant scope | Single tenant resolved from `$(TENANT_CODE)` at job creation time |
| Side effects | Creates renewal tasks for contracts expiring within 60 days (idempotent per contract) |
| Reversible? | Tasks can be closed/cancelled manually |

### Job 3 — YafesPars_WeeklyFsmaPortfolioCheck

| Field | Value |
|---|---|
| Schedule | Every Monday 08:00 (server local time) |
| SP Called | Inline SELECT (active policies, expired policies, pending commissions) |
| Database | `$(YAFES_SQL_DATABASE)` (SQLCMD variable) |
| Subsystem | TSQL |
| On Success | Quit with success |
| On Fail | Quit with failure |
| Tenant scope | All tenants in database |
| Side effects | READ-ONLY — results visible in SQL Agent job history only |
| Reversible? | N/A — read-only |

---

## Security Review

| Check | Result |
|---|---|
| DEV/TEST/ACC guard | ✅ RAISERROR level 16 + RETURN if DB name does not contain DEV, TEST, or ACC |
| Hard-coded database names | ✅ None — Job 2 uses `sp_executesql` with SQLCMD variable |
| Owner login | Configurable via `:setvar JOB_OWNER "sa"` — must be changed to a dedicated service account for PROD |
| Idempotent | ✅ IF NOT EXISTS check per job |
| Requires permissions | `sysadmin` or `SQLAgentOperatorRole` on msdb |
| Reads production data | Job 3 reads policy/commission counts — no PII extracted |
| Writes production data | Job 1 updates invoice status; Job 2 creates tasks |

---

## Pre-Execution Checklist

- [ ] SQLServerAgent service is running on target instance
- [ ] `YAFES_SQL_DATABASE` set to correct database name (must contain DEV or TEST)
- [ ] `TENANT_CODE` set to correct tenant code for Job 2
- [ ] `JOB_OWNER` changed from `sa` to approved service account login
- [ ] Script reviewed on `database/ssms/18__sql_agent_job_setup.sql` — current SHA: ______
- [ ] Test run with DRY_RUN equivalent (EXECUTE_ACTION not applicable; run on DEV first)
- [ ] DEV jobs verified before promoting to TEST

---

## DBA Sign-Off

| Field | Value |
|---|---|
| DBA name | |
| Review date UTC | |
| Environment | |
| Database | |
| Jobs approved | YafesPars_DailyMarkOverdueInvoices / YafesPars_DailyRenewalTasks / YafesPars_WeeklyFsmaPortfolioCheck |
| JOB_OWNER login confirmed | |
| Notes | |
| DBA signature | |
| Approved by | |
| Approval date | |
