# TEST Access Review Template

**Environment:** TEST
**Status:** PENDING ENVIRONMENT EXECUTION
**Owner:** Deuterium12{MCK}

> Evidence must be collected by an authorized operator with TEST database
> access. This template defines the procedure and required evidence fields.

## Pre-conditions

- [ ] Reviewer has read-only access to the TEST SQL Server instance
- [ ] Review date and reviewer name have been recorded below
- [ ] No DDL or DML will be executed during this review

## Review Details

| Field | Value |
|-------|-------|
| Environment | TEST |
| Review Date | _(fill at execution)_ |
| Reviewer | _(fill at execution)_ |
| SQL Server Instance | _(fill at execution)_ |
| Database Name | YafesPars |

## Step 1 — Active Users

Run: `database/tools/access-review/01__list_active_users.sql`

| Check | Result | Pass/Fail |
|-------|--------|-----------|
| All active users have a named individual associated | | |
| No service accounts in active user list (except approved) | | |
| No accounts inactive for 90+ days without sign-off | | |

Attach exported CSV as evidence.

## Step 2 — Role-Permission Matrix

Run: `database/tools/access-review/02__role_permission_matrix.sql`

| Check | Result | Pass/Fail |
|-------|--------|-----------|
| All assigned roles appear in the approved role list | | |
| No users hold roles beyond their job function | | |
| Orphan accounts (users with no role) investigated | | |

## Step 3 — Segregation of Duties

Run: `database/tools/access-review/03__segregation_of_duties_check.sql`

| Check | Result | Pass/Fail |
|-------|--------|-----------|
| No user holds both CLAIM_HANDLER and CLAIM_APPROVER | | |
| No user holds both FINANCE_ENTRY and FINANCE_APPROVAL | | |
| Admin user count per tenant is ≤ 2 | | |

## Sign-off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Reviewer | | | |
| Approver | | | |

## Evidence Attachments

- [ ] `01__list_active_users_TEST_YYYY-MM-DD.csv`
- [ ] `02__role_permission_matrix_TEST_YYYY-MM-DD.csv`
- [ ] `03__sod_check_TEST_YYYY-MM-DD.csv`
