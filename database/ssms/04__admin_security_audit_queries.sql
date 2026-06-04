/*
    Yafes Pars SSMS Workbench - Admin, Security, Audit

    INFO TIP:
    Use this SSMS Results Grid pack for real RBAC, audit, trigger, and data
    quality checks. The local preview is visual only.

    Enable SQLCMD Mode before running.
    This script is read-only.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE "DEV-BE-BROKER"

SET NOCOUNT ON;
GO

USE [master];
GO

DECLARE @TargetDatabase SYSNAME = N'$(YAFES_SQL_DATABASE)';
DECLARE @ServerName NVARCHAR(256) = LOWER(CONVERT(NVARCHAR(256), @@SERVERNAME));
DECLARE @MachineName NVARCHAR(256) = LOWER(CONVERT(NVARCHAR(256), SERVERPROPERTY('MachineName')));

IF @TargetDatabase NOT LIKE N'%DEV%'
    THROW 52040, 'Target database name must contain DEV.', 1;

IF @ServerName LIKE N'%prod%' OR @ServerName LIKE N'%production%' OR @ServerName LIKE N'%prd%' OR @ServerName LIKE N'%live%'
    THROW 52041, 'Connected server name suggests production/live.', 1;

IF @MachineName LIKE N'%prod%' OR @MachineName LIKE N'%production%' OR @MachineName LIKE N'%prd%' OR @MachineName LIKE N'%live%'
    THROW 52042, 'Connected machine name suggests production/live.', 1;

IF DB_ID(@TargetDatabase) IS NULL
    THROW 52043, 'Target DEV database does not exist.', 1;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

DECLARE @TenantCode NVARCHAR(80) = N'$(TENANT_CODE)';
DECLARE @TenantId UNIQUEIDENTIFIER;

SELECT @TenantId = tenant_id
FROM core.Tenant
WHERE tenant_code = @TenantCode;

IF @TenantId IS NULL
    THROW 52044, 'Tenant code was not found.', 1;

PRINT '01 - Users and roles';
SELECT
    u.tenant_id,
    u.user_id,
    u.email,
    u.display_name,
    r.role_code,
    r.role_name,
    u.is_active
FROM core.AppUser u
LEFT JOIN core.UserRole ur
    ON ur.user_id = u.user_id
LEFT JOIN core.Role r
    ON r.role_id = ur.role_id
WHERE u.tenant_id = @TenantId
ORDER BY u.email, r.role_code;

PRINT '02 - Role permissions';
SELECT
    r.role_code,
    p.permission_code,
    p.module_code,
    p.permission_name
FROM core.Role r
INNER JOIN core.RolePermission rp
    ON rp.role_id = r.role_id
INNER JOIN core.Permission p
    ON p.permission_code = rp.permission_code
ORDER BY r.role_code, p.module_code, p.permission_code;

PRINT '03 - Audit trigger inventory';
SELECT
    s.name AS schema_name,
    o.name AS table_name,
    tr.name AS trigger_name,
    tr.is_disabled
FROM sys.triggers tr
INNER JOIN sys.objects o
    ON o.object_id = tr.parent_id
INNER JOIN sys.schemas s
    ON s.schema_id = o.schema_id
WHERE tr.name LIKE N'TR[_]%[_]Audit'
ORDER BY s.name, o.name, tr.name;

PRINT '04 - Recent audit events';
SELECT TOP (100)
    audit_log_id,
    tenant_id,
    schema_name,
    table_name,
    primary_key_value,
    action_type,
    changed_at_utc,
    changed_by_name,
    source_system,
    correlation_id
FROM audit.AuditLog
WHERE tenant_id = @TenantId
ORDER BY changed_at_utc DESC, audit_log_id DESC;

PRINT '05 - Open validation issues: active package without item';
SELECT
    cp.package_code,
    cp.contract_domain_code,
    cp.package_name
FROM coverage.CoveragePackage cp
WHERE cp.is_active = 1
  AND NOT EXISTS (
        SELECT 1
        FROM coverage.CoveragePackageItem cpi
        WHERE cpi.coverage_package_id = cp.coverage_package_id
  );

PRINT '06 - Open validation issues: active coverage without domain';
SELECT
    c.coverage_code,
    c.label_nl
FROM coverage.Coverage c
WHERE c.is_active = 1
  AND NOT EXISTS (
        SELECT 1
        FROM coverage.CoverageDomain cd
        WHERE cd.coverage_code = c.coverage_code
  );

PRINT '07 - Open validation issues: task assignee outside tenant';
SELECT
    t.task_id,
    t.tenant_id AS task_tenant_id,
    t.assigned_to_user_id,
    u.tenant_id AS user_tenant_id,
    t.title
FROM tasking.Task t
INNER JOIN core.AppUser u
    ON u.user_id = t.assigned_to_user_id
WHERE t.assigned_to_user_id IS NOT NULL
  AND t.tenant_id <> u.tenant_id;
GO
