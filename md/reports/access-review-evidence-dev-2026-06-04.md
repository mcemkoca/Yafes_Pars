# Access Review Evidence - DEV - 2026-06-04

## Summary

| Field | Value |
| --- | --- |
| Environment | DEV local ephemeral SQL Server container |
| Database reviewed | `YafesPars_RESTORE_DEV` |
| Evidence date | 2026-06-04 |
| Source script | `database/ssms/14__admin_role_permission_matrix.sql` |
| Tenant code | `DEV-BE-BROKER` |
| Tenant display name | Yafes Broker Operations |
| Result | PASS |

## RBAC Signals

| Signal | Value |
| --- | --- |
| Expected system roles present | 4 |
| Active permissions present | 18 |
| Active DEV sample users present | 3 |
| Admin matrix execution | PASS |
| Least-privilege checklist execution | PASS |

## Role Review

| Role | Expected use | DEV evidence |
| --- | --- | --- |
| `SYSTEM_ADMIN` | Platform/database administration only | Present; all active permissions covered. |
| `BROKER_ADMIN` | Tenant administration | Present; operations admin user assigned. |
| `BROKER_USER` | Daily broker operation | Present; broker operator user assigned. |
| `CLAIM_HANDLER` | Claim handling | Present; claims specialist user assigned. |

## Decision

DEV access review evidence is acceptable for the current SSMS-first product
baseline. TEST/PROD access review still requires environment-specific evidence
with named operators, approved SQL logins or Windows groups, and formal sign-off.
