-- =============================================================================
-- Migration 035: audit sorgu SP'leri + GDPR veri-erişim raporu SP'si
-- Denetçi rolü için audit log sorgulama ve GDPR Article 15 (inzagerecht).
-- =============================================================================
USE [YafesPars];
GO

BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'035__add_audit_query_sps')
        INSERT INTO core.SchemaMigration (migration_name, execution_status)
        VALUES (N'035__add_audit_query_sps', N'SUCCESS');
COMMIT TRANSACTION;
GO

-- SP: Audit log sorgusu — tenant, tablo, zaman aralığı ve işlem tipine göre filtreleme.
CREATE OR ALTER PROCEDURE audit.SP_QueryAuditLog
    @tenant_id      UNIQUEIDENTIFIER,
    @schema_name    SYSNAME         = NULL,
    @table_name     SYSNAME         = NULL,
    @entity_id      NVARCHAR(200)   = NULL,
    @action_type    NVARCHAR(20)    = NULL,   -- INSERT, UPDATE, DELETE
    @from_utc       DATETIME2(0)    = NULL,
    @to_utc         DATETIME2(0)    = NULL,
    @limit          INT             = 100
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    IF @limit < 1 OR @limit > 1000
        SET @limit = 100;

    SELECT TOP (@limit)
        al.audit_log_id         AS AuditLogId,
        al.schema_name          AS SchemaName,
        al.table_name           AS TableName,
        al.primary_key_value    AS EntityId,
        al.action_type          AS ActionType,
        al.changed_at_utc       AS ChangedAtUtc,
        al.changed_by_name      AS ChangedByName,
        al.old_values_json      AS OldValuesJson,
        al.new_values_json      AS NewValuesJson,
        al.source_system        AS SourceSystem,
        al.correlation_id       AS CorrelationId
    FROM audit.AuditLog al
    WHERE al.tenant_id = @tenant_id
      AND (@schema_name IS NULL OR al.schema_name     = @schema_name)
      AND (@table_name  IS NULL OR al.table_name      = @table_name)
      AND (@entity_id   IS NULL OR al.primary_key_value = @entity_id)
      AND (@action_type IS NULL OR al.action_type     = @action_type)
      AND (@from_utc    IS NULL OR al.changed_at_utc >= @from_utc)
      AND (@to_utc      IS NULL OR al.changed_at_utc <= @to_utc)
    ORDER BY al.changed_at_utc DESC;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

-- SP: Varlık değişiklik geçmişi — belirli bir kayıt için kolon bazlı diff.
-- P2: INNER JOIN -> LEFT JOIN: EntityChangeSet satırı olmayan AuditLog kayıtları da döner.
--     Kolon bazlı diff yoksa old/new JSON fallback olarak AuditLog.old_values_json kullanılır.
CREATE OR ALTER PROCEDURE audit.SP_GetEntityHistory
    @tenant_id      UNIQUEIDENTIFIER,
    @schema_name    SYSNAME,
    @table_name     SYSNAME,
    @entity_id      NVARCHAR(200),
    @limit          INT = 50
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    SELECT TOP (@limit)
        al.audit_log_id         AS AuditLogId,
        al.action_type          AS ActionType,
        al.changed_at_utc       AS ChangedAtUtc,
        al.changed_by_name      AS ChangedByName,
        ISNULL(cs.column_name,  N'(volledig record)')   AS ColumnName,
        ISNULL(cs.old_value,    al.old_values_json)     AS OldValue,
        ISNULL(cs.new_value,    al.new_values_json)     AS NewValue
    FROM audit.AuditLog al
    LEFT JOIN audit.EntityChangeSet cs
        ON cs.audit_log_id = al.audit_log_id
    WHERE al.tenant_id          = @tenant_id
      AND al.schema_name        = @schema_name
      AND al.table_name         = @table_name
      AND al.primary_key_value  = @entity_id
    ORDER BY al.changed_at_utc DESC, cs.column_name;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

-- SP: GDPR Article 15 — kişi bazlı tüm veri özeti (inzagerecht / recht op toegang).
-- P1 güvenlik: tüm alt sorgular person.Person üzerinden tenant_id ile izole edilir.
--   Başka tenant'ın person_id'si bilinse bile o tenant'ın verileri dönmez.
-- P1 tip: audit_log_id BIGINT — UNIQUEIDENTIFIER'a cast edilemez.
--   Audit satırları için entity_id = NULL (C# GdprDataRow.EntityId nullable yapıldı).
CREATE OR ALTER PROCEDURE audit.SP_GdprDataAccessReport
    @tenant_id  UNIQUEIDENTIFIER,
    @person_id  UNIQUEIDENTIFIER
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    -- Temel kişi bilgileri — tenant_id burada kontrol edilir.
    SELECT
        'person'            AS DataCategory,
        'Persoonsgegevens'  AS Label,
        p.person_id         AS EntityId,
        p.dossier           AS Detail1,
        p.person_kind       AS Detail2,
        CAST(p.created_at_utc AS NVARCHAR(30)) AS CreatedAt,
        CAST(p.updated_at_utc AS NVARCHAR(30)) AS UpdatedAt,
        p.is_deleted        AS IsAnonymised
    FROM person.Person p
    WHERE p.person_id = @person_id AND p.tenant_id = @tenant_id

    UNION ALL

    -- E-mailadressen — person.Person join ile tenant izolasyonu sağlanır.
    SELECT
        'person.email'      AS DataCategory,
        'E-mailadres'       AS Label,
        e.email_id          AS EntityId,
        e.email             AS Detail1,
        CASE WHEN e.is_primary = 1 THEN 'primair' ELSE 'secundair' END AS Detail2,
        CAST(e.created_at_utc AS NVARCHAR(30)) AS CreatedAt,
        CAST(e.updated_at_utc AS NVARCHAR(30)) AS UpdatedAt,
        e.is_deleted        AS IsAnonymised
    FROM person.Email e
    INNER JOIN person.Person p
        ON p.person_id = e.person_id AND p.tenant_id = @tenant_id
    WHERE e.person_id = @person_id

    UNION ALL

    -- Telefoonnummers — tenant izolasyonu.
    SELECT
        'person.phone'      AS DataCategory,
        'Telefoonnummer'    AS Label,
        ph.phone_id         AS EntityId,
        ph.phone_number     AS Detail1,
        ph.phone_type_code  AS Detail2,
        CAST(ph.created_at_utc AS NVARCHAR(30)) AS CreatedAt,
        CAST(ph.updated_at_utc AS NVARCHAR(30)) AS UpdatedAt,
        ph.is_deleted       AS IsAnonymised
    FROM person.Phone ph
    INNER JOIN person.Person p
        ON p.person_id = ph.person_id AND p.tenant_id = @tenant_id
    WHERE ph.person_id = @person_id

    UNION ALL

    -- Adressen — tenant izolasyonu.
    SELECT
        'person.address'    AS DataCategory,
        'Adres'             AS Label,
        a.address_id        AS EntityId,
        CONCAT(a.street, ' ', a.house_number, ', ', a.postal_code, ' ', a.city) AS Detail1,
        a.country_code      AS Detail2,
        CAST(a.created_at_utc AS NVARCHAR(30)) AS CreatedAt,
        CAST(a.updated_at_utc AS NVARCHAR(30)) AS UpdatedAt,
        a.is_deleted        AS IsAnonymised
    FROM person.Address a
    INNER JOIN person.Person p
        ON p.person_id = a.person_id AND p.tenant_id = @tenant_id
    WHERE a.person_id = @person_id

    UNION ALL

    -- Audit kayıtları — audit_log_id BIGINT olduğu için EntityId NULL döner.
    -- C# tarafında GdprDataRow.EntityId nullable (Guid?) olarak tanımlanmıştır.
    SELECT TOP 50
        'audit'             AS DataCategory,
        'Auditlog'          AS Label,
        NULL                AS EntityId,
        CONCAT(al.schema_name, '.', al.table_name) AS Detail1,
        al.action_type      AS Detail2,
        CAST(al.changed_at_utc AS NVARCHAR(30)) AS CreatedAt,
        CAST(al.changed_at_utc AS NVARCHAR(30)) AS UpdatedAt,
        0                   AS IsAnonymised
    FROM audit.AuditLog al
    WHERE al.tenant_id = @tenant_id
      AND al.primary_key_value = CAST(@person_id AS NVARCHAR(200))

    ORDER BY DataCategory, CreatedAt DESC;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

PRINT 'Migration 035 tamamlandi: audit SP''leri + GDPR veri-erisim raporu.';
GO
