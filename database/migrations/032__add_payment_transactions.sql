-- =============================================================================
-- Migration 032: finance.PaymentTransaction + betaling-SPs
-- Mollie-betalingsintegratie voor premie-invordering (Belgische verzekeraar).
-- Ondersteunt iDEAL, Bancontact, SEPA, creditcard via Mollie REST API v2.
-- =============================================================================
USE [YafesPars];
GO

BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'032__add_payment_transactions')
    BEGIN
        INSERT INTO core.SchemaMigration (migration_name, execution_status)
        VALUES (N'032__add_payment_transactions', N'SUCCESS');
    END

COMMIT TRANSACTION;
GO

-- Betalingstransactietabel: één rij per Mollie-betaling.
-- Kolon convention: snake_case voor eigen kolommen, PascalCase FK doelen volgen bronschema.
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID(N'finance') AND name = N'PaymentTransaction')
BEGIN
    CREATE TABLE finance.PaymentTransaction (
        transaction_id      UNIQUEIDENTIFIER    NOT NULL DEFAULT NEWSEQUENTIALID(),
        tenant_id           UNIQUEIDENTIFIER    NOT NULL,
        invoice_id          UNIQUEIDENTIFIER    NOT NULL,
        mollie_payment_id   NVARCHAR(50)        NULL,       -- tr_xxxx van Mollie
        mollie_checkout_url NVARCHAR(500)       NULL,       -- betaal-URL voor klant
        amount_eur          DECIMAL(18,4)       NOT NULL,
        status_code         NVARCHAR(30)        NOT NULL    CONSTRAINT DF_PT_status   DEFAULT N'PENDING',
        payment_method      NVARCHAR(30)        NULL,       -- ideal, bancontact, creditcard …
        description         NVARCHAR(255)       NULL,
        return_url          NVARCHAR(500)       NULL,
        webhook_url         NVARCHAR(500)       NULL,
        created_at_utc      DATETIME2(3)        NOT NULL    CONSTRAINT DF_PT_created  DEFAULT SYSUTCDATETIME(),
        paid_at_utc         DATETIME2(3)        NULL,
        updated_at_utc      DATETIME2(3)        NOT NULL    CONSTRAINT DF_PT_updated  DEFAULT SYSUTCDATETIME(),
        is_deleted          BIT                 NOT NULL    CONSTRAINT DF_PT_del      DEFAULT 0,
        CONSTRAINT PK_PaymentTransaction  PRIMARY KEY (transaction_id),
        CONSTRAINT FK_PT_Tenant           FOREIGN KEY (tenant_id)  REFERENCES core.Tenant(tenant_id),
        CONSTRAINT FK_PT_Invoice          FOREIGN KEY (invoice_id) REFERENCES finance.Invoices(InvoiceId),
        CONSTRAINT CK_PT_status           CHECK (status_code IN (N'PENDING',N'PAID',N'FAILED',N'CANCELLED',N'EXPIRED')),
        CONSTRAINT CK_PT_amount           CHECK (amount_eur > 0)
    );

    CREATE INDEX IX_PT_tenant_invoice
        ON finance.PaymentTransaction (tenant_id, invoice_id)
        WHERE is_deleted = 0;

    CREATE UNIQUE INDEX IX_PT_mollie_id
        ON finance.PaymentTransaction (mollie_payment_id)
        WHERE mollie_payment_id IS NOT NULL AND is_deleted = 0;

    PRINT 'finance.PaymentTransaction tabel aangemaakt.';
END
GO

-- SP: maak een betalingstransactierecord aan (vóór Mollie-API-aanroep).
CREATE OR ALTER PROCEDURE finance.SP_CreatePaymentTransaction
    @tenant_id      UNIQUEIDENTIFIER,
    @invoice_id     UNIQUEIDENTIFIER,
    @amount_eur     DECIMAL(18,4),
    @description    NVARCHAR(255)   = NULL,
    @return_url     NVARCHAR(500)   = NULL,
    @webhook_url    NVARCHAR(500)   = NULL
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    -- Controleer of de factuur bij de tenant hoort (finance.Invoices gebruikt PascalCase).
    IF NOT EXISTS (
        SELECT 1 FROM finance.Invoices
        WHERE InvoiceId = @invoice_id AND TenantId = @tenant_id
    )
        THROW 52010, 'Factuur niet gevonden voor deze tenant.', 1;

    DECLARE @id UNIQUEIDENTIFIER = NEWSEQUENTIALID();

    INSERT INTO finance.PaymentTransaction
        (transaction_id, tenant_id, invoice_id, amount_eur, description, return_url, webhook_url)
    VALUES
        (@id, @tenant_id, @invoice_id, @amount_eur, @description, @return_url, @webhook_url);

    SELECT
        @id                 AS TransactionId,
        @invoice_id         AS InvoiceId,
        @amount_eur         AS AmountEur,
        N'PENDING'          AS StatusCode,
        SYSUTCDATETIME()    AS CreatedAtUtc;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

-- SP: werk betalingsstatus bij na Mollie-webhook of statuscontrole.
CREATE OR ALTER PROCEDURE finance.SP_UpdatePaymentStatus
    @tenant_id             UNIQUEIDENTIFIER,
    @transaction_id        UNIQUEIDENTIFIER    = NULL,
    @mollie_payment_id     NVARCHAR(50)        = NULL,
    @status_code           NVARCHAR(30),
    @mollie_payment_id_set NVARCHAR(50)        = NULL,
    @checkout_url          NVARCHAR(500)       = NULL
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    IF @transaction_id IS NULL AND @mollie_payment_id IS NULL
        THROW 52011, 'Geef @transaction_id of @mollie_payment_id op.', 1;

    IF @status_code NOT IN (N'PENDING', N'PAID', N'FAILED', N'CANCELLED', N'EXPIRED')
        THROW 52012, 'Ongeldige status_code.', 1;

    UPDATE finance.PaymentTransaction
    SET
        status_code         = @status_code,
        paid_at_utc         = CASE WHEN @status_code = N'PAID' THEN SYSUTCDATETIME() ELSE paid_at_utc END,
        mollie_payment_id   = ISNULL(@mollie_payment_id_set, mollie_payment_id),
        mollie_checkout_url = ISNULL(@checkout_url,          mollie_checkout_url),
        updated_at_utc      = SYSUTCDATETIME()
    WHERE tenant_id = @tenant_id
      AND is_deleted = 0
      AND (
            (@transaction_id    IS NOT NULL AND transaction_id    = @transaction_id)
         OR (@mollie_payment_id IS NOT NULL AND mollie_payment_id = @mollie_payment_id)
      );

    IF @@ROWCOUNT = 0
        THROW 52013, 'Betalingstransactie niet gevonden.', 1;

    -- Markeer factuur als PAID bij succesvolle betaling.
    IF @status_code = N'PAID'
    BEGIN
        UPDATE finance.Invoices
        SET StatusCode = N'PAID',
            UpdatedAt  = SYSUTCDATETIME()
        FROM finance.Invoices i
        INNER JOIN finance.PaymentTransaction pt
            ON pt.invoice_id = i.InvoiceId
        WHERE pt.tenant_id = @tenant_id
          AND (
                (@transaction_id    IS NOT NULL AND pt.transaction_id    = @transaction_id)
             OR (@mollie_payment_id IS NOT NULL AND pt.mollie_payment_id = @mollie_payment_id)
          );
    END

    SELECT @@ROWCOUNT AS Updated;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

PRINT 'Migration 032 complete: finance.PaymentTransaction + betaling-SPs.';
GO
