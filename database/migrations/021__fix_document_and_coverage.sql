-- =============================================================================
-- Migration 021 — Document & Coverage Fixes
-- Fixes:
--   1. document.DocumentLink (009) → document.DocumentLinks (019) consolidation
--   2. sp_CreateDocument: remove NEWID() owner hack, require explicit owner params
--   3. sp_LinkDocument: switch to document.DocumentLinks (PascalCase schema)
--   4. sp_AddCoverageItem: add coverage_type_code catalog validation
-- =============================================================================
USE [YafesPars];
GO

PRINT 'Running migration: 021__fix_document_and_coverage.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- ── 1. Migrate DocumentLink → DocumentLinks then drop old table ────────────
    IF OBJECT_ID(N'document.DocumentLink', N'U') IS NOT NULL
    BEGIN
        -- Copy any existing rows that aren't already in DocumentLinks
        INSERT INTO document.DocumentLinks (TenantId, DocumentId, EntityType, EntityId)
        SELECT DISTINCT
            d.tenant_id,
            dl.document_id,
            dl.owner_entity_type,
            dl.owner_entity_id
        FROM document.DocumentLink dl
        INNER JOIN document.Document d ON d.document_id = dl.document_id
        WHERE NOT EXISTS (
            SELECT 1
            FROM document.DocumentLinks existing
            WHERE existing.DocumentId  = dl.document_id
              AND existing.EntityType  = dl.owner_entity_type
              AND existing.EntityId    = dl.owner_entity_id
        );

        -- Drop legacy table (FK in sp_LinkDocument will be switched below)
        DROP TABLE document.DocumentLink;

        PRINT 'document.DocumentLink migrated to document.DocumentLinks and dropped.';
    END;

    -- ── 2. Drop also the IX_DocumentLink_owner index (was on dropped table) ───
    -- Already gone with the table drop above; no explicit action needed.

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'021__fix_document_and_coverage.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (migration_name, execution_status)
        VALUES (N'021__fix_document_and_coverage.sql', N'SUCCESS');
    END;

    COMMIT TRANSACTION;
    PRINT 'Migration 021 (schema changes) committed.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;
GO

-- ── 3. sp_CreateDocument — explicit owner params, no NEWID() hack ──────────
CREATE OR ALTER PROCEDURE document.sp_CreateDocument
    @tenant_id             UNIQUEIDENTIFIER,
    @document_type_code    NVARCHAR(80),
    @file_name             NVARCHAR(260),
    @mime_type             NVARCHAR(120)    = N'application/octet-stream',
    @file_size_bytes       BIGINT           = 0,
    @storage_uri           NVARCHAR(500)    = NULL,
    @description           NVARCHAR(500)    = NULL,
    @uploaded_by_user_id   UNIQUEIDENTIFIER = NULL,
    @owner_entity_type     NVARCHAR(60)     = N'POLICY',
    @owner_entity_id       UNIQUEIDENTIFIER = NULL,
    @document_id           UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @file_name IS NULL OR LEN(TRIM(@file_name)) = 0
        THROW 51810, 'file_name is required.', 1;
    IF @document_type_code IS NULL OR LEN(TRIM(@document_type_code)) = 0
        THROW 51811, 'document_type_code is required.', 1;
    IF @owner_entity_type NOT IN (N'PERSON', N'INSTITUTION', N'POLICY', N'CLAIM', N'RISK_OBJECT')
        THROW 51812, 'owner_entity_type must be PERSON, INSTITUTION, POLICY, CLAIM or RISK_OBJECT.', 1;
    IF @owner_entity_id IS NULL
        THROW 51813, 'owner_entity_id is required.', 1;

    DECLARE @ext NVARCHAR(20) = RIGHT(@file_name, CHARINDEX('.', REVERSE(@file_name)) - 1);
    IF LEN(@ext) = 0 SET @ext = N'bin';

    DECLARE @NewDoc TABLE (document_id UNIQUEIDENTIFIER NOT NULL);

    INSERT INTO document.Document
        (tenant_id, owner_entity_type, owner_entity_id,
         document_type_code, file_name, file_extension, mime_type,
         file_size_bytes, storage_provider, storage_key,
         uploaded_by_user_id)
    OUTPUT inserted.document_id INTO @NewDoc
    VALUES
        (@tenant_id, @owner_entity_type, @owner_entity_id,
         @document_type_code, @file_name, @ext,
         ISNULL(@mime_type, N'application/octet-stream'),
         ISNULL(@file_size_bytes, 0),
         N'AZURE_BLOB',
         ISNULL(@storage_uri, N'pending/' + CAST(NEWID() AS NVARCHAR(36))),
         @uploaded_by_user_id);

    SELECT @document_id = document_id FROM @NewDoc;
END;
GO

-- ── 4. sp_LinkDocument — use document.DocumentLinks (migration 019 table) ──
CREATE OR ALTER PROCEDURE document.sp_LinkDocument
    @tenant_id      UNIQUEIDENTIFIER,
    @document_id    UNIQUEIDENTIFIER,
    @entity_type    NVARCHAR(64),
    @entity_id      UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM document.Document WHERE document_id = @document_id AND tenant_id = @tenant_id)
        THROW 51820, 'Document not found or does not belong to tenant.', 1;

    IF @entity_type NOT IN (N'PERSON', N'INSTITUTION', N'POLICY', N'CLAIM', N'RISK_OBJECT')
        THROW 51821, 'entity_type must be PERSON, INSTITUTION, POLICY, CLAIM or RISK_OBJECT.', 1;

    IF NOT EXISTS (
        SELECT 1 FROM document.DocumentLinks
        WHERE DocumentId = @document_id
          AND EntityType = @entity_type
          AND EntityId   = @entity_id
    )
    BEGIN
        INSERT INTO document.DocumentLinks (TenantId, DocumentId, EntityType, EntityId)
        VALUES (@tenant_id, @document_id, @entity_type, @entity_id);
    END;
END;
GO

-- ── 5. coverage.CoverageType catalog table (if not yet present) ────────────
IF OBJECT_ID(N'coverage.CoverageType', N'U') IS NULL
BEGIN
    CREATE TABLE coverage.CoverageType (
        coverage_type_code NVARCHAR(80)  NOT NULL,
        label_tr           NVARCHAR(200) NOT NULL,
        label_en           NVARCHAR(200) NULL,
        is_active          BIT           NOT NULL CONSTRAINT DF_CoverageType_is_active DEFAULT 1,
        sort_order         INT           NULL,
        CONSTRAINT PK_CoverageType PRIMARY KEY (coverage_type_code)
    );

    -- Seed: common Turkish insurance coverage types
    INSERT INTO coverage.CoverageType (coverage_type_code, label_tr, label_en)
    VALUES
        (N'KASKO',           N'Kasko Sigortası',           N'Comprehensive Vehicle'),
        (N'TRAFIK',          N'Trafik Sigortası',          N'Third-Party Liability'),
        (N'KONUT',           N'Konut Sigortası',           N'Home Insurance'),
        (N'YANGIN',          N'Yangın Teminatı',           N'Fire Coverage'),
        (N'DEPREM',          N'Deprem Teminatı',           N'Earthquake Coverage'),
        (N'HIRSIZLIK',       N'Hırsızlık Teminatı',       N'Theft Coverage'),
        (N'SAGLIK',          N'Sağlık Sigortası',          N'Health Insurance'),
        (N'HAYAT',           N'Hayat Sigortası',           N'Life Insurance'),
        (N'SORUMLULUK',      N'Sorumluluk Sigortası',      N'Liability Insurance'),
        (N'SEYAHAT',         N'Seyahat Sigortası',         N'Travel Insurance'),
        (N'DASK',            N'DASK (Zorunlu Deprem)',     N'Mandatory Earthquake'),
        (N'ISE_IADE',        N'İşe İade Teminatı',        N'Reinstatement Coverage'),
        (N'FERDI_KAZA',      N'Ferdi Kaza Sigortası',     N'Personal Accident'),
        (N'MAKINE_KIRILMASI', N'Makine Kırılması',        N'Machine Breakdown'),
        (N'GENEL',           N'Genel Teminat',             N'General Coverage');

    PRINT 'coverage.CoverageType created and seeded.';
END;
GO

-- ── 6. sp_AddCoverageItem — validate coverage_type_code against catalog ────
CREATE OR ALTER PROCEDURE coverage.sp_AddCoverageItem
    @tenant_id             UNIQUEIDENTIFIER,
    @contract_id           UNIQUEIDENTIFIER,
    @coverage_type_code    NVARCHAR(80),
    @coverage_limit        DECIMAL(18,2),
    @deductible            DECIMAL(18,2)    = NULL,
    @currency_code         NCHAR(3)         = N'TRY',
    @coverage_item_id      UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @contract_id IS NULL
        THROW 51750, 'contract_id is required.', 1;
    IF @coverage_type_code IS NULL OR LEN(TRIM(@coverage_type_code)) = 0
        THROW 51751, 'coverage_type_code is required.', 1;
    IF @coverage_limit <= 0
        THROW 51752, 'coverage_limit must be greater than zero.', 1;

    IF NOT EXISTS (SELECT 1 FROM coverage.CoverageType WHERE coverage_type_code = @coverage_type_code AND is_active = 1)
        THROW 51753, 'coverage_type_code does not exist or is inactive.', 1;

    DECLARE @NewItem TABLE (coverage_item_id UNIQUEIDENTIFIER NOT NULL);

    INSERT INTO coverage.ContractCoverageItem
        (tenant_id, contract_id, coverage_type_code, coverage_limit, deductible, currency_code)
    OUTPUT inserted.coverage_item_id INTO @NewItem
    VALUES (@tenant_id, @contract_id, @coverage_type_code, @coverage_limit, @deductible, ISNULL(@currency_code, N'TRY'));

    SELECT @coverage_item_id = coverage_item_id FROM @NewItem;
END;
GO

PRINT 'Migration 021 completed successfully.';
GO
