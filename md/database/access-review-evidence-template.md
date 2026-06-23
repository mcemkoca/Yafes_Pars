# Access Review Evidence Template

Use this template when recording DEV, TEST, or PROD-like access review evidence.
The active SSMS workbench scripts are guarded for DEV execution. TEST/PROD
evidence must be collected through an approved environment procedure and must
not bypass production change control.

## Summary

| Field | Value |
| --- | --- |
| Environment |  |
| Database |  |
| Review date/time UTC |  |
| Reviewer |  |
| Approver |  |
| Commit SHA / release |  |
| Evidence location |  |

## Required Evidence

| Evidence | Source | Result | Notes |
| --- | --- | --- | --- |
| Expected role coverage | `14__admin_role_permission_matrix.sql` result set 02 or approved environment equivalent |  |  |
| Role permission matrix | `14__admin_role_permission_matrix.sql` result set 03 or approved environment equivalent |  |  |
| Permission module coverage | `14__admin_role_permission_matrix.sql` result set 04 or approved environment equivalent |  |  |
| Tenant user role assignments | `14__admin_role_permission_matrix.sql` result set 05 or approved environment equivalent |  |  |
| Least-privilege checklist | `14__admin_role_permission_matrix.sql` result set 06 or approved environment equivalent |  |  |
| Audit/security technical checks | `04__admin_security_audit_queries.sql` result sets or approved environment equivalent |  |  |

## Role Review

| Role | Expected owner | Approved use | Exception |
| --- | --- | --- | --- |
| `SYSTEM_ADMIN` | Platform/database owner | Emergency/platform administration only |  |
| `BROKER_ADMIN` | Tenant admin | Broker office administration |  |
| `BROKER_USER` | Daily operator | Read-focused daily broker work |  |
| `CLAIM_HANDLER` | Claims team | Claim handling and document work |  |

## User Assignment Review

| User | Role(s) | Status | Decision | Notes |
| --- | --- | --- | --- | --- |
|  |  |  | Keep / Remove / Change |  |

## Sign-Off

| Field | Value |
| --- | --- |
| Access accepted |  |
| Exceptions accepted |  |
| Follow-up tasks |  |
| Reviewer sign-off |  |
| Approver sign-off |  |
