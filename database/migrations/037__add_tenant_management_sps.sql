-- =============================================================================
-- Migration 037: tenant yönetim SP'leri — listeleme, deaktivation, sistem ayarları
-- core.SP_ProvisionTenant (migration 026) üzerindeki admin araçları.
-- =============================================================================
USE [YafesPars];
GO

BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'037__add_tenant_management_sps')
        INSERT INTO core.SchemaMigration (migration_name, execution_status)
        VALUES (N'037__add_tenant_management_sps', N'SUCCESS');
COMMIT TRANSACTION;
GO

-- SP_ProvisionTenant: migration 026'dan uzatıldı — sonuç satırı döndürecek şekilde.
-- CREATE OR ALTER mevcut tanımı korur, sadece SELECT çıkışını ekler.
CREATE OR ALTER PROCEDURE core.SP_ProvisionTenant
    @tenant_code               NVARCHAR(80),
    @legal_name                NVARCHAR(200),
    @display_name              NVARCHAR(200)    = NULL,
    @vat_number                NVARCHAR(30)     = NULL,
    @admin_email               NVARCHAR(320),
    @admin_display_name        NVARCHAR(160)    = NULL,
    @admin_external_subject_id NVARCHAR(200)    = NULL,
    @auth_provider             NVARCHAR(40)     = NULL
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
    DECLARE @tenant_id    UNIQUEIDENTIFIER;
    DECLARE @admin_user_id UNIQUEIDENTIFIER;
    DECLARE @adminRoleId  UNIQUEIDENTIFIER;

    SELECT @adminRoleId = role_id
    FROM core.Role
    WHERE role_code = N'Admin'
      AND tenant_id IN (
          SELECT tenant_id FROM core.Tenant WHERE tenant_code = N'SYSTEM' AND is_active = 1
      );

    BEGIN TRY
        BEGIN TRANSACTION;

        SET @tenant_id = NEWID();
        INSERT INTO core.Tenant (tenant_id, tenant_code, legal_name, display_name, vat_number, is_active)
        VALUES (@tenant_id, @tenant_code, @legal_name, ISNULL(NULLIF(@display_name, N''), @legal_name), @vat_number, 1);

        SET @admin_user_id = NEWID();
        INSERT INTO core.AppUser
            (user_id, tenant_id, email, display_name, auth_provider, external_subject_id, is_active)
        VALUES
            (@admin_user_id, @tenant_id, @admin_email,
             ISNULL(NULLIF(@admin_display_name, N''), @admin_email),
             ISNULL(@auth_provider, N'EXTERNAL'), @admin_external_subject_id, 1);

        IF @adminRoleId IS NOT NULL
            INSERT INTO core.UserRole (user_id, role_id) VALUES (@admin_user_id, @adminRoleId);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH

    SELECT
        @tenant_id      AS TenantId,
        @tenant_code    AS TenantCode,
        @admin_user_id  AS AdminUserId,
        @admin_email    AS AdminEmail;
END;
GO

-- SP: Tüm tenant'ları listele (Admin).
CREATE OR ALTER PROCEDURE core.SP_GetTenants
    @include_inactive BIT = 0
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    SELECT
        t.tenant_id         AS TenantId,
        t.tenant_code       AS TenantCode,
        t.legal_name        AS LegalName,
        t.display_name      AS DisplayName,
        t.vat_number        AS VatNumber,
        t.is_active         AS IsActive,
        t.created_at_utc    AS CreatedAtUtc,
        (SELECT COUNT(*) FROM core.AppUser u WHERE u.tenant_id = t.tenant_id AND u.is_active = 1) AS ActiveUserCount,
        (SELECT COUNT(*) FROM policy.Contract c WHERE c.tenant_id = t.tenant_id AND c.is_deleted = 0 AND c.contract_status_code = N'ACTIVE') AS ActiveContractCount
    FROM core.Tenant t
    WHERE @include_inactive = 1 OR t.is_active = 1
    ORDER BY t.legal_name;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

-- SP: Tenant'ı deaktive et (soft-disable; veriler korunur).
CREATE OR ALTER PROCEDURE core.SP_DeactivateTenant
    @tenant_id  UNIQUEIDENTIFIER,
    @reason     NVARCHAR(400) = NULL
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM core.Tenant WHERE tenant_id = @tenant_id)
        THROW 60001, N'Tenant bulunamadı.', 1;

    IF NOT EXISTS (SELECT 1 FROM core.Tenant WHERE tenant_id = @tenant_id AND is_active = 1)
        THROW 60002, N'Tenant zaten deaktif.', 1;

    UPDATE core.Tenant
    SET is_active = 0
    WHERE tenant_id = @tenant_id;

    -- Audit kaydı
    INSERT INTO audit.AuditLog (
        tenant_id, schema_name, table_name, primary_key_value,
        action_type, changed_by_name, new_values_json, source_system
    )
    VALUES (
        @tenant_id, N'core', N'Tenant', CAST(@tenant_id AS NVARCHAR(200)),
        N'UPDATE', N'SYSTEM',
        CONCAT(N'{"is_active":false,"reason":"', ISNULL(@reason, N''), N'"}'),
        N'TenantManagement'
    );

    SELECT
        t.tenant_id     AS TenantId,
        t.tenant_code   AS TenantCode,
        t.legal_name    AS LegalName,
        t.is_active     AS IsActive
    FROM core.Tenant t
    WHERE t.tenant_id = @tenant_id;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

-- SP: Tüm sistem ayarlarını getir.
CREATE OR ALTER PROCEDURE core.SP_GetSystemSettings
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    SELECT
        setting_key     AS SettingKey,
        setting_value   AS SettingValue,
        description     AS Description,
        updated_at_utc  AS UpdatedAtUtc
    FROM core.SystemSetting
    ORDER BY setting_key;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

-- SP: Sistem ayarı ekle veya güncelle (upsert).
CREATE OR ALTER PROCEDURE core.SP_UpsertSystemSetting
    @setting_key    NVARCHAR(100),
    @setting_value  NVARCHAR(400),
    @description    NVARCHAR(400) = NULL
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    IF LEN(LTRIM(RTRIM(@setting_key))) = 0
        THROW 60010, N'setting_key boş olamaz.', 1;

    MERGE core.SystemSetting AS target
    USING (SELECT @setting_key AS setting_key) AS source
        ON target.setting_key = source.setting_key
    WHEN MATCHED THEN
        UPDATE SET
            setting_value  = @setting_value,
            description    = ISNULL(@description, target.description),
            updated_at_utc = SYSUTCDATETIME()
    WHEN NOT MATCHED THEN
        INSERT (setting_key, setting_value, description, updated_at_utc)
        VALUES (@setting_key, @setting_value, @description, SYSUTCDATETIME());

    SELECT
        setting_key     AS SettingKey,
        setting_value   AS SettingValue,
        description     AS Description,
        updated_at_utc  AS UpdatedAtUtc
    FROM core.SystemSetting
    WHERE setting_key = @setting_key;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

-- SP: Tenant izolasyon kontrolü — başka tenant'ın verisine erişim olup olmadığını test et.
-- CI/otomated test aracı: belirli bir tablodaki tenant_id dağılımını listeler.
CREATE OR ALTER PROCEDURE core.SP_TenantIsolationCheck
    @schema_name    SYSNAME,
    @table_name     SYSNAME
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    DECLARE @sql NVARCHAR(MAX) = CONCAT(
        N'SELECT tenant_id AS TenantId, COUNT(*) AS RowCount ',
        N'FROM ', QUOTENAME(@schema_name), N'.', QUOTENAME(@table_name), N' ',
        N'GROUP BY tenant_id ',
        N'ORDER BY RowCount DESC'
    );
    EXEC sp_executesql @sql;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

PRINT 'Migration 037 tamamlandi: tenant yönetim SP''leri.';
GO
