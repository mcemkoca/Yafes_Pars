# PROD Access Review Evidence

**Environment:** PROD  
**Status:** PENDING — BLOCKED BY PROD ACCESS  
**Owner:** Deuterium12{MCK}  
**Template version:** 2026-07-19

> **IMPORTANT:** PROD access review may only be performed by named DBA or
> authorized operator through an approved change-management window.
> Evidence must be collected without reading or extracting PII from PROD.

---

## Summary

| Field | Value |
|---|---|
| Environment | PROD |
| Database | |
| Review date/time UTC | |
| Reviewer (named) | |
| Approver (named) | |
| Change management ticket | |
| Commit SHA / release | |
| Scripts used | `01__list_active_users.sql`, `02__role_permission_matrix.sql`, `03__segregation_of_duties_check.sql` |

---

## Active Users (counts only — do not record PII)

| Metric | Value |
|---|---|
| Total active users | |
| Users with no role | (expected: 0) |
| Users inactive > 90 days | (flag for removal) |
| Tenants with active users | |

---

## Role Permission Matrix

| Role | Permission count | Admin perms | Notes |
|---|---|---|---|
| SYSTEM_ADMIN | | | |
| BROKER_ADMIN | | | |
| BROKER_USER | | | |
| CLAIM_HANDLER | | | |

---

## Segregation of Duties

| Check | Result | Approved exception? |
|---|---|---|
| CLAIM_APPROVE + CLAIM_CLOSE same user | | |
| PAYMENT_CREATE + PAYMENT_APPROVE same user | | |

---

## Role Review

| Role | Expected owner | Approved use | Exception |
|---|---|---|---|
| `SYSTEM_ADMIN` | Platform owner | Emergency/platform only | |
| `BROKER_ADMIN` | Tenant admin | Broker administration | |
| `BROKER_USER` | Daily operator | Daily broker work | |
| `CLAIM_HANDLER` | Claims team | Claim handling | |

---

## PROD-Specific Controls

| Control | Status | Notes |
|---|---|---|
| No developer has SYSTEM_ADMIN in PROD | | |
| Service accounts use least-privilege roles | | |
| No shared passwords or credentials | | |
| SQL logins use Windows Authentication or managed identity | | |
| Audit trail enabled for all DML | | |

---

## Sign-Off (TWO SIGNATORIES REQUIRED FOR PROD)

| Field | Value |
|---|---|
| Access accepted | |
| Exceptions accepted | |
| Follow-up tasks | |
| First signatory sign-off | |
| Second signatory sign-off | |
| Date | |
