-- =============================================================================
-- Migration 036: operasyonel dashboard + tenant sağlık skoru SP'leri
-- Operasyonel izleme: poliçe/hasar/fatura metrikleri ve tenant sağlık skoru.
-- =============================================================================
USE [YafesPars];
GO

BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'036__add_operational_dashboard_sps')
        INSERT INTO core.SchemaMigration (migration_name, execution_status)
        VALUES (N'036__add_operational_dashboard_sps', N'SUCCESS');
COMMIT TRANSACTION;
GO

-- SP: Operasyonel dashboard — tenant için özet metrikler (son 30 gün).
CREATE OR ALTER PROCEDURE reporting.SP_OperationalDashboard
    @tenant_id      UNIQUEIDENTIFIER,
    @days_back      INT = 30
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    DECLARE @from_date DATE = DATEADD(DAY, -@days_back, CAST(GETUTCDATE() AS DATE));

    -- Aktif poliçe sayısı (domain bazlı)
    SELECT
        'policy_by_domain'              AS MetricCategory,
        c.contract_domain_code          AS Dimension,
        COUNT(*)                        AS MetricValue,
        NULL                            AS MetricAmount,
        CAST(GETUTCDATE() AS DATE)      AS AsOfDate
    FROM policy.Contract c
    WHERE c.tenant_id = @tenant_id
      AND c.is_deleted = 0
      AND c.contract_status_code = N'ACTIVE'
    GROUP BY c.contract_domain_code

    UNION ALL

    -- Yeni poliçeler (son N gün)
    SELECT
        'new_policies'                  AS MetricCategory,
        'total'                         AS Dimension,
        COUNT(*)                        AS MetricValue,
        NULL                            AS MetricAmount,
        CAST(GETUTCDATE() AS DATE)      AS AsOfDate
    FROM policy.Contract c
    WHERE c.tenant_id = @tenant_id
      AND c.is_deleted = 0
      AND CAST(c.created_at_utc AS DATE) >= @from_date

    UNION ALL

    -- Açık hasarlar (durum bazlı)
    SELECT
        'claims_by_status'              AS MetricCategory,
        cl.claim_status_code            AS Dimension,
        COUNT(*)                        AS MetricValue,
        SUM(ISNULL(cl.reserved_amount, 0)) AS MetricAmount,
        CAST(GETUTCDATE() AS DATE)      AS AsOfDate
    FROM claim.Claim cl
    WHERE cl.tenant_id = @tenant_id
      AND cl.is_deleted = 0
      AND cl.claim_status_code NOT IN (N'CLOSED', N'REJECTED', N'PAID')
    GROUP BY cl.claim_status_code

    UNION ALL

    -- Vadesi geçmiş faturalar
    SELECT
        'overdue_invoices'              AS MetricCategory,
        'overdue'                       AS Dimension,
        COUNT(*)                        AS MetricValue,
        SUM(ISNULL(inv.amount, 0))      AS MetricAmount,
        CAST(GETUTCDATE() AS DATE)      AS AsOfDate
    FROM finance.Invoices inv
    WHERE inv.TenantId = @tenant_id
      AND inv.StatusCode IN (N'OVERDUE', N'PENDING')
      AND inv.DueDate < CAST(GETUTCDATE() AS DATE)

    UNION ALL

    -- Komisyon toplam (son N gün)
    SELECT
        'commissions_period'            AS MetricCategory,
        'total'                         AS Dimension,
        COUNT(*)                        AS MetricValue,
        SUM(ISNULL(comm.commission_eur, 0)) AS MetricAmount,
        CAST(GETUTCDATE() AS DATE)      AS AsOfDate
    FROM finance.Commissions comm
    WHERE comm.tenant_id = @tenant_id
      AND CAST(comm.created_at_utc AS DATE) >= @from_date

    ORDER BY MetricCategory, Dimension;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

-- SP: Tenant sağlık skoru — SLA uyumu, hasar oranı ve gecikme göstergeleri.
CREATE OR ALTER PROCEDURE reporting.SP_TenantHealthScore
    @tenant_id  UNIQUEIDENTIFIER
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    DECLARE @today DATE = CAST(GETUTCDATE() AS DATE);

    -- Aktif poliçe
    DECLARE @active_contracts INT = (
        SELECT COUNT(*) FROM policy.Contract
        WHERE tenant_id = @tenant_id AND is_deleted = 0
          AND contract_status_code = N'ACTIVE'
    );

    -- Açık hasar
    DECLARE @open_claims INT = (
        SELECT COUNT(*) FROM claim.Claim
        WHERE tenant_id = @tenant_id AND is_deleted = 0
          AND claim_status_code NOT IN (N'CLOSED', N'REJECTED', N'PAID')
    );

    -- Vadesi geçmiş fatura
    DECLARE @overdue_invoices INT = (
        SELECT COUNT(*) FROM finance.Invoices
        WHERE TenantId = @tenant_id
          AND StatusCode IN (N'OVERDUE', N'PENDING')
          AND DueDate < @today
    );

    -- Toplam fatura (son 90 gün)
    DECLARE @total_invoices_90d INT = (
        SELECT COUNT(*) FROM finance.Invoices
        WHERE TenantId = @tenant_id
          AND CAST(DueDate AS DATE) >= DATEADD(DAY, -90, @today)
    );

    -- 30 gün içinde yenilenecek poliçeler
    DECLARE @expiring_soon INT = (
        SELECT COUNT(*) FROM policy.Contract
        WHERE tenant_id = @tenant_id AND is_deleted = 0
          AND contract_status_code = N'ACTIVE'
          AND end_date BETWEEN @today AND DATEADD(DAY, 30, @today)
    );

    -- Gecikme oranı (son 90 gün)
    DECLARE @overdue_rate DECIMAL(5,2) =
        CASE WHEN @total_invoices_90d > 0
             THEN CAST(@overdue_invoices AS DECIMAL(5,2)) / @total_invoices_90d * 100
             ELSE 0 END;

    -- Hasar oranı (açık hasar / aktif poliçe)
    DECLARE @claim_rate DECIMAL(5,2) =
        CASE WHEN @active_contracts > 0
             THEN CAST(@open_claims AS DECIMAL(5,2)) / @active_contracts * 100
             ELSE 0 END;

    -- Sağlık skoru: 100'den başla, sorunlardan düş
    DECLARE @health_score INT = 100;
    IF @overdue_rate > 10  SET @health_score = @health_score - 20;
    IF @overdue_rate > 25  SET @health_score = @health_score - 20;
    IF @claim_rate   > 15  SET @health_score = @health_score - 15;
    IF @claim_rate   > 30  SET @health_score = @health_score - 15;
    IF @expiring_soon > 10 SET @health_score = @health_score - 10;
    IF @health_score < 0   SET @health_score = 0;

    SELECT
        @health_score           AS HealthScore,
        @active_contracts       AS ActiveContracts,
        @open_claims            AS OpenClaims,
        @overdue_invoices       AS OverdueInvoices,
        @expiring_soon          AS ExpiringSoon,
        @overdue_rate           AS OverdueRatePct,
        @claim_rate             AS ClaimRatePct,
        @today                  AS AsOfDate,
        CASE
            WHEN @health_score >= 80 THEN N'HEALTHY'
            WHEN @health_score >= 60 THEN N'WARNING'
            ELSE                          N'CRITICAL'
        END                     AS Status;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

-- SP: Son audit aktivitesi — tenant için özet (izleme için).
CREATE OR ALTER PROCEDURE reporting.SP_RecentActivity
    @tenant_id  UNIQUEIDENTIFIER,
    @hours_back INT = 24
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    DECLARE @from_utc DATETIME2(0) = DATEADD(HOUR, -@hours_back, GETUTCDATE());

    SELECT
        al.schema_name      AS SchemaName,
        al.table_name       AS TableName,
        al.action_type      AS ActionType,
        COUNT(*)            AS EventCount,
        MAX(al.changed_at_utc) AS LastEventUtc
    FROM audit.AuditLog al
    WHERE al.tenant_id = @tenant_id
      AND al.changed_at_utc >= @from_utc
    GROUP BY al.schema_name, al.table_name, al.action_type
    ORDER BY LastEventUtc DESC;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

PRINT 'Migration 036 tamamlandi: operasyonel dashboard SP''leri.';
GO
