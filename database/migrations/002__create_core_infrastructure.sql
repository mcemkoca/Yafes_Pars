SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [YafesPars];
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
