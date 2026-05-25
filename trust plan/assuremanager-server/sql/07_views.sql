-- =============================================================
-- AssureManager Views
-- Pre-built query views for dashboard and reporting
-- =============================================================
-- Run AFTER 06_stored_procedures.sql
-- =============================================================

SET NOCOUNT ON;
GO

USE AssureManagerDB;
GO

PRINT '======================================================';
PRINT ' Creating views...';
PRINT '======================================================';
GO

-- =============================================================
-- 1. vw_Person_Full - Person + Natural/Legal details joined
-- =============================================================
CREATE OR ALTER VIEW vw_Person_Full
AS
SELECT
    p.person_id,
    p.person_kind,
    p.dossier,
    p.language_code,
    l.language_label_nl,
    p.nationality,
    p.created_at,
    p.updated_at,
    -- Natural person columns
    np.first_name,
    np.last_name,
    np.birth_date,
    np.birth_place,
    np.death_date,
    np.gender,
    np.marital_status,
    np.national_number,
    np.passport_number,
    t.title_label_nl,
    -- Legal person columns
    lp.legal_form,
    lp.incorporation_date,
    lp.closing_date,
    -- Computed
    CASE
        WHEN p.person_kind = 'NATURAL' THEN CONCAT(np.first_name, ' ', np.last_name)
        ELSE lp.legal_form
    END AS display_name,
    CASE
        WHEN np.birth_date IS NOT NULL THEN DATEDIFF(YEAR, np.birth_date, GETDATE())
        WHEN lp.incorporation_date IS NOT NULL THEN DATEDIFF(YEAR, lp.incorporation_date, GETDATE())
    END AS age_years,
    -- Primary contact info
    a.street AS primary_street,
    a.house_number AS primary_house_number,
    a.postal_code AS primary_postal_code,
    a.city AS primary_city,
    a.country_code AS primary_country_code,
    ph.phone_number AS primary_phone,
    e.email AS primary_email
FROM Person p
LEFT JOIN Language l ON p.language_code = l.language_code
LEFT JOIN NaturalPerson np ON p.person_id = np.person_id
LEFT JOIN Title t ON np.title_code = t.title_code
LEFT JOIN LegalPerson lp ON p.person_id = lp.person_id
LEFT JOIN Address a ON p.person_id = a.person_id AND a.is_primary = 1
LEFT JOIN Phone ph ON p.person_id = ph.person_id AND ph.is_primary = 1
LEFT JOIN Email e ON p.person_id = e.person_id;
GO

-- =============================================================
-- 2. vw_Contract_Full - Contract with versions, parties, objects
-- =============================================================
CREATE OR ALTER VIEW vw_Contract_Full
AS
SELECT
    c.contract_id,
    c.contract_number,
    c.contract_domain_code,
    cd.label_nl AS domain_label,
    c.contract_type_code,
    ct.contract_type_name,
    c.contract_status_code,
    cs.status_label AS contract_status_label,
    c.company_id,
    i.name AS company_name,
    c.handling_company_id,
    hi.name AS handling_company_name,
    c.start_date,
    c.end_date,
    c.created_at,
    c.updated_at,
    -- Latest version info
    cv_latest.contract_version_id AS latest_version_id,
    cv_latest.version_no AS latest_version_no,
    cv_latest.effective_from AS version_effective_from,
    cv_latest.effective_to AS version_effective_to,
    cvs.status_label AS version_status_label,
    cv_latest.periodicity_code,
    p.periodicity_label_nl,
    -- Party info (policyholder)
    ph.person_id AS policyholder_id,
    COALESCE(nph.first_name + ' ' + nph.last_name, lph.legal_form) AS policyholder_name,
    -- Object count
    (SELECT COUNT(*) FROM Contract_Object co WHERE co.contract_id = c.contract_id) AS object_count,
    -- Claim count
    (SELECT COUNT(*) FROM Claim cl WHERE cl.contract_id = c.contract_id) AS claim_count,
    -- Days until expiry
    CASE
        WHEN c.end_date IS NOT NULL AND c.contract_status_code = 'LOPEND'
        THEN DATEDIFF(DAY, GETDATE(), c.end_date)
    END AS days_until_expiry
FROM Contract c
JOIN ContractDomain cd ON c.contract_domain_code = cd.contract_domain_code
JOIN ContractType ct ON c.contract_type_code = ct.contract_type_code
JOIN ContractStatus cs ON c.contract_status_code = cs.contract_status_code
LEFT JOIN Institution i ON c.company_id = i.institution_id
LEFT JOIN Institution hi ON c.handling_company_id = hi.institution_id
OUTER APPLY (
    SELECT TOP 1 *
    FROM ContractVersion cv
    WHERE cv.contract_id = c.contract_id
    ORDER BY cv.version_no DESC
) cv_latest
LEFT JOIN ContractVersionStatus cvs ON cv_latest.status_code = cvs.status_code
LEFT JOIN Periodicity p ON cv_latest.periodicity_code = p.periodicity_code
LEFT JOIN Contract_Party cpp ON c.contract_id = cpp.contract_id AND cpp.contract_party_role_code = 'POLICYHOLDER'
LEFT JOIN Person ph ON cpp.person_id = ph.person_id
LEFT JOIN NaturalPerson nph ON ph.person_id = nph.person_id
LEFT JOIN LegalPerson lph ON ph.person_id = lph.person_id;
GO

-- =============================================================
-- 3. vw_Claim_Full - Claim with all related entities
-- =============================================================
CREATE OR ALTER VIEW vw_Claim_Full
AS
SELECT
    cl.claim_id,
    cl.claim_number,
    cl.contract_id,
    c.contract_number,
    c.contract_domain_code,
    cd.label_nl AS domain_label,
    cl.coverage_code,
    lc.label_nl AS coverage_label,
    cl.claim_status_code,
    cs.status_label AS claim_status_label,
    cl.claims_handler_id,
    COALESCE(hnp.first_name + ' ' + hnp.last_name, hlp.legal_form) AS handler_name,
    cl.incident_date,
    cl.reported_date,
    cl.closed_date,
    cl.description,
    cl.paid_amount,
    cl.payment_method_code,
    cpm.method_label AS payment_method_label,
    cl.created_at,
    cl.updated_at,
    -- Computed fields
    DATEDIFF(DAY, COALESCE(cl.incident_date, cl.reported_date), GETDATE()) AS days_open,
    CASE
        WHEN cl.claim_status_code <> 'AFGEHANDELD'
             AND DATEDIFF(DAY, COALESCE(cl.incident_date, cl.reported_date), GETDATE()) > 45
        THEN 1 ELSE 0
    END AS is_urgent,
    CASE
        WHEN cl.closed_date IS NOT NULL AND cl.reported_date IS NOT NULL
        THEN DATEDIFF(DAY, cl.reported_date, cl.closed_date)
    END AS resolution_days,
    -- Claimant info
    cp.person_id AS claimant_id,
    COALESCE(ncp.first_name + ' ' + ncp.last_name, lcp.legal_form) AS claimant_name
FROM Claim cl
JOIN Contract c ON cl.contract_id = c.contract_id
JOIN ContractDomain cd ON c.contract_domain_code = cd.contract_domain_code
JOIN lookup_coverage lc ON cl.coverage_code = lc.coverage_code
JOIN ClaimStatus cs ON cl.claim_status_code = cs.claim_status_code
LEFT JOIN Person hp ON cl.claims_handler_id = hp.person_id
LEFT JOIN NaturalPerson hnp ON hp.person_id = hnp.person_id
LEFT JOIN LegalPerson hlp ON hp.person_id = hlp.person_id
LEFT JOIN ClaimPaymentMethod cpm ON cl.payment_method_code = cpm.payment_method_code
LEFT JOIN Claim_Party cp ON cl.claim_id = cp.claim_id AND cp.claim_party_role_code = 'CLAIMANT'
LEFT JOIN Person cp_p ON cp.person_id = cp_p.person_id
LEFT JOIN NaturalPerson ncp ON cp_p.person_id = ncp.person_id
LEFT JOIN LegalPerson lcp ON cp_p.person_id = lcp.person_id;
GO

-- =============================================================
-- 4. vw_Dashboard_KPIs - Aggregated dashboard metrics
-- =============================================================
CREATE OR ALTER VIEW vw_Dashboard_KPIs
AS
SELECT
    -- Person metrics
    (SELECT COUNT(*) FROM Person) AS total_persons,
    (SELECT COUNT(*) FROM Person WHERE person_kind = 'NATURAL') AS natural_persons,
    (SELECT COUNT(*) FROM Person WHERE person_kind = 'LEGAL') AS legal_persons,
    -- Contract metrics
    (SELECT COUNT(*) FROM Contract) AS total_contracts,
    (SELECT COUNT(*) FROM Contract WHERE contract_status_code = 'LOPEND') AS active_contracts,
    (SELECT COUNT(*) FROM Contract WHERE contract_status_code = 'OPGEZEGD') AS terminated_contracts,
    (SELECT COUNT(*) FROM Contract WHERE end_date <= DATEADD(DAY, 90, CAST(GETDATE() AS DATE))
                                     AND end_date >= CAST(GETDATE() AS DATE)
                                     AND contract_status_code = 'LOPEND') AS expiring_contracts_90d,
    -- Claim metrics
    (SELECT COUNT(*) FROM Claim) AS total_claims,
    (SELECT COUNT(*) FROM Claim WHERE claim_status_code = 'INGEDIEND') AS submitted_claims,
    (SELECT COUNT(*) FROM Claim WHERE claim_status_code = 'IN_BEHANDELING') AS open_claims,
    (SELECT COUNT(*) FROM Claim WHERE claim_status_code = 'AFGEHANDELD') AS resolved_claims,
    (SELECT ISNULL(SUM(paid_amount), 0) FROM Claim) AS total_claims_paid,
    (SELECT COUNT(*) FROM Claim WHERE claim_status_code <> 'AFGEHANDELD'
        AND DATEDIFF(DAY, COALESCE(incident_date, reported_date), GETDATE()) > 45) AS urgent_claims,
    -- Object metrics
    (SELECT COUNT(*) FROM [Object]) AS total_objects,
    -- Institution metrics
    (SELECT COUNT(*) FROM Institution) AS total_institutions;
GO

-- =============================================================
-- 5. vw_OpenClaims - Open claims with aging (days open)
-- =============================================================
CREATE OR ALTER VIEW vw_OpenClaims
AS
SELECT
    cf.*,
    -- Age categories
    CASE
        WHEN cf.days_open <= 7 THEN '0-7 dagen'
        WHEN cf.days_open <= 14 THEN '8-14 dagen'
        WHEN cf.days_open <= 30 THEN '15-30 dagen'
        WHEN cf.days_open <= 45 THEN '31-45 dagen'
        ELSE '45+ dagen (URGENT)'
    END AS age_category
FROM vw_Claim_Full cf
WHERE cf.claim_status_code <> 'AFGEHANDELD'
  AND cf.claim_status_code <> 'GEWEIGERD';
GO

-- =============================================================
-- 6. vw_ExpiringContracts - Contracts expiring within 90 days
-- =============================================================
CREATE OR ALTER VIEW vw_ExpiringContracts
AS
SELECT
    vf.*,
    -- Days remaining
    CASE
        WHEN vf.end_date IS NOT NULL AND vf.contract_status_code = 'LOPEND'
        THEN DATEDIFF(DAY, GETDATE(), vf.end_date)
    END AS days_remaining,
    -- Expiry window
    CASE
        WHEN vf.end_date <= DATEADD(DAY, 30, CAST(GETDATE() AS DATE))
        THEN '0-30 dagen (KORT)'
        WHEN vf.end_date <= DATEADD(DAY, 60, CAST(GETDATE() AS DATE))
        THEN '31-60 dagen (MEDIUM)'
        ELSE '61-90 dagen (LANg)'
    END AS expiry_window
FROM vw_Contract_Full vf
WHERE vf.end_date IS NOT NULL
  AND vf.end_date <= DATEADD(DAY, 90, CAST(GETDATE() AS DATE))
  AND vf.end_date >= CAST(GETDATE() AS DATE)
  AND vf.contract_status_code = 'LOPEND';
GO

PRINT '';
PRINT '======================================================';
PRINT ' All views created successfully!';
PRINT ' (6 views created)';
PRINT '======================================================';
GO
