SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF NOT EXISTS (SELECT 1 FROM ref.Language WHERE language_code = 'nl')
    THROW 51601, 'Missing seed: Language nl', 1;

IF NOT EXISTS (SELECT 1 FROM policy.ContractStatus WHERE contract_status_code = N'ACTIVE')
    THROW 51602, 'Missing seed: ContractStatus ACTIVE', 1;

IF NOT EXISTS (SELECT 1 FROM policy.ContractVersionStatus WHERE contract_version_status_code = N'ACTIVE')
    THROW 51603, 'Missing seed: ContractVersionStatus ACTIVE', 1;

IF NOT EXISTS (SELECT 1 FROM claim.ClaimStatus WHERE claim_status_code = N'OPEN')
    THROW 51604, 'Missing seed: ClaimStatus OPEN', 1;

IF NOT EXISTS (SELECT 1 FROM tasking.TaskStatus WHERE task_status_code = N'OPEN')
    THROW 51605, 'Missing seed: TaskStatus OPEN', 1;

IF NOT EXISTS (SELECT 1 FROM tasking.TaskPriority WHERE task_priority_code = N'NORMAL')
    THROW 51606, 'Missing seed: TaskPriority NORMAL', 1;

IF NOT EXISTS (SELECT 1 FROM document.DocumentType WHERE document_type_code = N'ID_CARD')
    THROW 51607, 'Missing seed: DocumentType ID_CARD', 1;

IF NOT EXISTS (SELECT 1 FROM core.Permission WHERE permission_code = N'admin.user.manage')
    THROW 51608, 'Missing seed: Permission admin.user.manage', 1;

IF NOT EXISTS (SELECT 1 FROM core.Role WHERE tenant_id IS NULL AND role_code = N'SYSTEM_ADMIN')
    THROW 51609, 'Missing seed: Role SYSTEM_ADMIN', 1;

IF NOT EXISTS (SELECT 1 FROM risk.InsurableObjectType WHERE object_type_code = N'VEHICLE')
    THROW 51610, 'Missing seed: InsurableObjectType VEHICLE', 1;

IF EXISTS (
    SELECT required.contract_domain_code
    FROM (VALUES
        (N'AUTO'), (N'FIRE'), (N'FAMILY'), (N'LIABILITY'), (N'LEGAL_PROTECTION'),
        (N'HEALTH'), (N'LIFE'), (N'LOAN'), (N'BUSINESS'), (N'TRAVEL')
    ) AS required (contract_domain_code)
    WHERE NOT EXISTS (
        SELECT 1
        FROM policy.ContractDomain cd
        WHERE cd.contract_domain_code = required.contract_domain_code
          AND cd.is_active = 1
    )
)
    THROW 51611, 'Missing required coverage contract domain seed.', 1;

IF EXISTS (
    SELECT required.coverage_code
    FROM (VALUES
        (N'BA_AUTO'), (N'OMNIUM'), (N'MINI_OMNIUM'), (N'DRIVER_PROTECTION'),
        (N'LEGAL_PROTECTION_AUTO'), (N'FIRE_BUILDING'), (N'FIRE_CONTENTS'),
        (N'THEFT'), (N'GLASS_BREAKAGE'), (N'WATER_DAMAGE'), (N'FAMILY_LIABILITY'),
        (N'LEGAL_PROTECTION_PRIVATE'), (N'HOSPITALIZATION'), (N'LIFE_COVER'),
        (N'OUTSTANDING_BALANCE'), (N'BUSINESS_LIABILITY'), (N'TRAVEL_ASSISTANCE')
    ) AS required (coverage_code)
    WHERE NOT EXISTS (
        SELECT 1
        FROM coverage.Coverage c
        WHERE c.coverage_code = required.coverage_code
          AND c.is_active = 1
    )
)
    THROW 51612, 'Missing required coverage seed.', 1;

IF EXISTS (
    SELECT required.package_code
    FROM (VALUES
        (N'AUTO_BASIC'), (N'AUTO_FULL'), (N'HOME_BASIC'), (N'HOME_FULL'),
        (N'FAMILY_BASIC'), (N'BUSINESS_BASIC')
    ) AS required (package_code)
    WHERE NOT EXISTS (
        SELECT 1
        FROM coverage.CoveragePackage cp
        WHERE cp.package_code = required.package_code
          AND cp.is_active = 1
    )
)
    THROW 51613, 'Missing required coverage package seed.', 1;

IF EXISTS (
    SELECT 1
    FROM coverage.CoveragePackage cp
    WHERE cp.is_active = 1
      AND NOT EXISTS (
            SELECT 1
            FROM coverage.CoveragePackageItem cpi
            WHERE cpi.coverage_package_id = cp.coverage_package_id
      )
)
    THROW 51614, 'Coverage package seed has no items.', 1;

IF EXISTS (
    SELECT required.lookup_name
    FROM (VALUES
        (N'risk.VehicleType', 3),
        (N'risk.UsageType', 2),
        (N'risk.LicensePlateType', 2),
        (N'risk.FuelType', 3),
        (N'risk.DriveType', 3),
        (N'risk.RealEstateType', 3),
        (N'risk.UseTypeRealEstate', 2),
        (N'risk.InsuredRole', 2),
        (N'risk.ResidenceType', 3),
        (N'risk.DestinationType', 4),
        (N'risk.AdjacencyType', 4),
        (N'risk.OccupancyLevel', 4),
        (N'risk.ConstructionType', 4),
        (N'risk.RoofType', 4),
        (N'risk.BurglaryProtectionType', 4),
        (N'risk.InsurablePersonSubtype', 8),
        (N'risk.WorkerRiskClass', 3),
        (N'risk.EmployeeRiskClass', 3),
        (N'risk.AgeCategory', 3),
        (N'risk.InsurableThingSubtype', 4),
        (N'risk.ThingRiskCategory', 3),
        (N'risk.ThingMaterialType', 4),
        (N'risk.InsurableActivitySubtype', 4),
        (N'risk.ActivityRiskLevel', 3)
    ) AS required (lookup_name, minimum_count)
    CROSS APPLY (
        SELECT current_count =
            CASE required.lookup_name
                WHEN N'risk.VehicleType' THEN (SELECT COUNT(1) FROM risk.VehicleType WHERE is_active = 1)
                WHEN N'risk.UsageType' THEN (SELECT COUNT(1) FROM risk.UsageType WHERE is_active = 1)
                WHEN N'risk.LicensePlateType' THEN (SELECT COUNT(1) FROM risk.LicensePlateType WHERE is_active = 1)
                WHEN N'risk.FuelType' THEN (SELECT COUNT(1) FROM risk.FuelType WHERE is_active = 1)
                WHEN N'risk.DriveType' THEN (SELECT COUNT(1) FROM risk.DriveType WHERE is_active = 1)
                WHEN N'risk.RealEstateType' THEN (SELECT COUNT(1) FROM risk.RealEstateType WHERE is_active = 1)
                WHEN N'risk.UseTypeRealEstate' THEN (SELECT COUNT(1) FROM risk.UseTypeRealEstate WHERE is_active = 1)
                WHEN N'risk.InsuredRole' THEN (SELECT COUNT(1) FROM risk.InsuredRole WHERE is_active = 1)
                WHEN N'risk.ResidenceType' THEN (SELECT COUNT(1) FROM risk.ResidenceType WHERE is_active = 1)
                WHEN N'risk.DestinationType' THEN (SELECT COUNT(1) FROM risk.DestinationType WHERE is_active = 1)
                WHEN N'risk.AdjacencyType' THEN (SELECT COUNT(1) FROM risk.AdjacencyType WHERE is_active = 1)
                WHEN N'risk.OccupancyLevel' THEN (SELECT COUNT(1) FROM risk.OccupancyLevel WHERE is_active = 1)
                WHEN N'risk.ConstructionType' THEN (SELECT COUNT(1) FROM risk.ConstructionType WHERE is_active = 1)
                WHEN N'risk.RoofType' THEN (SELECT COUNT(1) FROM risk.RoofType WHERE is_active = 1)
                WHEN N'risk.BurglaryProtectionType' THEN (SELECT COUNT(1) FROM risk.BurglaryProtectionType WHERE is_active = 1)
                WHEN N'risk.InsurablePersonSubtype' THEN (SELECT COUNT(1) FROM risk.InsurablePersonSubtype WHERE is_active = 1)
                WHEN N'risk.WorkerRiskClass' THEN (SELECT COUNT(1) FROM risk.WorkerRiskClass WHERE is_active = 1)
                WHEN N'risk.EmployeeRiskClass' THEN (SELECT COUNT(1) FROM risk.EmployeeRiskClass WHERE is_active = 1)
                WHEN N'risk.AgeCategory' THEN (SELECT COUNT(1) FROM risk.AgeCategory WHERE is_active = 1)
                WHEN N'risk.InsurableThingSubtype' THEN (SELECT COUNT(1) FROM risk.InsurableThingSubtype WHERE is_active = 1)
                WHEN N'risk.ThingRiskCategory' THEN (SELECT COUNT(1) FROM risk.ThingRiskCategory WHERE is_active = 1)
                WHEN N'risk.ThingMaterialType' THEN (SELECT COUNT(1) FROM risk.ThingMaterialType WHERE is_active = 1)
                WHEN N'risk.InsurableActivitySubtype' THEN (SELECT COUNT(1) FROM risk.InsurableActivitySubtype WHERE is_active = 1)
                WHEN N'risk.ActivityRiskLevel' THEN (SELECT COUNT(1) FROM risk.ActivityRiskLevel WHERE is_active = 1)
                ELSE 0
            END
    ) AS actual
    WHERE actual.current_count < required.minimum_count
)
    THROW 51615, 'Risk lookup seed is below required minimum row count.', 1;

PRINT 'Seed validation passed.';
GO
