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
        old_values_json,
        new_values_json,
        source_system
    )
    SELECT
        COALESCE(i.tenant_id, d.tenant_id),
        N'<schema>',
        N'<TableName>',
        CONVERT(NVARCHAR(200), COALESCE(i.<primary_key_column>, d.<primary_key_column>)),
        CASE
            WHEN d.<primary_key_column> IS NULL THEN N'INSERT'
            WHEN i.<primary_key_column> IS NULL THEN N'DELETE'
            ELSE N'UPDATE'
        END,
        CASE WHEN d.<primary_key_column> IS NULL THEN NULL
            ELSE CONCAT(N'{"<primary_key_column>":"', CONVERT(NVARCHAR(36), d.<primary_key_column>), N'"}') END,
        CASE WHEN i.<primary_key_column> IS NULL THEN NULL
            ELSE CONCAT(N'{"<primary_key_column>":"', CONVERT(NVARCHAR(36), i.<primary_key_column>), N'"}') END,
        N'SQL_TRIGGER'
    FROM inserted i
    FULL OUTER JOIN deleted d ON d.<primary_key_column> = i.<primary_key_column>;
END;
GO
