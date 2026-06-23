-- =============================================================================
-- Yafes Pars — SQL Agent Job Tanımları
-- Çalıştır: SQL Server Agent etkin olan bir sunucuda sa veya sysadmin rolüyle
-- =============================================================================
USE msdb;
GO

-- ─── JOB 1: Günlük Yenileme Görevi Oluşturma ─────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'YafesPars - Daily Renewal Task Creation')
BEGIN
    EXEC msdb.dbo.sp_add_job
        @job_name        = N'YafesPars - Daily Renewal Task Creation',
        @enabled         = 1,
        @description     = N'Poliçe yenileme tarihi yaklaşan sözleşmeler için otomatik görev oluşturur.',
        @category_name   = N'[Uncategorized (Local)]',
        @owner_login_name = N'sa';

    EXEC msdb.dbo.sp_add_jobstep
        @job_name      = N'YafesPars - Daily Renewal Task Creation',
        @step_name     = N'Create renewal tasks',
        @subsystem     = N'TSQL',
        @database_name = N'YafesPars',
        @command       = N'
            SET NOCOUNT ON;
            DECLARE @DryRun BIT = 0;
            DECLARE @DaysAhead INT = 30;
            -- Yenileme scriptini çağır
            EXEC tasking.sp_CreateRenewalTasks @DryRun = @DryRun, @DaysAhead = @DaysAhead;
        ',
        @on_success_action = 1,
        @on_fail_action    = 2;

    EXEC msdb.dbo.sp_add_schedule
        @schedule_name      = N'YafesPars Daily 06:00',
        @freq_type          = 4,
        @freq_interval      = 1,
        @active_start_time  = 60000;

    EXEC msdb.dbo.sp_attach_schedule
        @job_name      = N'YafesPars - Daily Renewal Task Creation',
        @schedule_name = N'YafesPars Daily 06:00';

    EXEC msdb.dbo.sp_add_jobserver
        @job_name = N'YafesPars - Daily Renewal Task Creation';

    PRINT 'Job created: YafesPars - Daily Renewal Task Creation';
END
ELSE
    PRINT 'Job already exists: YafesPars - Daily Renewal Task Creation';
GO

-- ─── JOB 2: Günlük Audit Log Temizleme ───────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'YafesPars - Audit Log Cleanup')
BEGIN
    EXEC msdb.dbo.sp_add_job
        @job_name        = N'YafesPars - Audit Log Cleanup',
        @enabled         = 1,
        @description     = N'90 günden eski audit log kayıtlarını arşivler.',
        @category_name   = N'[Uncategorized (Local)]',
        @owner_login_name = N'sa';

    EXEC msdb.dbo.sp_add_jobstep
        @job_name      = N'YafesPars - Audit Log Cleanup',
        @step_name     = N'Archive old audit logs',
        @subsystem     = N'TSQL',
        @database_name = N'YafesPars',
        @command       = N'
            SET NOCOUNT ON;
            DECLARE @CutoffDate DATE = DATEADD(DAY, -90, GETUTCDATE());
            DELETE FROM audit.AuditLog
            WHERE created_at_utc < @CutoffDate;
            PRINT CONCAT(''Deleted rows: '', @@ROWCOUNT);
        ',
        @on_success_action = 1,
        @on_fail_action    = 2;

    EXEC msdb.dbo.sp_add_schedule
        @schedule_name      = N'YafesPars Weekly Sunday 02:00',
        @freq_type          = 8,
        @freq_interval      = 1,
        @freq_recurrence_factor = 1,
        @active_start_time  = 20000;

    EXEC msdb.dbo.sp_attach_schedule
        @job_name      = N'YafesPars - Audit Log Cleanup',
        @schedule_name = N'YafesPars Weekly Sunday 02:00';

    EXEC msdb.dbo.sp_add_jobserver
        @job_name = N'YafesPars - Audit Log Cleanup';

    PRINT 'Job created: YafesPars - Audit Log Cleanup';
END
ELSE
    PRINT 'Job already exists: YafesPars - Audit Log Cleanup';
GO

-- ─── JOB 3: Gecikmiş Fatura Durumu Güncelleme ────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'YafesPars - Overdue Invoice Status Update')
BEGIN
    EXEC msdb.dbo.sp_add_job
        @job_name        = N'YafesPars - Overdue Invoice Status Update',
        @enabled         = 1,
        @description     = N'Vadesi geçmiş faturaları OVERDUE olarak işaretler.',
        @category_name   = N'[Uncategorized (Local)]',
        @owner_login_name = N'sa';

    EXEC msdb.dbo.sp_add_jobstep
        @job_name      = N'YafesPars - Overdue Invoice Status Update',
        @step_name     = N'Mark overdue invoices',
        @subsystem     = N'TSQL',
        @database_name = N'YafesPars',
        @command       = N'
            SET NOCOUNT ON;
            UPDATE finance.Invoices
            SET StatusCode = N''OVERDUE'',
                UpdatedAt  = SYSUTCDATETIME()
            WHERE StatusCode = N''PENDING''
              AND DueDate < CAST(GETUTCDATE() AS DATE);
            PRINT CONCAT(''Marked overdue: '', @@ROWCOUNT);
        ',
        @on_success_action = 1,
        @on_fail_action    = 2;

    EXEC msdb.dbo.sp_add_schedule
        @schedule_name      = N'YafesPars Daily 07:00',
        @freq_type          = 4,
        @freq_interval      = 1,
        @active_start_time  = 70000;

    EXEC msdb.dbo.sp_attach_schedule
        @job_name      = N'YafesPars - Overdue Invoice Status Update',
        @schedule_name = N'YafesPars Daily 07:00';

    EXEC msdb.dbo.sp_add_jobserver
        @job_name = N'YafesPars - Overdue Invoice Status Update';

    PRINT 'Job created: YafesPars - Overdue Invoice Status Update';
END
ELSE
    PRINT 'Job already exists: YafesPars - Overdue Invoice Status Update';
GO

-- ─── JOB 4: Haftalık Veritabanı Yedeği ───────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'YafesPars - Weekly Database Backup')
BEGIN
    EXEC msdb.dbo.sp_add_job
        @job_name        = N'YafesPars - Weekly Database Backup',
        @enabled         = 1,
        @description     = N'YafesPars veritabanının tam yedeğini alır.',
        @category_name   = N'[Uncategorized (Local)]',
        @owner_login_name = N'sa';

    EXEC msdb.dbo.sp_add_jobstep
        @job_name      = N'YafesPars - Weekly Database Backup',
        @step_name     = N'Full backup',
        @subsystem     = N'TSQL',
        @database_name = N'master',
        @command       = N'
            SET NOCOUNT ON;
            DECLARE @Path NVARCHAR(500) = N''C:\SQLBackups\YafesPars_'' +
                FORMAT(GETDATE(), ''yyyyMMdd_HHmm'') + N''.bak'';
            BACKUP DATABASE [YafesPars]
            TO DISK = @Path
            WITH COMPRESSION, CHECKSUM, STATS = 10;
            PRINT CONCAT(''Backup completed: '', @Path);
        ',
        @on_success_action = 1,
        @on_fail_action    = 2;

    EXEC msdb.dbo.sp_add_schedule
        @schedule_name      = N'YafesPars Weekly Saturday 01:00',
        @freq_type          = 8,
        @freq_interval      = 64,
        @freq_recurrence_factor = 1,
        @active_start_time  = 10000;

    EXEC msdb.dbo.sp_attach_schedule
        @job_name      = N'YafesPars - Weekly Database Backup',
        @schedule_name = N'YafesPars Weekly Saturday 01:00';

    EXEC msdb.dbo.sp_add_jobserver
        @job_name = N'YafesPars - Weekly Database Backup';

    PRINT 'Job created: YafesPars - Weekly Database Backup';
END
ELSE
    PRINT 'Job already exists: YafesPars - Weekly Database Backup';
GO

PRINT '=== SQL Agent Job setup complete ===';
GO
