-- =============================================================================
-- Migration 040: Sözleşme yenileme pipeline
-- SP_GetRenewalQueue, SP_ProcessRenewal, SP_GetRenewalMetrics
-- Belçika sigorta: yenileme bildirimi yasal olarak 3 ay önceden yapılmalı.
-- =============================================================================
USE [YafesPars];
GO

-- -----------------------------------------------------------------------------
-- 1. policy.RenewalQueue — yenileme takip tablosu
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables
               WHERE schema_id = SCHEMA_ID(N'policy') AND name = N'RenewalQueue')
BEGIN
    CREATE TABLE policy.RenewalQueue (
        renewal_id          UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
        tenant_id           UNIQUEIDENTIFIER NOT NULL,
        contract_id         UNIQUEIDENTIFIER NOT NULL,
        contract_end_date   DATE             NOT NULL,
        days_until_expiry   AS DATEDIFF(DAY, CAST(GETUTCDATE() AS DATE), contract_end_date) PERSISTED,
        status_code         NVARCHAR(30)     NOT NULL DEFAULT N'PENDING',
        notice_sent_at      DATETIME2        NULL,
        notice_count        INT              NOT NULL DEFAULT 0,
        renewed_contract_id UNIQUEIDENTIFIER NULL,
        processed_at        DATETIME2        NULL,
        notes               NVARCHAR(500)    NULL,
        created_at_utc      DATETIME2        NOT NULL DEFAULT GETUTCDATE(),
        updated_at_utc      DATETIME2        NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT PK_RenewalQueue    PRIMARY KEY (renewal_id),
        CONSTRAINT FK_RQ_Tenant       FOREIGN KEY (tenant_id)   REFERENCES core.Tenant   (tenant_id),
        CONSTRAINT FK_RQ_Contract     FOREIGN KEY (contract_id) REFERENCES policy.Contract(contract_id),
        CONSTRAINT UQ_RQ_Contract     UNIQUE (contract_id),
        CONSTRAINT CK_RQ_Status       CHECK (status_code IN (N'PENDING', N'NOTICE_SENT', N'RENEWED', N'DECLINED', N'EXPIRED'))
    );

    CREATE INDEX IX_RQ_tenant_status ON policy.RenewalQueue (tenant_id, status_code, contract_end_date) WHERE status_code IN (N'PENDING', N'NOTICE_SENT');

    PRINT 'policy.RenewalQueue aangemaakt.';
END;
ELSE
    PRINT 'policy.RenewalQueue bestaat al.';
GO

-- -----------------------------------------------------------------------------
-- 2. SP_GetRenewalQueue — yaklaşan yenilemeler listesi
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE policy.SP_GetRenewalQueue
    @tenant_id      UNIQUEIDENTIFIER,
    @days_ahead     INT = 90,
    @status_code    NVARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Yeni süresi dolacak sözleşmeleri kuyruğa ekle (idempotent)
    INSERT INTO policy.RenewalQueue (tenant_id, contract_id, contract_end_date)
    SELECT
        c.tenant_id,
        c.contract_id,
        c.end_date
    FROM policy.Contract c
    WHERE c.tenant_id           = @tenant_id
      AND c.contract_status_code = N'ACTIVE'
      AND c.end_date             IS NOT NULL
      AND c.end_date             BETWEEN CAST(GETUTCDATE() AS DATE)
                                      AND DATEADD(DAY, @days_ahead, CAST(GETUTCDATE() AS DATE))
      AND NOT EXISTS (SELECT 1 FROM policy.RenewalQueue rq WHERE rq.contract_id = c.contract_id);

    -- Liste döndür
    SELECT
        rq.renewal_id          AS RenewalId,
        rq.contract_id         AS ContractId,
        c.contract_number      AS ContractNumber,
        c.contract_domain_code AS DomainCode,
        rq.contract_end_date   AS ContractEndDate,
        rq.days_until_expiry   AS DaysUntilExpiry,
        rq.status_code         AS StatusCode,
        rq.notice_sent_at      AS NoticeSentAt,
        rq.notice_count        AS NoticeCount,
        ISNULL(np.first_name + N' ' + np.last_name, lp.legal_name) AS HolderName,
        e.email                AS HolderEmail
    FROM policy.RenewalQueue rq
    INNER JOIN policy.Contract c    ON c.contract_id = rq.contract_id
    LEFT JOIN policy.ContractParty cp
        ON cp.contract_id = rq.contract_id
       AND cp.party_role_code = N'POLICY_HOLDER'
    LEFT JOIN person.Person p       ON p.person_id = cp.person_id AND p.is_deleted = 0
    LEFT JOIN person.NaturalPerson np ON np.person_id = p.person_id AND np.is_deleted = 0
    LEFT JOIN person.LegalPerson   lp ON lp.person_id = p.person_id AND lp.is_deleted = 0
    LEFT JOIN person.Email e
        ON e.person_id = p.person_id AND e.is_primary = 1 AND e.is_deleted = 0
    WHERE rq.tenant_id  = @tenant_id
      AND (@status_code IS NULL OR rq.status_code = @status_code)
    ORDER BY rq.contract_end_date ASC;
END;
GO

-- -----------------------------------------------------------------------------
-- 3. SP_ProcessRenewal — yenileme durumu güncelle
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE policy.SP_ProcessRenewal
    @tenant_id              UNIQUEIDENTIFIER,
    @renewal_id             UNIQUEIDENTIFIER,
    @new_status             NVARCHAR(30),
    @renewed_contract_id    UNIQUEIDENTIFIER = NULL,
    @notes                  NVARCHAR(500)    = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM policy.RenewalQueue
        WHERE renewal_id = @renewal_id AND tenant_id = @tenant_id
    )
    BEGIN
        RAISERROR (N'Yenileme kaydı bulunamadı.', 16, 1);
        RETURN;
    END;

    DECLARE @notice_sent_at DATETIME2 = NULL;
    DECLARE @notice_count   INT       = (SELECT notice_count FROM policy.RenewalQueue WHERE renewal_id = @renewal_id);

    IF @new_status = N'NOTICE_SENT'
    BEGIN
        SET @notice_sent_at = GETUTCDATE();
        SET @notice_count   = @notice_count + 1;
    END;

    UPDATE policy.RenewalQueue
    SET status_code          = @new_status,
        renewed_contract_id  = COALESCE(@renewed_contract_id, renewed_contract_id),
        notes                = COALESCE(@notes, notes),
        notice_sent_at       = COALESCE(@notice_sent_at, notice_sent_at),
        notice_count         = @notice_count,
        processed_at         = CASE WHEN @new_status IN (N'RENEWED', N'DECLINED', N'EXPIRED')
                                    THEN GETUTCDATE() ELSE processed_at END,
        updated_at_utc       = GETUTCDATE()
    WHERE renewal_id = @renewal_id
      AND tenant_id  = @tenant_id;

    SELECT
        renewal_id          AS RenewalId,
        contract_id         AS ContractId,
        status_code         AS StatusCode,
        notice_count        AS NoticeCount,
        renewed_contract_id AS RenewedContractId,
        updated_at_utc      AS UpdatedAtUtc
    FROM policy.RenewalQueue
    WHERE renewal_id = @renewal_id;
END;
GO

-- -----------------------------------------------------------------------------
-- 4. SP_GetRenewalMetrics — yenileme performans metrikleri
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE policy.SP_GetRenewalMetrics
    @tenant_id  UNIQUEIDENTIFIER,
    @year       INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @y INT = ISNULL(@year, YEAR(GETUTCDATE()));

    SELECT
        SUM(CASE WHEN status_code = N'PENDING'     THEN 1 ELSE 0 END) AS PendingCount,
        SUM(CASE WHEN status_code = N'NOTICE_SENT' THEN 1 ELSE 0 END) AS NoticeSentCount,
        SUM(CASE WHEN status_code = N'RENEWED'     THEN 1 ELSE 0 END) AS RenewedCount,
        SUM(CASE WHEN status_code = N'DECLINED'    THEN 1 ELSE 0 END) AS DeclinedCount,
        SUM(CASE WHEN status_code = N'EXPIRED'     THEN 1 ELSE 0 END) AS ExpiredCount,
        COUNT(*)                                                        AS TotalCount,
        -- Yenileme oranı (RENEWED / (RENEWED + DECLINED + EXPIRED))
        CASE WHEN SUM(CASE WHEN status_code IN (N'RENEWED', N'DECLINED', N'EXPIRED') THEN 1 ELSE 0 END) > 0
             THEN ROUND(100.0 * SUM(CASE WHEN status_code = N'RENEWED' THEN 1 ELSE 0 END) /
                        SUM(CASE WHEN status_code IN (N'RENEWED', N'DECLINED', N'EXPIRED') THEN 1 ELSE 0 END), 1)
             ELSE NULL END AS RenewalRatePct,
        SUM(CASE WHEN days_until_expiry < 0 AND status_code IN (N'PENDING', N'NOTICE_SENT')
                 THEN 1 ELSE 0 END) AS OverdueCount
    FROM policy.RenewalQueue
    WHERE tenant_id = @tenant_id
      AND YEAR(contract_end_date) = @y;
END;
GO

PRINT 'Migration 040 complete: policy.RenewalQueue + SP_GetRenewalQueue, SP_ProcessRenewal, SP_GetRenewalMetrics.';
GO
