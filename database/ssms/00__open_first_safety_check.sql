/*
    Yafes Pars SSMS Workbench - Open First

    Enable SQLCMD Mode before running.
    This script does not change data.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"

SET NOCOUNT ON;
GO

USE [master];
GO

DECLARE @TargetDatabase SYSNAME = N'$(YAFES_SQL_DATABASE)';
DECLARE @ServerName NVARCHAR(256) = LOWER(CONVERT(NVARCHAR(256), @@SERVERNAME));
DECLARE @MachineName NVARCHAR(256) = LOWER(CONVERT(NVARCHAR(256), SERVERPROPERTY('MachineName')));

IF @TargetDatabase NOT LIKE N'%DEV%'
    THROW 52000, 'Target database name must contain DEV.', 1;

IF @ServerName LIKE N'%prod%' OR @ServerName LIKE N'%production%' OR @ServerName LIKE N'%prd%' OR @ServerName LIKE N'%live%'
    THROW 52001, 'Connected server name suggests production/live.', 1;

IF @MachineName LIKE N'%prod%' OR @MachineName LIKE N'%production%' OR @MachineName LIKE N'%prd%' OR @MachineName LIKE N'%live%'
    THROW 52002, 'Connected machine name suggests production/live.', 1;

SELECT
    @@SERVERNAME AS server_name,
    SERVERPROPERTY('MachineName') AS machine_name,
    @TargetDatabase AS target_database,
    DB_ID(@TargetDatabase) AS target_database_id,
    SERVERPROPERTY('ProductVersion') AS sql_server_version,
    SERVERPROPERTY('Edition') AS sql_server_edition,
    SYSDATETIMEOFFSET() AS checked_at;

IF DB_ID(@TargetDatabase) IS NULL
BEGIN
    PRINT 'Target DEV database does not exist yet. Create it or run the guarded migration workflow.';
END
ELSE
BEGIN
    PRINT 'Target DEV database exists. Continue with SSMS dashboard or guarded migration workflow.';
END;
GO
