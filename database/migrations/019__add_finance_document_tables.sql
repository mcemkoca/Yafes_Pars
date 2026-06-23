-- =============================================================================
-- Migration 019 — Finance & Document extended tables
-- Adds: finance.Invoices, finance.PaymentPlans, finance.PaymentPlanItems,
--       document.DocumentLinks, risk extended columns
-- =============================================================================
USE YafesPars;
GO

-- ─── finance.Invoices ────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID('finance') AND name = 'Invoices')
BEGIN
    CREATE TABLE finance.Invoices (
        InvoiceId        UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID()
                             CONSTRAINT PK_finance_Invoices PRIMARY KEY,
        TenantId         UNIQUEIDENTIFIER NOT NULL,
        ContractId       UNIQUEIDENTIFIER NOT NULL,
        IssueDate        DATE             NOT NULL,
        DueDate          DATE             NOT NULL,
        Amount           DECIMAL(18,2)    NOT NULL,
        CurrencyCode     NCHAR(3)         NOT NULL DEFAULT N'TRY',
        StatusCode       NVARCHAR(32)     NOT NULL DEFAULT N'PENDING'
                             CONSTRAINT CK_finance_Invoices_Status CHECK (StatusCode IN (N'PENDING', N'PAID', N'CANCELLED', N'OVERDUE')),
        CreatedAt        DATETIME2(2)     NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedAt        DATETIME2(2)     NOT NULL DEFAULT SYSUTCDATETIME()
    );
    CREATE INDEX IX_finance_Invoices_ContractId ON finance.Invoices (ContractId);
    CREATE INDEX IX_finance_Invoices_TenantId   ON finance.Invoices (TenantId);
    PRINT 'finance.Invoices created.';
END
GO

-- ─── finance.Payments ────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID('finance') AND name = 'Payments')
BEGIN
    CREATE TABLE finance.Payments (
        PaymentId        UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID()
                             CONSTRAINT PK_finance_Payments PRIMARY KEY,
        TenantId         UNIQUEIDENTIFIER NOT NULL,
        InvoiceId        UNIQUEIDENTIFIER NOT NULL
                             CONSTRAINT FK_finance_Payments_Invoice
                             REFERENCES finance.Invoices(InvoiceId),
        PaymentDate      DATE             NOT NULL,
        Amount           DECIMAL(18,2)    NOT NULL,
        PaymentMethodCode NVARCHAR(32)    NOT NULL DEFAULT N'CASH',
        CreatedAt        DATETIME2(2)     NOT NULL DEFAULT SYSUTCDATETIME()
    );
    CREATE INDEX IX_finance_Payments_InvoiceId ON finance.Payments (InvoiceId);
    PRINT 'finance.Payments created.';
END
GO

-- ─── finance.PaymentPlans ─────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID('finance') AND name = 'PaymentPlans')
BEGIN
    CREATE TABLE finance.PaymentPlans (
        PlanId           UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID()
                             CONSTRAINT PK_finance_PaymentPlans PRIMARY KEY,
        TenantId         UNIQUEIDENTIFIER NOT NULL,
        ContractId       UNIQUEIDENTIFIER NOT NULL,
        InstallmentCount SMALLINT         NOT NULL CONSTRAINT CK_finance_PaymentPlans_Count CHECK (InstallmentCount >= 1),
        FirstDueDate     DATE             NOT NULL,
        TotalAmount      DECIMAL(18,2)    NOT NULL,
        CurrencyCode     NCHAR(3)         NOT NULL DEFAULT N'TRY',
        CreatedAt        DATETIME2(2)     NOT NULL DEFAULT SYSUTCDATETIME()
    );
    CREATE INDEX IX_finance_PaymentPlans_ContractId ON finance.PaymentPlans (ContractId);
    PRINT 'finance.PaymentPlans created.';
END
GO

-- ─── finance.PaymentPlanItems ─────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID('finance') AND name = 'PaymentPlanItems')
BEGIN
    CREATE TABLE finance.PaymentPlanItems (
        ItemId           UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID()
                             CONSTRAINT PK_finance_PaymentPlanItems PRIMARY KEY,
        PlanId           UNIQUEIDENTIFIER NOT NULL
                             CONSTRAINT FK_finance_PlanItems_Plan
                             REFERENCES finance.PaymentPlans(PlanId),
        InstallmentNo    SMALLINT         NOT NULL,
        DueDate          DATE             NOT NULL,
        Amount           DECIMAL(18,2)    NOT NULL,
        IsPaid           BIT              NOT NULL DEFAULT 0,
        PaidAt           DATETIME2(2)     NULL
    );
    CREATE INDEX IX_finance_PlanItems_PlanId ON finance.PaymentPlanItems (PlanId);
    PRINT 'finance.PaymentPlanItems created.';
END
GO

-- ─── document.DocumentLinks ───────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID('document') AND name = 'DocumentLinks')
BEGIN
    CREATE TABLE document.DocumentLinks (
        LinkId      UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID()
                        CONSTRAINT PK_document_DocumentLinks PRIMARY KEY,
        TenantId    UNIQUEIDENTIFIER NOT NULL,
        DocumentId  UNIQUEIDENTIFIER NOT NULL,
        EntityType  NVARCHAR(64)     NOT NULL,
        EntityId    UNIQUEIDENTIFIER NOT NULL,
        LinkedAt    DATETIME2(2)     NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT UQ_document_DocumentLinks UNIQUE (DocumentId, EntityType, EntityId)
    );
    CREATE INDEX IX_document_DocumentLinks_Entity ON document.DocumentLinks (EntityType, EntityId);
    PRINT 'document.DocumentLinks created.';
END
GO

-- ─── audit.EntityNotes ────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID('audit') AND name = 'EntityNotes')
BEGIN
    CREATE TABLE audit.EntityNotes (
        NoteId      UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID()
                        CONSTRAINT PK_audit_EntityNotes PRIMARY KEY,
        TenantId    UNIQUEIDENTIFIER NOT NULL,
        EntityType  NVARCHAR(64)     NOT NULL,
        EntityId    UNIQUEIDENTIFIER NOT NULL,
        NoteText    NVARCHAR(2000)   NOT NULL,
        CreatedBy   UNIQUEIDENTIFIER NOT NULL,
        CreatedAt   DATETIME2(2)     NOT NULL DEFAULT SYSUTCDATETIME()
    );
    CREATE INDEX IX_audit_EntityNotes_Entity ON audit.EntityNotes (EntityType, EntityId);
    PRINT 'audit.EntityNotes created.';
END
GO

PRINT 'Migration 019 completed successfully.';
GO
