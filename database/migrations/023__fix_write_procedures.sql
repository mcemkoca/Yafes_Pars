-- =============================================================================
-- Migration 023: Write-procedure signatuur-correcties / Yazma SP imza düzeltmeleri
--   C1. SP_CreateContract: app-vriendelijke signatuur (auto contractnummer,
--       status ACTIEF default, verzekeraarcode → company_id resolutie)
--   C2. SP_CreateLegalPerson: legal_name + vat_number kolommen + opslag
--   C3. SP_AddContractObject: status default ACTIVE
-- =============================================================================
USE [YafesPars];
GO

BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'023__fix_write_procedures')
    BEGIN

        -- ── C2: LegalPerson — naam + BTW-nummer kolommen ─────────────────────
        IF COL_LENGTH(N'person.LegalPerson', N'legal_name') IS NULL
            ALTER TABLE person.LegalPerson ADD legal_name NVARCHAR(200) NULL;

        IF COL_LENGTH(N'person.LegalPerson', N'vat_number') IS NULL
            ALTER TABLE person.LegalPerson ADD vat_number NVARCHAR(30) NULL;

        INSERT INTO core.SchemaMigration (migration_name, execution_status)
        VALUES (N'023__fix_write_procedures', N'SUCCESS');

    END

COMMIT TRANSACTION;
GO

-- ── C2: SP_CreateLegalPerson — legal_name + vat_number ───────────────────────
CREATE OR ALTER PROCEDURE person.SP_CreateLegalPerson
    @tenant_id          UNIQUEIDENTIFIER,
    @dossier            NVARCHAR(50)     = NULL,
    @language_code      NVARCHAR(10)     = N'NL',
    @legal_name         NVARCHAR(200)    = NULL,
    @legal_form         NVARCHAR(120)    = NULL,
    @vat_number         NVARCHAR(30)     = NULL,
    @kbo_number         NVARCHAR(12)     = NULL,
    @nationality        NVARCHAR(80)     = NULL,
    @incorporation_date DATE             = NULL,
    @created_by_user_id UNIQUEIDENTIFIER = NULL,
    @created_person_id  UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @tenant_id IS NULL
        THROW 51700, 'tenant_id is required.', 1;

    IF NULLIF(LTRIM(RTRIM(@legal_name)), N'') IS NULL
        THROW 51701, 'legal_name (bedrijfsnaam) is verplicht.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @NewPerson TABLE (person_id UNIQUEIDENTIFIER NOT NULL);

        INSERT INTO person.Person (tenant_id, person_kind, dossier, language_code, nationality, created_by_user_id)
        OUTPUT inserted.person_id INTO @NewPerson
        VALUES (@tenant_id, N'LEGAL', @dossier, ISNULL(@language_code, N'NL'), @nationality, @created_by_user_id);

        SELECT @created_person_id = person_id FROM @NewPerson;

        INSERT INTO person.LegalPerson
            (person_id, legal_name, legal_form, vat_number, kbo_number, incorporation_date, created_by_user_id)
        VALUES
            (@created_person_id, @legal_name, @legal_form, @vat_number, @kbo_number, @incorporation_date, @created_by_user_id);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ── C1: SP_CreateContract — app-vriendelijke signatuur ───────────────────────
CREATE OR ALTER PROCEDURE policy.SP_CreateContract
    @tenant_id                UNIQUEIDENTIFIER,
    @contract_domain_code     NVARCHAR(40),
    @contract_type_code       NVARCHAR(80),
    @start_date               DATE,
    @end_date                 DATE             = NULL,
    @insurer_institution_code NVARCHAR(60)     = NULL,
    @contract_status_code     NVARCHAR(40)     = N'ACTIVE',
    @contract_number          NVARCHAR(40)     = NULL,
    @created_by_user_id       UNIQUEIDENTIFIER = NULL,
    @created_contract_id      UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @tenant_id IS NULL
        THROW 51632, 'tenant_id is required.', 1;

    -- Verzekeraarcode → company_id resolutie (optioneel)
    DECLARE @company_id UNIQUEIDENTIFIER = NULL;
    IF @insurer_institution_code IS NOT NULL
        SELECT @company_id = institution_id
        FROM institution.Institution
        WHERE institution_code = @insurer_institution_code
          AND tenant_id = @tenant_id
          AND is_deleted = 0;

    -- Auto contractnummer: {jaar}/{domein}/{6 hex}
    IF @contract_number IS NULL OR LTRIM(RTRIM(@contract_number)) = N''
        SET @contract_number = CONCAT(
            YEAR(@start_date), N'/', @contract_domain_code, N'/',
            RIGHT(REPLACE(CONVERT(NVARCHAR(36), NEWID()), N'-', N''), 6));

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CreatedContract TABLE (contract_id UNIQUEIDENTIFIER NOT NULL);

        INSERT INTO policy.Contract (
            tenant_id, contract_number, contract_domain_code, contract_type_code,
            contract_status_code, company_id, start_date, end_date, created_by_user_id
        )
        OUTPUT inserted.contract_id INTO @CreatedContract (contract_id)
        VALUES (
            @tenant_id, @contract_number, @contract_domain_code, @contract_type_code,
            @contract_status_code, @company_id, @start_date, @end_date, @created_by_user_id
        );

        SELECT @created_contract_id = contract_id FROM @CreatedContract;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ── C3: SP_AddContractObject — status default ACTIVE ─────────────────────────
CREATE OR ALTER PROCEDURE policy.SP_AddContractObject
    @tenant_id                   UNIQUEIDENTIFIER,
    @contract_id                 UNIQUEIDENTIFIER,
    @insurable_object_id         UNIQUEIDENTIFIER,
    @contract_object_status_code NVARCHAR(20) = N'ACTIVE',
    @is_primary                  BIT          = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1 FROM policy.Contract
            WHERE contract_id = @contract_id AND tenant_id = @tenant_id AND is_deleted = 0)
            THROW 51604, 'Contract not found for tenant.', 1;

        IF NOT EXISTS (
            SELECT 1 FROM risk.InsurableObject
            WHERE insurable_object_id = @insurable_object_id AND tenant_id = @tenant_id AND is_deleted = 0)
            THROW 51606, 'Insurable object not found for tenant.', 1;

        INSERT INTO policy.ContractObject
            (contract_id, insurable_object_id, contract_object_status_code, is_primary)
        VALUES
            (@contract_id, @insurable_object_id, ISNULL(@contract_object_status_code, N'ACTIVE'), @is_primary);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ── C5: SP_CreateClaim — app-vriendelijke signatuur (auto nummer, +reserved) ─
CREATE OR ALTER PROCEDURE claim.SP_CreateClaim
    @tenant_id          UNIQUEIDENTIFIER,
    @contract_id        UNIQUEIDENTIFIER,
    @reported_date      DATE,
    @incident_date      DATE             = NULL,
    @coverage_code      NVARCHAR(80)     = NULL,
    @description        NVARCHAR(500)    = NULL,
    @reserved_amount    DECIMAL(18,2)    = NULL,
    @claim_status_code  NVARCHAR(40)     = N'OPEN',
    @claim_number       NVARCHAR(50)     = NULL,
    @claims_handler_id  UNIQUEIDENTIFIER = NULL,
    @created_by_user_id UNIQUEIDENTIFIER = NULL,
    @created_claim_id   UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (
        SELECT 1 FROM policy.Contract
        WHERE contract_id = @contract_id AND tenant_id = @tenant_id AND is_deleted = 0)
        THROW 51607, 'Contract not found for tenant.', 1;

    IF @claims_handler_id IS NOT NULL
       AND NOT EXISTS (
            SELECT 1 FROM person.Person
            WHERE person_id = @claims_handler_id AND tenant_id = @tenant_id AND is_deleted = 0)
        THROW 51608, 'claims_handler_id does not belong to the tenant.', 1;

    IF @created_by_user_id IS NOT NULL
       AND NOT EXISTS (
            SELECT 1 FROM core.AppUser
            WHERE user_id = @created_by_user_id AND tenant_id = @tenant_id AND is_active = 1)
        THROW 51609, 'created_by_user_id does not belong to the tenant.', 1;

    -- Auto schadenummer: S{jjjjMMdd}/{6 hex}
    IF @claim_number IS NULL OR LTRIM(RTRIM(@claim_number)) = N''
        SET @claim_number = CONCAT(
            N'S', FORMAT(SYSUTCDATETIME(), N'yyyyMMdd'), N'/',
            RIGHT(REPLACE(CONVERT(NVARCHAR(36), NEWID()), N'-', N''), 6));

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CreatedClaim TABLE (claim_id UNIQUEIDENTIFIER NOT NULL);

        INSERT INTO claim.Claim (
            tenant_id, claim_number, contract_id, coverage_code, claim_status_code,
            claims_handler_id, incident_date, reported_date, description,
            reserved_amount, created_by_user_id
        )
        OUTPUT inserted.claim_id INTO @CreatedClaim (claim_id)
        VALUES (
            @tenant_id, @claim_number, @contract_id, @coverage_code, ISNULL(@claim_status_code, N'OPEN'),
            @claims_handler_id, @incident_date, @reported_date, @description,
            @reserved_amount, @created_by_user_id
        );

        SELECT @created_claim_id = claim_id FROM @CreatedClaim;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

PRINT 'Migration 023 voltooid: write-procedure signaturen gecorrigeerd.';
GO
