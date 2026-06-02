SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [YafesPars];
GO

PRINT 'Running migration: 004__create_institution_domain.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'institution.InstitutionRole', N'U') IS NULL
    BEGIN
        CREATE TABLE institution.InstitutionRole (
            institution_role_code NVARCHAR(20) NOT NULL,
            label_nl NVARCHAR(160) NOT NULL,
            label_fr NVARCHAR(160) NULL,
            label_en NVARCHAR(160) NULL,
            label_tr NVARCHAR(160) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_InstitutionRole_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_InstitutionRole PRIMARY KEY (institution_role_code)
        );
    END;

    IF OBJECT_ID(N'institution.InstitutionIdentifierType', N'U') IS NULL
    BEGIN
        CREATE TABLE institution.InstitutionIdentifierType (
            id_type_code NVARCHAR(20) NOT NULL,
            label_nl NVARCHAR(160) NOT NULL,
            label_fr NVARCHAR(160) NULL,
            label_en NVARCHAR(160) NULL,
            label_tr NVARCHAR(160) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_InstitutionIdentifierType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_InstitutionIdentifierType PRIMARY KEY (id_type_code)
        );
    END;

    IF OBJECT_ID(N'institution.InstitutionAddressRole', N'U') IS NULL
    BEGIN
        CREATE TABLE institution.InstitutionAddressRole (
            address_role_code NVARCHAR(20) NOT NULL,
            label_nl NVARCHAR(120) NOT NULL,
            label_fr NVARCHAR(120) NULL,
            label_en NVARCHAR(120) NULL,
            label_tr NVARCHAR(120) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_InstitutionAddressRole_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_InstitutionAddressRole PRIMARY KEY (address_role_code)
        );
    END;

    IF OBJECT_ID(N'institution.Institution', N'U') IS NULL
    BEGIN
        CREATE TABLE institution.Institution (
            institution_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_Institution_institution_id DEFAULT NEWSEQUENTIALID(),
            tenant_id UNIQUEIDENTIFIER NOT NULL,
            institution_code NVARCHAR(80) NOT NULL,
            name NVARCHAR(200) NOT NULL,
            legal_name NVARCHAR(200) NULL,
            vat_number NVARCHAR(30) NULL,
            country_code CHAR(2) NOT NULL
                CONSTRAINT DF_Institution_country_code DEFAULT 'BE',
            is_active BIT NOT NULL
                CONSTRAINT DF_Institution_is_active DEFAULT 1,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_Institution_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_Institution_updated_at_utc DEFAULT SYSUTCDATETIME(),
            created_by_user_id UNIQUEIDENTIFIER NULL,
            updated_by_user_id UNIQUEIDENTIFIER NULL,
            is_deleted BIT NOT NULL
                CONSTRAINT DF_Institution_is_deleted DEFAULT 0,
            CONSTRAINT PK_Institution PRIMARY KEY (institution_id),
            CONSTRAINT UQ_Institution_tenant_code UNIQUE (tenant_id, institution_code),
            CONSTRAINT FK_Institution_Tenant FOREIGN KEY (tenant_id)
                REFERENCES core.Tenant (tenant_id),
            CONSTRAINT FK_Institution_AppUser_CreatedBy FOREIGN KEY (created_by_user_id)
                REFERENCES core.AppUser (user_id),
            CONSTRAINT FK_Institution_AppUser_UpdatedBy FOREIGN KEY (updated_by_user_id)
                REFERENCES core.AppUser (user_id)
        );
    END;

    IF OBJECT_ID(N'institution.InstitutionIdentifier', N'U') IS NULL
    BEGIN
        CREATE TABLE institution.InstitutionIdentifier (
            institution_identifier_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_InstitutionIdentifier_institution_identifier_id DEFAULT NEWID(),
            institution_id UNIQUEIDENTIFIER NOT NULL,
            id_type_code NVARCHAR(20) NOT NULL,
            id_value NVARCHAR(80) NOT NULL,
            valid_from DATE NOT NULL,
            valid_to DATE NULL,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_InstitutionIdentifier_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_InstitutionIdentifier_updated_at_utc DEFAULT SYSUTCDATETIME(),
            created_by_user_id UNIQUEIDENTIFIER NULL,
            updated_by_user_id UNIQUEIDENTIFIER NULL,
            is_deleted BIT NOT NULL
                CONSTRAINT DF_InstitutionIdentifier_is_deleted DEFAULT 0,
            CONSTRAINT PK_InstitutionIdentifier PRIMARY KEY (institution_identifier_id),
            CONSTRAINT UQ_InstitutionIdentifier_type_value UNIQUE (institution_id, id_type_code, id_value),
            CONSTRAINT CK_InstitutionIdentifier_dates
                CHECK (valid_to IS NULL OR valid_to >= valid_from),
            CONSTRAINT FK_InstitutionIdentifier_Institution FOREIGN KEY (institution_id)
                REFERENCES institution.Institution (institution_id),
            CONSTRAINT FK_InstitutionIdentifier_InstitutionIdentifierType FOREIGN KEY (id_type_code)
                REFERENCES institution.InstitutionIdentifierType (id_type_code)
        );
    END;

    IF OBJECT_ID(N'institution.InstitutionAddress', N'U') IS NULL
    BEGIN
        CREATE TABLE institution.InstitutionAddress (
            institution_address_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_InstitutionAddress_institution_address_id DEFAULT NEWID(),
            institution_id UNIQUEIDENTIFIER NOT NULL,
            address_role_code NVARCHAR(20) NOT NULL,
            street NVARCHAR(200) NOT NULL,
            house_number NVARCHAR(30) NOT NULL,
            box NVARCHAR(30) NULL,
            postal_code NVARCHAR(20) NOT NULL,
            city NVARCHAR(120) NOT NULL,
            country NVARCHAR(80) NOT NULL,
            country_code CHAR(2) NOT NULL
                CONSTRAINT DF_InstitutionAddress_country_code DEFAULT 'BE',
            remark NVARCHAR(400) NULL,
            is_primary BIT NOT NULL
                CONSTRAINT DF_InstitutionAddress_is_primary DEFAULT 0,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_InstitutionAddress_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_InstitutionAddress_updated_at_utc DEFAULT SYSUTCDATETIME(),
            created_by_user_id UNIQUEIDENTIFIER NULL,
            updated_by_user_id UNIQUEIDENTIFIER NULL,
            is_deleted BIT NOT NULL
                CONSTRAINT DF_InstitutionAddress_is_deleted DEFAULT 0,
            CONSTRAINT PK_InstitutionAddress PRIMARY KEY (institution_address_id),
            CONSTRAINT FK_InstitutionAddress_Institution FOREIGN KEY (institution_id)
                REFERENCES institution.Institution (institution_id),
            CONSTRAINT FK_InstitutionAddress_InstitutionAddressRole FOREIGN KEY (address_role_code)
                REFERENCES institution.InstitutionAddressRole (address_role_code)
        );
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_Institution_name'
          AND object_id = OBJECT_ID(N'institution.Institution')
    )
        CREATE INDEX IX_Institution_name
        ON institution.Institution (name);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_InstitutionIdentifier_value'
          AND object_id = OBJECT_ID(N'institution.InstitutionIdentifier')
    )
        CREATE INDEX IX_InstitutionIdentifier_value
        ON institution.InstitutionIdentifier (id_type_code, id_value);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_InstitutionIdentifier_institution_id'
          AND object_id = OBJECT_ID(N'institution.InstitutionIdentifier')
    )
        CREATE INDEX IX_InstitutionIdentifier_institution_id
        ON institution.InstitutionIdentifier (institution_id);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_InstitutionAddress_institution_id'
          AND object_id = OBJECT_ID(N'institution.InstitutionAddress')
    )
        CREATE INDEX IX_InstitutionAddress_institution_id
        ON institution.InstitutionAddress (institution_id);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'UQ_InstitutionAddress_primary'
          AND object_id = OBJECT_ID(N'institution.InstitutionAddress')
    )
        CREATE UNIQUE INDEX UQ_InstitutionAddress_primary
        ON institution.InstitutionAddress (institution_id)
        WHERE is_primary = 1 AND is_deleted = 0;

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'004__create_institution_domain.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'004__create_institution_domain.sql',
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
