SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [YafesPars];
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
