SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [YafesPars];
GO

PRINT 'Running migration: 013__add_indexes.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @MissingFkIndexes TABLE (
        schema_name SYSNAME NOT NULL,
        table_name SYSNAME NOT NULL,
        column_name SYSNAME NOT NULL,
        index_name SYSNAME NOT NULL,
        PRIMARY KEY (schema_name, table_name, column_name)
    );

    INSERT INTO @MissingFkIndexes (
        schema_name,
        table_name,
        column_name,
        index_name
    )
    SELECT DISTINCT
        s.name,
        t.name,
        c.name,
        CONVERT(SYSNAME, LEFT(N'IX_' + t.name + N'_' + c.name + N'_fk', 128))
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
    )
    AND NOT EXISTS (
        SELECT 1
        FROM sys.indexes i
        WHERE i.object_id = t.object_id
          AND i.name = CONVERT(SYSNAME, LEFT(N'IX_' + t.name + N'_' + c.name + N'_fk', 128))
    );

    DECLARE @SchemaName SYSNAME;
    DECLARE @TableName SYSNAME;
    DECLARE @ColumnName SYSNAME;
    DECLARE @IndexName SYSNAME;
    DECLARE @Sql NVARCHAR(MAX);

    DECLARE fk_index_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT schema_name, table_name, column_name, index_name
        FROM @MissingFkIndexes
        ORDER BY schema_name, table_name, column_name;

    OPEN fk_index_cursor;

    FETCH NEXT FROM fk_index_cursor
    INTO @SchemaName, @TableName, @ColumnName, @IndexName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Sql = N'CREATE INDEX ' + QUOTENAME(@IndexName)
            + N' ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName)
            + N' (' + QUOTENAME(@ColumnName) + N');';

        EXEC sys.sp_executesql @Sql;

        FETCH NEXT FROM fk_index_cursor
        INTO @SchemaName, @TableName, @ColumnName, @IndexName;
    END;

    CLOSE fk_index_cursor;
    DEALLOCATE fk_index_cursor;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_Document_tenant_uploaded'
          AND object_id = OBJECT_ID(N'document.Document')
    )
        CREATE INDEX IX_Document_tenant_uploaded
        ON document.Document (tenant_id, uploaded_at_utc DESC);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_Task_tenant_assigned_status_due'
          AND object_id = OBJECT_ID(N'tasking.Task')
    )
        CREATE INDEX IX_Task_tenant_assigned_status_due
        ON tasking.Task (tenant_id, assigned_to_user_id, task_status_code, due_at_utc);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_AuditLog_correlation'
          AND object_id = OBJECT_ID(N'audit.AuditLog')
    )
        CREATE INDEX IX_AuditLog_correlation
        ON audit.AuditLog (correlation_id)
        WHERE correlation_id IS NOT NULL;

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'013__add_indexes.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'013__add_indexes.sql',
            N'SUCCESS'
        );
    END;

    COMMIT TRANSACTION;
    PRINT 'Migration completed successfully.';
END TRY
BEGIN CATCH
    IF CURSOR_STATUS('local', 'fk_index_cursor') >= 0
        CLOSE fk_index_cursor;

    IF CURSOR_STATUS('local', 'fk_index_cursor') >= -1
        DEALLOCATE fk_index_cursor;

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;
GO
