SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF OBJECT_ID(N'institution.Institution', N'U') IS NULL
    THROW 50301, 'Missing table: institution.Institution', 1;

IF OBJECT_ID(N'institution.InstitutionRole', N'U') IS NULL
    THROW 50302, 'Missing table: institution.InstitutionRole', 1;

IF OBJECT_ID(N'institution.InstitutionIdentifier', N'U') IS NULL
    THROW 50303, 'Missing table: institution.InstitutionIdentifier', 1;

IF OBJECT_ID(N'institution.InstitutionIdentifierType', N'U') IS NULL
    THROW 50304, 'Missing table: institution.InstitutionIdentifierType', 1;

IF OBJECT_ID(N'institution.InstitutionAddress', N'U') IS NULL
    THROW 50305, 'Missing table: institution.InstitutionAddress', 1;

IF OBJECT_ID(N'institution.InstitutionAddressRole', N'U') IS NULL
    THROW 50306, 'Missing table: institution.InstitutionAddressRole', 1;

IF COL_LENGTH(N'institution.Institution', N'tenant_id') IS NULL
    THROW 50307, 'Missing column: institution.Institution.tenant_id', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_Institution_Tenant'
      AND parent_object_id = OBJECT_ID(N'institution.Institution')
)
    THROW 50308, 'Missing FK: FK_Institution_Tenant', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_InstitutionIdentifier_Institution'
      AND parent_object_id = OBJECT_ID(N'institution.InstitutionIdentifier')
)
    THROW 50309, 'Missing FK: FK_InstitutionIdentifier_Institution', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_InstitutionAddress_Institution'
      AND parent_object_id = OBJECT_ID(N'institution.InstitutionAddress')
)
    THROW 50310, 'Missing FK: FK_InstitutionAddress_Institution', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE name = N'UQ_Institution_tenant_code'
      AND parent_object_id = OBJECT_ID(N'institution.Institution')
)
    THROW 50311, 'Missing unique constraint: UQ_Institution_tenant_code', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Institution_name'
      AND object_id = OBJECT_ID(N'institution.Institution')
)
    THROW 50312, 'Missing index: IX_Institution_name', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_InstitutionIdentifier_value'
      AND object_id = OBJECT_ID(N'institution.InstitutionIdentifier')
)
    THROW 50313, 'Missing index: IX_InstitutionIdentifier_value', 1;

PRINT 'Institution domain validation passed.';
GO
