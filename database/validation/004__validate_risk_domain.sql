SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF OBJECT_ID(N'risk.InsurableObject', N'U') IS NULL
    THROW 50401, 'Missing table: risk.InsurableObject', 1;

IF OBJECT_ID(N'risk.InsurableVehicle', N'U') IS NULL
    THROW 50402, 'Missing table: risk.InsurableVehicle', 1;

IF OBJECT_ID(N'risk.InsurableRealEstate', N'U') IS NULL
    THROW 50403, 'Missing table: risk.InsurableRealEstate', 1;

IF OBJECT_ID(N'risk.InsurableLoan', N'U') IS NULL
    THROW 50404, 'Missing table: risk.InsurableLoan', 1;

IF OBJECT_ID(N'risk.InsurablePerson', N'U') IS NULL
    THROW 50405, 'Missing table: risk.InsurablePerson', 1;

IF OBJECT_ID(N'risk.InsurableThing', N'U') IS NULL
    THROW 50406, 'Missing table: risk.InsurableThing', 1;

IF OBJECT_ID(N'risk.InsurableActivity', N'U') IS NULL
    THROW 50407, 'Missing table: risk.InsurableActivity', 1;

IF OBJECT_ID(N'risk.InsurableObjectType', N'U') IS NULL
    THROW 50408, 'Missing table: risk.InsurableObjectType', 1;

IF OBJECT_ID(N'risk.Object', N'U') IS NOT NULL
    THROW 50409, 'Forbidden table exists: risk.Object', 1;

IF OBJECT_ID(N'dbo.Object', N'U') IS NOT NULL
    THROW 50410, 'Forbidden table exists: dbo.Object', 1;

IF COL_LENGTH(N'risk.InsurableObject', N'tenant_id') IS NULL
    THROW 50411, 'Missing column: risk.InsurableObject.tenant_id', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_InsurableObject_Tenant'
      AND parent_object_id = OBJECT_ID(N'risk.InsurableObject')
)
    THROW 50412, 'Missing FK: FK_InsurableObject_Tenant', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_InsurableVehicle_InsurableObject'
      AND parent_object_id = OBJECT_ID(N'risk.InsurableVehicle')
)
    THROW 50413, 'Missing FK: FK_InsurableVehicle_InsurableObject', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_InsurableRealEstate_InsurableObject'
      AND parent_object_id = OBJECT_ID(N'risk.InsurableRealEstate')
)
    THROW 50414, 'Missing FK: FK_InsurableRealEstate_InsurableObject', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_InsurableVehicle_plate'
      AND object_id = OBJECT_ID(N'risk.InsurableVehicle')
)
    THROW 50415, 'Missing index: IX_InsurableVehicle_plate', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_InsurableVehicle_chassis'
      AND object_id = OBJECT_ID(N'risk.InsurableVehicle')
)
    THROW 50416, 'Missing index: IX_InsurableVehicle_chassis', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_InsurableRealEstate_address'
      AND object_id = OBJECT_ID(N'risk.InsurableRealEstate')
)
    THROW 50417, 'Missing index: IX_InsurableRealEstate_address', 1;

PRINT 'Risk domain validation passed.';
GO
