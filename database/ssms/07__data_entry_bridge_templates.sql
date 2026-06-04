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
    N'CREATE_CLAIM',
    N'CLOSE_CLAIM'
)
    THROW 52302, 'Unknown ACTION_NAME.', 1;

PRINT '01B - Available bridge actions';
SELECT
    action_name,
    procedure_name,
    default_mode,
    info_tip
FROM (VALUES
    (N'CREATE_NATURAL_PERSON', N'person.SP_CreateNaturalPerson', N'PREVIEW_FIRST', N'Creates the customer root and natural-person detail row.'),
    (N'CREATE_POLICY', N'policy.SP_CreateContract', N'PREVIEW_FIRST', N'Creates the policy contract shell after lookup checks.'),
    (N'CREATE_POLICY_VERSION', N'policy.SP_CreateContractVersion', N'PREVIEW_FIRST', N'Adds a version to an existing tenant-owned policy.'),
    (N'ADD_POLICY_PARTY', N'policy.SP_AddContractParty', N'PREVIEW_FIRST', N'Links a tenant-owned person to a tenant-owned policy.'),
    (N'ADD_POLICY_OBJECT', N'policy.SP_AddContractObject', N'PREVIEW_FIRST', N'Links a tenant-owned risk object to a tenant-owned policy.'),
    (N'CREATE_CLAIM', N'claim.SP_CreateClaim', N'PREVIEW_FIRST', N'Creates an open claim and resolves handler email to handler person_id.'),
    (N'CLOSE_CLAIM', N'claim.SP_CloseClaim', N'PREVIEW_FIRST', N'Closes a tenant-owned claim with amount and payment checks.')
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
GO
