/*
    Yafes Pars SSMS Workbench - Renewal Task Runner

    INFO TIP:
    Real renewal task work happens in SSMS, not the visual preview. Keep DRY_RUN = 1
    until candidates are reviewed in Results Grid.

    Enable SQLCMD Mode before running.
    Set DRY_RUN to 1 to preview candidates, 0 to insert tasks.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE "DEV-BE-BROKER"
:setvar DAYS_AHEAD "60"
:setvar DRY_RUN "1"

SET NOCOUNT ON;
GO

USE [master];
GO

DECLARE @TargetDatabase SYSNAME = N'$(YAFES_SQL_DATABASE)';
DECLARE @ServerName NVARCHAR(256) = LOWER(CONVERT(NVARCHAR(256), @@SERVERNAME));
DECLARE @MachineName NVARCHAR(256) = LOWER(CONVERT(NVARCHAR(256), SERVERPROPERTY('MachineName')));

IF @TargetDatabase NOT LIKE N'%DEV%'
    THROW 52030, 'Target database name must contain DEV.', 1;

IF @ServerName LIKE N'%prod%' OR @ServerName LIKE N'%production%' OR @ServerName LIKE N'%prd%' OR @ServerName LIKE N'%live%'
    THROW 52031, 'Connected server name suggests production/live.', 1;

IF @MachineName LIKE N'%prod%' OR @MachineName LIKE N'%production%' OR @MachineName LIKE N'%prd%' OR @MachineName LIKE N'%live%'
    THROW 52032, 'Connected machine name suggests production/live.', 1;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

DECLARE @TenantCode NVARCHAR(80) = N'$(TENANT_CODE)';
DECLARE @TenantId UNIQUEIDENTIFIER;
DECLARE @DaysAhead INT = TRY_CONVERT(INT, N'$(DAYS_AHEAD)');
DECLARE @DryRun BIT = TRY_CONVERT(BIT, N'$(DRY_RUN)');

SELECT @TenantId = tenant_id
FROM core.Tenant
WHERE tenant_code = @TenantCode;

IF @TenantId IS NULL
    THROW 52033, 'Tenant code was not found.', 1;

IF @DaysAhead IS NULL OR @DaysAhead < 0 OR @DaysAhead > 366
    THROW 52034, 'DAYS_AHEAD must be between 0 and 366.', 1;

IF @DryRun IS NULL
    THROW 52035, 'DRY_RUN must be 0 or 1.', 1;

EXEC tasking.SP_CreateRenewalTasks
    @tenant_id = @TenantId,
    @days_ahead = @DaysAhead,
    @assigned_to_user_id = NULL,
    @created_by_user_id = NULL,
    @dry_run = @DryRun;
GO
