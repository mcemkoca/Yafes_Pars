/*
    Yafes Pars SSMS Workbench - Admin Role Permission Matrix

    INFO TIP:
    Run this read-only matrix before assigning users, approving admin access,
    or preparing TEST/PROD role evidence. It shows expected roles, permissions,
    user assignments, and least-privilege control points from the real core
    security tables.

    Enable SQLCMD Mode before running.
    This script is read-only.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE "DEMO-BE-BROKER"

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET QUOTED_IDENTIFIER ON;
GO

USE [master];
GO

DECLARE @TargetDatabase SYSNAME = N'$(YAFES_SQL_DATABASE)';
DECLARE @ServerName NVARCHAR(256) = LOWER(CONVERT(NVARCHAR(256), @@SERVERNAME));
DECLARE @MachineName NVARCHAR(256) = LOWER(CONVERT(NVARCHAR(256), SERVERPROPERTY('MachineName')));

IF @TargetDatabase NOT LIKE N'%DEV%'
    THROW 52140, 'Target database name must contain DEV.', 1;

IF @ServerName LIKE N'%prod%' OR @ServerName LIKE N'%production%' OR @ServerName LIKE N'%prd%' OR @ServerName LIKE N'%live%'
    THROW 52141, 'Connected server name suggests production/live.', 1;

IF @MachineName LIKE N'%prod%' OR @MachineName LIKE N'%production%' OR @MachineName LIKE N'%prd%' OR @MachineName LIKE N'%live%'
    THROW 52142, 'Connected machine name suggests production/live.', 1;

IF DB_ID(@TargetDatabase) IS NULL
    THROW 52143, 'Target DEV database does not exist.', 1;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

DECLARE @TenantCode NVARCHAR(80) = N'$(TENANT_CODE)';
DECLARE @TenantId UNIQUEIDENTIFIER;

SELECT @TenantId = tenant_id
FROM core.Tenant
WHERE tenant_code = @TenantCode;

IF @TenantId IS NULL
    THROW 52144, 'Tenant code was not found.', 1;

PRINT 'INFO TIP: Review this matrix before giving users new access. This script does not change data.';

PRINT '01 - Admin operating context';
SELECT
    DB_NAME() AS database_name,
    @TenantCode AS tenant_code,
    @TenantId AS tenant_id,
    SUSER_SNAME() AS login_name,
    SYSUTCDATETIME() AS checked_at_utc,
    (SELECT COUNT_BIG(*) FROM core.Role WHERE is_active = 1 AND (tenant_id IS NULL OR tenant_id = @TenantId)) AS visible_role_count,
    (SELECT COUNT_BIG(*) FROM core.Permission WHERE is_active = 1) AS active_permission_count,
    (SELECT COUNT_BIG(*) FROM core.AppUser WHERE tenant_id = @TenantId AND is_active = 1) AS active_user_count,
    N'INFO TIP: If tenant_code or database_name is unexpected, stop before changing any access.' AS info_tip;

PRINT '02 - Expected system role coverage';
WITH ExpectedRoles AS (
    SELECT *
    FROM (VALUES
        (10, N'SYSTEM_ADMIN', N'Platform owner', N'All active permissions; never assign casually.'),
        (20, N'BROKER_ADMIN', N'Broker office admin', N'Person, institution, risk, policy, claim, document, lookup, and user management.'),
        (30, N'BROKER_USER', N'Daily broker operator', N'Read-only customer, institution, risk, policy, claim, and document visibility.'),
        (40, N'CLAIM_HANDLER', N'Claims operator', N'Claim read/write/close and document handling.')
    ) AS er(role_order, role_code, expected_operator_profile, expected_permission_shape)
)
SELECT
    er.role_order,
    er.role_code,
    er.expected_operator_profile,
    er.expected_permission_shape,
    CASE WHEN r.role_id IS NULL THEN N'MISSING' ELSE N'OK' END AS role_status,
    COUNT(DISTINCT rp.permission_code) AS permission_count,
    CASE
        WHEN r.role_id IS NULL THEN N'Create or reseed lookup/security data before using this role.'
        WHEN COUNT(DISTINCT rp.permission_code) = 0 THEN N'Role exists but has no permissions.'
        ELSE N'INFO TIP: Review permission rows in result set 03 before assigning users.'
    END AS info_tip
FROM ExpectedRoles er
LEFT JOIN core.Role r
    ON r.tenant_id IS NULL
   AND r.role_code = er.role_code
   AND r.is_active = 1
LEFT JOIN core.RolePermission rp
    ON rp.role_id = r.role_id
GROUP BY er.role_order, er.role_code, er.expected_operator_profile, er.expected_permission_shape, r.role_id
ORDER BY er.role_order;

PRINT '03 - Role permission matrix';
SELECT
    r.role_code,
    r.role_name,
    CASE WHEN r.tenant_id IS NULL THEN N'SYSTEM' ELSE N'TENANT' END AS role_scope,
    p.module_code,
    p.permission_code,
    p.permission_name,
    CASE
        WHEN p.permission_code LIKE N'admin.%' THEN N'ADMIN'
        WHEN p.permission_code LIKE N'%.write' OR p.permission_code LIKE N'%upload%' OR p.permission_code LIKE N'%close%' OR p.permission_code LIKE N'%.create' THEN N'WRITE'
        WHEN p.permission_code LIKE N'%.read' OR p.permission_code LIKE N'%read' THEN N'READ'
        ELSE N'ACTION'
    END AS access_weight,
    N'INFO TIP: Assign the smallest role that covers the operator task.' AS info_tip
FROM core.Role r
INNER JOIN core.RolePermission rp
    ON rp.role_id = r.role_id
INNER JOIN core.Permission p
    ON p.permission_code = rp.permission_code
WHERE r.is_active = 1
  AND p.is_active = 1
  AND (r.tenant_id IS NULL OR r.tenant_id = @TenantId)
ORDER BY r.role_code, p.module_code, p.permission_code;

PRINT '04 - Permission module coverage';
WITH PermissionCoverage AS (
    SELECT
        p.module_code,
        p.permission_code,
        CASE WHEN p.permission_code LIKE N'admin.%' THEN 1 ELSE 0 END AS is_admin_permission,
        CASE WHEN EXISTS (
            SELECT 1
            FROM core.RolePermission rp
            INNER JOIN core.Role r
                ON r.role_id = rp.role_id
            WHERE rp.permission_code = p.permission_code
              AND r.is_active = 1
              AND (r.tenant_id IS NULL OR r.tenant_id = @TenantId)
        ) THEN 1 ELSE 0 END AS is_assigned_to_visible_role
    FROM core.Permission p
    WHERE p.is_active = 1
)
SELECT
    pc.module_code,
    COUNT_BIG(*) AS active_permission_count,
    SUM(pc.is_admin_permission) AS admin_permission_count,
    SUM(CASE WHEN pc.is_assigned_to_visible_role = 1 THEN 0 ELSE 1 END) AS unassigned_permission_count,
    N'INFO TIP: Unassigned active permissions need owner review before TEST/PROD promotion.' AS info_tip
FROM PermissionCoverage pc
GROUP BY pc.module_code
ORDER BY pc.module_code;

PRINT '05 - Tenant user role assignments';
SELECT
    u.email,
    u.display_name,
    u.is_active,
    COALESCE(STRING_AGG(CONVERT(NVARCHAR(MAX), r.role_code), N', '), N'NO_ROLE') AS role_codes,
    COUNT(DISTINCT rp.permission_code) AS effective_permission_count,
    CASE
        WHEN u.is_active = 0 THEN N'INACTIVE'
        WHEN COUNT(DISTINCT r.role_id) = 0 THEN N'REVIEW'
        WHEN MAX(CASE WHEN r.role_code IN (N'SYSTEM_ADMIN', N'BROKER_ADMIN') THEN 1 ELSE 0 END) = 1 THEN N'ADMIN_REVIEW'
        ELSE N'OK'
    END AS assignment_status,
    N'INFO TIP: Admin roles should have an approval trail outside this script.' AS info_tip
FROM core.AppUser u
LEFT JOIN core.UserRole ur
    ON ur.user_id = u.user_id
LEFT JOIN core.Role r
    ON r.role_id = ur.role_id
LEFT JOIN core.RolePermission rp
    ON rp.role_id = r.role_id
WHERE u.tenant_id = @TenantId
GROUP BY u.email, u.display_name, u.is_active
ORDER BY assignment_status DESC, u.email;

PRINT '06 - Least privilege checklist';
SELECT
    check_order,
    control_area,
    expected_rule,
    observed_signal,
    check_status,
    admin_action,
    info_tip
FROM (
    SELECT
        10 AS check_order,
        N'SYSTEM_ADMIN' AS control_area,
        N'SYSTEM_ADMIN has every active permission.' AS expected_rule,
        CONVERT(NVARCHAR(40), (
            SELECT COUNT_BIG(*)
            FROM core.Permission p
            WHERE p.is_active = 1
              AND NOT EXISTS (
                    SELECT 1
                    FROM core.Role r
                    INNER JOIN core.RolePermission rp
                        ON rp.role_id = r.role_id
                    WHERE r.tenant_id IS NULL
                      AND r.role_code = N'SYSTEM_ADMIN'
                      AND rp.permission_code = p.permission_code
              )
        )) + N' missing permission(s)' AS observed_signal,
        CASE WHEN NOT EXISTS (
            SELECT 1
            FROM core.Permission p
            WHERE p.is_active = 1
              AND NOT EXISTS (
                    SELECT 1
                    FROM core.Role r
                    INNER JOIN core.RolePermission rp
                        ON rp.role_id = r.role_id
                    WHERE r.tenant_id IS NULL
                      AND r.role_code = N'SYSTEM_ADMIN'
                      AND rp.permission_code = p.permission_code
              )
        ) THEN N'OK' ELSE N'REVIEW' END AS check_status,
        N'Reseed security lookups if missing permissions are not intentional.' AS admin_action,
        N'INFO TIP: SYSTEM_ADMIN should be rare and audited.' AS info_tip
    UNION ALL
    SELECT
        20,
        N'BROKER_USER',
        N'BROKER_USER has no write or admin permissions.',
        CONVERT(NVARCHAR(40), COUNT_BIG(*)) + N' elevated permission(s)',
        CASE WHEN COUNT_BIG(*) = 0 THEN N'OK' ELSE N'REVIEW' END,
        N'Remove write/admin permissions or use BROKER_ADMIN for approved admins.',
        N'INFO TIP: Daily operators should start from read-only visibility.'
    FROM core.Role r
    INNER JOIN core.RolePermission rp
        ON rp.role_id = r.role_id
    WHERE r.tenant_id IS NULL
      AND r.role_code = N'BROKER_USER'
      AND (rp.permission_code LIKE N'admin.%' OR rp.permission_code LIKE N'%.write' OR rp.permission_code LIKE N'%upload%' OR rp.permission_code LIKE N'%close%' OR rp.permission_code LIKE N'%.create')
    UNION ALL
    SELECT
        30,
        N'CLAIM_HANDLER',
        N'CLAIM_HANDLER can close claims and handle documents.',
        CASE WHEN EXISTS (
            SELECT 1
            FROM core.Role r
            INNER JOIN core.RolePermission rp
                ON rp.role_id = r.role_id
            WHERE r.tenant_id IS NULL
              AND r.role_code = N'CLAIM_HANDLER'
              AND rp.permission_code = N'claim.close'
        ) THEN N'claim.close present' ELSE N'claim.close missing' END,
        CASE WHEN EXISTS (
            SELECT 1
            FROM core.Role r
            INNER JOIN core.RolePermission rp
                ON rp.role_id = r.role_id
            WHERE r.tenant_id IS NULL
              AND r.role_code = N'CLAIM_HANDLER'
              AND rp.permission_code = N'claim.close'
        ) THEN N'OK' ELSE N'REVIEW' END,
        N'Reseed or update role permissions before claims go live.',
        N'INFO TIP: Claim closure should be role-controlled.'
    UNION ALL
    SELECT
        40,
        N'Tenant admin assignment',
        N'At least one active tenant user has BROKER_ADMIN.',
        CONVERT(NVARCHAR(40), COUNT_BIG(*)) + N' active broker admin user(s)',
        CASE WHEN COUNT_BIG(*) >= 1 THEN N'OK' ELSE N'REVIEW' END,
        N'Assign BROKER_ADMIN to an approved active tenant admin.',
        N'INFO TIP: DEV tenant should always have one owner for operator support.'
    FROM core.AppUser u
    INNER JOIN core.UserRole ur
        ON ur.user_id = u.user_id
    INNER JOIN core.Role r
        ON r.role_id = ur.role_id
    WHERE u.tenant_id = @TenantId
      AND u.is_active = 1
      AND r.role_code = N'BROKER_ADMIN'
    UNION ALL
    SELECT
        50,
        N'Inactive users',
        N'Inactive users should not keep active role assignments.',
        CONVERT(NVARCHAR(40), COUNT_BIG(*)) + N' inactive user role assignment(s)',
        CASE WHEN COUNT_BIG(*) = 0 THEN N'OK' ELSE N'REVIEW' END,
        N'Remove roles from inactive users or confirm offboarding evidence.',
        N'INFO TIP: Use this before TEST/PROD access reviews.'
    FROM core.AppUser u
    INNER JOIN core.UserRole ur
        ON ur.user_id = u.user_id
    WHERE u.tenant_id = @TenantId
      AND u.is_active = 0
) AS checks
ORDER BY check_order;

PRINT '07 - Admin handoff scripts';
SELECT
    handoff_order,
    open_script,
    purpose,
    safety_mode,
    admin_rule,
    info_tip
FROM (VALUES
    (10, N'database/ssms/04__admin_security_audit_queries.sql', N'RBAC, audit trigger, audit log, and integrity checks', N'READ_ONLY', N'Run after role matrix review.', N'INFO TIP: Use for technical security and audit evidence.'),
    (20, N'database/ssms/05__operator_dashboard_home.sql', N'Return to operator cockpit', N'READ_ONLY', N'Keep dashboard pinned.', N'INFO TIP: Home shows shortcuts and health signals.'),
    (30, N'database/ssms/08__data_editing_guardrails.sql', N'Rollback-default update patterns', N'ROLLBACK_DEFAULT', N'Use only after row-count review.', N'INFO TIP: Editing scripts should roll back until approved.'),
    (40, N'md/database/security-hardening.md', N'Environment hardening checklist', N'DOCUMENTATION', N'Use for TEST/PROD hardening.', N'INFO TIP: Commit only docs, not secrets or local evidence files.')
) AS h(handoff_order, open_script, purpose, safety_mode, admin_rule, info_tip)
ORDER BY handoff_order;
GO
