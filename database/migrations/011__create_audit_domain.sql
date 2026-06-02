SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [YafesPars];
GO

PRINT 'Running migration: 011__create_audit_domain.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'audit.AuditLog', N'U') IS NULL
    BEGIN
        CREATE TABLE audit.AuditLog (
            audit_log_id BIGINT IDENTITY(1,1) NOT NULL,
            tenant_id UNIQUEIDENTIFIER NULL,
            schema_name SYSNAME NOT NULL,
            table_name SYSNAME NOT NULL,
            primary_key_value NVARCHAR(200) NOT NULL,
            action_type NVARCHAR(20) NOT NULL,
            changed_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_AuditLog_changed_at_utc DEFAULT SYSUTCDATETIME(),
            changed_by_user_id UNIQUEIDENTIFIER NULL,
            changed_by_name NVARCHAR(200) NULL
                CONSTRAINT DF_AuditLog_changed_by_name DEFAULT SUSER_SNAME(),
            old_values_json NVARCHAR(MAX) NULL,
            new_values_json NVARCHAR(MAX) NULL,
            source_system NVARCHAR(80) NULL,
            correlation_id UNIQUEIDENTIFIER NULL,
            CONSTRAINT PK_AuditLog PRIMARY KEY (audit_log_id),
            CONSTRAINT CK_AuditLog_action_type CHECK (action_type IN (N'INSERT', N'UPDATE', N'DELETE')),
            CONSTRAINT FK_AuditLog_Tenant FOREIGN KEY (tenant_id)
                REFERENCES core.Tenant (tenant_id),
            CONSTRAINT FK_AuditLog_AppUser_ChangedBy FOREIGN KEY (changed_by_user_id)
                REFERENCES core.AppUser (user_id)
        );
    END;

    IF OBJECT_ID(N'audit.EntityChangeSet', N'U') IS NULL
    BEGIN
        CREATE TABLE audit.EntityChangeSet (
            entity_change_set_id BIGINT IDENTITY(1,1) NOT NULL,
            audit_log_id BIGINT NOT NULL,
            column_name SYSNAME NOT NULL,
            old_value NVARCHAR(MAX) NULL,
            new_value NVARCHAR(MAX) NULL,
            CONSTRAINT PK_EntityChangeSet PRIMARY KEY (entity_change_set_id),
            CONSTRAINT FK_EntityChangeSet_AuditLog FOREIGN KEY (audit_log_id)
                REFERENCES audit.AuditLog (audit_log_id)
        );
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_AuditLog_tenant_changed'
          AND object_id = OBJECT_ID(N'audit.AuditLog')
    )
        CREATE INDEX IX_AuditLog_tenant_changed
        ON audit.AuditLog (tenant_id, changed_at_utc DESC);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_AuditLog_entity'
          AND object_id = OBJECT_ID(N'audit.AuditLog')
    )
        CREATE INDEX IX_AuditLog_entity
        ON audit.AuditLog (schema_name, table_name, primary_key_value, changed_at_utc DESC);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_EntityChangeSet_audit_log_id'
          AND object_id = OBJECT_ID(N'audit.EntityChangeSet')
    )
        CREATE INDEX IX_EntityChangeSet_audit_log_id
        ON audit.EntityChangeSet (audit_log_id);

    COMMIT TRANSACTION;
    PRINT 'Audit tables created.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;
GO

PRINT 'Creating audit trigger: person.TR_Person_Audit';
GO

CREATE OR ALTER TRIGGER person.TR_Person_Audit
ON person.Person
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO audit.AuditLog (
        tenant_id,
        schema_name,
        table_name,
        primary_key_value,
        action_type,
        old_values_json,
        new_values_json,
        source_system
    )
    SELECT
        COALESCE(i.tenant_id, d.tenant_id),
        N'person',
        N'Person',
        CONVERT(NVARCHAR(200), COALESCE(i.person_id, d.person_id)),
        CASE
            WHEN d.person_id IS NULL THEN N'INSERT'
            WHEN i.person_id IS NULL THEN N'DELETE'
            ELSE N'UPDATE'
        END,
        CASE WHEN d.person_id IS NULL THEN NULL
            ELSE CONCAT(N'{"person_id":"', CONVERT(NVARCHAR(36), d.person_id), N'"}') END,
        CASE WHEN i.person_id IS NULL THEN NULL
            ELSE CONCAT(N'{"person_id":"', CONVERT(NVARCHAR(36), i.person_id), N'"}') END,
        N'SQL_TRIGGER'
    FROM inserted i
    FULL OUTER JOIN deleted d ON d.person_id = i.person_id;
END;
GO

PRINT 'Creating audit trigger: institution.TR_Institution_Audit';
GO

CREATE OR ALTER TRIGGER institution.TR_Institution_Audit
ON institution.Institution
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO audit.AuditLog (
        tenant_id,
        schema_name,
        table_name,
        primary_key_value,
        action_type,
        old_values_json,
        new_values_json,
        source_system
    )
    SELECT
        COALESCE(i.tenant_id, d.tenant_id),
        N'institution',
        N'Institution',
        CONVERT(NVARCHAR(200), COALESCE(i.institution_id, d.institution_id)),
        CASE
            WHEN d.institution_id IS NULL THEN N'INSERT'
            WHEN i.institution_id IS NULL THEN N'DELETE'
            ELSE N'UPDATE'
        END,
        CASE WHEN d.institution_id IS NULL THEN NULL
            ELSE CONCAT(N'{"institution_id":"', CONVERT(NVARCHAR(36), d.institution_id), N'"}') END,
        CASE WHEN i.institution_id IS NULL THEN NULL
            ELSE CONCAT(N'{"institution_id":"', CONVERT(NVARCHAR(36), i.institution_id), N'"}') END,
        N'SQL_TRIGGER'
    FROM inserted i
    FULL OUTER JOIN deleted d ON d.institution_id = i.institution_id;
END;
GO

PRINT 'Creating audit trigger: risk.TR_InsurableObject_Audit';
GO

CREATE OR ALTER TRIGGER risk.TR_InsurableObject_Audit
ON risk.InsurableObject
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO audit.AuditLog (
        tenant_id,
        schema_name,
        table_name,
        primary_key_value,
        action_type,
        old_values_json,
        new_values_json,
        source_system
    )
    SELECT
        COALESCE(i.tenant_id, d.tenant_id),
        N'risk',
        N'InsurableObject',
        CONVERT(NVARCHAR(200), COALESCE(i.insurable_object_id, d.insurable_object_id)),
        CASE
            WHEN d.insurable_object_id IS NULL THEN N'INSERT'
            WHEN i.insurable_object_id IS NULL THEN N'DELETE'
            ELSE N'UPDATE'
        END,
        CASE WHEN d.insurable_object_id IS NULL THEN NULL
            ELSE CONCAT(N'{"insurable_object_id":"', CONVERT(NVARCHAR(36), d.insurable_object_id), N'"}') END,
        CASE WHEN i.insurable_object_id IS NULL THEN NULL
            ELSE CONCAT(N'{"insurable_object_id":"', CONVERT(NVARCHAR(36), i.insurable_object_id), N'"}') END,
        N'SQL_TRIGGER'
    FROM inserted i
    FULL OUTER JOIN deleted d ON d.insurable_object_id = i.insurable_object_id;
END;
GO

PRINT 'Creating audit trigger: policy.TR_Contract_Audit';
GO

CREATE OR ALTER TRIGGER policy.TR_Contract_Audit
ON policy.Contract
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO audit.AuditLog (
        tenant_id,
        schema_name,
        table_name,
        primary_key_value,
        action_type,
        old_values_json,
        new_values_json,
        source_system
    )
    SELECT
        COALESCE(i.tenant_id, d.tenant_id),
        N'policy',
        N'Contract',
        CONVERT(NVARCHAR(200), COALESCE(i.contract_id, d.contract_id)),
        CASE
            WHEN d.contract_id IS NULL THEN N'INSERT'
            WHEN i.contract_id IS NULL THEN N'DELETE'
            ELSE N'UPDATE'
        END,
        CASE WHEN d.contract_id IS NULL THEN NULL
            ELSE CONCAT(N'{"contract_id":"', CONVERT(NVARCHAR(36), d.contract_id), N'"}') END,
        CASE WHEN i.contract_id IS NULL THEN NULL
            ELSE CONCAT(N'{"contract_id":"', CONVERT(NVARCHAR(36), i.contract_id), N'"}') END,
        N'SQL_TRIGGER'
    FROM inserted i
    FULL OUTER JOIN deleted d ON d.contract_id = i.contract_id;
END;
GO

PRINT 'Creating audit trigger: policy.TR_ContractVersion_Audit';
GO

CREATE OR ALTER TRIGGER policy.TR_ContractVersion_Audit
ON policy.ContractVersion
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO audit.AuditLog (
        tenant_id,
        schema_name,
        table_name,
        primary_key_value,
        action_type,
        old_values_json,
        new_values_json,
        source_system
    )
    SELECT
        c.tenant_id,
        N'policy',
        N'ContractVersion',
        CONVERT(NVARCHAR(200), COALESCE(i.contract_version_id, d.contract_version_id)),
        CASE
            WHEN d.contract_version_id IS NULL THEN N'INSERT'
            WHEN i.contract_version_id IS NULL THEN N'DELETE'
            ELSE N'UPDATE'
        END,
        CASE WHEN d.contract_version_id IS NULL THEN NULL
            ELSE CONCAT(N'{"contract_version_id":"', CONVERT(NVARCHAR(36), d.contract_version_id), N'"}') END,
        CASE WHEN i.contract_version_id IS NULL THEN NULL
            ELSE CONCAT(N'{"contract_version_id":"', CONVERT(NVARCHAR(36), i.contract_version_id), N'"}') END,
        N'SQL_TRIGGER'
    FROM inserted i
    FULL OUTER JOIN deleted d ON d.contract_version_id = i.contract_version_id
    INNER JOIN policy.Contract c ON c.contract_id = COALESCE(i.contract_id, d.contract_id);
END;
GO

PRINT 'Creating audit trigger: claim.TR_Claim_Audit';
GO

CREATE OR ALTER TRIGGER claim.TR_Claim_Audit
ON claim.Claim
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO audit.AuditLog (
        tenant_id,
        schema_name,
        table_name,
        primary_key_value,
        action_type,
        old_values_json,
        new_values_json,
        source_system
    )
    SELECT
        COALESCE(i.tenant_id, d.tenant_id),
        N'claim',
        N'Claim',
        CONVERT(NVARCHAR(200), COALESCE(i.claim_id, d.claim_id)),
        CASE
            WHEN d.claim_id IS NULL THEN N'INSERT'
            WHEN i.claim_id IS NULL THEN N'DELETE'
            ELSE N'UPDATE'
        END,
        CASE WHEN d.claim_id IS NULL THEN NULL
            ELSE CONCAT(N'{"claim_id":"', CONVERT(NVARCHAR(36), d.claim_id), N'"}') END,
        CASE WHEN i.claim_id IS NULL THEN NULL
            ELSE CONCAT(N'{"claim_id":"', CONVERT(NVARCHAR(36), i.claim_id), N'"}') END,
        N'SQL_TRIGGER'
    FROM inserted i
    FULL OUTER JOIN deleted d ON d.claim_id = i.claim_id;
END;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'011__create_audit_domain.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'011__create_audit_domain.sql',
            N'SUCCESS'
        );
    END;

    COMMIT TRANSACTION;
    PRINT 'Migration completed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @FinalErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @FinalErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @FinalErrorState INT = ERROR_STATE();

    RAISERROR(@FinalErrorMessage, @FinalErrorSeverity, @FinalErrorState);
END CATCH;
GO
