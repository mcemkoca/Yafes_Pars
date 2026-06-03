/*
    Report Grid Template

    INFO TIP:
    Return chart_axis and chart_value columns so the result can be copied to
    Excel or Power BI without reshaping.
    Keep SQLCMD Mode enabled and run only against a DEV database.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE "DEMO-BE-BROKER"

SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

IF DB_NAME() NOT LIKE N'%DEV%'
    THROW 52931, 'Current database name must contain DEV.', 1;

DECLARE @TenantId UNIQUEIDENTIFIER;

SELECT @TenantId = tenant_id
FROM core.Tenant
WHERE tenant_code = N'$(TENANT_CODE)';

IF @TenantId IS NULL
    THROW 52930, 'Tenant code was not found.', 1;

SELECT
    contract_status_code AS chart_axis,
    COUNT_BIG(*) AS chart_value,
    N'INFO TIP: Use chart_axis/chart_value for quick Excel charts.' AS info_tip
FROM policy.Contract
WHERE tenant_id = @TenantId
  AND is_deleted = 0
GROUP BY contract_status_code
ORDER BY chart_value DESC;
GO
