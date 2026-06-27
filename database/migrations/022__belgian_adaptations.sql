-- =============================================================================
-- Migration 022: Belgische aanpassingen / Belçika uyarlamaları
-- Rijksregisternummer (RRN), KBO-format, burgerlijke staat,
-- Belgische postcode, FSMA-rapportageview, Turkse dekkingscodes deactiveren
-- =============================================================================
USE [YafesPars];
GO

BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'022__belgian_adaptations')
    BEGIN

        -- ── 1. RRN (Rijksregisternummer) veld aan NaturalPerson ──────────────
        IF COL_LENGTH(N'person.NaturalPerson', N'rrn') IS NULL
            ALTER TABLE person.NaturalPerson
                ADD rrn NVARCHAR(11) NULL;

        -- ── 2. Burgerlijke staat (samenlevingsvorm) ──────────────────────────
        IF COL_LENGTH(N'person.NaturalPerson', N'civil_status') IS NULL
            ALTER TABLE person.NaturalPerson
                ADD civil_status NVARCHAR(40) NULL;

        -- ── 3. KBO-nummer op Institution (al bestaat het veld, uitbreiden) ───
        -- kbo_number bestaat al; voeg NACEBEL-classificatie toe aan LegalPerson
        IF COL_LENGTH(N'person.LegalPerson', N'kbo_number') IS NULL
            ALTER TABLE person.LegalPerson
                ADD kbo_number NVARCHAR(12) NULL;

        -- ── 4. Turkse dekkingscodes deactiveren (Belgische blijven actief) ───
        UPDATE coverage.CoverageType
        SET    is_active = 0
        WHERE  coverage_type_code IN (N'KASKO', N'TRAFIK', N'DASK', N'YANGIN',
                                       N'SAGLIK', N'HAYAT', N'SORUMLULUK',
                                       N'SEYAHAT', N'ISE_IADE', N'FERDI_KAZA');

        INSERT INTO core.SchemaMigration (migration_name, execution_status)
        VALUES (N'022__belgian_adaptations', N'SUCCESS');

    END

COMMIT TRANSACTION;
GO

-- ── 5. CHECK-constraint RRN (11 cijfers) ─────────────────────────────────────
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'CK_NaturalPerson_rrn' AND parent_object_id = OBJECT_ID(N'person.NaturalPerson')
)
    ALTER TABLE person.NaturalPerson
        ADD CONSTRAINT CK_NaturalPerson_rrn
            CHECK (rrn IS NULL OR (LEN(rrn) = 11 AND rrn NOT LIKE N'%[^0-9]%'));
GO

-- ── 6. CHECK-constraint KBO-nummer (10 cijfers) ──────────────────────────────
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'CK_LegalPerson_kbo_number' AND parent_object_id = OBJECT_ID(N'person.LegalPerson')
)
    ALTER TABLE person.LegalPerson
        ADD CONSTRAINT CK_LegalPerson_kbo_number
            CHECK (kbo_number IS NULL OR (LEN(REPLACE(REPLACE(kbo_number,'.',''),'-','')) = 10));
GO

-- ── 7. CHECK-constraint burgerlijke staat ────────────────────────────────────
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'CK_NaturalPerson_civil_status' AND parent_object_id = OBJECT_ID(N'person.NaturalPerson')
)
    ALTER TABLE person.NaturalPerson
        ADD CONSTRAINT CK_NaturalPerson_civil_status
            CHECK (civil_status IS NULL OR civil_status IN (
                N'ONGEHUWD',              -- ongehuwd
                N'GEHUWD',               -- gehuwd
                N'WETTELIJK_SAMENWONEND',-- wettelijk samenwonend
                N'FEITELIJK_SAMENWONEND',-- feitelijk samenwonend
                N'GESCHEIDEN',           -- gescheiden
                N'WEDUWE_WEDUWNAAR'      -- weduwe/weduwnaar
            ));
GO

-- ── 8. SP_CreateNaturalPerson uitbreiden met RRN en burgerlijke staat ────────
CREATE OR ALTER PROCEDURE person.SP_CreateNaturalPerson
    @tenant_id          UNIQUEIDENTIFIER,
    @dossier            NVARCHAR(60)     = NULL,
    @language_code      NVARCHAR(10)     = N'NL',
    @nationality        NVARCHAR(80)     = NULL,
    @first_name         NVARCHAR(100)    = NULL,
    @last_name          NVARCHAR(100)    = NULL,
    @birth_date         DATE             = NULL,
    @title_code         NVARCHAR(20)     = NULL,
    @created_by_user_id UNIQUEIDENTIFIER = NULL,
    @created_person_id  UNIQUEIDENTIFIER OUTPUT,
    -- Belgische uitbreidingen
    @rrn                NVARCHAR(11)     = NULL,
    @civil_status       NVARCHAR(40)     = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NULLIF(LTRIM(RTRIM(@first_name)), N'') IS NULL
       AND NULLIF(LTRIM(RTRIM(@last_name)), N'') IS NULL
        THROW 51630, 'Voornaam of achternaam is verplicht.', 1;

    IF @rrn IS NOT NULL AND (LEN(@rrn) <> 11 OR @rrn LIKE N'%[^0-9]%')
        THROW 51635, 'Rijksregisternummer moet 11 cijfers bevatten.', 1;

    DECLARE @NewPerson TABLE (person_id UNIQUEIDENTIFIER NOT NULL);

    INSERT INTO person.Person (tenant_id, person_kind, dossier, language_code, nationality, created_by_user_id)
    OUTPUT inserted.person_id INTO @NewPerson
    VALUES (@tenant_id, N'NATURAL', @dossier, ISNULL(@language_code, N'NL'), @nationality, @created_by_user_id);

    SELECT @created_person_id = person_id FROM @NewPerson;

    INSERT INTO person.NaturalPerson
        (person_id, first_name, last_name, birth_date, title_code, rrn, civil_status)
    VALUES
        (@created_person_id,
         NULLIF(LTRIM(RTRIM(@first_name)), N''),
         NULLIF(LTRIM(RTRIM(@last_name)), N''),
         @birth_date, @title_code, @rrn, @civil_status);
END;
GO

-- ── 9. FSMA-rapportageview ────────────────────────────────────────────────────
IF OBJECT_ID(N'reporting.VW_FsmaReport', N'V') IS NOT NULL
    DROP VIEW reporting.VW_FsmaReport;
GO

IF SCHEMA_ID(N'reporting') IS NULL
    EXEC(N'CREATE SCHEMA reporting');
GO

CREATE VIEW reporting.VW_FsmaReport AS
SELECT
    -- Identificatie
    c.tenant_id,
    c.contract_id,
    c.contract_number,
    c.contract_domain_code                          AS tak,           -- tak (AUTO, FIRE, ...)
    c.contract_type_code                            AS productcode,
    c.contract_status_code                          AS status,

    -- Verzekeringnemer
    p.person_id                                     AS vn_person_id,
    np.first_name + N' ' + ISNULL(np.last_name,'') AS vn_naam,
    np.rrn                                          AS vn_rrn,
    lp.kbo_number                                   AS vn_kbo,

    -- Polisperiode
    c.start_date                                    AS ingangsdatum,
    c.end_date                                      AS vervaldatum,

    -- Premie & schade (rolling 12 maanden)
    ISNULL(prem.totaal_premie, 0)                   AS totaal_premie_eur,
    ISNULL(schd.aantal_schaden, 0)                  AS aantal_schaden,
    ISNULL(schd.totaal_gereserveerd, 0)             AS totaal_gereserveerd_eur,
    ISNULL(schd.totaal_betaald, 0)                  AS totaal_betaald_eur,

    -- Tijdstip
    CAST(SYSUTCDATETIME() AS DATE)                  AS rapportdatum

FROM policy.Contract c

-- Verzekeringnemer (POLICYHOLDER)
LEFT JOIN policy.ContractParty  cp  ON cp.contract_id = c.contract_id
                                    AND cp.contract_party_role_code = N'POLICYHOLDER'
LEFT JOIN person.Person         p   ON p.person_id  = cp.person_id
LEFT JOIN person.NaturalPerson  np  ON np.person_id = p.person_id
LEFT JOIN person.LegalPerson    lp  ON lp.person_id = p.person_id

-- Premie
OUTER APPLY (
    SELECT ISNULL(SUM(i.Amount), 0) AS totaal_premie
    FROM finance.Invoices i
    WHERE i.TenantId    = c.tenant_id
      AND i.ContractId  = c.contract_id
      AND i.IssueDate  >= DATEADD(MONTH, -12, SYSUTCDATETIME())
) prem

-- Schade
OUTER APPLY (
    SELECT
        COUNT(*)                          AS aantal_schaden,
        ISNULL(SUM(cl.reserved_amount),0) AS totaal_gereserveerd,
        ISNULL(SUM(cl.paid_amount),0)     AS totaal_betaald
    FROM claim.Claim cl
    WHERE cl.tenant_id   = c.tenant_id
      AND cl.contract_id = c.contract_id
) schd

WHERE c.is_deleted = 0;
GO

PRINT 'Migration 022 voltooid: Belgische aanpassingen toegepast.';
GO
