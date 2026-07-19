-- =============================================================================
-- Access Review Tool 01: Active Users per Tenant
-- Read-only. Run against the target environment with appropriate credentials.
-- Evidence: export results to CSV and attach to access-review report.
-- =============================================================================
SET NOCOUNT ON;
GO

PRINT 'Access Review: 01 - Active users per tenant';

SELECT
    t.tenant_code                           AS tenant_code,
    t.display_name                          AS tenant_display_name,
    u.email                                 AS user_email,
    u.display_name                          AS display_name,
    u.is_active                             AS is_active,
    u.created_at_utc                        AS created_at_utc,
    u.last_login_at_utc                     AS last_login_at_utc,
    DATEDIFF(DAY, u.last_login_at_utc, SYSUTCDATETIME()) AS days_since_last_login
FROM core.AppUser u
INNER JOIN core.Tenant t ON t.tenant_id = u.tenant_id
WHERE u.is_active = 1
ORDER BY t.tenant_code, u.email;
GO

PRINT 'Access Review: 02 - Inactive users (active flag = 0, review for cleanup)';

SELECT
    t.tenant_code,
    u.email,
    u.display_name,
    u.is_active,
    u.created_at_utc,
    u.last_login_at_utc
FROM core.AppUser u
INNER JOIN core.Tenant t ON t.tenant_id = u.tenant_id
WHERE u.is_active = 0
ORDER BY t.tenant_code, u.email;
GO

PRINT 'Access Review: 03 - Users not logged in for 90+ days (stale accounts)';

SELECT
    t.tenant_code,
    u.email,
    u.display_name,
    u.last_login_at_utc,
    DATEDIFF(DAY, u.last_login_at_utc, SYSUTCDATETIME()) AS days_inactive
FROM core.AppUser u
INNER JOIN core.Tenant t ON t.tenant_id = u.tenant_id
WHERE u.is_active = 1
  AND (u.last_login_at_utc IS NULL OR u.last_login_at_utc < DATEADD(DAY, -90, SYSUTCDATETIME()))
ORDER BY days_inactive DESC;
GO
