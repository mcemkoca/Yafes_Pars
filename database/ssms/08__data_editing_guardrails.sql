/*
    Yafes Pars SSMS Workbench - Data Editing Guardrails

    INFO TIP:
    This file is for controlled updates. It opens a transaction, previews the
    affected rows, applies only the selected action, shows the result, and rolls
    back by default. Set COMMIT_CHANGES = 1 only after the preview is correct.

    Enable SQLCMD Mode before running.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE "DEMO-BE-BROKER"
:setvar ACTION_NAME "UPDATE_TASK_STATUS"
:setvar COMMIT_CHANGES "0"
:setvar UPDATED_BY_USER_EMAIL "admin@yafes.demo"

-- UPDATE_TASK_STATUS
:setvar TASK_ID ""
:setvar TASK_STATUS_CODE "DONE"
:setvar TASK_COMPLETED_AT_UTC "2026-06-03 09:00:00"

-- CLOSE_CLAIM
:setvar CLAIM_ID ""
:setvar CLAIM_CLOSED_DATE "2026-06-03"
:setvar CLAIM_PAID_AMOUNT "0.00"
:setvar CLAIM_RESERVED_AMOUNT "0.00"
:setvar CLAIM_PAYMENT_METHOD_CODE ""

-- SOFT_DELETE_DOCUMENT
:setvar DOCUMENT_ID ""

SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

IF DB_NAME() NOT LIKE N'%DEV%'
    THROW 52499, 'Current database name must contain DEV.', 1;

DECLARE @TenantCode NVARCHAR(80) = N'$(TENANT_CODE)';
DECLARE @ActionName NVARCHAR(80) = UPPER(N'$(ACTION_NAME)');
DECLARE @CommitChanges BIT = TRY_CONVERT(BIT, N'$(COMMIT_CHANGES)');
DECLARE @TenantId UNIQUEIDENTIFIER;
DECLARE @UpdatedByUserId UNIQUEIDENTIFIER;

IF @CommitChanges IS NULL
    THROW 52400, 'COMMIT_CHANGES must be 0 or 1.', 1;

SELECT @TenantId = tenant_id
FROM core.Tenant
WHERE tenant_code = @TenantCode;

IF @TenantId IS NULL
    THROW 52401, 'Tenant code was not found.', 1;

SELECT @UpdatedByUserId = user_id
FROM core.AppUser
WHERE tenant_id = @TenantId
  AND email = NULLIF(N'$(UPDATED_BY_USER_EMAIL)', N'')
  AND is_active = 1;

IF @ActionName NOT IN (N'UPDATE_TASK_STATUS', N'CLOSE_CLAIM', N'SOFT_DELETE_DOCUMENT')
    THROW 52402, 'Unknown ACTION_NAME.', 1;

PRINT 'INFO TIP: COMMIT_CHANGES = 0 means rollback. COMMIT_CHANGES = 1 commits the selected action.';

BEGIN TRY
    BEGIN TRANSACTION;

    PRINT '01 - Edit context';
    SELECT
        @ActionName AS action_name,
        @CommitChanges AS commit_changes,
        @TenantCode AS tenant_code,
        @TenantId AS tenant_id,
        @UpdatedByUserId AS updated_by_user_id,
        N'INFO TIP: Confirm tenant_id and action_name before trusting any update preview.' AS info_tip;

    IF @ActionName = N'UPDATE_TASK_STATUS'
    BEGIN
        DECLARE @TaskId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, N'$(TASK_ID)');
        DECLARE @TaskCompletedAtUtc DATETIME2(0) = TRY_CONVERT(DATETIME2(0), NULLIF(N'$(TASK_COMPLETED_AT_UTC)', N''));

        PRINT '02 - Task before update';
        SELECT
            task_id,
            title,
            task_status_code,
            completed_at_utc,
            updated_at_utc,
            N'INFO TIP: Expected row count is exactly 1.' AS info_tip
        FROM tasking.Task
        WHERE tenant_id = @TenantId
          AND task_id = @TaskId
          AND is_deleted = 0;

        UPDATE tasking.Task
            SET task_status_code = N'$(TASK_STATUS_CODE)',
                completed_at_utc = CASE WHEN N'$(TASK_STATUS_CODE)' = N'DONE' THEN COALESCE(@TaskCompletedAtUtc, SYSUTCDATETIME()) ELSE NULL END,
                updated_at_utc = SYSUTCDATETIME()
        WHERE tenant_id = @TenantId
          AND task_id = @TaskId
          AND is_deleted = 0;

        IF @@ROWCOUNT <> 1
            THROW 52403, 'Task update expected exactly one row.', 1;

        PRINT '03 - Task after update';
        SELECT
            task_id,
            title,
            task_status_code,
            completed_at_utc,
            updated_at_utc,
            N'INFO TIP: If this looks wrong, keep COMMIT_CHANGES = 0.' AS info_tip
        FROM tasking.Task
        WHERE tenant_id = @TenantId
          AND task_id = @TaskId;
    END;

    IF @ActionName = N'CLOSE_CLAIM'
    BEGIN
        DECLARE @ClaimId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, N'$(CLAIM_ID)');

        PRINT '02 - Claim before close';
        SELECT
            claim_id,
            claim_number,
            claim_status_code,
            closed_date,
            paid_amount,
            reserved_amount,
            N'INFO TIP: Expected row count is exactly 1.' AS info_tip
        FROM claim.Claim
        WHERE tenant_id = @TenantId
          AND claim_id = @ClaimId
          AND is_deleted = 0;

        EXEC claim.SP_CloseClaim
            @tenant_id = @TenantId,
            @claim_id = @ClaimId,
            @closed_date = '$(CLAIM_CLOSED_DATE)',
            @paid_amount = '$(CLAIM_PAID_AMOUNT)',
            @reserved_amount = '$(CLAIM_RESERVED_AMOUNT)',
            @payment_method_code = NULLIF(N'$(CLAIM_PAYMENT_METHOD_CODE)', N''),
            @updated_by_user_id = @UpdatedByUserId;

        PRINT '03 - Claim after close';
        SELECT
            claim_id,
            claim_number,
            claim_status_code,
            closed_date,
            paid_amount,
            reserved_amount,
            updated_at_utc,
            N'INFO TIP: If this looks wrong, keep COMMIT_CHANGES = 0.' AS info_tip
        FROM claim.Claim
        WHERE tenant_id = @TenantId
          AND claim_id = @ClaimId;
    END;

    IF @ActionName = N'SOFT_DELETE_DOCUMENT'
    BEGIN
        DECLARE @DocumentId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, N'$(DOCUMENT_ID)');

        PRINT '02 - Document before soft delete';
        SELECT
            document_id,
            owner_entity_type,
            owner_entity_id,
            document_type_code,
            file_name,
            is_deleted,
            N'INFO TIP: This is a soft delete only; file storage is not touched.' AS info_tip
        FROM document.Document
        WHERE tenant_id = @TenantId
          AND document_id = @DocumentId
          AND is_deleted = 0;

        UPDATE document.Document
            SET is_deleted = 1,
                deleted_at_utc = SYSUTCDATETIME(),
                updated_at_utc = SYSUTCDATETIME()
        WHERE tenant_id = @TenantId
          AND document_id = @DocumentId
          AND is_deleted = 0;

        IF @@ROWCOUNT <> 1
            THROW 52404, 'Document soft delete expected exactly one row.', 1;

        PRINT '03 - Document after soft delete';
        SELECT
            document_id,
            owner_entity_type,
            owner_entity_id,
            document_type_code,
            file_name,
            is_deleted,
            updated_at_utc,
            N'INFO TIP: If this looks wrong, keep COMMIT_CHANGES = 0.' AS info_tip
        FROM document.Document
        WHERE tenant_id = @TenantId
          AND document_id = @DocumentId;
    END;

    IF @CommitChanges = 1
    BEGIN
        COMMIT TRANSACTION;
        PRINT 'COMMIT completed.';
    END
    ELSE
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'ROLLBACK completed because COMMIT_CHANGES = 0.';
    END;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO
