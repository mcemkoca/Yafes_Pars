-- =============================================================================
-- Migration 030: Import staging / İçe aktarma hazırlama tabloları
-- Adds: import schema, import.PolicyImport (staging),
--       import.SP_ValidateImportBatch, import.SP_CommitImportBatch
-- =============================================================================
USE [YafesPars];
GO

BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'030__add_import_staging')
    BEGIN

        IF SCHEMA_ID(N'import') IS NULL
            EXEC(N'CREATE SCHEMA import');

        -- --- import.PolicyImport (staging tabel) ---------------------------
        IF NOT EXISTS (
            SELECT 1 FROM sys.tables
            WHERE schema_id = SCHEMA_ID(N'import') AND name = N'PolicyImport'
        )
        BEGIN
            CREATE TABLE import.PolicyImport (
                import_row_id       BIGINT IDENTITY(1,1)     NOT NULL
                                        CONSTRAINT PK_import_PolicyImport PRIMARY KEY,
                batch_id            UNIQUEIDENTIFIER         NOT NULL,
                tenant_id           UNIQUEIDENTIFIER         NOT NULL,
                row_number          INT                      NOT NULL,

                -- Bron-velden (ruwe invoer)
                contract_number     NVARCHAR(40)             NULL,
                contract_domain_code NVARCHAR(40)            NULL,
                contract_type_code  NVARCHAR(80)             NULL,
                start_date          NVARCHAR(20)             NULL,
                end_date            NVARCHAR(20)             NULL,
                policyholder_rrn    NVARCHAR(11)             NULL,
                policyholder_name   NVARCHAR(200)            NULL,
                gross_premium       NVARCHAR(20)             NULL,
                currency_code       NCHAR(3)                 NULL,

                -- Validatie-status
                validation_status   NVARCHAR(16)             NOT NULL DEFAULT N'PENDING'
                                        CONSTRAINT CK_PolicyImport_Status CHECK (
                                            validation_status IN (N'PENDING', N'VALID', N'INVALID', N'IMPORTED')
                                        ),
                validation_errors   NVARCHAR(MAX)            NULL,

                -- Tracking
                created_at_utc      DATETIME2(2)             NOT NULL DEFAULT SYSUTCDATETIME(),
                imported_at_utc     DATETIME2(2)             NULL,
                created_by_user_id  UNIQUEIDENTIFIER         NULL
            );

            CREATE INDEX IX_PolicyImport_BatchId
                ON import.PolicyImport (batch_id);
            CREATE INDEX IX_PolicyImport_TenantStatus
                ON import.PolicyImport (tenant_id, validation_status);

            PRINT 'import.PolicyImport created.';
        END

        INSERT INTO core.SchemaMigration (migration_name, execution_status)
        VALUES (N'030__add_import_staging', N'SUCCESS');

    END

COMMIT TRANSACTION;
GO

-- --- import.SP_ValidateImportBatch ----------------------------------------
CREATE OR ALTER PROCEDURE import.SP_ValidateImportBatch
    @tenant_id  UNIQUEIDENTIFIER,
    @batch_id   UNIQUEIDENTIFIER,
    @valid_count   INT OUTPUT,
    @invalid_count INT OUTPUT
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    -- Reset naar PENDING voor hervalidatie
    UPDATE import.PolicyImport
    SET validation_status = N'PENDING', validation_errors = NULL
    WHERE batch_id = @batch_id AND tenant_id = @tenant_id;

    -- Valideer elke rij
    UPDATE import.PolicyImport
    SET
        validation_status = CASE
            WHEN contract_number IS NULL OR LEN(LTRIM(RTRIM(contract_number))) = 0
                THEN N'INVALID'
            WHEN contract_domain_code IS NULL OR LEN(LTRIM(RTRIM(contract_domain_code))) = 0
                THEN N'INVALID'
            WHEN start_date IS NULL OR TRY_CAST(start_date AS DATE) IS NULL
                THEN N'INVALID'
            ELSE N'VALID'
        END,
        validation_errors = CASE
            WHEN contract_number IS NULL OR LEN(LTRIM(RTRIM(contract_number))) = 0
                THEN N'contract_number is verplicht.'
            WHEN contract_domain_code IS NULL OR LEN(LTRIM(RTRIM(contract_domain_code))) = 0
                THEN N'contract_domain_code is verplicht.'
            WHEN start_date IS NULL OR TRY_CAST(start_date AS DATE) IS NULL
                THEN N'start_date is geen geldige datum (verwacht yyyy-MM-dd).'
            ELSE NULL
        END
    WHERE batch_id = @batch_id AND tenant_id = @tenant_id;

    SELECT @valid_count   = COUNT(*) FROM import.PolicyImport
    WHERE batch_id = @batch_id AND tenant_id = @tenant_id AND validation_status = N'VALID';

    SELECT @invalid_count = COUNT(*) FROM import.PolicyImport
    WHERE batch_id = @batch_id AND tenant_id = @tenant_id AND validation_status = N'INVALID';
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

PRINT 'Migration 030 complete: import.PolicyImport + SP_ValidateImportBatch.';
GO
