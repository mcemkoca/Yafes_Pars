-- =============================================================================
-- Migration 027: GDPR recht-op-vergetelheid (right-to-erasure)
--   core.SP_ErasePersonData — anonimiseert persoonsgegevens (PII) van een
--   natuurlijke persoon, maar BEHOUDT person_id zodat polissen/schades
--   referentieel intact blijven (wettelijke bewaarplicht transactiegegevens).
--   Tenant-scoped. Onomkeerbaar.
-- =============================================================================
USE [YafesPars];
GO

BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'027__gdpr_erasure')
        INSERT INTO core.SchemaMigration (migration_name, execution_status)
        VALUES (N'027__gdpr_erasure', N'SUCCESS');
COMMIT TRANSACTION;
GO

CREATE OR ALTER PROCEDURE core.SP_ErasePersonData
    @tenant_id     UNIQUEIDENTIFIER,
    @person_id     UNIQUEIDENTIFIER,
    @reason        NVARCHAR(400)    = NULL,
    @erased_fields INT              OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @erased_fields = 0;

    IF NOT EXISTS (
        SELECT 1 FROM person.Person
        WHERE person_id = @person_id AND tenant_id = @tenant_id AND is_deleted = 0)
        THROW 51950, 'Persoon niet gevonden voor deze tenant.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Natuurlijke persoon — PII anonimiseren
        UPDATE person.NaturalPerson
        SET first_name      = N'GEWIST',
            last_name       = N'GEWIST',
            birth_date      = NULL,
            birth_place     = NULL,
            gender          = NULL,
            marital_status  = NULL,
            national_number = NULL,
            passport_number = NULL,
            id_card_number  = NULL,
            rrn             = NULL,
            updated_at_utc  = SYSUTCDATETIME()
        WHERE person_id = @person_id;
        SET @erased_fields += @@ROWCOUNT;

        -- Contactgegevens anonimiseren
        UPDATE e SET e.email = N'gewist@geanonimiseerd.local', e.updated_at_utc = SYSUTCDATETIME()
        FROM person.Email e WHERE e.person_id = @person_id;
        SET @erased_fields += @@ROWCOUNT;

        UPDATE p SET p.phone_number = N'0000000000', p.updated_at_utc = SYSUTCDATETIME()
        FROM person.Phone p WHERE p.person_id = @person_id;
        SET @erased_fields += @@ROWCOUNT;

        UPDATE a SET a.street = N'GEWIST', a.house_number = NULL, a.box = NULL,
                     a.postal_code = NULL, a.city = N'GEWIST', a.remark = NULL,
                     a.updated_at_utc = SYSUTCDATETIME()
        FROM person.Address a WHERE a.person_id = @person_id;
        SET @erased_fields += @@ROWCOUNT;

        UPDATE b SET b.iban = N'ANONIEM', b.bic = NULL, b.bank = N'GEWIST',
                     b.updated_at_utc = SYSUTCDATETIME()
        FROM person.BankAccount b WHERE b.person_id = @person_id;
        SET @erased_fields += @@ROWCOUNT;

        -- Dossier markeren als geanonimiseerd
        UPDATE person.Person
        SET dossier = LEFT(N'GEWIST-' + CAST(person_id AS NVARCHAR(36)), 50),
            updated_at_utc = SYSUTCDATETIME()
        WHERE person_id = @person_id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

PRINT 'Migration 027 voltooid: GDPR recht-op-vergetelheid.';
GO
