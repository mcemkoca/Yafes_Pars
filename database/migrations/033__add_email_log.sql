-- =============================================================================
-- Migration 033: communication.EmailLog
-- Registreert alle uitgaande e-mails (transactioneel + compliance-trail).
-- Provider-agnostisch: werkt met SendGrid, Azure Communication Services of SMTP.
-- =============================================================================
USE [YafesPars];
GO

BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'033__add_email_log')
        INSERT INTO core.SchemaMigration (migration_name, execution_status)
        VALUES (N'033__add_email_log', N'SUCCESS');
COMMIT TRANSACTION;
GO

-- Schema aanmaken als het nog niet bestaat.
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'communication')
    EXEC sp_executesql N'CREATE SCHEMA communication;';
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID(N'communication') AND name = N'EmailLog')
BEGIN
    CREATE TABLE communication.EmailLog (
        email_log_id        UNIQUEIDENTIFIER    NOT NULL DEFAULT NEWSEQUENTIALID(),
        tenant_id           UNIQUEIDENTIFIER    NOT NULL,
        recipient_email     NVARCHAR(320)       NOT NULL,
        recipient_name      NVARCHAR(200)       NULL,
        subject             NVARCHAR(500)       NOT NULL,
        template_code       NVARCHAR(80)        NOT NULL,   -- OVERDUE_REMINDER, PAYMENT_CONFIRM, RENEWAL_NOTICE …
        related_entity_type NVARCHAR(80)        NULL,       -- Invoice, Contract, PaymentTransaction …
        related_entity_id   UNIQUEIDENTIFIER    NULL,
        status_code         NVARCHAR(30)        NOT NULL    CONSTRAINT DF_EL_status  DEFAULT N'QUEUED',
        provider_message_id NVARCHAR(200)       NULL,       -- ID teruggegeven door provider
        error_message       NVARCHAR(1000)      NULL,
        sent_at_utc         DATETIME2(3)        NULL,
        created_at_utc      DATETIME2(3)        NOT NULL    CONSTRAINT DF_EL_created DEFAULT SYSUTCDATETIME(),
        is_deleted          BIT                 NOT NULL    CONSTRAINT DF_EL_del     DEFAULT 0,
        CONSTRAINT PK_EmailLog  PRIMARY KEY (email_log_id),
        CONSTRAINT FK_EL_Tenant FOREIGN KEY (tenant_id) REFERENCES core.Tenant(tenant_id),
        CONSTRAINT CK_EL_status CHECK (status_code IN (N'QUEUED', N'SENT', N'FAILED', N'SKIPPED'))
    );

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'communication.EmailLog') AND name = N'IX_EL_tenant_id')
        CREATE INDEX IX_EL_tenant_id ON communication.EmailLog (tenant_id) WHERE is_deleted = 0;

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'communication.EmailLog') AND name = N'IX_EL_entity')
        CREATE INDEX IX_EL_entity ON communication.EmailLog (related_entity_type, related_entity_id) WHERE is_deleted = 0;

    PRINT 'communication.EmailLog aangemaakt.';
END
GO

CREATE OR ALTER PROCEDURE communication.SP_LogEmail
    @tenant_id           UNIQUEIDENTIFIER,
    @recipient_email     NVARCHAR(320),
    @recipient_name      NVARCHAR(200)   = NULL,
    @subject             NVARCHAR(500),
    @template_code       NVARCHAR(80),
    @related_entity_type NVARCHAR(80)    = NULL,
    @related_entity_id   UNIQUEIDENTIFIER = NULL,
    @status_code         NVARCHAR(30)    = N'QUEUED',
    @provider_message_id NVARCHAR(200)   = NULL,
    @error_message       NVARCHAR(1000)  = NULL
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    DECLARE @out TABLE (email_log_id UNIQUEIDENTIFIER);

    INSERT INTO communication.EmailLog
        (tenant_id, recipient_email, recipient_name, subject, template_code,
         related_entity_type, related_entity_id, status_code, provider_message_id,
         error_message, sent_at_utc)
    OUTPUT inserted.email_log_id INTO @out
    VALUES
        (@tenant_id, @recipient_email, @recipient_name, @subject, @template_code,
         @related_entity_type, @related_entity_id, @status_code, @provider_message_id,
         @error_message,
         CASE WHEN @status_code = N'SENT' THEN SYSUTCDATETIME() ELSE NULL END);

    SELECT email_log_id AS EmailLogId FROM @out;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

PRINT 'Migration 033 complete: communication.EmailLog + SP_LogEmail.';
GO
