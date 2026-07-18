-- =============================================================================
-- Migration 045: Finance double-entry ledger
-- Adds: finance.LedgerEntry, finance.LedgerAccount,
--       finance.SP_PostLedgerEntry, finance.SP_GetLedgerBalance,
--       finance.SP_GetLedgerByContract, finance.SP_GetClaimCostSummary
-- =============================================================================
USE [YafesPars];
GO

BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'045__add_finance_ledger')
    BEGIN

        -- ------------------------------------------------------------------
        -- 1. finance.LedgerAccount — chart of accounts (tenant-shared codes)
        -- ------------------------------------------------------------------
        IF NOT EXISTS (
            SELECT 1 FROM sys.tables
            WHERE schema_id = SCHEMA_ID(N'finance') AND name = N'LedgerAccount'
        )
        BEGIN
            CREATE TABLE finance.LedgerAccount (
                account_code        NVARCHAR(20)    NOT NULL
                                        CONSTRAINT PK_LedgerAccount PRIMARY KEY,
                account_name_nl     NVARCHAR(200)   NOT NULL,
                account_name_fr     NVARCHAR(200)   NULL,
                account_type        NVARCHAR(16)    NOT NULL
                                        CONSTRAINT CK_LedgerAccount_Type CHECK (
                                            account_type IN (
                                                N'ASSET',       -- activa
                                                N'LIABILITY',   -- passiva
                                                N'INCOME',      -- opbrengsten
                                                N'EXPENSE',     -- kosten
                                                N'EQUITY'       -- eigen vermogen
                                            )
                                        ),
                normal_balance      NCHAR(1)        NOT NULL
                                        CONSTRAINT CK_LedgerAccount_NB CHECK (
                                            normal_balance IN (N'D', N'C')
                                        ),
                is_active           BIT             NOT NULL DEFAULT 1,
                created_at_utc      DATETIME2(2)    NOT NULL DEFAULT SYSUTCDATETIME()
            );

            -- Seed: core Belgian insurance accounts
            INSERT INTO finance.LedgerAccount
                (account_code, account_name_nl, account_name_fr, account_type, normal_balance)
            VALUES
                (N'4000', N'Premievorderingen',            N'Primes à recevoir',           N'ASSET',     N'D'),
                (N'4100', N'Commissievorderingen',         N'Commissions à recevoir',       N'ASSET',     N'D'),
                (N'4200', N'Schadebetalingsvorderingen',   N'Sinistres à payer',            N'LIABILITY', N'C'),
                (N'4300', N'Uitgestelde premie-inkomsten', N'Primes différées',             N'LIABILITY', N'C'),
                (N'5000', N'Kasrekening',                  N'Compte de caisse',             N'ASSET',     N'D'),
                (N'6000', N'Schadekost',                   N'Charge sinistres',             N'EXPENSE',   N'D'),
                (N'6100', N'Commissiekost',                N'Charge commissions',           N'EXPENSE',   N'D'),
                (N'6200', N'Reservewijziging',             N'Variation de provision',       N'EXPENSE',   N'D'),
                (N'7000', N'Premie-inkomen',               N'Produit des primes',           N'INCOME',    N'C'),
                (N'7100', N'Interestinkomen',              N'Produit des intérêts',         N'INCOME',    N'C'),
                (N'9000', N'Technische reserve',           N'Provision technique',          N'LIABILITY', N'C');

            PRINT 'finance.LedgerAccount created and seeded.';
        END

        -- ------------------------------------------------------------------
        -- 2. finance.LedgerEntry — double-entry journal lines
        -- ------------------------------------------------------------------
        IF NOT EXISTS (
            SELECT 1 FROM sys.tables
            WHERE schema_id = SCHEMA_ID(N'finance') AND name = N'LedgerEntry'
        )
        BEGIN
            CREATE TABLE finance.LedgerEntry (
                entry_id            UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID()
                                        CONSTRAINT PK_LedgerEntry PRIMARY KEY,
                tenant_id           UNIQUEIDENTIFIER NOT NULL,
                journal_id          UNIQUEIDENTIFIER NOT NULL,   -- groups debit+credit pair
                posting_date        DATE             NOT NULL,
                value_date          DATE             NOT NULL,
                account_code        NVARCHAR(20)     NOT NULL
                                        CONSTRAINT FK_LedgerEntry_Account
                                        REFERENCES finance.LedgerAccount (account_code),
                debit_eur           DECIMAL(18,2)    NOT NULL DEFAULT 0,
                credit_eur          DECIMAL(18,2)    NOT NULL DEFAULT 0,
                currency_code       NCHAR(3)         NOT NULL DEFAULT N'EUR',
                description         NVARCHAR(500)    NULL,
                source_type         NVARCHAR(32)     NOT NULL
                                        CONSTRAINT CK_LedgerEntry_Source CHECK (
                                            source_type IN (
                                                N'PREMIUM',     -- inkassering premie
                                                N'CLAIM',       -- schadebetaling
                                                N'RESERVE',     -- reservewijziging
                                                N'COMMISSION',  -- makelaarscourtage
                                                N'CORRECTION',  -- boekhoudkundige correctie
                                                N'INTEREST',    -- interest
                                                N'TRANSFER'     -- interne overdracht
                                            )
                                        ),
                -- optional links to domain entities
                contract_id         UNIQUEIDENTIFIER NULL,
                claim_id            UNIQUEIDENTIFIER NULL,
                commission_id       UNIQUEIDENTIFIER NULL,
                created_by_user_id  UNIQUEIDENTIFIER NULL,
                created_at_utc      DATETIME2(2)     NOT NULL DEFAULT SYSUTCDATETIME(),
                is_reversed         BIT              NOT NULL DEFAULT 0,
                reversed_by_entry_id UNIQUEIDENTIFIER NULL
                                        CONSTRAINT FK_LedgerEntry_Reversal
                                        REFERENCES finance.LedgerEntry (entry_id)
            );

            -- Indexes for performance
            CREATE INDEX IX_LedgerEntry_Tenant_Date
                ON finance.LedgerEntry (tenant_id, posting_date);
            CREATE INDEX IX_LedgerEntry_Contract
                ON finance.LedgerEntry (contract_id) WHERE contract_id IS NOT NULL;
            CREATE INDEX IX_LedgerEntry_Claim
                ON finance.LedgerEntry (claim_id) WHERE claim_id IS NOT NULL;
            CREATE INDEX IX_LedgerEntry_Account_Date
                ON finance.LedgerEntry (account_code, posting_date);
            CREATE INDEX IX_LedgerEntry_Journal
                ON finance.LedgerEntry (journal_id);
            CREATE INDEX IX_LedgerEntry_Reversal
                ON finance.LedgerEntry (reversed_by_entry_id) WHERE reversed_by_entry_id IS NOT NULL;

            PRINT 'finance.LedgerEntry created.';
        END

        INSERT INTO core.SchemaMigration (migration_name, execution_status)
        VALUES (N'045__add_finance_ledger', N'SUCCESS');

    END

COMMIT TRANSACTION;
GO

-- =============================================================================
-- Stored Procedures (CREATE OR ALTER — idempotent)
-- =============================================================================

-- ---------------------------------------------------------------------------
-- finance.SP_PostLedgerEntry
-- Posts a balanced debit/credit pair in one transaction.
-- Returns the journal_id so the caller can retrieve both lines.
-- ---------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE finance.SP_PostLedgerEntry
    @tenant_id          UNIQUEIDENTIFIER,
    @posting_date       DATE,
    @value_date         DATE              = NULL,
    @debit_account      NVARCHAR(20),
    @credit_account     NVARCHAR(20),
    @amount_eur         DECIMAL(18,2),
    @source_type        NVARCHAR(32),
    @description        NVARCHAR(500)     = NULL,
    @contract_id        UNIQUEIDENTIFIER  = NULL,
    @claim_id           UNIQUEIDENTIFIER  = NULL,
    @commission_id      UNIQUEIDENTIFIER  = NULL,
    @created_by_user_id UNIQUEIDENTIFIER  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @amount_eur <= 0
    BEGIN
        RAISERROR(N'amount_eur moet groter zijn dan 0.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM finance.LedgerAccount WHERE account_code = @debit_account AND is_active = 1)
    BEGIN
        RAISERROR(N'Debet-rekening niet gevonden of inactief: %s', 16, 1, @debit_account);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM finance.LedgerAccount WHERE account_code = @credit_account AND is_active = 1)
    BEGIN
        RAISERROR(N'Credit-rekening niet gevonden of inactief: %s', 16, 1, @credit_account);
        RETURN;
    END

    DECLARE @journal_id UNIQUEIDENTIFIER = NEWID();
    DECLARE @eff_value_date DATE = ISNULL(@value_date, @posting_date);

    BEGIN TRANSACTION;
    BEGIN TRY

        -- Debit line
        INSERT INTO finance.LedgerEntry
            (tenant_id, journal_id, posting_date, value_date,
             account_code, debit_eur, credit_eur,
             source_type, description,
             contract_id, claim_id, commission_id, created_by_user_id)
        VALUES
            (@tenant_id, @journal_id, @posting_date, @eff_value_date,
             @debit_account, @amount_eur, 0,
             @source_type, @description,
             @contract_id, @claim_id, @commission_id, @created_by_user_id);

        -- Credit line
        INSERT INTO finance.LedgerEntry
            (tenant_id, journal_id, posting_date, value_date,
             account_code, debit_eur, credit_eur,
             source_type, description,
             contract_id, claim_id, commission_id, created_by_user_id)
        VALUES
            (@tenant_id, @journal_id, @posting_date, @eff_value_date,
             @credit_account, 0, @amount_eur,
             @source_type, @description,
             @contract_id, @claim_id, @commission_id, @created_by_user_id);

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    -- Return the journal so caller can verify
    -- PascalCase aliases required: Dapper positional record maps by column name (case-insensitive,
    -- no underscore stripping), so snake_case columns would silently map to wrong constructor params.
    SELECT
        le.entry_id       AS EntryId,
        le.journal_id     AS JournalId,
        le.posting_date   AS PostingDate,
        le.account_code   AS AccountCode,
        la.account_name_nl AS AccountNameNl,
        la.account_type   AS AccountType,
        le.debit_eur      AS DebitEur,
        le.credit_eur     AS CreditEur,
        le.source_type    AS SourceType
    FROM finance.LedgerEntry le
    JOIN finance.LedgerAccount la ON la.account_code = le.account_code
    WHERE le.journal_id = @journal_id
    ORDER BY le.debit_eur DESC;  -- debit first
END;
GO

-- ---------------------------------------------------------------------------
-- finance.SP_GetLedgerBalance
-- Returns account balances for a tenant between two dates.
-- ---------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE finance.SP_GetLedgerBalance
    @tenant_id      UNIQUEIDENTIFIER,
    @from_date      DATE             = NULL,
    @to_date        DATE             = NULL,
    @account_type   NVARCHAR(16)     = NULL   -- filter by ASSET/LIABILITY/INCOME/EXPENSE/EQUITY
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        la.account_code                AS AccountCode,
        la.account_name_nl             AS AccountNameNl,
        la.account_type                AS AccountType,
        la.normal_balance              AS NormalBalance,
        ISNULL(SUM(le.debit_eur),  0)  AS TotalDebitEur,
        ISNULL(SUM(le.credit_eur), 0)  AS TotalCreditEur,
        CASE la.normal_balance
            WHEN N'D' THEN ISNULL(SUM(le.debit_eur),  0) - ISNULL(SUM(le.credit_eur), 0)
            ELSE           ISNULL(SUM(le.credit_eur), 0) - ISNULL(SUM(le.debit_eur),  0)
        END                            AS BalanceEur,
        COUNT(le.entry_id)             AS EntryCount
    FROM finance.LedgerAccount la
    LEFT JOIN finance.LedgerEntry le
        ON  le.account_code = la.account_code
        AND le.tenant_id    = @tenant_id
        AND le.is_reversed  = 0
        AND (@from_date IS NULL OR le.posting_date >= @from_date)
        AND (@to_date   IS NULL OR le.posting_date <= @to_date)
    WHERE la.is_active = 1
      AND (@account_type IS NULL OR la.account_type = @account_type)
    GROUP BY
        la.account_code, la.account_name_nl, la.account_type, la.normal_balance
    ORDER BY
        la.account_code;
END;
GO

-- ---------------------------------------------------------------------------
-- finance.SP_GetLedgerByContract
-- Returns all ledger lines for a specific contract.
-- ---------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE finance.SP_GetLedgerByContract
    @tenant_id      UNIQUEIDENTIFIER,
    @contract_id    UNIQUEIDENTIFIER,
    @limit          INT              = 100
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@limit)
        le.entry_id       AS EntryId,
        le.journal_id     AS JournalId,
        le.posting_date   AS PostingDate,
        le.account_code   AS AccountCode,
        la.account_name_nl AS AccountNameNl,
        la.account_type   AS AccountType,
        le.debit_eur      AS DebitEur,
        le.credit_eur     AS CreditEur,
        le.source_type    AS SourceType
    FROM finance.LedgerEntry le
    JOIN finance.LedgerAccount la ON la.account_code = le.account_code
    WHERE le.tenant_id   = @tenant_id
      AND le.contract_id = @contract_id
    ORDER BY le.posting_date DESC, le.created_at_utc DESC;
END;
GO

-- ---------------------------------------------------------------------------
-- finance.SP_GetClaimCostSummary
-- Aggregates ledger EXPENSE + RESERVE lines per claim.
-- ---------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE finance.SP_GetClaimCostSummary
    @tenant_id      UNIQUEIDENTIFIER,
    @claim_id       UNIQUEIDENTIFIER = NULL,   -- NULL = all claims for tenant
    @from_date      DATE             = NULL,
    @to_date        DATE             = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Only EXPENSE-side (debit) lines represent real outflow per journal.
    -- Both debit and credit lines share the same claim_id, so SUM(debit-credit)
    -- cancels to zero for every balanced posting. Summing debit_eur restricted
    -- to EXPENSE accounts avoids the cancellation and correctly measures outflow.
    SELECT
        le.claim_id                                                                   AS ClaimId,
        SUM(CASE WHEN le.source_type = N'CLAIM'   THEN le.debit_eur ELSE 0 END)     AS PaidEur,
        SUM(CASE WHEN le.source_type = N'RESERVE' THEN le.debit_eur ELSE 0 END)     AS ReservedEur,
        SUM(le.debit_eur)                                                             AS NetCostEur,
        COUNT(DISTINCT le.journal_id)                                                 AS PostingCount,
        MIN(le.posting_date)                                                          AS FirstPosting,
        MAX(le.posting_date)                                                          AS LastPosting
    FROM finance.LedgerEntry le
    JOIN finance.LedgerAccount la ON la.account_code = le.account_code
    WHERE le.tenant_id   = @tenant_id
      AND le.is_reversed = 0
      AND le.claim_id IS NOT NULL
      AND la.account_type = N'EXPENSE'
      AND le.source_type IN (N'CLAIM', N'RESERVE', N'CORRECTION')
      AND (@claim_id  IS NULL OR le.claim_id     = @claim_id)
      AND (@from_date IS NULL OR le.posting_date >= @from_date)
      AND (@to_date   IS NULL OR le.posting_date <= @to_date)
    GROUP BY le.claim_id
    ORDER BY net_cost_eur DESC;
END;
GO

PRINT 'Migration 045 complete: finance.LedgerAccount + finance.LedgerEntry + 4 SPs.';
GO
