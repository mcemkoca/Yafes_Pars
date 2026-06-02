SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [YafesPars];
GO

PRINT 'Running migration: 003__create_person_domain.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'ref.Language', N'U') IS NULL
    BEGIN
        CREATE TABLE ref.Language (
            language_code CHAR(2) NOT NULL,
            label_nl NVARCHAR(80) NOT NULL,
            label_fr NVARCHAR(80) NULL,
            label_en NVARCHAR(80) NULL,
            label_tr NVARCHAR(80) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_Language_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_Language PRIMARY KEY (language_code)
        );
    END;

    IF OBJECT_ID(N'ref.Title', N'U') IS NULL
    BEGIN
        CREATE TABLE ref.Title (
            title_code NVARCHAR(10) NOT NULL,
            label_nl NVARCHAR(40) NOT NULL,
            label_fr NVARCHAR(40) NULL,
            label_en NVARCHAR(40) NULL,
            label_tr NVARCHAR(40) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_Title_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_Title PRIMARY KEY (title_code)
        );
    END;

    IF OBJECT_ID(N'ref.PhoneType', N'U') IS NULL
    BEGIN
        CREATE TABLE ref.PhoneType (
            phone_type_code NVARCHAR(20) NOT NULL,
            label_nl NVARCHAR(40) NOT NULL,
            label_fr NVARCHAR(40) NULL,
            label_en NVARCHAR(40) NULL,
            label_tr NVARCHAR(40) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_PhoneType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_PhoneType PRIMARY KEY (phone_type_code)
        );
    END;

    IF OBJECT_ID(N'ref.SocialType', N'U') IS NULL
    BEGIN
        CREATE TABLE ref.SocialType (
            social_type_code NVARCHAR(20) NOT NULL,
            label_nl NVARCHAR(40) NOT NULL,
            label_fr NVARCHAR(40) NULL,
            label_en NVARCHAR(40) NULL,
            label_tr NVARCHAR(40) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_SocialType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_SocialType PRIMARY KEY (social_type_code)
        );
    END;

    IF OBJECT_ID(N'ref.ProfessionalStatus', N'U') IS NULL
    BEGIN
        CREATE TABLE ref.ProfessionalStatus (
            professional_status_code NVARCHAR(30) NOT NULL,
            label_nl NVARCHAR(100) NOT NULL,
            label_fr NVARCHAR(100) NULL,
            label_en NVARCHAR(100) NULL,
            label_tr NVARCHAR(100) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_ProfessionalStatus_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_ProfessionalStatus PRIMARY KEY (professional_status_code)
        );
    END;

    IF OBJECT_ID(N'ref.PersonType', N'U') IS NULL
    BEGIN
        CREATE TABLE ref.PersonType (
            person_type_code NVARCHAR(60) NOT NULL,
            label_nl NVARCHAR(120) NOT NULL,
            label_fr NVARCHAR(120) NULL,
            label_en NVARCHAR(120) NULL,
            label_tr NVARCHAR(120) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_PersonType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_PersonType PRIMARY KEY (person_type_code)
        );
    END;

    IF OBJECT_ID(N'person.PersonAddressRole', N'U') IS NULL
    BEGIN
        CREATE TABLE person.PersonAddressRole (
            address_role_code NVARCHAR(20) NOT NULL,
            label_nl NVARCHAR(120) NOT NULL,
            label_fr NVARCHAR(120) NULL,
            label_en NVARCHAR(120) NULL,
            label_tr NVARCHAR(120) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_PersonAddressRole_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_PersonAddressRole PRIMARY KEY (address_role_code)
        );
    END;

    IF OBJECT_ID(N'person.PersonRelationType', N'U') IS NULL
    BEGIN
        CREATE TABLE person.PersonRelationType (
            relation_type_code NVARCHAR(50) NOT NULL,
            relation_category NVARCHAR(20) NOT NULL,
            label_nl NVARCHAR(160) NOT NULL,
            label_fr NVARCHAR(160) NULL,
            label_en NVARCHAR(160) NULL,
            label_tr NVARCHAR(160) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_PersonRelationType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_PersonRelationType PRIMARY KEY (relation_type_code)
        );
    END;

    IF OBJECT_ID(N'person.Person', N'U') IS NULL
    BEGIN
        CREATE TABLE person.Person (
            person_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_Person_person_id DEFAULT NEWSEQUENTIALID(),
            tenant_id UNIQUEIDENTIFIER NOT NULL,
            person_kind NVARCHAR(10) NOT NULL,
            dossier NVARCHAR(50) NULL,
            language_code CHAR(2) NULL,
            nationality NVARCHAR(80) NULL,
            subagent_person_id UNIQUEIDENTIFIER NULL,
            manager_person_id UNIQUEIDENTIFIER NULL,
            portfolio_person_id UNIQUEIDENTIFIER NULL,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_Person_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_Person_updated_at_utc DEFAULT SYSUTCDATETIME(),
            created_by_user_id UNIQUEIDENTIFIER NULL,
            updated_by_user_id UNIQUEIDENTIFIER NULL,
            is_deleted BIT NOT NULL
                CONSTRAINT DF_Person_is_deleted DEFAULT 0,
            CONSTRAINT PK_Person PRIMARY KEY (person_id),
            CONSTRAINT CK_Person_person_kind CHECK (person_kind IN (N'NATURAL', N'LEGAL')),
            CONSTRAINT FK_Person_Tenant FOREIGN KEY (tenant_id)
                REFERENCES core.Tenant (tenant_id),
            CONSTRAINT FK_Person_Language FOREIGN KEY (language_code)
                REFERENCES ref.Language (language_code),
            CONSTRAINT FK_Person_Person_Subagent FOREIGN KEY (subagent_person_id)
                REFERENCES person.Person (person_id),
            CONSTRAINT FK_Person_Person_Manager FOREIGN KEY (manager_person_id)
                REFERENCES person.Person (person_id),
            CONSTRAINT FK_Person_Person_Portfolio FOREIGN KEY (portfolio_person_id)
                REFERENCES person.Person (person_id),
            CONSTRAINT FK_Person_AppUser_CreatedBy FOREIGN KEY (created_by_user_id)
                REFERENCES core.AppUser (user_id),
            CONSTRAINT FK_Person_AppUser_UpdatedBy FOREIGN KEY (updated_by_user_id)
                REFERENCES core.AppUser (user_id)
        );
    END;

    IF OBJECT_ID(N'person.NaturalPerson', N'U') IS NULL
    BEGIN
        CREATE TABLE person.NaturalPerson (
            person_id UNIQUEIDENTIFIER NOT NULL,
            first_name NVARCHAR(100) NULL,
            last_name NVARCHAR(100) NULL,
            birth_date DATE NULL,
            birth_place NVARCHAR(120) NULL,
            death_date DATE NULL,
            gender NVARCHAR(20) NULL,
            marital_status NVARCHAR(50) NULL,
            national_number NVARCHAR(30) NULL,
            passport_number NVARCHAR(30) NULL,
            id_card_number NVARCHAR(30) NULL,
            id_card_valid_from DATE NULL,
            id_card_valid_to DATE NULL,
            title_code NVARCHAR(10) NULL,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_NaturalPerson_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_NaturalPerson_updated_at_utc DEFAULT SYSUTCDATETIME(),
            created_by_user_id UNIQUEIDENTIFIER NULL,
            updated_by_user_id UNIQUEIDENTIFIER NULL,
            is_deleted BIT NOT NULL
                CONSTRAINT DF_NaturalPerson_is_deleted DEFAULT 0,
            CONSTRAINT PK_NaturalPerson PRIMARY KEY (person_id),
            CONSTRAINT CK_NaturalPerson_lifespan
                CHECK (death_date IS NULL OR birth_date IS NULL OR death_date >= birth_date),
            CONSTRAINT CK_NaturalPerson_id_card_dates
                CHECK (id_card_valid_to IS NULL OR id_card_valid_from IS NULL OR id_card_valid_to >= id_card_valid_from),
            CONSTRAINT FK_NaturalPerson_Person FOREIGN KEY (person_id)
                REFERENCES person.Person (person_id),
            CONSTRAINT FK_NaturalPerson_Title FOREIGN KEY (title_code)
                REFERENCES ref.Title (title_code)
        );
    END;

    IF OBJECT_ID(N'person.LegalPerson', N'U') IS NULL
    BEGIN
        CREATE TABLE person.LegalPerson (
            person_id UNIQUEIDENTIFIER NOT NULL,
            incorporation_date DATE NULL,
            closing_date DATE NULL,
            legal_form NVARCHAR(120) NULL,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_LegalPerson_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_LegalPerson_updated_at_utc DEFAULT SYSUTCDATETIME(),
            created_by_user_id UNIQUEIDENTIFIER NULL,
            updated_by_user_id UNIQUEIDENTIFIER NULL,
            is_deleted BIT NOT NULL
                CONSTRAINT DF_LegalPerson_is_deleted DEFAULT 0,
            CONSTRAINT PK_LegalPerson PRIMARY KEY (person_id),
            CONSTRAINT CK_LegalPerson_dates
                CHECK (closing_date IS NULL OR incorporation_date IS NULL OR closing_date >= incorporation_date),
            CONSTRAINT FK_LegalPerson_Person FOREIGN KEY (person_id)
                REFERENCES person.Person (person_id)
        );
    END;

    IF OBJECT_ID(N'person.EconomicActivity', N'U') IS NULL
    BEGIN
        CREATE TABLE person.EconomicActivity (
            economic_activity_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_EconomicActivity_economic_activity_id DEFAULT NEWID(),
            person_id UNIQUEIDENTIFIER NOT NULL,
            profession NVARCHAR(150) NULL,
            professional_status_code NVARCHAR(30) NULL,
            kbo_number NVARCHAR(30) NULL,
            vat_number NVARCHAR(30) NULL,
            paritair_comite_code NVARCHAR(10) NULL,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_EconomicActivity_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_EconomicActivity_updated_at_utc DEFAULT SYSUTCDATETIME(),
            created_by_user_id UNIQUEIDENTIFIER NULL,
            updated_by_user_id UNIQUEIDENTIFIER NULL,
            is_deleted BIT NOT NULL
                CONSTRAINT DF_EconomicActivity_is_deleted DEFAULT 0,
            CONSTRAINT PK_EconomicActivity PRIMARY KEY (economic_activity_id),
            CONSTRAINT FK_EconomicActivity_Person FOREIGN KEY (person_id)
                REFERENCES person.Person (person_id),
            CONSTRAINT FK_EconomicActivity_ProfessionalStatus FOREIGN KEY (professional_status_code)
                REFERENCES ref.ProfessionalStatus (professional_status_code)
        );
    END;

    IF OBJECT_ID(N'person.EconomicActivityNacebel', N'U') IS NULL
    BEGIN
        CREATE TABLE person.EconomicActivityNacebel (
            economic_activity_id UNIQUEIDENTIFIER NOT NULL,
            nacebel_code NVARCHAR(10) NOT NULL,
            CONSTRAINT PK_EconomicActivityNacebel PRIMARY KEY (economic_activity_id, nacebel_code),
            CONSTRAINT FK_EconomicActivityNacebel_EconomicActivity FOREIGN KEY (economic_activity_id)
                REFERENCES person.EconomicActivity (economic_activity_id)
        );
    END;

    IF OBJECT_ID(N'person.PersonPersonType', N'U') IS NULL
    BEGIN
        CREATE TABLE person.PersonPersonType (
            person_id UNIQUEIDENTIFIER NOT NULL,
            person_type_code NVARCHAR(60) NOT NULL,
            CONSTRAINT PK_PersonPersonType PRIMARY KEY (person_id, person_type_code),
            CONSTRAINT FK_PersonPersonType_Person FOREIGN KEY (person_id)
                REFERENCES person.Person (person_id),
            CONSTRAINT FK_PersonPersonType_PersonType FOREIGN KEY (person_type_code)
                REFERENCES ref.PersonType (person_type_code)
        );
    END;

    IF OBJECT_ID(N'person.Address', N'U') IS NULL
    BEGIN
        CREATE TABLE person.Address (
            address_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_Address_address_id DEFAULT NEWID(),
            person_id UNIQUEIDENTIFIER NOT NULL,
            address_role_code NVARCHAR(20) NOT NULL,
            street NVARCHAR(200) NOT NULL,
            house_number NVARCHAR(30) NULL,
            box NVARCHAR(30) NULL,
            postal_code NVARCHAR(20) NOT NULL,
            city NVARCHAR(120) NOT NULL,
            country NVARCHAR(80) NOT NULL,
            country_code CHAR(2) NOT NULL
                CONSTRAINT DF_Address_country_code DEFAULT 'BE',
            remark NVARCHAR(400) NULL,
            is_primary BIT NOT NULL
                CONSTRAINT DF_Address_is_primary DEFAULT 0,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_Address_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_Address_updated_at_utc DEFAULT SYSUTCDATETIME(),
            created_by_user_id UNIQUEIDENTIFIER NULL,
            updated_by_user_id UNIQUEIDENTIFIER NULL,
            is_deleted BIT NOT NULL
                CONSTRAINT DF_Address_is_deleted DEFAULT 0,
            CONSTRAINT PK_Address PRIMARY KEY (address_id),
            CONSTRAINT FK_Address_Person FOREIGN KEY (person_id)
                REFERENCES person.Person (person_id),
            CONSTRAINT FK_Address_PersonAddressRole FOREIGN KEY (address_role_code)
                REFERENCES person.PersonAddressRole (address_role_code)
        );
    END;

    IF OBJECT_ID(N'person.Phone', N'U') IS NULL
    BEGIN
        CREATE TABLE person.Phone (
            phone_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_Phone_phone_id DEFAULT NEWID(),
            person_id UNIQUEIDENTIFIER NOT NULL,
            phone_number NVARCHAR(50) NOT NULL,
            phone_type_code NVARCHAR(20) NOT NULL,
            is_primary BIT NOT NULL
                CONSTRAINT DF_Phone_is_primary DEFAULT 0,
            comment NVARCHAR(200) NULL,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_Phone_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_Phone_updated_at_utc DEFAULT SYSUTCDATETIME(),
            created_by_user_id UNIQUEIDENTIFIER NULL,
            updated_by_user_id UNIQUEIDENTIFIER NULL,
            is_deleted BIT NOT NULL
                CONSTRAINT DF_Phone_is_deleted DEFAULT 0,
            CONSTRAINT PK_Phone PRIMARY KEY (phone_id),
            CONSTRAINT FK_Phone_Person FOREIGN KEY (person_id)
                REFERENCES person.Person (person_id),
            CONSTRAINT FK_Phone_PhoneType FOREIGN KEY (phone_type_code)
                REFERENCES ref.PhoneType (phone_type_code)
        );
    END;

    IF OBJECT_ID(N'person.Email', N'U') IS NULL
    BEGIN
        CREATE TABLE person.Email (
            email_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_Email_email_id DEFAULT NEWID(),
            person_id UNIQUEIDENTIFIER NOT NULL,
            email NVARCHAR(320) NOT NULL,
            is_primary BIT NOT NULL
                CONSTRAINT DF_Email_is_primary DEFAULT 0,
            comment NVARCHAR(200) NULL,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_Email_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_Email_updated_at_utc DEFAULT SYSUTCDATETIME(),
            created_by_user_id UNIQUEIDENTIFIER NULL,
            updated_by_user_id UNIQUEIDENTIFIER NULL,
            is_deleted BIT NOT NULL
                CONSTRAINT DF_Email_is_deleted DEFAULT 0,
            CONSTRAINT PK_Email PRIMARY KEY (email_id),
            CONSTRAINT FK_Email_Person FOREIGN KEY (person_id)
                REFERENCES person.Person (person_id)
        );
    END;

    IF OBJECT_ID(N'person.SocialMedia', N'U') IS NULL
    BEGIN
        CREATE TABLE person.SocialMedia (
            social_media_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_SocialMedia_social_media_id DEFAULT NEWID(),
            person_id UNIQUEIDENTIFIER NOT NULL,
            social_type_code NVARCHAR(20) NOT NULL,
            url NVARCHAR(400) NOT NULL,
            description NVARCHAR(200) NULL,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_SocialMedia_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_SocialMedia_updated_at_utc DEFAULT SYSUTCDATETIME(),
            created_by_user_id UNIQUEIDENTIFIER NULL,
            updated_by_user_id UNIQUEIDENTIFIER NULL,
            is_deleted BIT NOT NULL
                CONSTRAINT DF_SocialMedia_is_deleted DEFAULT 0,
            CONSTRAINT PK_SocialMedia PRIMARY KEY (social_media_id),
            CONSTRAINT FK_SocialMedia_Person FOREIGN KEY (person_id)
                REFERENCES person.Person (person_id),
            CONSTRAINT FK_SocialMedia_SocialType FOREIGN KEY (social_type_code)
                REFERENCES ref.SocialType (social_type_code)
        );
    END;

    IF OBJECT_ID(N'person.BankAccount', N'U') IS NULL
    BEGIN
        CREATE TABLE person.BankAccount (
            bank_account_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_BankAccount_bank_account_id DEFAULT NEWID(),
            person_id UNIQUEIDENTIFIER NOT NULL,
            iban NVARCHAR(34) NOT NULL,
            bic NVARCHAR(11) NULL,
            bank NVARCHAR(120) NOT NULL,
            remark NVARCHAR(200) NULL,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_BankAccount_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_BankAccount_updated_at_utc DEFAULT SYSUTCDATETIME(),
            created_by_user_id UNIQUEIDENTIFIER NULL,
            updated_by_user_id UNIQUEIDENTIFIER NULL,
            is_deleted BIT NOT NULL
                CONSTRAINT DF_BankAccount_is_deleted DEFAULT 0,
            CONSTRAINT PK_BankAccount PRIMARY KEY (bank_account_id),
            CONSTRAINT FK_BankAccount_Person FOREIGN KEY (person_id)
                REFERENCES person.Person (person_id)
        );
    END;

    IF OBJECT_ID(N'person.DriverLicense', N'U') IS NULL
    BEGIN
        CREATE TABLE person.DriverLicense (
            driver_license_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_DriverLicense_driver_license_id DEFAULT NEWID(),
            person_id UNIQUEIDENTIFIER NOT NULL,
            license_number NVARCHAR(50) NOT NULL,
            license_type NVARCHAR(30) NOT NULL,
            start_date DATE NOT NULL,
            end_date DATE NULL,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_DriverLicense_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_DriverLicense_updated_at_utc DEFAULT SYSUTCDATETIME(),
            created_by_user_id UNIQUEIDENTIFIER NULL,
            updated_by_user_id UNIQUEIDENTIFIER NULL,
            is_deleted BIT NOT NULL
                CONSTRAINT DF_DriverLicense_is_deleted DEFAULT 0,
            CONSTRAINT PK_DriverLicense PRIMARY KEY (driver_license_id),
            CONSTRAINT CK_DriverLicense_dates
                CHECK (end_date IS NULL OR end_date >= start_date),
            CONSTRAINT FK_DriverLicense_Person FOREIGN KEY (person_id)
                REFERENCES person.Person (person_id)
        );
    END;

    IF OBJECT_ID(N'person.PersonRelation', N'U') IS NULL
    BEGIN
        CREATE TABLE person.PersonRelation (
            person_relation_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_PersonRelation_person_relation_id DEFAULT NEWSEQUENTIALID(),
            tenant_id UNIQUEIDENTIFIER NOT NULL,
            relation_type_code NVARCHAR(50) NOT NULL,
            start_date DATE NULL,
            end_date DATE NULL,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_PersonRelation_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_PersonRelation_updated_at_utc DEFAULT SYSUTCDATETIME(),
            created_by_user_id UNIQUEIDENTIFIER NULL,
            updated_by_user_id UNIQUEIDENTIFIER NULL,
            is_deleted BIT NOT NULL
                CONSTRAINT DF_PersonRelation_is_deleted DEFAULT 0,
            CONSTRAINT PK_PersonRelation PRIMARY KEY (person_relation_id),
            CONSTRAINT CK_PersonRelation_dates
                CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date),
            CONSTRAINT FK_PersonRelation_Tenant FOREIGN KEY (tenant_id)
                REFERENCES core.Tenant (tenant_id),
            CONSTRAINT FK_PersonRelation_PersonRelationType FOREIGN KEY (relation_type_code)
                REFERENCES person.PersonRelationType (relation_type_code)
        );
    END;

    IF OBJECT_ID(N'person.PersonRelationPerson', N'U') IS NULL
    BEGIN
        CREATE TABLE person.PersonRelationPerson (
            person_relation_id UNIQUEIDENTIFIER NOT NULL,
            person_role CHAR(1) NOT NULL,
            person_id UNIQUEIDENTIFIER NOT NULL,
            CONSTRAINT PK_PersonRelationPerson PRIMARY KEY (person_relation_id, person_role),
            CONSTRAINT CK_PersonRelationPerson_person_role CHECK (person_role IN ('F', 'T')),
            CONSTRAINT FK_PersonRelationPerson_PersonRelation FOREIGN KEY (person_relation_id)
                REFERENCES person.PersonRelation (person_relation_id),
            CONSTRAINT FK_PersonRelationPerson_Person FOREIGN KEY (person_id)
                REFERENCES person.Person (person_id)
        );
    END;

    IF COL_LENGTH(N'core.AppUser', N'person_id') IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = N'FK_AppUser_Person'
              AND parent_object_id = OBJECT_ID(N'core.AppUser')
       )
    BEGIN
        ALTER TABLE core.AppUser
            ADD CONSTRAINT FK_AppUser_Person FOREIGN KEY (person_id)
            REFERENCES person.Person (person_id);
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'UQ_Person_tenant_dossier'
          AND object_id = OBJECT_ID(N'person.Person')
    )
        CREATE UNIQUE INDEX UQ_Person_tenant_dossier
        ON person.Person (tenant_id, dossier)
        WHERE dossier IS NOT NULL;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_Person_tenant_id'
          AND object_id = OBJECT_ID(N'person.Person')
    )
        CREATE INDEX IX_Person_tenant_id
        ON person.Person (tenant_id);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_NaturalPerson_name'
          AND object_id = OBJECT_ID(N'person.NaturalPerson')
    )
        CREATE INDEX IX_NaturalPerson_name
        ON person.NaturalPerson (last_name, first_name);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_Address_person_id'
          AND object_id = OBJECT_ID(N'person.Address')
    )
        CREATE INDEX IX_Address_person_id
        ON person.Address (person_id);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_Phone_person_id'
          AND object_id = OBJECT_ID(N'person.Phone')
    )
        CREATE INDEX IX_Phone_person_id
        ON person.Phone (person_id);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_Phone_number'
          AND object_id = OBJECT_ID(N'person.Phone')
    )
        CREATE INDEX IX_Phone_number
        ON person.Phone (phone_number);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_Email_person_id'
          AND object_id = OBJECT_ID(N'person.Email')
    )
        CREATE INDEX IX_Email_person_id
        ON person.Email (person_id);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_Email_email'
          AND object_id = OBJECT_ID(N'person.Email')
    )
        CREATE INDEX IX_Email_email
        ON person.Email (email);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'UQ_Address_person_primary'
          AND object_id = OBJECT_ID(N'person.Address')
    )
        CREATE UNIQUE INDEX UQ_Address_person_primary
        ON person.Address (person_id)
        WHERE is_primary = 1 AND is_deleted = 0;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'UQ_Phone_person_primary'
          AND object_id = OBJECT_ID(N'person.Phone')
    )
        CREATE UNIQUE INDEX UQ_Phone_person_primary
        ON person.Phone (person_id)
        WHERE is_primary = 1 AND is_deleted = 0;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'UQ_Email_person_primary'
          AND object_id = OBJECT_ID(N'person.Email')
    )
        CREATE UNIQUE INDEX UQ_Email_person_primary
        ON person.Email (person_id)
        WHERE is_primary = 1 AND is_deleted = 0;

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'003__create_person_domain.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'003__create_person_domain.sql',
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
