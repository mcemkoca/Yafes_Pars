# Security And Audit

## Purpose

Review RBAC, role permissions, tenant user assignments, least-privilege checks,
audit triggers, audit logs, and open integrity issues.

## Main Script

Use:

```text
database/ssms/14__admin_role_permission_matrix.sql
database/ssms/04__admin_security_audit_queries.sql
```

## What To Review

- Expected system role coverage
- Role/permission matrix
- Tenant user role assignments
- Least-privilege checklist
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
- before assigning admin or broker roles

## Info Tips

- Security review should be read-only.
- Start with `14__admin_role_permission_matrix.sql` for human-friendly RBAC,
  then run `04__admin_security_audit_queries.sql` for technical audit evidence.
- Do not paste credentials into SSMS query tabs.
- Use `SECURITY.md` for repository-level vulnerability handling.
