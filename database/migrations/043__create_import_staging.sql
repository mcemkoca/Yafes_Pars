-- =============================================================================
-- Migration 042: Legacy data import staging
-- Kaynak: Eski Belçika sigorta sistemi (data/ klasöründeki CSV dosyaları)
-- Amaç: CSV verilerini temizleyip Yafes Pars şemasına aktarmak için
--        staging tabloları ve import stored procedure'ları.
-- =============================================================================
USE [YafesPars];
GO

-- -----------------------------------------------------------------------------
-- 1. import şeması (zaten varsa atla)
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'import')
BEGIN
    EXEC('CREATE SCHEMA import AUTHORIZATION dbo');
    PRINT 'Schema import aangemaakt.';
END;
GO

-- -----------------------------------------------------------------------------
-- 2. import.LegacyPerson — betrokkenen + betrokken_algemeen staging
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables
               WHERE schema_id = SCHEMA_ID(N'import') AND name = N'LegacyPerson')
    CREATE TABLE import.LegacyPerson (
        legacy_bet_id       BIGINT          NOT NULL,
        nat_of_rechtspersoon TINYINT        NULL,   -- 1=persoon, 2=rechtspersoon
        last_name           NVARCHAR(200)   NULL,
        first_name          NVARCHAR(200)   NULL,
        gender_code         NCHAR(1)        NULL,   -- m→M, v→F
        date_of_birth       DATE            NULL,   -- 0000-00-00 → NULL
        national_id         NVARCHAR(20)    NULL,   -- rijksregisternummer
        id_card_number      NVARCHAR(30)    NULL,
        language_code       NCHAR(2)        NULL,   -- 0→NL, 1→FR, 2→EN
        nationality         NVARCHAR(100)   NULL,
        risk_level          TINYINT         NULL,
        -- mapping resultaat
        yafes_person_id     UNIQUEIDENTIFIER NULL,
        import_status       NVARCHAR(20)    NOT NULL DEFAULT N'PENDING',
        import_error        NVARCHAR(500)   NULL,
        CONSTRAINT PK_LegacyPerson PRIMARY KEY (legacy_bet_id)
    );
GO

-- -----------------------------------------------------------------------------
-- 3. import.LegacyContract — contracten staging
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables
               WHERE schema_id = SCHEMA_ID(N'import') AND name = N'LegacyContract')
    CREATE TABLE import.LegacyContract (
        legacy_contract_id  BIGINT          NOT NULL,
        legacy_bet_id       BIGINT          NULL,
        policy_number       NVARCHAR(50)    NULL,
        legacy_domain       NVARCHAR(10)    NULL,   -- domein code (01,02,...)
        contract_domain_code NVARCHAR(40)  NULL,   -- gemapped (AUTO, BRAND, ...)
        legacy_status       TINYINT         NULL,   -- 1-5
        contract_status_code NVARCHAR(20)  NULL,   -- gemapped (ACTIVE, EXPIRED, ...)
        payment_frequency   TINYINT         NULL,   -- 1=m,2=kw,3=half,4=jaar
        gross_premium       DECIMAL(10,2)  NULL,
        net_premium         DECIMAL(10,2)  NULL,
        commission          DECIMAL(10,2)  NULL,
        created_at          DATETIME2       NULL,
        -- mapping resultaat
        yafes_contract_id   UNIQUEIDENTIFIER NULL,
        import_status       NVARCHAR(20)    NOT NULL DEFAULT N'PENDING',
        import_error        NVARCHAR(500)   NULL,
        CONSTRAINT PK_LegacyContract PRIMARY KEY (legacy_contract_id)
    );
GO

-- -----------------------------------------------------------------------------
-- 4. import.LegacyClaim — schadegeval staging
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables
               WHERE schema_id = SCHEMA_ID(N'import') AND name = N'LegacyClaim')
    CREATE TABLE import.LegacyClaim (
        legacy_schade_id    BIGINT          NOT NULL,
        legacy_contract_id  BIGINT          NULL,
        incident_date       DATE            NULL,
        description         NVARCHAR(1000)  NULL,
        liability_flag      BIT             NULL,
        material_damage_amt DECIMAL(12,2)  NULL,
        bodily_injury_amt   DECIMAL(12,2)  NULL,
        -- mapping resultaat
        yafes_claim_id      UNIQUEIDENTIFIER NULL,
        import_status       NVARCHAR(20)    NOT NULL DEFAULT N'PENDING',
        import_error        NVARCHAR(500)   NULL,
        CONSTRAINT PK_LegacyClaim PRIMARY KEY (legacy_schade_id)
    );
GO

-- -----------------------------------------------------------------------------
-- 5. SP_ImportLegacyPersons — staging → core.Person
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE import.SP_ImportLegacyPersons
    @tenant_id      UNIQUEIDENTIFIER,
    @batch_size     INT = 500,
    @dry_run        BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @imported INT = 0, @errors INT = 0;

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT TOP (@batch_size) legacy_bet_id, last_name, first_name, gender_code,
               date_of_birth, national_id, id_card_number, language_code, nationality
        FROM import.LegacyPerson
        WHERE import_status = N'PENDING'
        ORDER BY legacy_bet_id;

    DECLARE @bid BIGINT, @ln NVARCHAR(200), @fn NVARCHAR(200), @gnd NCHAR(1),
            @dob DATE, @nid NVARCHAR(20), @icard NVARCHAR(30), @lang NCHAR(2), @nat NVARCHAR(100);
    DECLARE @new_id UNIQUEIDENTIFIER;

    OPEN cur;
    FETCH NEXT FROM cur INTO @bid, @ln, @fn, @gnd, @dob, @nid, @icard, @lang, @nat;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            SET @new_id = NEWID();

            IF @dry_run = 0
            BEGIN
                INSERT INTO core.Person (person_id, tenant_id, last_name, first_name,
                    gender_code, date_of_birth, national_id, language_code)
                VALUES (@new_id, @tenant_id,
                    NULLIF(LTRIM(RTRIM(@ln)), N''),
                    NULLIF(LTRIM(RTRIM(@fn)), N''),
                    CASE WHEN @gnd IN (N'M', N'F') THEN @gnd ELSE NULL END,
                    @dob,
                    NULLIF(@nid, N''),
                    ISNULL(NULLIF(@lang, N''), N'NL'));

                UPDATE import.LegacyPerson
                SET yafes_person_id = @new_id, import_status = N'DONE'
                WHERE legacy_bet_id = @bid;
            END
            ELSE
            BEGIN
                UPDATE import.LegacyPerson
                SET import_status = N'DRY_OK'
                WHERE legacy_bet_id = @bid;
            END;

            SET @imported += 1;
        END TRY
        BEGIN CATCH
            UPDATE import.LegacyPerson
            SET import_status = N'ERROR', import_error = ERROR_MESSAGE()
            WHERE legacy_bet_id = @bid;
            SET @errors += 1;
        END CATCH;

        FETCH NEXT FROM cur INTO @bid, @ln, @fn, @gnd, @dob, @nid, @icard, @lang, @nat;
    END;
    CLOSE cur; DEALLOCATE cur;

    SELECT @imported AS Imported, @errors AS Errors,
           @dry_run  AS DryRun,  @batch_size AS BatchSize;
END;
GO

-- -----------------------------------------------------------------------------
-- 6. SP_GetImportSummary — staging tablo istatistikleri
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE import.SP_GetImportSummary
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        'LegacyPerson'   AS StagingTable,
        COUNT(*)         AS Total,
        SUM(CASE WHEN import_status = N'DONE'    THEN 1 ELSE 0 END) AS Done,
        SUM(CASE WHEN import_status = N'PENDING' THEN 1 ELSE 0 END) AS Pending,
        SUM(CASE WHEN import_status = N'ERROR'   THEN 1 ELSE 0 END) AS Errors
    FROM import.LegacyPerson
    UNION ALL
    SELECT
        'LegacyContract',
        COUNT(*),
        SUM(CASE WHEN import_status = N'DONE'    THEN 1 ELSE 0 END),
        SUM(CASE WHEN import_status = N'PENDING' THEN 1 ELSE 0 END),
        SUM(CASE WHEN import_status = N'ERROR'   THEN 1 ELSE 0 END)
    FROM import.LegacyContract
    UNION ALL
    SELECT
        'LegacyClaim',
        COUNT(*),
        SUM(CASE WHEN import_status = N'DONE'    THEN 1 ELSE 0 END),
        SUM(CASE WHEN import_status = N'PENDING' THEN 1 ELSE 0 END),
        SUM(CASE WHEN import_status = N'ERROR'   THEN 1 ELSE 0 END)
    FROM import.LegacyClaim;
END;
GO

PRINT 'Migration 042 complete: import schema + LegacyPerson/Contract/Claim staging tables + SPs.';
GO
