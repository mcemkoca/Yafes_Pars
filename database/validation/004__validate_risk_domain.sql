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

IF EXISTS (
    SELECT 1
    FROM risk.InsurableVehicle
    WHERE (is_financed = 1 AND finance_institution_id IS NULL)
       OR (is_financed = 0 AND finance_institution_id IS NOT NULL)
)
    THROW 50418, 'Vehicle financing rule violation.', 1;

IF EXISTS (
    SELECT 1
    FROM risk.InsurableVehicle
    WHERE build_year < 1886
       OR build_year > YEAR(SYSUTCDATETIME()) + 1
)
    THROW 50419, 'Vehicle build year outside sane range.', 1;

IF EXISTS (
    SELECT 1
    FROM risk.InsurableVehicle
    WHERE registration_date < first_commissioning_date
)
    THROW 50420, 'Vehicle registration date cannot be before first commissioning date.', 1;

IF EXISTS (
    SELECT 1
    FROM risk.InsurableRealEstate
    WHERE flammable_materials_pct IS NOT NULL
      AND (flammable_materials_pct < 0 OR flammable_materials_pct > 100)
)
    THROW 50421, 'Real estate flammable percentage outside 0-100.', 1;

IF EXISTS (
    SELECT 1
    FROM risk.InsurableActivity
    WHERE end_datetime < start_datetime
)
    THROW 50422, 'Activity end date cannot be before start date.', 1;

IF EXISTS (
    SELECT 1
    FROM risk.InsurableObject
    WHERE status_code NOT IN (N'ACTIVE', N'INACTIVE', N'ARCHIVED', N'PENDING')
)
    THROW 50423, 'Invalid insurable object status_code.', 1;

IF EXISTS (
    SELECT 1
    FROM (VALUES
        (N'risk.ResidenceType', OBJECT_ID(N'risk.ResidenceType')),
        (N'risk.DestinationType', OBJECT_ID(N'risk.DestinationType')),
        (N'risk.AdjacencyType', OBJECT_ID(N'risk.AdjacencyType')),
        (N'risk.OccupancyLevel', OBJECT_ID(N'risk.OccupancyLevel')),
        (N'risk.ConstructionType', OBJECT_ID(N'risk.ConstructionType')),
        (N'risk.RoofType', OBJECT_ID(N'risk.RoofType')),
        (N'risk.BurglaryProtectionType', OBJECT_ID(N'risk.BurglaryProtectionType')),
        (N'risk.InsurablePersonSubtype', OBJECT_ID(N'risk.InsurablePersonSubtype')),
        (N'risk.WorkerRiskClass', OBJECT_ID(N'risk.WorkerRiskClass')),
        (N'risk.EmployeeRiskClass', OBJECT_ID(N'risk.EmployeeRiskClass')),
        (N'risk.AgeCategory', OBJECT_ID(N'risk.AgeCategory')),
        (N'risk.InsurableThingSubtype', OBJECT_ID(N'risk.InsurableThingSubtype')),
        (N'risk.ThingRiskCategory', OBJECT_ID(N'risk.ThingRiskCategory')),
        (N'risk.ThingMaterialType', OBJECT_ID(N'risk.ThingMaterialType')),
        (N'risk.InsurableActivitySubtype', OBJECT_ID(N'risk.InsurableActivitySubtype')),
        (N'risk.ActivityRiskLevel', OBJECT_ID(N'risk.ActivityRiskLevel'))
    ) AS lookup_tables (lookup_name, object_id)
    WHERE lookup_tables.object_id IS NULL
)
    THROW 50424, 'Missing advanced risk lookup table.', 1;

PRINT 'Risk domain validation passed.';
GO
