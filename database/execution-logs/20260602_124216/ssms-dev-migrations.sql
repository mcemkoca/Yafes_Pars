/*
Manual SSMS fallback for Yafes Pars DEV migrations.
Enable Query > SQLCMD Mode in SSMS before running this script.
Edit YAFES_SQL_DATABASE and YAFES_SQL_BACKUP_PATH before execution.
Do not run if the database name does not contain DEV.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar YAFES_SQL_BACKUP_PATH "C:\SqlBackups\YafesPars_Dev_PreMigration_YYYYMMDD_HHMMSS.bak"

SET NOCOUNT ON;
GO
USE [master];
GO
DECLARE @TargetDatabase SYSNAME = N'$(YAFES_SQL_DATABASE)';
DECLARE @BackupPath NVARCHAR(4000) = N'$(YAFES_SQL_BACKUP_PATH)';
DECLARE @ServerName NVARCHAR(256) = LOWER(CONVERT(NVARCHAR(256), @@SERVERNAME));
DECLARE @MachineName NVARCHAR(256) = LOWER(CONVERT(NVARCHAR(256), SERVERPROPERTY('MachineName')));
IF @TargetDatabase NOT LIKE N'%DEV%' THROW 51001, 'Target database name must contain DEV.', 1;
IF @ServerName LIKE N'%prod%' OR @ServerName LIKE N'%production%' OR @ServerName LIKE N'%prd%' THROW 51002, 'Target server name suggests production.', 1;
IF @MachineName LIKE N'%prod%' OR @MachineName LIKE N'%production%' OR @MachineName LIKE N'%prd%' THROW 51003, 'Target machine name suggests production.', 1;
IF DB_ID(@TargetDatabase) IS NULL THROW 51004, 'Target DEV database must exist so a pre-migration backup can be created.', 1;
IF @BackupPath LIKE N'%YYYYMMDD%' OR @BackupPath LIKE N'%HHMMSS%' THROW 51005, 'Set a timestamped backup path before running.', 1;
DECLARE @BackupSql NVARCHAR(MAX) = N'BACKUP DATABASE ' + QUOTENAME(@TargetDatabase) + N' TO DISK = N''' + REPLACE(@BackupPath, N'''', N'''''') + N''' WITH COPY_ONLY, INIT, STATS = 10;';
EXEC sys.sp_executesql @BackupSql;
PRINT 'Pre-migration backup completed.';
GO

PRINT '=== MIGRATION 000__create_database.sql ===';
GO
SET NOCOUNT ON;
GO

USE [master];
GO

PRINT 'Running migration: 000__create_database.sql';
GO

IF DB_ID(N'$(YAFES_SQL_DATABASE)') IS NULL
BEGIN
    CREATE DATABASE [$(YAFES_SQL_DATABASE)];
    PRINT 'Database created: YafesPars';
END
ELSE
BEGIN
    PRINT 'Database already exists: YafesPars';
END;
GO

PRINT 'Migration completed successfully.';
GO


PRINT '=== MIGRATION 001__create_schemas.sql ===';
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

PRINT 'Running migration: 001__create_schemas.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF SCHEMA_ID(N'core') IS NULL
        EXEC(N'CREATE SCHEMA core AUTHORIZATION dbo;');

    IF SCHEMA_ID(N'ref') IS NULL
        EXEC(N'CREATE SCHEMA ref AUTHORIZATION dbo;');

    IF SCHEMA_ID(N'person') IS NULL
        EXEC(N'CREATE SCHEMA person AUTHORIZATION dbo;');

    IF SCHEMA_ID(N'institution') IS NULL
        EXEC(N'CREATE SCHEMA institution AUTHORIZATION dbo;');

    IF SCHEMA_ID(N'risk') IS NULL
        EXEC(N'CREATE SCHEMA risk AUTHORIZATION dbo;');

    IF SCHEMA_ID(N'policy') IS NULL
        EXEC(N'CREATE SCHEMA policy AUTHORIZATION dbo;');

    IF SCHEMA_ID(N'coverage') IS NULL
        EXEC(N'CREATE SCHEMA coverage AUTHORIZATION dbo;');

    IF SCHEMA_ID(N'claim') IS NULL
        EXEC(N'CREATE SCHEMA claim AUTHORIZATION dbo;');

    IF SCHEMA_ID(N'document') IS NULL
        EXEC(N'CREATE SCHEMA document AUTHORIZATION dbo;');

    IF SCHEMA_ID(N'tasking') IS NULL
        EXEC(N'CREATE SCHEMA tasking AUTHORIZATION dbo;');

    IF SCHEMA_ID(N'audit') IS NULL
        EXEC(N'CREATE SCHEMA audit AUTHORIZATION dbo;');

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


PRINT '=== MIGRATION 002__create_core_infrastructure.sql ===';
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

PRINT 'Running migration: 002__create_core_infrastructure.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'core.SchemaMigration', N'U') IS NULL
    BEGIN
        CREATE TABLE core.SchemaMigration (
            migration_id INT IDENTITY(1,1) NOT NULL,
            migration_name NVARCHAR(255) NOT NULL,
            checksum NVARCHAR(128) NULL,
            executed_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_SchemaMigration_executed_at_utc DEFAULT SYSUTCDATETIME(),
            executed_by SYSNAME NOT NULL
                CONSTRAINT DF_SchemaMigration_executed_by DEFAULT SUSER_SNAME(),
            execution_status NVARCHAR(20) NOT NULL,
            error_message NVARCHAR(MAX) NULL,
            CONSTRAINT PK_SchemaMigration PRIMARY KEY (migration_id),
            CONSTRAINT UQ_SchemaMigration_migration_name UNIQUE (migration_name),
            CONSTRAINT CK_SchemaMigration_execution_status
                CHECK (execution_status IN (N'SUCCESS', N'FAILED'))
        );
    END;

    IF OBJECT_ID(N'core.Tenant', N'U') IS NULL
    BEGIN
        CREATE TABLE core.Tenant (
            tenant_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_Tenant_tenant_id DEFAULT NEWSEQUENTIALID(),
            tenant_code NVARCHAR(80) NOT NULL,
            legal_name NVARCHAR(200) NOT NULL,
            display_name NVARCHAR(200) NOT NULL,
            vat_number NVARCHAR(30) NULL,
            country_code CHAR(2) NOT NULL
                CONSTRAINT DF_Tenant_country_code DEFAULT 'BE',
            default_language CHAR(2) NOT NULL
                CONSTRAINT DF_Tenant_default_language DEFAULT 'nl',
            is_active BIT NOT NULL
                CONSTRAINT DF_Tenant_is_active DEFAULT 1,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_Tenant_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_Tenant_updated_at_utc DEFAULT SYSUTCDATETIME(),
            CONSTRAINT PK_Tenant PRIMARY KEY (tenant_id),
            CONSTRAINT UQ_Tenant_tenant_code UNIQUE (tenant_code)
        );
    END;

    IF OBJECT_ID(N'core.AppUser', N'U') IS NULL
    BEGIN
        CREATE TABLE core.AppUser (
            user_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_AppUser_user_id DEFAULT NEWSEQUENTIALID(),
            tenant_id UNIQUEIDENTIFIER NOT NULL,
            email NVARCHAR(320) NOT NULL,
            display_name NVARCHAR(160) NOT NULL,
            person_id UNIQUEIDENTIFIER NULL,
            auth_provider NVARCHAR(40) NOT NULL
                CONSTRAINT DF_AppUser_auth_provider DEFAULT 'local',
            external_subject_id NVARCHAR(200) NULL,
            is_active BIT NOT NULL
                CONSTRAINT DF_AppUser_is_active DEFAULT 1,
            last_login_at_utc DATETIME2(0) NULL,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_AppUser_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_AppUser_updated_at_utc DEFAULT SYSUTCDATETIME(),
            CONSTRAINT PK_AppUser PRIMARY KEY (user_id),
            CONSTRAINT UQ_AppUser_tenant_email UNIQUE (tenant_id, email),
            CONSTRAINT FK_AppUser_Tenant FOREIGN KEY (tenant_id)
                REFERENCES core.Tenant (tenant_id)
        );
    END;

    IF OBJECT_ID(N'core.Role', N'U') IS NULL
    BEGIN
        CREATE TABLE core.Role (
            role_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_Role_role_id DEFAULT NEWSEQUENTIALID(),
            tenant_id UNIQUEIDENTIFIER NULL,
            role_code NVARCHAR(80) NOT NULL,
            role_name NVARCHAR(160) NOT NULL,
            is_system_role BIT NOT NULL
                CONSTRAINT DF_Role_is_system_role DEFAULT 0,
            is_active BIT NOT NULL
                CONSTRAINT DF_Role_is_active DEFAULT 1,
            CONSTRAINT PK_Role PRIMARY KEY (role_id),
            CONSTRAINT UQ_Role_tenant_code UNIQUE (tenant_id, role_code),
            CONSTRAINT FK_Role_Tenant FOREIGN KEY (tenant_id)
                REFERENCES core.Tenant (tenant_id)
        );
    END;

    IF OBJECT_ID(N'core.Permission', N'U') IS NULL
    BEGIN
        CREATE TABLE core.Permission (
            permission_code NVARCHAR(120) NOT NULL,
            permission_name NVARCHAR(200) NOT NULL,
            module_code NVARCHAR(80) NOT NULL,
            is_active BIT NOT NULL
                CONSTRAINT DF_Permission_is_active DEFAULT 1,
            CONSTRAINT PK_Permission PRIMARY KEY (permission_code)
        );
    END;

    IF OBJECT_ID(N'core.RolePermission', N'U') IS NULL
    BEGIN
        CREATE TABLE core.RolePermission (
            role_id UNIQUEIDENTIFIER NOT NULL,
            permission_code NVARCHAR(120) NOT NULL,
            CONSTRAINT PK_RolePermission PRIMARY KEY (role_id, permission_code),
            CONSTRAINT FK_RolePermission_Role FOREIGN KEY (role_id)
                REFERENCES core.Role (role_id),
            CONSTRAINT FK_RolePermission_Permission FOREIGN KEY (permission_code)
                REFERENCES core.Permission (permission_code)
        );
    END;

    IF OBJECT_ID(N'core.UserRole', N'U') IS NULL
    BEGIN
        CREATE TABLE core.UserRole (
            user_id UNIQUEIDENTIFIER NOT NULL,
            role_id UNIQUEIDENTIFIER NOT NULL,
            CONSTRAINT PK_UserRole PRIMARY KEY (user_id, role_id),
            CONSTRAINT FK_UserRole_AppUser FOREIGN KEY (user_id)
                REFERENCES core.AppUser (user_id),
            CONSTRAINT FK_UserRole_Role FOREIGN KEY (role_id)
                REFERENCES core.Role (role_id)
        );
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_AppUser_tenant_id'
          AND object_id = OBJECT_ID(N'core.AppUser')
    )
        CREATE INDEX IX_AppUser_tenant_id
        ON core.AppUser (tenant_id);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_AppUser_person_id'
          AND object_id = OBJECT_ID(N'core.AppUser')
    )
        CREATE INDEX IX_AppUser_person_id
        ON core.AppUser (person_id);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_Role_tenant_id'
          AND object_id = OBJECT_ID(N'core.Role')
    )
        CREATE INDEX IX_Role_tenant_id
        ON core.Role (tenant_id);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_RolePermission_permission_code'
          AND object_id = OBJECT_ID(N'core.RolePermission')
    )
        CREATE INDEX IX_RolePermission_permission_code
        ON core.RolePermission (permission_code);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_UserRole_role_id'
          AND object_id = OBJECT_ID(N'core.UserRole')
    )
        CREATE INDEX IX_UserRole_role_id
        ON core.UserRole (role_id);

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'002__create_core_infrastructure.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'002__create_core_infrastructure.sql',
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


PRINT '=== MIGRATION 003__create_person_domain.sql ===';
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
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


PRINT '=== MIGRATION 004__create_institution_domain.sql ===';
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
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


PRINT '=== MIGRATION 005__create_object_domain.sql ===';
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

PRINT 'Running migration: 005__create_object_domain.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'risk.InsurableObjectType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsurableObjectType (
            object_type_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(120) NOT NULL,
            label_fr NVARCHAR(120) NULL,
            label_en NVARCHAR(120) NULL,
            label_tr NVARCHAR(120) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_InsurableObjectType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_InsurableObjectType PRIMARY KEY (object_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.VehicleType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.VehicleType (
            vehicle_type_code NVARCHAR(60) NOT NULL,
            label_nl NVARCHAR(160) NOT NULL,
            label_fr NVARCHAR(160) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_VehicleType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_VehicleType PRIMARY KEY (vehicle_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.UsageType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.UsageType (
            usage_type_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(160) NOT NULL,
            label_fr NVARCHAR(160) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_UsageType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_UsageType PRIMARY KEY (usage_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.FuelType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.FuelType (
            fuel_type_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(160) NOT NULL,
            label_fr NVARCHAR(160) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_FuelType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_FuelType PRIMARY KEY (fuel_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.DriveType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.DriveType (
            drive_type_code NVARCHAR(20) NOT NULL,
            label_nl NVARCHAR(160) NOT NULL,
            label_fr NVARCHAR(160) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_DriveType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_DriveType PRIMARY KEY (drive_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.LicensePlateType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.LicensePlateType (
            plate_type_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(160) NOT NULL,
            label_fr NVARCHAR(160) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_LicensePlateType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_LicensePlateType PRIMARY KEY (plate_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.RealEstateType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.RealEstateType (
            realestate_type_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_RealEstateType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_RealEstateType PRIMARY KEY (realestate_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.InsuredRole', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsuredRole (
            insured_role_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_InsuredRole_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_InsuredRole PRIMARY KEY (insured_role_code)
        );
    END;

    IF OBJECT_ID(N'risk.UseTypeRealEstate', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.UseTypeRealEstate (
            use_type_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_UseTypeRealEstate_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_UseTypeRealEstate PRIMARY KEY (use_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.ResidenceType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.ResidenceType (
            residence_type_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_ResidenceType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_ResidenceType PRIMARY KEY (residence_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.DestinationType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.DestinationType (
            destination_type_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_DestinationType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_DestinationType PRIMARY KEY (destination_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.AdjacencyType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.AdjacencyType (
            adjacency_type_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_AdjacencyType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_AdjacencyType PRIMARY KEY (adjacency_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.OccupancyLevel', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.OccupancyLevel (
            occupancy_level_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(240) NOT NULL,
            label_fr NVARCHAR(240) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_OccupancyLevel_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_OccupancyLevel PRIMARY KEY (occupancy_level_code)
        );
    END;

    IF OBJECT_ID(N'risk.ConstructionType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.ConstructionType (
            construction_type_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_ConstructionType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_ConstructionType PRIMARY KEY (construction_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.RoofType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.RoofType (
            roof_type_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_RoofType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_RoofType PRIMARY KEY (roof_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.BurglaryProtectionType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.BurglaryProtectionType (
            burglary_protection_type_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(240) NOT NULL,
            label_fr NVARCHAR(240) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_BurglaryProtectionType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_BurglaryProtectionType PRIMARY KEY (burglary_protection_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.InsurablePersonSubtype', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsurablePersonSubtype (
            subtype_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_InsurablePersonSubtype_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_InsurablePersonSubtype PRIMARY KEY (subtype_code)
        );
    END;

    IF OBJECT_ID(N'risk.WorkerRiskClass', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.WorkerRiskClass (
            worker_risk_class_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_WorkerRiskClass_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_WorkerRiskClass PRIMARY KEY (worker_risk_class_code)
        );
    END;

    IF OBJECT_ID(N'risk.EmployeeRiskClass', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.EmployeeRiskClass (
            employee_risk_class_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_EmployeeRiskClass_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_EmployeeRiskClass PRIMARY KEY (employee_risk_class_code)
        );
    END;

    IF OBJECT_ID(N'risk.AgeCategory', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.AgeCategory (
            age_category_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(120) NOT NULL,
            label_fr NVARCHAR(120) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_AgeCategory_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_AgeCategory PRIMARY KEY (age_category_code)
        );
    END;

    IF OBJECT_ID(N'risk.InsurableThingSubtype', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsurableThingSubtype (
            subtype_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_InsurableThingSubtype_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_InsurableThingSubtype PRIMARY KEY (subtype_code)
        );
    END;

    IF OBJECT_ID(N'risk.ThingRiskCategory', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.ThingRiskCategory (
            risk_category_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(120) NOT NULL,
            label_fr NVARCHAR(120) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_ThingRiskCategory_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_ThingRiskCategory PRIMARY KEY (risk_category_code)
        );
    END;

    IF OBJECT_ID(N'risk.ThingMaterialType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.ThingMaterialType (
            material_type_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(120) NOT NULL,
            label_fr NVARCHAR(120) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_ThingMaterialType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_ThingMaterialType PRIMARY KEY (material_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.InsurableActivitySubtype', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsurableActivitySubtype (
            activity_type_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_InsurableActivitySubtype_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_InsurableActivitySubtype PRIMARY KEY (activity_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.ActivityRiskLevel', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.ActivityRiskLevel (
            risk_level_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(120) NOT NULL,
            label_fr NVARCHAR(120) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_ActivityRiskLevel_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_ActivityRiskLevel PRIMARY KEY (risk_level_code)
        );
    END;

    IF OBJECT_ID(N'risk.InsurableObject', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsurableObject (
            insurable_object_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_InsurableObject_insurable_object_id DEFAULT NEWSEQUENTIALID(),
            tenant_id UNIQUEIDENTIFIER NOT NULL,
            object_type_code NVARCHAR(40) NOT NULL,
            description NVARCHAR(255) NOT NULL,
            status_code NVARCHAR(30) NOT NULL,
            start_date DATE NOT NULL,
            end_date DATE NULL,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_InsurableObject_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_InsurableObject_updated_at_utc DEFAULT SYSUTCDATETIME(),
            created_by_user_id UNIQUEIDENTIFIER NULL,
            updated_by_user_id UNIQUEIDENTIFIER NULL,
            is_deleted BIT NOT NULL
                CONSTRAINT DF_InsurableObject_is_deleted DEFAULT 0,
            CONSTRAINT PK_InsurableObject PRIMARY KEY (insurable_object_id),
            CONSTRAINT CK_InsurableObject_dates
                CHECK (end_date IS NULL OR end_date >= start_date),
            CONSTRAINT FK_InsurableObject_Tenant FOREIGN KEY (tenant_id)
                REFERENCES core.Tenant (tenant_id),
            CONSTRAINT FK_InsurableObject_InsurableObjectType FOREIGN KEY (object_type_code)
                REFERENCES risk.InsurableObjectType (object_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.InsurableVehicle', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsurableVehicle (
            insurable_object_id UNIQUEIDENTIFIER NOT NULL,
            vehicle_type_code NVARCHAR(60) NOT NULL,
            usage_type_code NVARCHAR(40) NOT NULL,
            plate_type_code NVARCHAR(40) NOT NULL,
            brand NVARCHAR(100) NOT NULL,
            model NVARCHAR(100) NOT NULL,
            chassis_number NVARCHAR(40) NOT NULL,
            build_year INT NOT NULL,
            first_commissioning_date DATE NOT NULL,
            registration_date DATE NOT NULL,
            license_plate NVARCHAR(20) NOT NULL,
            fuel_type_code NVARCHAR(40) NULL,
            drive_type_code NVARCHAR(20) NULL,
            finance_institution_id UNIQUEIDENTIFIER NULL,
            is_financed BIT NOT NULL CONSTRAINT DF_InsurableVehicle_is_financed DEFAULT 0,
            insured_value_ex_vat DECIMAL(18,2) NULL,
            insured_value_inc_vat DECIMAL(18,2) NULL,
            catalog_value_ex_vat DECIMAL(18,2) NULL,
            catalog_value_inc_vat DECIMAL(18,2) NULL,
            vat_exemption_pct DECIMAL(5,2) NULL,
            accessories_value DECIMAL(18,2) NULL,
            pvg_number NVARCHAR(40) NULL,
            eu_pvg_number NVARCHAR(40) NULL,
            adr_code NVARCHAR(40) NULL,
            engine_cc INT NULL,
            power_kw INT NULL,
            power_hp INT NULL,
            plate_cancellation_date DATE NULL,
            CONSTRAINT PK_InsurableVehicle PRIMARY KEY (insurable_object_id),
            CONSTRAINT CK_InsurableVehicle_financing CHECK (
                (is_financed = 0 AND finance_institution_id IS NULL)
                OR (is_financed = 1 AND finance_institution_id IS NOT NULL)
            ),
            CONSTRAINT CK_InsurableVehicle_build_year CHECK (build_year >= 1886),
            CONSTRAINT FK_InsurableVehicle_InsurableObject FOREIGN KEY (insurable_object_id)
                REFERENCES risk.InsurableObject (insurable_object_id),
            CONSTRAINT FK_InsurableVehicle_VehicleType FOREIGN KEY (vehicle_type_code)
                REFERENCES risk.VehicleType (vehicle_type_code),
            CONSTRAINT FK_InsurableVehicle_UsageType FOREIGN KEY (usage_type_code)
                REFERENCES risk.UsageType (usage_type_code),
            CONSTRAINT FK_InsurableVehicle_LicensePlateType FOREIGN KEY (plate_type_code)
                REFERENCES risk.LicensePlateType (plate_type_code),
            CONSTRAINT FK_InsurableVehicle_FuelType FOREIGN KEY (fuel_type_code)
                REFERENCES risk.FuelType (fuel_type_code),
            CONSTRAINT FK_InsurableVehicle_DriveType FOREIGN KEY (drive_type_code)
                REFERENCES risk.DriveType (drive_type_code),
            CONSTRAINT FK_InsurableVehicle_Institution_Finance FOREIGN KEY (finance_institution_id)
                REFERENCES institution.Institution (institution_id)
        );
    END;

    IF OBJECT_ID(N'risk.InsurableRealEstate', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsurableRealEstate (
            insurable_object_id UNIQUEIDENTIFIER NOT NULL,
            realestate_type_code NVARCHAR(80) NOT NULL,
            description NVARCHAR(255) NULL,
            use_type_code NVARCHAR(80) NOT NULL,
            insured_role_code NVARCHAR(80) NOT NULL,
            is_risk_address_policyholder BIT NOT NULL
                CONSTRAINT DF_InsurableRealEstate_is_risk_address_policyholder DEFAULT 0,
            residence_type_code NVARCHAR(80) NULL,
            destination_type_code NVARCHAR(80) NULL,
            street NVARCHAR(200) NOT NULL,
            number NVARCHAR(30) NOT NULL,
            box NVARCHAR(30) NULL,
            postal_code NVARCHAR(20) NOT NULL,
            city NVARCHAR(120) NOT NULL,
            country_code CHAR(2) NOT NULL
                CONSTRAINT DF_InsurableRealEstate_country_code DEFAULT 'BE',
            adjacency_type_code NVARCHAR(80) NULL,
            occupancy_level_code NVARCHAR(80) NULL,
            construction_type_code NVARCHAR(80) NULL,
            roof_type_code NVARCHAR(80) NULL,
            build_year INT NULL,
            is_under_construction BIT NOT NULL
                CONSTRAINT DF_InsurableRealEstate_is_under_construction DEFAULT 0,
            provisional_delivery_date DATE NULL,
            floors_count INT NULL,
            apartment_count INT NULL,
            has_solar_panels BIT NOT NULL
                CONSTRAINT DF_InsurableRealEstate_has_solar_panels DEFAULT 0,
            has_flammable_materials BIT NOT NULL
                CONSTRAINT DF_InsurableRealEstate_has_flammable_materials DEFAULT 0,
            flammable_materials_pct DECIMAL(5,2) NULL,
            abex_index_building INT NULL,
            capital_building DECIMAL(18,2) NULL,
            abex_index_roof INT NULL,
            capital_roof DECIMAL(18,2) NULL,
            CONSTRAINT PK_InsurableRealEstate PRIMARY KEY (insurable_object_id),
            CONSTRAINT CK_InsurableRealEstate_flammable_pct
                CHECK (flammable_materials_pct IS NULL OR flammable_materials_pct BETWEEN 0 AND 100),
            CONSTRAINT CK_InsurableRealEstate_build_year
                CHECK (build_year IS NULL OR build_year >= 1000),
            CONSTRAINT FK_InsurableRealEstate_InsurableObject FOREIGN KEY (insurable_object_id)
                REFERENCES risk.InsurableObject (insurable_object_id),
            CONSTRAINT FK_InsurableRealEstate_RealEstateType FOREIGN KEY (realestate_type_code)
                REFERENCES risk.RealEstateType (realestate_type_code),
            CONSTRAINT FK_InsurableRealEstate_UseTypeRealEstate FOREIGN KEY (use_type_code)
                REFERENCES risk.UseTypeRealEstate (use_type_code),
            CONSTRAINT FK_InsurableRealEstate_InsuredRole FOREIGN KEY (insured_role_code)
                REFERENCES risk.InsuredRole (insured_role_code),
            CONSTRAINT FK_InsurableRealEstate_ResidenceType FOREIGN KEY (residence_type_code)
                REFERENCES risk.ResidenceType (residence_type_code),
            CONSTRAINT FK_InsurableRealEstate_DestinationType FOREIGN KEY (destination_type_code)
                REFERENCES risk.DestinationType (destination_type_code),
            CONSTRAINT FK_InsurableRealEstate_AdjacencyType FOREIGN KEY (adjacency_type_code)
                REFERENCES risk.AdjacencyType (adjacency_type_code),
            CONSTRAINT FK_InsurableRealEstate_OccupancyLevel FOREIGN KEY (occupancy_level_code)
                REFERENCES risk.OccupancyLevel (occupancy_level_code),
            CONSTRAINT FK_InsurableRealEstate_ConstructionType FOREIGN KEY (construction_type_code)
                REFERENCES risk.ConstructionType (construction_type_code),
            CONSTRAINT FK_InsurableRealEstate_RoofType FOREIGN KEY (roof_type_code)
                REFERENCES risk.RoofType (roof_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.InsurableRealEstateBurglaryProtection', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsurableRealEstateBurglaryProtection (
            insurable_object_id UNIQUEIDENTIFIER NOT NULL,
            burglary_protection_type_code NVARCHAR(80) NOT NULL,
            CONSTRAINT PK_InsurableRealEstateBurglaryProtection
                PRIMARY KEY (insurable_object_id, burglary_protection_type_code),
            CONSTRAINT FK_InsurableRealEstateBurglaryProtection_InsurableRealEstate
                FOREIGN KEY (insurable_object_id)
                REFERENCES risk.InsurableRealEstate (insurable_object_id),
            CONSTRAINT FK_InsurableRealEstateBurglaryProtection_BurglaryProtectionType
                FOREIGN KEY (burglary_protection_type_code)
                REFERENCES risk.BurglaryProtectionType (burglary_protection_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.InsurableLoan', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsurableLoan (
            insurable_object_id UNIQUEIDENTIFIER NOT NULL,
            principal_amount DECIMAL(18,2) NOT NULL,
            interest_rate_pct DECIMAL(5,2) NOT NULL,
            interest_periodicity_code NVARCHAR(40) NOT NULL,
            duration_type_code NVARCHAR(20) NOT NULL,
            start_date DATE NOT NULL,
            end_date DATE NULL,
            remark NVARCHAR(255) NULL,
            CONSTRAINT PK_InsurableLoan PRIMARY KEY (insurable_object_id),
            CONSTRAINT CK_InsurableLoan_dates CHECK (end_date IS NULL OR end_date >= start_date),
            CONSTRAINT CK_InsurableLoan_principal CHECK (principal_amount > 0),
            CONSTRAINT CK_InsurableLoan_interest CHECK (interest_rate_pct >= 0),
            CONSTRAINT FK_InsurableLoan_InsurableObject FOREIGN KEY (insurable_object_id)
                REFERENCES risk.InsurableObject (insurable_object_id)
        );
    END;

    IF OBJECT_ID(N'risk.InsurablePerson', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsurablePerson (
            insurable_object_id UNIQUEIDENTIFIER NOT NULL,
            subtype_code NVARCHAR(80) NOT NULL,
            description NVARCHAR(255) NULL,
            is_policyholder BIT NOT NULL CONSTRAINT DF_InsurablePerson_is_policyholder DEFAULT 0,
            worker_risk_class_code NVARCHAR(80) NULL,
            employee_risk_class_code NVARCHAR(80) NULL,
            person_count INT NULL,
            nacebel_code NVARCHAR(10) NULL,
            person_id UNIQUEIDENTIFIER NULL,
            person_relation_id UNIQUEIDENTIFIER NULL,
            age_category_code NVARCHAR(40) NULL,
            CONSTRAINT PK_InsurablePerson PRIMARY KEY (insurable_object_id),
            CONSTRAINT CK_InsurablePerson_individual_or_group CHECK (
                (subtype_code NOT IN (N'PERS_IND', N'PERS_ACT')
                    OR (person_id IS NOT NULL AND person_relation_id IS NULL AND ISNULL(person_count, 1) = 1))
                AND
                (subtype_code NOT IN (N'GROEP_COL', N'GROEP_ARB', N'GROEP_BED', N'GROEP_POB', N'GROEP_GEZIN', N'GEZIN_PRIV')
                    OR (person_id IS NULL AND person_relation_id IS NOT NULL AND ISNULL(person_count, 0) >= 2))
            ),
            CONSTRAINT FK_InsurablePerson_InsurableObject FOREIGN KEY (insurable_object_id)
                REFERENCES risk.InsurableObject (insurable_object_id),
            CONSTRAINT FK_InsurablePerson_InsurablePersonSubtype FOREIGN KEY (subtype_code)
                REFERENCES risk.InsurablePersonSubtype (subtype_code),
            CONSTRAINT FK_InsurablePerson_WorkerRiskClass FOREIGN KEY (worker_risk_class_code)
                REFERENCES risk.WorkerRiskClass (worker_risk_class_code),
            CONSTRAINT FK_InsurablePerson_EmployeeRiskClass FOREIGN KEY (employee_risk_class_code)
                REFERENCES risk.EmployeeRiskClass (employee_risk_class_code),
            CONSTRAINT FK_InsurablePerson_Person FOREIGN KEY (person_id)
                REFERENCES person.Person (person_id),
            CONSTRAINT FK_InsurablePerson_PersonRelation FOREIGN KEY (person_relation_id)
                REFERENCES person.PersonRelation (person_relation_id),
            CONSTRAINT FK_InsurablePerson_AgeCategory FOREIGN KEY (age_category_code)
                REFERENCES risk.AgeCategory (age_category_code)
        );
    END;

    IF OBJECT_ID(N'risk.InsurableThing', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsurableThing (
            insurable_object_id UNIQUEIDENTIFIER NOT NULL,
            subtype_code NVARCHAR(80) NOT NULL,
            description NVARCHAR(255) NULL,
            brand NVARCHAR(120) NULL,
            model NVARCHAR(120) NULL,
            serial_number NVARCHAR(120) NULL,
            value_insured DECIMAL(18,2) NULL,
            value_new DECIMAL(18,2) NULL,
            value_current DECIMAL(18,2) NULL,
            risk_category_code NVARCHAR(40) NULL,
            material_type_code NVARCHAR(40) NULL,
            flammable_pct DECIMAL(5,2) NULL,
            location_street NVARCHAR(200) NULL,
            location_number NVARCHAR(30) NULL,
            location_box NVARCHAR(30) NULL,
            location_postal_code NVARCHAR(20) NULL,
            location_city NVARCHAR(120) NULL,
            location_country_code CHAR(2) NULL
                CONSTRAINT DF_InsurableThing_location_country_code DEFAULT 'BE',
            CONSTRAINT PK_InsurableThing PRIMARY KEY (insurable_object_id),
            CONSTRAINT CK_InsurableThing_flammable_pct
                CHECK (flammable_pct IS NULL OR flammable_pct BETWEEN 0 AND 100),
            CONSTRAINT FK_InsurableThing_InsurableObject FOREIGN KEY (insurable_object_id)
                REFERENCES risk.InsurableObject (insurable_object_id),
            CONSTRAINT FK_InsurableThing_InsurableThingSubtype FOREIGN KEY (subtype_code)
                REFERENCES risk.InsurableThingSubtype (subtype_code),
            CONSTRAINT FK_InsurableThing_ThingRiskCategory FOREIGN KEY (risk_category_code)
                REFERENCES risk.ThingRiskCategory (risk_category_code),
            CONSTRAINT FK_InsurableThing_ThingMaterialType FOREIGN KEY (material_type_code)
                REFERENCES risk.ThingMaterialType (material_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.InsurableActivity', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsurableActivity (
            insurable_object_id UNIQUEIDENTIFIER NOT NULL,
            activity_type_code NVARCHAR(80) NOT NULL,
            description NVARCHAR(255) NULL,
            start_datetime DATETIME2(0) NOT NULL,
            end_datetime DATETIME2(0) NOT NULL,
            participant_count INT NULL,
            age_category_code NVARCHAR(40) NULL,
            risk_level_code NVARCHAR(40) NULL,
            location_street NVARCHAR(200) NULL,
            location_number NVARCHAR(30) NULL,
            location_box NVARCHAR(30) NULL,
            location_postal_code NVARCHAR(20) NULL,
            location_city NVARCHAR(120) NULL,
            location_country_code CHAR(2) NULL
                CONSTRAINT DF_InsurableActivity_location_country_code DEFAULT 'BE',
            CONSTRAINT PK_InsurableActivity PRIMARY KEY (insurable_object_id),
            CONSTRAINT CK_InsurableActivity_dates CHECK (end_datetime >= start_datetime),
            CONSTRAINT CK_InsurableActivity_participants CHECK (participant_count IS NULL OR participant_count >= 0),
            CONSTRAINT FK_InsurableActivity_InsurableObject FOREIGN KEY (insurable_object_id)
                REFERENCES risk.InsurableObject (insurable_object_id),
            CONSTRAINT FK_InsurableActivity_InsurableActivitySubtype FOREIGN KEY (activity_type_code)
                REFERENCES risk.InsurableActivitySubtype (activity_type_code),
            CONSTRAINT FK_InsurableActivity_AgeCategory FOREIGN KEY (age_category_code)
                REFERENCES risk.AgeCategory (age_category_code),
            CONSTRAINT FK_InsurableActivity_ActivityRiskLevel FOREIGN KEY (risk_level_code)
                REFERENCES risk.ActivityRiskLevel (risk_level_code)
        );
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_InsurableObject_tenant_type'
          AND object_id = OBJECT_ID(N'risk.InsurableObject')
    )
        CREATE INDEX IX_InsurableObject_tenant_type
        ON risk.InsurableObject (tenant_id, object_type_code);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_InsurableVehicle_plate'
          AND object_id = OBJECT_ID(N'risk.InsurableVehicle')
    )
        CREATE INDEX IX_InsurableVehicle_plate
        ON risk.InsurableVehicle (license_plate);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_InsurableVehicle_chassis'
          AND object_id = OBJECT_ID(N'risk.InsurableVehicle')
    )
        CREATE INDEX IX_InsurableVehicle_chassis
        ON risk.InsurableVehicle (chassis_number);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_InsurableVehicle_finance_institution'
          AND object_id = OBJECT_ID(N'risk.InsurableVehicle')
    )
        CREATE INDEX IX_InsurableVehicle_finance_institution
        ON risk.InsurableVehicle (finance_institution_id);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_InsurableRealEstate_address'
          AND object_id = OBJECT_ID(N'risk.InsurableRealEstate')
    )
        CREATE INDEX IX_InsurableRealEstate_address
        ON risk.InsurableRealEstate (postal_code, city, street, number);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_InsurablePerson_person_id'
          AND object_id = OBJECT_ID(N'risk.InsurablePerson')
    )
        CREATE INDEX IX_InsurablePerson_person_id
        ON risk.InsurablePerson (person_id);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_InsurablePerson_person_relation_id'
          AND object_id = OBJECT_ID(N'risk.InsurablePerson')
    )
        CREATE INDEX IX_InsurablePerson_person_relation_id
        ON risk.InsurablePerson (person_relation_id);

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'005__create_object_domain.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'005__create_object_domain.sql',
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


PRINT '=== MIGRATION 006__create_contract_domain.sql ===';
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

PRINT 'Running migration: 006__create_contract_domain.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'policy.ContractDomain', N'U') IS NULL
    BEGIN
        CREATE TABLE policy.ContractDomain (
            contract_domain_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            label_en NVARCHAR(200) NULL,
            label_tr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_ContractDomain_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_ContractDomain PRIMARY KEY (contract_domain_code)
        );
    END;

    IF OBJECT_ID(N'policy.ContractStatus', N'U') IS NULL
    BEGIN
        CREATE TABLE policy.ContractStatus (
            contract_status_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(100) NOT NULL,
            label_fr NVARCHAR(100) NULL,
            label_en NVARCHAR(100) NULL,
            label_tr NVARCHAR(100) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_ContractStatus_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_ContractStatus PRIMARY KEY (contract_status_code)
        );
    END;

    IF OBJECT_ID(N'policy.ContractVersionStatus', N'U') IS NULL
    BEGIN
        CREATE TABLE policy.ContractVersionStatus (
            contract_version_status_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(100) NOT NULL,
            label_fr NVARCHAR(100) NULL,
            label_en NVARCHAR(100) NULL,
            label_tr NVARCHAR(100) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_ContractVersionStatus_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_ContractVersionStatus PRIMARY KEY (contract_version_status_code)
        );
    END;

    IF OBJECT_ID(N'policy.Periodicity', N'U') IS NULL
    BEGIN
        CREATE TABLE policy.Periodicity (
            periodicity_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(100) NOT NULL,
            label_fr NVARCHAR(100) NULL,
            label_en NVARCHAR(100) NULL,
            label_tr NVARCHAR(100) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_Periodicity_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_Periodicity PRIMARY KEY (periodicity_code)
        );
    END;

    IF OBJECT_ID(N'policy.CollectionMethod', N'U') IS NULL
    BEGIN
        CREATE TABLE policy.CollectionMethod (
            collection_method_code NVARCHAR(20) NOT NULL,
            label_nl NVARCHAR(100) NOT NULL,
            label_fr NVARCHAR(100) NULL,
            label_en NVARCHAR(100) NULL,
            label_tr NVARCHAR(100) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_CollectionMethod_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_CollectionMethod PRIMARY KEY (collection_method_code)
        );
    END;

    IF OBJECT_ID(N'policy.DurationType', N'U') IS NULL
    BEGIN
        CREATE TABLE policy.DurationType (
            duration_type_code NVARCHAR(20) NOT NULL,
            label_nl NVARCHAR(40) NOT NULL,
            label_fr NVARCHAR(40) NULL,
            label_en NVARCHAR(40) NULL,
            label_tr NVARCHAR(40) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_DurationType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_DurationType PRIMARY KEY (duration_type_code)
        );
    END;

    IF OBJECT_ID(N'policy.ContractType', N'U') IS NULL
    BEGIN
        CREATE TABLE policy.ContractType (
            contract_type_code NVARCHAR(80) NOT NULL,
            contract_domain_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(100) NOT NULL,
            label_fr NVARCHAR(100) NULL,
            label_en NVARCHAR(100) NULL,
            label_tr NVARCHAR(100) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_ContractType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_ContractType PRIMARY KEY (contract_type_code),
            CONSTRAINT UQ_ContractType_code_domain UNIQUE (contract_type_code, contract_domain_code),
            CONSTRAINT FK_ContractType_ContractDomain FOREIGN KEY (contract_domain_code)
                REFERENCES policy.ContractDomain (contract_domain_code)
        );
    END;

    IF OBJECT_ID(N'policy.ContractPartyRole', N'U') IS NULL
    BEGIN
        CREATE TABLE policy.ContractPartyRole (
            contract_party_role_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(100) NOT NULL,
            label_fr NVARCHAR(100) NULL,
            label_en NVARCHAR(100) NULL,
            label_tr NVARCHAR(100) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_ContractPartyRole_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_ContractPartyRole PRIMARY KEY (contract_party_role_code)
        );
    END;

    IF OBJECT_ID(N'policy.ContractObjectStatus', N'U') IS NULL
    BEGIN
        CREATE TABLE policy.ContractObjectStatus (
            contract_object_status_code NVARCHAR(20) NOT NULL,
            label_nl NVARCHAR(100) NOT NULL,
            label_fr NVARCHAR(100) NULL,
            label_en NVARCHAR(100) NULL,
            label_tr NVARCHAR(100) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_ContractObjectStatus_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_ContractObjectStatus PRIMARY KEY (contract_object_status_code)
        );
    END;

    IF OBJECT_ID(N'policy.TakeoverDirection', N'U') IS NULL
    BEGIN
        CREATE TABLE policy.TakeoverDirection (
            takeover_direction_code NVARCHAR(20) NOT NULL,
            label_nl NVARCHAR(100) NOT NULL,
            label_fr NVARCHAR(100) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_TakeoverDirection_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_TakeoverDirection PRIMARY KEY (takeover_direction_code)
        );
    END;

    IF OBJECT_ID(N'policy.TakeoverSourceType', N'U') IS NULL
    BEGIN
        CREATE TABLE policy.TakeoverSourceType (
            takeover_source_type_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(100) NOT NULL,
            label_fr NVARCHAR(100) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_TakeoverSourceType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_TakeoverSourceType PRIMARY KEY (takeover_source_type_code)
        );
    END;

    IF OBJECT_ID(N'policy.Contract', N'U') IS NULL
    BEGIN
        CREATE TABLE policy.Contract (
            contract_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_Contract_contract_id DEFAULT NEWSEQUENTIALID(),
            tenant_id UNIQUEIDENTIFIER NOT NULL,
            contract_number NVARCHAR(40) NOT NULL,
            contract_domain_code NVARCHAR(40) NOT NULL,
            contract_type_code NVARCHAR(80) NOT NULL,
            contract_status_code NVARCHAR(40) NOT NULL,
            company_id UNIQUEIDENTIFIER NULL,
            handling_company_id UNIQUEIDENTIFIER NULL,
            start_date DATE NOT NULL,
            end_date DATE NULL,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_Contract_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_Contract_updated_at_utc DEFAULT SYSUTCDATETIME(),
            created_by_user_id UNIQUEIDENTIFIER NULL,
            updated_by_user_id UNIQUEIDENTIFIER NULL,
            is_deleted BIT NOT NULL
                CONSTRAINT DF_Contract_is_deleted DEFAULT 0,
            CONSTRAINT PK_Contract PRIMARY KEY (contract_id),
            CONSTRAINT UQ_Contract_tenant_number UNIQUE (tenant_id, contract_number),
            CONSTRAINT CK_Contract_dates CHECK (end_date IS NULL OR end_date >= start_date),
            CONSTRAINT FK_Contract_Tenant FOREIGN KEY (tenant_id)
                REFERENCES core.Tenant (tenant_id),
            CONSTRAINT FK_Contract_ContractDomain FOREIGN KEY (contract_domain_code)
                REFERENCES policy.ContractDomain (contract_domain_code),
            CONSTRAINT FK_Contract_ContractType FOREIGN KEY (contract_type_code, contract_domain_code)
                REFERENCES policy.ContractType (contract_type_code, contract_domain_code),
            CONSTRAINT FK_Contract_ContractStatus FOREIGN KEY (contract_status_code)
                REFERENCES policy.ContractStatus (contract_status_code),
            CONSTRAINT FK_Contract_Institution_Company FOREIGN KEY (company_id)
                REFERENCES institution.Institution (institution_id),
            CONSTRAINT FK_Contract_Institution_HandlingCompany FOREIGN KEY (handling_company_id)
                REFERENCES institution.Institution (institution_id),
            CONSTRAINT FK_Contract_AppUser_CreatedBy FOREIGN KEY (created_by_user_id)
                REFERENCES core.AppUser (user_id),
            CONSTRAINT FK_Contract_AppUser_UpdatedBy FOREIGN KEY (updated_by_user_id)
                REFERENCES core.AppUser (user_id)
        );
    END;

    IF OBJECT_ID(N'policy.ContractVersion', N'U') IS NULL
    BEGIN
        CREATE TABLE policy.ContractVersion (
            contract_version_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_ContractVersion_contract_version_id DEFAULT NEWSEQUENTIALID(),
            contract_id UNIQUEIDENTIFIER NOT NULL,
            version_no INT NOT NULL,
            effective_from DATE NOT NULL,
            effective_to DATE NULL,
            contract_version_status_code NVARCHAR(40) NOT NULL,
            continuation_type_code NVARCHAR(20) NULL,
            duration_type_code NVARCHAR(20) NOT NULL,
            periodicity_code NVARCHAR(40) NOT NULL,
            collection_method_code NVARCHAR(20) NOT NULL,
            initial_start_date DATE NULL,
            parent_contract_id UNIQUEIDENTIFIER NULL,
            company_endorsement_number NVARCHAR(40) NULL,
            coinsurance_participation_pct DECIMAL(5,2) NULL,
            manager_person_id UNIQUEIDENTIFIER NULL,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_ContractVersion_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_ContractVersion_updated_at_utc DEFAULT SYSUTCDATETIME(),
            created_by_user_id UNIQUEIDENTIFIER NULL,
            updated_by_user_id UNIQUEIDENTIFIER NULL,
            is_deleted BIT NOT NULL
                CONSTRAINT DF_ContractVersion_is_deleted DEFAULT 0,
            CONSTRAINT PK_ContractVersion PRIMARY KEY (contract_version_id),
            CONSTRAINT UQ_ContractVersion_contract_version_no UNIQUE (contract_id, version_no),
            CONSTRAINT UQ_ContractVersion_id_contract UNIQUE (contract_version_id, contract_id),
            CONSTRAINT CK_ContractVersion_effective_dates
                CHECK (effective_to IS NULL OR effective_to >= effective_from),
            CONSTRAINT CK_ContractVersion_version_no CHECK (version_no > 0),
            CONSTRAINT CK_ContractVersion_coinsurance
                CHECK (coinsurance_participation_pct IS NULL OR coinsurance_participation_pct BETWEEN 0 AND 100),
            CONSTRAINT FK_ContractVersion_Contract FOREIGN KEY (contract_id)
                REFERENCES policy.Contract (contract_id),
            CONSTRAINT FK_ContractVersion_ContractVersionStatus FOREIGN KEY (contract_version_status_code)
                REFERENCES policy.ContractVersionStatus (contract_version_status_code),
            CONSTRAINT FK_ContractVersion_DurationType FOREIGN KEY (duration_type_code)
                REFERENCES policy.DurationType (duration_type_code),
            CONSTRAINT FK_ContractVersion_Periodicity FOREIGN KEY (periodicity_code)
                REFERENCES policy.Periodicity (periodicity_code),
            CONSTRAINT FK_ContractVersion_CollectionMethod FOREIGN KEY (collection_method_code)
                REFERENCES policy.CollectionMethod (collection_method_code),
            CONSTRAINT FK_ContractVersion_Contract_Parent FOREIGN KEY (parent_contract_id)
                REFERENCES policy.Contract (contract_id),
            CONSTRAINT FK_ContractVersion_Person_Manager FOREIGN KEY (manager_person_id)
                REFERENCES person.Person (person_id)
        );
    END;

    IF OBJECT_ID(N'policy.ContractParty', N'U') IS NULL
    BEGIN
        CREATE TABLE policy.ContractParty (
            contract_id UNIQUEIDENTIFIER NOT NULL,
            person_id UNIQUEIDENTIFIER NOT NULL,
            contract_party_role_code NVARCHAR(40) NOT NULL,
            is_primary BIT NOT NULL CONSTRAINT DF_ContractParty_is_primary DEFAULT 0,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_ContractParty_created_at_utc DEFAULT SYSUTCDATETIME(),
            CONSTRAINT PK_ContractParty PRIMARY KEY (contract_id, person_id, contract_party_role_code),
            CONSTRAINT FK_ContractParty_Contract FOREIGN KEY (contract_id)
                REFERENCES policy.Contract (contract_id),
            CONSTRAINT FK_ContractParty_Person FOREIGN KEY (person_id)
                REFERENCES person.Person (person_id),
            CONSTRAINT FK_ContractParty_ContractPartyRole FOREIGN KEY (contract_party_role_code)
                REFERENCES policy.ContractPartyRole (contract_party_role_code)
        );
    END;

    IF OBJECT_ID(N'policy.ContractObject', N'U') IS NULL
    BEGIN
        CREATE TABLE policy.ContractObject (
            contract_id UNIQUEIDENTIFIER NOT NULL,
            insurable_object_id UNIQUEIDENTIFIER NOT NULL,
            contract_object_status_code NVARCHAR(20) NOT NULL,
            is_primary BIT NOT NULL CONSTRAINT DF_ContractObject_is_primary DEFAULT 0,
            to_date DATE NULL,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_ContractObject_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_ContractObject_updated_at_utc DEFAULT SYSUTCDATETIME(),
            CONSTRAINT PK_ContractObject PRIMARY KEY (contract_id, insurable_object_id),
            CONSTRAINT FK_ContractObject_Contract FOREIGN KEY (contract_id)
                REFERENCES policy.Contract (contract_id),
            CONSTRAINT FK_ContractObject_InsurableObject FOREIGN KEY (insurable_object_id)
                REFERENCES risk.InsurableObject (insurable_object_id),
            CONSTRAINT FK_ContractObject_ContractObjectStatus FOREIGN KEY (contract_object_status_code)
                REFERENCES policy.ContractObjectStatus (contract_object_status_code)
        );
    END;

    IF OBJECT_ID(N'policy.ContractVersionObject', N'U') IS NULL
    BEGIN
        CREATE TABLE policy.ContractVersionObject (
            contract_version_id UNIQUEIDENTIFIER NOT NULL,
            contract_id UNIQUEIDENTIFIER NOT NULL,
            insurable_object_id UNIQUEIDENTIFIER NOT NULL,
            CONSTRAINT PK_ContractVersionObject PRIMARY KEY (contract_version_id, insurable_object_id),
            CONSTRAINT FK_ContractVersionObject_ContractVersion FOREIGN KEY (contract_version_id, contract_id)
                REFERENCES policy.ContractVersion (contract_version_id, contract_id),
            CONSTRAINT FK_ContractVersionObject_ContractObject FOREIGN KEY (contract_id, insurable_object_id)
                REFERENCES policy.ContractObject (contract_id, insurable_object_id)
        );
    END;

    IF OBJECT_ID(N'policy.ContractTakeover', N'U') IS NULL
    BEGIN
        CREATE TABLE policy.ContractTakeover (
            contract_version_id UNIQUEIDENTIFIER NOT NULL,
            takeover_direction_code NVARCHAR(20) NOT NULL,
            takeover_source_type_code NVARCHAR(40) NOT NULL,
            other_institution_id UNIQUEIDENTIFIER NULL,
            other_policy_number NVARCHAR(40) NULL,
            other_policy_start_date DATE NULL,
            other_policy_end_date DATE NULL,
            related_contract_version_id UNIQUEIDENTIFIER NULL,
            CONSTRAINT PK_ContractTakeover PRIMARY KEY (contract_version_id),
            CONSTRAINT CK_ContractTakeover_other_dates
                CHECK (other_policy_end_date IS NULL OR other_policy_start_date IS NULL OR other_policy_end_date >= other_policy_start_date),
            CONSTRAINT FK_ContractTakeover_ContractVersion FOREIGN KEY (contract_version_id)
                REFERENCES policy.ContractVersion (contract_version_id),
            CONSTRAINT FK_ContractTakeover_TakeoverDirection FOREIGN KEY (takeover_direction_code)
                REFERENCES policy.TakeoverDirection (takeover_direction_code),
            CONSTRAINT FK_ContractTakeover_TakeoverSourceType FOREIGN KEY (takeover_source_type_code)
                REFERENCES policy.TakeoverSourceType (takeover_source_type_code),
            CONSTRAINT FK_ContractTakeover_Institution_Other FOREIGN KEY (other_institution_id)
                REFERENCES institution.Institution (institution_id),
            CONSTRAINT FK_ContractTakeover_ContractVersion_Related FOREIGN KEY (related_contract_version_id)
                REFERENCES policy.ContractVersion (contract_version_id)
        );
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_Contract_status_dates'
          AND object_id = OBJECT_ID(N'policy.Contract')
    )
        CREATE INDEX IX_Contract_status_dates
        ON policy.Contract (tenant_id, contract_status_code, start_date, end_date);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_Contract_company_id'
          AND object_id = OBJECT_ID(N'policy.Contract')
    )
        CREATE INDEX IX_Contract_company_id
        ON policy.Contract (company_id);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_ContractVersion_contract_effective'
          AND object_id = OBJECT_ID(N'policy.ContractVersion')
    )
        CREATE INDEX IX_ContractVersion_contract_effective
        ON policy.ContractVersion (contract_id, effective_from, effective_to);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_ContractParty_person_id'
          AND object_id = OBJECT_ID(N'policy.ContractParty')
    )
        CREATE INDEX IX_ContractParty_person_id
        ON policy.ContractParty (person_id);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_ContractObject_insurable_object_id'
          AND object_id = OBJECT_ID(N'policy.ContractObject')
    )
        CREATE INDEX IX_ContractObject_insurable_object_id
        ON policy.ContractObject (insurable_object_id);

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'006__create_contract_domain.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'006__create_contract_domain.sql',
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


PRINT '=== MIGRATION 007__create_coverage_domain.sql ===';
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

PRINT 'Running migration: 007__create_coverage_domain.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'coverage.Coverage', N'U') IS NULL
    BEGIN
        CREATE TABLE coverage.Coverage (
            coverage_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(160) NOT NULL,
            label_fr NVARCHAR(160) NULL,
            label_en NVARCHAR(160) NULL,
            label_tr NVARCHAR(160) NULL,
            description NVARCHAR(500) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_Coverage_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_Coverage PRIMARY KEY (coverage_code)
        );
    END;

    IF OBJECT_ID(N'coverage.CoverageDomain', N'U') IS NULL
    BEGIN
        CREATE TABLE coverage.CoverageDomain (
            coverage_code NVARCHAR(80) NOT NULL,
            contract_domain_code NVARCHAR(40) NOT NULL,
            is_default BIT NOT NULL CONSTRAINT DF_CoverageDomain_is_default DEFAULT 0,
            sort_order INT NULL,
            CONSTRAINT PK_CoverageDomain PRIMARY KEY (coverage_code, contract_domain_code),
            CONSTRAINT FK_CoverageDomain_Coverage FOREIGN KEY (coverage_code)
                REFERENCES coverage.Coverage (coverage_code),
            CONSTRAINT FK_CoverageDomain_ContractDomain FOREIGN KEY (contract_domain_code)
                REFERENCES policy.ContractDomain (contract_domain_code)
        );
    END;

    IF OBJECT_ID(N'coverage.CoveragePackage', N'U') IS NULL
    BEGIN
        CREATE TABLE coverage.CoveragePackage (
            coverage_package_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_CoveragePackage_coverage_package_id DEFAULT NEWSEQUENTIALID(),
            package_code NVARCHAR(80) NOT NULL,
            contract_domain_code NVARCHAR(40) NOT NULL,
            package_name NVARCHAR(160) NOT NULL,
            description NVARCHAR(500) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_CoveragePackage_is_active DEFAULT 1,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_CoveragePackage_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_CoveragePackage_updated_at_utc DEFAULT SYSUTCDATETIME(),
            CONSTRAINT PK_CoveragePackage PRIMARY KEY (coverage_package_id),
            CONSTRAINT UQ_CoveragePackage_package_code UNIQUE (package_code),
            CONSTRAINT FK_CoveragePackage_ContractDomain FOREIGN KEY (contract_domain_code)
                REFERENCES policy.ContractDomain (contract_domain_code)
        );
    END;

    IF OBJECT_ID(N'coverage.CoveragePackageItem', N'U') IS NULL
    BEGIN
        CREATE TABLE coverage.CoveragePackageItem (
            coverage_package_id UNIQUEIDENTIFIER NOT NULL,
            coverage_code NVARCHAR(80) NOT NULL,
            is_mandatory BIT NOT NULL CONSTRAINT DF_CoveragePackageItem_is_mandatory DEFAULT 0,
            sort_order INT NULL,
            CONSTRAINT PK_CoveragePackageItem PRIMARY KEY (coverage_package_id, coverage_code),
            CONSTRAINT FK_CoveragePackageItem_CoveragePackage FOREIGN KEY (coverage_package_id)
                REFERENCES coverage.CoveragePackage (coverage_package_id),
            CONSTRAINT FK_CoveragePackageItem_Coverage FOREIGN KEY (coverage_code)
                REFERENCES coverage.Coverage (coverage_code)
        );
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_CoverageDomain_contract_domain'
          AND object_id = OBJECT_ID(N'coverage.CoverageDomain')
    )
        CREATE INDEX IX_CoverageDomain_contract_domain
        ON coverage.CoverageDomain (contract_domain_code);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_CoveragePackage_contract_domain'
          AND object_id = OBJECT_ID(N'coverage.CoveragePackage')
    )
        CREATE INDEX IX_CoveragePackage_contract_domain
        ON coverage.CoveragePackage (contract_domain_code);

    MERGE coverage.Coverage AS target
    USING (VALUES
        (N'AUTO_LIABILITY', N'BA Auto', N'RC Auto', N'Motor liability', N'Trafik sorumluluk', 10),
        (N'LEGAL_ASSISTANCE', N'Rechtsbijstand', N'Protection juridique', N'Legal assistance', N'Hukuki yardim', 20),
        (N'OMNIUM', N'Omnium', N'Omnium', N'Comprehensive motor', N'Kapsamli kasko', 30),
        (N'FIRE_BUILDING', N'Brand gebouw', N'Incendie batiment', N'Fire building', N'Bina yangin', 40),
        (N'FIRE_CONTENTS', N'Brand inhoud', N'Incendie contenu', N'Fire contents', N'Esya yangin', 50),
        (N'FAMILY_LIABILITY', N'Familiale BA', N'RC familiale', N'Family liability', N'Aile sorumluluk', 60),
        (N'CLAIM_ASSISTANCE', N'Bijstand schade', N'Assistance sinistre', N'Claim assistance', N'Hasar yardimi', 70)
    ) AS source (coverage_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.coverage_code = source.coverage_code
    WHEN MATCHED THEN
        UPDATE SET
            label_nl = source.label_nl,
            label_fr = source.label_fr,
            label_en = source.label_en,
            label_tr = source.label_tr,
            sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (coverage_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.coverage_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'007__create_coverage_domain.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'007__create_coverage_domain.sql',
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


PRINT '=== MIGRATION 008__create_claim_domain.sql ===';
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

PRINT 'Running migration: 008__create_claim_domain.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.key_constraints
        WHERE name = N'UQ_Contract_id_tenant'
          AND parent_object_id = OBJECT_ID(N'policy.Contract')
    )
    BEGIN
        ALTER TABLE policy.Contract
            ADD CONSTRAINT UQ_Contract_id_tenant UNIQUE (contract_id, tenant_id);
    END;

    IF OBJECT_ID(N'claim.ClaimStatus', N'U') IS NULL
    BEGIN
        CREATE TABLE claim.ClaimStatus (
            claim_status_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(100) NOT NULL,
            label_fr NVARCHAR(100) NULL,
            label_en NVARCHAR(100) NULL,
            label_tr NVARCHAR(100) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_ClaimStatus_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_ClaimStatus PRIMARY KEY (claim_status_code)
        );
    END;

    IF OBJECT_ID(N'claim.ClaimPartyRole', N'U') IS NULL
    BEGIN
        CREATE TABLE claim.ClaimPartyRole (
            claim_party_role_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(100) NOT NULL,
            label_fr NVARCHAR(100) NULL,
            label_en NVARCHAR(100) NULL,
            label_tr NVARCHAR(100) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_ClaimPartyRole_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_ClaimPartyRole PRIMARY KEY (claim_party_role_code)
        );
    END;

    IF OBJECT_ID(N'claim.ClaimCircumstanceType', N'U') IS NULL
    BEGIN
        CREATE TABLE claim.ClaimCircumstanceType (
            claim_circumstance_type_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(100) NOT NULL,
            label_fr NVARCHAR(100) NULL,
            label_en NVARCHAR(100) NULL,
            label_tr NVARCHAR(100) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_ClaimCircumstanceType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_ClaimCircumstanceType PRIMARY KEY (claim_circumstance_type_code)
        );
    END;

    IF OBJECT_ID(N'claim.ClaimPaymentMethod', N'U') IS NULL
    BEGIN
        CREATE TABLE claim.ClaimPaymentMethod (
            payment_method_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(100) NOT NULL,
            label_fr NVARCHAR(100) NULL,
            label_en NVARCHAR(100) NULL,
            label_tr NVARCHAR(100) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_ClaimPaymentMethod_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_ClaimPaymentMethod PRIMARY KEY (payment_method_code)
        );
    END;

    IF OBJECT_ID(N'claim.Claim', N'U') IS NULL
    BEGIN
        CREATE TABLE claim.Claim (
            claim_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_Claim_claim_id DEFAULT NEWSEQUENTIALID(),
            tenant_id UNIQUEIDENTIFIER NOT NULL,
            claim_number NVARCHAR(50) NOT NULL,
            contract_id UNIQUEIDENTIFIER NOT NULL,
            coverage_code NVARCHAR(80) NULL,
            claim_status_code NVARCHAR(40) NOT NULL,
            claims_handler_id UNIQUEIDENTIFIER NULL,
            incident_date DATE NULL,
            reported_date DATE NOT NULL,
            closed_date DATE NULL,
            description NVARCHAR(500) NULL,
            paid_amount DECIMAL(18,2) NULL,
            reserved_amount DECIMAL(18,2) NULL,
            payment_method_code NVARCHAR(40) NULL,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_Claim_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_Claim_updated_at_utc DEFAULT SYSUTCDATETIME(),
            created_by_user_id UNIQUEIDENTIFIER NULL,
            updated_by_user_id UNIQUEIDENTIFIER NULL,
            is_deleted BIT NOT NULL
                CONSTRAINT DF_Claim_is_deleted DEFAULT 0,
            CONSTRAINT PK_Claim PRIMARY KEY (claim_id),
            CONSTRAINT UQ_Claim_tenant_number UNIQUE (tenant_id, claim_number),
            CONSTRAINT CK_Claim_reported_after_incident
                CHECK (incident_date IS NULL OR reported_date >= incident_date),
            CONSTRAINT CK_Claim_closed_status_date CHECK (
                (closed_date IS NULL OR claim_status_code = N'CLOSED')
                AND (claim_status_code <> N'CLOSED' OR closed_date IS NOT NULL)
                AND (closed_date IS NULL OR closed_date >= reported_date)
            ),
            CONSTRAINT CK_Claim_payment_method
                CHECK (NOT (paid_amount > 0 AND payment_method_code IS NULL)),
            CONSTRAINT CK_Claim_amounts_nonnegative
                CHECK ((paid_amount IS NULL OR paid_amount >= 0)
                    AND (reserved_amount IS NULL OR reserved_amount >= 0)),
            CONSTRAINT FK_Claim_Tenant FOREIGN KEY (tenant_id)
                REFERENCES core.Tenant (tenant_id),
            CONSTRAINT FK_Claim_Contract FOREIGN KEY (contract_id, tenant_id)
                REFERENCES policy.Contract (contract_id, tenant_id),
            CONSTRAINT FK_Claim_Coverage FOREIGN KEY (coverage_code)
                REFERENCES coverage.Coverage (coverage_code),
            CONSTRAINT FK_Claim_ClaimStatus FOREIGN KEY (claim_status_code)
                REFERENCES claim.ClaimStatus (claim_status_code),
            CONSTRAINT FK_Claim_Person_Handler FOREIGN KEY (claims_handler_id)
                REFERENCES person.Person (person_id),
            CONSTRAINT FK_Claim_ClaimPaymentMethod FOREIGN KEY (payment_method_code)
                REFERENCES claim.ClaimPaymentMethod (payment_method_code),
            CONSTRAINT FK_Claim_AppUser_CreatedBy FOREIGN KEY (created_by_user_id)
                REFERENCES core.AppUser (user_id),
            CONSTRAINT FK_Claim_AppUser_UpdatedBy FOREIGN KEY (updated_by_user_id)
                REFERENCES core.AppUser (user_id)
        );
    END;

    IF OBJECT_ID(N'claim.ClaimParty', N'U') IS NULL
    BEGIN
        CREATE TABLE claim.ClaimParty (
            claim_id UNIQUEIDENTIFIER NOT NULL,
            person_id UNIQUEIDENTIFIER NOT NULL,
            claim_party_role_code NVARCHAR(40) NOT NULL,
            is_primary BIT NOT NULL CONSTRAINT DF_ClaimParty_is_primary DEFAULT 0,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_ClaimParty_created_at_utc DEFAULT SYSUTCDATETIME(),
            CONSTRAINT PK_ClaimParty PRIMARY KEY (claim_id, person_id, claim_party_role_code),
            CONSTRAINT FK_ClaimParty_Claim FOREIGN KEY (claim_id)
                REFERENCES claim.Claim (claim_id),
            CONSTRAINT FK_ClaimParty_Person FOREIGN KEY (person_id)
                REFERENCES person.Person (person_id),
            CONSTRAINT FK_ClaimParty_ClaimPartyRole FOREIGN KEY (claim_party_role_code)
                REFERENCES claim.ClaimPartyRole (claim_party_role_code)
        );
    END;

    IF OBJECT_ID(N'claim.ClaimObject', N'U') IS NULL
    BEGIN
        CREATE TABLE claim.ClaimObject (
            claim_id UNIQUEIDENTIFIER NOT NULL,
            insurable_object_id UNIQUEIDENTIFIER NOT NULL,
            is_primary BIT NOT NULL CONSTRAINT DF_ClaimObject_is_primary DEFAULT 0,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_ClaimObject_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_ClaimObject_updated_at_utc DEFAULT SYSUTCDATETIME(),
            CONSTRAINT PK_ClaimObject PRIMARY KEY (claim_id, insurable_object_id),
            CONSTRAINT FK_ClaimObject_Claim FOREIGN KEY (claim_id)
                REFERENCES claim.Claim (claim_id),
            CONSTRAINT FK_ClaimObject_InsurableObject FOREIGN KEY (insurable_object_id)
                REFERENCES risk.InsurableObject (insurable_object_id)
        );
    END;

    IF OBJECT_ID(N'claim.ClaimCircumstance', N'U') IS NULL
    BEGIN
        CREATE TABLE claim.ClaimCircumstance (
            claim_id UNIQUEIDENTIFIER NOT NULL,
            claim_circumstance_type_code NVARCHAR(40) NOT NULL,
            is_primary BIT NOT NULL CONSTRAINT DF_ClaimCircumstance_is_primary DEFAULT 0,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_ClaimCircumstance_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_ClaimCircumstance_updated_at_utc DEFAULT SYSUTCDATETIME(),
            CONSTRAINT PK_ClaimCircumstance PRIMARY KEY (claim_id, claim_circumstance_type_code),
            CONSTRAINT FK_ClaimCircumstance_Claim FOREIGN KEY (claim_id)
                REFERENCES claim.Claim (claim_id),
            CONSTRAINT FK_ClaimCircumstance_ClaimCircumstanceType FOREIGN KEY (claim_circumstance_type_code)
                REFERENCES claim.ClaimCircumstanceType (claim_circumstance_type_code)
        );
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_Claim_contract'
          AND object_id = OBJECT_ID(N'claim.Claim')
    )
        CREATE INDEX IX_Claim_contract
        ON claim.Claim (contract_id);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_Claim_status_reported'
          AND object_id = OBJECT_ID(N'claim.Claim')
    )
        CREATE INDEX IX_Claim_status_reported
        ON claim.Claim (tenant_id, claim_status_code, reported_date);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_ClaimParty_person_id'
          AND object_id = OBJECT_ID(N'claim.ClaimParty')
    )
        CREATE INDEX IX_ClaimParty_person_id
        ON claim.ClaimParty (person_id);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_ClaimObject_insurable_object_id'
          AND object_id = OBJECT_ID(N'claim.ClaimObject')
    )
        CREATE INDEX IX_ClaimObject_insurable_object_id
        ON claim.ClaimObject (insurable_object_id);

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'008__create_claim_domain.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'008__create_claim_domain.sql',
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


PRINT '=== MIGRATION 009__create_document_domain.sql ===';
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
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


PRINT '=== MIGRATION 010__create_task_domain.sql ===';
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
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


PRINT '=== MIGRATION 011__create_audit_domain.sql ===';
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

PRINT 'Running migration: 011__create_audit_domain.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'audit.AuditLog', N'U') IS NULL
    BEGIN
        CREATE TABLE audit.AuditLog (
            audit_log_id BIGINT IDENTITY(1,1) NOT NULL,
            tenant_id UNIQUEIDENTIFIER NULL,
            schema_name SYSNAME NOT NULL,
            table_name SYSNAME NOT NULL,
            primary_key_value NVARCHAR(200) NOT NULL,
            action_type NVARCHAR(20) NOT NULL,
            changed_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_AuditLog_changed_at_utc DEFAULT SYSUTCDATETIME(),
            changed_by_user_id UNIQUEIDENTIFIER NULL,
            changed_by_name NVARCHAR(200) NULL
                CONSTRAINT DF_AuditLog_changed_by_name DEFAULT SUSER_SNAME(),
            old_values_json NVARCHAR(MAX) NULL,
            new_values_json NVARCHAR(MAX) NULL,
            source_system NVARCHAR(80) NULL,
            correlation_id UNIQUEIDENTIFIER NULL,
            CONSTRAINT PK_AuditLog PRIMARY KEY (audit_log_id),
            CONSTRAINT CK_AuditLog_action_type CHECK (action_type IN (N'INSERT', N'UPDATE', N'DELETE')),
            CONSTRAINT FK_AuditLog_Tenant FOREIGN KEY (tenant_id)
                REFERENCES core.Tenant (tenant_id),
            CONSTRAINT FK_AuditLog_AppUser_ChangedBy FOREIGN KEY (changed_by_user_id)
                REFERENCES core.AppUser (user_id)
        );
    END;

    IF OBJECT_ID(N'audit.EntityChangeSet', N'U') IS NULL
    BEGIN
        CREATE TABLE audit.EntityChangeSet (
            entity_change_set_id BIGINT IDENTITY(1,1) NOT NULL,
            audit_log_id BIGINT NOT NULL,
            column_name SYSNAME NOT NULL,
            old_value NVARCHAR(MAX) NULL,
            new_value NVARCHAR(MAX) NULL,
            CONSTRAINT PK_EntityChangeSet PRIMARY KEY (entity_change_set_id),
            CONSTRAINT FK_EntityChangeSet_AuditLog FOREIGN KEY (audit_log_id)
                REFERENCES audit.AuditLog (audit_log_id)
        );
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_AuditLog_tenant_changed'
          AND object_id = OBJECT_ID(N'audit.AuditLog')
    )
        CREATE INDEX IX_AuditLog_tenant_changed
        ON audit.AuditLog (tenant_id, changed_at_utc DESC);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_AuditLog_entity'
          AND object_id = OBJECT_ID(N'audit.AuditLog')
    )
        CREATE INDEX IX_AuditLog_entity
        ON audit.AuditLog (schema_name, table_name, primary_key_value, changed_at_utc DESC);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_EntityChangeSet_audit_log_id'
          AND object_id = OBJECT_ID(N'audit.EntityChangeSet')
    )
        CREATE INDEX IX_EntityChangeSet_audit_log_id
        ON audit.EntityChangeSet (audit_log_id);

    COMMIT TRANSACTION;
    PRINT 'Audit tables created.';
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

PRINT 'Creating audit trigger: person.TR_Person_Audit';
GO

CREATE OR ALTER TRIGGER person.TR_Person_Audit
ON person.Person
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO audit.AuditLog (
        tenant_id,
        schema_name,
        table_name,
        primary_key_value,
        action_type,
        old_values_json,
        new_values_json,
        source_system
    )
    SELECT
        COALESCE(i.tenant_id, d.tenant_id),
        N'person',
        N'Person',
        CONVERT(NVARCHAR(200), COALESCE(i.person_id, d.person_id)),
        CASE
            WHEN d.person_id IS NULL THEN N'INSERT'
            WHEN i.person_id IS NULL THEN N'DELETE'
            ELSE N'UPDATE'
        END,
        CASE WHEN d.person_id IS NULL THEN NULL
            ELSE CONCAT(N'{"person_id":"', CONVERT(NVARCHAR(36), d.person_id), N'"}') END,
        CASE WHEN i.person_id IS NULL THEN NULL
            ELSE CONCAT(N'{"person_id":"', CONVERT(NVARCHAR(36), i.person_id), N'"}') END,
        N'SQL_TRIGGER'
    FROM inserted i
    FULL OUTER JOIN deleted d ON d.person_id = i.person_id;
END;
GO

PRINT 'Creating audit trigger: institution.TR_Institution_Audit';
GO

CREATE OR ALTER TRIGGER institution.TR_Institution_Audit
ON institution.Institution
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO audit.AuditLog (
        tenant_id,
        schema_name,
        table_name,
        primary_key_value,
        action_type,
        old_values_json,
        new_values_json,
        source_system
    )
    SELECT
        COALESCE(i.tenant_id, d.tenant_id),
        N'institution',
        N'Institution',
        CONVERT(NVARCHAR(200), COALESCE(i.institution_id, d.institution_id)),
        CASE
            WHEN d.institution_id IS NULL THEN N'INSERT'
            WHEN i.institution_id IS NULL THEN N'DELETE'
            ELSE N'UPDATE'
        END,
        CASE WHEN d.institution_id IS NULL THEN NULL
            ELSE CONCAT(N'{"institution_id":"', CONVERT(NVARCHAR(36), d.institution_id), N'"}') END,
        CASE WHEN i.institution_id IS NULL THEN NULL
            ELSE CONCAT(N'{"institution_id":"', CONVERT(NVARCHAR(36), i.institution_id), N'"}') END,
        N'SQL_TRIGGER'
    FROM inserted i
    FULL OUTER JOIN deleted d ON d.institution_id = i.institution_id;
END;
GO

PRINT 'Creating audit trigger: risk.TR_InsurableObject_Audit';
GO

CREATE OR ALTER TRIGGER risk.TR_InsurableObject_Audit
ON risk.InsurableObject
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO audit.AuditLog (
        tenant_id,
        schema_name,
        table_name,
        primary_key_value,
        action_type,
        old_values_json,
        new_values_json,
        source_system
    )
    SELECT
        COALESCE(i.tenant_id, d.tenant_id),
        N'risk',
        N'InsurableObject',
        CONVERT(NVARCHAR(200), COALESCE(i.insurable_object_id, d.insurable_object_id)),
        CASE
            WHEN d.insurable_object_id IS NULL THEN N'INSERT'
            WHEN i.insurable_object_id IS NULL THEN N'DELETE'
            ELSE N'UPDATE'
        END,
        CASE WHEN d.insurable_object_id IS NULL THEN NULL
            ELSE CONCAT(N'{"insurable_object_id":"', CONVERT(NVARCHAR(36), d.insurable_object_id), N'"}') END,
        CASE WHEN i.insurable_object_id IS NULL THEN NULL
            ELSE CONCAT(N'{"insurable_object_id":"', CONVERT(NVARCHAR(36), i.insurable_object_id), N'"}') END,
        N'SQL_TRIGGER'
    FROM inserted i
    FULL OUTER JOIN deleted d ON d.insurable_object_id = i.insurable_object_id;
END;
GO

PRINT 'Creating audit trigger: policy.TR_Contract_Audit';
GO

CREATE OR ALTER TRIGGER policy.TR_Contract_Audit
ON policy.Contract
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO audit.AuditLog (
        tenant_id,
        schema_name,
        table_name,
        primary_key_value,
        action_type,
        old_values_json,
        new_values_json,
        source_system
    )
    SELECT
        COALESCE(i.tenant_id, d.tenant_id),
        N'policy',
        N'Contract',
        CONVERT(NVARCHAR(200), COALESCE(i.contract_id, d.contract_id)),
        CASE
            WHEN d.contract_id IS NULL THEN N'INSERT'
            WHEN i.contract_id IS NULL THEN N'DELETE'
            ELSE N'UPDATE'
        END,
        CASE WHEN d.contract_id IS NULL THEN NULL
            ELSE CONCAT(N'{"contract_id":"', CONVERT(NVARCHAR(36), d.contract_id), N'"}') END,
        CASE WHEN i.contract_id IS NULL THEN NULL
            ELSE CONCAT(N'{"contract_id":"', CONVERT(NVARCHAR(36), i.contract_id), N'"}') END,
        N'SQL_TRIGGER'
    FROM inserted i
    FULL OUTER JOIN deleted d ON d.contract_id = i.contract_id;
END;
GO

PRINT 'Creating audit trigger: policy.TR_ContractVersion_Audit';
GO

CREATE OR ALTER TRIGGER policy.TR_ContractVersion_Audit
ON policy.ContractVersion
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO audit.AuditLog (
        tenant_id,
        schema_name,
        table_name,
        primary_key_value,
        action_type,
        old_values_json,
        new_values_json,
        source_system
    )
    SELECT
        c.tenant_id,
        N'policy',
        N'ContractVersion',
        CONVERT(NVARCHAR(200), COALESCE(i.contract_version_id, d.contract_version_id)),
        CASE
            WHEN d.contract_version_id IS NULL THEN N'INSERT'
            WHEN i.contract_version_id IS NULL THEN N'DELETE'
            ELSE N'UPDATE'
        END,
        CASE WHEN d.contract_version_id IS NULL THEN NULL
            ELSE CONCAT(N'{"contract_version_id":"', CONVERT(NVARCHAR(36), d.contract_version_id), N'"}') END,
        CASE WHEN i.contract_version_id IS NULL THEN NULL
            ELSE CONCAT(N'{"contract_version_id":"', CONVERT(NVARCHAR(36), i.contract_version_id), N'"}') END,
        N'SQL_TRIGGER'
    FROM inserted i
    FULL OUTER JOIN deleted d ON d.contract_version_id = i.contract_version_id
    INNER JOIN policy.Contract c ON c.contract_id = COALESCE(i.contract_id, d.contract_id);
END;
GO

PRINT 'Creating audit trigger: claim.TR_Claim_Audit';
GO

CREATE OR ALTER TRIGGER claim.TR_Claim_Audit
ON claim.Claim
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO audit.AuditLog (
        tenant_id,
        schema_name,
        table_name,
        primary_key_value,
        action_type,
        old_values_json,
        new_values_json,
        source_system
    )
    SELECT
        COALESCE(i.tenant_id, d.tenant_id),
        N'claim',
        N'Claim',
        CONVERT(NVARCHAR(200), COALESCE(i.claim_id, d.claim_id)),
        CASE
            WHEN d.claim_id IS NULL THEN N'INSERT'
            WHEN i.claim_id IS NULL THEN N'DELETE'
            ELSE N'UPDATE'
        END,
        CASE WHEN d.claim_id IS NULL THEN NULL
            ELSE CONCAT(N'{"claim_id":"', CONVERT(NVARCHAR(36), d.claim_id), N'"}') END,
        CASE WHEN i.claim_id IS NULL THEN NULL
            ELSE CONCAT(N'{"claim_id":"', CONVERT(NVARCHAR(36), i.claim_id), N'"}') END,
        N'SQL_TRIGGER'
    FROM inserted i
    FULL OUTER JOIN deleted d ON d.claim_id = i.claim_id;
END;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'011__create_audit_domain.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'011__create_audit_domain.sql',
            N'SUCCESS'
        );
    END;

    COMMIT TRANSACTION;
    PRINT 'Migration completed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @FinalErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @FinalErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @FinalErrorState INT = ERROR_STATE();

    RAISERROR(@FinalErrorMessage, @FinalErrorSeverity, @FinalErrorState);
END CATCH;
GO


PRINT '=== MIGRATION 012__add_constraints.sql ===';
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

PRINT 'Running migration: 012__add_constraints.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = N'FK_InsurableLoan_Periodicity'
          AND parent_object_id = OBJECT_ID(N'risk.InsurableLoan')
    )
    BEGIN
        ALTER TABLE risk.InsurableLoan
            ADD CONSTRAINT FK_InsurableLoan_Periodicity
            FOREIGN KEY (interest_periodicity_code)
            REFERENCES policy.Periodicity (periodicity_code);
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = N'FK_InsurableLoan_DurationType'
          AND parent_object_id = OBJECT_ID(N'risk.InsurableLoan')
    )
    BEGIN
        ALTER TABLE risk.InsurableLoan
            ADD CONSTRAINT FK_InsurableLoan_DurationType
            FOREIGN KEY (duration_type_code)
            REFERENCES policy.DurationType (duration_type_code);
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = N'FK_InsurableObject_AppUser_CreatedBy'
          AND parent_object_id = OBJECT_ID(N'risk.InsurableObject')
    )
    BEGIN
        ALTER TABLE risk.InsurableObject
            ADD CONSTRAINT FK_InsurableObject_AppUser_CreatedBy
            FOREIGN KEY (created_by_user_id)
            REFERENCES core.AppUser (user_id);
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = N'FK_InsurableObject_AppUser_UpdatedBy'
          AND parent_object_id = OBJECT_ID(N'risk.InsurableObject')
    )
    BEGIN
        ALTER TABLE risk.InsurableObject
            ADD CONSTRAINT FK_InsurableObject_AppUser_UpdatedBy
            FOREIGN KEY (updated_by_user_id)
            REFERENCES core.AppUser (user_id);
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = N'FK_ContractVersion_AppUser_CreatedBy'
          AND parent_object_id = OBJECT_ID(N'policy.ContractVersion')
    )
    BEGIN
        ALTER TABLE policy.ContractVersion
            ADD CONSTRAINT FK_ContractVersion_AppUser_CreatedBy
            FOREIGN KEY (created_by_user_id)
            REFERENCES core.AppUser (user_id);
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = N'FK_ContractVersion_AppUser_UpdatedBy'
          AND parent_object_id = OBJECT_ID(N'policy.ContractVersion')
    )
    BEGIN
        ALTER TABLE policy.ContractVersion
            ADD CONSTRAINT FK_ContractVersion_AppUser_UpdatedBy
            FOREIGN KEY (updated_by_user_id)
            REFERENCES core.AppUser (user_id);
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'012__add_constraints.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'012__add_constraints.sql',
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


PRINT '=== MIGRATION 013__add_indexes.sql ===';
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

PRINT 'Running migration: 013__add_indexes.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @MissingFkIndexes TABLE (
        schema_name SYSNAME NOT NULL,
        table_name SYSNAME NOT NULL,
        column_name SYSNAME NOT NULL,
        index_name SYSNAME NOT NULL,
        PRIMARY KEY (schema_name, table_name, column_name)
    );

    INSERT INTO @MissingFkIndexes (
        schema_name,
        table_name,
        column_name,
        index_name
    )
    SELECT DISTINCT
        s.name,
        t.name,
        c.name,
        CONVERT(SYSNAME, LEFT(N'IX_' + t.name + N'_' + c.name + N'_fk', 128))
    FROM sys.foreign_keys fk
    INNER JOIN sys.foreign_key_columns fkc
        ON fkc.constraint_object_id = fk.object_id
       AND fkc.constraint_column_id = 1
    INNER JOIN sys.tables t
        ON t.object_id = fk.parent_object_id
    INNER JOIN sys.schemas s
        ON s.schema_id = t.schema_id
    INNER JOIN sys.columns c
        ON c.object_id = t.object_id
       AND c.column_id = fkc.parent_column_id
    WHERE NOT EXISTS (
        SELECT 1
        FROM sys.indexes i
        INNER JOIN sys.index_columns ic
            ON ic.object_id = i.object_id
           AND ic.index_id = i.index_id
           AND ic.key_ordinal = 1
        WHERE i.object_id = t.object_id
          AND i.is_hypothetical = 0
          AND ic.column_id = fkc.parent_column_id
    )
    AND NOT EXISTS (
        SELECT 1
        FROM sys.indexes i
        WHERE i.object_id = t.object_id
          AND i.name = CONVERT(SYSNAME, LEFT(N'IX_' + t.name + N'_' + c.name + N'_fk', 128))
    );

    DECLARE @SchemaName SYSNAME;
    DECLARE @TableName SYSNAME;
    DECLARE @ColumnName SYSNAME;
    DECLARE @IndexName SYSNAME;
    DECLARE @Sql NVARCHAR(MAX);

    DECLARE fk_index_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT schema_name, table_name, column_name, index_name
        FROM @MissingFkIndexes
        ORDER BY schema_name, table_name, column_name;

    OPEN fk_index_cursor;

    FETCH NEXT FROM fk_index_cursor
    INTO @SchemaName, @TableName, @ColumnName, @IndexName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Sql = N'CREATE INDEX ' + QUOTENAME(@IndexName)
            + N' ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName)
            + N' (' + QUOTENAME(@ColumnName) + N');';

        EXEC sys.sp_executesql @Sql;

        FETCH NEXT FROM fk_index_cursor
        INTO @SchemaName, @TableName, @ColumnName, @IndexName;
    END;

    CLOSE fk_index_cursor;
    DEALLOCATE fk_index_cursor;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_Document_tenant_uploaded'
          AND object_id = OBJECT_ID(N'document.Document')
    )
        CREATE INDEX IX_Document_tenant_uploaded
        ON document.Document (tenant_id, uploaded_at_utc DESC);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_Task_tenant_assigned_status_due'
          AND object_id = OBJECT_ID(N'tasking.Task')
    )
        CREATE INDEX IX_Task_tenant_assigned_status_due
        ON tasking.Task (tenant_id, assigned_to_user_id, task_status_code, due_at_utc);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_AuditLog_correlation'
          AND object_id = OBJECT_ID(N'audit.AuditLog')
    )
        CREATE INDEX IX_AuditLog_correlation
        ON audit.AuditLog (correlation_id)
        WHERE correlation_id IS NOT NULL;

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'013__add_indexes.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'013__add_indexes.sql',
            N'SUCCESS'
        );
    END;

    COMMIT TRANSACTION;
    PRINT 'Migration completed successfully.';
END TRY
BEGIN CATCH
    IF CURSOR_STATUS('local', 'fk_index_cursor') >= 0
        CLOSE fk_index_cursor;

    IF CURSOR_STATUS('local', 'fk_index_cursor') >= -1
        DEALLOCATE fk_index_cursor;

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;
GO


PRINT '=== MIGRATION 014__add_triggers.sql ===';
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

PRINT 'Running migration: 014__add_triggers.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'014__add_triggers.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'014__add_triggers.sql',
            N'SUCCESS'
        );
    END;

    COMMIT TRANSACTION;
    PRINT 'Trigger phase registered. Root audit triggers are created in 011__create_audit_domain.sql.';
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


PRINT '=== MIGRATION 015__add_views.sql ===';
GO
SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

PRINT 'Running migration: 015__add_views.sql';
GO

CREATE OR ALTER VIEW person.VW_CustomerSummary
AS
SELECT
    p.tenant_id,
    p.person_id,
    p.person_kind,
    p.dossier,
    np.first_name,
    np.last_name,
    lp.legal_form,
    e.email AS primary_email,
    ph.phone_number AS primary_phone,
    p.created_at_utc,
    p.updated_at_utc
FROM person.Person p
LEFT JOIN person.NaturalPerson np
    ON np.person_id = p.person_id
LEFT JOIN person.LegalPerson lp
    ON lp.person_id = p.person_id
LEFT JOIN person.Email e
    ON e.person_id = p.person_id
   AND e.is_primary = 1
   AND e.is_deleted = 0
LEFT JOIN person.Phone ph
    ON ph.person_id = p.person_id
   AND ph.is_primary = 1
   AND ph.is_deleted = 0
WHERE p.is_deleted = 0;
GO

CREATE OR ALTER VIEW institution.VW_InstitutionSummary
AS
SELECT
    i.tenant_id,
    i.institution_id,
    i.institution_code,
    i.name,
    i.legal_name,
    i.vat_number,
    ia.street,
    ia.house_number,
    ia.box,
    ia.postal_code,
    ia.city,
    ia.country_code,
    i.is_active,
    i.created_at_utc,
    i.updated_at_utc
FROM institution.Institution i
LEFT JOIN institution.InstitutionAddress ia
    ON ia.institution_id = i.institution_id
   AND ia.is_primary = 1
   AND ia.is_deleted = 0
WHERE i.is_deleted = 0;
GO

CREATE OR ALTER VIEW risk.VW_InsurableObjectSummary
AS
SELECT
    io.tenant_id,
    io.insurable_object_id,
    io.object_type_code,
    io.description,
    io.status_code,
    io.start_date,
    io.end_date,
    v.license_plate,
    v.chassis_number,
    v.brand,
    v.model,
    re.postal_code,
    re.city,
    re.street,
    re.number,
    io.created_at_utc,
    io.updated_at_utc
FROM risk.InsurableObject io
LEFT JOIN risk.InsurableVehicle v
    ON v.insurable_object_id = io.insurable_object_id
LEFT JOIN risk.InsurableRealEstate re
    ON re.insurable_object_id = io.insurable_object_id
WHERE io.is_deleted = 0;
GO

CREATE OR ALTER VIEW policy.VW_ActivePolicy
AS
SELECT
    c.tenant_id,
    c.contract_id,
    c.contract_number,
    c.contract_domain_code,
    c.contract_type_code,
    c.contract_status_code,
    c.start_date,
    c.end_date,
    i.name AS company_name
FROM policy.Contract c
LEFT JOIN institution.Institution i
    ON i.institution_id = c.company_id
WHERE c.is_deleted = 0
  AND c.contract_status_code IN (N'ACTIVE', N'IN_FORCE')
  AND (c.end_date IS NULL OR c.end_date >= CONVERT(date, SYSUTCDATETIME()));
GO

CREATE OR ALTER VIEW policy.VW_PolicyDashboard
AS
SELECT
    c.tenant_id,
    c.contract_id,
    c.contract_number,
    c.contract_status_code,
    c.contract_domain_code,
    c.contract_type_code,
    c.start_date,
    c.end_date,
    i.name AS company_name,
    latest_version.version_no AS latest_version_no,
    latest_version.effective_from AS latest_effective_from,
    latest_version.effective_to AS latest_effective_to,
    party_counts.party_count,
    object_counts.object_count
FROM policy.Contract c
LEFT JOIN institution.Institution i
    ON i.institution_id = c.company_id
OUTER APPLY (
    SELECT TOP (1)
        cv.version_no,
        cv.effective_from,
        cv.effective_to
    FROM policy.ContractVersion cv
    WHERE cv.contract_id = c.contract_id
      AND cv.is_deleted = 0
    ORDER BY cv.version_no DESC
) latest_version
OUTER APPLY (
    SELECT COUNT_BIG(*) AS party_count
    FROM policy.ContractParty cp
    WHERE cp.contract_id = c.contract_id
) party_counts
OUTER APPLY (
    SELECT COUNT_BIG(*) AS object_count
    FROM policy.ContractObject co
    WHERE co.contract_id = c.contract_id
) object_counts
WHERE c.is_deleted = 0;
GO

CREATE OR ALTER VIEW claim.VW_ClaimDashboard
AS
SELECT
    cl.tenant_id,
    cl.claim_id,
    cl.claim_number,
    cl.contract_id,
    c.contract_number,
    cl.coverage_code,
    cl.claim_status_code,
    cl.incident_date,
    cl.reported_date,
    cl.closed_date,
    cl.paid_amount,
    cl.reserved_amount,
    cl.claims_handler_id
FROM claim.Claim cl
INNER JOIN policy.Contract c
    ON c.contract_id = cl.contract_id
WHERE cl.is_deleted = 0;
GO

CREATE OR ALTER VIEW tasking.VW_OpenTaskDashboard
AS
SELECT
    t.tenant_id,
    t.task_id,
    t.title,
    t.related_entity_type,
    t.related_entity_id,
    t.assigned_to_user_id,
    au.display_name AS assigned_to_name,
    t.task_priority_code,
    t.task_status_code,
    t.due_at_utc,
    t.created_at_utc,
    t.updated_at_utc
FROM tasking.Task t
LEFT JOIN core.AppUser au
    ON au.user_id = t.assigned_to_user_id
WHERE t.is_deleted = 0
  AND t.task_status_code IN (N'OPEN', N'IN_PROGRESS', N'WAITING');
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'015__add_views.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'015__add_views.sql',
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


PRINT '=== MIGRATION 016__add_stored_procedures.sql ===';
GO
SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

PRINT 'Running migration: 016__add_stored_procedures.sql';
GO

CREATE OR ALTER PROCEDURE person.SP_CreateNaturalPerson
    @tenant_id UNIQUEIDENTIFIER,
    @dossier NVARCHAR(50) = NULL,
    @language_code CHAR(2) = NULL,
    @nationality NVARCHAR(80) = NULL,
    @first_name NVARCHAR(100) = NULL,
    @last_name NVARCHAR(100) = NULL,
    @birth_date DATE = NULL,
    @title_code NVARCHAR(10) = NULL,
    @created_by_user_id UNIQUEIDENTIFIER = NULL,
    @created_person_id UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CreatedPerson TABLE (
            person_id UNIQUEIDENTIFIER NOT NULL
        );

        INSERT INTO person.Person (
            tenant_id,
            person_kind,
            dossier,
            language_code,
            nationality,
            created_by_user_id
        )
        OUTPUT inserted.person_id INTO @CreatedPerson (person_id)
        VALUES (
            @tenant_id,
            N'NATURAL',
            @dossier,
            @language_code,
            @nationality,
            @created_by_user_id
        );

        SELECT @created_person_id = person_id
        FROM @CreatedPerson;

        INSERT INTO person.NaturalPerson (
            person_id,
            first_name,
            last_name,
            birth_date,
            title_code,
            created_by_user_id
        )
        VALUES (
            @created_person_id,
            @first_name,
            @last_name,
            @birth_date,
            @title_code,
            @created_by_user_id
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE person.SP_SearchPerson
    @tenant_id UNIQUEIDENTIFIER,
    @search_text NVARCHAR(160) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        person_id,
        person_kind,
        dossier,
        first_name,
        last_name,
        legal_form,
        primary_email,
        primary_phone,
        created_at_utc,
        updated_at_utc
    FROM person.VW_CustomerSummary
    WHERE tenant_id = @tenant_id
      AND (
            @search_text IS NULL
         OR dossier LIKE N'%' + @search_text + N'%'
         OR first_name LIKE N'%' + @search_text + N'%'
         OR last_name LIKE N'%' + @search_text + N'%'
         OR primary_email LIKE N'%' + @search_text + N'%'
         OR primary_phone LIKE N'%' + @search_text + N'%'
      )
    ORDER BY last_name, first_name, dossier;
END;
GO

CREATE OR ALTER PROCEDURE institution.SP_SearchInstitution
    @tenant_id UNIQUEIDENTIFIER,
    @search_text NVARCHAR(160) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        institution_id,
        institution_code,
        name,
        legal_name,
        vat_number,
        city,
        country_code,
        is_active
    FROM institution.VW_InstitutionSummary
    WHERE tenant_id = @tenant_id
      AND (
            @search_text IS NULL
         OR institution_code LIKE N'%' + @search_text + N'%'
         OR name LIKE N'%' + @search_text + N'%'
         OR legal_name LIKE N'%' + @search_text + N'%'
         OR vat_number LIKE N'%' + @search_text + N'%'
      )
    ORDER BY name;
END;
GO

CREATE OR ALTER PROCEDURE risk.SP_SearchVehicle
    @tenant_id UNIQUEIDENTIFIER,
    @search_text NVARCHAR(120) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        insurable_object_id,
        object_type_code,
        description,
        status_code,
        license_plate,
        chassis_number,
        brand,
        model,
        start_date,
        end_date
    FROM risk.VW_InsurableObjectSummary
    WHERE tenant_id = @tenant_id
      AND license_plate IS NOT NULL
      AND (
            @search_text IS NULL
         OR license_plate LIKE N'%' + @search_text + N'%'
         OR chassis_number LIKE N'%' + @search_text + N'%'
         OR brand LIKE N'%' + @search_text + N'%'
         OR model LIKE N'%' + @search_text + N'%'
      )
    ORDER BY license_plate;
END;
GO

CREATE OR ALTER PROCEDURE policy.SP_CreateContract
    @tenant_id UNIQUEIDENTIFIER,
    @contract_number NVARCHAR(40),
    @contract_domain_code NVARCHAR(40),
    @contract_type_code NVARCHAR(80),
    @contract_status_code NVARCHAR(40),
    @start_date DATE,
    @company_id UNIQUEIDENTIFIER = NULL,
    @handling_company_id UNIQUEIDENTIFIER = NULL,
    @end_date DATE = NULL,
    @created_by_user_id UNIQUEIDENTIFIER = NULL,
    @created_contract_id UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CreatedContract TABLE (
            contract_id UNIQUEIDENTIFIER NOT NULL
        );

        INSERT INTO policy.Contract (
            tenant_id,
            contract_number,
            contract_domain_code,
            contract_type_code,
            contract_status_code,
            company_id,
            handling_company_id,
            start_date,
            end_date,
            created_by_user_id
        )
        OUTPUT inserted.contract_id INTO @CreatedContract (contract_id)
        VALUES (
            @tenant_id,
            @contract_number,
            @contract_domain_code,
            @contract_type_code,
            @contract_status_code,
            @company_id,
            @handling_company_id,
            @start_date,
            @end_date,
            @created_by_user_id
        );

        SELECT @created_contract_id = contract_id
        FROM @CreatedContract;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE policy.SP_CreateContractVersion
    @tenant_id UNIQUEIDENTIFIER,
    @contract_id UNIQUEIDENTIFIER,
    @version_no INT,
    @effective_from DATE,
    @contract_version_status_code NVARCHAR(40),
    @duration_type_code NVARCHAR(20),
    @periodicity_code NVARCHAR(40),
    @collection_method_code NVARCHAR(20),
    @effective_to DATE = NULL,
    @created_by_user_id UNIQUEIDENTIFIER = NULL,
    @created_contract_version_id UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1
            FROM policy.Contract
            WHERE contract_id = @contract_id
              AND tenant_id = @tenant_id
              AND is_deleted = 0
        )
            THROW 51602, 'Contract not found for tenant.', 1;

        DECLARE @CreatedContractVersion TABLE (
            contract_version_id UNIQUEIDENTIFIER NOT NULL
        );

        INSERT INTO policy.ContractVersion (
            contract_id,
            version_no,
            effective_from,
            effective_to,
            contract_version_status_code,
            duration_type_code,
            periodicity_code,
            collection_method_code,
            created_by_user_id
        )
        OUTPUT inserted.contract_version_id INTO @CreatedContractVersion (contract_version_id)
        VALUES (
            @contract_id,
            @version_no,
            @effective_from,
            @effective_to,
            @contract_version_status_code,
            @duration_type_code,
            @periodicity_code,
            @collection_method_code,
            @created_by_user_id
        );

        SELECT @created_contract_version_id = contract_version_id
        FROM @CreatedContractVersion;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE policy.SP_AddContractParty
    @tenant_id UNIQUEIDENTIFIER,
    @contract_id UNIQUEIDENTIFIER,
    @person_id UNIQUEIDENTIFIER,
    @contract_party_role_code NVARCHAR(40),
    @is_primary BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1
            FROM policy.Contract
            WHERE contract_id = @contract_id
              AND tenant_id = @tenant_id
              AND is_deleted = 0
        )
            THROW 51603, 'Contract not found for tenant.', 1;

        INSERT INTO policy.ContractParty (
            contract_id,
            person_id,
            contract_party_role_code,
            is_primary
        )
        VALUES (
            @contract_id,
            @person_id,
            @contract_party_role_code,
            @is_primary
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE policy.SP_AddContractObject
    @tenant_id UNIQUEIDENTIFIER,
    @contract_id UNIQUEIDENTIFIER,
    @insurable_object_id UNIQUEIDENTIFIER,
    @contract_object_status_code NVARCHAR(20),
    @is_primary BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1
            FROM policy.Contract
            WHERE contract_id = @contract_id
              AND tenant_id = @tenant_id
              AND is_deleted = 0
        )
            THROW 51604, 'Contract not found for tenant.', 1;

        INSERT INTO policy.ContractObject (
            contract_id,
            insurable_object_id,
            contract_object_status_code,
            is_primary
        )
        VALUES (
            @contract_id,
            @insurable_object_id,
            @contract_object_status_code,
            @is_primary
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE claim.SP_CreateClaim
    @tenant_id UNIQUEIDENTIFIER,
    @claim_number NVARCHAR(50),
    @contract_id UNIQUEIDENTIFIER,
    @claim_status_code NVARCHAR(40),
    @reported_date DATE,
    @coverage_code NVARCHAR(80) = NULL,
    @claims_handler_id UNIQUEIDENTIFIER = NULL,
    @incident_date DATE = NULL,
    @description NVARCHAR(500) = NULL,
    @created_by_user_id UNIQUEIDENTIFIER = NULL,
    @created_claim_id UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CreatedClaim TABLE (
            claim_id UNIQUEIDENTIFIER NOT NULL
        );

        INSERT INTO claim.Claim (
            tenant_id,
            claim_number,
            contract_id,
            coverage_code,
            claim_status_code,
            claims_handler_id,
            incident_date,
            reported_date,
            description,
            created_by_user_id
        )
        OUTPUT inserted.claim_id INTO @CreatedClaim (claim_id)
        VALUES (
            @tenant_id,
            @claim_number,
            @contract_id,
            @coverage_code,
            @claim_status_code,
            @claims_handler_id,
            @incident_date,
            @reported_date,
            @description,
            @created_by_user_id
        );

        SELECT @created_claim_id = claim_id
        FROM @CreatedClaim;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE claim.SP_CloseClaim
    @tenant_id UNIQUEIDENTIFIER,
    @claim_id UNIQUEIDENTIFIER,
    @closed_date DATE,
    @paid_amount DECIMAL(18,2) = NULL,
    @reserved_amount DECIMAL(18,2) = NULL,
    @payment_method_code NVARCHAR(40) = NULL,
    @updated_by_user_id UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE claim.Claim
            SET claim_status_code = N'CLOSED',
                closed_date = @closed_date,
                paid_amount = @paid_amount,
                reserved_amount = @reserved_amount,
                payment_method_code = @payment_method_code,
                updated_by_user_id = @updated_by_user_id,
                updated_at_utc = SYSUTCDATETIME()
        WHERE claim_id = @claim_id
          AND tenant_id = @tenant_id
          AND is_deleted = 0;

        IF @@ROWCOUNT = 0
            THROW 51601, 'Claim not found or deleted.', 1;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE audit.SP_GetEntityAuditTrail
    @schema_name SYSNAME,
    @table_name SYSNAME,
    @primary_key_value NVARCHAR(200),
    @tenant_id UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        audit_log_id,
        tenant_id,
        schema_name,
        table_name,
        primary_key_value,
        action_type,
        changed_at_utc,
        changed_by_user_id,
        changed_by_name,
        old_values_json,
        new_values_json,
        source_system,
        correlation_id
    FROM audit.AuditLog
    WHERE schema_name = @schema_name
      AND table_name = @table_name
      AND primary_key_value = @primary_key_value
      AND (@tenant_id IS NULL OR tenant_id = @tenant_id)
    ORDER BY changed_at_utc DESC, audit_log_id DESC;
END;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'016__add_stored_procedures.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'016__add_stored_procedures.sql',
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


PRINT '=== MIGRATION 017__seed_lookup_data.sql ===';
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

PRINT 'Running migration: 017__seed_lookup_data.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    MERGE ref.Language AS target
    USING (VALUES
        ('nl', N'Nederlands', N'Neerlandais', N'Dutch', N'Felemenkce', 10),
        ('fr', N'Frans', N'Francais', N'French', N'Fransizca', 20),
        ('en', N'Engels', N'Anglais', N'English', N'Ingilizce', 30),
        ('tr', N'Turks', N'Turc', N'Turkish', N'Turkce', 40)
    ) AS source (language_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.language_code = source.language_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (language_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.language_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE ref.Title AS target
    USING (VALUES
        (N'MR', N'Mijnheer', N'Monsieur', N'Mr', N'Bay', 10),
        (N'MRS', N'Mevrouw', N'Madame', N'Mrs', N'Bayan', 20)
    ) AS source (title_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.title_code = source.title_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (title_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.title_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE ref.PhoneType AS target
    USING (VALUES
        (N'MOBILE', N'Mobiel', N'Mobile', N'Mobile', N'Cep', 10),
        (N'LANDLINE', N'Vast', N'Fixe', N'Landline', N'Sabit', 20),
        (N'FAX', N'Fax', N'Fax', N'Fax', N'Faks', 30),
        (N'OTHER', N'Overige', N'Autre', N'Other', N'Diger', 40)
    ) AS source (phone_type_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.phone_type_code = source.phone_type_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (phone_type_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.phone_type_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE ref.SocialType AS target
    USING (VALUES
        (N'LINKEDIN', N'LinkedIn', N'LinkedIn', N'LinkedIn', N'LinkedIn', 10),
        (N'FACEBOOK', N'Facebook', N'Facebook', N'Facebook', N'Facebook', 20),
        (N'INSTAGRAM', N'Instagram', N'Instagram', N'Instagram', N'Instagram', 30),
        (N'OTHER', N'Overige', N'Autre', N'Other', N'Diger', 40)
    ) AS source (social_type_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.social_type_code = source.social_type_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (social_type_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.social_type_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE ref.ProfessionalStatus AS target
    USING (VALUES
        (N'EMPLOYEE', N'Bediende', N'Employe', N'Employee', N'Calisan', 10),
        (N'WORKER', N'Arbeider', N'Ouvrier', N'Worker', N'Isci', 20),
        (N'SELF_EMPLOYED', N'Zelfstandige', N'Independant', N'Self-employed', N'Serbest', 30),
        (N'RETIRED', N'Gepensioneerd', N'Retraite', N'Retired', N'Emekli', 40),
        (N'STUDENT', N'Student', N'Etudiant', N'Student', N'Ogrenci', 50)
    ) AS source (professional_status_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.professional_status_code = source.professional_status_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (professional_status_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.professional_status_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE ref.PersonType AS target
    USING (VALUES
        (N'CUSTOMER', N'Klant', N'Client', N'Customer', N'Musteri', 10),
        (N'PROSPECT', N'Prospect', N'Prospect', N'Prospect', N'Aday', 20),
        (N'SUBAGENT', N'Subagent', N'Sous-agent', N'Subagent', N'Alt acente', 30)
    ) AS source (person_type_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.person_type_code = source.person_type_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (person_type_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.person_type_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE person.PersonAddressRole AS target
    USING (VALUES
        (N'HOME', N'Thuis', N'Domicile', N'Home', N'Ev', 10),
        (N'POSTAL', N'Postadres', N'Adresse postale', N'Postal', N'Posta', 20),
        (N'BILLING', N'Facturatie', N'Facturation', N'Billing', N'Fatura', 30)
    ) AS source (address_role_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.address_role_code = source.address_role_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (address_role_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.address_role_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE person.PersonRelationType AS target
    USING (VALUES
        (N'SPOUSE', N'FAMILY', N'Echtgenoot', N'Conjoint', N'Spouse', N'Es', 10),
        (N'CHILD', N'FAMILY', N'Kind', N'Enfant', N'Child', N'Cocuk', 20),
        (N'EMPLOYER', N'BUSINESS', N'Werkgever', N'Employeur', N'Employer', N'Isveren', 30)
    ) AS source (relation_type_code, relation_category, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.relation_type_code = source.relation_type_code
    WHEN MATCHED THEN
        UPDATE SET relation_category = source.relation_category, label_nl = source.label_nl,
            label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr,
            sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (relation_type_code, relation_category, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.relation_type_code, source.relation_category, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE institution.InstitutionRole AS target
    USING (VALUES
        (N'INSURER', N'Verzekeraar', N'Assureur', N'Insurer', N'Sigortaci', 10),
        (N'BROKER', N'Makelaar', N'Courtier', N'Broker', N'Broker', 20),
        (N'BANK', N'Bank', N'Banque', N'Bank', N'Banka', 30),
        (N'LEASING', N'Leasing', N'Leasing', N'Leasing', N'Leasing', 40)
    ) AS source (institution_role_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.institution_role_code = source.institution_role_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (institution_role_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.institution_role_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE institution.InstitutionIdentifierType AS target
    USING (VALUES
        (N'KBO', N'KBO nummer', N'Numero BCE', N'KBO number', N'KBO no', 10),
        (N'VAT', N'BTW nummer', N'Numero TVA', N'VAT number', N'KDV no', 20),
        (N'FSMA', N'FSMA nummer', N'Numero FSMA', N'FSMA number', N'FSMA no', 30)
    ) AS source (id_type_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.id_type_code = source.id_type_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (id_type_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.id_type_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE institution.InstitutionAddressRole AS target
    USING (VALUES
        (N'HEAD_OFFICE', N'Hoofdzetel', N'Siege social', N'Head office', N'Merkez', 10),
        (N'POSTAL', N'Postadres', N'Adresse postale', N'Postal', N'Posta', 20),
        (N'BILLING', N'Facturatie', N'Facturation', N'Billing', N'Fatura', 30)
    ) AS source (address_role_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.address_role_code = source.address_role_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (address_role_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.address_role_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE risk.InsurableObjectType AS target
    USING (VALUES
        (N'VEHICLE', N'Voertuig', N'Vehicule', N'Vehicle', N'Arac', 10),
        (N'REAL_ESTATE', N'Onroerend goed', N'Immobilier', N'Real estate', N'Gayrimenkul', 20),
        (N'LOAN', N'Lening', N'Pret', N'Loan', N'Kredi', 30),
        (N'PERSON', N'Persoon', N'Personne', N'Person', N'Kisi', 40),
        (N'THING', N'Zaak', N'Objet', N'Thing', N'Esya', 50),
        (N'ACTIVITY', N'Activiteit', N'Activite', N'Activity', N'Etkinlik', 60)
    ) AS source (object_type_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.object_type_code = source.object_type_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (object_type_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.object_type_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE risk.VehicleType AS target
    USING (VALUES
        (N'CAR', N'Personenwagen', N'Voiture', 10),
        (N'VAN', N'Bestelwagen', N'Camionnette', 20),
        (N'MOTORCYCLE', N'Motorfiets', N'Moto', 30)
    ) AS source (vehicle_type_code, label_nl, label_fr, sort_order)
    ON target.vehicle_type_code = source.vehicle_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (vehicle_type_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.vehicle_type_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.UsageType AS target
    USING (VALUES
        (N'PRIVATE', N'Prive', N'Prive', 10),
        (N'PROFESSIONAL', N'Professioneel', N'Professionnel', 20)
    ) AS source (usage_type_code, label_nl, label_fr, sort_order)
    ON target.usage_type_code = source.usage_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (usage_type_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.usage_type_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.FuelType AS target
    USING (VALUES
        (N'PETROL', N'Benzine', N'Essence', 10),
        (N'DIESEL', N'Diesel', N'Diesel', 20),
        (N'ELECTRIC', N'Elektrisch', N'Electrique', 30)
    ) AS source (fuel_type_code, label_nl, label_fr, sort_order)
    ON target.fuel_type_code = source.fuel_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (fuel_type_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.fuel_type_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.DriveType AS target
    USING (VALUES
        (N'FWD', N'Voorwielaandrijving', N'Traction', 10),
        (N'RWD', N'Achterwielaandrijving', N'Propulsion', 20),
        (N'AWD', N'Vierwielaandrijving', N'Integrale', 30)
    ) AS source (drive_type_code, label_nl, label_fr, sort_order)
    ON target.drive_type_code = source.drive_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (drive_type_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.drive_type_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.LicensePlateType AS target
    USING (VALUES
        (N'NORMAL', N'Normaal', N'Normal', 10),
        (N'TEMPORARY', N'Tijdelijk', N'Temporaire', 20)
    ) AS source (plate_type_code, label_nl, label_fr, sort_order)
    ON target.plate_type_code = source.plate_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (plate_type_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.plate_type_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.RealEstateType AS target
    USING (VALUES
        (N'HOUSE', N'Woning', N'Maison', 10),
        (N'APARTMENT', N'Appartement', N'Appartement', 20),
        (N'COMMERCIAL', N'Handelspand', N'Commercial', 30)
    ) AS source (realestate_type_code, label_nl, label_fr, sort_order)
    ON target.realestate_type_code = source.realestate_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (realestate_type_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.realestate_type_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.InsuredRole AS target
    USING (VALUES
        (N'OWNER', N'Eigenaar', N'Proprietaire', 10),
        (N'TENANT', N'Huurder', N'Locataire', 20)
    ) AS source (insured_role_code, label_nl, label_fr, sort_order)
    ON target.insured_role_code = source.insured_role_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (insured_role_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.insured_role_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.UseTypeRealEstate AS target
    USING (VALUES
        (N'PRIVATE', N'Prive gebruik', N'Usage prive', 10),
        (N'COMMERCIAL', N'Commercieel gebruik', N'Usage commercial', 20)
    ) AS source (use_type_code, label_nl, label_fr, sort_order)
    ON target.use_type_code = source.use_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (use_type_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.use_type_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE policy.ContractDomain AS target
    USING (VALUES
        (N'MOTOR', N'Motor', N'Auto', N'Motor', N'Trafik', 10),
        (N'FIRE', N'Brand', N'Incendie', N'Fire', N'Yangin', 20),
        (N'FAMILY', N'Familie', N'Famille', N'Family', N'Aile', 30),
        (N'LOAN', N'Lening', N'Pret', N'Loan', N'Kredi', 40),
        (N'GENERAL', N'Algemeen', N'General', N'General', N'Genel', 50)
    ) AS source (contract_domain_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.contract_domain_code = source.contract_domain_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (contract_domain_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.contract_domain_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE policy.ContractStatus AS target
    USING (VALUES
        (N'DRAFT', N'Concept', N'Brouillon', N'Draft', N'Taslak', 10),
        (N'QUOTE', N'Offerte', N'Offre', N'Quote', N'Teklif', 20),
        (N'ACTIVE', N'Actief', N'Actif', N'Active', N'Aktif', 30),
        (N'SUSPENDED', N'Geschorst', N'Suspendu', N'Suspended', N'Askida', 40),
        (N'CANCELLED', N'Geannuleerd', N'Annule', N'Cancelled', N'Iptal', 50),
        (N'EXPIRED', N'Verlopen', N'Expire', N'Expired', N'Suresi doldu', 60),
        (N'ARCHIVED', N'Gearchiveerd', N'Archive', N'Archived', N'Arsiv', 70)
    ) AS source (contract_status_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.contract_status_code = source.contract_status_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (contract_status_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.contract_status_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE policy.ContractVersionStatus AS target
    USING (VALUES
        (N'DRAFT', N'Concept', N'Brouillon', N'Draft', N'Taslak', 10),
        (N'PENDING_APPROVAL', N'Wacht op goedkeuring', N'En attente', N'Pending approval', N'Onay bekliyor', 20),
        (N'ACTIVE', N'Actief', N'Actif', N'Active', N'Aktif', 30),
        (N'SUPERSEDED', N'Vervangen', N'Remplace', N'Superseded', N'Degisti', 40),
        (N'CANCELLED', N'Geannuleerd', N'Annule', N'Cancelled', N'Iptal', 50)
    ) AS source (contract_version_status_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.contract_version_status_code = source.contract_version_status_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (contract_version_status_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.contract_version_status_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE policy.Periodicity AS target
    USING (VALUES
        (N'MONTHLY', N'Maandelijks', N'Mensuel', N'Monthly', N'Aylik', 10),
        (N'QUARTERLY', N'Driemaandelijks', N'Trimestriel', N'Quarterly', N'Uc aylik', 20),
        (N'YEARLY', N'Jaarlijks', N'Annuel', N'Yearly', N'Yillik', 30)
    ) AS source (periodicity_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.periodicity_code = source.periodicity_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (periodicity_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.periodicity_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE policy.CollectionMethod AS target
    USING (VALUES
        (N'DIRECT_DEBIT', N'Domiciliering', N'Domiciliation', N'Direct debit', N'Otomatik odeme', 10),
        (N'BANK_TRANSFER', N'Overschrijving', N'Virement', N'Bank transfer', N'Havale', 20)
    ) AS source (collection_method_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.collection_method_code = source.collection_method_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (collection_method_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.collection_method_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE policy.DurationType AS target
    USING (VALUES
        (N'FIXED', N'Vast', N'Fixe', N'Fixed', N'Sabit', 10),
        (N'INDEFINITE', N'Onbepaald', N'Indetermine', N'Indefinite', N'Suresiz', 20)
    ) AS source (duration_type_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.duration_type_code = source.duration_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (duration_type_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.duration_type_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE policy.ContractType AS target
    USING (VALUES
        (N'AUTO_BA', N'MOTOR', N'BA Auto', N'RC Auto', N'Motor liability', N'Trafik sorumluluk', 10),
        (N'FIRE_HOME', N'FIRE', N'Brand woning', N'Incendie habitation', N'Home fire', N'Konut yangin', 20),
        (N'FAMILY_RC', N'FAMILY', N'Familiale BA', N'RC familiale', N'Family liability', N'Aile sorumluluk', 30),
        (N'LOAN_PROTECTION', N'LOAN', N'Lening bescherming', N'Protection pret', N'Loan protection', N'Kredi koruma', 40)
    ) AS source (contract_type_code, contract_domain_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.contract_type_code = source.contract_type_code
    WHEN MATCHED THEN
        UPDATE SET contract_domain_code = source.contract_domain_code, label_nl = source.label_nl,
            label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr,
            sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (contract_type_code, contract_domain_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.contract_type_code, source.contract_domain_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE policy.ContractPartyRole AS target
    USING (VALUES
        (N'POLICYHOLDER', N'Verzekeringnemer', N'Preneur', N'Policyholder', N'Police sahibi', 10),
        (N'INSURED', N'Verzekerde', N'Assure', N'Insured', N'Sigortali', 20),
        (N'BENEFICIARY', N'Begunstigde', N'Beneficiaire', N'Beneficiary', N'Lehtar', 30)
    ) AS source (contract_party_role_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.contract_party_role_code = source.contract_party_role_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (contract_party_role_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.contract_party_role_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE policy.ContractObjectStatus AS target
    USING (VALUES
        (N'ACTIVE', N'Actief', N'Actif', N'Active', N'Aktif', 10),
        (N'REMOVED', N'Verwijderd', N'Supprime', N'Removed', N'Kaldirildi', 20)
    ) AS source (contract_object_status_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.contract_object_status_code = source.contract_object_status_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (contract_object_status_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.contract_object_status_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE policy.TakeoverDirection AS target
    USING (VALUES
        (N'IN', N'Inkomend', N'Entrant', 10),
        (N'OUT', N'Uitgaand', N'Sortant', 20)
    ) AS source (takeover_direction_code, label_nl, label_fr, sort_order)
    ON target.takeover_direction_code = source.takeover_direction_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (takeover_direction_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.takeover_direction_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE policy.TakeoverSourceType AS target
    USING (VALUES
        (N'EXTERNAL_COMPANY', N'Externe maatschappij', N'Compagnie externe', 10),
        (N'INTERNAL_POLICY', N'Interne polis', N'Police interne', 20)
    ) AS source (takeover_source_type_code, label_nl, label_fr, sort_order)
    ON target.takeover_source_type_code = source.takeover_source_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (takeover_source_type_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.takeover_source_type_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE claim.ClaimStatus AS target
    USING (VALUES
        (N'OPEN', N'Open', N'Ouvert', N'Open', N'Acik', 10),
        (N'IN_REVIEW', N'In onderzoek', N'En revue', N'In review', N'Incelemede', 20),
        (N'WAITING_DOCUMENTS', N'Wacht op documenten', N'Attente documents', N'Waiting documents', N'Belge bekliyor', 30),
        (N'APPROVED', N'Goedgekeurd', N'Approuve', N'Approved', N'Onaylandi', 40),
        (N'REJECTED', N'Afgewezen', N'Rejete', N'Rejected', N'Reddedildi', 50),
        (N'PAID', N'Betaald', N'Paye', N'Paid', N'Odendi', 60),
        (N'CLOSED', N'Gesloten', N'Ferme', N'Closed', N'Kapali', 70)
    ) AS source (claim_status_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.claim_status_code = source.claim_status_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (claim_status_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.claim_status_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE claim.ClaimPartyRole AS target
    USING (VALUES
        (N'CLAIMANT', N'Eiser', N'Demandeur', N'Claimant', N'Talep eden', 10),
        (N'INSURED', N'Verzekerde', N'Assure', N'Insured', N'Sigortali', 20),
        (N'THIRD_PARTY', N'Derde partij', N'Tiers', N'Third party', N'Ucuncu taraf', 30)
    ) AS source (claim_party_role_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.claim_party_role_code = source.claim_party_role_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (claim_party_role_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.claim_party_role_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE claim.ClaimCircumstanceType AS target
    USING (VALUES
        (N'ACCIDENT', N'Ongeval', N'Accident', N'Accident', N'Kaza', 10),
        (N'THEFT', N'Diefstal', N'Vol', N'Theft', N'Hirsizlik', 20),
        (N'FIRE', N'Brand', N'Incendie', N'Fire', N'Yangin', 30),
        (N'WATER_DAMAGE', N'Waterschade', N'Degats des eaux', N'Water damage', N'Su hasari', 40)
    ) AS source (claim_circumstance_type_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.claim_circumstance_type_code = source.claim_circumstance_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (claim_circumstance_type_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.claim_circumstance_type_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE claim.ClaimPaymentMethod AS target
    USING (VALUES
        (N'BANK_TRANSFER', N'Overschrijving', N'Virement', N'Bank transfer', N'Havale', 10),
        (N'DIRECT_PAYMENT', N'Rechtstreekse betaling', N'Paiement direct', N'Direct payment', N'Dogrudan odeme', 20)
    ) AS source (payment_method_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.payment_method_code = source.payment_method_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (payment_method_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.payment_method_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE tasking.TaskStatus AS target
    USING (VALUES
        (N'OPEN', N'Open', N'Ouvert', N'Open', N'Acik', 10),
        (N'IN_PROGRESS', N'In behandeling', N'En cours', N'In progress', N'Islemde', 20),
        (N'WAITING', N'Wachtend', N'En attente', N'Waiting', N'Bekliyor', 30),
        (N'DONE', N'Klaar', N'Termine', N'Done', N'Tamam', 40),
        (N'CANCELLED', N'Geannuleerd', N'Annule', N'Cancelled', N'Iptal', 50)
    ) AS source (task_status_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.task_status_code = source.task_status_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (task_status_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.task_status_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE tasking.TaskPriority AS target
    USING (VALUES
        (N'LOW', N'Laag', N'Bas', N'Low', N'Dusuk', 10),
        (N'NORMAL', N'Normaal', N'Normal', N'Normal', N'Normal', 20),
        (N'HIGH', N'Hoog', N'Haut', N'High', N'Yuksek', 30),
        (N'URGENT', N'Dringend', N'Urgent', N'Urgent', N'Acil', 40)
    ) AS source (task_priority_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.task_priority_code = source.task_priority_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (task_priority_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.task_priority_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE document.DocumentType AS target
    USING (VALUES
        (N'ID_CARD', N'Identiteitskaart', N'Carte identite', N'ID card', N'Kimlik karti', 10),
        (N'PASSPORT', N'Paspoort', N'Passeport', N'Passport', N'Pasaport', 20),
        (N'POLICY_DOCUMENT', N'Polisdocument', N'Document police', N'Policy document', N'Police dokumani', 30),
        (N'GREEN_CARD', N'Groene kaart', N'Carte verte', N'Green card', N'Yesil kart', 40),
        (N'CLAIM_REPORT', N'Schaderapport', N'Rapport sinistre', N'Claim report', N'Hasar raporu', 50),
        (N'INVOICE', N'Factuur', N'Facture', N'Invoice', N'Fatura', 60),
        (N'PHOTO', N'Foto', N'Photo', N'Photo', N'Fotograf', 70),
        (N'BANK_DOCUMENT', N'Bankdocument', N'Document bancaire', N'Bank document', N'Banka dokumani', 80),
        (N'SIGNED_CONTRACT', N'Getekend contract', N'Contrat signe', N'Signed contract', N'Imzali sozlesme', 90),
        (N'EMAIL_ATTACHMENT', N'E-mail bijlage', N'Piece jointe email', N'Email attachment', N'E-posta eki', 100)
    ) AS source (document_type_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.document_type_code = source.document_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (document_type_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.document_type_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE core.Permission AS target
    USING (VALUES
        (N'person.read', N'Read persons', N'person'),
        (N'person.write', N'Write persons', N'person'),
        (N'person.delete', N'Delete persons', N'person'),
        (N'institution.read', N'Read institutions', N'institution'),
        (N'institution.write', N'Write institutions', N'institution'),
        (N'risk.read', N'Read risks', N'risk'),
        (N'risk.write', N'Write risks', N'risk'),
        (N'policy.read', N'Read policies', N'policy'),
        (N'policy.write', N'Write policies', N'policy'),
        (N'policy.version.create', N'Create policy versions', N'policy'),
        (N'claim.read', N'Read claims', N'claim'),
        (N'claim.write', N'Write claims', N'claim'),
        (N'claim.close', N'Close claims', N'claim'),
        (N'document.upload', N'Upload documents', N'document'),
        (N'document.read', N'Read documents', N'document'),
        (N'admin.lookup.manage', N'Manage lookups', N'admin'),
        (N'admin.user.manage', N'Manage users', N'admin'),
        (N'audit.read', N'Read audit logs', N'audit')
    ) AS source (permission_code, permission_name, module_code)
    ON target.permission_code = source.permission_code
    WHEN MATCHED THEN UPDATE SET permission_name = source.permission_name, module_code = source.module_code, is_active = 1
    WHEN NOT MATCHED THEN INSERT (permission_code, permission_name, module_code, is_active)
        VALUES (source.permission_code, source.permission_name, source.module_code, 1);

    MERGE core.Role AS target
    USING (VALUES
        (N'SYSTEM_ADMIN', N'System administrator', 1),
        (N'BROKER_ADMIN', N'Broker administrator', 1),
        (N'BROKER_USER', N'Broker user', 1),
        (N'CLAIM_HANDLER', N'Claim handler', 1)
    ) AS source (role_code, role_name, is_system_role)
    ON target.tenant_id IS NULL
       AND target.role_code = source.role_code
    WHEN MATCHED THEN UPDATE SET role_name = source.role_name, is_system_role = source.is_system_role, is_active = 1
    WHEN NOT MATCHED THEN INSERT (tenant_id, role_code, role_name, is_system_role, is_active)
        VALUES (NULL, source.role_code, source.role_name, source.is_system_role, 1);

    INSERT INTO core.RolePermission (role_id, permission_code)
    SELECT r.role_id, p.permission_code
    FROM core.Role r
    CROSS JOIN core.Permission p
    WHERE r.tenant_id IS NULL
      AND r.role_code = N'SYSTEM_ADMIN'
      AND NOT EXISTS (
        SELECT 1
        FROM core.RolePermission rp
        WHERE rp.role_id = r.role_id
          AND rp.permission_code = p.permission_code
      );

    INSERT INTO core.RolePermission (role_id, permission_code)
    SELECT r.role_id, p.permission_code
    FROM core.Role r
    INNER JOIN core.Permission p
        ON p.permission_code IN (
            N'person.read', N'person.write',
            N'institution.read', N'institution.write',
            N'risk.read', N'risk.write',
            N'policy.read', N'policy.write', N'policy.version.create',
            N'claim.read', N'claim.write',
            N'document.upload', N'document.read',
            N'admin.lookup.manage', N'admin.user.manage'
        )
    WHERE r.tenant_id IS NULL
      AND r.role_code = N'BROKER_ADMIN'
      AND NOT EXISTS (
        SELECT 1
        FROM core.RolePermission rp
        WHERE rp.role_id = r.role_id
          AND rp.permission_code = p.permission_code
      );

    INSERT INTO core.RolePermission (role_id, permission_code)
    SELECT r.role_id, p.permission_code
    FROM core.Role r
    INNER JOIN core.Permission p
        ON p.permission_code IN (
            N'person.read',
            N'institution.read',
            N'risk.read',
            N'policy.read',
            N'claim.read',
            N'document.read'
        )
    WHERE r.tenant_id IS NULL
      AND r.role_code = N'BROKER_USER'
      AND NOT EXISTS (
        SELECT 1
        FROM core.RolePermission rp
        WHERE rp.role_id = r.role_id
          AND rp.permission_code = p.permission_code
      );

    INSERT INTO core.RolePermission (role_id, permission_code)
    SELECT r.role_id, p.permission_code
    FROM core.Role r
    INNER JOIN core.Permission p
        ON p.permission_code IN (
            N'claim.read',
            N'claim.write',
            N'claim.close',
            N'document.upload',
            N'document.read'
        )
    WHERE r.tenant_id IS NULL
      AND r.role_code = N'CLAIM_HANDLER'
      AND NOT EXISTS (
        SELECT 1
        FROM core.RolePermission rp
        WHERE rp.role_id = r.role_id
          AND rp.permission_code = p.permission_code
      );

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'017__seed_lookup_data.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'017__seed_lookup_data.sql',
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


PRINT '=== MIGRATION 018__seed_demo_data.sql ===';
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

PRINT 'Running optional migration: 018__seed_demo_data.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @TenantId UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000000001';
    DECLARE @UserAdmin UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000000101';
    DECLARE @UserBroker UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000000102';
    DECLARE @UserClaim UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000000103';
    DECLARE @Person1 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000001001';
    DECLARE @Person2 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000001002';
    DECLARE @Person3 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000001003';
    DECLARE @Person4 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000001004';
    DECLARE @Person5 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000001005';
    DECLARE @Legal1 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000001101';
    DECLARE @Legal2 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000001102';
    DECLARE @Inst1 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000002001';
    DECLARE @Inst2 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000002002';
    DECLARE @Inst3 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000002003';
    DECLARE @Vehicle1 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000003001';
    DECLARE @Vehicle2 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000003002';
    DECLARE @Vehicle3 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000003003';
    DECLARE @Estate1 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000003101';
    DECLARE @Estate2 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000003102';
    DECLARE @Contract1 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000004001';
    DECLARE @Contract2 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000004002';
    DECLARE @Contract3 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000004003';
    DECLARE @Contract4 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000004004';
    DECLARE @Version1 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000004101';
    DECLARE @Version2 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000004102';
    DECLARE @Claim1 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000005001';
    DECLARE @Claim2 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000005002';

    IF NOT EXISTS (SELECT 1 FROM core.Tenant WHERE tenant_id = @TenantId)
    BEGIN
        INSERT INTO core.Tenant (
            tenant_id,
            tenant_code,
            legal_name,
            display_name,
            vat_number,
            country_code,
            default_language
        )
        VALUES (
            @TenantId,
            N'DEMO-BE-BROKER',
            N'Yafes Demo Broker BV',
            N'Yafes Demo Broker',
            N'BE0123456789',
            'BE',
            'nl'
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM person.Person WHERE person_id = @Person1)
        INSERT INTO person.Person (person_id, tenant_id, person_kind, dossier, language_code, nationality)
        VALUES (@Person1, @TenantId, N'NATURAL', N'DEMO-P-001', 'nl', N'Belgian');
    IF NOT EXISTS (SELECT 1 FROM person.NaturalPerson WHERE person_id = @Person1)
        INSERT INTO person.NaturalPerson (person_id, first_name, last_name, birth_date, title_code)
        VALUES (@Person1, N'Jan', N'Peeters', '1982-04-12', N'MR');

    IF NOT EXISTS (SELECT 1 FROM person.Person WHERE person_id = @Person2)
        INSERT INTO person.Person (person_id, tenant_id, person_kind, dossier, language_code, nationality)
        VALUES (@Person2, @TenantId, N'NATURAL', N'DEMO-P-002', 'fr', N'Belgian');
    IF NOT EXISTS (SELECT 1 FROM person.NaturalPerson WHERE person_id = @Person2)
        INSERT INTO person.NaturalPerson (person_id, first_name, last_name, birth_date, title_code)
        VALUES (@Person2, N'Marie', N'Dubois', '1976-08-21', N'MRS');

    IF NOT EXISTS (SELECT 1 FROM person.Person WHERE person_id = @Person3)
        INSERT INTO person.Person (person_id, tenant_id, person_kind, dossier, language_code, nationality)
        VALUES (@Person3, @TenantId, N'NATURAL', N'DEMO-P-003', 'nl', N'Belgian');
    IF NOT EXISTS (SELECT 1 FROM person.NaturalPerson WHERE person_id = @Person3)
        INSERT INTO person.NaturalPerson (person_id, first_name, last_name, birth_date, title_code)
        VALUES (@Person3, N'Anke', N'Janssens', '1990-01-08', N'MRS');

    IF NOT EXISTS (SELECT 1 FROM person.Person WHERE person_id = @Person4)
        INSERT INTO person.Person (person_id, tenant_id, person_kind, dossier, language_code, nationality)
        VALUES (@Person4, @TenantId, N'NATURAL', N'DEMO-P-004', 'fr', N'Belgian');
    IF NOT EXISTS (SELECT 1 FROM person.NaturalPerson WHERE person_id = @Person4)
        INSERT INTO person.NaturalPerson (person_id, first_name, last_name, birth_date, title_code)
        VALUES (@Person4, N'Luc', N'Martin', '1969-11-03', N'MR');

    IF NOT EXISTS (SELECT 1 FROM person.Person WHERE person_id = @Person5)
        INSERT INTO person.Person (person_id, tenant_id, person_kind, dossier, language_code, nationality)
        VALUES (@Person5, @TenantId, N'NATURAL', N'DEMO-P-005', 'nl', N'Belgian');
    IF NOT EXISTS (SELECT 1 FROM person.NaturalPerson WHERE person_id = @Person5)
        INSERT INTO person.NaturalPerson (person_id, first_name, last_name, birth_date, title_code)
        VALUES (@Person5, N'Sofie', N'Vermeulen', '1987-06-19', N'MRS');

    IF NOT EXISTS (SELECT 1 FROM person.Person WHERE person_id = @Legal1)
        INSERT INTO person.Person (person_id, tenant_id, person_kind, dossier, language_code, nationality)
        VALUES (@Legal1, @TenantId, N'LEGAL', N'DEMO-L-001', 'nl', N'Belgian');
    IF NOT EXISTS (SELECT 1 FROM person.LegalPerson WHERE person_id = @Legal1)
        INSERT INTO person.LegalPerson (person_id, incorporation_date, legal_form)
        VALUES (@Legal1, '2014-02-01', N'BV');

    IF NOT EXISTS (SELECT 1 FROM person.Person WHERE person_id = @Legal2)
        INSERT INTO person.Person (person_id, tenant_id, person_kind, dossier, language_code, nationality)
        VALUES (@Legal2, @TenantId, N'LEGAL', N'DEMO-L-002', 'fr', N'Belgian');
    IF NOT EXISTS (SELECT 1 FROM person.LegalPerson WHERE person_id = @Legal2)
        INSERT INTO person.LegalPerson (person_id, incorporation_date, legal_form)
        VALUES (@Legal2, '2019-09-15', N'SRL');

    IF NOT EXISTS (SELECT 1 FROM core.AppUser WHERE user_id = @UserAdmin)
        INSERT INTO core.AppUser (user_id, tenant_id, email, display_name, person_id)
        VALUES (@UserAdmin, @TenantId, N'admin@yafes-demo.be', N'Demo Admin', @Person1);
    IF NOT EXISTS (SELECT 1 FROM core.AppUser WHERE user_id = @UserBroker)
        INSERT INTO core.AppUser (user_id, tenant_id, email, display_name, person_id)
        VALUES (@UserBroker, @TenantId, N'broker@yafes-demo.be', N'Demo Broker', @Person3);
    IF NOT EXISTS (SELECT 1 FROM core.AppUser WHERE user_id = @UserClaim)
        INSERT INTO core.AppUser (user_id, tenant_id, email, display_name, person_id)
        VALUES (@UserClaim, @TenantId, N'claims@yafes-demo.be', N'Demo Claim Handler', @Person5);

    INSERT INTO core.UserRole (user_id, role_id)
    SELECT @UserAdmin, r.role_id
    FROM core.Role r
    WHERE r.tenant_id IS NULL
      AND r.role_code = N'BROKER_ADMIN'
      AND NOT EXISTS (
        SELECT 1
        FROM core.UserRole ur
        WHERE ur.user_id = @UserAdmin
          AND ur.role_id = r.role_id
      );

    INSERT INTO core.UserRole (user_id, role_id)
    SELECT @UserBroker, r.role_id
    FROM core.Role r
    WHERE r.tenant_id IS NULL
      AND r.role_code = N'BROKER_USER'
      AND NOT EXISTS (
        SELECT 1
        FROM core.UserRole ur
        WHERE ur.user_id = @UserBroker
          AND ur.role_id = r.role_id
      );

    INSERT INTO core.UserRole (user_id, role_id)
    SELECT @UserClaim, r.role_id
    FROM core.Role r
    WHERE r.tenant_id IS NULL
      AND r.role_code = N'CLAIM_HANDLER'
      AND NOT EXISTS (
        SELECT 1
        FROM core.UserRole ur
        WHERE ur.user_id = @UserClaim
          AND ur.role_id = r.role_id
      );

    IF NOT EXISTS (SELECT 1 FROM institution.Institution WHERE institution_id = @Inst1)
        INSERT INTO institution.Institution (institution_id, tenant_id, institution_code, name, legal_name, vat_number, created_by_user_id)
        VALUES (@Inst1, @TenantId, N'AG-BE', N'AG Insurance', N'AG Insurance NV', N'BE0404494849', @UserAdmin);
    IF NOT EXISTS (SELECT 1 FROM institution.Institution WHERE institution_id = @Inst2)
        INSERT INTO institution.Institution (institution_id, tenant_id, institution_code, name, legal_name, vat_number, created_by_user_id)
        VALUES (@Inst2, @TenantId, N'KBC-BE', N'KBC Bank', N'KBC Bank NV', N'BE0462920226', @UserAdmin);
    IF NOT EXISTS (SELECT 1 FROM institution.Institution WHERE institution_id = @Inst3)
        INSERT INTO institution.Institution (institution_id, tenant_id, institution_code, name, legal_name, vat_number, created_by_user_id)
        VALUES (@Inst3, @TenantId, N'ETHIAS-BE', N'Ethias', N'Ethias NV', N'BE0404485063', @UserAdmin);

    IF NOT EXISTS (SELECT 1 FROM risk.InsurableObject WHERE insurable_object_id = @Vehicle1)
        INSERT INTO risk.InsurableObject (insurable_object_id, tenant_id, object_type_code, description, status_code, start_date, created_by_user_id)
        VALUES (@Vehicle1, @TenantId, N'VEHICLE', N'Volkswagen Golf', N'ACTIVE', '2025-01-01', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM risk.InsurableVehicle WHERE insurable_object_id = @Vehicle1)
        INSERT INTO risk.InsurableVehicle (insurable_object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code)
        VALUES (@Vehicle1, N'CAR', N'PRIVATE', N'NORMAL', N'Volkswagen', N'Golf', N'WVWZZZ1KZ9W000001', 2022, '2022-02-01', '2022-02-12', N'1ABC123', N'PETROL', N'FWD');

    IF NOT EXISTS (SELECT 1 FROM risk.InsurableObject WHERE insurable_object_id = @Vehicle2)
        INSERT INTO risk.InsurableObject (insurable_object_id, tenant_id, object_type_code, description, status_code, start_date, created_by_user_id)
        VALUES (@Vehicle2, @TenantId, N'VEHICLE', N'Tesla Model 3', N'ACTIVE', '2025-01-01', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM risk.InsurableVehicle WHERE insurable_object_id = @Vehicle2)
        INSERT INTO risk.InsurableVehicle (insurable_object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code)
        VALUES (@Vehicle2, N'CAR', N'PRIVATE', N'NORMAL', N'Tesla', N'Model 3', N'5YJ3E7EBXJF000002', 2023, '2023-03-10', '2023-03-20', N'2XYZ456', N'ELECTRIC', N'AWD');

    IF NOT EXISTS (SELECT 1 FROM risk.InsurableObject WHERE insurable_object_id = @Vehicle3)
        INSERT INTO risk.InsurableObject (insurable_object_id, tenant_id, object_type_code, description, status_code, start_date, created_by_user_id)
        VALUES (@Vehicle3, @TenantId, N'VEHICLE', N'Ford Transit', N'ACTIVE', '2025-01-01', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM risk.InsurableVehicle WHERE insurable_object_id = @Vehicle3)
        INSERT INTO risk.InsurableVehicle (insurable_object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code)
        VALUES (@Vehicle3, N'VAN', N'PROFESSIONAL', N'NORMAL', N'Ford', N'Transit', N'WF0XXXTTGXK000003', 2021, '2021-05-12', '2021-05-20', N'3BUS789', N'DIESEL', N'RWD');

    IF NOT EXISTS (SELECT 1 FROM risk.InsurableObject WHERE insurable_object_id = @Estate1)
        INSERT INTO risk.InsurableObject (insurable_object_id, tenant_id, object_type_code, description, status_code, start_date, created_by_user_id)
        VALUES (@Estate1, @TenantId, N'REAL_ESTATE', N'Family home Antwerp', N'ACTIVE', '2025-01-01', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM risk.InsurableRealEstate WHERE insurable_object_id = @Estate1)
        INSERT INTO risk.InsurableRealEstate (insurable_object_id, realestate_type_code, use_type_code, insured_role_code, street, number, postal_code, city, build_year, capital_building)
        VALUES (@Estate1, N'HOUSE', N'PRIVATE', N'OWNER', N'Mechelsesteenweg', N'120', N'2018', N'Antwerpen', 1998, 350000.00);

    IF NOT EXISTS (SELECT 1 FROM risk.InsurableObject WHERE insurable_object_id = @Estate2)
        INSERT INTO risk.InsurableObject (insurable_object_id, tenant_id, object_type_code, description, status_code, start_date, created_by_user_id)
        VALUES (@Estate2, @TenantId, N'REAL_ESTATE', N'Apartment Brussels', N'ACTIVE', '2025-01-01', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM risk.InsurableRealEstate WHERE insurable_object_id = @Estate2)
        INSERT INTO risk.InsurableRealEstate (insurable_object_id, realestate_type_code, use_type_code, insured_role_code, street, number, postal_code, city, build_year, capital_building)
        VALUES (@Estate2, N'APARTMENT', N'PRIVATE', N'OWNER', N'Avenue Louise', N'250', N'1050', N'Brussels', 2008, 280000.00);

    IF NOT EXISTS (SELECT 1 FROM policy.Contract WHERE contract_id = @Contract1)
        INSERT INTO policy.Contract (contract_id, tenant_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, start_date, created_by_user_id)
        VALUES (@Contract1, @TenantId, N'POL-2026-0001', N'MOTOR', N'AUTO_BA', N'ACTIVE', @Inst1, '2026-01-01', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM policy.Contract WHERE contract_id = @Contract2)
        INSERT INTO policy.Contract (contract_id, tenant_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, start_date, created_by_user_id)
        VALUES (@Contract2, @TenantId, N'POL-2026-0002', N'MOTOR', N'AUTO_BA', N'ACTIVE', @Inst3, '2026-02-01', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM policy.Contract WHERE contract_id = @Contract3)
        INSERT INTO policy.Contract (contract_id, tenant_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, start_date, created_by_user_id)
        VALUES (@Contract3, @TenantId, N'POL-2026-0003', N'FIRE', N'FIRE_HOME', N'ACTIVE', @Inst1, '2026-03-01', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM policy.Contract WHERE contract_id = @Contract4)
        INSERT INTO policy.Contract (contract_id, tenant_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, start_date, created_by_user_id)
        VALUES (@Contract4, @TenantId, N'POL-2026-0004', N'FAMILY', N'FAMILY_RC', N'QUOTE', @Inst3, '2026-04-01', @UserBroker);

    IF NOT EXISTS (SELECT 1 FROM policy.ContractVersion WHERE contract_version_id = @Version1)
        INSERT INTO policy.ContractVersion (contract_version_id, contract_id, version_no, effective_from, contract_version_status_code, duration_type_code, periodicity_code, collection_method_code, created_by_user_id)
        VALUES (@Version1, @Contract1, 1, '2026-01-01', N'ACTIVE', N'INDEFINITE', N'YEARLY', N'DIRECT_DEBIT', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM policy.ContractVersion WHERE contract_version_id = @Version2)
        INSERT INTO policy.ContractVersion (contract_version_id, contract_id, version_no, effective_from, contract_version_status_code, duration_type_code, periodicity_code, collection_method_code, created_by_user_id)
        VALUES (@Version2, @Contract3, 1, '2026-03-01', N'ACTIVE', N'INDEFINITE', N'YEARLY', N'BANK_TRANSFER', @UserBroker);

    IF NOT EXISTS (SELECT 1 FROM policy.ContractParty WHERE contract_id = @Contract1 AND person_id = @Person1 AND contract_party_role_code = N'POLICYHOLDER')
        INSERT INTO policy.ContractParty (contract_id, person_id, contract_party_role_code, is_primary)
        VALUES (@Contract1, @Person1, N'POLICYHOLDER', 1);
    IF NOT EXISTS (SELECT 1 FROM policy.ContractObject WHERE contract_id = @Contract1 AND insurable_object_id = @Vehicle1)
        INSERT INTO policy.ContractObject (contract_id, insurable_object_id, contract_object_status_code, is_primary)
        VALUES (@Contract1, @Vehicle1, N'ACTIVE', 1);
    IF NOT EXISTS (SELECT 1 FROM policy.ContractParty WHERE contract_id = @Contract3 AND person_id = @Person2 AND contract_party_role_code = N'POLICYHOLDER')
        INSERT INTO policy.ContractParty (contract_id, person_id, contract_party_role_code, is_primary)
        VALUES (@Contract3, @Person2, N'POLICYHOLDER', 1);
    IF NOT EXISTS (SELECT 1 FROM policy.ContractObject WHERE contract_id = @Contract3 AND insurable_object_id = @Estate1)
        INSERT INTO policy.ContractObject (contract_id, insurable_object_id, contract_object_status_code, is_primary)
        VALUES (@Contract3, @Estate1, N'ACTIVE', 1);

    IF NOT EXISTS (SELECT 1 FROM claim.Claim WHERE claim_id = @Claim1)
        INSERT INTO claim.Claim (claim_id, tenant_id, claim_number, contract_id, coverage_code, claim_status_code, claims_handler_id, incident_date, reported_date, description, reserved_amount, created_by_user_id)
        VALUES (@Claim1, @TenantId, N'CLM-2026-0001', @Contract1, N'AUTO_LIABILITY', N'OPEN', @Person5, '2026-05-10', '2026-05-11', N'Minor parking accident.', 1500.00, @UserClaim);
    IF NOT EXISTS (SELECT 1 FROM claim.Claim WHERE claim_id = @Claim2)
        INSERT INTO claim.Claim (claim_id, tenant_id, claim_number, contract_id, coverage_code, claim_status_code, claims_handler_id, incident_date, reported_date, closed_date, description, paid_amount, reserved_amount, payment_method_code, created_by_user_id)
        VALUES (@Claim2, @TenantId, N'CLM-2026-0002', @Contract3, N'FIRE_BUILDING', N'CLOSED', @Person5, '2026-04-01', '2026-04-02', '2026-04-20', N'Water damage in kitchen.', 2400.00, 0.00, N'BANK_TRANSFER', @UserClaim);

    IF NOT EXISTS (SELECT 1 FROM tasking.Task WHERE task_id = '10000000-0000-0000-0000-000000006001')
        INSERT INTO tasking.Task (task_id, tenant_id, title, related_entity_type, related_entity_id, assigned_to_user_id, created_by_user_id, task_priority_code, task_status_code, due_at_utc)
        VALUES ('10000000-0000-0000-0000-000000006001', @TenantId, N'Renew policy POL-2026-0001', N'POLICY', @Contract1, @UserBroker, @UserAdmin, N'HIGH', N'OPEN', '2026-12-01T09:00:00');
    IF NOT EXISTS (SELECT 1 FROM tasking.Task WHERE task_id = '10000000-0000-0000-0000-000000006002')
        INSERT INTO tasking.Task (task_id, tenant_id, title, related_entity_type, related_entity_id, assigned_to_user_id, created_by_user_id, task_priority_code, task_status_code, due_at_utc)
        VALUES ('10000000-0000-0000-0000-000000006002', @TenantId, N'Follow up claim CLM-2026-0001', N'CLAIM', @Claim1, @UserClaim, @UserAdmin, N'NORMAL', N'IN_PROGRESS', '2026-06-15T10:00:00');
    IF NOT EXISTS (SELECT 1 FROM tasking.Task WHERE task_id = '10000000-0000-0000-0000-000000006003')
        INSERT INTO tasking.Task (task_id, tenant_id, title, related_entity_type, related_entity_id, assigned_to_user_id, created_by_user_id, task_priority_code, task_status_code, due_at_utc)
        VALUES ('10000000-0000-0000-0000-000000006003', @TenantId, N'Collect signed mandate', N'PERSON', @Person2, @UserBroker, @UserAdmin, N'NORMAL', N'OPEN', '2026-06-20T12:00:00');
    IF NOT EXISTS (SELECT 1 FROM tasking.Task WHERE task_id = '10000000-0000-0000-0000-000000006004')
        INSERT INTO tasking.Task (task_id, tenant_id, title, related_entity_type, related_entity_id, assigned_to_user_id, created_by_user_id, task_priority_code, task_status_code, due_at_utc)
        VALUES ('10000000-0000-0000-0000-000000006004', @TenantId, N'Verify vehicle plate', N'RISK_OBJECT', @Vehicle3, @UserBroker, @UserAdmin, N'LOW', N'OPEN', '2026-06-25T09:00:00');
    IF NOT EXISTS (SELECT 1 FROM tasking.Task WHERE task_id = '10000000-0000-0000-0000-000000006005')
        INSERT INTO tasking.Task (task_id, tenant_id, title, related_entity_type, related_entity_id, assigned_to_user_id, created_by_user_id, task_priority_code, task_status_code, due_at_utc)
        VALUES ('10000000-0000-0000-0000-000000006005', @TenantId, N'Review quote POL-2026-0004', N'POLICY', @Contract4, @UserBroker, @UserAdmin, N'NORMAL', N'WAITING', '2026-07-01T14:00:00');

    IF NOT EXISTS (SELECT 1 FROM document.Document WHERE document_id = '10000000-0000-0000-0000-000000007001')
        INSERT INTO document.Document (document_id, tenant_id, owner_entity_type, owner_entity_id, document_type_code, file_name, file_extension, mime_type, file_size_bytes, storage_provider, storage_key, uploaded_by_user_id)
        VALUES ('10000000-0000-0000-0000-000000007001', @TenantId, N'PERSON', @Person1, N'ID_CARD', N'jan-peeters-id.pdf', N'.pdf', N'application/pdf', 125000, N'demo', N'demo/person/jan-peeters-id.pdf', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM document.Document WHERE document_id = '10000000-0000-0000-0000-000000007002')
        INSERT INTO document.Document (document_id, tenant_id, owner_entity_type, owner_entity_id, document_type_code, file_name, file_extension, mime_type, file_size_bytes, storage_provider, storage_key, uploaded_by_user_id)
        VALUES ('10000000-0000-0000-0000-000000007002', @TenantId, N'POLICY', @Contract1, N'POLICY_DOCUMENT', N'POL-2026-0001.pdf', N'.pdf', N'application/pdf', 245000, N'demo', N'demo/policy/POL-2026-0001.pdf', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM document.Document WHERE document_id = '10000000-0000-0000-0000-000000007003')
        INSERT INTO document.Document (document_id, tenant_id, owner_entity_type, owner_entity_id, document_type_code, file_name, file_extension, mime_type, file_size_bytes, storage_provider, storage_key, uploaded_by_user_id)
        VALUES ('10000000-0000-0000-0000-000000007003', @TenantId, N'CLAIM', @Claim1, N'CLAIM_REPORT', N'CLM-2026-0001-report.pdf', N'.pdf', N'application/pdf', 180000, N'demo', N'demo/claim/CLM-2026-0001-report.pdf', @UserClaim);
    IF NOT EXISTS (SELECT 1 FROM document.Document WHERE document_id = '10000000-0000-0000-0000-000000007004')
        INSERT INTO document.Document (document_id, tenant_id, owner_entity_type, owner_entity_id, document_type_code, file_name, file_extension, mime_type, file_size_bytes, storage_provider, storage_key, uploaded_by_user_id)
        VALUES ('10000000-0000-0000-0000-000000007004', @TenantId, N'RISK_OBJECT', @Vehicle1, N'GREEN_CARD', N'green-card-1ABC123.pdf', N'.pdf', N'application/pdf', 97000, N'demo', N'demo/risk/green-card-1ABC123.pdf', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM document.Document WHERE document_id = '10000000-0000-0000-0000-000000007005')
        INSERT INTO document.Document (document_id, tenant_id, owner_entity_type, owner_entity_id, document_type_code, file_name, file_extension, mime_type, file_size_bytes, storage_provider, storage_key, uploaded_by_user_id)
        VALUES ('10000000-0000-0000-0000-000000007005', @TenantId, N'INSTITUTION', @Inst1, N'SIGNED_CONTRACT', N'ag-broker-agreement.pdf', N'.pdf', N'application/pdf', 310000, N'demo', N'demo/institution/ag-broker-agreement.pdf', @UserAdmin);

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'018__seed_demo_data.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'018__seed_demo_data.sql',
            N'SUCCESS'
        );
    END;

    COMMIT TRANSACTION;
    PRINT 'Optional demo data migration completed successfully.';
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


PRINT '=== VALIDATION 001__validate_core_infrastructure.sql ===';
GO
SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

IF SCHEMA_ID(N'core') IS NULL
    THROW 50101, 'Missing schema: core', 1;

IF SCHEMA_ID(N'ref') IS NULL
    THROW 50102, 'Missing schema: ref', 1;

IF SCHEMA_ID(N'person') IS NULL
    THROW 50103, 'Missing schema: person', 1;

IF SCHEMA_ID(N'institution') IS NULL
    THROW 50104, 'Missing schema: institution', 1;

IF SCHEMA_ID(N'risk') IS NULL
    THROW 50105, 'Missing schema: risk', 1;

IF SCHEMA_ID(N'policy') IS NULL
    THROW 50106, 'Missing schema: policy', 1;

IF SCHEMA_ID(N'coverage') IS NULL
    THROW 50107, 'Missing schema: coverage', 1;

IF SCHEMA_ID(N'claim') IS NULL
    THROW 50108, 'Missing schema: claim', 1;

IF SCHEMA_ID(N'document') IS NULL
    THROW 50109, 'Missing schema: document', 1;

IF SCHEMA_ID(N'tasking') IS NULL
    THROW 50110, 'Missing schema: tasking', 1;

IF SCHEMA_ID(N'audit') IS NULL
    THROW 50111, 'Missing schema: audit', 1;

IF OBJECT_ID(N'core.SchemaMigration', N'U') IS NULL
    THROW 50112, 'Missing table: core.SchemaMigration', 1;

IF OBJECT_ID(N'core.Tenant', N'U') IS NULL
    THROW 50113, 'Missing table: core.Tenant', 1;

IF OBJECT_ID(N'core.AppUser', N'U') IS NULL
    THROW 50114, 'Missing table: core.AppUser', 1;

IF OBJECT_ID(N'core.Role', N'U') IS NULL
    THROW 50115, 'Missing table: core.Role', 1;

IF OBJECT_ID(N'core.Permission', N'U') IS NULL
    THROW 50116, 'Missing table: core.Permission', 1;

IF OBJECT_ID(N'core.RolePermission', N'U') IS NULL
    THROW 50117, 'Missing table: core.RolePermission', 1;

IF OBJECT_ID(N'core.UserRole', N'U') IS NULL
    THROW 50118, 'Missing table: core.UserRole', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE name = N'PK_SchemaMigration'
      AND parent_object_id = OBJECT_ID(N'core.SchemaMigration')
)
    THROW 50119, 'Missing primary key: PK_SchemaMigration', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = N'CK_SchemaMigration_execution_status'
      AND parent_object_id = OBJECT_ID(N'core.SchemaMigration')
)
    THROW 50120, 'Missing check constraint: CK_SchemaMigration_execution_status', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_AppUser_Tenant'
      AND parent_object_id = OBJECT_ID(N'core.AppUser')
)
    THROW 50121, 'Missing FK: FK_AppUser_Tenant', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_Role_Tenant'
      AND parent_object_id = OBJECT_ID(N'core.Role')
)
    THROW 50122, 'Missing FK: FK_Role_Tenant', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_RolePermission_Role'
      AND parent_object_id = OBJECT_ID(N'core.RolePermission')
)
    THROW 50123, 'Missing FK: FK_RolePermission_Role', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_RolePermission_Permission'
      AND parent_object_id = OBJECT_ID(N'core.RolePermission')
)
    THROW 50124, 'Missing FK: FK_RolePermission_Permission', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_UserRole_AppUser'
      AND parent_object_id = OBJECT_ID(N'core.UserRole')
)
    THROW 50125, 'Missing FK: FK_UserRole_AppUser', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_UserRole_Role'
      AND parent_object_id = OBJECT_ID(N'core.UserRole')
)
    THROW 50126, 'Missing FK: FK_UserRole_Role', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_AppUser_tenant_id'
      AND object_id = OBJECT_ID(N'core.AppUser')
)
    THROW 50127, 'Missing index: IX_AppUser_tenant_id', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_RolePermission_permission_code'
      AND object_id = OBJECT_ID(N'core.RolePermission')
)
    THROW 50128, 'Missing index: IX_RolePermission_permission_code', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_AppUser_person_id'
      AND object_id = OBJECT_ID(N'core.AppUser')
)
    THROW 50129, 'Missing index: IX_AppUser_person_id', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Role_tenant_id'
      AND object_id = OBJECT_ID(N'core.Role')
)
    THROW 50130, 'Missing index: IX_Role_tenant_id', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_UserRole_role_id'
      AND object_id = OBJECT_ID(N'core.UserRole')
)
    THROW 50131, 'Missing index: IX_UserRole_role_id', 1;

PRINT 'Core infrastructure validation passed.';
GO


PRINT '=== VALIDATION 002__validate_person_domain.sql ===';
GO
SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

IF OBJECT_ID(N'person.Person', N'U') IS NULL
    THROW 50201, 'Missing table: person.Person', 1;

IF OBJECT_ID(N'person.NaturalPerson', N'U') IS NULL
    THROW 50202, 'Missing table: person.NaturalPerson', 1;

IF OBJECT_ID(N'person.LegalPerson', N'U') IS NULL
    THROW 50203, 'Missing table: person.LegalPerson', 1;

IF OBJECT_ID(N'person.Address', N'U') IS NULL
    THROW 50204, 'Missing table: person.Address', 1;

IF OBJECT_ID(N'person.Phone', N'U') IS NULL
    THROW 50205, 'Missing table: person.Phone', 1;

IF OBJECT_ID(N'person.Email', N'U') IS NULL
    THROW 50206, 'Missing table: person.Email', 1;

IF OBJECT_ID(N'person.PersonRelation', N'U') IS NULL
    THROW 50207, 'Missing table: person.PersonRelation', 1;

IF OBJECT_ID(N'ref.Language', N'U') IS NULL
    THROW 50208, 'Missing table: ref.Language', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_Person_Tenant'
      AND parent_object_id = OBJECT_ID(N'person.Person')
)
    THROW 50209, 'Missing FK: FK_Person_Tenant', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_NaturalPerson_Person'
      AND parent_object_id = OBJECT_ID(N'person.NaturalPerson')
)
    THROW 50210, 'Missing FK: FK_NaturalPerson_Person', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_LegalPerson_Person'
      AND parent_object_id = OBJECT_ID(N'person.LegalPerson')
)
    THROW 50211, 'Missing FK: FK_LegalPerson_Person', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_Email_Person'
      AND parent_object_id = OBJECT_ID(N'person.Email')
)
    THROW 50212, 'Missing FK: FK_Email_Person', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_AppUser_Person'
      AND parent_object_id = OBJECT_ID(N'core.AppUser')
)
    THROW 50213, 'Missing FK: FK_AppUser_Person', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'UQ_Person_tenant_dossier'
      AND object_id = OBJECT_ID(N'person.Person')
)
    THROW 50214, 'Missing index: UQ_Person_tenant_dossier', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_NaturalPerson_name'
      AND object_id = OBJECT_ID(N'person.NaturalPerson')
)
    THROW 50215, 'Missing index: IX_NaturalPerson_name', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Email_email'
      AND object_id = OBJECT_ID(N'person.Email')
)
    THROW 50216, 'Missing index: IX_Email_email', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Phone_number'
      AND object_id = OBJECT_ID(N'person.Phone')
)
    THROW 50217, 'Missing index: IX_Phone_number', 1;

IF COL_LENGTH(N'person.Person', N'tenant_id') IS NULL
    THROW 50218, 'Missing column: person.Person.tenant_id', 1;

IF COL_LENGTH(N'person.Person', N'is_deleted') IS NULL
    THROW 50219, 'Missing column: person.Person.is_deleted', 1;

PRINT 'Person domain validation passed.';
GO


PRINT '=== VALIDATION 003__validate_institution_domain.sql ===';
GO
SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

IF OBJECT_ID(N'institution.Institution', N'U') IS NULL
    THROW 50301, 'Missing table: institution.Institution', 1;

IF OBJECT_ID(N'institution.InstitutionRole', N'U') IS NULL
    THROW 50302, 'Missing table: institution.InstitutionRole', 1;

IF OBJECT_ID(N'institution.InstitutionIdentifier', N'U') IS NULL
    THROW 50303, 'Missing table: institution.InstitutionIdentifier', 1;

IF OBJECT_ID(N'institution.InstitutionIdentifierType', N'U') IS NULL
    THROW 50304, 'Missing table: institution.InstitutionIdentifierType', 1;

IF OBJECT_ID(N'institution.InstitutionAddress', N'U') IS NULL
    THROW 50305, 'Missing table: institution.InstitutionAddress', 1;

IF OBJECT_ID(N'institution.InstitutionAddressRole', N'U') IS NULL
    THROW 50306, 'Missing table: institution.InstitutionAddressRole', 1;

IF COL_LENGTH(N'institution.Institution', N'tenant_id') IS NULL
    THROW 50307, 'Missing column: institution.Institution.tenant_id', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_Institution_Tenant'
      AND parent_object_id = OBJECT_ID(N'institution.Institution')
)
    THROW 50308, 'Missing FK: FK_Institution_Tenant', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_InstitutionIdentifier_Institution'
      AND parent_object_id = OBJECT_ID(N'institution.InstitutionIdentifier')
)
    THROW 50309, 'Missing FK: FK_InstitutionIdentifier_Institution', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_InstitutionAddress_Institution'
      AND parent_object_id = OBJECT_ID(N'institution.InstitutionAddress')
)
    THROW 50310, 'Missing FK: FK_InstitutionAddress_Institution', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE name = N'UQ_Institution_tenant_code'
      AND parent_object_id = OBJECT_ID(N'institution.Institution')
)
    THROW 50311, 'Missing unique constraint: UQ_Institution_tenant_code', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Institution_name'
      AND object_id = OBJECT_ID(N'institution.Institution')
)
    THROW 50312, 'Missing index: IX_Institution_name', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_InstitutionIdentifier_value'
      AND object_id = OBJECT_ID(N'institution.InstitutionIdentifier')
)
    THROW 50313, 'Missing index: IX_InstitutionIdentifier_value', 1;

PRINT 'Institution domain validation passed.';
GO


PRINT '=== VALIDATION 004__validate_risk_domain.sql ===';
GO
SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

IF OBJECT_ID(N'risk.InsurableObject', N'U') IS NULL
    THROW 50401, 'Missing table: risk.InsurableObject', 1;

IF OBJECT_ID(N'risk.InsurableVehicle', N'U') IS NULL
    THROW 50402, 'Missing table: risk.InsurableVehicle', 1;

IF OBJECT_ID(N'risk.InsurableRealEstate', N'U') IS NULL
    THROW 50403, 'Missing table: risk.InsurableRealEstate', 1;

IF OBJECT_ID(N'risk.InsurableLoan', N'U') IS NULL
    THROW 50404, 'Missing table: risk.InsurableLoan', 1;

IF OBJECT_ID(N'risk.InsurablePerson', N'U') IS NULL
    THROW 50405, 'Missing table: risk.InsurablePerson', 1;

IF OBJECT_ID(N'risk.InsurableThing', N'U') IS NULL
    THROW 50406, 'Missing table: risk.InsurableThing', 1;

IF OBJECT_ID(N'risk.InsurableActivity', N'U') IS NULL
    THROW 50407, 'Missing table: risk.InsurableActivity', 1;

IF OBJECT_ID(N'risk.InsurableObjectType', N'U') IS NULL
    THROW 50408, 'Missing table: risk.InsurableObjectType', 1;

IF OBJECT_ID(N'risk.Object', N'U') IS NOT NULL
    THROW 50409, 'Forbidden table exists: risk.Object', 1;

IF OBJECT_ID(N'dbo.Object', N'U') IS NOT NULL
    THROW 50410, 'Forbidden table exists: dbo.Object', 1;

IF COL_LENGTH(N'risk.InsurableObject', N'tenant_id') IS NULL
    THROW 50411, 'Missing column: risk.InsurableObject.tenant_id', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_InsurableObject_Tenant'
      AND parent_object_id = OBJECT_ID(N'risk.InsurableObject')
)
    THROW 50412, 'Missing FK: FK_InsurableObject_Tenant', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_InsurableVehicle_InsurableObject'
      AND parent_object_id = OBJECT_ID(N'risk.InsurableVehicle')
)
    THROW 50413, 'Missing FK: FK_InsurableVehicle_InsurableObject', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_InsurableRealEstate_InsurableObject'
      AND parent_object_id = OBJECT_ID(N'risk.InsurableRealEstate')
)
    THROW 50414, 'Missing FK: FK_InsurableRealEstate_InsurableObject', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_InsurableVehicle_plate'
      AND object_id = OBJECT_ID(N'risk.InsurableVehicle')
)
    THROW 50415, 'Missing index: IX_InsurableVehicle_plate', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_InsurableVehicle_chassis'
      AND object_id = OBJECT_ID(N'risk.InsurableVehicle')
)
    THROW 50416, 'Missing index: IX_InsurableVehicle_chassis', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_InsurableRealEstate_address'
      AND object_id = OBJECT_ID(N'risk.InsurableRealEstate')
)
    THROW 50417, 'Missing index: IX_InsurableRealEstate_address', 1;

PRINT 'Risk domain validation passed.';
GO


PRINT '=== VALIDATION 005__validate_policy_domain.sql ===';
GO
SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

IF OBJECT_ID(N'policy.Contract', N'U') IS NULL
    THROW 50501, 'Missing table: policy.Contract', 1;

IF OBJECT_ID(N'policy.ContractVersion', N'U') IS NULL
    THROW 50502, 'Missing table: policy.ContractVersion', 1;

IF OBJECT_ID(N'policy.ContractParty', N'U') IS NULL
    THROW 50503, 'Missing table: policy.ContractParty', 1;

IF OBJECT_ID(N'policy.ContractObject', N'U') IS NULL
    THROW 50504, 'Missing table: policy.ContractObject', 1;

IF OBJECT_ID(N'policy.ContractVersionObject', N'U') IS NULL
    THROW 50505, 'Missing table: policy.ContractVersionObject', 1;

IF OBJECT_ID(N'policy.ContractTakeover', N'U') IS NULL
    THROW 50506, 'Missing table: policy.ContractTakeover', 1;

IF COL_LENGTH(N'policy.Contract', N'tenant_id') IS NULL
    THROW 50507, 'Missing column: policy.Contract.tenant_id', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE name = N'UQ_Contract_tenant_number'
      AND parent_object_id = OBJECT_ID(N'policy.Contract')
)
    THROW 50508, 'Missing unique constraint: UQ_Contract_tenant_number', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE name = N'UQ_ContractVersion_contract_version_no'
      AND parent_object_id = OBJECT_ID(N'policy.ContractVersion')
)
    THROW 50509, 'Missing unique constraint: UQ_ContractVersion_contract_version_no', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_Contract_Tenant'
      AND parent_object_id = OBJECT_ID(N'policy.Contract')
)
    THROW 50510, 'Missing FK: FK_Contract_Tenant', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_ContractVersion_Contract'
      AND parent_object_id = OBJECT_ID(N'policy.ContractVersion')
)
    THROW 50511, 'Missing FK: FK_ContractVersion_Contract', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_ContractParty_Person'
      AND parent_object_id = OBJECT_ID(N'policy.ContractParty')
)
    THROW 50512, 'Missing FK: FK_ContractParty_Person', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_ContractObject_InsurableObject'
      AND parent_object_id = OBJECT_ID(N'policy.ContractObject')
)
    THROW 50513, 'Missing FK: FK_ContractObject_InsurableObject', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE name = N'UQ_ContractType_code_domain'
      AND parent_object_id = OBJECT_ID(N'policy.ContractType')
)
    THROW 50514, 'Missing unique constraint: UQ_ContractType_code_domain', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Contract_status_dates'
      AND object_id = OBJECT_ID(N'policy.Contract')
)
    THROW 50515, 'Missing index: IX_Contract_status_dates', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_ContractVersion_contract_effective'
      AND object_id = OBJECT_ID(N'policy.ContractVersion')
)
    THROW 50516, 'Missing index: IX_ContractVersion_contract_effective', 1;

PRINT 'Policy domain validation passed.';
GO


PRINT '=== VALIDATION 006__validate_coverage_domain.sql ===';
GO
SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

IF OBJECT_ID(N'coverage.Coverage', N'U') IS NULL
    THROW 50601, 'Missing table: coverage.Coverage', 1;

IF OBJECT_ID(N'coverage.CoverageDomain', N'U') IS NULL
    THROW 50602, 'Missing table: coverage.CoverageDomain', 1;

IF OBJECT_ID(N'coverage.CoveragePackage', N'U') IS NULL
    THROW 50603, 'Missing table: coverage.CoveragePackage', 1;

IF OBJECT_ID(N'coverage.CoveragePackageItem', N'U') IS NULL
    THROW 50604, 'Missing table: coverage.CoveragePackageItem', 1;

IF OBJECT_ID(N'dbo.lookup_coverage', N'U') IS NOT NULL
    THROW 50605, 'Forbidden legacy table exists: dbo.lookup_coverage', 1;

IF OBJECT_ID(N'dbo.coverage_domain', N'U') IS NOT NULL
    THROW 50606, 'Forbidden legacy table exists: dbo.coverage_domain', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_CoverageDomain_Coverage'
      AND parent_object_id = OBJECT_ID(N'coverage.CoverageDomain')
)
    THROW 50607, 'Missing FK: FK_CoverageDomain_Coverage', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_CoverageDomain_ContractDomain'
      AND parent_object_id = OBJECT_ID(N'coverage.CoverageDomain')
)
    THROW 50608, 'Missing FK: FK_CoverageDomain_ContractDomain', 1;

IF NOT EXISTS (
    SELECT 1
    FROM coverage.Coverage
    WHERE coverage_code = N'AUTO_LIABILITY'
)
    THROW 50609, 'Missing seed coverage: AUTO_LIABILITY', 1;

PRINT 'Coverage domain validation passed.';
GO


PRINT '=== VALIDATION 007__validate_claim_domain.sql ===';
GO
SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

IF OBJECT_ID(N'claim.Claim', N'U') IS NULL
    THROW 50701, 'Missing table: claim.Claim', 1;

IF OBJECT_ID(N'claim.ClaimParty', N'U') IS NULL
    THROW 50702, 'Missing table: claim.ClaimParty', 1;

IF OBJECT_ID(N'claim.ClaimObject', N'U') IS NULL
    THROW 50703, 'Missing table: claim.ClaimObject', 1;

IF OBJECT_ID(N'claim.ClaimCircumstance', N'U') IS NULL
    THROW 50704, 'Missing table: claim.ClaimCircumstance', 1;

IF OBJECT_ID(N'claim.ClaimStatus', N'U') IS NULL
    THROW 50705, 'Missing table: claim.ClaimStatus', 1;

IF COL_LENGTH(N'claim.Claim', N'tenant_id') IS NULL
    THROW 50706, 'Missing column: claim.Claim.tenant_id', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE name = N'UQ_Claim_tenant_number'
      AND parent_object_id = OBJECT_ID(N'claim.Claim')
)
    THROW 50707, 'Missing unique constraint: UQ_Claim_tenant_number', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_Claim_Contract'
      AND parent_object_id = OBJECT_ID(N'claim.Claim')
)
    THROW 50708, 'Missing FK: FK_Claim_Contract', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_ClaimObject_InsurableObject'
      AND parent_object_id = OBJECT_ID(N'claim.ClaimObject')
)
    THROW 50709, 'Missing FK: FK_ClaimObject_InsurableObject', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = N'CK_Claim_payment_method'
      AND parent_object_id = OBJECT_ID(N'claim.Claim')
)
    THROW 50710, 'Missing check constraint: CK_Claim_payment_method', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Claim_contract'
      AND object_id = OBJECT_ID(N'claim.Claim')
)
    THROW 50711, 'Missing index: IX_Claim_contract', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Claim_status_reported'
      AND object_id = OBJECT_ID(N'claim.Claim')
)
    THROW 50712, 'Missing index: IX_Claim_status_reported', 1;

PRINT 'Claim domain validation passed.';
GO


PRINT '=== VALIDATION 008__validate_document_domain.sql ===';
GO
SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

IF OBJECT_ID(N'document.Document', N'U') IS NULL
    THROW 50801, 'Missing table: document.Document', 1;

IF OBJECT_ID(N'document.DocumentType', N'U') IS NULL
    THROW 50802, 'Missing table: document.DocumentType', 1;

IF OBJECT_ID(N'document.DocumentLink', N'U') IS NULL
    THROW 50803, 'Missing table: document.DocumentLink', 1;

IF OBJECT_ID(N'document.DocumentVersion', N'U') IS NULL
    THROW 50804, 'Missing table: document.DocumentVersion', 1;

IF COL_LENGTH(N'document.Document', N'tenant_id') IS NULL
    THROW 50805, 'Missing column: document.Document.tenant_id', 1;

IF COL_LENGTH(N'document.Document', N'storage_key') IS NULL
    THROW 50806, 'Missing column: document.Document.storage_key', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = N'CK_Document_owner_entity_type'
      AND parent_object_id = OBJECT_ID(N'document.Document')
)
    THROW 50807, 'Missing check constraint: CK_Document_owner_entity_type', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_Document_Tenant'
      AND parent_object_id = OBJECT_ID(N'document.Document')
)
    THROW 50808, 'Missing FK: FK_Document_Tenant', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Document_tenant_owner'
      AND object_id = OBJECT_ID(N'document.Document')
)
    THROW 50809, 'Missing index: IX_Document_tenant_owner', 1;

PRINT 'Document domain validation passed.';
GO


PRINT '=== VALIDATION 009__validate_task_domain.sql ===';
GO
SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
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

PRINT 'Task domain validation passed.';
GO


PRINT '=== VALIDATION 010__validate_audit_domain.sql ===';
GO
SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

IF OBJECT_ID(N'audit.AuditLog', N'U') IS NULL
    THROW 51001, 'Missing table: audit.AuditLog', 1;

IF OBJECT_ID(N'audit.EntityChangeSet', N'U') IS NULL
    THROW 51002, 'Missing table: audit.EntityChangeSet', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = N'CK_AuditLog_action_type'
      AND parent_object_id = OBJECT_ID(N'audit.AuditLog')
)
    THROW 51003, 'Missing check constraint: CK_AuditLog_action_type', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_AuditLog_entity'
      AND object_id = OBJECT_ID(N'audit.AuditLog')
)
    THROW 51004, 'Missing index: IX_AuditLog_entity', 1;

IF OBJECT_ID(N'person.TR_Person_Audit', N'TR') IS NULL
    THROW 51005, 'Missing trigger: person.TR_Person_Audit', 1;

IF OBJECT_ID(N'institution.TR_Institution_Audit', N'TR') IS NULL
    THROW 51006, 'Missing trigger: institution.TR_Institution_Audit', 1;

IF OBJECT_ID(N'risk.TR_InsurableObject_Audit', N'TR') IS NULL
    THROW 51007, 'Missing trigger: risk.TR_InsurableObject_Audit', 1;

IF OBJECT_ID(N'policy.TR_Contract_Audit', N'TR') IS NULL
    THROW 51008, 'Missing trigger: policy.TR_Contract_Audit', 1;

IF OBJECT_ID(N'policy.TR_ContractVersion_Audit', N'TR') IS NULL
    THROW 51009, 'Missing trigger: policy.TR_ContractVersion_Audit', 1;

IF OBJECT_ID(N'claim.TR_Claim_Audit', N'TR') IS NULL
    THROW 51010, 'Missing trigger: claim.TR_Claim_Audit', 1;

PRINT 'Audit domain validation passed.';
GO


PRINT '=== VALIDATION 011__validate_constraints_exist.sql ===';
GO
SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_InsurableLoan_Periodicity'
      AND parent_object_id = OBJECT_ID(N'risk.InsurableLoan')
)
    THROW 51101, 'Missing FK: FK_InsurableLoan_Periodicity', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_InsurableLoan_DurationType'
      AND parent_object_id = OBJECT_ID(N'risk.InsurableLoan')
)
    THROW 51102, 'Missing FK: FK_InsurableLoan_DurationType', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_InsurableObject_AppUser_CreatedBy'
      AND parent_object_id = OBJECT_ID(N'risk.InsurableObject')
)
    THROW 51103, 'Missing FK: FK_InsurableObject_AppUser_CreatedBy', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_ContractVersion_AppUser_CreatedBy'
      AND parent_object_id = OBJECT_ID(N'policy.ContractVersion')
)
    THROW 51104, 'Missing FK: FK_ContractVersion_AppUser_CreatedBy', 1;

PRINT 'Cross-domain constraint validation passed.';
GO


PRINT '=== VALIDATION 012__validate_indexes.sql ===';
GO
SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

DECLARE @MissingFkIndexes TABLE (
    fk_name SYSNAME NOT NULL,
    schema_name SYSNAME NOT NULL,
    table_name SYSNAME NOT NULL,
    column_name SYSNAME NOT NULL
);

INSERT INTO @MissingFkIndexes (
    fk_name,
    schema_name,
    table_name,
    column_name
)
SELECT
    fk.name,
    s.name,
    t.name,
    c.name
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc
    ON fkc.constraint_object_id = fk.object_id
   AND fkc.constraint_column_id = 1
INNER JOIN sys.tables t
    ON t.object_id = fk.parent_object_id
INNER JOIN sys.schemas s
    ON s.schema_id = t.schema_id
INNER JOIN sys.columns c
    ON c.object_id = t.object_id
   AND c.column_id = fkc.parent_column_id
WHERE NOT EXISTS (
    SELECT 1
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic
        ON ic.object_id = i.object_id
       AND ic.index_id = i.index_id
       AND ic.key_ordinal = 1
    WHERE i.object_id = t.object_id
      AND i.is_hypothetical = 0
      AND ic.column_id = fkc.parent_column_id
);

IF EXISTS (SELECT 1 FROM @MissingFkIndexes)
BEGIN
    SELECT fk_name, schema_name, table_name, column_name
    FROM @MissingFkIndexes
    ORDER BY schema_name, table_name, column_name;

    THROW 51201, 'Missing FK-supporting indexes detected.', 1;
END;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Document_tenant_uploaded'
      AND object_id = OBJECT_ID(N'document.Document')
)
    THROW 51202, 'Missing index: IX_Document_tenant_uploaded', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Task_tenant_assigned_status_due'
      AND object_id = OBJECT_ID(N'tasking.Task')
)
    THROW 51203, 'Missing index: IX_Task_tenant_assigned_status_due', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_AuditLog_correlation'
      AND object_id = OBJECT_ID(N'audit.AuditLog')
)
    THROW 51204, 'Missing index: IX_AuditLog_correlation', 1;

PRINT 'Index validation passed.';
GO


PRINT '=== VALIDATION 013__validate_triggers.sql ===';
GO
SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

IF OBJECT_ID(N'person.TR_Person_Audit', N'TR') IS NULL
    THROW 51301, 'Missing trigger: person.TR_Person_Audit', 1;

IF OBJECT_ID(N'institution.TR_Institution_Audit', N'TR') IS NULL
    THROW 51302, 'Missing trigger: institution.TR_Institution_Audit', 1;

IF OBJECT_ID(N'risk.TR_InsurableObject_Audit', N'TR') IS NULL
    THROW 51303, 'Missing trigger: risk.TR_InsurableObject_Audit', 1;

IF OBJECT_ID(N'policy.TR_Contract_Audit', N'TR') IS NULL
    THROW 51304, 'Missing trigger: policy.TR_Contract_Audit', 1;

IF OBJECT_ID(N'policy.TR_ContractVersion_Audit', N'TR') IS NULL
    THROW 51305, 'Missing trigger: policy.TR_ContractVersion_Audit', 1;

IF OBJECT_ID(N'claim.TR_Claim_Audit', N'TR') IS NULL
    THROW 51306, 'Missing trigger: claim.TR_Claim_Audit', 1;

PRINT 'Trigger validation passed.';
GO


PRINT '=== VALIDATION 014__validate_views.sql ===';
GO
SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

IF OBJECT_ID(N'person.VW_CustomerSummary', N'V') IS NULL
    THROW 51401, 'Missing view: person.VW_CustomerSummary', 1;

IF OBJECT_ID(N'institution.VW_InstitutionSummary', N'V') IS NULL
    THROW 51402, 'Missing view: institution.VW_InstitutionSummary', 1;

IF OBJECT_ID(N'risk.VW_InsurableObjectSummary', N'V') IS NULL
    THROW 51403, 'Missing view: risk.VW_InsurableObjectSummary', 1;

IF OBJECT_ID(N'policy.VW_ActivePolicy', N'V') IS NULL
    THROW 51404, 'Missing view: policy.VW_ActivePolicy', 1;

IF OBJECT_ID(N'policy.VW_PolicyDashboard', N'V') IS NULL
    THROW 51405, 'Missing view: policy.VW_PolicyDashboard', 1;

IF OBJECT_ID(N'claim.VW_ClaimDashboard', N'V') IS NULL
    THROW 51406, 'Missing view: claim.VW_ClaimDashboard', 1;

IF OBJECT_ID(N'tasking.VW_OpenTaskDashboard', N'V') IS NULL
    THROW 51407, 'Missing view: tasking.VW_OpenTaskDashboard', 1;

PRINT 'View validation passed.';
GO


PRINT '=== VALIDATION 015__validate_stored_procedures.sql ===';
GO
SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

IF OBJECT_ID(N'person.SP_CreateNaturalPerson', N'P') IS NULL
    THROW 51501, 'Missing procedure: person.SP_CreateNaturalPerson', 1;

IF OBJECT_ID(N'person.SP_SearchPerson', N'P') IS NULL
    THROW 51502, 'Missing procedure: person.SP_SearchPerson', 1;

IF OBJECT_ID(N'institution.SP_SearchInstitution', N'P') IS NULL
    THROW 51503, 'Missing procedure: institution.SP_SearchInstitution', 1;

IF OBJECT_ID(N'risk.SP_SearchVehicle', N'P') IS NULL
    THROW 51504, 'Missing procedure: risk.SP_SearchVehicle', 1;

IF OBJECT_ID(N'policy.SP_CreateContract', N'P') IS NULL
    THROW 51505, 'Missing procedure: policy.SP_CreateContract', 1;

IF OBJECT_ID(N'policy.SP_CreateContractVersion', N'P') IS NULL
    THROW 51506, 'Missing procedure: policy.SP_CreateContractVersion', 1;

IF OBJECT_ID(N'policy.SP_AddContractParty', N'P') IS NULL
    THROW 51507, 'Missing procedure: policy.SP_AddContractParty', 1;

IF OBJECT_ID(N'policy.SP_AddContractObject', N'P') IS NULL
    THROW 51508, 'Missing procedure: policy.SP_AddContractObject', 1;

IF OBJECT_ID(N'claim.SP_CreateClaim', N'P') IS NULL
    THROW 51509, 'Missing procedure: claim.SP_CreateClaim', 1;

IF OBJECT_ID(N'claim.SP_CloseClaim', N'P') IS NULL
    THROW 51510, 'Missing procedure: claim.SP_CloseClaim', 1;

IF OBJECT_ID(N'audit.SP_GetEntityAuditTrail', N'P') IS NULL
    THROW 51511, 'Missing procedure: audit.SP_GetEntityAuditTrail', 1;

PRINT 'Stored procedure validation passed.';
GO


PRINT '=== VALIDATION 016__validate_seed_data.sql ===';
GO
SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

IF NOT EXISTS (SELECT 1 FROM ref.Language WHERE language_code = 'nl')
    THROW 51601, 'Missing seed: Language nl', 1;

IF NOT EXISTS (SELECT 1 FROM policy.ContractStatus WHERE contract_status_code = N'ACTIVE')
    THROW 51602, 'Missing seed: ContractStatus ACTIVE', 1;

IF NOT EXISTS (SELECT 1 FROM policy.ContractVersionStatus WHERE contract_version_status_code = N'ACTIVE')
    THROW 51603, 'Missing seed: ContractVersionStatus ACTIVE', 1;

IF NOT EXISTS (SELECT 1 FROM claim.ClaimStatus WHERE claim_status_code = N'OPEN')
    THROW 51604, 'Missing seed: ClaimStatus OPEN', 1;

IF NOT EXISTS (SELECT 1 FROM tasking.TaskStatus WHERE task_status_code = N'OPEN')
    THROW 51605, 'Missing seed: TaskStatus OPEN', 1;

IF NOT EXISTS (SELECT 1 FROM tasking.TaskPriority WHERE task_priority_code = N'NORMAL')
    THROW 51606, 'Missing seed: TaskPriority NORMAL', 1;

IF NOT EXISTS (SELECT 1 FROM document.DocumentType WHERE document_type_code = N'ID_CARD')
    THROW 51607, 'Missing seed: DocumentType ID_CARD', 1;

IF NOT EXISTS (SELECT 1 FROM core.Permission WHERE permission_code = N'admin.user.manage')
    THROW 51608, 'Missing seed: Permission admin.user.manage', 1;

IF NOT EXISTS (SELECT 1 FROM core.Role WHERE tenant_id IS NULL AND role_code = N'SYSTEM_ADMIN')
    THROW 51609, 'Missing seed: Role SYSTEM_ADMIN', 1;

IF NOT EXISTS (SELECT 1 FROM risk.InsurableObjectType WHERE object_type_code = N'VEHICLE')
    THROW 51610, 'Missing seed: InsurableObjectType VEHICLE', 1;

PRINT 'Seed validation passed.';
GO


PRINT '=== VALIDATION 017__validate_demo_data.sql ===';
GO
SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

DECLARE @TenantId UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000000001';

IF NOT EXISTS (SELECT 1 FROM core.Tenant WHERE tenant_id = @TenantId)
    THROW 51701, 'Missing demo tenant.', 1;

IF (SELECT COUNT(*) FROM core.AppUser WHERE tenant_id = @TenantId) < 3
    THROW 51702, 'Missing demo users.', 1;

IF (
    SELECT COUNT(*)
    FROM core.UserRole ur
    INNER JOIN core.AppUser au
        ON au.user_id = ur.user_id
    WHERE au.tenant_id = @TenantId
) < 3
    THROW 51712, 'Missing demo user roles.', 1;

IF (
    SELECT COUNT(*)
    FROM person.Person
    WHERE tenant_id = @TenantId
      AND person_kind = N'NATURAL'
) < 5
    THROW 51703, 'Missing demo natural persons.', 1;

IF (
    SELECT COUNT(*)
    FROM person.Person
    WHERE tenant_id = @TenantId
      AND person_kind = N'LEGAL'
) < 2
    THROW 51704, 'Missing demo legal persons.', 1;

IF (SELECT COUNT(*) FROM institution.Institution WHERE tenant_id = @TenantId) < 3
    THROW 51705, 'Missing demo institutions.', 1;

IF (SELECT COUNT(*) FROM risk.InsurableObject WHERE tenant_id = @TenantId AND object_type_code = N'VEHICLE') < 3
    THROW 51706, 'Missing demo vehicles.', 1;

IF (SELECT COUNT(*) FROM risk.InsurableObject WHERE tenant_id = @TenantId AND object_type_code = N'REAL_ESTATE') < 2
    THROW 51707, 'Missing demo real estate risks.', 1;

IF (SELECT COUNT(*) FROM policy.Contract WHERE tenant_id = @TenantId) < 4
    THROW 51708, 'Missing demo contracts.', 1;

IF (SELECT COUNT(*) FROM claim.Claim WHERE tenant_id = @TenantId) < 2
    THROW 51709, 'Missing demo claims.', 1;

IF (SELECT COUNT(*) FROM tasking.Task WHERE tenant_id = @TenantId) < 5
    THROW 51710, 'Missing demo tasks.', 1;

IF (SELECT COUNT(*) FROM document.Document WHERE tenant_id = @TenantId) < 5
    THROW 51711, 'Missing demo documents.', 1;

PRINT 'Demo data validation passed.';
GO


PRINT 'SSMS fallback completed successfully.';
GO
