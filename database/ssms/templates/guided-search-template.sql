/*
    Guided Search Template

    INFO TIP:
    Read-only search pattern. Use this before any edit bridge action.
    Keep SQLCMD Mode enabled and run only against a DEV database.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE "DEV-BE-BROKER"
:setvar SEARCH_TEXT ""
:setvar TOP_ROWS "100"

SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

IF DB_NAME() NOT LIKE N'%DEV%'
    THROW 52911, 'Current database name must contain DEV.', 1;

DECLARE @TenantId UNIQUEIDENTIFIER;
DECLARE @SearchText NVARCHAR(160) = NULLIF(N'$(SEARCH_TEXT)', N'');
DECLARE @TopRows INT = TRY_CONVERT(INT, N'$(TOP_ROWS)');

IF @TopRows IS NULL OR @TopRows < 1 OR @TopRows > 1000
    SET @TopRows = 100;

SELECT @TenantId = tenant_id
FROM core.Tenant
WHERE tenant_code = N'$(TENANT_CODE)';

IF @TenantId IS NULL
    THROW 52910, 'Tenant code was not found.', 1;

SELECT TOP (@TopRows)
    person_id,
    dossier,
    first_name,
    last_name,
    primary_email,
    primary_phone,
    N'INFO TIP: Copy person_id into bridge templates; do not retype GUIDs.' AS info_tip
FROM person.VW_CustomerSummary
WHERE tenant_id = @TenantId
  AND (
        @SearchText IS NULL
     OR dossier LIKE N'%' + @SearchText + N'%'
     OR first_name LIKE N'%' + @SearchText + N'%'
     OR last_name LIKE N'%' + @SearchText + N'%'
     OR primary_email LIKE N'%' + @SearchText + N'%'
  )
ORDER BY updated_at_utc DESC;
GO
