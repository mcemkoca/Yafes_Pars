SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF OBJECT_ID(N'tasking.Task', N'U') IS NULL
    THROW 50901, 'Missing table: tasking.Task', 1;

IF OBJECT_ID(N'tasking.TaskComment', N'U') IS NULL
    THROW 50902, 'Missing table: tasking.TaskComment', 1;

IF OBJECT_ID(N'tasking.TaskReminder', N'U') IS NULL
    THROW 50903, 'Missing table: tasking.TaskReminder', 1;

IF OBJECT_ID(N'tasking.TaskStatus', N'U') IS NULL
    THROW 50904, 'Missing table: tasking.TaskStatus', 1;

IF OBJECT_ID(N'tasking.TaskPriority', N'U') IS NULL
    THROW 50905, 'Missing table: tasking.TaskPriority', 1;

IF COL_LENGTH(N'tasking.Task', N'tenant_id') IS NULL
    THROW 50906, 'Missing column: tasking.Task.tenant_id', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = N'CK_Task_related_entity'
      AND parent_object_id = OBJECT_ID(N'tasking.Task')
)
    THROW 50907, 'Missing check constraint: CK_Task_related_entity', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_Task_Tenant'
      AND parent_object_id = OBJECT_ID(N'tasking.Task')
)
    THROW 50908, 'Missing FK: FK_Task_Tenant', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Task_tenant_status_due'
      AND object_id = OBJECT_ID(N'tasking.Task')
)
    THROW 50909, 'Missing index: IX_Task_tenant_status_due', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_TaskReminder_due'
      AND object_id = OBJECT_ID(N'tasking.TaskReminder')
)
    THROW 50910, 'Missing index: IX_TaskReminder_due', 1;

IF EXISTS (
    SELECT 1
    FROM tasking.Task
    WHERE (task_status_code = N'DONE' AND completed_at_utc IS NULL)
       OR (task_status_code <> N'DONE' AND completed_at_utc IS NOT NULL)
)
    THROW 50911, 'Task completion state is inconsistent.', 1;

IF EXISTS (
    SELECT 1
    FROM tasking.Task t
    INNER JOIN core.AppUser u
        ON u.user_id = t.assigned_to_user_id
    WHERE t.assigned_to_user_id IS NOT NULL
      AND u.tenant_id <> t.tenant_id
)
    THROW 50912, 'Assigned task user must belong to task tenant.', 1;

IF EXISTS (
    SELECT 1
    FROM tasking.Task
    WHERE related_entity_type IS NOT NULL
      AND related_entity_id IS NULL
)
    THROW 50913, 'Task related_entity_type requires related_entity_id.', 1;

IF EXISTS (
    SELECT 1
    FROM tasking.TaskReminder
    WHERE sent_at_utc IS NOT NULL
      AND sent_at_utc < remind_at_utc
)
    THROW 50914, 'Task reminder sent_at_utc cannot be before remind_at_utc.', 1;

PRINT 'Task domain validation passed.';
GO
