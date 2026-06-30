-- =============================================================================
-- Migration 034: reporting.SP_FsmaExport
-- FSMA (Autoriteit voor Financiële Diensten en Markten) periodiek rapport.
-- Geeft per tenant geaggregeerde data terug voor regelgevende rapportage.
-- =============================================================================
USE [YafesPars];
GO

BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'034__add_fsma_export_sp')
        INSERT INTO core.SchemaMigration (migration_name, execution_status)
        VALUES (N'034__add_fsma_export_sp', N'SUCCESS');
COMMIT TRANSACTION;
GO

-- Schema aanmaken als het nog niet bestaat.
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'reporting')
    EXEC sp_executesql N'CREATE SCHEMA reporting;';
GO

CREATE OR ALTER PROCEDURE reporting.SP_FsmaExport
    @tenant_id      UNIQUEIDENTIFIER,
    @period_start   DATE,
    @period_end     DATE
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    IF @period_end < @period_start
        THROW 54001, '@period_end mag niet voor @period_start liggen.', 1;

    -- Actieve polissen per tak (branche) in de rapportageperiode.
    SELECT
        'policy_summary'            AS section,
        ISNULL(p.insurance_domain, N'ONBEKEND') AS branche,
        COUNT(*)                    AS aantal_polissen,
        SUM(CAST(p.annual_premium AS DECIMAL(18,4))) AS totaal_premie_eur,
        CONVERT(NVARCHAR(10), @period_start, 120)   AS periode_van,
        CONVERT(NVARCHAR(10), @period_end,   120)   AS periode_tot
    FROM policy.Contract p
    WHERE p.tenant_id = @tenant_id
      AND p.is_deleted = 0
      AND p.start_date <= @period_end
      AND (p.end_date IS NULL OR p.end_date >= @period_start)
    GROUP BY p.insurance_domain

    UNION ALL

    -- Provisietotalen per maand.
    SELECT
        'commission_summary'        AS section,
        FORMAT(c.commission_date, 'yyyy-MM')    AS branche,
        COUNT(*)                    AS aantal_polissen,
        SUM(c.net_commission_eur)   AS totaal_premie_eur,
        CONVERT(NVARCHAR(10), MIN(c.commission_date), 120) AS periode_van,
        CONVERT(NVARCHAR(10), MAX(c.commission_date), 120) AS periode_tot
    FROM finance.Commissions c
    WHERE c.tenant_id = @tenant_id
      AND c.is_deleted = 0
      AND c.commission_date >= @period_start
      AND c.commission_date <= @period_end
    GROUP BY FORMAT(c.commission_date, 'yyyy-MM')

    UNION ALL

    -- Openstaande facturen (OVERDUE) in de periode.
    SELECT
        'overdue_invoices'          AS section,
        N'VERVALLEN'                AS branche,
        COUNT(*)                    AS aantal_polissen,
        SUM(CAST(i.Amount AS DECIMAL(18,4))) AS totaal_premie_eur,
        CONVERT(NVARCHAR(10), MIN(i.DueDate), 120) AS periode_van,
        CONVERT(NVARCHAR(10), MAX(i.DueDate), 120) AS periode_tot
    FROM finance.Invoices i
    WHERE i.TenantId = @tenant_id
      AND i.StatusCode = N'OVERDUE'
      AND i.DueDate >= @period_start
      AND i.DueDate <= @period_end

    ORDER BY section, branche;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

PRINT 'Migration 034 complete: reporting.SP_FsmaExport.';
GO
