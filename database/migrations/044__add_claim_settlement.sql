-- =============================================================================
-- Migration 044: Claim afwikkeling workflow
-- ClaimSettlement: aanbod/akkoord tracking, reserve-mutaties, uitbetalingen.
-- SP_CreateSettlement, SP_ApproveSettlement, SP_GetClaimSettlementSummary.
-- =============================================================================
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [YafesPars];
GO

PRINT 'Running migration: 044__add_claim_settlement.sql';
GO

-- -----------------------------------------------------------------------------
-- 1. claim.ClaimSettlement — schikkingsaanboden en goedkeuringen
-- -----------------------------------------------------------------------------
IF OBJECT_ID(N'claim.ClaimSettlement', N'U') IS NULL
BEGIN
    CREATE TABLE claim.ClaimSettlement (
        settlement_id           UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_ClaimSettlement_id DEFAULT NEWSEQUENTIALID(),
        claim_id                UNIQUEIDENTIFIER NOT NULL,
        tenant_id               UNIQUEIDENTIFIER NOT NULL,
        settlement_status_code  NVARCHAR(40)     NOT NULL
            CONSTRAINT DF_ClaimSettlement_status DEFAULT N'DRAFT',
        offer_amount_eur        DECIMAL(18,2)    NOT NULL,
        agreed_amount_eur       DECIMAL(18,2)    NULL,
        offered_at_utc          DATETIME2(0)     NOT NULL
            CONSTRAINT DF_ClaimSettlement_offered_at DEFAULT SYSUTCDATETIME(),
        approved_at_utc         DATETIME2(0)     NULL,
        paid_at_utc             DATETIME2(0)     NULL,
        iban                    NVARCHAR(34)     NULL,
        payment_reference       NVARCHAR(50)     NULL,
        notes                   NVARCHAR(500)    NULL,
        created_by_user_id      UNIQUEIDENTIFIER NULL,
        updated_by_user_id      UNIQUEIDENTIFIER NULL,
        created_at_utc          DATETIME2(0)     NOT NULL
            CONSTRAINT DF_ClaimSettlement_created_at DEFAULT SYSUTCDATETIME(),
        updated_at_utc          DATETIME2(0)     NOT NULL
            CONSTRAINT DF_ClaimSettlement_updated_at DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_ClaimSettlement PRIMARY KEY (settlement_id),
        CONSTRAINT FK_ClaimSettlement_Claim FOREIGN KEY (claim_id)
            REFERENCES claim.Claim (claim_id),
        CONSTRAINT CK_ClaimSettlement_status CHECK (
            settlement_status_code IN (N'DRAFT', N'OFFERED', N'APPROVED', N'PAID', N'REJECTED', N'WITHDRAWN')
        ),
        CONSTRAINT CK_ClaimSettlement_agreed_amount CHECK (
            agreed_amount_eur IS NULL OR agreed_amount_eur >= 0
        ),
        CONSTRAINT CK_ClaimSettlement_offer_amount CHECK (
            offer_amount_eur >= 0
        )
    );

    PRINT '  Table claim.ClaimSettlement created.';
END;
GO

-- -----------------------------------------------------------------------------
-- 2. claim.ClaimReserveLog — reserve-wijzigingen bijhouden
-- -----------------------------------------------------------------------------
IF OBJECT_ID(N'claim.ClaimReserveLog', N'U') IS NULL
BEGIN
    CREATE TABLE claim.ClaimReserveLog (
        reserve_log_id      UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_ClaimReserveLog_id DEFAULT NEWSEQUENTIALID(),
        claim_id            UNIQUEIDENTIFIER NOT NULL,
        tenant_id           UNIQUEIDENTIFIER NOT NULL,
        previous_reserve    DECIMAL(18,2)    NULL,
        new_reserve         DECIMAL(18,2)    NOT NULL,
        delta_amount        DECIMAL(18,2)    NOT NULL,
        reason_code         NVARCHAR(40)     NOT NULL
            CONSTRAINT DF_ClaimReserveLog_reason DEFAULT N'MANUAL',
        notes               NVARCHAR(500)    NULL,
        changed_by_user_id  UNIQUEIDENTIFIER NULL,
        changed_at_utc      DATETIME2(0)     NOT NULL
            CONSTRAINT DF_ClaimReserveLog_changed_at DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_ClaimReserveLog PRIMARY KEY (reserve_log_id),
        CONSTRAINT FK_ClaimReserveLog_Claim FOREIGN KEY (claim_id)
            REFERENCES claim.Claim (claim_id),
        CONSTRAINT CK_ClaimReserveLog_reason CHECK (
            reason_code IN (N'INITIAL', N'ADJUSTMENT', N'SETTLEMENT', N'RECOVERY', N'MANUAL')
        )
    );

    PRINT '  Table claim.ClaimReserveLog created.';
END;
GO

-- -----------------------------------------------------------------------------
-- 3. Indexen
-- -----------------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_ClaimSettlement_claim'
      AND object_id = OBJECT_ID(N'claim.ClaimSettlement')
)
    CREATE INDEX IX_ClaimSettlement_claim
    ON claim.ClaimSettlement (claim_id, settlement_status_code);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_ClaimReserveLog_claim'
      AND object_id = OBJECT_ID(N'claim.ClaimReserveLog')
)
    CREATE INDEX IX_ClaimReserveLog_claim
    ON claim.ClaimReserveLog (claim_id, changed_at_utc DESC);
GO

-- -----------------------------------------------------------------------------
-- 4. SP_CreateSettlement — nieuw schikkingsaanbod aanmaken
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE claim.SP_CreateSettlement
    @tenant_id          UNIQUEIDENTIFIER,
    @claim_id           UNIQUEIDENTIFIER,
    @offer_amount_eur   DECIMAL(18,2),
    @iban               NVARCHAR(34)    = NULL,
    @notes              NVARCHAR(500)   = NULL,
    @created_by         UNIQUEIDENTIFIER = NULL,
    @dry_run            BIT             = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @settlement_id UNIQUEIDENTIFIER = NEWID();
    DECLARE @claim_status  NVARCHAR(40);
    DECLARE @current_reserve DECIMAL(18,2);

    -- Tenant guard
    SELECT @claim_status = c.claim_status_code,
           @current_reserve = c.reserved_amount
    FROM claim.Claim c
    WHERE c.claim_id = @claim_id
      AND c.tenant_id = @tenant_id
      AND c.is_deleted = 0;

    IF @claim_status IS NULL
    BEGIN
        SELECT 'CLAIM_NOT_FOUND' AS error_code;
        RETURN;
    END;

    IF @claim_status NOT IN (N'OPEN', N'UNDER_INVESTIGATION', N'PENDING_PAYMENT')
    BEGIN
        SELECT 'INVALID_CLAIM_STATUS' AS error_code, @claim_status AS current_status;
        RETURN;
    END;

    IF @offer_amount_eur <= 0
    BEGIN
        SELECT 'INVALID_AMOUNT' AS error_code;
        RETURN;
    END;

    IF @dry_run = 1
    BEGIN
        SELECT
            @claim_id           AS claim_id,
            @settlement_id      AS settlement_id,
            @offer_amount_eur   AS offer_amount_eur,
            @claim_status       AS claim_status,
            'DRY_RUN'           AS result;
        RETURN;
    END;

    INSERT INTO claim.ClaimSettlement (
        settlement_id, claim_id, tenant_id, settlement_status_code,
        offer_amount_eur, iban, notes, created_by_user_id, updated_by_user_id
    )
    VALUES (
        @settlement_id, @claim_id, @tenant_id, N'OFFERED',
        @offer_amount_eur, @iban, @notes, @created_by, @created_by
    );

    SELECT
        @settlement_id  AS settlement_id,
        @claim_id       AS claim_id,
        'OFFERED'       AS settlement_status_code,
        @offer_amount_eur AS offer_amount_eur;
END;
GO

-- -----------------------------------------------------------------------------
-- 5. SP_ApproveSettlement — schikking goedkeuren en uitbetalen
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE claim.SP_ApproveSettlement
    @tenant_id          UNIQUEIDENTIFIER,
    @settlement_id      UNIQUEIDENTIFIER,
    @agreed_amount_eur  DECIMAL(18,2)   = NULL,
    @payment_reference  NVARCHAR(50)    = NULL,
    @approved_by        UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @claim_id           UNIQUEIDENTIFIER;
    DECLARE @offer_amount       DECIMAL(18,2);
    DECLARE @settlement_status  NVARCHAR(40);
    DECLARE @current_reserve    DECIMAL(18,2);
    DECLARE @final_amount       DECIMAL(18,2);

    SELECT
        @claim_id          = s.claim_id,
        @offer_amount      = s.offer_amount_eur,
        @settlement_status = s.settlement_status_code
    FROM claim.ClaimSettlement s
    WHERE s.settlement_id = @settlement_id
      AND s.tenant_id     = @tenant_id;

    IF @claim_id IS NULL
    BEGIN
        SELECT 'SETTLEMENT_NOT_FOUND' AS error_code;
        RETURN;
    END;

    IF @settlement_status <> N'OFFERED'
    BEGIN
        SELECT 'INVALID_SETTLEMENT_STATUS' AS error_code, @settlement_status AS current_status;
        RETURN;
    END;

    SET @final_amount = ISNULL(@agreed_amount_eur, @offer_amount);
    IF @final_amount <= 0
    BEGIN
        SELECT 'INVALID_AMOUNT' AS error_code;
        RETURN;
    END;

    -- Huidige reserve ophalen
    SELECT @current_reserve = c.reserved_amount
    FROM claim.Claim c
    WHERE c.claim_id = @claim_id AND c.tenant_id = @tenant_id;

    BEGIN TRANSACTION;

    -- Settlement goedkeuren
    UPDATE claim.ClaimSettlement
    SET settlement_status_code = N'PAID',
        agreed_amount_eur      = @final_amount,
        approved_at_utc        = SYSUTCDATETIME(),
        paid_at_utc            = SYSUTCDATETIME(),
        payment_reference      = @payment_reference,
        updated_by_user_id     = @approved_by,
        updated_at_utc         = SYSUTCDATETIME()
    WHERE settlement_id = @settlement_id;

    -- Claim bijwerken
    UPDATE claim.Claim
    SET paid_amount         = ISNULL(paid_amount, 0) + @final_amount,
        reserved_amount     = CASE
                                  WHEN ISNULL(reserved_amount, 0) <= @final_amount
                                  THEN 0
                                  ELSE reserved_amount - @final_amount
                              END,
        claim_status_code   = N'CLOSED',
        closed_date         = CAST(SYSUTCDATETIME() AS DATE),
        updated_at_utc      = SYSUTCDATETIME(),
        updated_by_user_id  = @approved_by
    WHERE claim_id  = @claim_id
      AND tenant_id = @tenant_id;

    -- Reserve log
    INSERT INTO claim.ClaimReserveLog (
        claim_id, tenant_id, previous_reserve, new_reserve, delta_amount,
        reason_code, notes, changed_by_user_id
    )
    VALUES (
        @claim_id, @tenant_id,
        @current_reserve,
        CASE WHEN ISNULL(@current_reserve, 0) <= @final_amount THEN 0
             ELSE @current_reserve - @final_amount END,
        -@final_amount,
        N'SETTLEMENT',
        N'Schikking goedgekeurd: ' + @settlement_id,
        @approved_by
    );

    COMMIT TRANSACTION;

    SELECT
        @settlement_id  AS settlement_id,
        @claim_id       AS claim_id,
        @final_amount   AS paid_amount,
        'PAID'          AS settlement_status_code;
END;
GO

-- -----------------------------------------------------------------------------
-- 6. SP_UpdateClaimReserve — reserve manueel bijstellen
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE claim.SP_UpdateClaimReserve
    @tenant_id      UNIQUEIDENTIFIER,
    @claim_id       UNIQUEIDENTIFIER,
    @new_reserve    DECIMAL(18,2),
    @reason_code    NVARCHAR(40)    = N'MANUAL',
    @notes          NVARCHAR(500)   = NULL,
    @changed_by     UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @current_reserve DECIMAL(18,2);
    DECLARE @claim_status    NVARCHAR(40);

    SELECT @current_reserve = c.reserved_amount,
           @claim_status    = c.claim_status_code
    FROM claim.Claim c
    WHERE c.claim_id = @claim_id
      AND c.tenant_id = @tenant_id
      AND c.is_deleted = 0;

    IF @claim_status IS NULL
    BEGIN
        SELECT 'CLAIM_NOT_FOUND' AS error_code;
        RETURN;
    END;

    IF @claim_status IN (N'CLOSED', N'WITHDRAWN')
    BEGIN
        SELECT 'CLAIM_ALREADY_CLOSED' AS error_code;
        RETURN;
    END;

    IF @new_reserve < 0
    BEGIN
        SELECT 'INVALID_RESERVE' AS error_code;
        RETURN;
    END;

    UPDATE claim.Claim
    SET reserved_amount    = @new_reserve,
        updated_at_utc     = SYSUTCDATETIME(),
        updated_by_user_id = @changed_by
    WHERE claim_id  = @claim_id
      AND tenant_id = @tenant_id;

    INSERT INTO claim.ClaimReserveLog (
        claim_id, tenant_id, previous_reserve, new_reserve, delta_amount,
        reason_code, notes, changed_by_user_id
    )
    VALUES (
        @claim_id, @tenant_id,
        @current_reserve,
        @new_reserve,
        @new_reserve - ISNULL(@current_reserve, 0),
        @reason_code,
        @notes,
        @changed_by
    );

    SELECT
        @claim_id           AS claim_id,
        @current_reserve    AS previous_reserve,
        @new_reserve        AS new_reserve;
END;
GO

-- -----------------------------------------------------------------------------
-- 7. SP_GetClaimSettlementSummary — overzicht per claim
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE claim.SP_GetClaimSettlementSummary
    @tenant_id  UNIQUEIDENTIFIER,
    @claim_id   UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @domain_check NVARCHAR(40);

    IF @claim_id IS NOT NULL
    BEGIN
        SELECT @domain_check = claim_status_code
        FROM claim.Claim
        WHERE claim_id = @claim_id AND tenant_id = @tenant_id;

        IF @domain_check IS NULL
        BEGIN
            SELECT TOP 0 * FROM claim.ClaimSettlement WHERE 1 = 0;
            RETURN;
        END;
    END;

    SELECT
        c.claim_id,
        c.claim_number,
        c.claim_status_code,
        c.reserved_amount,
        c.paid_amount,
        s.settlement_id,
        s.settlement_status_code,
        s.offer_amount_eur,
        s.agreed_amount_eur,
        s.offered_at_utc,
        s.approved_at_utc,
        s.paid_at_utc,
        s.payment_reference
    FROM claim.Claim c
    LEFT JOIN claim.ClaimSettlement s ON s.claim_id = c.claim_id
    WHERE c.tenant_id = @tenant_id
      AND c.is_deleted = 0
      AND (@claim_id IS NULL OR c.claim_id = @claim_id)
    ORDER BY c.claim_number, s.offered_at_utc DESC;
END;
GO

-- -----------------------------------------------------------------------------
-- 8. SP_GetReserveLog — reserve-wijzigingen per claim
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE claim.SP_GetReserveLog
    @tenant_id  UNIQUEIDENTIFIER,
    @claim_id   UNIQUEIDENTIFIER,
    @limit      INT = 50
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM claim.Claim
        WHERE claim_id = @claim_id AND tenant_id = @tenant_id
    )
    BEGIN
        SELECT TOP 0 * FROM claim.ClaimReserveLog WHERE 1 = 0;
        RETURN;
    END;

    SELECT TOP (@limit)
        rl.reserve_log_id,
        rl.claim_id,
        rl.previous_reserve,
        rl.new_reserve,
        rl.delta_amount,
        rl.reason_code,
        rl.notes,
        rl.changed_at_utc
    FROM claim.ClaimReserveLog rl
    WHERE rl.claim_id  = @claim_id
      AND rl.tenant_id = @tenant_id
    ORDER BY rl.changed_at_utc DESC;
END;
GO

PRINT 'Migration 044__add_claim_settlement.sql completed.';
GO
