/*
    Yafes Pars SSMS Workbench - Compliance Control Matrix

    Runs sensitive column and compliance scans.
    Enable SQLCMD Mode before running.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE "DEV-BE-BROKER"

SET NOCOUNT ON;
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
