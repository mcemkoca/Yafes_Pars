SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [YafesPars];
GO

PRINT 'Running migration: 009__create_document_domain.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'document.DocumentType', N'U') IS NULL
    BEGIN
        CREATE TABLE document.DocumentType (
            document_type_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(160) NOT NULL,
            label_fr NVARCHAR(160) NULL,
            label_en NVARCHAR(160) NULL,
            label_tr NVARCHAR(160) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_DocumentType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_DocumentType PRIMARY KEY (document_type_code)
        );
    END;

    IF OBJECT_ID(N'document.Document', N'U') IS NULL
    BEGIN
        CREATE TABLE document.Document (
            document_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_Document_document_id DEFAULT NEWSEQUENTIALID(),
            tenant_id UNIQUEIDENTIFIER NOT NULL,
            owner_entity_type NVARCHAR(60) NOT NULL,
            owner_entity_id UNIQUEIDENTIFIER NOT NULL,
            document_type_code NVARCHAR(80) NOT NULL,
            file_name NVARCHAR(260) NOT NULL,
            file_extension NVARCHAR(20) NOT NULL,
            mime_type NVARCHAR(120) NOT NULL,
            file_size_bytes BIGINT NOT NULL,
            storage_provider NVARCHAR(40) NOT NULL,
            storage_key NVARCHAR(500) NOT NULL,
            checksum_sha256 NVARCHAR(128) NULL,
            language_code CHAR(2) NULL,
            uploaded_by_user_id UNIQUEIDENTIFIER NULL,
            uploaded_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_Document_uploaded_at_utc DEFAULT SYSUTCDATETIME(),
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_Document_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_Document_updated_at_utc DEFAULT SYSUTCDATETIME(),
            is_deleted BIT NOT NULL
                CONSTRAINT DF_Document_is_deleted DEFAULT 0,
            deleted_at_utc DATETIME2(0) NULL,
            CONSTRAINT PK_Document PRIMARY KEY (document_id),
            CONSTRAINT CK_Document_owner_entity_type
                CHECK (owner_entity_type IN (N'PERSON', N'INSTITUTION', N'POLICY', N'CLAIM', N'RISK_OBJECT')),
            CONSTRAINT CK_Document_file_size CHECK (file_size_bytes >= 0),
            CONSTRAINT CK_Document_deleted_state
                CHECK ((is_deleted = 0 AND deleted_at_utc IS NULL) OR (is_deleted = 1 AND deleted_at_utc IS NOT NULL)),
            CONSTRAINT FK_Document_Tenant FOREIGN KEY (tenant_id)
                REFERENCES core.Tenant (tenant_id),
            CONSTRAINT FK_Document_DocumentType FOREIGN KEY (document_type_code)
                REFERENCES document.DocumentType (document_type_code),
            CONSTRAINT FK_Document_Language FOREIGN KEY (language_code)
                REFERENCES ref.Language (language_code),
            CONSTRAINT FK_Document_AppUser_UploadedBy FOREIGN KEY (uploaded_by_user_id)
                REFERENCES core.AppUser (user_id)
        );
    END;

    IF OBJECT_ID(N'document.DocumentLink', N'U') IS NULL
    BEGIN
        CREATE TABLE document.DocumentLink (
            document_id UNIQUEIDENTIFIER NOT NULL,
            owner_entity_type NVARCHAR(60) NOT NULL,
            owner_entity_id UNIQUEIDENTIFIER NOT NULL,
            link_role_code NVARCHAR(40) NULL,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_DocumentLink_created_at_utc DEFAULT SYSUTCDATETIME(),
            CONSTRAINT PK_DocumentLink PRIMARY KEY (document_id, owner_entity_type, owner_entity_id),
            CONSTRAINT CK_DocumentLink_owner_entity_type
                CHECK (owner_entity_type IN (N'PERSON', N'INSTITUTION', N'POLICY', N'CLAIM', N'RISK_OBJECT')),
            CONSTRAINT FK_DocumentLink_Document FOREIGN KEY (document_id)
                REFERENCES document.Document (document_id)
        );
    END;

    IF OBJECT_ID(N'document.DocumentVersion', N'U') IS NULL
    BEGIN
        CREATE TABLE document.DocumentVersion (
            document_version_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_DocumentVersion_document_version_id DEFAULT NEWSEQUENTIALID(),
            document_id UNIQUEIDENTIFIER NOT NULL,
            version_no INT NOT NULL,
            file_name NVARCHAR(260) NOT NULL,
            file_extension NVARCHAR(20) NOT NULL,
            mime_type NVARCHAR(120) NOT NULL,
            file_size_bytes BIGINT NOT NULL,
            storage_provider NVARCHAR(40) NOT NULL,
            storage_key NVARCHAR(500) NOT NULL,
            checksum_sha256 NVARCHAR(128) NULL,
            uploaded_by_user_id UNIQUEIDENTIFIER NULL,
            uploaded_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_DocumentVersion_uploaded_at_utc DEFAULT SYSUTCDATETIME(),
            CONSTRAINT PK_DocumentVersion PRIMARY KEY (document_version_id),
            CONSTRAINT UQ_DocumentVersion_document_version_no UNIQUE (document_id, version_no),
            CONSTRAINT CK_DocumentVersion_version_no CHECK (version_no > 0),
            CONSTRAINT CK_DocumentVersion_file_size CHECK (file_size_bytes >= 0),
            CONSTRAINT FK_DocumentVersion_Document FOREIGN KEY (document_id)
                REFERENCES document.Document (document_id),
            CONSTRAINT FK_DocumentVersion_AppUser_UploadedBy FOREIGN KEY (uploaded_by_user_id)
                REFERENCES core.AppUser (user_id)
        );
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_Document_tenant_owner'
          AND object_id = OBJECT_ID(N'document.Document')
    )
        CREATE INDEX IX_Document_tenant_owner
        ON document.Document (tenant_id, owner_entity_type, owner_entity_id);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'UQ_Document_storage'
          AND object_id = OBJECT_ID(N'document.Document')
    )
        CREATE UNIQUE INDEX UQ_Document_storage
        ON document.Document (storage_provider, storage_key)
        WHERE is_deleted = 0;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_DocumentLink_owner'
          AND object_id = OBJECT_ID(N'document.DocumentLink')
    )
        CREATE INDEX IX_DocumentLink_owner
        ON document.DocumentLink (owner_entity_type, owner_entity_id);

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'009__create_document_domain.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'009__create_document_domain.sql',
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
