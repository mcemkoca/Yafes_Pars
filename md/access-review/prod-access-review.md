# PROD Access Review Template

**Environment:** PROD
**Status:** PENDING ENVIRONMENT EXECUTION — BLOCKED BY ENVIRONMENT ACCESS
**Owner:** Deuterium12{MCK}

> PROD access review requires additional sign-off. A second named approver
> must co-sign the evidence. No query should be executed by the same person
> who performed the most recent user-provisioning action.

## Pre-conditions

- [ ] Reviewer is NOT the same person who last provisioned/deprovisioned a PROD user
- [ ] Change-request ticket number recorded below
- [ ] Reviewer has read-only PROD access (no write permissions during review)
- [ ] Review window is logged in the change-management system

## Review Details

| Field | Value |
|-------|-------|
| Environment | PROD |
| Review Date | _(fill at execution)_ |
| Reviewer | _(fill at execution)_ |
| Second Approver | _(fill at execution)_ |
| Change Request # | _(fill at execution)_ |
| SQL Server Instance | _(fill at execution)_ |

## Steps

Follow the same steps as `test-access-review.md` but against the PROD instance.

## PROD-Specific Additional Checks

| Check | Result | Pass/Fail |
|-------|--------|-----------|
| No DEV or TEST service accounts exist in PROD | | |
| External contractor accounts are time-boxed (expiry set) | | |
| Last access-review date is ≤ 90 days ago | | |

## Sign-off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Reviewer | | | |
| Primary Approver | | | |
| Security Approver | | | |

## Evidence Attachments

- [ ] `01__list_active_users_PROD_YYYY-MM-DD.csv`
- [ ] `02__role_permission_matrix_PROD_YYYY-MM-DD.csv`
- [ ] `03__sod_check_PROD_YYYY-MM-DD.csv`
- [ ] Change-management ticket link
