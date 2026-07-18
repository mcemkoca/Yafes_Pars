/*
    Yafes Pars SSMS Workbench - Finance Ledger Cockpit

    INFO TIP:
    Double-entry ledger dashboard for Belgian insurance finance operations.
    Shows chart of accounts, trial balance, P&L summary, claim costs, and
    reserve evolution. Run with SQLCMD Mode enabled against a DEV database.

    Enable SQLCMD Mode before running (Query → SQLCMD Mode).
    Read-only — no data modifications performed by this script.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE         "DEV-BE-BROKER"
:setvar FROM_DATE           "2026-01-01"
:setvar TO_DATE             "2026-12-31"

SET NOCOUNT ON;
GO

-- DEV guard
USE [master];
GO

DECLARE @TargetDatabase SYSNAME = N'$(YAFES_SQL_DATABASE)';
IF @TargetDatabase NOT LIKE N'%DEV%'
    THROW 52019, 'Target database name must contain DEV.', 1;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

DECLARE @TenantCode NVARCHAR(80) = N'$(TENANT_CODE)';
DECLARE @TenantId   UNIQUEIDENTIFIER;

SELECT @TenantId = tenant_id
FROM core.Tenant
WHERE tenant_code = @TenantCode;

IF @TenantId IS NULL
    THROW 52019, 'Tenant code was not found in core.Tenant.', 1;

-- -------------------------------------------------------------------------
-- [1] REKENINGPLAN — Chart of Accounts
-- -------------------------------------------------------------------------
PRINT '01 - Rekeningplan (Chart of Accounts)';

SELECT
    account_code        AS [Code],
    account_name_nl     AS [Naam (NL)],
    account_type        AS [Type],
    normal_balance      AS [Norm],
    CASE is_active WHEN 1 THEN 'Actief' ELSE 'Inactief' END AS [Status]
FROM finance.LedgerAccount
ORDER BY account_code;
GO

-- -------------------------------------------------------------------------
-- [2] BALANS OVERZICHT — Account Balances
-- -------------------------------------------------------------------------
PRINT '02 - Balans overzicht (Account Balances)';

DECLARE @TenantId UNIQUEIDENTIFIER;
SELECT @TenantId = tenant_id FROM core.Tenant WHERE tenant_code = N'$(TENANT_CODE)';

EXEC finance.SP_GetLedgerBalance
    @tenant_id    = @TenantId,
    @from_date    = '$(FROM_DATE)',
    @to_date      = '$(TO_DATE)',
    @account_type = NULL;
GO

-- -------------------------------------------------------------------------
-- [3] PROEF- EN SALDIBALANS — Trial Balance check
-- -------------------------------------------------------------------------
PRINT '03 - Proef- en Saldibalans (Trial Balance)';

DECLARE @TenantId UNIQUEIDENTIFIER;
SELECT @TenantId = tenant_id FROM core.Tenant WHERE tenant_code = N'$(TENANT_CODE)';

SELECT
    SUM(debit_eur)  AS [Totaal Debet (EUR)],
    SUM(credit_eur) AS [Totaal Credit (EUR)],
    SUM(debit_eur) - SUM(credit_eur) AS [Verschil (0 = gebalanceerd)],
    COUNT(DISTINCT journal_id)        AS [Aantal Dagboeken],
    COUNT(*)                          AS [Aantal Regels]
FROM finance.LedgerEntry
WHERE tenant_id   = @TenantId
  AND is_reversed = 0
  AND posting_date BETWEEN '$(FROM_DATE)' AND '$(TO_DATE)';
GO

-- -------------------------------------------------------------------------
-- [4] INKOMEN vs KOSTEN — P&L Summary
-- -------------------------------------------------------------------------
PRINT '04 - Inkomen vs Kosten (P&L Summary)';

DECLARE @TenantId UNIQUEIDENTIFIER;
SELECT @TenantId = tenant_id FROM core.Tenant WHERE tenant_code = N'$(TENANT_CODE)';

WITH bal AS (
    SELECT
        la.account_type,
        SUM(CASE la.normal_balance WHEN N'D'
            THEN le.debit_eur  - le.credit_eur
            ELSE le.credit_eur - le.debit_eur
        END) AS balance_eur
    FROM finance.LedgerEntry le
    JOIN finance.LedgerAccount la ON la.account_code = le.account_code
    WHERE le.tenant_id   = @TenantId
      AND le.is_reversed = 0
      AND le.posting_date BETWEEN '$(FROM_DATE)' AND '$(TO_DATE)'
    GROUP BY la.account_type
)
SELECT
    account_type   AS [Type],
    balance_eur    AS [Saldo (EUR)],
    CASE account_type
        WHEN N'INCOME'  THEN N'Opbrengst'
        WHEN N'EXPENSE' THEN N'Kost'
        ELSE                 N'Balans'
    END            AS [Categorie]
FROM bal
ORDER BY account_type;
GO

-- -------------------------------------------------------------------------
-- [5] RECENTE DAGBOEKPOSTEN — Latest 50 journal entries
-- -------------------------------------------------------------------------
PRINT '05 - Recente dagboekposten (Recent Journal Entries)';

DECLARE @TenantId UNIQUEIDENTIFIER;
SELECT @TenantId = tenant_id FROM core.Tenant WHERE tenant_code = N'$(TENANT_CODE)';

SELECT TOP 50
    le.posting_date     AS [Boekdatum],
    le.journal_id       AS [Dagboek ID],
    le.account_code     AS [Rek.],
    la.account_name_nl  AS [Rekening],
    le.debit_eur        AS [Debet EUR],
    le.credit_eur       AS [Credit EUR],
    le.source_type      AS [Bron],
    LEFT(ISNULL(le.description, N''), 60) AS [Omschrijving],
    CASE le.is_reversed WHEN 1 THEN N'TERUGGEDRAAID' ELSE N'' END AS [Status]
FROM finance.LedgerEntry le
JOIN finance.LedgerAccount la ON la.account_code = le.account_code
WHERE le.tenant_id = @TenantId
ORDER BY le.posting_date DESC, le.created_at_utc DESC;
GO

-- -------------------------------------------------------------------------
-- [6] SCHADEKOSTOVERZICHT — Claim cost summary
-- -------------------------------------------------------------------------
PRINT '06 - Schadekostoverzicht (Claim Cost Summary)';

DECLARE @TenantId UNIQUEIDENTIFIER;
SELECT @TenantId = tenant_id FROM core.Tenant WHERE tenant_code = N'$(TENANT_CODE)';

EXEC finance.SP_GetClaimCostSummary
    @tenant_id = @TenantId,
    @claim_id  = NULL,
    @from_date = '$(FROM_DATE)',
    @to_date   = '$(TO_DATE)';
GO

-- -------------------------------------------------------------------------
-- [7] BRONTYPE BREAKDOWN — Entries by source_type
-- -------------------------------------------------------------------------
PRINT '07 - Brontype breakdown (Source Type Breakdown)';

DECLARE @TenantId UNIQUEIDENTIFIER;
SELECT @TenantId = tenant_id FROM core.Tenant WHERE tenant_code = N'$(TENANT_CODE)';

SELECT
    source_type                 AS [Brontype],
    COUNT(DISTINCT journal_id)  AS [Dagboeken],
    COUNT(*)                    AS [Regels],
    SUM(debit_eur)              AS [Debet EUR],
    SUM(credit_eur)             AS [Credit EUR],
    MIN(posting_date)           AS [Eerste Posting],
    MAX(posting_date)           AS [Laatste Posting]
FROM finance.LedgerEntry
WHERE tenant_id   = @TenantId
  AND is_reversed = 0
  AND posting_date BETWEEN '$(FROM_DATE)' AND '$(TO_DATE)'
GROUP BY source_type
ORDER BY SUM(debit_eur) DESC;
GO

-- -------------------------------------------------------------------------
-- [8] TECHNISCHE RESERVE EVOLUTIE — Reserve account month-by-month
-- -------------------------------------------------------------------------
PRINT '08 - Technische reserve evolutie (Reserve Evolution)';

DECLARE @TenantId UNIQUEIDENTIFIER;
SELECT @TenantId = tenant_id FROM core.Tenant WHERE tenant_code = N'$(TENANT_CODE)';

SELECT
    FORMAT(posting_date, 'yyyy-MM') AS [Maand],
    SUM(debit_eur)                  AS [Reserve Toevoeging EUR],
    SUM(credit_eur)                 AS [Reserve Vrijval EUR],
    SUM(credit_eur - debit_eur)     AS [Netto Reserve Saldo EUR]
FROM finance.LedgerEntry
WHERE tenant_id    = @TenantId
  AND account_code  = N'9000'
  AND is_reversed   = 0
  AND posting_date BETWEEN '$(FROM_DATE)' AND '$(TO_DATE)'
GROUP BY FORMAT(posting_date, 'yyyy-MM')
ORDER BY [Maand];
GO

PRINT 'Finance Ledger Cockpit klaar. / Finance Ledger Cockpit voltooid.';
GO
