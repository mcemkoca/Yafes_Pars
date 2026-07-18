-- =============================================================================
-- Migration 046: Commission domain integrity + FSMA export correctness
--
-- Addresses gaps identified in Faz 18 audit:
--   1. finance.Commissions had no FK constraints (contract, broker entities).
--   2. finance.LedgerEntry.commission_id had no FK to finance.Commissions.
--   3. SP_FsmaExport exported CANCELLED commissions (regulatory error).
--   4. No composite (tenant_id, commission_date) index for FSMA query path.
-- =============================================================================
USE [YafesPars];
GO

BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'046__add_commission_integrity')
    BEGIN

        -- ------------------------------------------------------------------
        -- 1. FK: finance.Commissions.contract_id → policy.Contract
        -- ------------------------------------------------------------------
        IF NOT EXISTS (
            SELECT 1 FROM sys.foreign_keys
            WHERE name = N'FK_Commissions_Contract'
              AND parent_object_id = OBJECT_ID(N'finance.Commissions')
        )
            ALTER TABLE finance.Commissions
                ADD CONSTRAINT FK_Commissions_Contract
                FOREIGN KEY (contract_id) REFERENCES policy.Contract (contract_id);

        -- ------------------------------------------------------------------
        -- 2. FK: finance.Commissions.broker_person_id → person.NaturalPerson
        -- ------------------------------------------------------------------
        IF NOT EXISTS (
            SELECT 1 FROM sys.foreign_keys
            WHERE name = N'FK_Commissions_BrokerPerson'
              AND parent_object_id = OBJECT_ID(N'finance.Commissions')
        )
            ALTER TABLE finance.Commissions
                ADD CONSTRAINT FK_Commissions_BrokerPerson
                FOREIGN KEY (broker_person_id) REFERENCES person.NaturalPerson (person_id);

        -- ------------------------------------------------------------------
        -- 3. FK: finance.Commissions.broker_institution_id → institution.Institution
        -- ------------------------------------------------------------------
        IF NOT EXISTS (
            SELECT 1 FROM sys.foreign_keys
            WHERE name = N'FK_Commissions_BrokerInstitution'
              AND parent_object_id = OBJECT_ID(N'finance.Commissions')
        )
            ALTER TABLE finance.Commissions
                ADD CONSTRAINT FK_Commissions_BrokerInstitution
                FOREIGN KEY (broker_institution_id) REFERENCES institution.Institution (institution_id);

        -- ------------------------------------------------------------------
        -- 4. FK: finance.LedgerEntry.commission_id → finance.Commissions
        --    (commission_id was added in migration 045 but FK was omitted)
        -- ------------------------------------------------------------------
        IF NOT EXISTS (
            SELECT 1 FROM sys.foreign_keys
            WHERE name = N'FK_LedgerEntry_Commission'
              AND parent_object_id = OBJECT_ID(N'finance.LedgerEntry')
        )
            ALTER TABLE finance.LedgerEntry
                ADD CONSTRAINT FK_LedgerEntry_Commission
                FOREIGN KEY (commission_id) REFERENCES finance.Commissions (commission_id);

        -- ------------------------------------------------------------------
        -- 5. Composite index: (tenant_id, commission_date) for FSMA export
        --    SP_FsmaExport WHERE clause: tenant_id = @x AND commission_date BETWEEN ...
        -- ------------------------------------------------------------------
        IF NOT EXISTS (
            SELECT 1 FROM sys.indexes
            WHERE name = N'IX_Commissions_Tenant_Date'
              AND object_id = OBJECT_ID(N'finance.Commissions')
        )
            CREATE INDEX IX_Commissions_Tenant_Date
                ON finance.Commissions (tenant_id, commission_date)
                INCLUDE (commission_eur, status_code, is_deleted);

        -- ------------------------------------------------------------------
        -- 6. Supporting filtered index for FK_LedgerEntry_Commission
        --    (validation 012 checks every FK column has a supporting index)
        -- ------------------------------------------------------------------
        IF NOT EXISTS (
            SELECT 1 FROM sys.indexes
            WHERE name = N'IX_LedgerEntry_Commission'
              AND object_id = OBJECT_ID(N'finance.LedgerEntry')
        )
            CREATE INDEX IX_LedgerEntry_Commission
                ON finance.LedgerEntry (commission_id)
                WHERE commission_id IS NOT NULL;

        INSERT INTO core.SchemaMigration (migration_name, execution_status)
        VALUES (N'046__add_commission_integrity', N'SUCCESS');

        PRINT 'Migration 046: FK constraints + indexes added to finance.Commissions and finance.LedgerEntry.';
    END

COMMIT TRANSACTION;
GO

-- =============================================================================
-- Fix SP_FsmaExport: exclude CANCELLED commissions from regulatory export.
-- CANCELLED commissions must not appear in FSMA reporting (art. 12bis IDD).
-- This CREATE OR ALTER is idempotent; the original is in migration 034.
-- =============================================================================
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

    -- Actieve polissen per tak (contract_domain_code) in de rapportageperiode.
    -- PascalCase aliases required: Dapper positional records map by column name
    -- (case-insensitive, no underscore stripping).
    SELECT
        'policy_summary'                                    AS Section,
        ISNULL(c.contract_domain_code, N'ONBEKEND')        AS Branche,
        COUNT(*)                                            AS AantalPolissen,
        CAST(0 AS DECIMAL(18,4))                           AS TotaalPremieEur,
        CONVERT(NVARCHAR(10), @period_start, 120)          AS PeriodeVan,
        CONVERT(NVARCHAR(10), @period_end,   120)          AS PeriodeTot
    FROM policy.Contract c
    WHERE c.tenant_id = @tenant_id
      AND c.is_deleted = 0
      AND c.start_date <= @period_end
      AND (c.end_date IS NULL OR c.end_date >= @period_start)
    GROUP BY c.contract_domain_code

    UNION ALL

    -- Provisietotalen per maand — CANCELLED commissies worden uitgesloten
    -- (IDD art. 12bis: enkel definitief erkende commissies rapporteren).
    SELECT
        'commission_summary'                               AS Section,
        FORMAT(cm.commission_date, 'yyyy-MM')             AS Branche,
        COUNT(*)                                           AS AantalPolissen,
        SUM(CAST(cm.commission_eur AS DECIMAL(18,4)))     AS TotaalPremieEur,
        CONVERT(NVARCHAR(10), MIN(cm.commission_date), 120) AS PeriodeVan,
        CONVERT(NVARCHAR(10), MAX(cm.commission_date), 120) AS PeriodeTot
    FROM finance.Commissions cm
    WHERE cm.tenant_id   = @tenant_id
      AND cm.is_deleted  = 0
      AND cm.status_code <> N'CANCELLED'
      AND cm.commission_date >= @period_start
      AND cm.commission_date <= @period_end
    GROUP BY FORMAT(cm.commission_date, 'yyyy-MM')

    UNION ALL

    -- Openstaande facturen (OVERDUE) in de periode.
    SELECT
        'overdue_invoices'                                 AS Section,
        N'VERVALLEN'                                       AS Branche,
        COUNT(*)                                           AS AantalPolissen,
        SUM(CAST(i.Amount AS DECIMAL(18,4)))              AS TotaalPremieEur,
        CONVERT(NVARCHAR(10), MIN(i.DueDate), 120)        AS PeriodeVan,
        CONVERT(NVARCHAR(10), MAX(i.DueDate), 120)        AS PeriodeTot
    FROM finance.Invoices i
    WHERE i.TenantId   = @tenant_id
      AND i.StatusCode = N'OVERDUE'
      AND i.DueDate   >= @period_start
      AND i.DueDate   <= @period_end

    ORDER BY Section, Branche;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

PRINT 'Migration 046 complete: SP_FsmaExport updated — CANCELLED commissions excluded from export.';
GO
