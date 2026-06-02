SET NOCOUNT ON;
GO

USE [YafesPars];
GO

DECLARE @MissingFkIndexes TABLE (
    fk_name SYSNAME NOT NULL,
    schema_name SYSNAME NOT NULL,
    table_name SYSNAME NOT NULL,
    column_name SYSNAME NOT NULL
);

INSERT INTO @MissingFkIndexes (
    fk_name,
    schema_name,
    table_name,
    column_name
)
SELECT
    fk.name,
    s.name,
    t.name,
    c.name
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc
    ON fkc.constraint_object_id = fk.object_id
   AND fkc.constraint_column_id = 1
INNER JOIN sys.tables t
    ON t.object_id = fk.parent_object_id
INNER JOIN sys.schemas s
    ON s.schema_id = t.schema_id
INNER JOIN sys.columns c
    ON c.object_id = t.object_id
   AND c.column_id = fkc.parent_column_id
WHERE NOT EXISTS (
    SELECT 1
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic
        ON ic.object_id = i.object_id
       AND ic.index_id = i.index_id
       AND ic.key_ordinal = 1
    WHERE i.object_id = t.object_id
      AND i.is_hypothetical = 0
      AND ic.column_id = fkc.parent_column_id
);

IF EXISTS (SELECT 1 FROM @MissingFkIndexes)
BEGIN
    SELECT fk_name, schema_name, table_name, column_name
    FROM @MissingFkIndexes
    ORDER BY schema_name, table_name, column_name;

    THROW 51201, 'Missing FK-supporting indexes detected.', 1;
END;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Document_tenant_uploaded'
      AND object_id = OBJECT_ID(N'document.Document')
)
    THROW 51202, 'Missing index: IX_Document_tenant_uploaded', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Task_tenant_assigned_status_due'
      AND object_id = OBJECT_ID(N'tasking.Task')
)
    THROW 51203, 'Missing index: IX_Task_tenant_assigned_status_due', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_AuditLog_correlation'
      AND object_id = OBJECT_ID(N'audit.AuditLog')
)
    THROW 51204, 'Missing index: IX_AuditLog_correlation', 1;

PRINT 'Index validation passed.';
GO
