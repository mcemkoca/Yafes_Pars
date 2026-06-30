-- =============================================================================
-- Migration 039: Şikayet yönetimi (Klachtenbehandeling)
-- FSMA Circulaire 2012-17 / EU Solvency II art.295 — tüm müşteri şikayetleri
-- izlenebilir olmalı. 15 iş günü çözüm süresi zorunlu.
-- =============================================================================
USE [YafesPars];
GO

-- -----------------------------------------------------------------------------
-- 1. communication.Complaint tablosu
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables
               WHERE schema_id = SCHEMA_ID(N'communication') AND name = N'Complaint')
BEGIN
    CREATE TABLE communication.Complaint (
        complaint_id        UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
        tenant_id           UNIQUEIDENTIFIER NOT NULL,
        person_id           UNIQUEIDENTIFIER NOT NULL,
        contract_id         UNIQUEIDENTIFIER NULL,
        claim_id            UNIQUEIDENTIFIER NULL,
        received_date       DATE             NOT NULL DEFAULT CAST(GETUTCDATE() AS DATE),
        channel_code        NVARCHAR(30)     NOT NULL DEFAULT N'EMAIL',
        subject             NVARCHAR(200)    NOT NULL,
        description         NVARCHAR(MAX)    NOT NULL,
        status_code         NVARCHAR(30)     NOT NULL DEFAULT N'OPEN',
        priority_code       NVARCHAR(20)     NOT NULL DEFAULT N'NORMAL',
        assigned_user_id    UNIQUEIDENTIFIER NULL,
        resolved_date       DATE             NULL,
        resolution_notes    NVARCHAR(MAX)    NULL,
        fsma_reportable     BIT              NOT NULL DEFAULT 0,
        created_at_utc      DATETIME2        NOT NULL DEFAULT GETUTCDATE(),
        updated_at_utc      DATETIME2        NOT NULL DEFAULT GETUTCDATE(),
        is_deleted          BIT              NOT NULL DEFAULT 0,
        CONSTRAINT PK_Complaint PRIMARY KEY (complaint_id),
        CONSTRAINT FK_Complaint_Tenant   FOREIGN KEY (tenant_id)  REFERENCES core.Tenant  (tenant_id),
        CONSTRAINT FK_Complaint_Person   FOREIGN KEY (person_id)  REFERENCES person.Person (person_id),
        CONSTRAINT CK_Complaint_Status   CHECK (status_code   IN (N'OPEN', N'IN_PROGRESS', N'RESOLVED', N'ESCALATED', N'CLOSED')),
        CONSTRAINT CK_Complaint_Priority CHECK (priority_code IN (N'LOW', N'NORMAL', N'HIGH', N'URGENT')),
        CONSTRAINT CK_Complaint_Channel  CHECK (channel_code  IN (N'EMAIL', N'PHONE', N'POST', N'IN_PERSON', N'ONLINE', N'SOCIAL'))
    );

    CREATE INDEX IX_Complaint_tenant  ON communication.Complaint (tenant_id, status_code) WHERE is_deleted = 0;
    CREATE INDEX IX_Complaint_person  ON communication.Complaint (person_id)              WHERE is_deleted = 0;
    CREATE INDEX IX_Complaint_received ON communication.Complaint (received_date DESC)    WHERE is_deleted = 0;

    PRINT 'communication.Complaint aangemaakt.';
END;
ELSE
    PRINT 'communication.Complaint bestaat al.';
GO

-- -----------------------------------------------------------------------------
-- 2. SP_RegisterComplaint
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE communication.SP_RegisterComplaint
    @tenant_id      UNIQUEIDENTIFIER,
    @person_id      UNIQUEIDENTIFIER,
    @contract_id    UNIQUEIDENTIFIER = NULL,
    @claim_id       UNIQUEIDENTIFIER = NULL,
    @channel_code   NVARCHAR(30)     = N'EMAIL',
    @subject        NVARCHAR(200),
    @description    NVARCHAR(MAX),
    @priority_code  NVARCHAR(20)     = N'NORMAL',
    @fsma_reportable BIT             = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- Tenant/person kontrolü
    IF NOT EXISTS (SELECT 1 FROM person.Person WHERE person_id = @person_id AND tenant_id = @tenant_id AND is_deleted = 0)
    BEGIN
        RAISERROR (N'Kişi bu tenant kapsamında bulunamadı.', 16, 1);
        RETURN;
    END;

    -- contract_id verilmişse aynı tenant'a ait olmalı
    IF @contract_id IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM policy.Contract WHERE contract_id = @contract_id AND tenant_id = @tenant_id)
    BEGIN
        RAISERROR (N'Sözleşme bu tenant kapsamında bulunamadı.', 16, 1);
        RETURN;
    END;

    -- claim_id verilmişse aynı tenant'a ait olmalı
    IF @claim_id IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM claim.Claim WHERE claim_id = @claim_id AND tenant_id = @tenant_id)
    BEGIN
        RAISERROR (N'Hasar kaydı bu tenant kapsamında bulunamadı.', 16, 1);
        RETURN;
    END;

    -- NEWSEQUENTIALID() sadece tablo DEFAULT'unda kullanılabilir; NEWID() kullan
    DECLARE @complaint_id UNIQUEIDENTIFIER = NEWID();

    INSERT INTO communication.Complaint
        (complaint_id, tenant_id, person_id, contract_id, claim_id,
         channel_code, subject, description, priority_code, fsma_reportable)
    VALUES
        (@complaint_id, @tenant_id, @person_id, @contract_id, @claim_id,
         @channel_code, @subject, @description, @priority_code, @fsma_reportable);

    SELECT
        complaint_id   AS ComplaintId,
        status_code    AS StatusCode,
        received_date  AS ReceivedDate,
        priority_code  AS PriorityCode,
        fsma_reportable AS FsmaReportable
    FROM communication.Complaint
    WHERE complaint_id = @complaint_id;
END;
GO

-- -----------------------------------------------------------------------------
-- 3. SP_UpdateComplaintStatus
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE communication.SP_UpdateComplaintStatus
    @complaint_id       UNIQUEIDENTIFIER,
    @tenant_id          UNIQUEIDENTIFIER,
    @new_status         NVARCHAR(30),
    @resolution_notes   NVARCHAR(MAX) = NULL,
    @assigned_user_id   UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Bulunamazsa boş result set döndür (caller rows.FirstOrDefault() → null → 404)
    IF NOT EXISTS (
        SELECT 1 FROM communication.Complaint
        WHERE complaint_id = @complaint_id AND tenant_id = @tenant_id AND is_deleted = 0
    )
    BEGIN
        SELECT NULL AS ComplaintId, NULL AS StatusCode, NULL AS ResolvedDate,
               NULL AS FsmaReportable, NULL AS UpdatedAtUtc WHERE 1 = 0;
        RETURN;
    END;

    DECLARE @resolved_date DATE = NULL;
    IF @new_status IN (N'RESOLVED', N'CLOSED')
        SET @resolved_date = CAST(GETUTCDATE() AS DATE);

    -- ESCALATED ise otomatik FSMA raporlanabilir yap
    DECLARE @fsma BIT = (SELECT fsma_reportable FROM communication.Complaint WHERE complaint_id = @complaint_id);
    IF @new_status = N'ESCALATED' SET @fsma = 1;

    UPDATE communication.Complaint
    SET status_code      = @new_status,
        resolution_notes = COALESCE(@resolution_notes, resolution_notes),
        assigned_user_id = COALESCE(@assigned_user_id, assigned_user_id),
        resolved_date    = COALESCE(@resolved_date, resolved_date),
        fsma_reportable  = @fsma,
        updated_at_utc   = GETUTCDATE()
    WHERE complaint_id = @complaint_id
      AND tenant_id    = @tenant_id;

    SELECT
        complaint_id    AS ComplaintId,
        status_code     AS StatusCode,
        resolved_date   AS ResolvedDate,
        fsma_reportable AS FsmaReportable,
        updated_at_utc  AS UpdatedAtUtc
    FROM communication.Complaint
    WHERE complaint_id = @complaint_id;
END;
GO

-- -----------------------------------------------------------------------------
-- 4. SP_GetComplaintsByTenant
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE communication.SP_GetComplaintsByTenant
    @tenant_id      UNIQUEIDENTIFIER,
    @status_code    NVARCHAR(30)  = NULL,
    @top_n          INT           = 100
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@top_n)
        c.complaint_id      AS ComplaintId,
        c.person_id         AS PersonId,
        ISNULL(np.first_name + N' ' + np.last_name, N'(onbekend)') AS PersonName,
        c.contract_id       AS ContractId,
        c.claim_id          AS ClaimId,
        c.received_date     AS ReceivedDate,
        c.channel_code      AS ChannelCode,
        c.subject           AS Subject,
        c.status_code       AS StatusCode,
        c.priority_code     AS PriorityCode,
        c.fsma_reportable   AS FsmaReportable,
        c.resolved_date     AS ResolvedDate,
        DATEDIFF(DAY, c.received_date, ISNULL(c.resolved_date, CAST(GETUTCDATE() AS DATE))) AS DaysOpen
    FROM communication.Complaint c
    LEFT JOIN person.NaturalPerson np ON np.person_id = c.person_id AND np.is_deleted = 0
    WHERE c.tenant_id  = @tenant_id
      AND c.is_deleted = 0
      AND (@status_code IS NULL OR c.status_code = @status_code)
    ORDER BY c.received_date DESC;
END;
GO

-- -----------------------------------------------------------------------------
-- 5. SP_GetComplaintDashboard
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE communication.SP_GetComplaintDashboard
    @tenant_id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        SUM(CASE WHEN status_code = N'OPEN'                    THEN 1 ELSE 0 END) AS OpenCount,
        SUM(CASE WHEN status_code = N'IN_PROGRESS'             THEN 1 ELSE 0 END) AS InProgressCount,
        SUM(CASE WHEN status_code = N'ESCALATED'               THEN 1 ELSE 0 END) AS EscalatedCount,
        SUM(CASE WHEN status_code IN (N'RESOLVED', N'CLOSED')  THEN 1 ELSE 0 END) AS ClosedCount,
        SUM(CASE WHEN fsma_reportable = 1 AND status_code NOT IN (N'CLOSED') THEN 1 ELSE 0 END) AS FsmaPendingCount,
        -- Gecikmiş: 15 iş gününden fazla açık (yaklaşık 21 takvim günü)
        SUM(CASE WHEN status_code IN (N'OPEN', N'IN_PROGRESS', N'ESCALATED')
                   AND DATEDIFF(DAY, received_date, GETUTCDATE()) > 21
                THEN 1 ELSE 0 END) AS OverdueCount,
        AVG(CASE WHEN resolved_date IS NOT NULL
                 THEN DATEDIFF(DAY, received_date, resolved_date)
                 ELSE NULL END) AS AvgResolutionDays
    FROM communication.Complaint
    WHERE tenant_id = @tenant_id
      AND is_deleted = 0;
END;
GO

-- -----------------------------------------------------------------------------
-- 6. reporting.SP_FsmaComplaintReport
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE reporting.SP_FsmaComplaintReport
    @tenant_id    UNIQUEIDENTIFIER,
    @year         INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @report_year INT = ISNULL(@year, YEAR(GETUTCDATE()));

    SELECT
        c.complaint_id      AS ComplaintId,
        c.received_date     AS ReceivedDate,
        c.channel_code      AS Channel,
        c.subject           AS Subject,
        c.status_code       AS Status,
        c.priority_code     AS Priority,
        c.resolved_date     AS ResolvedDate,
        DATEDIFF(DAY, c.received_date,
            ISNULL(c.resolved_date, CAST(GETUTCDATE() AS DATE))) AS DaysToResolve,
        CASE WHEN DATEDIFF(DAY, c.received_date,
                ISNULL(c.resolved_date, CAST(GETUTCDATE() AS DATE))) > 21
             THEN 1 ELSE 0 END AS ExceededDeadline,
        ISNULL(np.first_name + N' ' + np.last_name, N'(onbekend)') AS ClientName
    FROM communication.Complaint c
    LEFT JOIN person.NaturalPerson np ON np.person_id = c.person_id AND np.is_deleted = 0
    WHERE c.tenant_id       = @tenant_id
      AND c.fsma_reportable = 1
      AND c.is_deleted      = 0
      AND YEAR(c.received_date) = @report_year
    ORDER BY c.received_date;
END;
GO

PRINT 'Migration 039 complete: communication.Complaint + 5 SPs (Register/UpdateStatus/GetByTenant/Dashboard/FsmaReport).';
GO
