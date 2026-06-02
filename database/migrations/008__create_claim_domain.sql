SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [YafesPars];
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
