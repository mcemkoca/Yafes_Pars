/*
    Yafes Pars SSMS Workbench - Data Entry Bridge Templates

    INFO TIP:
    This file turns common data entry into guided, procedure-based SSMS actions.
    It changes no data while EXECUTE_ACTION = 0. Set one ACTION_NAME, review the
    preview grids, then set EXECUTE_ACTION = 1 only when the input is correct.

    Enable SQLCMD Mode before running.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE "DEV-BE-BROKER"
:setvar ACTION_NAME "CREATE_NATURAL_PERSON"
:setvar EXECUTE_ACTION "0"

-- Common operator values
:setvar CREATED_BY_USER_EMAIL "ops.admin@yafes.local"

-- CREATE_NATURAL_PERSON values
:setvar PERSON_DOSSIER "DOS-NEW-001"
:setvar PERSON_LANGUAGE "nl"
:setvar PERSON_NATIONALITY "Belgian"
:setvar PERSON_FIRST_NAME "New"
:setvar PERSON_LAST_NAME "Customer"
:setvar PERSON_BIRTH_DATE "1985-01-01"
:setvar PERSON_TITLE_CODE ""

-- CREATE_POLICY values
:setvar CONTRACT_NUMBER "POL-NEW-001"
:setvar CONTRACT_DOMAIN_CODE "AUTO"
:setvar CONTRACT_TYPE_CODE "AUTO_PRIVATE"
:setvar CONTRACT_STATUS_CODE "ACTIVE"
:setvar CONTRACT_START_DATE "2026-01-01"
:setvar CONTRACT_END_DATE "2026-12-31"
:setvar COMPANY_ID ""
:setvar HANDLING_COMPANY_ID ""

-- CREATE_POLICY_VERSION values
:setvar CONTRACT_ID ""
:setvar VERSION_NO "1"
:setvar VERSION_EFFECTIVE_FROM "2026-01-01"
:setvar VERSION_EFFECTIVE_TO "2026-12-31"
:setvar CONTRACT_VERSION_STATUS_CODE "ACTIVE"
:setvar DURATION_TYPE_CODE "ANNUAL"
:setvar PERIODICITY_CODE "YEARLY"
:setvar COLLECTION_METHOD_CODE "DIRECT_DEBIT"

-- ADD_POLICY_PARTY values
:setvar PARTY_CONTRACT_ID ""
:setvar PARTY_PERSON_ID ""
:setvar CONTRACT_PARTY_ROLE_CODE "POLICYHOLDER"
:setvar PARTY_IS_PRIMARY "1"

-- ADD_POLICY_OBJECT values
:setvar OBJECT_CONTRACT_ID ""
:setvar INSURABLE_OBJECT_ID ""
:setvar CONTRACT_OBJECT_STATUS_CODE "ACTIVE"
:setvar OBJECT_IS_PRIMARY "0"

-- CREATE_VEHICLE_OBJECT values
:setvar VEHICLE_DESCRIPTION "2026 Volvo XC40"
:setvar VEHICLE_STATUS_CODE "ACTIVE"
:setvar VEHICLE_START_DATE "2026-01-01"
:setvar VEHICLE_END_DATE ""
:setvar VEHICLE_TYPE_CODE "CAR"
:setvar VEHICLE_USAGE_TYPE_CODE "PRIVATE"
:setvar VEHICLE_PLATE_TYPE_CODE "NORMAL"
:setvar VEHICLE_BRAND "Volvo"
:setvar VEHICLE_MODEL "XC40"
:setvar VEHICLE_CHASSIS_NUMBER "YV1NEWSSMS0000001"
:setvar VEHICLE_BUILD_YEAR "2026"
:setvar VEHICLE_FIRST_COMMISSIONING_DATE "2026-01-01"
:setvar VEHICLE_REGISTRATION_DATE "2026-01-02"
:setvar VEHICLE_LICENSE_PLATE "1-SSMS-001"
:setvar VEHICLE_FUEL_TYPE_CODE "ELECTRIC"
:setvar VEHICLE_DRIVE_TYPE_CODE "AWD"
:setvar VEHICLE_IS_FINANCED "0"
:setvar VEHICLE_FINANCE_INSTITUTION_ID ""
:setvar VEHICLE_INSURED_VALUE_EX_VAT ""
:setvar VEHICLE_INSURED_VALUE_INC_VAT ""
:setvar VEHICLE_CATALOG_VALUE_EX_VAT ""
:setvar VEHICLE_CATALOG_VALUE_INC_VAT ""

-- CREATE_CLAIM values
:setvar CLAIM_NUMBER "CLM-NEW-001"
:setvar CLAIM_CONTRACT_ID ""
:setvar CLAIM_STATUS_CODE "OPEN"
:setvar CLAIM_REPORTED_DATE "2026-06-03"
:setvar CLAIM_COVERAGE_CODE ""
:setvar CLAIM_HANDLER_USER_EMAIL ""
:setvar CLAIM_INCIDENT_DATE "2026-06-03"
:setvar CLAIM_DESCRIPTION "New claim created from SSMS bridge template."

-- CLOSE_CLAIM values
:setvar CLOSE_CLAIM_ID ""
:setvar CLOSE_CLAIM_CLOSED_DATE "2026-06-04"
:setvar CLOSE_CLAIM_PAID_AMOUNT ""
:setvar CLOSE_CLAIM_RESERVED_AMOUNT ""
:setvar CLOSE_CLAIM_PAYMENT_METHOD_CODE ""

-- CREATE_TASK values
:setvar TASK_TITLE "Follow up customer file"
:setvar TASK_DESCRIPTION "Created from SSMS bridge template."
:setvar TASK_RELATED_ENTITY_TYPE ""
:setvar TASK_RELATED_ENTITY_ID ""
:setvar TASK_ASSIGNED_TO_USER_EMAIL "broker.operator@yafes.local"
:setvar TASK_PRIORITY_CODE "NORMAL"
:setvar TASK_STATUS_CODE "OPEN"
:setvar TASK_DUE_AT_UTC "2026-06-15T10:00:00"

-- ADD_TASK_COMMENT values
:setvar TASK_COMMENT_TASK_ID ""
:setvar TASK_COMMENT_TEXT "Reviewed in SSMS bridge."

-- ADD_TASK_REMINDER values
:setvar TASK_REMINDER_TASK_ID ""
:setvar TASK_REMINDER_AT_UTC "2026-06-15T09:00:00"
:setvar TASK_REMINDER_CHANNEL_CODE "IN_APP"

-- CREATE_SETTLEMENT values
:setvar SETTLEMENT_CLAIM_ID ""
:setvar SETTLEMENT_OFFER_AMOUNT "1000.00"
:setvar SETTLEMENT_IBAN ""
:setvar SETTLEMENT_NOTES "Settlement offer created via SSMS bridge."

-- APPROVE_SETTLEMENT values
:setvar APPROVE_SETTLEMENT_ID ""
:setvar APPROVE_SETTLEMENT_CLAIM_ID ""
:setvar APPROVE_AGREED_AMOUNT ""
:setvar APPROVE_PAYMENT_REFERENCE ""
:setvar APPROVE_PAYMENT_METHOD_CODE "BANK_TRANSFER"

-- UPDATE_CLAIM_RESERVE values
:setvar RESERVE_CLAIM_ID ""
:setvar RESERVE_NEW_AMOUNT "5000.00"
:setvar RESERVE_REASON_CODE "MANUAL"
:setvar RESERVE_NOTES "Reserve updated via SSMS bridge."

-- CREATE_LEGAL_PERSON values
:setvar LEGAL_DOSSIER "DOS-ORG-001"
:setvar LEGAL_LANGUAGE "nl"
:setvar LEGAL_NAME "New Legal Entity NV"
:setvar LEGAL_FORM "NV"
:setvar LEGAL_VAT_NUMBER ""
:setvar LEGAL_KBO_NUMBER ""
:setvar LEGAL_NATIONALITY "Belgian"
:setvar LEGAL_INCORPORATION_DATE "2020-01-01"

-- REGISTER_EXPORT_JOB values
:setvar EXPORT_TYPE_CODE "FSMA"
:setvar EXPORT_PERIOD_START "2026-01-01"
:setvar EXPORT_PERIOD_END "2026-06-30"

-- COMPLETE_EXPORT_JOB values
:setvar COMPLETE_JOB_ID ""
:setvar COMPLETE_STATUS_CODE "SUCCESS"
:setvar COMPLETE_ROW_COUNT "0"
:setvar COMPLETE_ERROR_MESSAGE ""

-- CREATE_REAL_ESTATE_OBJECT values
:setvar PROPERTY_ADDRESS "Leopoldstraat 1, 1000 Brussel"
:setvar PROPERTY_TYPE_CODE "HOUSE"
:setvar PROPERTY_CONSTRUCTION_AREA ""
:setvar PROPERTY_CONSTRUCTION_YEAR ""
:setvar PROPERTY_INSURED_VALUE ""
:setvar PROPERTY_CURRENCY_CODE "EUR"

-- ADD_COVERAGE_ITEM values
:setvar COVERAGE_CONTRACT_ID ""
:setvar COVERAGE_TYPE_CODE "FIRE_BUILDING"
:setvar COVERAGE_LIMIT "250000.00"
:setvar COVERAGE_DEDUCTIBLE "500.00"
:setvar COVERAGE_CURRENCY_CODE "EUR"

-- ATTACH_DOCUMENT values
:setvar DOC_DOCUMENT_TYPE_CODE "POLICY_DOCUMENT"
:setvar DOC_FILE_NAME "policy.pdf"
:setvar DOC_MIME_TYPE "application/pdf"
:setvar DOC_FILE_SIZE_BYTES "0"
:setvar DOC_STORAGE_URI ""
:setvar DOC_OWNER_ENTITY_TYPE "POLICY"
:setvar DOC_OWNER_ENTITY_ID ""

-- RECORD_PAYMENT values
:setvar PAYMENT_INVOICE_ID ""
:setvar PAYMENT_DATE "2026-07-01"
:setvar PAYMENT_AMOUNT "500.00"
:setvar PAYMENT_METHOD_CODE "BANK_TRANSFER"

-- CREATE_PAYMENT_PLAN values
:setvar PLAN_CONTRACT_ID ""
:setvar PLAN_INSTALLMENT_COUNT "4"
:setvar PLAN_FIRST_DUE_DATE "2026-08-01"
:setvar PLAN_TOTAL_AMOUNT "2000.00"
:setvar PLAN_CURRENCY_CODE "EUR"

SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

IF DB_NAME() NOT LIKE N'%DEV%'
    THROW 52399, 'Current database name must contain DEV.', 1;

DECLARE @TenantCode NVARCHAR(80) = N'$(TENANT_CODE)';
DECLARE @ActionName NVARCHAR(80) = UPPER(N'$(ACTION_NAME)');
DECLARE @ExecuteAction BIT = TRY_CONVERT(BIT, N'$(EXECUTE_ACTION)');
DECLARE @TenantId UNIQUEIDENTIFIER;
DECLARE @CreatedByUserId UNIQUEIDENTIFIER;

IF @ExecuteAction IS NULL
    THROW 52300, 'EXECUTE_ACTION must be 0 or 1.', 1;

SELECT @TenantId = tenant_id
FROM core.Tenant
WHERE tenant_code = @TenantCode;

IF @TenantId IS NULL
    THROW 52301, 'Tenant code was not found.', 1;

SELECT @CreatedByUserId = user_id
FROM core.AppUser
WHERE tenant_id = @TenantId
  AND email = NULLIF(N'$(CREATED_BY_USER_EMAIL)', N'')
  AND is_active = 1;

PRINT 'INFO TIP: EXECUTE_ACTION = 0 previews only. EXECUTE_ACTION = 1 performs the selected action.';

PRINT '01 - Selected action';
SELECT
    @ActionName AS action_name,
    @ExecuteAction AS execute_action,
    @TenantCode AS tenant_code,
    @TenantId AS tenant_id,
    @CreatedByUserId AS created_by_user_id,
    N'INFO TIP: If created_by_user_id is NULL, creation still works only where the stored procedure allows NULL.' AS info_tip;

IF @ActionName NOT IN (
    N'CREATE_NATURAL_PERSON',
    N'CREATE_POLICY',
    N'CREATE_POLICY_VERSION',
    N'ADD_POLICY_PARTY',
    N'ADD_POLICY_OBJECT',
    N'CREATE_VEHICLE_OBJECT',
    N'CREATE_CLAIM',
    N'CLOSE_CLAIM',
    N'CREATE_TASK',
    N'ADD_TASK_COMMENT',
    N'ADD_TASK_REMINDER',
    N'CREATE_SETTLEMENT',
    N'APPROVE_SETTLEMENT',
    N'UPDATE_CLAIM_RESERVE',
    N'CREATE_LEGAL_PERSON',
    N'REGISTER_EXPORT_JOB',
    N'COMPLETE_EXPORT_JOB',
    N'CREATE_REAL_ESTATE_OBJECT',
    N'ADD_COVERAGE_ITEM',
    N'ATTACH_DOCUMENT',
    N'RECORD_PAYMENT',
    N'CREATE_PAYMENT_PLAN'
)
    THROW 52302, 'Unknown ACTION_NAME.', 1;

PRINT '01B - Available bridge actions';
SELECT
    action_name,
    procedure_name,
    default_mode,
    info_tip
FROM (VALUES
    (N'ADD_POLICY_OBJECT',    N'policy.SP_AddContractObject',      N'PREVIEW_FIRST', N'Links a tenant-owned risk object to a tenant-owned policy.'),
    (N'ADD_POLICY_PARTY',     N'policy.SP_AddContractParty',       N'PREVIEW_FIRST', N'Links a tenant-owned person to a tenant-owned policy.'),
    (N'ADD_TASK_COMMENT',     N'tasking.SP_AddTaskComment',        N'PREVIEW_FIRST', N'Adds an operator comment to a tenant-owned task.'),
    (N'ADD_TASK_REMINDER',    N'tasking.SP_AddTaskReminder',       N'PREVIEW_FIRST', N'Adds a future reminder to a tenant-owned open task.'),
    (N'APPROVE_SETTLEMENT',   N'claim.SP_ApproveSettlement',       N'PREVIEW_FIRST', N'Approves a DRAFT settlement offer; transitions claim to PENDING_PAYMENT.'),
    (N'CLOSE_CLAIM',          N'claim.SP_CloseClaim',              N'PREVIEW_FIRST', N'Closes a tenant-owned claim with amount and payment checks.'),
    (N'COMPLETE_EXPORT_JOB',  N'import.SP_CompleteExportJob',      N'PREVIEW_FIRST', N'Marks an export job SUCCESS, FAILED, or CANCELLED with row count.'),
    (N'CREATE_CLAIM',         N'claim.SP_CreateClaim',             N'PREVIEW_FIRST', N'Creates an open claim and resolves handler email to handler person_id.'),
    (N'CREATE_LEGAL_PERSON',  N'person.SP_CreateLegalPerson',      N'PREVIEW_FIRST', N'Creates a legal entity (company/org) customer root record.'),
    (N'CREATE_NATURAL_PERSON',N'person.SP_CreateNaturalPerson',    N'PREVIEW_FIRST', N'Creates the customer root and natural-person detail row.'),
    (N'CREATE_POLICY',        N'policy.SP_CreateContract',         N'PREVIEW_FIRST', N'Creates the policy contract shell after lookup checks.'),
    (N'CREATE_POLICY_VERSION',N'policy.SP_CreateContractVersion',  N'PREVIEW_FIRST', N'Adds a version to an existing tenant-owned policy.'),
    (N'CREATE_SETTLEMENT',    N'claim.SP_CreateSettlement',        N'PREVIEW_FIRST', N'Creates a settlement offer (DRAFT) for a tenant-owned claim.'),
    (N'CREATE_TASK',          N'tasking.SP_CreateTask',            N'PREVIEW_FIRST', N'Creates a tenant-owned follow-up task with optional related entity validation.'),
    (N'CREATE_VEHICLE_OBJECT',N'risk.SP_CreateVehicleObject',      N'PREVIEW_FIRST', N'Creates a tenant-owned vehicle risk object before policy linking.'),
    (N'REGISTER_EXPORT_JOB',  N'import.SP_CreateExportJob',        N'PREVIEW_FIRST', N'Registers a new bulk export job (FSMA, PORTFOLIO, CLAIMS, LEDGER, CUSTOM).'),
    (N'UPDATE_CLAIM_RESERVE',        N'claim.SP_UpdateClaimReserve',        N'PREVIEW_FIRST', N'Updates the reserved amount for a tenant-owned claim with reason logging.'),
    (N'CREATE_REAL_ESTATE_OBJECT',   N'risk.sp_CreateProperty',             N'PREVIEW_FIRST', N'Creates a real estate risk object (house, apartment) before policy linking.'),
    (N'ADD_COVERAGE_ITEM',           N'coverage.sp_AddCoverageItem',        N'PREVIEW_FIRST', N'Adds a coverage line item to a tenant-owned policy contract.'),
    (N'ATTACH_DOCUMENT',             N'document.sp_CreateDocument',         N'PREVIEW_FIRST', N'Registers a document metadata record and links it to a policy, claim, or person.'),
    (N'RECORD_PAYMENT',              N'finance.sp_RecordPayment',           N'PREVIEW_FIRST', N'Records a payment against an invoice; auto-marks invoice PAID when fully settled.'),
    (N'CREATE_PAYMENT_PLAN',         N'finance.sp_CreatePaymentPlan',       N'PREVIEW_FIRST', N'Creates an installment payment plan with auto-generated instalment schedule.')
) AS a(action_name, procedure_name, default_mode, info_tip)
ORDER BY action_name;

IF @ActionName = N'CREATE_NATURAL_PERSON'
BEGIN
    DECLARE @PersonDossier NVARCHAR(50) = NULLIF(N'$(PERSON_DOSSIER)', N'');
    DECLARE @PersonLanguage CHAR(2) = TRY_CONVERT(CHAR(2), NULLIF(N'$(PERSON_LANGUAGE)', N''));
    DECLARE @PersonNationality NVARCHAR(80) = NULLIF(N'$(PERSON_NATIONALITY)', N'');
    DECLARE @PersonFirstName NVARCHAR(100) = NULLIF(N'$(PERSON_FIRST_NAME)', N'');
    DECLARE @PersonLastName NVARCHAR(100) = NULLIF(N'$(PERSON_LAST_NAME)', N'');
    DECLARE @BirthDate DATE = TRY_CONVERT(DATE, NULLIF(N'$(PERSON_BIRTH_DATE)', N''));
    DECLARE @TitleCode NVARCHAR(10) = NULLIF(N'$(PERSON_TITLE_CODE)', N'');

    PRINT '02 - CREATE_NATURAL_PERSON preview';
    SELECT
        @TenantId AS tenant_id,
        @PersonDossier AS dossier,
        @PersonLanguage AS language_code,
        @PersonNationality AS nationality,
        @PersonFirstName AS first_name,
        @PersonLastName AS last_name,
        @BirthDate AS birth_date,
        @TitleCode AS title_code,
        N'INFO TIP: Confirm language/title lookup values before EXECUTE_ACTION = 1.' AS info_tip;

    IF @ExecuteAction = 0
        RETURN;

    DECLARE @CreatedPersonId UNIQUEIDENTIFIER;

    EXEC person.SP_CreateNaturalPerson
        @tenant_id = @TenantId,
        @dossier = @PersonDossier,
        @language_code = @PersonLanguage,
        @nationality = @PersonNationality,
        @first_name = @PersonFirstName,
        @last_name = @PersonLastName,
        @birth_date = @BirthDate,
        @title_code = @TitleCode,
        @created_by_user_id = @CreatedByUserId,
        @created_person_id = @CreatedPersonId OUTPUT;

    SELECT
        @CreatedPersonId AS created_person_id,
        N'Created natural person. Copy this ID into party or contact templates.' AS info_tip;
END;

IF @ActionName = N'CREATE_POLICY'
BEGIN
    DECLARE @CompanyId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, NULLIF(N'$(COMPANY_ID)', N''));
    DECLARE @HandlingCompanyId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, NULLIF(N'$(HANDLING_COMPANY_ID)', N''));
    DECLARE @StartDate DATE = TRY_CONVERT(DATE, N'$(CONTRACT_START_DATE)');
    DECLARE @EndDate DATE = TRY_CONVERT(DATE, NULLIF(N'$(CONTRACT_END_DATE)', N''));

    PRINT '02 - CREATE_POLICY preview';
    SELECT
        @TenantId AS tenant_id,
        N'$(CONTRACT_NUMBER)' AS contract_number,
        N'$(CONTRACT_DOMAIN_CODE)' AS contract_domain_code,
        N'$(CONTRACT_TYPE_CODE)' AS contract_type_code,
        N'$(CONTRACT_STATUS_CODE)' AS contract_status_code,
        @StartDate AS start_date,
        @EndDate AS end_date,
        @CompanyId AS company_id,
        @HandlingCompanyId AS handling_company_id,
        N'INFO TIP: Contract number must be unique per tenant.' AS info_tip;

    PRINT '03 - Lookup validation';
    SELECT
        CASE WHEN EXISTS (SELECT 1 FROM policy.ContractDomain WHERE contract_domain_code = N'$(CONTRACT_DOMAIN_CODE)' AND is_active = 1) THEN N'OK' ELSE N'MISSING' END AS contract_domain_status,
        CASE WHEN EXISTS (SELECT 1 FROM policy.ContractType WHERE contract_type_code = N'$(CONTRACT_TYPE_CODE)' AND contract_domain_code = N'$(CONTRACT_DOMAIN_CODE)' AND is_active = 1) THEN N'OK' ELSE N'MISSING' END AS contract_type_status,
        CASE WHEN EXISTS (SELECT 1 FROM policy.ContractStatus WHERE contract_status_code = N'$(CONTRACT_STATUS_CODE)' AND is_active = 1) THEN N'OK' ELSE N'MISSING' END AS contract_status_status;

    IF @ExecuteAction = 0
        RETURN;

    DECLARE @CreatedContractId UNIQUEIDENTIFIER;

    EXEC policy.SP_CreateContract
        @tenant_id = @TenantId,
        @contract_number = N'$(CONTRACT_NUMBER)',
        @contract_domain_code = N'$(CONTRACT_DOMAIN_CODE)',
        @contract_type_code = N'$(CONTRACT_TYPE_CODE)',
        @contract_status_code = N'$(CONTRACT_STATUS_CODE)',
        @start_date = @StartDate,
        @company_id = @CompanyId,
        @handling_company_id = @HandlingCompanyId,
        @end_date = @EndDate,
        @created_by_user_id = @CreatedByUserId,
        @created_contract_id = @CreatedContractId OUTPUT;

    SELECT
        @CreatedContractId AS created_contract_id,
        N'Created policy contract. Copy this ID into version, party, object, or claim templates.' AS info_tip;
END;

IF @ActionName = N'CREATE_POLICY_VERSION'
BEGIN
    DECLARE @ContractId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, N'$(CONTRACT_ID)');
    DECLARE @VersionNo INT = TRY_CONVERT(INT, N'$(VERSION_NO)');
    DECLARE @VersionFrom DATE = TRY_CONVERT(DATE, N'$(VERSION_EFFECTIVE_FROM)');
    DECLARE @VersionTo DATE = TRY_CONVERT(DATE, NULLIF(N'$(VERSION_EFFECTIVE_TO)', N''));

    PRINT '02 - CREATE_POLICY_VERSION preview';
    SELECT
        @TenantId AS tenant_id,
        @ContractId AS contract_id,
        @VersionNo AS version_no,
        @VersionFrom AS effective_from,
        @VersionTo AS effective_to,
        N'$(CONTRACT_VERSION_STATUS_CODE)' AS contract_version_status_code,
        N'$(DURATION_TYPE_CODE)' AS duration_type_code,
        N'$(PERIODICITY_CODE)' AS periodicity_code,
        N'$(COLLECTION_METHOD_CODE)' AS collection_method_code,
        N'INFO TIP: The contract must already exist for this tenant.' AS info_tip;

    IF @ExecuteAction = 0
        RETURN;

    DECLARE @CreatedContractVersionId UNIQUEIDENTIFIER;

    EXEC policy.SP_CreateContractVersion
        @tenant_id = @TenantId,
        @contract_id = @ContractId,
        @version_no = @VersionNo,
        @effective_from = @VersionFrom,
        @contract_version_status_code = N'$(CONTRACT_VERSION_STATUS_CODE)',
        @duration_type_code = N'$(DURATION_TYPE_CODE)',
        @periodicity_code = N'$(PERIODICITY_CODE)',
        @collection_method_code = N'$(COLLECTION_METHOD_CODE)',
        @effective_to = @VersionTo,
        @created_by_user_id = @CreatedByUserId,
        @created_contract_version_id = @CreatedContractVersionId OUTPUT;

    SELECT
        @CreatedContractVersionId AS created_contract_version_id,
        N'Created policy version.' AS info_tip;
END;

IF @ActionName = N'ADD_POLICY_PARTY'
BEGIN
    DECLARE @PartyContractId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, N'$(PARTY_CONTRACT_ID)');
    DECLARE @PartyPersonId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, N'$(PARTY_PERSON_ID)');
    DECLARE @PartyIsPrimary BIT = TRY_CONVERT(BIT, N'$(PARTY_IS_PRIMARY)');

    PRINT '02 - ADD_POLICY_PARTY preview';
    SELECT
        @TenantId AS tenant_id,
        @PartyContractId AS contract_id,
        @PartyPersonId AS person_id,
        N'$(CONTRACT_PARTY_ROLE_CODE)' AS contract_party_role_code,
        @PartyIsPrimary AS is_primary,
        N'INFO TIP: Use Query Library search results to copy contract_id and person_id.' AS info_tip;

    IF @ExecuteAction = 0
        RETURN;

    EXEC policy.SP_AddContractParty
        @tenant_id = @TenantId,
        @contract_id = @PartyContractId,
        @person_id = @PartyPersonId,
        @contract_party_role_code = N'$(CONTRACT_PARTY_ROLE_CODE)',
        @is_primary = @PartyIsPrimary;

    SELECT
        @PartyContractId AS contract_id,
        @PartyPersonId AS person_id,
        N'Added policy party.' AS info_tip;
END;

IF @ActionName = N'ADD_POLICY_OBJECT'
BEGIN
    DECLARE @ObjectContractId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, N'$(OBJECT_CONTRACT_ID)');
    DECLARE @InsurableObjectId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, N'$(INSURABLE_OBJECT_ID)');
    DECLARE @ObjectIsPrimary BIT = TRY_CONVERT(BIT, N'$(OBJECT_IS_PRIMARY)');

    PRINT '02 - ADD_POLICY_OBJECT preview';
    SELECT
        @TenantId AS tenant_id,
        @ObjectContractId AS contract_id,
        @InsurableObjectId AS insurable_object_id,
        N'$(CONTRACT_OBJECT_STATUS_CODE)' AS contract_object_status_code,
        @ObjectIsPrimary AS is_primary,
        N'INFO TIP: Use Query Library or object search results to copy contract_id and insurable_object_id.' AS info_tip;

    PRINT '03 - Tenant ownership validation';
    SELECT
        CASE WHEN EXISTS (SELECT 1 FROM policy.Contract WHERE contract_id = @ObjectContractId AND tenant_id = @TenantId AND is_deleted = 0) THEN N'OK' ELSE N'MISSING' END AS contract_status,
        CASE WHEN EXISTS (SELECT 1 FROM risk.InsurableObject WHERE insurable_object_id = @InsurableObjectId AND tenant_id = @TenantId AND is_deleted = 0) THEN N'OK' ELSE N'MISSING' END AS object_status,
        CASE WHEN EXISTS (SELECT 1 FROM policy.ContractObjectStatus WHERE contract_object_status_code = N'$(CONTRACT_OBJECT_STATUS_CODE)' AND is_active = 1) THEN N'OK' ELSE N'MISSING' END AS contract_object_status,
        N'INFO TIP: All three statuses must be OK before EXECUTE_ACTION = 1.' AS info_tip;

    IF @ExecuteAction = 0
        RETURN;

    EXEC policy.SP_AddContractObject
        @tenant_id = @TenantId,
        @contract_id = @ObjectContractId,
        @insurable_object_id = @InsurableObjectId,
        @contract_object_status_code = N'$(CONTRACT_OBJECT_STATUS_CODE)',
        @is_primary = @ObjectIsPrimary;

    SELECT
        @ObjectContractId AS contract_id,
        @InsurableObjectId AS insurable_object_id,
        N'Added policy object.' AS info_tip;
END;

IF @ActionName = N'CREATE_VEHICLE_OBJECT'
BEGIN
    DECLARE @VehicleStartDate DATE = TRY_CONVERT(DATE, N'$(VEHICLE_START_DATE)');
    DECLARE @VehicleEndDate DATE = TRY_CONVERT(DATE, NULLIF(N'$(VEHICLE_END_DATE)', N''));
    DECLARE @VehicleBuildYear INT = TRY_CONVERT(INT, N'$(VEHICLE_BUILD_YEAR)');
    DECLARE @VehicleFirstCommissioningDate DATE = TRY_CONVERT(DATE, N'$(VEHICLE_FIRST_COMMISSIONING_DATE)');
    DECLARE @VehicleRegistrationDate DATE = TRY_CONVERT(DATE, N'$(VEHICLE_REGISTRATION_DATE)');
    DECLARE @VehicleIsFinanced BIT = COALESCE(TRY_CONVERT(BIT, N'$(VEHICLE_IS_FINANCED)'), 0);
    DECLARE @VehicleFinanceInstitutionId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, NULLIF(N'$(VEHICLE_FINANCE_INSTITUTION_ID)', N''));
    DECLARE @VehicleFuelTypeCode NVARCHAR(40) = NULLIF(N'$(VEHICLE_FUEL_TYPE_CODE)', N'');
    DECLARE @VehicleDriveTypeCode NVARCHAR(20) = NULLIF(N'$(VEHICLE_DRIVE_TYPE_CODE)', N'');
    DECLARE @VehicleInsuredValueExVat DECIMAL(18,2) = TRY_CONVERT(DECIMAL(18,2), NULLIF(N'$(VEHICLE_INSURED_VALUE_EX_VAT)', N''));
    DECLARE @VehicleInsuredValueIncVat DECIMAL(18,2) = TRY_CONVERT(DECIMAL(18,2), NULLIF(N'$(VEHICLE_INSURED_VALUE_INC_VAT)', N''));
    DECLARE @VehicleCatalogValueExVat DECIMAL(18,2) = TRY_CONVERT(DECIMAL(18,2), NULLIF(N'$(VEHICLE_CATALOG_VALUE_EX_VAT)', N''));
    DECLARE @VehicleCatalogValueIncVat DECIMAL(18,2) = TRY_CONVERT(DECIMAL(18,2), NULLIF(N'$(VEHICLE_CATALOG_VALUE_INC_VAT)', N''));

    PRINT '02 - CREATE_VEHICLE_OBJECT preview';
    SELECT
        @TenantId AS tenant_id,
        N'$(VEHICLE_DESCRIPTION)' AS description,
        N'$(VEHICLE_STATUS_CODE)' AS status_code,
        @VehicleStartDate AS start_date,
        @VehicleEndDate AS end_date,
        N'$(VEHICLE_TYPE_CODE)' AS vehicle_type_code,
        N'$(VEHICLE_USAGE_TYPE_CODE)' AS usage_type_code,
        N'$(VEHICLE_PLATE_TYPE_CODE)' AS plate_type_code,
        N'$(VEHICLE_BRAND)' AS brand,
        N'$(VEHICLE_MODEL)' AS model,
        N'$(VEHICLE_CHASSIS_NUMBER)' AS chassis_number,
        @VehicleBuildYear AS build_year,
        @VehicleFirstCommissioningDate AS first_commissioning_date,
        @VehicleRegistrationDate AS registration_date,
        N'$(VEHICLE_LICENSE_PLATE)' AS license_plate,
        @VehicleFuelTypeCode AS fuel_type_code,
        @VehicleDriveTypeCode AS drive_type_code,
        @VehicleIsFinanced AS is_financed,
        @VehicleFinanceInstitutionId AS finance_institution_id,
        N'INFO TIP: Create the vehicle first, then copy created_insurable_object_id into ADD_POLICY_OBJECT.' AS info_tip;

    PRINT '03 - Vehicle lookup and duplicate validation';
    SELECT
        CASE WHEN N'$(VEHICLE_STATUS_CODE)' IN (N'ACTIVE', N'INACTIVE', N'ARCHIVED', N'PENDING') THEN N'OK' ELSE N'MISSING' END AS object_status_code,
        CASE WHEN EXISTS (SELECT 1 FROM risk.VehicleType WHERE vehicle_type_code = N'$(VEHICLE_TYPE_CODE)' AND is_active = 1) THEN N'OK' ELSE N'MISSING' END AS vehicle_type_status,
        CASE WHEN EXISTS (SELECT 1 FROM risk.UsageType WHERE usage_type_code = N'$(VEHICLE_USAGE_TYPE_CODE)' AND is_active = 1) THEN N'OK' ELSE N'MISSING' END AS usage_type_status,
        CASE WHEN EXISTS (SELECT 1 FROM risk.LicensePlateType WHERE plate_type_code = N'$(VEHICLE_PLATE_TYPE_CODE)' AND is_active = 1) THEN N'OK' ELSE N'MISSING' END AS plate_type_status,
        CASE WHEN NULLIF(N'$(VEHICLE_FUEL_TYPE_CODE)', N'') IS NULL OR EXISTS (SELECT 1 FROM risk.FuelType WHERE fuel_type_code = N'$(VEHICLE_FUEL_TYPE_CODE)' AND is_active = 1) THEN N'OK' ELSE N'MISSING' END AS fuel_type_status,
        CASE WHEN NULLIF(N'$(VEHICLE_DRIVE_TYPE_CODE)', N'') IS NULL OR EXISTS (SELECT 1 FROM risk.DriveType WHERE drive_type_code = N'$(VEHICLE_DRIVE_TYPE_CODE)' AND is_active = 1) THEN N'OK' ELSE N'MISSING' END AS drive_type_status,
        CASE WHEN NOT EXISTS (
            SELECT 1
            FROM risk.InsurableObject io
            INNER JOIN risk.InsurableVehicle iv
                ON iv.insurable_object_id = io.insurable_object_id
            WHERE io.tenant_id = @TenantId
              AND io.is_deleted = 0
              AND (iv.license_plate = N'$(VEHICLE_LICENSE_PLATE)' OR iv.chassis_number = N'$(VEHICLE_CHASSIS_NUMBER)')
        ) THEN N'OK' ELSE N'DUPLICATE' END AS duplicate_vehicle_status,
        N'INFO TIP: All lookup statuses must be OK and duplicate_vehicle_status must be OK before EXECUTE_ACTION = 1.' AS info_tip;

    IF @ExecuteAction = 0
        RETURN;

    DECLARE @CreatedInsurableObjectId UNIQUEIDENTIFIER;

    EXEC risk.SP_CreateVehicleObject
        @tenant_id = @TenantId,
        @description = N'$(VEHICLE_DESCRIPTION)',
        @status_code = N'$(VEHICLE_STATUS_CODE)',
        @start_date = @VehicleStartDate,
        @end_date = @VehicleEndDate,
        @vehicle_type_code = N'$(VEHICLE_TYPE_CODE)',
        @usage_type_code = N'$(VEHICLE_USAGE_TYPE_CODE)',
        @plate_type_code = N'$(VEHICLE_PLATE_TYPE_CODE)',
        @brand = N'$(VEHICLE_BRAND)',
        @model = N'$(VEHICLE_MODEL)',
        @chassis_number = N'$(VEHICLE_CHASSIS_NUMBER)',
        @build_year = @VehicleBuildYear,
        @first_commissioning_date = @VehicleFirstCommissioningDate,
        @registration_date = @VehicleRegistrationDate,
        @license_plate = N'$(VEHICLE_LICENSE_PLATE)',
        @fuel_type_code = @VehicleFuelTypeCode,
        @drive_type_code = @VehicleDriveTypeCode,
        @finance_institution_id = @VehicleFinanceInstitutionId,
        @is_financed = @VehicleIsFinanced,
        @insured_value_ex_vat = @VehicleInsuredValueExVat,
        @insured_value_inc_vat = @VehicleInsuredValueIncVat,
        @catalog_value_ex_vat = @VehicleCatalogValueExVat,
        @catalog_value_inc_vat = @VehicleCatalogValueIncVat,
        @created_by_user_id = @CreatedByUserId,
        @created_insurable_object_id = @CreatedInsurableObjectId OUTPUT;

    SELECT
        @CreatedInsurableObjectId AS created_insurable_object_id,
        N'Created vehicle risk object. Copy this ID into ADD_POLICY_OBJECT.' AS info_tip;
END;

IF @ActionName = N'CREATE_CLAIM'
BEGIN
    DECLARE @ClaimContractId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, N'$(CLAIM_CONTRACT_ID)');
    DECLARE @ClaimHandlerPersonId UNIQUEIDENTIFIER;
    DECLARE @ClaimReportedDate DATE = TRY_CONVERT(DATE, N'$(CLAIM_REPORTED_DATE)');
    DECLARE @ClaimIncidentDate DATE = TRY_CONVERT(DATE, NULLIF(N'$(CLAIM_INCIDENT_DATE)', N''));
    DECLARE @ClaimCoverageCode NVARCHAR(80) = NULLIF(N'$(CLAIM_COVERAGE_CODE)', N'');
    DECLARE @ClaimDescription NVARCHAR(500) = NULLIF(N'$(CLAIM_DESCRIPTION)', N'');

    SELECT @ClaimHandlerPersonId = person_id
    FROM core.AppUser
    WHERE tenant_id = @TenantId
      AND email = NULLIF(N'$(CLAIM_HANDLER_USER_EMAIL)', N'')
      AND is_active = 1;

    PRINT '02 - CREATE_CLAIM preview';
    SELECT
        @TenantId AS tenant_id,
        N'$(CLAIM_NUMBER)' AS claim_number,
        @ClaimContractId AS contract_id,
        N'$(CLAIM_STATUS_CODE)' AS claim_status_code,
        @ClaimReportedDate AS reported_date,
        @ClaimCoverageCode AS coverage_code,
        @ClaimHandlerPersonId AS claims_handler_person_id,
        @ClaimIncidentDate AS incident_date,
        @ClaimDescription AS description,
        N'INFO TIP: Handler email resolves to AppUser.person_id because claim.Claim references person.Person.' AS info_tip;

    IF @ExecuteAction = 0
        RETURN;

    DECLARE @CreatedClaimId UNIQUEIDENTIFIER;

    EXEC claim.SP_CreateClaim
        @tenant_id = @TenantId,
        @claim_number = N'$(CLAIM_NUMBER)',
        @contract_id = @ClaimContractId,
        @claim_status_code = N'$(CLAIM_STATUS_CODE)',
        @reported_date = @ClaimReportedDate,
        @coverage_code = @ClaimCoverageCode,
        @claims_handler_id = @ClaimHandlerPersonId,
        @incident_date = @ClaimIncidentDate,
        @description = @ClaimDescription,
        @created_by_user_id = @CreatedByUserId,
        @created_claim_id = @CreatedClaimId OUTPUT;

    SELECT
        @CreatedClaimId AS created_claim_id,
        N'Created claim. Copy this ID into audit or claim close templates.' AS info_tip;
END;

IF @ActionName = N'CLOSE_CLAIM'
BEGIN
    DECLARE @CloseClaimId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, N'$(CLOSE_CLAIM_ID)');
    DECLARE @ClosedDate DATE = TRY_CONVERT(DATE, N'$(CLOSE_CLAIM_CLOSED_DATE)');
    DECLARE @PaidAmount DECIMAL(18,2) = TRY_CONVERT(DECIMAL(18,2), NULLIF(N'$(CLOSE_CLAIM_PAID_AMOUNT)', N''));
    DECLARE @ReservedAmount DECIMAL(18,2) = TRY_CONVERT(DECIMAL(18,2), NULLIF(N'$(CLOSE_CLAIM_RESERVED_AMOUNT)', N''));
    DECLARE @PaymentMethodCode NVARCHAR(40) = NULLIF(N'$(CLOSE_CLAIM_PAYMENT_METHOD_CODE)', N'');

    PRINT '02 - CLOSE_CLAIM preview';
    SELECT
        @TenantId AS tenant_id,
        @CloseClaimId AS claim_id,
        @ClosedDate AS closed_date,
        @PaidAmount AS paid_amount,
        @ReservedAmount AS reserved_amount,
        @PaymentMethodCode AS payment_method_code,
        @CreatedByUserId AS updated_by_user_id,
        N'INFO TIP: Paid amount greater than zero requires a valid payment method code.' AS info_tip;

    PRINT '03 - Claim close validation';
    SELECT
        CASE WHEN EXISTS (SELECT 1 FROM claim.Claim WHERE claim_id = @CloseClaimId AND tenant_id = @TenantId AND is_deleted = 0) THEN N'OK' ELSE N'MISSING' END AS claim_status,
        CASE WHEN @PaymentMethodCode IS NULL OR EXISTS (SELECT 1 FROM claim.ClaimPaymentMethod WHERE payment_method_code = @PaymentMethodCode AND is_active = 1) THEN N'OK' ELSE N'MISSING' END AS payment_method_status,
        CASE WHEN @PaidAmount IS NULL OR @PaidAmount <= 0 OR @PaymentMethodCode IS NOT NULL THEN N'OK' ELSE N'MISSING_PAYMENT_METHOD' END AS payment_rule_status,
        N'INFO TIP: Review claim row count and amounts before EXECUTE_ACTION = 1.' AS info_tip;

    IF @ExecuteAction = 0
        RETURN;

    EXEC claim.SP_CloseClaim
        @tenant_id = @TenantId,
        @claim_id = @CloseClaimId,
        @closed_date = @ClosedDate,
        @paid_amount = @PaidAmount,
        @reserved_amount = @ReservedAmount,
        @payment_method_code = @PaymentMethodCode,
        @updated_by_user_id = @CreatedByUserId;

    SELECT
        @CloseClaimId AS closed_claim_id,
        N'Closed claim. Use audit trail to review the change.' AS info_tip;
END;

IF @ActionName = N'CREATE_TASK'
BEGIN
    DECLARE @TaskRelatedEntityType NVARCHAR(60) = NULLIF(UPPER(N'$(TASK_RELATED_ENTITY_TYPE)'), N'');
    DECLARE @TaskRelatedEntityId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, NULLIF(N'$(TASK_RELATED_ENTITY_ID)', N''));
    DECLARE @TaskDescription NVARCHAR(MAX) = NULLIF(N'$(TASK_DESCRIPTION)', N'');
    DECLARE @TaskAssignedToUserId UNIQUEIDENTIFIER;
    DECLARE @TaskDueAtUtc DATETIME2(0) = TRY_CONVERT(DATETIME2(0), NULLIF(N'$(TASK_DUE_AT_UTC)', N''));

    SELECT @TaskAssignedToUserId = user_id
    FROM core.AppUser
    WHERE tenant_id = @TenantId
      AND email = NULLIF(N'$(TASK_ASSIGNED_TO_USER_EMAIL)', N'')
      AND is_active = 1;

    PRINT '02 - CREATE_TASK preview';
    SELECT
        @TenantId AS tenant_id,
        N'$(TASK_TITLE)' AS title,
        @TaskDescription AS description,
        @TaskRelatedEntityType AS related_entity_type,
        @TaskRelatedEntityId AS related_entity_id,
        @TaskAssignedToUserId AS assigned_to_user_id,
        @CreatedByUserId AS created_by_user_id,
        N'$(TASK_PRIORITY_CODE)' AS task_priority_code,
        N'$(TASK_STATUS_CODE)' AS task_status_code,
        @TaskDueAtUtc AS due_at_utc,
        N'INFO TIP: related_entity_type may be PERSON, INSTITUTION, POLICY, CLAIM, RISK_OBJECT, or DOCUMENT.' AS info_tip;

    PRINT '03 - Task lookup and ownership validation';
    SELECT
        CASE WHEN EXISTS (SELECT 1 FROM tasking.TaskPriority WHERE task_priority_code = N'$(TASK_PRIORITY_CODE)' AND is_active = 1) THEN N'OK' ELSE N'MISSING' END AS priority_status,
        CASE WHEN EXISTS (SELECT 1 FROM tasking.TaskStatus WHERE task_status_code = N'$(TASK_STATUS_CODE)' AND is_active = 1) THEN N'OK' ELSE N'MISSING' END AS task_status_status,
        CASE WHEN NULLIF(N'$(TASK_ASSIGNED_TO_USER_EMAIL)', N'') IS NULL OR @TaskAssignedToUserId IS NOT NULL THEN N'OK' ELSE N'MISSING' END AS assigned_user_status,
        CASE
            WHEN @TaskRelatedEntityType IS NULL AND @TaskRelatedEntityId IS NULL THEN N'OK'
            WHEN @TaskRelatedEntityType = N'PERSON' AND EXISTS (SELECT 1 FROM person.Person WHERE person_id = @TaskRelatedEntityId AND tenant_id = @TenantId AND is_deleted = 0) THEN N'OK'
            WHEN @TaskRelatedEntityType = N'INSTITUTION' AND EXISTS (SELECT 1 FROM institution.Institution WHERE institution_id = @TaskRelatedEntityId AND tenant_id = @TenantId AND is_deleted = 0) THEN N'OK'
            WHEN @TaskRelatedEntityType = N'POLICY' AND EXISTS (SELECT 1 FROM policy.Contract WHERE contract_id = @TaskRelatedEntityId AND tenant_id = @TenantId AND is_deleted = 0) THEN N'OK'
            WHEN @TaskRelatedEntityType = N'CLAIM' AND EXISTS (SELECT 1 FROM claim.Claim WHERE claim_id = @TaskRelatedEntityId AND tenant_id = @TenantId AND is_deleted = 0) THEN N'OK'
            WHEN @TaskRelatedEntityType = N'RISK_OBJECT' AND EXISTS (SELECT 1 FROM risk.InsurableObject WHERE insurable_object_id = @TaskRelatedEntityId AND tenant_id = @TenantId AND is_deleted = 0) THEN N'OK'
            WHEN @TaskRelatedEntityType = N'DOCUMENT' AND EXISTS (SELECT 1 FROM document.Document WHERE document_id = @TaskRelatedEntityId AND tenant_id = @TenantId AND is_deleted = 0) THEN N'OK'
            ELSE N'MISSING'
        END AS related_entity_status,
        N'INFO TIP: All statuses must be OK before EXECUTE_ACTION = 1.' AS info_tip;

    IF @ExecuteAction = 0
        RETURN;

    DECLARE @CreatedTaskId UNIQUEIDENTIFIER;

    EXEC tasking.SP_CreateTask
        @tenant_id = @TenantId,
        @title = N'$(TASK_TITLE)',
        @description = @TaskDescription,
        @related_entity_type = @TaskRelatedEntityType,
        @related_entity_id = @TaskRelatedEntityId,
        @assigned_to_user_id = @TaskAssignedToUserId,
        @created_by_user_id = @CreatedByUserId,
        @task_priority_code = N'$(TASK_PRIORITY_CODE)',
        @task_status_code = N'$(TASK_STATUS_CODE)',
        @due_at_utc = @TaskDueAtUtc,
        @created_task_id = @CreatedTaskId OUTPUT;

    SELECT
        @CreatedTaskId AS created_task_id,
        N'Created task. Copy this ID into ADD_TASK_COMMENT or ADD_TASK_REMINDER.' AS info_tip;
END;

IF @ActionName = N'ADD_TASK_COMMENT'
BEGIN
    DECLARE @TaskCommentTaskId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, NULLIF(N'$(TASK_COMMENT_TASK_ID)', N''));

    PRINT '02 - ADD_TASK_COMMENT preview';
    SELECT
        @TenantId AS tenant_id,
        @TaskCommentTaskId AS task_id,
        N'$(TASK_COMMENT_TEXT)' AS comment_text,
        @CreatedByUserId AS created_by_user_id,
        N'INFO TIP: Use Query Library or CREATE_TASK output to copy task_id.' AS info_tip;

    PRINT '03 - Task comment validation';
    SELECT
        CASE WHEN EXISTS (SELECT 1 FROM tasking.Task WHERE task_id = @TaskCommentTaskId AND tenant_id = @TenantId AND is_deleted = 0) THEN N'OK' ELSE N'MISSING' END AS task_status,
        CASE WHEN NULLIF(N'$(TASK_COMMENT_TEXT)', N'') IS NULL THEN N'MISSING' ELSE N'OK' END AS comment_text_status,
        N'INFO TIP: Both statuses must be OK before EXECUTE_ACTION = 1.' AS info_tip;

    IF @ExecuteAction = 0
        RETURN;

    DECLARE @CreatedTaskCommentId UNIQUEIDENTIFIER;

    EXEC tasking.SP_AddTaskComment
        @tenant_id = @TenantId,
        @task_id = @TaskCommentTaskId,
        @comment_text = N'$(TASK_COMMENT_TEXT)',
        @created_by_user_id = @CreatedByUserId,
        @created_task_comment_id = @CreatedTaskCommentId OUTPUT;

    SELECT
        @CreatedTaskCommentId AS created_task_comment_id,
        N'Added task comment.' AS info_tip;
END;

IF @ActionName = N'ADD_TASK_REMINDER'
BEGIN
    DECLARE @TaskReminderTaskId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, NULLIF(N'$(TASK_REMINDER_TASK_ID)', N''));
    DECLARE @TaskReminderAtUtc DATETIME2(0) = TRY_CONVERT(DATETIME2(0), NULLIF(N'$(TASK_REMINDER_AT_UTC)', N''));

    PRINT '02 - ADD_TASK_REMINDER preview';
    SELECT
        @TenantId AS tenant_id,
        @TaskReminderTaskId AS task_id,
        @TaskReminderAtUtc AS remind_at_utc,
        N'$(TASK_REMINDER_CHANNEL_CODE)' AS channel_code,
        N'INFO TIP: Reminder time must be now or future. Channel must be IN_APP, EMAIL, or SMS.' AS info_tip;

    PRINT '03 - Task reminder validation';
    SELECT
        CASE WHEN EXISTS (SELECT 1 FROM tasking.Task WHERE task_id = @TaskReminderTaskId AND tenant_id = @TenantId AND is_deleted = 0 AND task_status_code <> N'DONE') THEN N'OK' ELSE N'MISSING' END AS task_status,
        CASE WHEN @TaskReminderAtUtc IS NOT NULL AND @TaskReminderAtUtc >= DATEADD(MINUTE, -5, SYSUTCDATETIME()) THEN N'OK' ELSE N'PAST_OR_MISSING' END AS reminder_time_status,
        CASE WHEN N'$(TASK_REMINDER_CHANNEL_CODE)' IN (N'IN_APP', N'EMAIL', N'SMS') THEN N'OK' ELSE N'MISSING' END AS channel_status,
        N'INFO TIP: All statuses must be OK before EXECUTE_ACTION = 1.' AS info_tip;

    IF @ExecuteAction = 0
        RETURN;

    DECLARE @CreatedTaskReminderId UNIQUEIDENTIFIER;

    EXEC tasking.SP_AddTaskReminder
        @tenant_id = @TenantId,
        @task_id = @TaskReminderTaskId,
        @remind_at_utc = @TaskReminderAtUtc,
        @channel_code = N'$(TASK_REMINDER_CHANNEL_CODE)',
        @created_task_reminder_id = @CreatedTaskReminderId OUTPUT;

    SELECT
        @CreatedTaskReminderId AS created_task_reminder_id,
        N'Added task reminder.' AS info_tip;
END;

-- =============================================================================
-- CREATE_SETTLEMENT
-- Creates a settlement offer (DRAFT) for an open tenant-owned claim.
-- =============================================================================
IF @ActionName = N'CREATE_SETTLEMENT'
BEGIN
    DECLARE @SettlementClaimId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, NULLIF(N'$(SETTLEMENT_CLAIM_ID)', N''));
    DECLARE @OfferAmount DECIMAL(18,2) = TRY_CONVERT(DECIMAL(18,2), N'$(SETTLEMENT_OFFER_AMOUNT)');
    DECLARE @SettlementIban NVARCHAR(34) = NULLIF(N'$(SETTLEMENT_IBAN)', N'');
    DECLARE @SettlementNotes NVARCHAR(500) = NULLIF(N'$(SETTLEMENT_NOTES)', N'');

    PRINT '02 - CREATE_SETTLEMENT preview';
    SELECT
        @TenantId AS tenant_id,
        @SettlementClaimId AS claim_id,
        @OfferAmount AS offer_amount_eur,
        @SettlementIban AS iban,
        @SettlementNotes AS notes,
        @CreatedByUserId AS created_by_user_id,
        N'INFO TIP: claim must be OPEN or UNDER_INVESTIGATION. Offer amount must be > 0.' AS info_tip;

    PRINT '03 - Claim ownership validation';
    SELECT
        CASE WHEN @SettlementClaimId IS NULL THEN N'MISSING_ID'
             WHEN EXISTS (SELECT 1 FROM claim.Claim WHERE claim_id = @SettlementClaimId AND tenant_id = @TenantId AND is_deleted = 0) THEN N'OK'
             ELSE N'MISSING' END AS claim_status,
        CASE WHEN @OfferAmount > 0 THEN N'OK' ELSE N'INVALID' END AS offer_amount_status,
        N'INFO TIP: Both statuses must be OK before EXECUTE_ACTION = 1.' AS info_tip;

    IF @ExecuteAction = 0
        RETURN;

    -- SP returns a result set on success or an error_code row on rejection.
    -- Capture and display it so the operator can see the outcome immediately.
    EXEC claim.SP_CreateSettlement
        @tenant_id        = @TenantId,
        @claim_id         = @SettlementClaimId,
        @offer_amount_eur = @OfferAmount,
        @iban             = @SettlementIban,
        @notes            = @SettlementNotes,
        @created_by       = @CreatedByUserId,
        @dry_run          = 0;
    -- SP output: settlement_id + status on success, error_code on rejection.
    -- Review the result grid above before proceeding.
END;

-- =============================================================================
-- APPROVE_SETTLEMENT
-- Approves a settlement offer and transitions claim to PENDING_PAYMENT.
-- =============================================================================
IF @ActionName = N'APPROVE_SETTLEMENT'
BEGIN
    DECLARE @ApproveSettlementId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, NULLIF(N'$(APPROVE_SETTLEMENT_ID)', N''));
    DECLARE @ApproveSettlementClaimId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, NULLIF(N'$(APPROVE_SETTLEMENT_CLAIM_ID)', N''));
    DECLARE @AgreedAmount DECIMAL(18,2) = TRY_CONVERT(DECIMAL(18,2), NULLIF(N'$(APPROVE_AGREED_AMOUNT)', N''));
    DECLARE @PaymentReference NVARCHAR(50) = NULLIF(N'$(APPROVE_PAYMENT_REFERENCE)', N'');
    DECLARE @ApprovePaymentMethodCode NVARCHAR(40) = NULLIF(N'$(APPROVE_PAYMENT_METHOD_CODE)', N'');

    PRINT '02 - APPROVE_SETTLEMENT preview';
    SELECT
        @TenantId AS tenant_id,
        @ApproveSettlementId AS settlement_id,
        @ApproveSettlementClaimId AS claim_id,
        @AgreedAmount AS agreed_amount_eur,
        @PaymentReference AS payment_reference,
        @ApprovePaymentMethodCode AS payment_method_code,
        @CreatedByUserId AS approved_by_user_id,
        N'INFO TIP: Settlement must be in DRAFT status. Use BANK_TRANSFER, CASH, or CHECK.' AS info_tip;

    PRINT '03 - Settlement ownership validation';
    SELECT
        CASE WHEN @ApproveSettlementId IS NULL THEN N'MISSING_ID'
             WHEN EXISTS (
                SELECT 1 FROM claim.ClaimSettlement cs
                INNER JOIN claim.Claim c ON c.claim_id = cs.claim_id
                WHERE cs.settlement_id = @ApproveSettlementId
                  AND c.tenant_id = @TenantId
                  AND c.is_deleted = 0
             ) THEN N'OK' ELSE N'MISSING' END AS settlement_status,
        N'INFO TIP: settlement_status must be OK before EXECUTE_ACTION = 1.' AS info_tip;

    IF @ExecuteAction = 0
        RETURN;

    EXEC claim.SP_ApproveSettlement
        @tenant_id           = @TenantId,
        @settlement_id       = @ApproveSettlementId,
        @claim_id            = @ApproveSettlementClaimId,
        @agreed_amount_eur   = @AgreedAmount,
        @payment_reference   = @PaymentReference,
        @payment_method_code = @ApprovePaymentMethodCode,
        @approved_by         = @CreatedByUserId;

    SELECT N'Settlement approved. Claim status transitions to PENDING_PAYMENT.' AS info_tip;
END;

-- =============================================================================
-- UPDATE_CLAIM_RESERVE
-- Updates the reserve amount for a tenant-owned claim.
-- =============================================================================
IF @ActionName = N'UPDATE_CLAIM_RESERVE'
BEGIN
    DECLARE @ReserveClaimId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, NULLIF(N'$(RESERVE_CLAIM_ID)', N''));
    DECLARE @NewReserve DECIMAL(18,2) = TRY_CONVERT(DECIMAL(18,2), N'$(RESERVE_NEW_AMOUNT)');
    DECLARE @ReserveReasonCode NVARCHAR(40) = COALESCE(NULLIF(N'$(RESERVE_REASON_CODE)', N''), N'MANUAL');
    DECLARE @ReserveNotes NVARCHAR(500) = NULLIF(N'$(RESERVE_NOTES)', N'');

    PRINT '02 - UPDATE_CLAIM_RESERVE preview';
    SELECT
        @TenantId AS tenant_id,
        @ReserveClaimId AS claim_id,
        @NewReserve AS new_reserve_eur,
        @ReserveReasonCode AS reason_code,
        @ReserveNotes AS notes,
        @CreatedByUserId AS changed_by_user_id,
        N'INFO TIP: New reserve replaces old reserve. Reason codes: MANUAL, REASSESSMENT, EXPERT_VALUATION, COURT_ORDER.' AS info_tip;

    PRINT '03 - Claim ownership validation';
    SELECT
        CASE WHEN @ReserveClaimId IS NULL THEN N'MISSING_ID'
             WHEN EXISTS (SELECT 1 FROM claim.Claim WHERE claim_id = @ReserveClaimId AND tenant_id = @TenantId AND is_deleted = 0) THEN N'OK'
             ELSE N'MISSING' END AS claim_status,
        CASE WHEN @NewReserve >= 0 THEN N'OK' ELSE N'INVALID' END AS reserve_amount_status,
        N'INFO TIP: Both statuses must be OK before EXECUTE_ACTION = 1.' AS info_tip;

    IF @ExecuteAction = 0
        RETURN;

    EXEC claim.SP_UpdateClaimReserve
        @tenant_id   = @TenantId,
        @claim_id    = @ReserveClaimId,
        @new_reserve = @NewReserve,
        @reason_code = @ReserveReasonCode,
        @notes       = @ReserveNotes,
        @changed_by  = @CreatedByUserId;

    SELECT
        @ReserveClaimId AS claim_id,
        @NewReserve AS new_reserve_eur,
        N'Reserve updated. Check audit log for change history.' AS info_tip;
END;

-- =============================================================================
-- CREATE_LEGAL_PERSON
-- Creates a legal entity (company/organisation) customer root record.
-- =============================================================================
IF @ActionName = N'CREATE_LEGAL_PERSON'
BEGIN
    DECLARE @LegalDossier NVARCHAR(50) = NULLIF(N'$(LEGAL_DOSSIER)', N'');
    DECLARE @LegalLanguage NVARCHAR(10) = NULLIF(N'$(LEGAL_LANGUAGE)', N'');
    DECLARE @LegalName NVARCHAR(200) = NULLIF(N'$(LEGAL_NAME)', N'');
    DECLARE @LegalForm NVARCHAR(120) = NULLIF(N'$(LEGAL_FORM)', N'');
    DECLARE @LegalVatNumber NVARCHAR(30) = NULLIF(N'$(LEGAL_VAT_NUMBER)', N'');
    DECLARE @LegalKboNumber NVARCHAR(12) = NULLIF(N'$(LEGAL_KBO_NUMBER)', N'');
    DECLARE @LegalNationality NVARCHAR(80) = NULLIF(N'$(LEGAL_NATIONALITY)', N'');
    DECLARE @LegalIncorporationDate DATE = TRY_CONVERT(DATE, NULLIF(N'$(LEGAL_INCORPORATION_DATE)', N''));

    PRINT '02 - CREATE_LEGAL_PERSON preview';
    SELECT
        @TenantId AS tenant_id,
        @LegalDossier AS dossier,
        @LegalLanguage AS language_code,
        @LegalName AS legal_name,
        @LegalForm AS legal_form,
        @LegalVatNumber AS vat_number,
        @LegalKboNumber AS kbo_number,
        @LegalNationality AS nationality,
        @LegalIncorporationDate AS incorporation_date,
        N'INFO TIP: legal_form examples: NV, BV, VZW, BVBA, SA, SPRL, ASBL.' AS info_tip;

    IF @ExecuteAction = 0
        RETURN;

    DECLARE @CreatedLegalPersonId UNIQUEIDENTIFIER;

    EXEC person.SP_CreateLegalPerson
        @tenant_id          = @TenantId,
        @dossier            = @LegalDossier,
        @language_code      = @LegalLanguage,
        @legal_name         = @LegalName,
        @legal_form         = @LegalForm,
        @vat_number         = @LegalVatNumber,
        @kbo_number         = @LegalKboNumber,
        @nationality        = @LegalNationality,
        @incorporation_date = @LegalIncorporationDate,
        @created_by_user_id = @CreatedByUserId,
        @created_person_id  = @CreatedLegalPersonId OUTPUT;

    SELECT
        @CreatedLegalPersonId AS created_person_id,
        N'Created legal person. Copy this ID into ADD_POLICY_PARTY as person_id.' AS info_tip;
END;

-- =============================================================================
-- REGISTER_EXPORT_JOB
-- Registers a new bulk export job (FSMA, PORTFOLIO, CLAIMS, LEDGER, CUSTOM).
-- =============================================================================
IF @ActionName = N'REGISTER_EXPORT_JOB'
BEGIN
    DECLARE @ExportTypeCode NVARCHAR(40) = UPPER(NULLIF(N'$(EXPORT_TYPE_CODE)', N''));
    DECLARE @ExportPeriodStart DATE = TRY_CONVERT(DATE, NULLIF(N'$(EXPORT_PERIOD_START)', N''));
    DECLARE @ExportPeriodEnd DATE = TRY_CONVERT(DATE, NULLIF(N'$(EXPORT_PERIOD_END)', N''));

    PRINT '02 - REGISTER_EXPORT_JOB preview';
    SELECT
        @TenantId AS tenant_id,
        @ExportTypeCode AS export_type_code,
        @ExportPeriodStart AS period_start,
        @ExportPeriodEnd AS period_end,
        N'INFO TIP: ExportTypeCodes: FSMA, PORTFOLIO, CLAIMS, LEDGER, CUSTOM. Job starts as PENDING.' AS info_tip;

    PRINT '03 - Export type validation';
    SELECT
        CASE WHEN @ExportTypeCode IN (N'FSMA', N'PORTFOLIO', N'CLAIMS', N'LEDGER', N'CUSTOM') THEN N'OK' ELSE N'INVALID' END AS export_type_status,
        CASE WHEN @ExportPeriodEnd IS NULL OR @ExportPeriodStart IS NULL OR @ExportPeriodEnd >= @ExportPeriodStart THEN N'OK' ELSE N'INVALID_PERIOD' END AS period_status,
        N'INFO TIP: Both statuses must be OK before EXECUTE_ACTION = 1.' AS info_tip;

    IF @ExecuteAction = 0
        RETURN;

    DECLARE @ExportJobRows TABLE (
        JobId          UNIQUEIDENTIFIER,
        TenantId       UNIQUEIDENTIFIER,
        ExportTypeCode NVARCHAR(40),
        StatusCode     NVARCHAR(20),
        CreatedAtUtc   DATETIME2(0)
    );

    INSERT INTO @ExportJobRows
    EXEC import.SP_CreateExportJob
        @tenant_id              = @TenantId,
        @export_type_code       = @ExportTypeCode,
        @period_start           = @ExportPeriodStart,
        @period_end             = @ExportPeriodEnd,
        @requested_by_user_id   = @CreatedByUserId;

    SELECT
        JobId AS created_job_id,
        ExportTypeCode AS export_type_code,
        StatusCode AS status_code,
        CreatedAtUtc AS created_at_utc,
        N'Export job registered. Copy job_id into COMPLETE_EXPORT_JOB after the export runs.' AS info_tip
    FROM @ExportJobRows;
END;

-- =============================================================================
-- COMPLETE_EXPORT_JOB
-- Marks an export job as SUCCESS, FAILED, or CANCELLED with row count.
-- =============================================================================
IF @ActionName = N'COMPLETE_EXPORT_JOB'
BEGIN
    DECLARE @CompleteJobId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, NULLIF(N'$(COMPLETE_JOB_ID)', N''));
    DECLARE @CompleteStatusCode NVARCHAR(20) = UPPER(NULLIF(N'$(COMPLETE_STATUS_CODE)', N''));
    DECLARE @CompleteRowCount INT = TRY_CONVERT(INT, NULLIF(N'$(COMPLETE_ROW_COUNT)', N''));
    DECLARE @CompleteErrorMessage NVARCHAR(1000) = NULLIF(N'$(COMPLETE_ERROR_MESSAGE)', N'');

    PRINT '02 - COMPLETE_EXPORT_JOB preview';
    SELECT
        @TenantId AS tenant_id,
        @CompleteJobId AS job_id,
        @CompleteStatusCode AS status_code,
        @CompleteRowCount AS row_count,
        @CompleteErrorMessage AS error_message,
        N'INFO TIP: StatusCodes: SUCCESS, FAILED, CANCELLED. error_message required for FAILED.' AS info_tip;

    PRINT '03 - Export job ownership validation';
    SELECT
        CASE WHEN @CompleteJobId IS NULL THEN N'MISSING_ID'
             WHEN EXISTS (SELECT 1 FROM import.ExportJob WHERE job_id = @CompleteJobId AND tenant_id = @TenantId) THEN N'OK'
             ELSE N'MISSING' END AS job_status,
        CASE WHEN @CompleteStatusCode IN (N'SUCCESS', N'FAILED', N'CANCELLED') THEN N'OK' ELSE N'INVALID' END AS status_code_status,
        CASE WHEN @CompleteStatusCode <> N'FAILED' OR @CompleteErrorMessage IS NOT NULL THEN N'OK' ELSE N'ERROR_MESSAGE_REQUIRED' END AS error_message_status,
        N'INFO TIP: All statuses must be OK before EXECUTE_ACTION = 1.' AS info_tip;

    IF @ExecuteAction = 0
        RETURN;

    EXEC import.SP_CompleteExportJob
        @job_id        = @CompleteJobId,
        @tenant_id     = @TenantId,
        @status_code   = @CompleteStatusCode,
        @row_count     = @CompleteRowCount,
        @error_message = @CompleteErrorMessage;

    SELECT
        @CompleteJobId AS job_id,
        @CompleteStatusCode AS final_status,
        N'Export job updated. Use GetExportJobStatus to verify final state.' AS info_tip;
END;

-- =============================================================================
-- CREATE_REAL_ESTATE_OBJECT
-- Creates a real estate (fire/property) risk object in risk.InsurableRealEstate.
-- Result: insurable_object_id — use as INSURABLE_OBJECT_ID for ADD_POLICY_OBJECT.
-- =============================================================================
IF @ActionName = N'CREATE_REAL_ESTATE_OBJECT'
BEGIN
    DECLARE @PropAddress NVARCHAR(500) = NULLIF(N'$(PROPERTY_ADDRESS)', N'');
    DECLARE @PropTypeCode NVARCHAR(80) = COALESCE(NULLIF(N'$(PROPERTY_TYPE_CODE)', N''), N'HOUSE');
    DECLARE @PropArea DECIMAL(10,2) = TRY_CONVERT(DECIMAL(10,2), NULLIF(N'$(PROPERTY_CONSTRUCTION_AREA)', N''));
    DECLARE @PropYear INT = TRY_CONVERT(INT, NULLIF(N'$(PROPERTY_CONSTRUCTION_YEAR)', N''));
    DECLARE @PropInsuredValue DECIMAL(18,2) = TRY_CONVERT(DECIMAL(18,2), NULLIF(N'$(PROPERTY_INSURED_VALUE)', N''));
    DECLARE @PropCurrencyCode NCHAR(3) = COALESCE(NULLIF(N'$(PROPERTY_CURRENCY_CODE)', N''), N'EUR');

    PRINT '02 - CREATE_REAL_ESTATE_OBJECT preview';
    SELECT
        @TenantId AS tenant_id,
        @PropAddress AS property_address,
        @PropTypeCode AS property_type_code,
        @PropArea AS construction_area,
        @PropYear AS construction_year,
        @PropInsuredValue AS insured_value,
        @PropCurrencyCode AS currency_code,
        N'INFO TIP: PropertyTypeCodes: HOUSE, APARTMENT, OFFICE, WAREHOUSE, COMMERCIAL. insured_value is informational; set tariff via UpsertTariffRate.' AS info_tip;

    PRINT '03 - Input validation';
    SELECT
        CASE WHEN @PropAddress IS NOT NULL THEN N'OK' ELSE N'WARN: property_address is empty' END AS address_status,
        CASE WHEN @PropTypeCode IN (N'HOUSE', N'APARTMENT', N'OFFICE', N'WAREHOUSE', N'COMMERCIAL') THEN N'OK' ELSE N'WARN: unexpected property_type_code' END AS type_status,
        N'INFO TIP: Proceed with EXECUTE_ACTION = 1 when inputs are correct.' AS info_tip;

    IF @ExecuteAction = 0
        RETURN;

    DECLARE @PropObjectId UNIQUEIDENTIFIER;

    EXEC risk.sp_CreateProperty
        @tenant_id           = @TenantId,
        @property_address    = @PropAddress,
        @property_type_code  = @PropTypeCode,
        @construction_area   = @PropArea,
        @construction_year   = @PropYear,
        @insured_value       = @PropInsuredValue,
        @currency_code       = @PropCurrencyCode,
        @created_by_user_id  = @CreatedByUserId,
        @insurable_object_id = @PropObjectId OUTPUT;

    SELECT
        @PropObjectId AS insurable_object_id,
        @PropTypeCode AS property_type_code,
        @PropAddress AS property_address,
        N'Real estate object created. Copy insurable_object_id into INSURABLE_OBJECT_ID for ADD_POLICY_OBJECT.' AS info_tip;
END;

-- =============================================================================
-- ADD_COVERAGE_ITEM
-- Adds a coverage line item to a policy contract.
-- =============================================================================
IF @ActionName = N'ADD_COVERAGE_ITEM'
BEGIN
    DECLARE @CovContractId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, NULLIF(N'$(COVERAGE_CONTRACT_ID)', N''));
    DECLARE @CovTypeCode NVARCHAR(80) = UPPER(NULLIF(N'$(COVERAGE_TYPE_CODE)', N''));
    DECLARE @CovLimit DECIMAL(18,2) = TRY_CONVERT(DECIMAL(18,2), NULLIF(N'$(COVERAGE_LIMIT)', N''));
    DECLARE @CovDeductible DECIMAL(18,2) = TRY_CONVERT(DECIMAL(18,2), NULLIF(N'$(COVERAGE_DEDUCTIBLE)', N''));
    DECLARE @CovCurrencyCode NCHAR(3) = COALESCE(NULLIF(N'$(COVERAGE_CURRENCY_CODE)', N''), N'EUR');

    PRINT '02 - ADD_COVERAGE_ITEM preview';
    SELECT
        @CovContractId AS contract_id,
        @CovTypeCode AS coverage_type_code,
        @CovLimit AS coverage_limit,
        @CovDeductible AS deductible,
        @CovCurrencyCode AS currency_code,
        N'INFO TIP: coverage_limit > 0 required. deductible is optional.' AS info_tip;

    PRINT '03 - Coverage type and contract validation';
    SELECT
        CASE WHEN @CovContractId IS NULL THEN N'MISSING' WHEN EXISTS (SELECT 1 FROM policy.Contract WHERE contract_id = @CovContractId AND tenant_id = @TenantId) THEN N'OK' ELSE N'NOT_FOUND' END AS contract_status,
        CASE WHEN @CovTypeCode IS NULL THEN N'MISSING' WHEN EXISTS (SELECT 1 FROM coverage.CoverageType WHERE coverage_type_code = @CovTypeCode AND is_active = 1) THEN N'OK' ELSE N'UNKNOWN_TYPE' END AS coverage_type_status,
        CASE WHEN ISNULL(@CovLimit, 0) > 0 THEN N'OK' ELSE N'INVALID: must be > 0' END AS limit_status,
        N'INFO TIP: All statuses must be OK before EXECUTE_ACTION = 1.' AS info_tip;

    IF @ExecuteAction = 0
        RETURN;

    DECLARE @CovItemId UNIQUEIDENTIFIER;

    EXEC coverage.sp_AddCoverageItem
        @tenant_id          = @TenantId,
        @contract_id        = @CovContractId,
        @coverage_type_code = @CovTypeCode,
        @coverage_limit     = @CovLimit,
        @deductible         = @CovDeductible,
        @currency_code      = @CovCurrencyCode,
        @coverage_item_id   = @CovItemId OUTPUT;

    SELECT
        @CovItemId AS coverage_item_id,
        @CovContractId AS contract_id,
        @CovTypeCode AS coverage_type_code,
        @CovLimit AS coverage_limit,
        @CovCurrencyCode AS currency_code,
        N'Coverage item added. Use CalculatePremium MCP tool or SP_CalculatePremium to recalculate premium.' AS info_tip;
END;

-- =============================================================================
-- ATTACH_DOCUMENT
-- Registers a document and links it to a policy, claim, person, or risk object.
-- owner_entity_type: POLICY | CLAIM | PERSON | INSTITUTION | RISK_OBJECT
-- =============================================================================
IF @ActionName = N'ATTACH_DOCUMENT'
BEGIN
    DECLARE @DocTypeCode NVARCHAR(80) = NULLIF(N'$(DOC_DOCUMENT_TYPE_CODE)', N'');
    DECLARE @DocFileName NVARCHAR(260) = NULLIF(N'$(DOC_FILE_NAME)', N'');
    DECLARE @DocMimeType NVARCHAR(120) = COALESCE(NULLIF(N'$(DOC_MIME_TYPE)', N''), N'application/pdf');
    DECLARE @DocSizeBytes BIGINT = TRY_CONVERT(BIGINT, NULLIF(N'$(DOC_FILE_SIZE_BYTES)', N''));
    DECLARE @DocStorageUri NVARCHAR(500) = NULLIF(N'$(DOC_STORAGE_URI)', N'');
    DECLARE @DocOwnerType NVARCHAR(60) = UPPER(COALESCE(NULLIF(N'$(DOC_OWNER_ENTITY_TYPE)', N''), N'POLICY'));
    DECLARE @DocOwnerEntityId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, NULLIF(N'$(DOC_OWNER_ENTITY_ID)', N''));

    PRINT '02 - ATTACH_DOCUMENT preview';
    SELECT
        @DocFileName AS file_name,
        @DocTypeCode AS document_type_code,
        @DocMimeType AS mime_type,
        @DocOwnerType AS owner_entity_type,
        @DocOwnerEntityId AS owner_entity_id,
        @DocStorageUri AS storage_uri,
        N'INFO TIP: owner_entity_type: POLICY, CLAIM, PERSON, INSTITUTION, RISK_OBJECT. storage_uri can be empty (placeholder assigned).' AS info_tip;

    PRINT '03 - Input validation';
    SELECT
        CASE WHEN @DocFileName IS NOT NULL THEN N'OK' ELSE N'MISSING' END AS file_name_status,
        CASE WHEN @DocTypeCode IS NOT NULL THEN N'OK' ELSE N'MISSING' END AS document_type_status,
        CASE WHEN @DocOwnerType IN (N'PERSON', N'INSTITUTION', N'POLICY', N'CLAIM', N'RISK_OBJECT') THEN N'OK' ELSE N'INVALID_TYPE' END AS owner_type_status,
        CASE WHEN @DocOwnerEntityId IS NOT NULL THEN N'OK' ELSE N'MISSING' END AS owner_entity_id_status,
        N'INFO TIP: All statuses must be OK before EXECUTE_ACTION = 1.' AS info_tip;

    IF @ExecuteAction = 0
        RETURN;

    DECLARE @DocId UNIQUEIDENTIFIER;

    EXEC document.sp_CreateDocument
        @tenant_id           = @TenantId,
        @document_type_code  = @DocTypeCode,
        @file_name           = @DocFileName,
        @mime_type           = @DocMimeType,
        @file_size_bytes     = @DocSizeBytes,
        @storage_uri         = @DocStorageUri,
        @uploaded_by_user_id = @CreatedByUserId,
        @owner_entity_type   = @DocOwnerType,
        @owner_entity_id     = @DocOwnerEntityId,
        @document_id         = @DocId OUTPUT;

    SELECT
        @DocId AS document_id,
        @DocFileName AS file_name,
        @DocTypeCode AS document_type_code,
        @DocOwnerType AS owner_entity_type,
        @DocOwnerEntityId AS owner_entity_id,
        N'Document registered. Update storage_uri later via direct update when the file has been uploaded to Azure Blob.' AS info_tip;
END;

-- =============================================================================
-- RECORD_PAYMENT
-- Records a payment against a finance.Invoice.
-- Auto-marks the invoice PAID when total payments >= invoice amount.
-- =============================================================================
IF @ActionName = N'RECORD_PAYMENT'
BEGIN
    DECLARE @PayInvoiceId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, NULLIF(N'$(PAYMENT_INVOICE_ID)', N''));
    DECLARE @PayDate DATE = TRY_CONVERT(DATE, NULLIF(N'$(PAYMENT_DATE)', N''));
    DECLARE @PayAmount DECIMAL(18,2) = TRY_CONVERT(DECIMAL(18,2), NULLIF(N'$(PAYMENT_AMOUNT)', N''));
    DECLARE @PayMethodCode NVARCHAR(32) = COALESCE(NULLIF(N'$(PAYMENT_METHOD_CODE)', N''), N'BANK_TRANSFER');

    PRINT '02 - RECORD_PAYMENT preview';
    SELECT
        @PayInvoiceId AS invoice_id,
        @PayDate AS payment_date,
        @PayAmount AS amount,
        @PayMethodCode AS payment_method_code,
        N'INFO TIP: PaymentMethodCodes: BANK_TRANSFER, DIRECT_DEBIT, CASH, CARD. Invoice auto-marked PAID when sum of payments >= invoice total.' AS info_tip;

    PRINT '03 - Invoice and amount validation';
    SELECT
        CASE WHEN @PayInvoiceId IS NULL THEN N'MISSING'
             WHEN EXISTS (SELECT 1 FROM finance.Invoices WHERE InvoiceId = @PayInvoiceId AND TenantId = @TenantId) THEN N'OK'
             ELSE N'NOT_FOUND' END AS invoice_status,
        CASE WHEN ISNULL(@PayAmount, 0) > 0 THEN N'OK' ELSE N'INVALID: must be > 0' END AS amount_status,
        CASE WHEN @PayDate IS NOT NULL THEN N'OK' ELSE N'MISSING' END AS payment_date_status,
        CASE WHEN @PayMethodCode IN (N'BANK_TRANSFER', N'DIRECT_DEBIT', N'CASH', N'CARD') THEN N'OK' ELSE N'UNKNOWN_METHOD' END AS method_status,
        N'INFO TIP: All statuses must be OK before EXECUTE_ACTION = 1.' AS info_tip;

    IF @ExecuteAction = 0
        RETURN;

    DECLARE @PayId UNIQUEIDENTIFIER;

    EXEC finance.sp_RecordPayment
        @tenant_id          = @TenantId,
        @invoice_id         = @PayInvoiceId,
        @payment_date       = @PayDate,
        @amount             = @PayAmount,
        @payment_method_code= @PayMethodCode,
        @payment_id         = @PayId OUTPUT;

    DECLARE @InvoiceBalance TABLE (StatusCode NVARCHAR(20), Amount DECIMAL(18,2), PaidTotal DECIMAL(18,2));
    INSERT INTO @InvoiceBalance
    SELECT
        i.StatusCode,
        i.Amount,
        ISNULL(SUM(p.Amount), 0)
    FROM finance.Invoices i
    LEFT JOIN finance.Payments p ON p.InvoiceId = i.InvoiceId
    WHERE i.InvoiceId = @PayInvoiceId
    GROUP BY i.StatusCode, i.Amount;

    SELECT
        @PayId AS payment_id,
        @PayInvoiceId AS invoice_id,
        @PayAmount AS recorded_amount,
        b.StatusCode AS invoice_status,
        b.Amount AS invoice_total,
        b.PaidTotal AS total_paid,
        b.Amount - b.PaidTotal AS remaining_balance,
        N'Payment recorded.' AS info_tip
    FROM @InvoiceBalance b;
END;

-- =============================================================================
-- CREATE_PAYMENT_PLAN
-- Creates an installment payment plan with auto-generated schedule.
-- =============================================================================
IF @ActionName = N'CREATE_PAYMENT_PLAN'
BEGIN
    DECLARE @PlanContractId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, NULLIF(N'$(PLAN_CONTRACT_ID)', N''));
    DECLARE @PlanInstallmentCount SMALLINT = TRY_CONVERT(SMALLINT, NULLIF(N'$(PLAN_INSTALLMENT_COUNT)', N''));
    DECLARE @PlanFirstDueDate DATE = TRY_CONVERT(DATE, NULLIF(N'$(PLAN_FIRST_DUE_DATE)', N''));
    DECLARE @PlanTotalAmount DECIMAL(18,2) = TRY_CONVERT(DECIMAL(18,2), NULLIF(N'$(PLAN_TOTAL_AMOUNT)', N''));
    DECLARE @PlanCurrencyCode NCHAR(3) = COALESCE(NULLIF(N'$(PLAN_CURRENCY_CODE)', N''), N'EUR');

    PRINT '02 - CREATE_PAYMENT_PLAN preview';
    SELECT
        @PlanContractId AS contract_id,
        @PlanInstallmentCount AS installment_count,
        @PlanFirstDueDate AS first_due_date,
        @PlanTotalAmount AS total_amount,
        @PlanCurrencyCode AS currency_code,
        ROUND(ISNULL(@PlanTotalAmount, 0) / ISNULL(NULLIF(@PlanInstallmentCount, 0), 1), 2) AS installment_amount_preview,
        N'INFO TIP: Installments are auto-scheduled monthly from first_due_date. installment_count >= 1 required.' AS info_tip;

    PRINT '03 - Contract and amount validation';
    SELECT
        CASE WHEN @PlanContractId IS NULL THEN N'MISSING'
             WHEN EXISTS (SELECT 1 FROM policy.Contract WHERE contract_id = @PlanContractId AND tenant_id = @TenantId) THEN N'OK'
             ELSE N'NOT_FOUND' END AS contract_status,
        CASE WHEN ISNULL(@PlanInstallmentCount, 0) >= 1 THEN N'OK' ELSE N'INVALID: must be >= 1' END AS installment_count_status,
        CASE WHEN @PlanFirstDueDate IS NOT NULL THEN N'OK' ELSE N'MISSING' END AS first_due_date_status,
        CASE WHEN ISNULL(@PlanTotalAmount, 0) > 0 THEN N'OK' ELSE N'INVALID: must be > 0' END AS total_amount_status,
        N'INFO TIP: All statuses must be OK before EXECUTE_ACTION = 1.' AS info_tip;

    IF @ExecuteAction = 0
        RETURN;

    DECLARE @PlanId UNIQUEIDENTIFIER;

    EXEC finance.sp_CreatePaymentPlan
        @tenant_id          = @TenantId,
        @contract_id        = @PlanContractId,
        @installment_count  = @PlanInstallmentCount,
        @first_due_date     = @PlanFirstDueDate,
        @total_amount       = @PlanTotalAmount,
        @currency_code      = @PlanCurrencyCode,
        @plan_id            = @PlanId OUTPUT;

    SELECT
        @PlanId AS payment_plan_id,
        @PlanContractId AS contract_id,
        @PlanInstallmentCount AS installment_count,
        @PlanTotalAmount AS total_amount,
        @PlanCurrencyCode AS currency_code,
        ROUND(@PlanTotalAmount / @PlanInstallmentCount, 2) AS installment_amount,
        @PlanFirstDueDate AS first_due_date,
        N'Payment plan created with instalment schedule. Review via finance.PaymentPlanItems.' AS info_tip;
END;
GO
