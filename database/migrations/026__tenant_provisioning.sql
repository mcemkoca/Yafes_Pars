-- =============================================================================
-- Migration 026: Tenant provisioning + systeeminstellingen
--   core.SystemSetting   — globale sleutel/waarde-instellingen (environment-marker,
--                          demo-data vlag) → basis voor DEMO/PROD-scheiding.
--   core.SP_ProvisionTenant — onboarding van een nieuwe verzekeraar/makelaar:
--                          tenant + initiële beheerder (AppUser) + BROKER_ADMIN-rol.
--                          Vervangt het leunen op 018__seed_demo_data in PROD.
-- =============================================================================
USE [YafesPars];
GO

BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'026__tenant_provisioning')
    BEGIN

        IF OBJECT_ID(N'core.SystemSetting', N'U') IS NULL
        BEGIN
            CREATE TABLE core.SystemSetting (
                setting_key    NVARCHAR(100) NOT NULL,
                setting_value  NVARCHAR(400) NULL,
                description    NVARCHAR(400) NULL,
                updated_at_utc DATETIME2(0)  NOT NULL
                    CONSTRAINT DF_SystemSetting_updated_at_utc DEFAULT SYSUTCDATETIME(),
                CONSTRAINT PK_SystemSetting PRIMARY KEY (setting_key)
            );

            INSERT INTO core.SystemSetting (setting_key, setting_value, description)
            VALUES
                (N'environment',      N'DEV', N'Doelomgeving: DEV / TEST / PROD. PROD blokkeert demo-seed.'),
                (N'demo_data_seeded', N'0',   N'1 als 018__seed_demo_data is toegepast.');
        END

        INSERT INTO core.SchemaMigration (migration_name, execution_status)
        VALUES (N'026__tenant_provisioning', N'SUCCESS');

    END

COMMIT TRANSACTION;
GO

-- ── core.SP_ProvisionTenant ──────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE core.SP_ProvisionTenant
    @tenant_code               NVARCHAR(80),
    @legal_name                NVARCHAR(200),
    @display_name              NVARCHAR(200)    = NULL,
    @vat_number                NVARCHAR(30)     = NULL,
    @admin_email               NVARCHAR(320),
    @admin_display_name        NVARCHAR(160)    = NULL,
    @admin_external_subject_id NVARCHAR(200)    = NULL,
    @auth_provider             NVARCHAR(40)     = N'EXTERNAL',
    @tenant_id                 UNIQUEIDENTIFIER OUTPUT,
    @admin_user_id             UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NULLIF(LTRIM(RTRIM(@tenant_code)), N'') IS NULL
        THROW 51900, 'tenant_code is verplicht.', 1;
    IF NULLIF(LTRIM(RTRIM(@legal_name)), N'') IS NULL
        THROW 51901, 'legal_name is verplicht.', 1;
    IF NULLIF(LTRIM(RTRIM(@admin_email)), N'') IS NULL
        THROW 51902, 'admin_email is verplicht.', 1;
    IF EXISTS (SELECT 1 FROM core.Tenant WHERE tenant_code = @tenant_code)
        THROW 51903, 'tenant_code bestaat al voor een andere tenant.', 1;

    -- Globale BROKER_ADMIN-rol (tenant_id IS NULL) voor de initiële beheerder.
    DECLARE @adminRoleId UNIQUEIDENTIFIER =
        (SELECT TOP 1 role_id FROM core.Role
         WHERE role_code = N'BROKER_ADMIN' AND tenant_id IS NULL AND is_active = 1);

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
END;
GO

PRINT 'Migration 026 voltooid: tenant provisioning + SystemSetting.';
GO
