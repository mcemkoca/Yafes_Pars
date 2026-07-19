-- =============================================================================
-- Access Review Tool 03: Segregation of Duties (SoD) Check
-- Read-only. Identifies users who hold both sensitive role combinations.
-- Evidence: export to CSV and attach to access-review report.
-- =============================================================================
SET NOCOUNT ON;
GO

USE [YafesPars];
GO

PRINT 'SoD Check: 01 - Users with both CLAIM_HANDLER and CLAIM_APPROVER roles';

SELECT
    t.tenant_code,
    u.email,
    STRING_AGG(r.role_code, ', ') AS roles
FROM core.UserRole ur
INNER JOIN core.AppUser u ON u.user_id   = ur.user_id
INNER JOIN core.AppRole  r ON r.role_id   = ur.role_id
INNER JOIN core.Tenant   t ON t.tenant_id = u.tenant_id
WHERE r.role_code IN (N'CLAIM_HANDLER', N'CLAIM_APPROVER')
GROUP BY t.tenant_code, u.user_id, u.email
HAVING COUNT(DISTINCT r.role_code) >= 2
ORDER BY t.tenant_code, u.email;
GO

PRINT 'SoD Check: 02 - Users with both FINANCE_ENTRY and FINANCE_APPROVAL roles';

SELECT
    t.tenant_code,
    u.email,
    STRING_AGG(r.role_code, ', ') AS roles
FROM core.UserRole ur
INNER JOIN core.AppUser u ON u.user_id   = ur.user_id
INNER JOIN core.AppRole  r ON r.role_id   = ur.role_id
INNER JOIN core.Tenant   t ON t.tenant_id = u.tenant_id
WHERE r.role_code IN (N'FINANCE_ENTRY', N'FINANCE_APPROVAL')
GROUP BY t.tenant_code, u.user_id, u.email
HAVING COUNT(DISTINCT r.role_code) >= 2
ORDER BY t.tenant_code, u.email;
GO

PRINT 'SoD Check: 03 - Admin users count per tenant';

SELECT
    t.tenant_code,
    COUNT(DISTINCT u.user_id) AS admin_user_count
FROM core.UserRole ur
INNER JOIN core.AppUser u ON u.user_id   = ur.user_id
INNER JOIN core.AppRole  r ON r.role_id   = ur.role_id
INNER JOIN core.Tenant   t ON t.tenant_id = u.tenant_id
WHERE r.role_code LIKE N'%ADMIN%'
  AND u.is_active = 1
GROUP BY t.tenant_code
ORDER BY t.tenant_code;
GO
