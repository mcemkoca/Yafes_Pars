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
        cs.column_name          AS ColumnName,
        cs.old_value            AS OldValue,
        cs.new_value            AS NewValue
    FROM audit.AuditLog al
    INNER JOIN audit.EntityChangeSet cs
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
-- Kişiye ait tüm kayıtları schema bazlı özetler; silerek anonimleştirilen kayıtlar dahil.
CREATE OR ALTER PROCEDURE audit.SP_GdprDataAccessReport
    @tenant_id  UNIQUEIDENTIFIER,
    @person_id  UNIQUEIDENTIFIER
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    -- Temel kişi bilgileri
    SELECT
        'person'            AS data_category,
        'Persoonsgegevens'  AS label,
        p.person_id         AS entity_id,
        p.dossier           AS detail_1,
        p.person_kind       AS detail_2,
        CAST(p.created_at_utc AS NVARCHAR(30)) AS created_at,
        CAST(p.updated_at_utc AS NVARCHAR(30)) AS updated_at,
        p.is_deleted        AS is_anonymised
    FROM person.Person p
    WHERE p.person_id = @person_id AND p.tenant_id = @tenant_id

    UNION ALL

    -- E-mailadressen
    SELECT
        'person.email'      AS data_category,
        'E-mailadres'       AS label,
        e.email_id          AS entity_id,
        e.email             AS detail_1,
        CASE WHEN e.is_primary = 1 THEN 'primair' ELSE 'secundair' END AS detail_2,
        CAST(e.created_at_utc AS NVARCHAR(30)) AS created_at,
        CAST(e.updated_at_utc AS NVARCHAR(30)) AS updated_at,
        e.is_deleted        AS is_anonymised
    FROM person.Email e
    WHERE e.person_id = @person_id

    UNION ALL

    -- Telefoonnummers
    SELECT
        'person.phone'      AS data_category,
        'Telefoonnummer'    AS label,
        ph.phone_id         AS entity_id,
        ph.phone_number     AS detail_1,
        ph.phone_type_code  AS detail_2,
        CAST(ph.created_at_utc AS NVARCHAR(30)) AS created_at,
        CAST(ph.updated_at_utc AS NVARCHAR(30)) AS updated_at,
        ph.is_deleted       AS is_anonymised
    FROM person.Phone ph
    WHERE ph.person_id = @person_id

    UNION ALL

    -- Adressen
    SELECT
        'person.address'    AS data_category,
        'Adres'             AS label,
        a.address_id        AS entity_id,
        CONCAT(a.street, ' ', a.house_number, ', ', a.postal_code, ' ', a.city) AS detail_1,
        a.country_code      AS detail_2,
        CAST(a.created_at_utc AS NVARCHAR(30)) AS created_at,
        CAST(a.updated_at_utc AS NVARCHAR(30)) AS updated_at,
        a.is_deleted        AS is_anonymised
    FROM person.Address a
    WHERE a.person_id = @person_id

    UNION ALL

    -- Audit kayıtları (bu kişi için yapılan değişiklikler)
    -- audit_log_id BIGINT'tir; UNIQUEIDENTIFIER'a cast edilemez, NVARCHAR üzerinden NEWID ile temsil edilir.
    SELECT TOP 50
        'audit'             AS data_category,
        'Auditlog'          AS label,
        CAST(HASHBYTES('MD5', CAST(al.audit_log_id AS NVARCHAR(36))) AS UNIQUEIDENTIFIER) AS entity_id,
        al.table_name       AS detail_1,
        al.action_type      AS detail_2,
        CAST(al.changed_at_utc AS NVARCHAR(30)) AS created_at,
        CAST(al.changed_at_utc AS NVARCHAR(30)) AS updated_at,
        0                   AS is_anonymised
    FROM audit.AuditLog al
    WHERE al.tenant_id = @tenant_id
      AND al.primary_key_value = CAST(@person_id AS NVARCHAR(200))

    ORDER BY data_category, created_at DESC;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

PRINT 'Migration 035 tamamlandi: audit SP''leri + GDPR veri-erisim raporu.';
GO
