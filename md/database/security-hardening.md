# Security Hardening

This guide lists the minimum hardening controls for a professional SQL Server
and SSMS-first Yafes Pars deployment.

## Secrets

- Do not commit passwords, tokens, connection strings, certificates, or backup
  files.
- Use environment variables, secret stores, or deployment tooling for secrets.
- Rotate any credential that was pasted into chat, tickets, logs, or source.
- Mask secrets in CI logs.

## Windows Server

- Keep Windows Server patched.
- Restrict local administrators.
- Use named service accounts for SQL Server services.
- Disable unused services.
- Restrict RDP with network rules and just-in-time access where available.
- Enable endpoint protection and event forwarding.

## SQL Server Instance

- Apply approved SQL Server cumulative updates.
- Disable or restrict `sa`.
- Use least-privilege logins.
- Remove unused sample databases.
- Restrict linked servers and external access features unless approved.
- Configure maximum server memory.
- Review SQL Server Error Log after every deployment.

## Database Access

- Separate deployment, application, support, and read-only access.
- Grant only required permissions.
- Keep tenant-aware tables protected from broad ad hoc updates.
- Use stored procedure bridges for guided create operations.
- Use rollback-by-default scripts for manual data correction.

## Tenant Isolation

Business root tables must include `tenant_id`. Query templates and dashboard
scripts must require tenant context for operator workflows. Cross-tenant joins
must be explicit and reviewed.

## RBAC

The platform uses:

- `core.Role`
- `core.Permission`
- `core.RolePermission`
- `core.UserRole`

Production roles should be reviewed before go-live and after each release that
changes permissions.

## Audit

Audit triggers write key root table changes to `audit.AuditLog`. Production
operations should also record:

- release owner
- execution timestamp
- target environment
- changed scripts
- validation status
- incident or rollback decision

## CI And Repository Controls

- Use branch protection for production release branches.
- Require pull request review for database changes.
- Require SQL quality gate and SQL Server validation workflows.
- Keep Dependabot enabled for GitHub Actions and NuGet.
- Keep `SECURITY.md` current.
