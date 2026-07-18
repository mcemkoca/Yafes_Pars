/*
    Yafes Pars SSMS Workbench - SQL Risk Review Board

    INFO TIP:
    Visual preview screens are not execution tools. Run this file in SSMS with
    SQLCMD Mode enabled against a DEV database to get real Results Grid data.

    Creates a sample review request if SAMPLE_SQL is changed.
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
    THROW 52021, 'Target database name must contain DEV.', 1;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

DECLARE @TenantId UNIQUEIDENTIFIER;
SELECT @TenantId = tenant_id FROM core.Tenant WHERE tenant_code = N'$(TENANT_CODE)';
IF @TenantId IS NULL THROW 52210, 'Tenant code was not found.', 1;

DECLARE @SampleSql NVARCHAR(MAX) = N'
UPDATE policy.Contract
SET status_code = ''CANCELLED'';
';

DECLARE @RollbackSql NVARCHAR(MAX) = N'
-- Provide precise rollback SQL before production execution.
';

PRINT '01 - Create SQL review request';
EXEC assurance.SP_CreateSqlReviewRequest
    @tenant_id = @TenantId,
    @environment_code = N'PROD',
    @target_database = N'$(YAFES_SQL_DATABASE)',
    @script_name = N'ssms-sample-risk-review.sql',
    @submitted_sql = @SampleSql,
    @rollback_sql = @RollbackSql,
    @submitted_by_user_id = NULL;

PRINT '02 - Review board';
EXEC assurance.SP_GetSqlReviewRequests @tenant_id = @TenantId, @limit = 100;

PRINT '03 - Findings';
EXEC assurance.SP_GetSqlRiskFindings @tenant_id = @TenantId, @sql_review_request_id = NULL;
GO
