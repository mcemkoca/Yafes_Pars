SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF OBJECT_ID(N'document.Document', N'U') IS NULL
    THROW 50801, 'Missing table: document.Document', 1;

IF OBJECT_ID(N'document.DocumentType', N'U') IS NULL
    THROW 50802, 'Missing table: document.DocumentType', 1;

IF OBJECT_ID(N'document.DocumentLink', N'U') IS NULL
    THROW 50803, 'Missing table: document.DocumentLink', 1;

IF OBJECT_ID(N'document.DocumentVersion', N'U') IS NULL
    THROW 50804, 'Missing table: document.DocumentVersion', 1;

IF COL_LENGTH(N'document.Document', N'tenant_id') IS NULL
    THROW 50805, 'Missing column: document.Document.tenant_id', 1;

IF COL_LENGTH(N'document.Document', N'storage_key') IS NULL
    THROW 50806, 'Missing column: document.Document.storage_key', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = N'CK_Document_owner_entity_type'
      AND parent_object_id = OBJECT_ID(N'document.Document')
)
    THROW 50807, 'Missing check constraint: CK_Document_owner_entity_type', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_Document_Tenant'
      AND parent_object_id = OBJECT_ID(N'document.Document')
)
    THROW 50808, 'Missing FK: FK_Document_Tenant', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Document_tenant_owner'
      AND object_id = OBJECT_ID(N'document.Document')
)
    THROW 50809, 'Missing index: IX_Document_tenant_owner', 1;

PRINT 'Document domain validation passed.';
GO
