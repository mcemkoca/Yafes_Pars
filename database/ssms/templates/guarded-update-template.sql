/*
    Guarded Update Template

    INFO TIP:
    Rollback is the default. Set COMMIT_CHANGES = 1 only after the preview
    shows exactly the row you intended.
    Keep SQLCMD Mode enabled and run only against a DEV database.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE "DEV-BE-BROKER"
:setvar COMMIT_CHANGES "0"
:setvar TARGET_TASK_ID ""
:setvar NEW_TASK_STATUS_CODE "DONE"

SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

IF DB_NAME() NOT LIKE N'%DEV%'
    THROW 52923, 'Current database name must contain DEV.', 1;

DECLARE @TenantId UNIQUEIDENTIFIER;
DECLARE @CommitChanges BIT = TRY_CONVERT(BIT, N'$(COMMIT_CHANGES)');
DECLARE @TargetTaskId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, N'$(TARGET_TASK_ID)');

IF @CommitChanges IS NULL
    THROW 52920, 'COMMIT_CHANGES must be 0 or 1.', 1;

SELECT @TenantId = tenant_id
FROM core.Tenant
WHERE tenant_code = N'$(TENANT_CODE)';

IF @TenantId IS NULL
    THROW 52921, 'Tenant code was not found.', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    SELECT
        task_id,
        title,
        task_status_code,
        completed_at_utc,
        N'INFO TIP: Preview before update. Expected row count: 1.' AS info_tip
    FROM tasking.Task
    WHERE tenant_id = @TenantId
      AND task_id = @TargetTaskId
      AND is_deleted = 0;

    UPDATE tasking.Task
        SET task_status_code = N'$(NEW_TASK_STATUS_CODE)',
            completed_at_utc = CASE WHEN N'$(NEW_TASK_STATUS_CODE)' = N'DONE' THEN SYSUTCDATETIME() ELSE NULL END,
            updated_at_utc = SYSUTCDATETIME()
    WHERE tenant_id = @TenantId
      AND task_id = @TargetTaskId
      AND is_deleted = 0;

    IF @@ROWCOUNT <> 1
        THROW 52922, 'Expected exactly one updated row.', 1;

    SELECT
        task_id,
        title,
        task_status_code,
        completed_at_utc,
        N'INFO TIP: Confirm this row before committing.' AS info_tip
    FROM tasking.Task
    WHERE tenant_id = @TenantId
      AND task_id = @TargetTaskId;

    IF @CommitChanges = 1
        COMMIT TRANSACTION;
    ELSE
        ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO
