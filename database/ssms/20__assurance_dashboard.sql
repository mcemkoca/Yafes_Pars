/*
    Yafes Pars SSMS Workbench - Assurance Dashboard

    INFO TIP:
    Visual preview screens are not execution tools. Run this file in SSMS with
    SQLCMD Mode enabled against a DEV database to get real Results Grid data.

    Enable SQLCMD Mode before running.
    Read-heavy dashboard; scan procedures insert assurance findings.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE "DEV-BE-BROKER"

SET NOCOUNT ON;
GO

USE [master];
GO

DECLARE @TargetDatabase SYSNAME = N'$(YAFES_SQL_DATABASE)';
IF @TargetDatabase NOT LIKE N'%DEV%'
    THROW 52020, 'Target database name must contain DEV.', 1;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

DECLARE @TenantCode NVARCHAR(80) = N'$(TENANT_CODE)';
DECLARE @TenantId UNIQUEIDENTIFIER;

SELECT @TenantId = tenant_id
FROM core.Tenant
WHERE tenant_code = @TenantCode;

IF @TenantId IS NULL
    THROW 52200, 'Tenant code was not found.', 1;

PRINT '01 - Assurance KPI dashboard';
EXEC assurance.SP_GetAssuranceDashboard @tenant_id = @TenantId;

PRINT '02 - Latest SQL review requests';
EXEC assurance.SP_GetSqlReviewRequests @tenant_id = @TenantId, @limit = 50;

PRINT '03 - Latest risk findings';
EXEC assurance.SP_GetSqlRiskFindings @tenant_id = @TenantId, @sql_review_request_id = NULL;

PRINT '04 - Latest compliance findings';
EXEC assurance.SP_GetComplianceFindings @tenant_id = @TenantId, @limit = 100;

PRINT '05 - Open permission drift findings';
EXEC assurance.SP_GetPermissionDriftFindings @tenant_id = @TenantId;
GO
