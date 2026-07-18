-- =============================================================================
-- 19  Finance Ledger Cockpit
-- Yafes Pars | Belçika Sigorta | Dubbel Boekhouden Dashboard
-- =============================================================================
-- Gebruik:
--   :setvar TenantId "00000000-0000-0000-0000-000000000001"
--   :setvar FromDate "2026-01-01"
--   :setvar ToDate   "2026-12-31"
--   SQLCMD Mode (Query → SQLCMD Mode) aktif edilmeli.
-- =============================================================================

:setvar TenantId  "00000000-0000-0000-0000-000000000001"
:setvar FromDate  "2026-01-01"
:setvar ToDate    "2026-12-31"

USE [YafesPars];
SET NOCOUNT ON;
GO

-- ---------------------------------------------------------------------------
-- [1] REKENINGPLAN — Chart of Accounts
-- ---------------------------------------------------------------------------
PRINT '=== [1] REKENINGPLAN =================================================';

SELECT
    account_code        AS [Code],
    account_name_nl     AS [Naam (NL)],
    account_type        AS [Type],
    normal_balance      AS [Norm],
    CASE is_active WHEN 1 THEN 'Actief' ELSE 'Inactief' END AS [Status]
FROM finance.LedgerAccount
ORDER BY account_code;
GO

-- ---------------------------------------------------------------------------
-- [2] BALANS OVERZICHT — Account Balances for period
-- ---------------------------------------------------------------------------
PRINT '=== [2] BALANS OVERZICHT ============================================';

EXEC finance.SP_GetLedgerBalance
    @tenant_id    = '$(TenantId)',
    @from_date    = '$(FromDate)',
    @to_date      = '$(ToDate)',
    @account_type = NULL;
GO

-- ---------------------------------------------------------------------------
-- [3] PROEF- EN SALDIBALANS — Trial Balance check (debit = credit)
-- ---------------------------------------------------------------------------
PRINT '=== [3] PROEF- EN SALDIBALANS =======================================';

SELECT
    SUM(debit_eur)  AS [Totaal Debet (EUR)],
    SUM(credit_eur) AS [Totaal Credit (EUR)],
    SUM(debit_eur) - SUM(credit_eur) AS [Verschil (0 = gebalanceerd)],
    COUNT(DISTINCT journal_id)        AS [Aantal Dagboeken],
    COUNT(*)                          AS [Aantal Regels]
FROM finance.LedgerEntry
WHERE tenant_id   = '$(TenantId)'
  AND is_reversed = 0
  AND posting_date BETWEEN '$(FromDate)' AND '$(ToDate)';
GO

-- ---------------------------------------------------------------------------
-- [4] INKOMEN vs KOSTEN — Income Statement summary
-- ---------------------------------------------------------------------------
PRINT '=== [4] INKOMEN vs KOSTEN ===========================================';

WITH bal AS (
    SELECT
        la.account_type,
        SUM(CASE la.normal_balance WHEN 'D'
            THEN le.debit_eur  - le.credit_eur
            ELSE le.credit_eur - le.debit_eur
        END) AS balance_eur
    FROM finance.LedgerEntry le
    JOIN finance.LedgerAccount la ON la.account_code = le.account_code
    WHERE le.tenant_id   = '$(TenantId)'
      AND le.is_reversed = 0
      AND le.posting_date BETWEEN '$(FromDate)' AND '$(ToDate)'
    GROUP BY la.account_type
)
SELECT
    account_type            AS [Type],
    balance_eur             AS [Saldo (EUR)],
    CASE account_type
        WHEN 'INCOME'  THEN 'Opbrengst'
        WHEN 'EXPENSE' THEN 'Kost'
        ELSE                'Balans'
    END                     AS [Categorie]
FROM bal
ORDER BY account_type;
GO

-- ---------------------------------------------------------------------------
-- [5] RECENTE DAGBOEKPOSTEN — Latest 50 journal entries
-- ---------------------------------------------------------------------------
PRINT '=== [5] RECENTE DAGBOEKPOSTEN =======================================';

SELECT TOP 50
    le.posting_date     AS [Boekdatum],
    le.journal_id       AS [Dagboek ID],
    le.account_code     AS [Rek.],
    la.account_name_nl  AS [Rekening],
    le.debit_eur        AS [Debet EUR],
    le.credit_eur       AS [Credit EUR],
    le.source_type      AS [Bron],
    LEFT(le.description, 60) AS [Omschrijving],
    CASE le.is_reversed WHEN 1 THEN 'TERUGGEDRAAID' ELSE '' END AS [Status]
FROM finance.LedgerEntry le
JOIN finance.LedgerAccount la ON la.account_code = le.account_code
WHERE le.tenant_id = '$(TenantId)'
ORDER BY le.posting_date DESC, le.created_at_utc DESC;
GO

-- ---------------------------------------------------------------------------
-- [6] SCHADEKOSTOVERZICHT — Claim cost summary
-- ---------------------------------------------------------------------------
PRINT '=== [6] SCHADEKOSTOVERZICHT ==========================================';

EXEC finance.SP_GetClaimCostSummary
    @tenant_id = '$(TenantId)',
    @claim_id  = NULL,
    @from_date = '$(FromDate)',
    @to_date   = '$(ToDate)';
GO

-- ---------------------------------------------------------------------------
-- [7] BRONTYPE BREAKDOWN — Entries by source_type
-- ---------------------------------------------------------------------------
PRINT '=== [7] BRONTYPE BREAKDOWN ===========================================';

SELECT
    source_type                 AS [Brontype],
    COUNT(DISTINCT journal_id)  AS [Dagboeken],
    COUNT(*)                    AS [Regels],
    SUM(debit_eur)              AS [Debet EUR],
    SUM(credit_eur)             AS [Credit EUR],
    MIN(posting_date)           AS [Eerste Posting],
    MAX(posting_date)           AS [Laatste Posting]
FROM finance.LedgerEntry
WHERE tenant_id   = '$(TenantId)'
  AND is_reversed = 0
  AND posting_date BETWEEN '$(FromDate)' AND '$(ToDate)'
GROUP BY source_type
ORDER BY SUM(debit_eur) DESC;
GO

-- ---------------------------------------------------------------------------
-- [8] TECHNISCHE RESERVE EVOLUTIE — Reserve account (9000) month-by-month
-- ---------------------------------------------------------------------------
PRINT '=== [8] TECHNISCHE RESERVE EVOLUTIE ==================================';

SELECT
    FORMAT(posting_date, 'yyyy-MM') AS [Maand],
    SUM(debit_eur)                  AS [Reserve Toevoeging EUR],
    SUM(credit_eur)                 AS [Reserve Vrijval EUR],
    SUM(credit_eur - debit_eur)     AS [Netto Reserve Saldo EUR]
FROM finance.LedgerEntry
WHERE tenant_id   = '$(TenantId)'
  AND account_code = N'9000'
  AND is_reversed  = 0
  AND posting_date BETWEEN '$(FromDate)' AND '$(ToDate)'
GROUP BY FORMAT(posting_date, 'yyyy-MM')
ORDER BY [Maand];
GO

PRINT '=== Finance Ledger Cockpit klaar. =====================================';
GO
