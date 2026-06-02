SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [YafesPars];
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
