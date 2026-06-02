SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [YafesPars];
GO

PRINT 'Running migration: 005__create_object_domain.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'risk.InsurableObjectType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsurableObjectType (
            object_type_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(120) NOT NULL,
            label_fr NVARCHAR(120) NULL,
            label_en NVARCHAR(120) NULL,
            label_tr NVARCHAR(120) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_InsurableObjectType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_InsurableObjectType PRIMARY KEY (object_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.VehicleType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.VehicleType (
            vehicle_type_code NVARCHAR(60) NOT NULL,
            label_nl NVARCHAR(160) NOT NULL,
            label_fr NVARCHAR(160) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_VehicleType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_VehicleType PRIMARY KEY (vehicle_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.UsageType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.UsageType (
            usage_type_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(160) NOT NULL,
            label_fr NVARCHAR(160) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_UsageType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_UsageType PRIMARY KEY (usage_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.FuelType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.FuelType (
            fuel_type_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(160) NOT NULL,
            label_fr NVARCHAR(160) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_FuelType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_FuelType PRIMARY KEY (fuel_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.DriveType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.DriveType (
            drive_type_code NVARCHAR(20) NOT NULL,
            label_nl NVARCHAR(160) NOT NULL,
            label_fr NVARCHAR(160) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_DriveType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_DriveType PRIMARY KEY (drive_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.LicensePlateType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.LicensePlateType (
            plate_type_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(160) NOT NULL,
            label_fr NVARCHAR(160) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_LicensePlateType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_LicensePlateType PRIMARY KEY (plate_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.RealEstateType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.RealEstateType (
            realestate_type_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_RealEstateType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_RealEstateType PRIMARY KEY (realestate_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.InsuredRole', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsuredRole (
            insured_role_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_InsuredRole_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_InsuredRole PRIMARY KEY (insured_role_code)
        );
    END;

    IF OBJECT_ID(N'risk.UseTypeRealEstate', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.UseTypeRealEstate (
            use_type_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_UseTypeRealEstate_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_UseTypeRealEstate PRIMARY KEY (use_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.ResidenceType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.ResidenceType (
            residence_type_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_ResidenceType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_ResidenceType PRIMARY KEY (residence_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.DestinationType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.DestinationType (
            destination_type_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_DestinationType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_DestinationType PRIMARY KEY (destination_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.AdjacencyType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.AdjacencyType (
            adjacency_type_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_AdjacencyType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_AdjacencyType PRIMARY KEY (adjacency_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.OccupancyLevel', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.OccupancyLevel (
            occupancy_level_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(240) NOT NULL,
            label_fr NVARCHAR(240) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_OccupancyLevel_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_OccupancyLevel PRIMARY KEY (occupancy_level_code)
        );
    END;

    IF OBJECT_ID(N'risk.ConstructionType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.ConstructionType (
            construction_type_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_ConstructionType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_ConstructionType PRIMARY KEY (construction_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.RoofType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.RoofType (
            roof_type_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_RoofType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_RoofType PRIMARY KEY (roof_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.BurglaryProtectionType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.BurglaryProtectionType (
            burglary_protection_type_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(240) NOT NULL,
            label_fr NVARCHAR(240) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_BurglaryProtectionType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_BurglaryProtectionType PRIMARY KEY (burglary_protection_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.InsurablePersonSubtype', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsurablePersonSubtype (
            subtype_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_InsurablePersonSubtype_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_InsurablePersonSubtype PRIMARY KEY (subtype_code)
        );
    END;

    IF OBJECT_ID(N'risk.WorkerRiskClass', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.WorkerRiskClass (
            worker_risk_class_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_WorkerRiskClass_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_WorkerRiskClass PRIMARY KEY (worker_risk_class_code)
        );
    END;

    IF OBJECT_ID(N'risk.EmployeeRiskClass', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.EmployeeRiskClass (
            employee_risk_class_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_EmployeeRiskClass_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_EmployeeRiskClass PRIMARY KEY (employee_risk_class_code)
        );
    END;

    IF OBJECT_ID(N'risk.AgeCategory', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.AgeCategory (
            age_category_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(120) NOT NULL,
            label_fr NVARCHAR(120) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_AgeCategory_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_AgeCategory PRIMARY KEY (age_category_code)
        );
    END;

    IF OBJECT_ID(N'risk.InsurableThingSubtype', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsurableThingSubtype (
            subtype_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_InsurableThingSubtype_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_InsurableThingSubtype PRIMARY KEY (subtype_code)
        );
    END;

    IF OBJECT_ID(N'risk.ThingRiskCategory', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.ThingRiskCategory (
            risk_category_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(120) NOT NULL,
            label_fr NVARCHAR(120) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_ThingRiskCategory_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_ThingRiskCategory PRIMARY KEY (risk_category_code)
        );
    END;

    IF OBJECT_ID(N'risk.ThingMaterialType', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.ThingMaterialType (
            material_type_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(120) NOT NULL,
            label_fr NVARCHAR(120) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_ThingMaterialType_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_ThingMaterialType PRIMARY KEY (material_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.InsurableActivitySubtype', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsurableActivitySubtype (
            activity_type_code NVARCHAR(80) NOT NULL,
            label_nl NVARCHAR(200) NOT NULL,
            label_fr NVARCHAR(200) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_InsurableActivitySubtype_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_InsurableActivitySubtype PRIMARY KEY (activity_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.ActivityRiskLevel', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.ActivityRiskLevel (
            risk_level_code NVARCHAR(40) NOT NULL,
            label_nl NVARCHAR(120) NOT NULL,
            label_fr NVARCHAR(120) NULL,
            is_active BIT NOT NULL CONSTRAINT DF_ActivityRiskLevel_is_active DEFAULT 1,
            sort_order INT NULL,
            CONSTRAINT PK_ActivityRiskLevel PRIMARY KEY (risk_level_code)
        );
    END;

    IF OBJECT_ID(N'risk.InsurableObject', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsurableObject (
            insurable_object_id UNIQUEIDENTIFIER NOT NULL
                CONSTRAINT DF_InsurableObject_insurable_object_id DEFAULT NEWSEQUENTIALID(),
            tenant_id UNIQUEIDENTIFIER NOT NULL,
            object_type_code NVARCHAR(40) NOT NULL,
            description NVARCHAR(255) NOT NULL,
            status_code NVARCHAR(30) NOT NULL,
            start_date DATE NOT NULL,
            end_date DATE NULL,
            created_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_InsurableObject_created_at_utc DEFAULT SYSUTCDATETIME(),
            updated_at_utc DATETIME2(0) NOT NULL
                CONSTRAINT DF_InsurableObject_updated_at_utc DEFAULT SYSUTCDATETIME(),
            created_by_user_id UNIQUEIDENTIFIER NULL,
            updated_by_user_id UNIQUEIDENTIFIER NULL,
            is_deleted BIT NOT NULL
                CONSTRAINT DF_InsurableObject_is_deleted DEFAULT 0,
            CONSTRAINT PK_InsurableObject PRIMARY KEY (insurable_object_id),
            CONSTRAINT CK_InsurableObject_dates
                CHECK (end_date IS NULL OR end_date >= start_date),
            CONSTRAINT FK_InsurableObject_Tenant FOREIGN KEY (tenant_id)
                REFERENCES core.Tenant (tenant_id),
            CONSTRAINT FK_InsurableObject_InsurableObjectType FOREIGN KEY (object_type_code)
                REFERENCES risk.InsurableObjectType (object_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.InsurableVehicle', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsurableVehicle (
            insurable_object_id UNIQUEIDENTIFIER NOT NULL,
            vehicle_type_code NVARCHAR(60) NOT NULL,
            usage_type_code NVARCHAR(40) NOT NULL,
            plate_type_code NVARCHAR(40) NOT NULL,
            brand NVARCHAR(100) NOT NULL,
            model NVARCHAR(100) NOT NULL,
            chassis_number NVARCHAR(40) NOT NULL,
            build_year INT NOT NULL,
            first_commissioning_date DATE NOT NULL,
            registration_date DATE NOT NULL,
            license_plate NVARCHAR(20) NOT NULL,
            fuel_type_code NVARCHAR(40) NULL,
            drive_type_code NVARCHAR(20) NULL,
            finance_institution_id UNIQUEIDENTIFIER NULL,
            is_financed BIT NOT NULL CONSTRAINT DF_InsurableVehicle_is_financed DEFAULT 0,
            insured_value_ex_vat DECIMAL(18,2) NULL,
            insured_value_inc_vat DECIMAL(18,2) NULL,
            catalog_value_ex_vat DECIMAL(18,2) NULL,
            catalog_value_inc_vat DECIMAL(18,2) NULL,
            vat_exemption_pct DECIMAL(5,2) NULL,
            accessories_value DECIMAL(18,2) NULL,
            pvg_number NVARCHAR(40) NULL,
            eu_pvg_number NVARCHAR(40) NULL,
            adr_code NVARCHAR(40) NULL,
            engine_cc INT NULL,
            power_kw INT NULL,
            power_hp INT NULL,
            plate_cancellation_date DATE NULL,
            CONSTRAINT PK_InsurableVehicle PRIMARY KEY (insurable_object_id),
            CONSTRAINT CK_InsurableVehicle_financing CHECK (
                (is_financed = 0 AND finance_institution_id IS NULL)
                OR (is_financed = 1 AND finance_institution_id IS NOT NULL)
            ),
            CONSTRAINT CK_InsurableVehicle_build_year CHECK (build_year >= 1886),
            CONSTRAINT FK_InsurableVehicle_InsurableObject FOREIGN KEY (insurable_object_id)
                REFERENCES risk.InsurableObject (insurable_object_id),
            CONSTRAINT FK_InsurableVehicle_VehicleType FOREIGN KEY (vehicle_type_code)
                REFERENCES risk.VehicleType (vehicle_type_code),
            CONSTRAINT FK_InsurableVehicle_UsageType FOREIGN KEY (usage_type_code)
                REFERENCES risk.UsageType (usage_type_code),
            CONSTRAINT FK_InsurableVehicle_LicensePlateType FOREIGN KEY (plate_type_code)
                REFERENCES risk.LicensePlateType (plate_type_code),
            CONSTRAINT FK_InsurableVehicle_FuelType FOREIGN KEY (fuel_type_code)
                REFERENCES risk.FuelType (fuel_type_code),
            CONSTRAINT FK_InsurableVehicle_DriveType FOREIGN KEY (drive_type_code)
                REFERENCES risk.DriveType (drive_type_code),
            CONSTRAINT FK_InsurableVehicle_Institution_Finance FOREIGN KEY (finance_institution_id)
                REFERENCES institution.Institution (institution_id)
        );
    END;

    IF OBJECT_ID(N'risk.InsurableRealEstate', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsurableRealEstate (
            insurable_object_id UNIQUEIDENTIFIER NOT NULL,
            realestate_type_code NVARCHAR(80) NOT NULL,
            description NVARCHAR(255) NULL,
            use_type_code NVARCHAR(80) NOT NULL,
            insured_role_code NVARCHAR(80) NOT NULL,
            is_risk_address_policyholder BIT NOT NULL
                CONSTRAINT DF_InsurableRealEstate_is_risk_address_policyholder DEFAULT 0,
            residence_type_code NVARCHAR(80) NULL,
            destination_type_code NVARCHAR(80) NULL,
            street NVARCHAR(200) NOT NULL,
            number NVARCHAR(30) NOT NULL,
            box NVARCHAR(30) NULL,
            postal_code NVARCHAR(20) NOT NULL,
            city NVARCHAR(120) NOT NULL,
            country_code CHAR(2) NOT NULL
                CONSTRAINT DF_InsurableRealEstate_country_code DEFAULT 'BE',
            adjacency_type_code NVARCHAR(80) NULL,
            occupancy_level_code NVARCHAR(80) NULL,
            construction_type_code NVARCHAR(80) NULL,
            roof_type_code NVARCHAR(80) NULL,
            build_year INT NULL,
            is_under_construction BIT NOT NULL
                CONSTRAINT DF_InsurableRealEstate_is_under_construction DEFAULT 0,
            provisional_delivery_date DATE NULL,
            floors_count INT NULL,
            apartment_count INT NULL,
            has_solar_panels BIT NOT NULL
                CONSTRAINT DF_InsurableRealEstate_has_solar_panels DEFAULT 0,
            has_flammable_materials BIT NOT NULL
                CONSTRAINT DF_InsurableRealEstate_has_flammable_materials DEFAULT 0,
            flammable_materials_pct DECIMAL(5,2) NULL,
            abex_index_building INT NULL,
            capital_building DECIMAL(18,2) NULL,
            abex_index_roof INT NULL,
            capital_roof DECIMAL(18,2) NULL,
            CONSTRAINT PK_InsurableRealEstate PRIMARY KEY (insurable_object_id),
            CONSTRAINT CK_InsurableRealEstate_flammable_pct
                CHECK (flammable_materials_pct IS NULL OR flammable_materials_pct BETWEEN 0 AND 100),
            CONSTRAINT CK_InsurableRealEstate_build_year
                CHECK (build_year IS NULL OR build_year >= 1000),
            CONSTRAINT FK_InsurableRealEstate_InsurableObject FOREIGN KEY (insurable_object_id)
                REFERENCES risk.InsurableObject (insurable_object_id),
            CONSTRAINT FK_InsurableRealEstate_RealEstateType FOREIGN KEY (realestate_type_code)
                REFERENCES risk.RealEstateType (realestate_type_code),
            CONSTRAINT FK_InsurableRealEstate_UseTypeRealEstate FOREIGN KEY (use_type_code)
                REFERENCES risk.UseTypeRealEstate (use_type_code),
            CONSTRAINT FK_InsurableRealEstate_InsuredRole FOREIGN KEY (insured_role_code)
                REFERENCES risk.InsuredRole (insured_role_code),
            CONSTRAINT FK_InsurableRealEstate_ResidenceType FOREIGN KEY (residence_type_code)
                REFERENCES risk.ResidenceType (residence_type_code),
            CONSTRAINT FK_InsurableRealEstate_DestinationType FOREIGN KEY (destination_type_code)
                REFERENCES risk.DestinationType (destination_type_code),
            CONSTRAINT FK_InsurableRealEstate_AdjacencyType FOREIGN KEY (adjacency_type_code)
                REFERENCES risk.AdjacencyType (adjacency_type_code),
            CONSTRAINT FK_InsurableRealEstate_OccupancyLevel FOREIGN KEY (occupancy_level_code)
                REFERENCES risk.OccupancyLevel (occupancy_level_code),
            CONSTRAINT FK_InsurableRealEstate_ConstructionType FOREIGN KEY (construction_type_code)
                REFERENCES risk.ConstructionType (construction_type_code),
            CONSTRAINT FK_InsurableRealEstate_RoofType FOREIGN KEY (roof_type_code)
                REFERENCES risk.RoofType (roof_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.InsurableRealEstateBurglaryProtection', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsurableRealEstateBurglaryProtection (
            insurable_object_id UNIQUEIDENTIFIER NOT NULL,
            burglary_protection_type_code NVARCHAR(80) NOT NULL,
            CONSTRAINT PK_InsurableRealEstateBurglaryProtection
                PRIMARY KEY (insurable_object_id, burglary_protection_type_code),
            CONSTRAINT FK_InsurableRealEstateBurglaryProtection_InsurableRealEstate
                FOREIGN KEY (insurable_object_id)
                REFERENCES risk.InsurableRealEstate (insurable_object_id),
            CONSTRAINT FK_InsurableRealEstateBurglaryProtection_BurglaryProtectionType
                FOREIGN KEY (burglary_protection_type_code)
                REFERENCES risk.BurglaryProtectionType (burglary_protection_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.InsurableLoan', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsurableLoan (
            insurable_object_id UNIQUEIDENTIFIER NOT NULL,
            principal_amount DECIMAL(18,2) NOT NULL,
            interest_rate_pct DECIMAL(5,2) NOT NULL,
            interest_periodicity_code NVARCHAR(40) NOT NULL,
            duration_type_code NVARCHAR(20) NOT NULL,
            start_date DATE NOT NULL,
            end_date DATE NULL,
            remark NVARCHAR(255) NULL,
            CONSTRAINT PK_InsurableLoan PRIMARY KEY (insurable_object_id),
            CONSTRAINT CK_InsurableLoan_dates CHECK (end_date IS NULL OR end_date >= start_date),
            CONSTRAINT CK_InsurableLoan_principal CHECK (principal_amount > 0),
            CONSTRAINT CK_InsurableLoan_interest CHECK (interest_rate_pct >= 0),
            CONSTRAINT FK_InsurableLoan_InsurableObject FOREIGN KEY (insurable_object_id)
                REFERENCES risk.InsurableObject (insurable_object_id)
        );
    END;

    IF OBJECT_ID(N'risk.InsurablePerson', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsurablePerson (
            insurable_object_id UNIQUEIDENTIFIER NOT NULL,
            subtype_code NVARCHAR(80) NOT NULL,
            description NVARCHAR(255) NULL,
            is_policyholder BIT NOT NULL CONSTRAINT DF_InsurablePerson_is_policyholder DEFAULT 0,
            worker_risk_class_code NVARCHAR(80) NULL,
            employee_risk_class_code NVARCHAR(80) NULL,
            person_count INT NULL,
            nacebel_code NVARCHAR(10) NULL,
            person_id UNIQUEIDENTIFIER NULL,
            person_relation_id UNIQUEIDENTIFIER NULL,
            age_category_code NVARCHAR(40) NULL,
            CONSTRAINT PK_InsurablePerson PRIMARY KEY (insurable_object_id),
            CONSTRAINT CK_InsurablePerson_individual_or_group CHECK (
                (subtype_code NOT IN (N'PERS_IND', N'PERS_ACT')
                    OR (person_id IS NOT NULL AND person_relation_id IS NULL AND ISNULL(person_count, 1) = 1))
                AND
                (subtype_code NOT IN (N'GROEP_COL', N'GROEP_ARB', N'GROEP_BED', N'GROEP_POB', N'GROEP_GEZIN', N'GEZIN_PRIV')
                    OR (person_id IS NULL AND person_relation_id IS NOT NULL AND ISNULL(person_count, 0) >= 2))
            ),
            CONSTRAINT FK_InsurablePerson_InsurableObject FOREIGN KEY (insurable_object_id)
                REFERENCES risk.InsurableObject (insurable_object_id),
            CONSTRAINT FK_InsurablePerson_InsurablePersonSubtype FOREIGN KEY (subtype_code)
                REFERENCES risk.InsurablePersonSubtype (subtype_code),
            CONSTRAINT FK_InsurablePerson_WorkerRiskClass FOREIGN KEY (worker_risk_class_code)
                REFERENCES risk.WorkerRiskClass (worker_risk_class_code),
            CONSTRAINT FK_InsurablePerson_EmployeeRiskClass FOREIGN KEY (employee_risk_class_code)
                REFERENCES risk.EmployeeRiskClass (employee_risk_class_code),
            CONSTRAINT FK_InsurablePerson_Person FOREIGN KEY (person_id)
                REFERENCES person.Person (person_id),
            CONSTRAINT FK_InsurablePerson_PersonRelation FOREIGN KEY (person_relation_id)
                REFERENCES person.PersonRelation (person_relation_id),
            CONSTRAINT FK_InsurablePerson_AgeCategory FOREIGN KEY (age_category_code)
                REFERENCES risk.AgeCategory (age_category_code)
        );
    END;

    IF OBJECT_ID(N'risk.InsurableThing', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsurableThing (
            insurable_object_id UNIQUEIDENTIFIER NOT NULL,
            subtype_code NVARCHAR(80) NOT NULL,
            description NVARCHAR(255) NULL,
            brand NVARCHAR(120) NULL,
            model NVARCHAR(120) NULL,
            serial_number NVARCHAR(120) NULL,
            value_insured DECIMAL(18,2) NULL,
            value_new DECIMAL(18,2) NULL,
            value_current DECIMAL(18,2) NULL,
            risk_category_code NVARCHAR(40) NULL,
            material_type_code NVARCHAR(40) NULL,
            flammable_pct DECIMAL(5,2) NULL,
            location_street NVARCHAR(200) NULL,
            location_number NVARCHAR(30) NULL,
            location_box NVARCHAR(30) NULL,
            location_postal_code NVARCHAR(20) NULL,
            location_city NVARCHAR(120) NULL,
            location_country_code CHAR(2) NULL
                CONSTRAINT DF_InsurableThing_location_country_code DEFAULT 'BE',
            CONSTRAINT PK_InsurableThing PRIMARY KEY (insurable_object_id),
            CONSTRAINT CK_InsurableThing_flammable_pct
                CHECK (flammable_pct IS NULL OR flammable_pct BETWEEN 0 AND 100),
            CONSTRAINT FK_InsurableThing_InsurableObject FOREIGN KEY (insurable_object_id)
                REFERENCES risk.InsurableObject (insurable_object_id),
            CONSTRAINT FK_InsurableThing_InsurableThingSubtype FOREIGN KEY (subtype_code)
                REFERENCES risk.InsurableThingSubtype (subtype_code),
            CONSTRAINT FK_InsurableThing_ThingRiskCategory FOREIGN KEY (risk_category_code)
                REFERENCES risk.ThingRiskCategory (risk_category_code),
            CONSTRAINT FK_InsurableThing_ThingMaterialType FOREIGN KEY (material_type_code)
                REFERENCES risk.ThingMaterialType (material_type_code)
        );
    END;

    IF OBJECT_ID(N'risk.InsurableActivity', N'U') IS NULL
    BEGIN
        CREATE TABLE risk.InsurableActivity (
            insurable_object_id UNIQUEIDENTIFIER NOT NULL,
            activity_type_code NVARCHAR(80) NOT NULL,
            description NVARCHAR(255) NULL,
            start_datetime DATETIME2(0) NOT NULL,
            end_datetime DATETIME2(0) NOT NULL,
            participant_count INT NULL,
            age_category_code NVARCHAR(40) NULL,
            risk_level_code NVARCHAR(40) NULL,
            location_street NVARCHAR(200) NULL,
            location_number NVARCHAR(30) NULL,
            location_box NVARCHAR(30) NULL,
            location_postal_code NVARCHAR(20) NULL,
            location_city NVARCHAR(120) NULL,
            location_country_code CHAR(2) NULL
                CONSTRAINT DF_InsurableActivity_location_country_code DEFAULT 'BE',
            CONSTRAINT PK_InsurableActivity PRIMARY KEY (insurable_object_id),
            CONSTRAINT CK_InsurableActivity_dates CHECK (end_datetime >= start_datetime),
            CONSTRAINT CK_InsurableActivity_participants CHECK (participant_count IS NULL OR participant_count >= 0),
            CONSTRAINT FK_InsurableActivity_InsurableObject FOREIGN KEY (insurable_object_id)
                REFERENCES risk.InsurableObject (insurable_object_id),
            CONSTRAINT FK_InsurableActivity_InsurableActivitySubtype FOREIGN KEY (activity_type_code)
                REFERENCES risk.InsurableActivitySubtype (activity_type_code),
            CONSTRAINT FK_InsurableActivity_AgeCategory FOREIGN KEY (age_category_code)
                REFERENCES risk.AgeCategory (age_category_code),
            CONSTRAINT FK_InsurableActivity_ActivityRiskLevel FOREIGN KEY (risk_level_code)
                REFERENCES risk.ActivityRiskLevel (risk_level_code)
        );
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_InsurableObject_tenant_type'
          AND object_id = OBJECT_ID(N'risk.InsurableObject')
    )
        CREATE INDEX IX_InsurableObject_tenant_type
        ON risk.InsurableObject (tenant_id, object_type_code);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_InsurableVehicle_plate'
          AND object_id = OBJECT_ID(N'risk.InsurableVehicle')
    )
        CREATE INDEX IX_InsurableVehicle_plate
        ON risk.InsurableVehicle (license_plate);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_InsurableVehicle_chassis'
          AND object_id = OBJECT_ID(N'risk.InsurableVehicle')
    )
        CREATE INDEX IX_InsurableVehicle_chassis
        ON risk.InsurableVehicle (chassis_number);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_InsurableVehicle_finance_institution'
          AND object_id = OBJECT_ID(N'risk.InsurableVehicle')
    )
        CREATE INDEX IX_InsurableVehicle_finance_institution
        ON risk.InsurableVehicle (finance_institution_id);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_InsurableRealEstate_address'
          AND object_id = OBJECT_ID(N'risk.InsurableRealEstate')
    )
        CREATE INDEX IX_InsurableRealEstate_address
        ON risk.InsurableRealEstate (postal_code, city, street, number);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_InsurablePerson_person_id'
          AND object_id = OBJECT_ID(N'risk.InsurablePerson')
    )
        CREATE INDEX IX_InsurablePerson_person_id
        ON risk.InsurablePerson (person_id);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = N'IX_InsurablePerson_person_relation_id'
          AND object_id = OBJECT_ID(N'risk.InsurablePerson')
    )
        CREATE INDEX IX_InsurablePerson_person_relation_id
        ON risk.InsurablePerson (person_relation_id);

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'005__create_object_domain.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'005__create_object_domain.sql',
            N'SUCCESS'
        );
    END;

    COMMIT TRANSACTION;
    PRINT 'Migration completed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;
GO
