/*
    Yafes Pars SSMS Workbench - Operations Dashboard

    INFO TIP:
    Visual demo screens are not execution tools. Run this file in SSMS with
    SQLCMD Mode enabled against a DEV database to get real Results Grid data.

    Enable SQLCMD Mode before running.
    This script is read-only and returns SSMS Results Grid sections.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE "DEMO-BE-BROKER"
:setvar TOP_ROWS "100"

SET NOCOUNT ON;
GO

USE [master];
GO

DECLARE @TargetDatabase SYSNAME = N'$(YAFES_SQL_DATABASE)';
DECLARE @ServerName NVARCHAR(256) = LOWER(CONVERT(NVARCHAR(256), @@SERVERNAME));
DECLARE @MachineName NVARCHAR(256) = LOWER(CONVERT(NVARCHAR(256), SERVERPROPERTY('MachineName')));

IF @TargetDatabase NOT LIKE N'%DEV%'
    THROW 52010, 'Target database name must contain DEV.', 1;

IF @ServerName LIKE N'%prod%' OR @ServerName LIKE N'%production%' OR @ServerName LIKE N'%prd%' OR @ServerName LIKE N'%live%'
    THROW 52011, 'Connected server name suggests production/live.', 1;

IF @MachineName LIKE N'%prod%' OR @MachineName LIKE N'%production%' OR @MachineName LIKE N'%prd%' OR @MachineName LIKE N'%live%'
    THROW 52012, 'Connected machine name suggests production/live.', 1;

IF DB_ID(@TargetDatabase) IS NULL
    THROW 52013, 'Target DEV database does not exist.', 1;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

DECLARE @TenantCode NVARCHAR(80) = N'$(TENANT_CODE)';
DECLARE @TopRows INT = TRY_CONVERT(INT, N'$(TOP_ROWS)');
DECLARE @TenantId UNIQUEIDENTIFIER;

IF @TopRows IS NULL OR @TopRows < 1 OR @TopRows > 1000
    SET @TopRows = 100;

SELECT @TenantId = tenant_id
FROM core.Tenant
WHERE tenant_code = @TenantCode;

IF @TenantId IS NULL
    THROW 52014, 'Tenant code was not found.', 1;

PRINT '01 - Engine context';
SELECT
    @@SERVERNAME AS server_name,
    DB_NAME() AS database_name,
    SERVERPROPERTY('MachineName') AS machine_name,
    SUSER_SNAME() AS login_name,
    SYSUTCDATETIME() AS checked_at_utc;

PRINT '02 - Tenant context';
SELECT TOP (@TopRows)
    tenant_id,
    tenant_code,
    legal_name,
    display_name,
    is_active,
    created_at_utc,
    updated_at_utc
FROM core.Tenant
ORDER BY tenant_code;

PRINT '03 - Migration status';
SELECT
    migration_name,
    execution_status,
    executed_at_utc,
    executed_by
FROM core.SchemaMigration
ORDER BY migration_name;

PRINT '04 - Operational KPIs';
SELECT
    (SELECT COUNT_BIG(*) FROM person.Person WHERE tenant_id = @TenantId AND is_deleted = 0) AS persons,
    (SELECT COUNT_BIG(*) FROM institution.Institution WHERE tenant_id = @TenantId AND is_deleted = 0) AS institutions,
    (SELECT COUNT_BIG(*) FROM risk.InsurableObject WHERE tenant_id = @TenantId AND is_deleted = 0) AS risk_objects,
    (SELECT COUNT_BIG(*) FROM policy.Contract WHERE tenant_id = @TenantId AND is_deleted = 0) AS policies,
    (SELECT COUNT_BIG(*) FROM claim.Claim WHERE tenant_id = @TenantId AND is_deleted = 0) AS claims,
    (SELECT COUNT_BIG(*) FROM document.Document WHERE tenant_id = @TenantId AND is_deleted = 0) AS documents,
    (SELECT COUNT_BIG(*) FROM tasking.Task WHERE tenant_id = @TenantId AND is_deleted = 0) AS tasks,
    (SELECT COUNT_BIG(*) FROM coverage.Coverage WHERE is_active = 1) AS active_coverages;

PRINT '05 - Customers / persons';
SELECT TOP (@TopRows)
    tenant_id,
    person_id,
    person_kind,
    dossier,
    first_name,
    last_name,
    legal_form,
    primary_email,
    primary_phone,
    updated_at_utc
FROM person.VW_CustomerSummary
WHERE @TenantId IS NULL OR tenant_id = @TenantId
ORDER BY updated_at_utc DESC;

PRINT '06 - Institutions';
SELECT TOP (@TopRows)
    tenant_id,
    institution_id,
    institution_code,
    name,
    legal_name,
    vat_number,
    city,
    country_code,
    is_active
FROM institution.VW_InstitutionSummary
WHERE @TenantId IS NULL OR tenant_id = @TenantId
ORDER BY name;

PRINT '07 - Risk objects';
SELECT TOP (@TopRows)
    tenant_id,
    insurable_object_id,
    object_type_code,
    description,
    status_code,
    license_plate,
    chassis_number,
    brand,
    model,
    city,
    updated_at_utc
FROM risk.VW_InsurableObjectSummary
WHERE @TenantId IS NULL OR tenant_id = @TenantId
ORDER BY updated_at_utc DESC;

PRINT '08 - Policies';
SELECT TOP (@TopRows)
    tenant_id,
    contract_id,
    contract_number,
    contract_status_code,
    contract_domain_code,
    contract_type_code,
    start_date,
    end_date,
    company_name,
    latest_version_no,
    party_count,
    object_count
FROM policy.VW_PolicyDashboard
WHERE @TenantId IS NULL OR tenant_id = @TenantId
ORDER BY contract_number DESC;

PRINT '09 - Renewal candidates';
SELECT TOP (@TopRows)
    c.tenant_id,
    c.contract_id,
    c.contract_number,
    c.contract_domain_code,
    c.contract_type_code,
    c.end_date,
    DATEDIFF(DAY, CONVERT(DATE, SYSUTCDATETIME()), c.end_date) AS days_until_end
FROM policy.Contract c
WHERE (@TenantId IS NULL OR c.tenant_id = @TenantId)
  AND c.is_deleted = 0
  AND c.contract_status_code = N'ACTIVE'
  AND c.end_date IS NOT NULL
  AND c.end_date >= CONVERT(DATE, SYSUTCDATETIME())
  AND c.end_date <= DATEADD(DAY, 60, CONVERT(DATE, SYSUTCDATETIME()))
  AND NOT EXISTS (
        SELECT 1
        FROM tasking.Task t
        WHERE t.tenant_id = c.tenant_id
          AND t.related_entity_type = N'POLICY'
          AND t.related_entity_id = c.contract_id
          AND t.task_status_code IN (N'OPEN', N'IN_PROGRESS', N'WAITING')
          AND t.is_deleted = 0
          AND t.title = N'Policy renewal follow-up'
  )
ORDER BY c.end_date, c.contract_number;

PRINT '10 - Claims';
SELECT TOP (@TopRows)
    tenant_id,
    claim_id,
    claim_number,
    contract_number,
    coverage_code,
    claim_status_code,
    incident_date,
    reported_date,
    closed_date,
    paid_amount,
    reserved_amount
FROM claim.VW_ClaimDashboard
WHERE @TenantId IS NULL OR tenant_id = @TenantId
ORDER BY reported_date DESC;

PRINT '11 - Documents';
SELECT TOP (@TopRows)
    tenant_id,
    document_id,
    owner_entity_type,
    owner_entity_id,
    document_type_code,
    file_name,
    mime_type,
    file_size_bytes,
    storage_provider,
    uploaded_at_utc
FROM document.Document
WHERE (@TenantId IS NULL OR tenant_id = @TenantId)
  AND is_deleted = 0
ORDER BY uploaded_at_utc DESC;

PRINT '12 - Open tasks';
SELECT TOP (@TopRows)
    tenant_id,
    task_id,
    title,
    related_entity_type,
    related_entity_id,
    assigned_to_name,
    task_priority_code,
    task_status_code,
    due_at_utc,
    updated_at_utc
FROM tasking.VW_OpenTaskDashboard
WHERE @TenantId IS NULL OR tenant_id = @TenantId
ORDER BY due_at_utc, created_at_utc DESC;

PRINT '13 - Coverage packages';
SELECT
    cp.package_code,
    cp.package_name,
    cp.contract_domain_code,
    COUNT(cpi.coverage_code) AS coverage_count
FROM coverage.CoveragePackage cp
LEFT JOIN coverage.CoveragePackageItem cpi
    ON cpi.coverage_package_id = cp.coverage_package_id
WHERE cp.is_active = 1
GROUP BY cp.package_code, cp.package_name, cp.contract_domain_code
ORDER BY cp.contract_domain_code, cp.package_code;

PRINT '14 - Coverage package items';
SELECT
    cp.package_code,
    cp.contract_domain_code,
    cpi.coverage_code,
    c.label_nl,
    cpi.is_mandatory,
    cpi.sort_order
FROM coverage.CoveragePackage cp
INNER JOIN coverage.CoveragePackageItem cpi
    ON cpi.coverage_package_id = cp.coverage_package_id
INNER JOIN coverage.Coverage c
    ON c.coverage_code = cpi.coverage_code
ORDER BY cp.package_code, cpi.sort_order, cpi.coverage_code;

PRINT '15 - Lookup health';
SELECT 'coverage.Coverage' AS lookup_name, COUNT_BIG(*) AS row_count FROM coverage.Coverage
UNION ALL SELECT 'coverage.CoverageDomain', COUNT_BIG(*) FROM coverage.CoverageDomain
UNION ALL SELECT 'coverage.CoveragePackage', COUNT_BIG(*) FROM coverage.CoveragePackage
UNION ALL SELECT 'risk.VehicleType', COUNT_BIG(*) FROM risk.VehicleType
UNION ALL SELECT 'risk.ResidenceType', COUNT_BIG(*) FROM risk.ResidenceType
UNION ALL SELECT 'risk.InsurablePersonSubtype', COUNT_BIG(*) FROM risk.InsurablePersonSubtype
UNION ALL SELECT 'tasking.TaskStatus', COUNT_BIG(*) FROM tasking.TaskStatus
UNION ALL SELECT 'claim.ClaimStatus', COUNT_BIG(*) FROM claim.ClaimStatus;
GO
