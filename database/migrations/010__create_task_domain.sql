SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [YafesPars];
GO

PRINT 'Running migration: 010__create_task_domain.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'tasking.TaskStatus', N'U') IS NULL
    BEGIN
        CREATE TABLE tasking.TaskStatus (
            task_status_code NVARCHAR(30) NOT NULL,
            label_nl NVARCHAR(100) NOT NULL,
            label_fr NVARCHAR(100) NULL,
            label_en NVARCHAR(100) NULL,
            label_tr NVARCHAR(100) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_TaskStatus_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_TaskStatus PRIMARY KEY (task_status_code)
        );
    END;

    IF OBJECT_ID(N'tasking.TaskPriority', N'U') IS NULL
    BEGIN
        CREATE TABLE tasking.TaskPriority (
            task_priority_code NVARCHAR(20) NOT NULL,
            label_nl NVARCHAR(100) NOT NULL,
            label_fr NVARCHAR(100) NULL,
            label_en NVARCHAR(100) NULL,
            label_tr NVARCHAR(100) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_TaskPriority_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_TaskPriority PRIMARY KEY (task_priority_code)
        );
    END;

    IF OBJECT_ID(N'tasking.Task', N'U') IS NULL
    BEGIN
        CREATE TABLE tasking.Task (
            task_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_Task_task_id DEFAULT NEWSEQUENTIALID(),
            tenant_id UNIQUEIDENTIFIER NOT NULL,
            title NVARCHAR(200) NOT NULL,
            description NVARCHAR(MAX) NULL,
            related_entity_type NVARCHAR(60) NULL,
            related_entity_id UNIQUEIDENTIFIER NULL,
            assigned_to_user_id UNIQUEIDENTIFIER NULL,
            created_by_user_id UNIQUEIDENTIFIER NULL,
            task_priority_code NVARCHAR(20) NOT NULL
                CONSTRAINT DF_Task_task_priority_code DEFAULT N'NORMAL',
            task_status_code NVARCHAR(30) NOT NULL
                CONSTRAINT DF_Task_task_status_code DEFAULT N'OPEN',
            due_at_utc DATETIME2(0) NULL,
            completed_at_utc DATETIME2(0) NULL,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_Task_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_Task_updated_at_utc DEFAULT SYSUTCDATETIME(),
            is_deleted BIT NOT NULL
                CONSTRAINT DF_Task_is_deleted DEFAULT 0,
            CONSTRAINT PK_Task PRIMARY KEY (task_id),
            CONSTRAINT CK_Task_related_entity CHECK (
                (related_entity_type IS NULL AND related_entity_id IS NULL)
                OR (related_entity_type IN (N'PERSON', N'INSTITUTION', N'POLICY', N'CLAIM', N'RISK_OBJECT', N'DOCUMENT')
                    AND related_entity_id IS NOT NULL)
            ),
            CONSTRAINT CK_Task_completion_state CHECK (
                (task_status_code <> N'DONE' OR completed_at_utc IS NOT NULL)
                AND (completed_at_utc IS NULL OR task_status_code = N'DONE')
            ),
            CONSTRAINT FK_Task_Tenant FOREIGN KEY (tenant_id)
                REFERENCES core.Tenant (tenant_id),
            CONSTRAINT FK_Task_TaskPriority FOREIGN KEY (task_priority_code)
                REFERENCES tasking.TaskPriority (task_priority_code),
            CONSTRAINT FK_Task_TaskStatus FOREIGN KEY (task_status_code)
                REFERENCES tasking.TaskStatus (task_status_code),
            CONSTRAINT FK_Task_AppUser_AssignedTo FOREIGN KEY (assigned_to_user_id)
                REFERENCES core.AppUser (user_id),
            CONSTRAINT FK_Task_AppUser_CreatedBy FOREIGN KEY (created_by_user_id)
                REFERENCES core.AppUser (user_id)
        );
    END;

    IF OBJECT_ID(N'tasking.TaskComment', N'U') IS NULL
    BEGIN
        CREATE TABLE tasking.TaskComment (
            task_comment_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_TaskComment_task_comment_id DEFAULT NEWSEQUENTIALID(),
            task_id UNIQUEIDENTIFIER NOT NULL,
            comment_text NVARCHAR(MAX) NOT NULL,
            created_by_user_id UNIQUEIDENTIFIER NULL,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_TaskComment_created_at_utc DEFAULT SYSUTCDATETIME(),
            CONSTRAINT PK_TaskComment PRIMARY KEY (task_comment_id),
            CONSTRAINT FK_TaskComment_Task FOREIGN KEY (task_id)
                REFERENCES tasking.Task (task_id),
            CONSTRAINT FK_TaskComment_AppUser_CreatedBy FOREIGN KEY (created_by_user_id)
                REFERENCES core.AppUser (user_id)
        );
    END;

    IF OBJECT_ID(N'tasking.TaskReminder', N'U') IS NULL
    BEGIN
        CREATE TABLE tasking.TaskReminder (
            task_reminder_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_TaskReminder_task_reminder_id DEFAULT NEWSEQUENTIALID(),
            task_id UNIQUEIDENTIFIER NOT NULL,
            remind_at_utc DATETIME2(0) NOT NULL,
            sent_at_utc DATETIME2(0) NULL,
            channel_code NVARCHAR(30) NOT NULL
                CONSTRAINT DF_TaskReminder_channel_code DEFAULT N'IN_APP',
            is_cancelled BIT NOT NULL
                CONSTRAINT DF_TaskReminder_is_cancelled DEFAULT 0,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_TaskReminder_created_at_utc DEFAULT SYSUTCDATETIME(),
            CONSTRAINT PK_TaskReminder PRIMARY KEY (task_reminder_id),
            CONSTRAINT CK_TaskReminder_channel CHECK (channel_code IN (N'IN_APP', N'EMAIL', N'SMS')),
            CONSTRAINT CK_TaskReminder_sent_after_remind
                CHECK (sent_at_utc IS NULL OR sent_at_utc >= remind_at_utc),
            CONSTRAINT FK_TaskReminder_Task FOREIGN KEY (task_id)
                REFERENCES tasking.Task (task_id)
        );
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_Task_tenant_status_due'
          AND object_id = OBJECT_ID(N'tasking.Task')
    )
        CREATE INDEX IX_Task_tenant_status_due
        ON tasking.Task (tenant_id, task_status_code, due_at_utc);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_Task_assigned_to'
          AND object_id = OBJECT_ID(N'tasking.Task')
    )
        CREATE INDEX IX_Task_assigned_to
        ON tasking.Task (assigned_to_user_id);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_Task_related_entity'
          AND object_id = OBJECT_ID(N'tasking.Task')
    )
        CREATE INDEX IX_Task_related_entity
        ON tasking.Task (related_entity_type, related_entity_id);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_TaskReminder_due'
          AND object_id = OBJECT_ID(N'tasking.TaskReminder')
    )
        CREATE INDEX IX_TaskReminder_due
        ON tasking.TaskReminder (remind_at_utc, sent_at_utc, is_cancelled);

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'010__create_task_domain.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'010__create_task_domain.sql',
            N'SUCCESS'
        );
    END;

    COMMIT TRANSACTION;
    PRINT 'Migration completed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;
GO
