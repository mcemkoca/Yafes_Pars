-- =============================================================================
-- Migration 048: Export job lifecycle tracking
--
-- Adds import.ExportJob table and supporting SPs so bulk data exports
-- (FSMA, portfolio, claim, ledger) can be tracked from creation to delivery.
-- Addresses P2 gap: export jobs were untracked, making audit and retry
-- impossible without manual log inspection.
--
-- Tables:
--   import.ExportJob         — one row per export run
--   import.ExportJobFile     — one row per generated file within a job
--
-- SPs:
--   import.SP_CreateExportJob    — register a new export job, return job_id
--   import.SP_CompleteExportJob  — mark job SUCCESS or FAILED with summary
--   import.SP_GetExportJobStatus — query job + file list for a given job_id
--   import.SP_GetExportJobQueue  — list recent/pending jobs for a tenant
-- =============================================================================
USE [YafesPars];
GO

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;
BEGIN TRY

IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'048__add_export_job_lifecycle')
BEGIN

    -- -------------------------------------------------------------------------
    -- 1. import.ExportJob
    -- -------------------------------------------------------------------------
    IF OBJECT_ID(N'import.ExportJob', N'U') IS NULL
    BEGIN
        CREATE TABLE import.ExportJob (
            job_id              UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_ExportJob_id DEFAULT NEWSEQUENTIALID(),
            tenant_id           UNIQUEIDENTIFIER NOT NULL,
            export_type_code    NVARCHAR(40)     NOT NULL,   -- FSMA, PORTFOLIO, CLAIMS, LEDGER, CUSTOM
            status_code         NVARCHAR(20)     NOT NULL
                CONSTRAINT DF_ExportJob_status DEFAULT N'PENDING',
            period_start        DATE             NULL,
            period_end          DATE             NULL,
            requested_by_user_id UNIQUEIDENTIFIER NULL,
            started_at_utc      DATETIME2(0)     NULL,
            completed_at_utc    DATETIME2(0)     NULL,
            row_count           INT              NULL,
            error_message       NVARCHAR(1000)   NULL,
            created_at_utc      DATETIME2(0)     NOT NULL
                CONSTRAINT DF_ExportJob_created DEFAULT SYSUTCDATETIME(),
            CONSTRAINT PK_ExportJob PRIMARY KEY (job_id),
            CONSTRAINT CK_ExportJob_status CHECK (
                status_code IN (N'PENDING', N'RUNNING', N'SUCCESS', N'FAILED', N'CANCELLED')
            ),
            CONSTRAINT CK_ExportJob_type CHECK (
                export_type_code IN (N'FSMA', N'PORTFOLIO', N'CLAIMS', N'LEDGER', N'CUSTOM')
            ),
            CONSTRAINT CK_ExportJob_period CHECK (
                period_end IS NULL OR period_start IS NULL OR period_end >= period_start
            )
        );
        PRINT '  Table import.ExportJob created.';
    END;

    -- -------------------------------------------------------------------------
    -- 2. import.ExportJobFile — files produced by a job
    -- -------------------------------------------------------------------------
    IF OBJECT_ID(N'import.ExportJobFile', N'U') IS NULL
    BEGIN
        CREATE TABLE import.ExportJobFile (
            file_id             UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_ExportJobFile_id DEFAULT NEWSEQUENTIALID(),
            job_id              UNIQUEIDENTIFIER NOT NULL,
            file_name           NVARCHAR(260)    NOT NULL,
            file_format_code    NVARCHAR(10)     NOT NULL   -- CSV, XLSX, JSON, XML
                CONSTRAINT DF_ExportJobFile_format DEFAULT N'CSV',
            byte_size           BIGINT           NULL,
            row_count           INT              NULL,
            storage_path        NVARCHAR(500)    NULL,      -- blob/share path
            created_at_utc      DATETIME2(0)     NOT NULL
                CONSTRAINT DF_ExportJobFile_created DEFAULT SYSUTCDATETIME(),
            CONSTRAINT PK_ExportJobFile PRIMARY KEY (file_id),
            CONSTRAINT FK_ExportJobFile_Job FOREIGN KEY (job_id)
                REFERENCES import.ExportJob (job_id),
            CONSTRAINT CK_ExportJobFile_format CHECK (
                file_format_code IN (N'CSV', N'XLSX', N'JSON', N'XML')
            )
        );
        PRINT '  Table import.ExportJobFile created.';
    END;

    -- -------------------------------------------------------------------------
    -- 3. Indexes
    -- -------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ExportJob_Tenant_Status'
                   AND object_id = OBJECT_ID(N'import.ExportJob'))
        CREATE INDEX IX_ExportJob_Tenant_Status
            ON import.ExportJob (tenant_id, status_code)
            INCLUDE (export_type_code, created_at_utc);

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ExportJob_Tenant_Type_Period'
                   AND object_id = OBJECT_ID(N'import.ExportJob'))
        CREATE INDEX IX_ExportJob_Tenant_Type_Period
            ON import.ExportJob (tenant_id, export_type_code, period_start, period_end);

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ExportJobFile_Job'
                   AND object_id = OBJECT_ID(N'import.ExportJobFile'))
        CREATE INDEX IX_ExportJobFile_Job
            ON import.ExportJobFile (job_id);

    INSERT INTO core.SchemaMigration (migration_name, execution_status)
    VALUES (N'048__add_export_job_lifecycle', N'SUCCESS');

    PRINT 'Migration 048: import.ExportJob + import.ExportJobFile created.';
END

COMMIT TRANSACTION;

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- =============================================================================
-- SP: import.SP_CreateExportJob
-- Registreert een nieuw exportjob en geeft het job_id terug.
-- =============================================================================
CREATE OR ALTER PROCEDURE import.SP_CreateExportJob
    @tenant_id              UNIQUEIDENTIFIER,
    @export_type_code       NVARCHAR(40),
    @period_start           DATE             = NULL,
    @period_end             DATE             = NULL,
    @requested_by_user_id   UNIQUEIDENTIFIER = NULL
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    IF @export_type_code NOT IN (N'FSMA', N'PORTFOLIO', N'CLAIMS', N'LEDGER', N'CUSTOM')
        THROW 55001, 'Ongeldig export_type_code. Gebruik: FSMA, PORTFOLIO, CLAIMS, LEDGER, CUSTOM.', 1;

    IF @period_end IS NOT NULL AND @period_start IS NOT NULL AND @period_end < @period_start
        THROW 55002, '@period_end mag niet voor @period_start liggen.', 1;

    DECLARE @job_id UNIQUEIDENTIFIER = NEWID();

    INSERT INTO import.ExportJob
        (job_id, tenant_id, export_type_code, status_code,
         period_start, period_end, requested_by_user_id)
    VALUES
        (@job_id, @tenant_id, @export_type_code, N'PENDING',
         @period_start, @period_end, @requested_by_user_id);

    SELECT
        @job_id                                     AS JobId,
        @tenant_id                                  AS TenantId,
        @export_type_code                           AS ExportTypeCode,
        N'PENDING'                                  AS StatusCode,
        SYSUTCDATETIME()                            AS CreatedAtUtc;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

-- =============================================================================
-- SP: import.SP_CompleteExportJob
-- Markeert een job als SUCCESS of FAILED en registreert het resultaat.
-- =============================================================================
CREATE OR ALTER PROCEDURE import.SP_CompleteExportJob
    @job_id         UNIQUEIDENTIFIER,
    @tenant_id      UNIQUEIDENTIFIER,
    @status_code    NVARCHAR(20),          -- SUCCESS or FAILED
    @row_count      INT              = NULL,
    @error_message  NVARCHAR(1000)   = NULL
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    IF @status_code NOT IN (N'SUCCESS', N'FAILED', N'CANCELLED')
        THROW 55003, '@status_code moet SUCCESS, FAILED of CANCELLED zijn.', 1;

    IF NOT EXISTS (
        SELECT 1 FROM import.ExportJob
        WHERE job_id = @job_id AND tenant_id = @tenant_id
    )
        THROW 55004, 'ExportJob niet gevonden of behoort niet tot deze tenant.', 1;

    UPDATE import.ExportJob
    SET status_code        = @status_code,
        completed_at_utc   = SYSUTCDATETIME(),
        row_count          = @row_count,
        error_message      = @error_message
    WHERE job_id   = @job_id
      AND tenant_id = @tenant_id;

    SELECT
        j.job_id            AS JobId,
        j.export_type_code  AS ExportTypeCode,
        j.status_code       AS StatusCode,
        j.row_count         AS RecordCount,
        j.started_at_utc    AS StartedAtUtc,
        j.completed_at_utc  AS CompletedAtUtc,
        j.error_message     AS ErrorMessage
    FROM import.ExportJob j
    WHERE j.job_id = @job_id;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

-- =============================================================================
-- SP: import.SP_GetExportJobStatus
-- Geeft de job-details + bijbehorende bestanden terug voor één job.
-- =============================================================================
CREATE OR ALTER PROCEDURE import.SP_GetExportJobStatus
    @job_id     UNIQUEIDENTIFIER,
    @tenant_id  UNIQUEIDENTIFIER
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    IF NOT EXISTS (
        SELECT 1 FROM import.ExportJob
        WHERE job_id = @job_id AND tenant_id = @tenant_id
    )
        THROW 55005, 'ExportJob niet gevonden of behoort niet tot deze tenant.', 1;

    -- Job header
    SELECT
        j.job_id                AS JobId,
        j.tenant_id             AS TenantId,
        j.export_type_code      AS ExportTypeCode,
        j.status_code           AS StatusCode,
        j.period_start          AS PeriodStart,
        j.period_end            AS PeriodEnd,
        j.row_count             AS RecordCount,
        j.started_at_utc        AS StartedAtUtc,
        j.completed_at_utc      AS CompletedAtUtc,
        j.error_message         AS ErrorMessage,
        j.created_at_utc        AS CreatedAtUtc
    FROM import.ExportJob j
    WHERE j.job_id = @job_id;

    -- Associated files
    SELECT
        f.file_id           AS FileId,
        f.file_name         AS FileName,
        f.file_format_code  AS FileFormatCode,
        f.byte_size         AS ByteSize,
        f.row_count         AS RecordCount,
        f.storage_path      AS StoragePath,
        f.created_at_utc    AS CreatedAtUtc
    FROM import.ExportJobFile f
    WHERE f.job_id = @job_id
    ORDER BY f.created_at_utc;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

-- =============================================================================
-- SP: import.SP_GetExportJobQueue
-- Geeft recente jobs voor een tenant, nieuwste eerst.
-- =============================================================================
CREATE OR ALTER PROCEDURE import.SP_GetExportJobQueue
    @tenant_id          UNIQUEIDENTIFIER,
    @export_type_code   NVARCHAR(40)    = NULL,   -- NULL = all types
    @status_code        NVARCHAR(20)    = NULL,   -- NULL = all statuses
    @limit              INT             = 50
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    IF @limit < 1 OR @limit > 500
        SET @limit = 50;

    SELECT TOP (@limit)
        j.job_id                AS JobId,
        j.export_type_code      AS ExportTypeCode,
        j.status_code           AS StatusCode,
        j.period_start          AS PeriodStart,
        j.period_end            AS PeriodEnd,
        j.row_count             AS RecordCount,
        j.started_at_utc        AS StartedAtUtc,
        j.completed_at_utc      AS CompletedAtUtc,
        j.created_at_utc        AS CreatedAtUtc
    FROM import.ExportJob j
    WHERE j.tenant_id = @tenant_id
      AND (@export_type_code IS NULL OR j.export_type_code = @export_type_code)
      AND (@status_code      IS NULL OR j.status_code      = @status_code)
    ORDER BY j.created_at_utc DESC;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

PRINT 'Migration 048 complete: ExportJob lifecycle SPs ready.';
GO
