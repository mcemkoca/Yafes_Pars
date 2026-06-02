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
