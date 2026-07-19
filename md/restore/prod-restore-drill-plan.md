# PROD Restore Drill Plan

**Environment:** PROD
**Status:** PENDING ENVIRONMENT EXECUTION — BLOCKED BY ENVIRONMENT ACCESS
**Frequency:** Annually (mandatory before go-live; quarterly thereafter)
**Owner:** Deuterium12{MCK}

## Objective

Verify that the PROD database backup can be restored and validated within
the agreed Recovery Time Objective, with signed evidence.

## Target RTO

≤ 2 hours from backup selection to signed validation pass.

## Target RPO

Data loss tolerance: ≤ 1 hour (matches backup schedule).

## Prerequisites

| Requirement | Status |
|-------------|--------|
| PROD backup access (read-only, named DBA) | PENDING |
| Isolated restore-target instance (not PROD, not TEST) | PENDING |
| Change-management approval for drill window | PENDING |
| Two signatories available | PENDING |

## Drill Steps

Same as `test-restore-drill-plan.md` but:

1. Backup must be the most recent PROD full backup.
2. Restore target must be an isolated instance (never PROD itself).
3. Two named signatories must review validation output.
4. Drill must be logged in the change-management system.

## Pass Criteria

- [ ] Restore completed without errors within RTO
- [ ] Migration count ≥ 48, all SUCCESS
- [ ] Table count ≥ 140
- [ ] No orphan FK violations
- [ ] Two signatories recorded in `md/reports/prod-restore-drill-report.md`
- [ ] Restore target dropped or snapshot discarded after evidence recorded

## Restrictions

- Do NOT restore PROD backup to the PROD instance itself.
- Do NOT allow the restore-target to be network-accessible after the drill.
- Do NOT retain a live copy of PROD data beyond the drill window.
