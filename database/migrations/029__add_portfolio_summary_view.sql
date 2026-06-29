-- =============================================================================
-- Migration 029: Portefeuille-overzicht / Portföy özeti
-- Adds: reporting.VW_PortfolioSummary (per tenant + tak/domain, rolling 12m
--       premie, schadelast en loss ratio). Geen nieuwe tabellen.
-- =============================================================================
USE [YafesPars];
GO

BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'029__add_portfolio_summary_view')
    BEGIN
        INSERT INTO core.SchemaMigration (migration_name, execution_status)
        VALUES (N'029__add_portfolio_summary_view', N'SUCCESS');
    END

COMMIT TRANSACTION;
GO

IF OBJECT_ID(N'reporting.VW_PortfolioSummary', N'V') IS NOT NULL
    DROP VIEW reporting.VW_PortfolioSummary;
GO
CREATE VIEW reporting.VW_PortfolioSummary AS
SELECT
    c.tenant_id,
    c.contract_domain_code                          AS tak,
    c.contract_status_code                          AS status,
    COUNT(DISTINCT c.contract_id)                   AS contract_count,
    ISNULL(SUM(prem.totaal_premie), 0)              AS totaal_premie_eur,
    ISNULL(SUM(schd.aantal_schaden), 0)             AS totaal_schaden,
    ISNULL(SUM(schd.totaal_gereserveerd), 0)        AS totaal_gereserveerd_eur,
    ISNULL(SUM(schd.totaal_betaald), 0)             AS totaal_betaald_eur,
    CASE
        WHEN ISNULL(SUM(prem.totaal_premie), 0) = 0 THEN NULL
        ELSE ROUND(ISNULL(SUM(schd.totaal_betaald), 0) / SUM(prem.totaal_premie), 4)
    END                                              AS loss_ratio
FROM policy.Contract c
OUTER APPLY (
    SELECT ISNULL(SUM(i.Amount), 0) AS totaal_premie
    FROM finance.Invoices i
    WHERE i.TenantId   = c.tenant_id
      AND i.ContractId = c.contract_id
      AND i.IssueDate  >= DATEADD(MONTH, -12, SYSUTCDATETIME())
) prem
OUTER APPLY (
    SELECT
        COUNT(*)                          AS aantal_schaden,
        ISNULL(SUM(cl.reserved_amount),0) AS totaal_gereserveerd,
        ISNULL(SUM(cl.paid_amount),0)     AS totaal_betaald
    FROM claim.Claim cl
    WHERE cl.tenant_id   = c.tenant_id
      AND cl.contract_id = c.contract_id
) schd
WHERE c.is_deleted = 0
GROUP BY c.tenant_id, c.contract_domain_code, c.contract_status_code;
GO

-- Correctie: rate_pct validatie VOOR de tenant ownership check in SP_RecordCommission
CREATE OR ALTER PROCEDURE finance.SP_RecordCommission
    @tenant_id              UNIQUEIDENTIFIER,
    @contract_id            UNIQUEIDENTIFIER,
    @commission_type_code   NVARCHAR(32)     = N'PRODUCTIE',
    @commission_date        DATE,
    @gross_premium_eur      DECIMAL(18,2),
    @rate_pct               DECIMAL(5,4),
    @broker_person_id       UNIQUEIDENTIFIER = NULL,
    @broker_institution_id  UNIQUEIDENTIFIER = NULL,
    @notes                  NVARCHAR(500)    = NULL,
    @created_by_user_id     UNIQUEIDENTIFIER = NULL,
    @commission_id          UNIQUEIDENTIFIER OUTPUT
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    -- Tarief validatie eerst
    IF @rate_pct <= 0 OR @rate_pct > 1
        THROW 51961, 'Commissietarief moet tussen 0 en 1 liggen (bv. 0.15 = 15%). / Oran 0-1 arasında olmalı.', 1;

    -- Tenant ownership check
    IF NOT EXISTS (
        SELECT 1 FROM policy.Contract
        WHERE contract_id = @contract_id AND tenant_id = @tenant_id AND is_deleted = 0
    )
        THROW 51960, 'Contract niet gevonden voor deze tenant. / Bu tenant için sözleşme bulunamadı.', 1;

    DECLARE @amount DECIMAL(18,2) = ROUND(@gross_premium_eur * @rate_pct, 2);

    INSERT INTO finance.Commissions (
        tenant_id, contract_id, commission_type_code, commission_date,
        gross_premium_eur, rate_pct, commission_eur,
        broker_person_id, broker_institution_id, notes, created_by_user_id
    )
    VALUES (
        @tenant_id, @contract_id, @commission_type_code, @commission_date,
        @gross_premium_eur, @rate_pct, @amount,
        @broker_person_id, @broker_institution_id, @notes, @created_by_user_id
    );

    SET @commission_id = (
        SELECT TOP 1 commission_id
        FROM finance.Commissions
        WHERE contract_id = @contract_id AND tenant_id = @tenant_id
        ORDER BY created_at_utc DESC
    );
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

PRINT 'Migration 029 complete: reporting.VW_PortfolioSummary + SP_RecordCommission fix.';
GO
