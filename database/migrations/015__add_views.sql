SET NOCOUNT ON;
GO

USE [YafesPars];
GO

PRINT 'Running migration: 015__add_views.sql';
GO

CREATE OR ALTER VIEW person.VW_CustomerSummary
AS
SELECT
    p.tenant_id,
    p.person_id,
    p.person_kind,
    p.dossier,
    np.first_name,
    np.last_name,
    lp.legal_form,
    e.email AS primary_email,
    ph.phone_number AS primary_phone,
    p.created_at_utc,
    p.updated_at_utc
FROM person.Person p
LEFT JOIN person.NaturalPerson np
    ON np.person_id = p.person_id
LEFT JOIN person.LegalPerson lp
    ON lp.person_id = p.person_id
LEFT JOIN person.Email e
    ON e.person_id = p.person_id
   AND e.is_primary = 1
   AND e.is_deleted = 0
LEFT JOIN person.Phone ph
    ON ph.person_id = p.person_id
   AND ph.is_primary = 1
   AND ph.is_deleted = 0
WHERE p.is_deleted = 0;
GO

CREATE OR ALTER VIEW institution.VW_InstitutionSummary
AS
SELECT
    i.tenant_id,
    i.institution_id,
    i.institution_code,
    i.name,
    i.legal_name,
    i.vat_number,
    ia.street,
    ia.house_number,
    ia.box,
    ia.postal_code,
    ia.city,
    ia.country_code,
    i.is_active,
    i.created_at_utc,
    i.updated_at_utc
FROM institution.Institution i
LEFT JOIN institution.InstitutionAddress ia
    ON ia.institution_id = i.institution_id
   AND ia.is_primary = 1
   AND ia.is_deleted = 0
WHERE i.is_deleted = 0;
GO

CREATE OR ALTER VIEW risk.VW_InsurableObjectSummary
AS
SELECT
    io.tenant_id,
    io.insurable_object_id,
    io.object_type_code,
    io.description,
    io.status_code,
    io.start_date,
    io.end_date,
    v.license_plate,
    v.chassis_number,
    v.brand,
    v.model,
    re.postal_code,
    re.city,
    re.street,
    re.number,
    io.created_at_utc,
    io.updated_at_utc
FROM risk.InsurableObject io
LEFT JOIN risk.InsurableVehicle v
    ON v.insurable_object_id = io.insurable_object_id
LEFT JOIN risk.InsurableRealEstate re
    ON re.insurable_object_id = io.insurable_object_id
WHERE io.is_deleted = 0;
GO

CREATE OR ALTER VIEW policy.VW_ActivePolicy
AS
SELECT
    c.tenant_id,
    c.contract_id,
    c.contract_number,
    c.contract_domain_code,
    c.contract_type_code,
    c.contract_status_code,
    c.start_date,
    c.end_date,
    i.name AS company_name
FROM policy.Contract c
LEFT JOIN institution.Institution i
    ON i.institution_id = c.company_id
WHERE c.is_deleted = 0
  AND c.contract_status_code IN (N'ACTIVE', N'IN_FORCE')
  AND (c.end_date IS NULL OR c.end_date >= CONVERT(date, SYSUTCDATETIME()));
GO

CREATE OR ALTER VIEW policy.VW_PolicyDashboard
AS
SELECT
    c.tenant_id,
    c.contract_id,
    c.contract_number,
    c.contract_status_code,
    c.contract_domain_code,
    c.contract_type_code,
    c.start_date,
    c.end_date,
    i.name AS company_name,
    latest_version.version_no AS latest_version_no,
    latest_version.effective_from AS latest_effective_from,
    latest_version.effective_to AS latest_effective_to,
    party_counts.party_count,
    object_counts.object_count
FROM policy.Contract c
LEFT JOIN institution.Institution i
    ON i.institution_id = c.company_id
OUTER APPLY (
    SELECT TOP (1)
        cv.version_no,
        cv.effective_from,
        cv.effective_to
    FROM policy.ContractVersion cv
    WHERE cv.contract_id = c.contract_id
      AND cv.is_deleted = 0
    ORDER BY cv.version_no DESC
) latest_version
OUTER APPLY (
    SELECT COUNT_BIG(*) AS party_count
    FROM policy.ContractParty cp
    WHERE cp.contract_id = c.contract_id
) party_counts
OUTER APPLY (
    SELECT COUNT_BIG(*) AS object_count
    FROM policy.ContractObject co
    WHERE co.contract_id = c.contract_id
) object_counts
WHERE c.is_deleted = 0;
GO

CREATE OR ALTER VIEW claim.VW_ClaimDashboard
AS
SELECT
    cl.tenant_id,
    cl.claim_id,
    cl.claim_number,
    cl.contract_id,
    c.contract_number,
    cl.coverage_code,
    cl.claim_status_code,
    cl.incident_date,
    cl.reported_date,
    cl.closed_date,
    cl.paid_amount,
    cl.reserved_amount,
    cl.claims_handler_id
FROM claim.Claim cl
INNER JOIN policy.Contract c
    ON c.contract_id = cl.contract_id
WHERE cl.is_deleted = 0;
GO

CREATE OR ALTER VIEW tasking.VW_OpenTaskDashboard
AS
SELECT
    t.tenant_id,
    t.task_id,
    t.title,
    t.related_entity_type,
    t.related_entity_id,
    t.assigned_to_user_id,
    au.display_name AS assigned_to_name,
    t.task_priority_code,
    t.task_status_code,
    t.due_at_utc,
    t.created_at_utc,
    t.updated_at_utc
FROM tasking.Task t
LEFT JOIN core.AppUser au
    ON au.user_id = t.assigned_to_user_id
WHERE t.is_deleted = 0
  AND t.task_status_code IN (N'OPEN', N'IN_PROGRESS', N'WAITING');
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'015__add_views.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'015__add_views.sql',
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
