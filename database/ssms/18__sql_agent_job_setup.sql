/*
    Yafes Pars SSMS Workbench - SQL Agent Job Setup

    INFO TIP:
    Creates three SQL Server Agent jobs for daily/weekly automated operations.
    Run ONCE on DEV/TEST/PROD after DBA approval. Idempotent: skips existing jobs.
    Jobs use sp_add_job / sp_add_jobstep / sp_add_schedule patterns.

    Jobs created:
      1. YafesPars_DailyMarkOverdueInvoices    — daily 06:00
      2. YafesPars_DailyRenewalTasks           — daily 07:00 (dry_run=0)
      3. YafesPars_WeeklyFsmaPortfolioCheck    — every Monday 08:00

    Requires: SQLServerAgent running, sysadmin or SQLAgentOperatorRole.
    Enable SQLCMD Mode before running.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE "DEV-BE-BROKER"
:setvar JOB_OWNER "sa"

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [msdb];
GO

-- Safety: alleen uitvoeren op DEV of indien expliciet toegestaan
DECLARE @db SYSNAME = N'$(YAFES_SQL_DATABASE)';
IF @db NOT LIKE N'%Dev%' AND @db NOT LIKE N'%Test%' AND @db NOT LIKE N'%Acc%'
BEGIN
    PRINT 'WARN: Database name does not contain Dev/Test/Acc. Verify target before running.';
END
GO

-- =============================================================================
-- JOB 1: YafesPars_DailyMarkOverdueInvoices
-- =============================================================================
IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'YafesPars_DailyMarkOverdueInvoices')
BEGIN
    DECLARE @job_id1 UNIQUEIDENTIFIER;

    EXEC msdb.dbo.sp_add_job
        @job_name    = N'YafesPars_DailyMarkOverdueInvoices',
        @enabled     = 1,
        @description = N'Zet PENDING facturen met vervaldatum in het verleden op OVERDUE. / Gecikmiş faturaları OVERDUE olarak işaretle.',
        @owner_login_name = N'$(JOB_OWNER)',
        @job_id      = @job_id1 OUTPUT;

    EXEC msdb.dbo.sp_add_jobstep
        @job_id          = @job_id1,
        @step_name       = N'MarkOverdueInvoices',
        @subsystem       = N'TSQL',
        @database_name   = N'$(YAFES_SQL_DATABASE)',
        @command         = N'EXEC finance.SP_MarkOverdueInvoices @dry_run = 0;',
        @on_success_action = 1,
        @on_fail_action  = 2;

    EXEC msdb.dbo.sp_add_schedule
        @schedule_name   = N'YafesPars_Daily0600',
        @freq_type       = 4,        -- Dagelijks
        @freq_interval   = 1,
        @active_start_time = 060000; -- 06:00

    EXEC msdb.dbo.sp_attach_schedule
        @job_id        = @job_id1,
        @schedule_name = N'YafesPars_Daily0600';

    EXEC msdb.dbo.sp_add_jobserver
        @job_id = @job_id1,
        @server_name = N'(LOCAL)';

    PRINT 'Job YafesPars_DailyMarkOverdueInvoices aangemaakt.';
END
ELSE
    PRINT 'Job YafesPars_DailyMarkOverdueInvoices bestaat al — overgeslagen.';
GO

-- =============================================================================
-- JOB 2: YafesPars_DailyRenewalTasks
-- =============================================================================
IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'YafesPars_DailyRenewalTasks')
BEGIN
    DECLARE @job_id2 UNIQUEIDENTIFIER;
    DECLARE @tenant_id UNIQUEIDENTIFIER;

    -- Haal de tenant-id op via tenant_code
    SELECT @tenant_id = tenant_id
    FROM YafesPars_Dev.core.Tenant
    WHERE tenant_code = N'$(TENANT_CODE)'
      AND is_active = 1;

    IF @tenant_id IS NULL
    BEGIN
        PRINT 'WARN: Tenant niet gevonden voor TENANT_CODE=$(TENANT_CODE). Job aangemaakt met placeholder tenant-id.';
        SET @tenant_id = '00000000-0000-0000-0000-000000000000';
    END

    DECLARE @cmd NVARCHAR(500) = N'EXEC tasking.SP_CreateRenewalTasks @tenant_id = ''' + CAST(@tenant_id AS NVARCHAR(36)) + N''', @days_ahead = 60, @dry_run = 0;';

    EXEC msdb.dbo.sp_add_job
        @job_name    = N'YafesPars_DailyRenewalTasks',
        @enabled     = 1,
        @description = N'Maak verlengingstaken voor polissen die binnen 60 dagen vervallen. / 60 gün içinde vadesi dolacak poliçeler için yenileme görevi oluştur.',
        @owner_login_name = N'$(JOB_OWNER)',
        @job_id      = @job_id2 OUTPUT;

    EXEC msdb.dbo.sp_add_jobstep
        @job_id          = @job_id2,
        @step_name       = N'CreateRenewalTasks',
        @subsystem       = N'TSQL',
        @database_name   = N'$(YAFES_SQL_DATABASE)',
        @command         = @cmd,
        @on_success_action = 1,
        @on_fail_action  = 2;

    EXEC msdb.dbo.sp_add_schedule
        @schedule_name   = N'YafesPars_Daily0700',
        @freq_type       = 4,
        @freq_interval   = 1,
        @active_start_time = 070000; -- 07:00

    EXEC msdb.dbo.sp_attach_schedule
        @job_id        = @job_id2,
        @schedule_name = N'YafesPars_Daily0700';

    EXEC msdb.dbo.sp_add_jobserver
        @job_id = @job_id2,
        @server_name = N'(LOCAL)';

    PRINT 'Job YafesPars_DailyRenewalTasks aangemaakt.';
END
ELSE
    PRINT 'Job YafesPars_DailyRenewalTasks bestaat al — overgeslagen.';
GO

-- =============================================================================
-- JOB 3: YafesPars_WeeklyFsmaPortfolioCheck
-- =============================================================================
IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'YafesPars_WeeklyFsmaPortfolioCheck')
BEGIN
    DECLARE @job_id3 UNIQUEIDENTIFIER;

    EXEC msdb.dbo.sp_add_job
        @job_name    = N'YafesPars_WeeklyFsmaPortfolioCheck',
        @enabled     = 1,
        @description = N'Wekelijkse portefeuille- en FSMA-controle: telt actieve polissen, verlopen polissen en commissies. Resultaat naar SQL Agent history. / Haftalık portföy ve FSMA kontrolü.',
        @owner_login_name = N'$(JOB_OWNER)',
        @job_id      = @job_id3 OUTPUT;

    EXEC msdb.dbo.sp_add_jobstep
        @job_id          = @job_id3,
        @step_name       = N'FsmaPortfolioCheck',
        @subsystem       = N'TSQL',
        @database_name   = N'$(YAFES_SQL_DATABASE)',
        @command         = N'
SELECT
    ''Actieve polissen'' AS check_naam,
    COUNT(*) AS waarde
FROM policy.Contract
WHERE contract_status_code = N''ACTIVE'' AND is_deleted = 0
UNION ALL
SELECT ''Verlopen polissen'', COUNT(*)
FROM policy.Contract
WHERE contract_status_code = N''ACTIVE''
  AND end_date < CAST(SYSUTCDATETIME() AS DATE)
  AND is_deleted = 0
UNION ALL
SELECT ''Openstaande commissies'', COUNT(*)
FROM finance.Commissions
WHERE status_code = N''PENDING'' AND is_deleted = 0;',
        @on_success_action = 1,
        @on_fail_action  = 2;

    EXEC msdb.dbo.sp_add_schedule
        @schedule_name      = N'YafesPars_WeeklyMonday0800',
        @freq_type          = 8,        -- Wekelijks
        @freq_interval      = 2,        -- Maandag (bitmask: 2 = Monday)
        @freq_recurrence_factor = 1,
        @active_start_time  = 080000;   -- 08:00

    EXEC msdb.dbo.sp_attach_schedule
        @job_id        = @job_id3,
        @schedule_name = N'YafesPars_WeeklyMonday0800';

    EXEC msdb.dbo.sp_add_jobserver
        @job_id = @job_id3,
        @server_name = N'(LOCAL)';

    PRINT 'Job YafesPars_WeeklyFsmaPortfolioCheck aangemaakt.';
END
ELSE
    PRINT 'Job YafesPars_WeeklyFsmaPortfolioCheck bestaat al — overgeslagen.';
GO

-- Controleer resultaat
SELECT
    name AS job_naam,
    enabled AS actief,
    description AS omschrijving
FROM msdb.dbo.sysjobs
WHERE name LIKE N'YafesPars_%'
ORDER BY name;
GO

PRINT 'SQL Agent job setup voltooid. / SQL Agent job kurulumu tamamlandi.';
GO
