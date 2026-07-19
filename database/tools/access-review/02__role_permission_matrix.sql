-- =============================================================================
-- Access Review Tool 02: Role–Permission Matrix
-- Read-only. Shows which roles have which permissions.
-- Evidence: export to CSV and attach to access-review report.
-- =============================================================================
SET NOCOUNT ON;
GO

USE [YafesPars];
GO

PRINT 'Access Review: 01 - Role list';

SELECT
    r.role_code,
    r.role_name,
    r.is_active,
    r.created_at_utc
FROM core.AppRole r
ORDER BY r.role_code;
GO

PRINT 'Access Review: 02 - Permission list';

SELECT
    p.permission_code,
    p.permission_name,
    p.module_code,
    p.is_active
FROM core.Permission p
ORDER BY p.module_code, p.permission_code;
GO

PRINT 'Access Review: 03 - Role-permission assignments';

SELECT
    r.role_code,
    r.role_name,
    p.module_code,
    p.permission_code,
    p.permission_name,
    rp.granted_at_utc
FROM core.RolePermission rp
INNER JOIN core.AppRole   r ON r.role_id      = rp.role_id
INNER JOIN core.Permission p ON p.permission_id = rp.permission_id
ORDER BY r.role_code, p.module_code, p.permission_code;
GO

PRINT 'Access Review: 04 - User-role assignments';

SELECT
    t.tenant_code,
    u.email,
    r.role_code,
    r.role_name,
    ur.assigned_at_utc
FROM core.UserRole ur
INNER JOIN core.AppUser   u ON u.user_id   = ur.user_id
INNER JOIN core.AppRole   r ON r.role_id   = ur.role_id
INNER JOIN core.Tenant    t ON t.tenant_id = u.tenant_id
ORDER BY t.tenant_code, u.email, r.role_code;
GO

PRINT 'Access Review: 05 - Users with no role assignment (orphan accounts)';

SELECT
    t.tenant_code,
    u.email,
    u.display_name,
    u.is_active
FROM core.AppUser u
INNER JOIN core.Tenant t ON t.tenant_id = u.tenant_id
WHERE NOT EXISTS (
    SELECT 1 FROM core.UserRole ur WHERE ur.user_id = u.user_id
)
ORDER BY t.tenant_code, u.email;
GO
