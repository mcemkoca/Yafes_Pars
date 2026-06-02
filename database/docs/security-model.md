# Security Model

The database core will include tenant-aware infrastructure and RBAC-friendly
tables:

- `core.Tenant`
- `core.AppUser`
- `core.Role`
- `core.Permission`
- `core.RolePermission`
- `core.UserRole`

Business root tables should include `tenant_id`. Audit tables should preserve
who changed what, when possible, without storing application secrets.
