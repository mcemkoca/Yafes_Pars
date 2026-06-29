-- =============================================================================
-- Migration 028: Commissie (makelaarscourtage) / Komisyon tabloları
-- Adds: finance.Commissions, finance.SP_RecordCommission,
--       reporting.VW_CommissionReport
-- =============================================================================
USE [YafesPars];
GO

BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'028__add_commission_tables')
    BEGIN

        -- --- finance.Commissions ------------------------------------------
        IF NOT EXISTS (
            SELECT 1 FROM sys.tables
            WHERE schema_id = SCHEMA_ID(N'finance') AND name = N'Commissions'
        )
        BEGIN
            CREATE TABLE finance.Commissions (
                commission_id       UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID()
                                        CONSTRAINT PK_finance_Commissions PRIMARY KEY,
                tenant_id           UNIQUEIDENTIFIER NOT NULL,
                contract_id         UNIQUEIDENTIFIER NOT NULL,
                broker_person_id    UNIQUEIDENTIFIER NULL,
                broker_institution_id UNIQUEIDENTIFIER NULL,
                commission_type_code NVARCHAR(32)    NOT NULL DEFAULT N'PRODUCTIE'
                                        CONSTRAINT CK_Commissions_Type CHECK (
                                            commission_type_code IN (
                                                N'PRODUCTIE',   -- nieuwe polis
                                                N'VERLENGING',  -- verlenging
                                                N'REGULARISATIE'-- regularisatie/correctie
                                            )
                                        ),
                commission_date     DATE             NOT NULL,
                gross_premium_eur   DECIMAL(18,2)    NOT NULL,
                rate_pct            DECIMAL(5,4)     NOT NULL,
                commission_eur      DECIMAL(18,2)    NOT NULL,
                status_code         NVARCHAR(16)     NOT NULL DEFAULT N'PENDING'
                                        CONSTRAINT CK_Commissions_Status CHECK (
                                            status_code IN (N'PENDING', N'PAID', N'CANCELLED')
                                        ),
                paid_date           DATE             NULL,
                notes               NVARCHAR(500)    NULL,
                created_at_utc      DATETIME2(2)     NOT NULL DEFAULT SYSUTCDATETIME(),
                updated_at_utc      DATETIME2(2)     NOT NULL DEFAULT SYSUTCDATETIME(),
                created_by_user_id  UNIQUEIDENTIFIER NULL,
                is_deleted          BIT              NOT NULL DEFAULT 0
            );

            CREATE INDEX IX_Commissions_TenantId
                ON finance.Commissions (tenant_id);
            CREATE INDEX IX_Commissions_ContractId
                ON finance.Commissions (contract_id);
            CREATE INDEX IX_Commissions_BrokerPerson
                ON finance.Commissions (broker_person_id) WHERE broker_person_id IS NOT NULL;
            CREATE INDEX IX_Commissions_BrokerInstitution
                ON finance.Commissions (broker_institution_id) WHERE broker_institution_id IS NOT NULL;

            PRINT 'finance.Commissions created.';
        END

        INSERT INTO core.SchemaMigration (migration_name, execution_status)
        VALUES (N'028__add_commission_tables', N'SUCCESS');

    END

COMMIT TRANSACTION;
GO

-- --- finance.SP_RecordCommission ------------------------------------------
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
    -- Tenant ownership check
    IF NOT EXISTS (
        SELECT 1 FROM policy.Contract
        WHERE contract_id = @contract_id AND tenant_id = @tenant_id AND is_deleted = 0
    )
        THROW 51960, 'Contract niet gevonden voor deze tenant. / Bu tenant için sözleşme bulunamadı.', 1;

    IF @rate_pct <= 0 OR @rate_pct > 1
        THROW 51961, 'Commissietarief moet tussen 0 en 1 liggen (bv. 0.15 = 15%). / Oran 0-1 arasında olmalı.', 1;

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

-- --- reporting.VW_CommissionReport ----------------------------------------
IF OBJECT_ID(N'reporting.VW_CommissionReport', N'V') IS NOT NULL
    DROP VIEW reporting.VW_CommissionReport;
GO
CREATE VIEW reporting.VW_CommissionReport AS
SELECT
    c.tenant_id,
    c.commission_id,
    c.commission_date,
    c.commission_type_code,
    c.status_code,
    ct.contract_number,
    ct.contract_domain_code                          AS tak,
    ct.contract_type_code                            AS productcode,
    pp.first_name + N' ' + pp.last_name              AS broker_naam,
    inst.name                                         AS broker_kantoor,
    c.gross_premium_eur,
    c.rate_pct,
    c.commission_eur,
    c.paid_date,
    c.notes
FROM finance.Commissions c
INNER JOIN policy.Contract ct
    ON ct.contract_id = c.contract_id
LEFT JOIN person.NaturalPerson pp
    ON pp.person_id = c.broker_person_id
LEFT JOIN institution.Institution inst
    ON inst.institution_id = c.broker_institution_id
WHERE c.is_deleted = 0;
GO

PRINT 'Migration 028 complete: finance.Commissions, SP_RecordCommission, VW_CommissionReport.';
GO
