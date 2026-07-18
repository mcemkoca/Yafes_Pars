/*
    Yafes Pars SSMS Workbench - Compliance Control Matrix

    INFO TIP:
    Visual preview screens are not execution tools. Run this file in SSMS with
    SQLCMD Mode enabled against a DEV database to get real Results Grid data.

    Runs sensitive column and compliance scans.
    Enable SQLCMD Mode before running.
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
    THROW 52022, 'Target database name must contain DEV.', 1;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

DECLARE @TenantId UNIQUEIDENTIFIER;
SELECT @TenantId = tenant_id FROM core.Tenant WHERE tenant_code = N'$(TENANT_CODE)';
IF @TenantId IS NULL THROW 52220, 'Tenant code was not found.', 1;

PRINT '01 - Sensitive column scan';
EXEC assurance.SP_RunSensitiveColumnScan @tenant_id = @TenantId;

PRINT '02 - Compliance scan';
EXEC assurance.SP_RunComplianceScan @tenant_id = @TenantId;

PRINT '03 - Compliance findings';
EXEC assurance.SP_GetComplianceFindings @tenant_id = @TenantId, @limit = 200;
GO
