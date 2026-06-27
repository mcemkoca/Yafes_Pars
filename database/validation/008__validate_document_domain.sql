SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF OBJECT_ID(N'document.Document', N'U') IS NULL
    THROW 50801, 'Missing table: document.Document', 1;

IF OBJECT_ID(N'document.DocumentType', N'U') IS NULL
    THROW 50802, 'Missing table: document.DocumentType', 1;

-- Migration 021: document.DocumentLink → _obsolete_DocumentLink; DocumentLinks is the active table
IF OBJECT_ID(N'document.DocumentLinks', N'U') IS NULL
    THROW 50803, 'Missing table: document.DocumentLinks', 1;

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

IF EXISTS (
    SELECT 1
    FROM document.Document
    WHERE owner_entity_type NOT IN (N'PERSON', N'INSTITUTION', N'POLICY', N'CLAIM', N'RISK_OBJECT')
)
    THROW 50810, 'Invalid document owner_entity_type.', 1;

IF EXISTS (
    SELECT 1
    FROM document.Document
    WHERE file_size_bytes <= 0
)
    THROW 50811, 'Document file_size_bytes must be positive.', 1;

IF EXISTS (
    SELECT 1
    FROM document.Document
    WHERE storage_key IS NULL
       OR LTRIM(RTRIM(storage_key)) = N''
)
    THROW 50812, 'Document storage_key cannot be empty.', 1;

IF EXISTS (
    SELECT 1
    FROM document.Document
    WHERE (is_deleted = 1 AND deleted_at_utc IS NULL)
       OR (is_deleted = 0 AND deleted_at_utc IS NOT NULL)
)
    THROW 50813, 'Document deleted state is inconsistent.', 1;

PRINT 'Document domain validation passed.';
GO
