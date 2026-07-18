-- =============================================================================
-- Migration 041: Premium hesaplama motoru
-- Belçika: her coverage domain için baz prim oranı + risk faktörleri.
-- SP_CalculatePremium sözleşme üzerindeki coverage itemlarından prim hesaplar.
-- Schema notu: ContractCoverageItem.coverage_limit = sigortalı değer (coverage_id yok)
--              Contract.contract_domain_code = tarife domain eşleşmesi için kullanılır
-- =============================================================================
USE [YafesPars];
GO

-- -----------------------------------------------------------------------------
-- 1. finance.TariffRate — domain + coverage tipi başına baz oran tablosu
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables
               WHERE schema_id = SCHEMA_ID(N'finance') AND name = N'TariffRate')
BEGIN
    CREATE TABLE finance.TariffRate (
        tariff_rate_id      UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
        tenant_id           UNIQUEIDENTIFIER NOT NULL,
        coverage_domain_code NVARCHAR(50)    NOT NULL,
        coverage_type_code  NVARCHAR(80)     NOT NULL DEFAULT N'*',
        base_rate_pct       DECIMAL(8,4)     NOT NULL,
        min_premium_eur     DECIMAL(10,2)    NOT NULL DEFAULT 0,
        max_premium_eur     DECIMAL(10,2)    NULL,
        age_factor_young    DECIMAL(6,4)     NOT NULL DEFAULT 1.0,
        age_factor_senior   DECIMAL(6,4)     NOT NULL DEFAULT 1.0,
        no_claim_discount   DECIMAL(6,4)     NOT NULL DEFAULT 0.0,
        effective_from      DATE             NOT NULL DEFAULT CAST(GETUTCDATE() AS DATE),
        effective_to        DATE             NULL,
        is_active           BIT              NOT NULL DEFAULT 1,
        created_at_utc      DATETIME2        NOT NULL DEFAULT GETUTCDATE(),
        updated_at_utc      DATETIME2        NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT PK_TariffRate          PRIMARY KEY (tariff_rate_id),
        CONSTRAINT FK_TR_Tenant           FOREIGN KEY (tenant_id) REFERENCES core.Tenant(tenant_id),
        CONSTRAINT UQ_TR_Domain_Type_Date UNIQUE (tenant_id, coverage_domain_code, coverage_type_code, effective_from),
        CONSTRAINT CK_TR_BaseRate         CHECK (base_rate_pct > 0 AND base_rate_pct <= 100),
        CONSTRAINT CK_TR_Dates            CHECK (effective_to IS NULL OR effective_to >= effective_from)
    );

    CREATE INDEX IX_TariffRate_tenant_domain ON finance.TariffRate (tenant_id, coverage_domain_code, is_active);

    PRINT 'finance.TariffRate aangemaakt.';
END;
ELSE
    PRINT 'finance.TariffRate bestaat al.';
GO

-- -----------------------------------------------------------------------------
-- 2. SP_GetTariffRates — aktif tarifeler listesi
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE finance.SP_GetTariffRates
    @tenant_id              UNIQUEIDENTIFIER,
    @coverage_domain_code   NVARCHAR(50) = NULL,
    @include_inactive       BIT          = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        tr.tariff_rate_id        AS TariffRateId,
        tr.coverage_domain_code  AS CoverageDomainCode,
        tr.coverage_type_code    AS CoverageTypeCode,
        tr.base_rate_pct         AS BaseRatePct,
        tr.min_premium_eur       AS MinPremiumEur,
        tr.max_premium_eur       AS MaxPremiumEur,
        tr.age_factor_young      AS AgeFactorYoung,
        tr.age_factor_senior     AS AgeFactorSenior,
        tr.no_claim_discount     AS NoClaimDiscount,
        tr.effective_from        AS EffectiveFrom,
        tr.effective_to          AS EffectiveTo,
        tr.is_active             AS IsActive
    FROM finance.TariffRate tr
    WHERE tr.tenant_id = @tenant_id
      AND (@coverage_domain_code IS NULL OR tr.coverage_domain_code = @coverage_domain_code)
      AND (@include_inactive = 1 OR tr.is_active = 1)
    ORDER BY tr.coverage_domain_code, tr.coverage_type_code;
END;
GO

-- -----------------------------------------------------------------------------
-- 3. SP_UpsertTariffRate — tarife ekle/güncelle
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE finance.SP_UpsertTariffRate
    @tenant_id              UNIQUEIDENTIFIER,
    @coverage_domain_code   NVARCHAR(50),
    @coverage_type_code     NVARCHAR(80)  = N'*',
    @base_rate_pct          DECIMAL(8,4),
    @min_premium_eur        DECIMAL(10,2) = 0,
    @max_premium_eur        DECIMAL(10,2) = NULL,
    @age_factor_young       DECIMAL(6,4)  = 1.0,
    @age_factor_senior      DECIMAL(6,4)  = 1.0,
    @no_claim_discount      DECIMAL(6,4)  = 0.0,
    @effective_from         DATE          = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @eff_from DATE = ISNULL(@effective_from, CAST(GETUTCDATE() AS DATE));

    MERGE finance.TariffRate AS tgt
    USING (SELECT @tenant_id AS tenant_id,
                  @coverage_domain_code AS coverage_domain_code,
                  @coverage_type_code AS coverage_type_code,
                  @eff_from AS effective_from) AS src
    ON  tgt.tenant_id             = src.tenant_id
    AND tgt.coverage_domain_code  = src.coverage_domain_code
    AND tgt.coverage_type_code    = src.coverage_type_code
    AND tgt.effective_from        = src.effective_from
    WHEN MATCHED THEN
        UPDATE SET
            base_rate_pct      = @base_rate_pct,
            min_premium_eur    = @min_premium_eur,
            max_premium_eur    = @max_premium_eur,
            age_factor_young   = @age_factor_young,
            age_factor_senior  = @age_factor_senior,
            no_claim_discount  = @no_claim_discount,
            is_active          = 1,
            updated_at_utc     = GETUTCDATE()
    WHEN NOT MATCHED THEN
        INSERT (tenant_id, coverage_domain_code, coverage_type_code,
                base_rate_pct, min_premium_eur, max_premium_eur,
                age_factor_young, age_factor_senior, no_claim_discount,
                effective_from, is_active)
        VALUES (@tenant_id, @coverage_domain_code, @coverage_type_code,
                @base_rate_pct, @min_premium_eur, @max_premium_eur,
                @age_factor_young, @age_factor_senior, @no_claim_discount,
                @eff_from, 1);

    SELECT
        tariff_rate_id       AS TariffRateId,
        coverage_domain_code AS CoverageDomainCode,
        coverage_type_code   AS CoverageTypeCode,
        base_rate_pct        AS BaseRatePct,
        min_premium_eur      AS MinPremiumEur,
        effective_from       AS EffectiveFrom,
        is_active            AS IsActive
    FROM finance.TariffRate
    WHERE tenant_id            = @tenant_id
      AND coverage_domain_code = @coverage_domain_code
      AND coverage_type_code   = @coverage_type_code
      AND effective_from       = @eff_from;
END;
GO

-- -----------------------------------------------------------------------------
-- 4. SP_CalculatePremium — sözleşme için prim hesapla
-- Schema: ContractCoverageItem(coverage_item_id, coverage_type_code, coverage_limit)
--         Contract(contract_domain_code) — tarife domain eşleşmesi için
-- Wildcard: spesifik tarife varsa onu kullan, yoksa '*' fallback.
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE finance.SP_CalculatePremium
    @tenant_id      UNIQUEIDENTIFIER,
    @contract_id    UNIQUEIDENTIFIER,
    @reference_date DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ref_date DATE = ISNULL(@reference_date, CAST(GETUTCDATE() AS DATE));
    DECLARE @domain_code NVARCHAR(40);

    -- Sözleşme tenant kontrolü + domain kodu al
    SELECT @domain_code = contract_domain_code
    FROM policy.Contract
    WHERE contract_id = @contract_id AND tenant_id = @tenant_id;

    IF @domain_code IS NULL
    BEGIN
        SELECT NULL AS CoverageItemId, NULL AS CoverageTypeCode,
               NULL AS InsuredValue,   NULL AS BaseRatePct,
               NULL AS CalculatedPremium, NULL AS Status
        WHERE 1 = 0;
        RETURN;
    END;

    -- Coverage item bazlı prim hesaplama.
    -- Tarife önceliği: spesifik coverage_type_code > wildcard '*'.
    -- CROSS APPLY TOP 1 garantiler her item için en fazla 1 tarife satırı.
    SELECT
        cci.coverage_item_id                    AS CoverageItemId,
        cci.coverage_type_code                  AS CoverageTypeCode,
        cci.coverage_limit                      AS InsuredValue,
        tr.base_rate_pct                        AS BaseRatePct,
        tr.min_premium_eur                      AS MinPremiumEur,
        tr.max_premium_eur                      AS MaxPremiumEur,
        CASE
            WHEN tr.tariff_rate_id IS NULL THEN 0
            ELSE ROUND(
                    GREATEST(
                        tr.min_premium_eur,
                        LEAST(
                            ISNULL(tr.max_premium_eur, 999999999),
                            cci.coverage_limit * tr.base_rate_pct / 100.0
                        )
                    )
                , 2)
        END                                     AS CalculatedPremium,
        CASE WHEN tr.tariff_rate_id IS NULL THEN N'NO_TARIFF' ELSE N'OK' END AS Status
    FROM coverage.ContractCoverageItem cci
    OUTER APPLY (
        SELECT TOP 1
            tariff_rate_id, base_rate_pct, min_premium_eur, max_premium_eur
        FROM finance.TariffRate
        WHERE tenant_id            = @tenant_id
          AND coverage_domain_code = @domain_code
          AND (coverage_type_code  = cci.coverage_type_code OR coverage_type_code = N'*')
          AND effective_from       <= @ref_date
          AND (effective_to IS NULL OR effective_to >= @ref_date)
          AND is_active            = 1
        ORDER BY
            CASE WHEN coverage_type_code = cci.coverage_type_code THEN 0 ELSE 1 END
    ) tr
    WHERE cci.contract_id = @contract_id
    ORDER BY cci.coverage_type_code;
END;
GO

-- -----------------------------------------------------------------------------
-- 5. SP_GetPremiumSummary — sözleşme için toplam prim özeti
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE finance.SP_GetPremiumSummary
    @tenant_id      UNIQUEIDENTIFIER,
    @contract_id    UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ref_date    DATE         = CAST(GETUTCDATE() AS DATE);
    DECLARE @domain_code NVARCHAR(40);

    -- Tenant guard
    SELECT @domain_code = contract_domain_code
    FROM policy.Contract
    WHERE contract_id = @contract_id AND tenant_id = @tenant_id;

    IF @domain_code IS NULL
    BEGIN
        SELECT NULL AS ContractId, NULL AS CoverageCount, NULL AS MissingTariffCount,
               NULL AS TotalAnnualPremiumEur, NULL AS MonthlyPremiumEur, NULL AS CalculatedAt
        WHERE 1 = 0;
        RETURN;
    END;

    SELECT
        @contract_id                         AS ContractId,
        COUNT(*)                             AS CoverageCount,
        SUM(CASE WHEN tr.tariff_rate_id IS NULL THEN 1 ELSE 0 END) AS MissingTariffCount,
        SUM(CASE
            WHEN tr.tariff_rate_id IS NULL THEN 0
            ELSE ROUND(GREATEST(tr.min_premium_eur,
                         LEAST(ISNULL(tr.max_premium_eur, 999999999),
                               cci.coverage_limit * tr.base_rate_pct / 100.0)), 2)
        END)                                 AS TotalAnnualPremiumEur,
        ROUND(SUM(CASE
            WHEN tr.tariff_rate_id IS NULL THEN 0
            ELSE ROUND(GREATEST(tr.min_premium_eur,
                         LEAST(ISNULL(tr.max_premium_eur, 999999999),
                               cci.coverage_limit * tr.base_rate_pct / 100.0)), 2)
        END) / 12.0, 2)                      AS MonthlyPremiumEur,
        @ref_date                            AS CalculatedAt
    FROM coverage.ContractCoverageItem cci
    OUTER APPLY (
        SELECT TOP 1
            tariff_rate_id, base_rate_pct, min_premium_eur, max_premium_eur
        FROM finance.TariffRate
        WHERE tenant_id            = @tenant_id
          AND coverage_domain_code = @domain_code
          AND (coverage_type_code  = cci.coverage_type_code OR coverage_type_code = N'*')
          AND effective_from       <= @ref_date
          AND (effective_to IS NULL OR effective_to >= @ref_date)
          AND is_active            = 1
        ORDER BY
            CASE WHEN coverage_type_code = cci.coverage_type_code THEN 0 ELSE 1 END
    ) tr
    WHERE cci.contract_id = @contract_id;
END;
GO

PRINT 'Migration 041 complete: finance.TariffRate + SP_GetTariffRates, SP_UpsertTariffRate, SP_CalculatePremium, SP_GetPremiumSummary.';
GO
