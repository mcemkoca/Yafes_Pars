SET NOCOUNT ON;
GO

USE [YafesPars];
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

    IF @tenant_id IS NULL
        THROW 51630, 'tenant_id is required.', 1;

    IF @created_by_user_id IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM core.AppUser
            WHERE user_id = @created_by_user_id
              AND tenant_id = @tenant_id
              AND is_active = 1
       )
        THROW 51631, 'created_by_user_id does not belong to the tenant.', 1;

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

CREATE OR ALTER PROCEDURE risk.SP_CreateVehicleObject
    @tenant_id UNIQUEIDENTIFIER,
    @description NVARCHAR(255),
    @status_code NVARCHAR(30),
    @start_date DATE,
    @end_date DATE = NULL,
    @vehicle_type_code NVARCHAR(60),
    @usage_type_code NVARCHAR(40),
    @plate_type_code NVARCHAR(40),
    @brand NVARCHAR(100),
    @model NVARCHAR(100),
    @chassis_number NVARCHAR(40),
    @build_year INT,
    @first_commissioning_date DATE,
    @registration_date DATE,
    @license_plate NVARCHAR(20),
    @fuel_type_code NVARCHAR(40) = NULL,
    @drive_type_code NVARCHAR(20) = NULL,
    @finance_institution_id UNIQUEIDENTIFIER = NULL,
    @is_financed BIT = 0,
    @insured_value_ex_vat DECIMAL(18,2) = NULL,
    @insured_value_inc_vat DECIMAL(18,2) = NULL,
    @catalog_value_ex_vat DECIMAL(18,2) = NULL,
    @catalog_value_inc_vat DECIMAL(18,2) = NULL,
    @created_by_user_id UNIQUEIDENTIFIER = NULL,
    @created_insurable_object_id UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @tenant_id IS NULL
        THROW 51640, 'tenant_id is required.', 1;

    IF NULLIF(LTRIM(RTRIM(@description)), N'') IS NULL
        THROW 51641, 'description is required.', 1;

    IF @status_code NOT IN (N'ACTIVE', N'INACTIVE', N'ARCHIVED', N'PENDING')
        THROW 51642, 'status_code is not valid for risk.InsurableObject.', 1;

    IF @start_date IS NULL
        THROW 51643, 'start_date is required.', 1;

    IF @end_date IS NOT NULL AND @end_date < @start_date
        THROW 51644, 'end_date must be greater than or equal to start_date.', 1;

    IF @build_year IS NULL OR @build_year < 1886
        THROW 51645, 'build_year must be 1886 or later.', 1;

    IF @first_commissioning_date IS NULL OR @registration_date IS NULL
        THROW 51646, 'first_commissioning_date and registration_date are required.', 1;

    IF NULLIF(LTRIM(RTRIM(@license_plate)), N'') IS NULL
       OR NULLIF(LTRIM(RTRIM(@chassis_number)), N'') IS NULL
       OR NULLIF(LTRIM(RTRIM(@brand)), N'') IS NULL
       OR NULLIF(LTRIM(RTRIM(@model)), N'') IS NULL
        THROW 51647, 'license_plate, chassis_number, brand, and model are required.', 1;

    IF @is_financed = 0 AND @finance_institution_id IS NOT NULL
        THROW 51648, 'finance_institution_id is allowed only when is_financed = 1.', 1;

    IF @is_financed = 1
       AND NOT EXISTS (
            SELECT 1
            FROM institution.Institution
            WHERE institution_id = @finance_institution_id
              AND tenant_id = @tenant_id
              AND is_deleted = 0
       )
        THROW 51649, 'finance_institution_id does not belong to the tenant.', 1;

    IF @created_by_user_id IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM core.AppUser
            WHERE user_id = @created_by_user_id
              AND tenant_id = @tenant_id
              AND is_active = 1
       )
        THROW 51650, 'created_by_user_id does not belong to the tenant.', 1;

    IF NOT EXISTS (SELECT 1 FROM risk.InsurableObjectType WHERE object_type_code = N'VEHICLE' AND is_active = 1)
        THROW 51651, 'VEHICLE object type is not active.', 1;

    IF NOT EXISTS (SELECT 1 FROM risk.VehicleType WHERE vehicle_type_code = @vehicle_type_code AND is_active = 1)
        THROW 51652, 'vehicle_type_code is not active.', 1;

    IF NOT EXISTS (SELECT 1 FROM risk.UsageType WHERE usage_type_code = @usage_type_code AND is_active = 1)
        THROW 51653, 'usage_type_code is not active.', 1;

    IF NOT EXISTS (SELECT 1 FROM risk.LicensePlateType WHERE plate_type_code = @plate_type_code AND is_active = 1)
        THROW 51654, 'plate_type_code is not active.', 1;

    IF @fuel_type_code IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM risk.FuelType WHERE fuel_type_code = @fuel_type_code AND is_active = 1)
        THROW 51655, 'fuel_type_code is not active.', 1;

    IF @drive_type_code IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM risk.DriveType WHERE drive_type_code = @drive_type_code AND is_active = 1)
        THROW 51656, 'drive_type_code is not active.', 1;

    IF EXISTS (
        SELECT 1
        FROM risk.InsurableObject io
        INNER JOIN risk.InsurableVehicle iv
            ON iv.insurable_object_id = io.insurable_object_id
        WHERE io.tenant_id = @tenant_id
          AND io.is_deleted = 0
          AND (iv.license_plate = @license_plate OR iv.chassis_number = @chassis_number)
    )
        THROW 51657, 'A tenant-owned vehicle already exists for this license plate or chassis number.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CreatedObject TABLE (
            insurable_object_id UNIQUEIDENTIFIER NOT NULL
        );

        INSERT INTO risk.InsurableObject (
            tenant_id,
            object_type_code,
            description,
            status_code,
            start_date,
            end_date,
            created_by_user_id
        )
        OUTPUT inserted.insurable_object_id INTO @CreatedObject (insurable_object_id)
        VALUES (
            @tenant_id,
            N'VEHICLE',
            @description,
            @status_code,
            @start_date,
            @end_date,
            @created_by_user_id
        );

        SELECT @created_insurable_object_id = insurable_object_id
        FROM @CreatedObject;

        INSERT INTO risk.InsurableVehicle (
            insurable_object_id,
            vehicle_type_code,
            usage_type_code,
            plate_type_code,
            brand,
            model,
            chassis_number,
            build_year,
            first_commissioning_date,
            registration_date,
            license_plate,
            fuel_type_code,
            drive_type_code,
            finance_institution_id,
            is_financed,
            insured_value_ex_vat,
            insured_value_inc_vat,
            catalog_value_ex_vat,
            catalog_value_inc_vat
        )
        VALUES (
            @created_insurable_object_id,
            @vehicle_type_code,
            @usage_type_code,
            @plate_type_code,
            @brand,
            @model,
            @chassis_number,
            @build_year,
            @first_commissioning_date,
            @registration_date,
            @license_plate,
            @fuel_type_code,
            @drive_type_code,
            @finance_institution_id,
            @is_financed,
            @insured_value_ex_vat,
            @insured_value_inc_vat,
            @catalog_value_ex_vat,
            @catalog_value_inc_vat
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

    IF @tenant_id IS NULL
        THROW 51632, 'tenant_id is required.', 1;

    IF @company_id IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM institution.Institution
            WHERE institution_id = @company_id
              AND tenant_id = @tenant_id
              AND is_deleted = 0
       )
        THROW 51633, 'company_id does not belong to the tenant.', 1;

    IF @handling_company_id IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM institution.Institution
            WHERE institution_id = @handling_company_id
              AND tenant_id = @tenant_id
              AND is_deleted = 0
       )
        THROW 51634, 'handling_company_id does not belong to the tenant.', 1;

    IF @created_by_user_id IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM core.AppUser
            WHERE user_id = @created_by_user_id
              AND tenant_id = @tenant_id
              AND is_active = 1
       )
        THROW 51635, 'created_by_user_id does not belong to the tenant.', 1;

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

    IF @created_by_user_id IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM core.AppUser
            WHERE user_id = @created_by_user_id
              AND tenant_id = @tenant_id
              AND is_active = 1
       )
        THROW 51636, 'created_by_user_id does not belong to the tenant.', 1;

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

        IF NOT EXISTS (
            SELECT 1
            FROM person.Person
            WHERE person_id = @person_id
              AND tenant_id = @tenant_id
              AND is_deleted = 0
        )
            THROW 51605, 'Person not found for tenant.', 1;

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

        IF NOT EXISTS (
            SELECT 1
            FROM risk.InsurableObject
            WHERE insurable_object_id = @insurable_object_id
              AND tenant_id = @tenant_id
              AND is_deleted = 0
        )
            THROW 51606, 'Insurable object not found for tenant.', 1;

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

    IF NOT EXISTS (
        SELECT 1
        FROM policy.Contract
        WHERE contract_id = @contract_id
          AND tenant_id = @tenant_id
          AND is_deleted = 0
    )
        THROW 51607, 'Contract not found for tenant.', 1;

    IF @claims_handler_id IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM person.Person
            WHERE person_id = @claims_handler_id
              AND tenant_id = @tenant_id
              AND is_deleted = 0
       )
        THROW 51608, 'claims_handler_id does not belong to the tenant.', 1;

    IF @created_by_user_id IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM core.AppUser
            WHERE user_id = @created_by_user_id
              AND tenant_id = @tenant_id
              AND is_active = 1
       )
        THROW 51609, 'created_by_user_id does not belong to the tenant.', 1;

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

    IF @updated_by_user_id IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM core.AppUser
            WHERE user_id = @updated_by_user_id
              AND tenant_id = @tenant_id
              AND is_active = 1
       )
        THROW 51610, 'updated_by_user_id does not belong to the tenant.', 1;

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

CREATE OR ALTER PROCEDURE tasking.SP_CreateTask
    @tenant_id UNIQUEIDENTIFIER,
    @title NVARCHAR(200),
    @description NVARCHAR(MAX) = NULL,
    @related_entity_type NVARCHAR(60) = NULL,
    @related_entity_id UNIQUEIDENTIFIER = NULL,
    @assigned_to_user_id UNIQUEIDENTIFIER = NULL,
    @created_by_user_id UNIQUEIDENTIFIER = NULL,
    @task_priority_code NVARCHAR(20) = N'NORMAL',
    @task_status_code NVARCHAR(30) = N'OPEN',
    @due_at_utc DATETIME2(0) = NULL,
    @created_task_id UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @title = NULLIF(LTRIM(RTRIM(@title)), N'');
    SET @related_entity_type = NULLIF(UPPER(LTRIM(RTRIM(@related_entity_type))), N'');
    SET @task_priority_code = COALESCE(NULLIF(UPPER(LTRIM(RTRIM(@task_priority_code))), N''), N'NORMAL');
    SET @task_status_code = COALESCE(NULLIF(UPPER(LTRIM(RTRIM(@task_status_code))), N''), N'OPEN');

    IF @tenant_id IS NULL
        THROW 51630, 'tenant_id is required.', 1;

    IF @title IS NULL
        THROW 51631, 'title is required.', 1;

    IF @related_entity_type IS NULL AND @related_entity_id IS NOT NULL
        THROW 51632, 'related_entity_type is required when related_entity_id is provided.', 1;

    IF @related_entity_type IS NOT NULL AND @related_entity_id IS NULL
        THROW 51633, 'related_entity_id is required when related_entity_type is provided.', 1;

    IF @related_entity_type IS NOT NULL
       AND @related_entity_type NOT IN (N'PERSON', N'INSTITUTION', N'POLICY', N'CLAIM', N'RISK_OBJECT', N'DOCUMENT')
        THROW 51634, 'related_entity_type is not supported.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM tasking.TaskPriority
        WHERE task_priority_code = @task_priority_code
          AND is_active = 1
    )
        THROW 51635, 'task_priority_code was not found or is inactive.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM tasking.TaskStatus
        WHERE task_status_code = @task_status_code
          AND is_active = 1
    )
        THROW 51636, 'task_status_code was not found or is inactive.', 1;

    IF @task_status_code = N'DONE'
        THROW 51637, 'Use editing guardrails to complete an existing task; create starts as OPEN/IN_PROGRESS/WAITING.', 1;

    IF @assigned_to_user_id IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM core.AppUser
            WHERE user_id = @assigned_to_user_id
              AND tenant_id = @tenant_id
              AND is_active = 1
       )
        THROW 51638, 'assigned_to_user_id does not belong to the tenant.', 1;

    IF @created_by_user_id IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM core.AppUser
            WHERE user_id = @created_by_user_id
              AND tenant_id = @tenant_id
              AND is_active = 1
       )
        THROW 51639, 'created_by_user_id does not belong to the tenant.', 1;

    IF @related_entity_type = N'PERSON'
       AND NOT EXISTS (
            SELECT 1
            FROM person.Person
            WHERE person_id = @related_entity_id
              AND tenant_id = @tenant_id
              AND is_deleted = 0
       )
        THROW 51640, 'related PERSON was not found for tenant.', 1;

    IF @related_entity_type = N'INSTITUTION'
       AND NOT EXISTS (
            SELECT 1
            FROM institution.Institution
            WHERE institution_id = @related_entity_id
              AND tenant_id = @tenant_id
              AND is_deleted = 0
       )
        THROW 51641, 'related INSTITUTION was not found for tenant.', 1;

    IF @related_entity_type = N'POLICY'
       AND NOT EXISTS (
            SELECT 1
            FROM policy.Contract
            WHERE contract_id = @related_entity_id
              AND tenant_id = @tenant_id
              AND is_deleted = 0
       )
        THROW 51642, 'related POLICY was not found for tenant.', 1;

    IF @related_entity_type = N'CLAIM'
       AND NOT EXISTS (
            SELECT 1
            FROM claim.Claim
            WHERE claim_id = @related_entity_id
              AND tenant_id = @tenant_id
              AND is_deleted = 0
       )
        THROW 51643, 'related CLAIM was not found for tenant.', 1;

    IF @related_entity_type = N'RISK_OBJECT'
       AND NOT EXISTS (
            SELECT 1
            FROM risk.InsurableObject
            WHERE insurable_object_id = @related_entity_id
              AND tenant_id = @tenant_id
              AND is_deleted = 0
       )
        THROW 51644, 'related RISK_OBJECT was not found for tenant.', 1;

    IF @related_entity_type = N'DOCUMENT'
       AND NOT EXISTS (
            SELECT 1
            FROM document.Document
            WHERE document_id = @related_entity_id
              AND tenant_id = @tenant_id
              AND is_deleted = 0
       )
        THROW 51645, 'related DOCUMENT was not found for tenant.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CreatedTask TABLE (
            task_id UNIQUEIDENTIFIER NOT NULL
        );

        INSERT INTO tasking.Task (
            tenant_id,
            title,
            description,
            related_entity_type,
            related_entity_id,
            assigned_to_user_id,
            created_by_user_id,
            task_priority_code,
            task_status_code,
            due_at_utc
        )
        OUTPUT inserted.task_id
        INTO @CreatedTask (task_id)
        VALUES (
            @tenant_id,
            @title,
            @description,
            @related_entity_type,
            @related_entity_id,
            @assigned_to_user_id,
            @created_by_user_id,
            @task_priority_code,
            @task_status_code,
            @due_at_utc
        );

        SELECT @created_task_id = task_id
        FROM @CreatedTask;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE tasking.SP_AddTaskComment
    @tenant_id UNIQUEIDENTIFIER,
    @task_id UNIQUEIDENTIFIER,
    @comment_text NVARCHAR(MAX),
    @created_by_user_id UNIQUEIDENTIFIER = NULL,
    @created_task_comment_id UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @comment_text = NULLIF(LTRIM(RTRIM(@comment_text)), N'');

    IF @tenant_id IS NULL
        THROW 51650, 'tenant_id is required.', 1;

    IF @task_id IS NULL
        THROW 51651, 'task_id is required.', 1;

    IF @comment_text IS NULL
        THROW 51652, 'comment_text is required.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM tasking.Task
        WHERE task_id = @task_id
          AND tenant_id = @tenant_id
          AND is_deleted = 0
    )
        THROW 51653, 'task_id was not found for tenant.', 1;

    IF @created_by_user_id IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM core.AppUser
            WHERE user_id = @created_by_user_id
              AND tenant_id = @tenant_id
              AND is_active = 1
       )
        THROW 51654, 'created_by_user_id does not belong to the tenant.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CreatedTaskComment TABLE (
            task_comment_id UNIQUEIDENTIFIER NOT NULL
        );

        INSERT INTO tasking.TaskComment (
            task_id,
            comment_text,
            created_by_user_id
        )
        OUTPUT inserted.task_comment_id
        INTO @CreatedTaskComment (task_comment_id)
        VALUES (
            @task_id,
            @comment_text,
            @created_by_user_id
        );

        SELECT @created_task_comment_id = task_comment_id
        FROM @CreatedTaskComment;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE tasking.SP_AddTaskReminder
    @tenant_id UNIQUEIDENTIFIER,
    @task_id UNIQUEIDENTIFIER,
    @remind_at_utc DATETIME2(0),
    @channel_code NVARCHAR(30) = N'IN_APP',
    @created_task_reminder_id UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @channel_code = COALESCE(NULLIF(UPPER(LTRIM(RTRIM(@channel_code))), N''), N'IN_APP');

    IF @tenant_id IS NULL
        THROW 51660, 'tenant_id is required.', 1;

    IF @task_id IS NULL
        THROW 51661, 'task_id is required.', 1;

    IF @remind_at_utc IS NULL
        THROW 51662, 'remind_at_utc is required.', 1;

    IF @remind_at_utc < DATEADD(MINUTE, -5, SYSUTCDATETIME())
        THROW 51663, 'remind_at_utc cannot be in the past.', 1;

    IF @channel_code NOT IN (N'IN_APP', N'EMAIL', N'SMS')
        THROW 51664, 'channel_code must be IN_APP, EMAIL, or SMS.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM tasking.Task
        WHERE task_id = @task_id
          AND tenant_id = @tenant_id
          AND is_deleted = 0
          AND task_status_code <> N'DONE'
    )
        THROW 51665, 'task_id was not found for tenant or is already DONE.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CreatedTaskReminder TABLE (
            task_reminder_id UNIQUEIDENTIFIER NOT NULL
        );

        INSERT INTO tasking.TaskReminder (
            task_id,
            remind_at_utc,
            channel_code
        )
        OUTPUT inserted.task_reminder_id
        INTO @CreatedTaskReminder (task_reminder_id)
        VALUES (
            @task_id,
            @remind_at_utc,
            @channel_code
        );

        SELECT @created_task_reminder_id = task_reminder_id
        FROM @CreatedTaskReminder;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE tasking.SP_CreateRenewalTasks
    @tenant_id UNIQUEIDENTIFIER,
    @days_ahead INT = 60,
    @assigned_to_user_id UNIQUEIDENTIFIER = NULL,
    @created_by_user_id UNIQUEIDENTIFIER = NULL,
    @dry_run BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @tenant_id IS NULL
        THROW 51620, 'tenant_id is required.', 1;

    IF @days_ahead IS NULL OR @days_ahead < 0 OR @days_ahead > 366
        THROW 51621, 'days_ahead must be between 0 and 366.', 1;

    IF @assigned_to_user_id IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM core.AppUser
            WHERE user_id = @assigned_to_user_id
              AND tenant_id = @tenant_id
              AND is_active = 1
       )
        THROW 51622, 'assigned_to_user_id does not belong to the tenant.', 1;

    IF @created_by_user_id IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM core.AppUser
            WHERE user_id = @created_by_user_id
              AND tenant_id = @tenant_id
              AND is_active = 1
       )
        THROW 51623, 'created_by_user_id does not belong to the tenant.', 1;

    DECLARE @today DATE = CONVERT(DATE, SYSUTCDATETIME());
    DECLARE @now DATETIME2(0) = SYSUTCDATETIME();

    DECLARE @Candidates TABLE (
        contract_id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
        contract_number NVARCHAR(40) NOT NULL,
        contract_domain_code NVARCHAR(40) NOT NULL,
        contract_type_code NVARCHAR(80) NOT NULL,
        end_date DATE NOT NULL,
        due_at_utc DATETIME2(0) NOT NULL,
        task_priority_code NVARCHAR(20) NOT NULL
    );

    INSERT INTO @Candidates (
        contract_id,
        contract_number,
        contract_domain_code,
        contract_type_code,
        end_date,
        due_at_utc,
        task_priority_code
    )
    SELECT
        c.contract_id,
        c.contract_number,
        c.contract_domain_code,
        c.contract_type_code,
        c.end_date,
        CASE
            WHEN DATEADD(DAY, -@days_ahead, CONVERT(DATETIME2(0), c.end_date)) < @now
                THEN @now
            ELSE DATEADD(DAY, -@days_ahead, CONVERT(DATETIME2(0), c.end_date))
        END AS due_at_utc,
        CASE
            WHEN DATEDIFF(DAY, @today, c.end_date) <= 14 THEN N'HIGH'
            ELSE N'NORMAL'
        END AS task_priority_code
    FROM policy.Contract c
    WHERE c.tenant_id = @tenant_id
      AND c.is_deleted = 0
      AND c.contract_status_code = N'ACTIVE'
      AND c.end_date IS NOT NULL
      AND c.end_date >= @today
      AND c.end_date <= DATEADD(DAY, @days_ahead, @today)
      AND NOT EXISTS (
            SELECT 1
            FROM tasking.Task t
            WHERE t.tenant_id = c.tenant_id
              AND t.related_entity_type = N'POLICY'
              AND t.related_entity_id = c.contract_id
              AND t.task_status_code IN (N'OPEN', N'IN_PROGRESS', N'WAITING')
              AND t.is_deleted = 0
              AND t.title = N'Policy renewal follow-up'
      );

    IF @dry_run = 1
    BEGIN
        SELECT
            contract_id,
            contract_number,
            contract_domain_code,
            contract_type_code,
            end_date,
            due_at_utc,
            task_priority_code
        FROM @Candidates
        ORDER BY end_date, contract_number;

        SELECT COUNT(1) AS candidate_task_count
        FROM @Candidates;

        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CreatedTasks TABLE (
            task_id UNIQUEIDENTIFIER NOT NULL,
            contract_id UNIQUEIDENTIFIER NOT NULL
        );

        INSERT INTO tasking.Task (
            tenant_id,
            title,
            description,
            related_entity_type,
            related_entity_id,
            assigned_to_user_id,
            created_by_user_id,
            task_priority_code,
            task_status_code,
            due_at_utc
        )
        OUTPUT inserted.task_id, inserted.related_entity_id
        INTO @CreatedTasks (task_id, contract_id)
        SELECT
            @tenant_id,
            N'Policy renewal follow-up',
            N'Automatically generated renewal reminder for policy ' + c.contract_number + N'.',
            N'POLICY',
            c.contract_id,
            @assigned_to_user_id,
            @created_by_user_id,
            c.task_priority_code,
            N'OPEN',
            c.due_at_utc
        FROM @Candidates c;

        SELECT COUNT(1) AS created_task_count
        FROM @CreatedTasks;

        SELECT
            ct.task_id,
            ct.contract_id
        FROM @CreatedTasks ct
        ORDER BY ct.task_id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
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
