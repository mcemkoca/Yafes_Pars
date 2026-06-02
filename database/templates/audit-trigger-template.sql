CREATE OR ALTER TRIGGER <schema>.TR_<TableName>_Audit
ON <schema>.<TableName>
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
        changed_at_utc
    )
    SELECT
        NULL,
        N'<schema>',
        N'<TableName>',
        N'<primary_key_value>',
        N'UPDATE',
        SYSUTCDATETIME();
END;
GO
