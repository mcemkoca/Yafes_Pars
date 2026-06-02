/*
    Yafes Pars SSMS Operator Query

    INFO TIP:
    Copy this header into new SSMS operator scripts. Keep SQLCMD Mode enabled
    and never remove the DEV target check for scripts that can change data.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE "DEMO-BE-BROKER"

SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

DECLARE @TenantCode NVARCHAR(80) = N'$(TENANT_CODE)';
DECLARE @TenantId UNIQUEIDENTIFIER;

SELECT @TenantId = tenant_id
FROM core.Tenant
WHERE tenant_code = @TenantCode;

IF @TenantId IS NULL
    THROW 52900, 'Tenant code was not found.', 1;

PRINT 'INFO TIP: Add query body below this line.';
