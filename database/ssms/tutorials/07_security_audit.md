# Security And Audit

## Purpose

Review RBAC, audit triggers, audit logs, and open integrity issues.

## Main Script

Use:

```text
database/ssms/04__admin_security_audit_queries.sql
```

## What To Review

- Users and roles
- Role permissions
- Audit trigger inventory
- Recent audit events
- Active packages without coverage items
- Active coverage without domains
- Task assignees outside tenant

## Recommended Routine

Run this script:

- after migrations
- after bulk data entry
- before handoff
- when a user/role problem is suspected

## Info Tips

- Security review should be read-only.
- Do not paste credentials into SSMS query tabs.
- Use `SECURITY.md` for repository-level vulnerability handling.
