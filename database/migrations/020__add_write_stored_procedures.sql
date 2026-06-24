-- =============================================================================
-- Migration 020 — Write Stored Procedures
-- Adds: coverage.ContractCoverageItem table
--       person.SP_CreateLegalPerson
--       risk.sp_CreateRiskObject / sp_CreateVehicle / sp_CreateProperty / sp_LinkRiskToContract
--       coverage.sp_AddCoverageItem / sp_SetPremium / sp_UpdateCoverage
--       finance.sp_CreateInvoice / sp_RecordPayment / sp_CreatePaymentPlan
--       document.sp_CreateDocument / sp_LinkDocument / sp_ArchiveDocument
-- NOTE: SP body logic intended for Copilot refinement — stubs are functional.
-- =============================================================================
USE [YafesPars];
GO

PRINT 'Running migration: 020__add_write_stored_procedures.sql';
GO

-- ─── coverage.ContractCoverageItem ───────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID('coverage') AND name = 'ContractCoverageItem')
BEGIN
    CREATE TABLE coverage.ContractCoverageItem (
        coverage_item_id   UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID()
                               CONSTRAINT PK_ContractCoverageItem PRIMARY KEY,
        tenant_id          UNIQUEIDENTIFIER NOT NULL,
        contract_id        UNIQUEIDENTIFIER NOT NULL,
        coverage_type_code NVARCHAR(80)     NOT NULL,
        coverage_limit     DECIMAL(18,2)    NOT NULL,
        deductible         DECIMAL(18,2)    NULL,
        currency_code      NCHAR(3)         NOT NULL DEFAULT N'TRY',
        gross_premium      DECIMAL(18,2)    NULL,
        tax_amount         DECIMAL(18,2)    NULL,
        commission_amount  DECIMAL(18,2)    NULL,
        premium_effective_date DATE         NULL,
        status_code        NVARCHAR(32)     NOT NULL DEFAULT N'ACTIVE'
                               CONSTRAINT CK_ContractCoverageItem_Status
                               CHECK (status_code IN (N'ACTIVE', N'CANCELLED', N'EXPIRED')),
        created_at_utc     DATETIME2(2)     NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at_utc     DATETIME2(2)     NOT NULL DEFAULT SYSUTCDATETIME()
    );
    CREATE INDEX IX_ContractCoverageItem_Contract ON coverage.ContractCoverageItem (contract_id);
    CREATE INDEX IX_ContractCoverageItem_Tenant   ON coverage.ContractCoverageItem (tenant_id);
    PRINT 'coverage.ContractCoverageItem created.';
END
GO

-- ─── person.SP_CreateLegalPerson ─────────────────────────────────────────────
CREATE OR ALTER PROCEDURE person.SP_CreateLegalPerson
    @tenant_id              UNIQUEIDENTIFIER,
    @dossier                NVARCHAR(50)     = NULL,
    @language_code          CHAR(2)          = NULL,
    @nationality            NVARCHAR(80)     = NULL,
    @legal_form             NVARCHAR(120)    = NULL,
    @incorporation_date     DATE             = NULL,
    @created_by_user_id     UNIQUEIDENTIFIER = NULL,
    @created_person_id      UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @tenant_id IS NULL
        THROW 51700, 'tenant_id is required.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @NewPerson TABLE (person_id UNIQUEIDENTIFIER NOT NULL);

        INSERT INTO person.Person (tenant_id, person_kind, dossier, language_code, nationality, created_by_user_id)
        OUTPUT inserted.person_id INTO @NewPerson
        VALUES (@tenant_id, N'LEGAL', @dossier, @language_code, @nationality, @created_by_user_id);

        SELECT @created_person_id = person_id FROM @NewPerson;

        INSERT INTO person.LegalPerson (person_id, legal_form, incorporation_date, created_by_user_id)
        VALUES (@created_person_id, @legal_form, @incorporation_date, @created_by_user_id);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ─── risk.sp_CreateRiskObject ────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE risk.sp_CreateRiskObject
    @tenant_id             UNIQUEIDENTIFIER,
    @object_type_code      NVARCHAR(40),
    @description           NVARCHAR(255)    = N'',
    @start_date            DATE             = NULL,
    @created_by_user_id    UNIQUEIDENTIFIER = NULL,
    @insurable_object_id   UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @tenant_id IS NULL
        THROW 51710, 'tenant_id is required.', 1;
    IF @object_type_code IS NULL OR LEN(TRIM(@object_type_code)) = 0
        THROW 51711, 'object_type_code is required.', 1;

    SET @start_date = ISNULL(@start_date, CAST(SYSUTCDATETIME() AS DATE));
    SET @description = ISNULL(@description, N'');

    DECLARE @NewObj TABLE (insurable_object_id UNIQUEIDENTIFIER NOT NULL);

    INSERT INTO risk.InsurableObject
        (tenant_id, object_type_code, description, status_code, start_date, created_by_user_id)
    OUTPUT inserted.insurable_object_id INTO @NewObj
    VALUES (@tenant_id, @object_type_code, @description, N'ACTIVE', @start_date, @created_by_user_id);

    SELECT @insurable_object_id = insurable_object_id FROM @NewObj;
END;
GO

-- ─── risk.sp_CreateVehicle ───────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE risk.sp_CreateVehicle
    @tenant_id             UNIQUEIDENTIFIER,
    @plate_number          NVARCHAR(20),
    @brand                 NVARCHAR(100)    = N'',
    @model                 NVARCHAR(100)    = N'',
    @model_year            INT              = NULL,
    @chassis_number        NVARCHAR(40)     = N'',
    @engine_number         NVARCHAR(40)     = NULL,
    @market_value          DECIMAL(18,2)    = NULL,
    @currency_code         NCHAR(3)         = N'TRY',
    @fuel_type_code        NVARCHAR(40)     = NULL,
    @vehicle_type_code     NVARCHAR(60)     = N'PASSENGER',
    @usage_type_code       NVARCHAR(40)     = N'PRIVATE',
    @plate_type_code       NVARCHAR(40)     = N'STANDARD',
    @created_by_user_id    UNIQUEIDENTIFIER = NULL,
    @insurable_object_id   UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @tenant_id IS NULL
        THROW 51720, 'tenant_id is required.', 1;
    IF @plate_number IS NULL OR LEN(TRIM(@plate_number)) = 0
        THROW 51721, 'plate_number is required.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        EXEC risk.sp_CreateRiskObject
            @tenant_id           = @tenant_id,
            @object_type_code    = N'VEHICLE',
            @description         = @plate_number,
            @created_by_user_id  = @created_by_user_id,
            @insurable_object_id = @insurable_object_id OUTPUT;

        INSERT INTO risk.InsurableVehicle
            (insurable_object_id, vehicle_type_code, usage_type_code, plate_type_code,
             brand, model, chassis_number, build_year, first_commissioning_date,
             registration_date, license_plate, fuel_type_code)
        VALUES
            (@insurable_object_id, @vehicle_type_code, @usage_type_code, @plate_type_code,
             ISNULL(@brand, N''), ISNULL(@model, N''), ISNULL(@chassis_number, N''),
             ISNULL(@model_year, YEAR(SYSUTCDATETIME())),
             CAST(SYSUTCDATETIME() AS DATE), CAST(SYSUTCDATETIME() AS DATE),
             @plate_number, @fuel_type_code);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ─── risk.sp_CreateProperty ──────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE risk.sp_CreateProperty
    @tenant_id             UNIQUEIDENTIFIER,
    @property_address      NVARCHAR(500)    = NULL,
    @property_type_code    NVARCHAR(80)     = N'HOUSE',
    @construction_area     DECIMAL(10,2)    = NULL,
    @construction_year     INT              = NULL,
    @insured_value         DECIMAL(18,2)    = NULL,
    @currency_code         NCHAR(3)         = N'TRY',
    @created_by_user_id    UNIQUEIDENTIFIER = NULL,
    @insurable_object_id   UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @tenant_id IS NULL
        THROW 51730, 'tenant_id is required.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @prop_desc NVARCHAR(255) = ISNULL(@property_address, N'Property');

        EXEC risk.sp_CreateRiskObject
            @tenant_id           = @tenant_id,
            @object_type_code    = N'REAL_ESTATE',
            @description         = @prop_desc,
            @created_by_user_id  = @created_by_user_id,
            @insurable_object_id = @insurable_object_id OUTPUT;

        INSERT INTO risk.InsurableRealEstate
            (insurable_object_id, realestate_type_code, use_type_code, insured_role_code,
             street, number, postal_code, city, country_code)
        VALUES
            (@insurable_object_id,
             ISNULL(@property_type_code, N'HOUSE'),
             N'PRIMARY', N'OWNER',
             ISNULL(@property_address, N''), N'-', N'00000', N'-', N'TR');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ─── risk.sp_LinkRiskToContract ──────────────────────────────────────────────
CREATE OR ALTER PROCEDURE risk.sp_LinkRiskToContract
    @tenant_id             UNIQUEIDENTIFIER,
    @contract_id           UNIQUEIDENTIFIER,
    @insurable_object_id   UNIQUEIDENTIFIER,
    @created_by_user_id    UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM risk.InsurableObject WHERE insurable_object_id = @insurable_object_id AND tenant_id = @tenant_id AND is_deleted = 0)
        THROW 51740, 'InsurableObject not found or does not belong to tenant.', 1;

    IF NOT EXISTS (SELECT 1 FROM policy.Contract WHERE contract_id = @contract_id AND tenant_id = @tenant_id)
        THROW 51741, 'Contract not found or does not belong to tenant.', 1;

    IF EXISTS (SELECT 1 FROM policy.ContractObject WHERE contract_id = @contract_id AND insurable_object_id = @insurable_object_id)
        RETURN;

    INSERT INTO policy.ContractObject (contract_id, insurable_object_id, added_by_user_id)
    VALUES (@contract_id, @insurable_object_id, @created_by_user_id);
END;
GO

-- ─── coverage.sp_AddCoverageItem ─────────────────────────────────────────────
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

    DECLARE @NewItem TABLE (coverage_item_id UNIQUEIDENTIFIER NOT NULL);

    INSERT INTO coverage.ContractCoverageItem
        (tenant_id, contract_id, coverage_type_code, coverage_limit, deductible, currency_code)
    OUTPUT inserted.coverage_item_id INTO @NewItem
    VALUES (@tenant_id, @contract_id, @coverage_type_code, @coverage_limit, @deductible, ISNULL(@currency_code, N'TRY'));

    SELECT @coverage_item_id = coverage_item_id FROM @NewItem;
END;
GO

-- ─── coverage.sp_SetPremium ──────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE coverage.sp_SetPremium
    @tenant_id             UNIQUEIDENTIFIER,
    @coverage_item_id      UNIQUEIDENTIFIER,
    @gross_premium         DECIMAL(18,2),
    @tax_amount            DECIMAL(18,2)    = NULL,
    @commission_amount     DECIMAL(18,2)    = NULL,
    @effective_date        DATE             = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM coverage.ContractCoverageItem WHERE coverage_item_id = @coverage_item_id AND tenant_id = @tenant_id)
        THROW 51760, 'CoverageItem not found or does not belong to tenant.', 1;
    IF @gross_premium < 0
        THROW 51761, 'gross_premium cannot be negative.', 1;

    UPDATE coverage.ContractCoverageItem
    SET gross_premium          = @gross_premium,
        tax_amount             = @tax_amount,
        commission_amount      = @commission_amount,
        premium_effective_date = ISNULL(@effective_date, CAST(SYSUTCDATETIME() AS DATE)),
        updated_at_utc         = SYSUTCDATETIME()
    WHERE coverage_item_id = @coverage_item_id AND tenant_id = @tenant_id;
END;
GO

-- ─── coverage.sp_UpdateCoverage ──────────────────────────────────────────────
CREATE OR ALTER PROCEDURE coverage.sp_UpdateCoverage
    @tenant_id             UNIQUEIDENTIFIER,
    @coverage_item_id      UNIQUEIDENTIFIER,
    @coverage_limit        DECIMAL(18,2),
    @deductible            DECIMAL(18,2)    = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM coverage.ContractCoverageItem WHERE coverage_item_id = @coverage_item_id AND tenant_id = @tenant_id)
        THROW 51770, 'CoverageItem not found or does not belong to tenant.', 1;
    IF @coverage_limit <= 0
        THROW 51771, 'coverage_limit must be greater than zero.', 1;

    UPDATE coverage.ContractCoverageItem
    SET coverage_limit = @coverage_limit,
        deductible     = @deductible,
        updated_at_utc = SYSUTCDATETIME()
    WHERE coverage_item_id = @coverage_item_id AND tenant_id = @tenant_id;
END;
GO

-- ─── finance.sp_CreateInvoice ────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE finance.sp_CreateInvoice
    @tenant_id             UNIQUEIDENTIFIER,
    @contract_id           UNIQUEIDENTIFIER,
    @issue_date            DATE,
    @due_date              DATE,
    @amount                DECIMAL(18,2),
    @currency_code         NCHAR(3)         = N'TRY',
    @invoice_id            UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @contract_id IS NULL
        THROW 51780, 'contract_id is required.', 1;
    IF @amount <= 0
        THROW 51781, 'amount must be greater than zero.', 1;
    IF @due_date < @issue_date
        THROW 51782, 'due_date cannot be before issue_date.', 1;

    DECLARE @NewInv TABLE (InvoiceId UNIQUEIDENTIFIER NOT NULL);

    INSERT INTO finance.Invoices (TenantId, ContractId, IssueDate, DueDate, Amount, CurrencyCode)
    OUTPUT inserted.InvoiceId INTO @NewInv
    VALUES (@tenant_id, @contract_id, @issue_date, @due_date, @amount, ISNULL(@currency_code, N'TRY'));

    SELECT @invoice_id = InvoiceId FROM @NewInv;
END;
GO

-- ─── finance.sp_RecordPayment ────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE finance.sp_RecordPayment
    @tenant_id             UNIQUEIDENTIFIER,
    @invoice_id            UNIQUEIDENTIFIER,
    @payment_date          DATE,
    @amount                DECIMAL(18,2),
    @payment_method_code   NVARCHAR(32)     = N'CASH',
    @payment_id            UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM finance.Invoices WHERE InvoiceId = @invoice_id AND TenantId = @tenant_id)
        THROW 51790, 'Invoice not found or does not belong to tenant.', 1;
    IF @amount <= 0
        THROW 51791, 'amount must be greater than zero.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @NewPay TABLE (PaymentId UNIQUEIDENTIFIER NOT NULL);

        INSERT INTO finance.Payments (TenantId, InvoiceId, PaymentDate, Amount, PaymentMethodCode)
        OUTPUT inserted.PaymentId INTO @NewPay
        VALUES (@tenant_id, @invoice_id, @payment_date, @amount, ISNULL(@payment_method_code, N'CASH'));

        SELECT @payment_id = PaymentId FROM @NewPay;

        DECLARE @paid DECIMAL(18,2);
        SELECT @paid = SUM(Amount) FROM finance.Payments WHERE InvoiceId = @invoice_id;
        DECLARE @total DECIMAL(18,2);
        SELECT @total = Amount FROM finance.Invoices WHERE InvoiceId = @invoice_id;

        IF @paid >= @total
            UPDATE finance.Invoices SET StatusCode = N'PAID', UpdatedAt = SYSUTCDATETIME() WHERE InvoiceId = @invoice_id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ─── finance.sp_CreatePaymentPlan ────────────────────────────────────────────
CREATE OR ALTER PROCEDURE finance.sp_CreatePaymentPlan
    @tenant_id             UNIQUEIDENTIFIER,
    @contract_id           UNIQUEIDENTIFIER,
    @installment_count     SMALLINT,
    @first_due_date        DATE,
    @total_amount          DECIMAL(18,2),
    @currency_code         NCHAR(3)         = N'TRY',
    @plan_id               UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @installment_count < 1
        THROW 51800, 'installment_count must be at least 1.', 1;
    IF @total_amount <= 0
        THROW 51801, 'total_amount must be greater than zero.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @NewPlan TABLE (PlanId UNIQUEIDENTIFIER NOT NULL);

        INSERT INTO finance.PaymentPlans (TenantId, ContractId, InstallmentCount, FirstDueDate, TotalAmount, CurrencyCode)
        OUTPUT inserted.PlanId INTO @NewPlan
        VALUES (@tenant_id, @contract_id, @installment_count, @first_due_date, @total_amount, ISNULL(@currency_code, N'TRY'));

        SELECT @plan_id = PlanId FROM @NewPlan;

        DECLARE @installment_amount DECIMAL(18,2) = ROUND(@total_amount / @installment_count, 2);
        DECLARE @i SMALLINT = 1;
        WHILE @i <= @installment_count
        BEGIN
            INSERT INTO finance.PaymentPlanItems (PlanId, InstallmentNo, DueDate, Amount)
            VALUES (@plan_id, @i, DATEADD(MONTH, @i - 1, @first_due_date), @installment_amount);
            SET @i += 1;
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ─── document.sp_CreateDocument ──────────────────────────────────────────────
CREATE OR ALTER PROCEDURE document.sp_CreateDocument
    @tenant_id             UNIQUEIDENTIFIER,
    @document_type_code    NVARCHAR(80),
    @file_name             NVARCHAR(260),
    @mime_type             NVARCHAR(120)    = N'application/octet-stream',
    @file_size_bytes       BIGINT           = 0,
    @storage_uri           NVARCHAR(500)    = NULL,
    @description           NVARCHAR(500)    = NULL,
    @uploaded_by_user_id   UNIQUEIDENTIFIER = NULL,
    @document_id           UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @file_name IS NULL OR LEN(TRIM(@file_name)) = 0
        THROW 51810, 'file_name is required.', 1;
    IF @document_type_code IS NULL OR LEN(TRIM(@document_type_code)) = 0
        THROW 51811, 'document_type_code is required.', 1;

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
        (@tenant_id, N'GENERAL', NEWID(),
         @document_type_code, @file_name, @ext,
         ISNULL(@mime_type, N'application/octet-stream'),
         ISNULL(@file_size_bytes, 0),
         N'AZURE_BLOB',
         ISNULL(@storage_uri, N'pending/' + CAST(NEWID() AS NVARCHAR(36))),
         @uploaded_by_user_id);

    SELECT @document_id = document_id FROM @NewDoc;
END;
GO

-- ─── document.sp_LinkDocument ────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE document.sp_LinkDocument
    @tenant_id      UNIQUEIDENTIFIER,
    @document_id    UNIQUEIDENTIFIER,
    @entity_type    NVARCHAR(60),
    @entity_id      UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM document.Document WHERE document_id = @document_id AND tenant_id = @tenant_id)
        THROW 51820, 'Document not found or does not belong to tenant.', 1;

    IF @entity_type NOT IN (N'PERSON', N'INSTITUTION', N'POLICY', N'CLAIM', N'RISK_OBJECT')
        THROW 51821, 'entity_type must be PERSON, INSTITUTION, POLICY, CLAIM or RISK_OBJECT.', 1;

    IF NOT EXISTS (SELECT 1 FROM document.DocumentLink WHERE document_id = @document_id AND owner_entity_type = @entity_type AND owner_entity_id = @entity_id)
    BEGIN
        INSERT INTO document.DocumentLink (document_id, owner_entity_type, owner_entity_id)
        VALUES (@document_id, @entity_type, @entity_id);
    END;
END;
GO

-- ─── document.sp_ArchiveDocument ─────────────────────────────────────────────
CREATE OR ALTER PROCEDURE document.sp_ArchiveDocument
    @tenant_id      UNIQUEIDENTIFIER,
    @document_id    UNIQUEIDENTIFIER,
    @reason         NVARCHAR(500)    = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM document.Document WHERE document_id = @document_id AND tenant_id = @tenant_id)
        THROW 51830, 'Document not found or does not belong to tenant.', 1;

    UPDATE document.Document
    SET storage_key  = N'archived/' + CAST(@document_id AS NVARCHAR(36)),
        updated_at_utc = SYSUTCDATETIME()
    WHERE document_id = @document_id AND tenant_id = @tenant_id;
END;
GO

PRINT 'Migration 020 completed successfully.';
GO
