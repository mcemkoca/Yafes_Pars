# TEST Access Review Evidence

**Environment:** TEST  
**Status:** PENDING ENVIRONMENT EXECUTION  
**Owner:** Deuterium12{MCK}  
**Template version:** 2026-07-19

Fill in from `database/tools/access-review/` scripts run against the TEST instance.

---

## Summary

| Field | Value |
|---|---|
| Environment | TEST |
| Database | |
| Review date/time UTC | |
| Reviewer | |
| Approver | |
| Commit SHA / release | |
| Scripts used | `01__list_active_users.sql`, `02__role_permission_matrix.sql`, `03__segregation_of_duties_check.sql` |

---

## Active Users (from 01__list_active_users.sql)

| user_id | email | role_count | last_login_at_utc | tenant | Status |
|---|---|---|---|---|---|
| | | | | | |

Total active users: ______  
Users with no role: ______ (expected: 0)  
Users inactive > 90 days: ______ (flag for removal)

---

## Role Permission Matrix (from 02__role_permission_matrix.sql)

| Role | Permission count | Admin perms | Status |
|---|---|---|---|
| SYSTEM_ADMIN | | | |
| BROKER_ADMIN | | | |
| BROKER_USER | | | |
| CLAIM_HANDLER | | | |

---

## Segregation of Duties (from 03__segregation_of_duties_check.sql)

| Check | Result | Notes |
|---|---|---|
| Users with CLAIM_APPROVE + CLAIM_CLOSE | | (expected: 0 or approved exception) |
| Users with PAYMENT_CREATE + PAYMENT_APPROVE | | (expected: 0 or approved exception) |
| Users with ADMIN + CLAIM_HANDLE combined | | |

---

## Role Review

| Role | Expected owner | Approved use | Exception |
|---|---|---|---|
| `SYSTEM_ADMIN` | Platform owner | Emergency/platform administration only | |
| `BROKER_ADMIN` | Tenant admin | Broker office administration | |
| `BROKER_USER` | Daily operator | Read-focused daily broker work | |
| `CLAIM_HANDLER` | Claims team | Claim handling and document work | |

---

## User Assignment Review

| User | Role(s) | Status | Decision | Notes |
|---|---|---|---|---|
| | | | Keep / Remove / Change | |

---

## Sign-Off

| Field | Value |
|---|---|
| Access accepted | |
| Exceptions accepted | |
| Follow-up tasks | |
| Reviewer sign-off | |
| Approver sign-off | |
| Date | |
