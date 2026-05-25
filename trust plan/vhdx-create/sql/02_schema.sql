-- =============================================================
-- AssureManager Database Schema
-- Belgian Insurance Management System
-- =============================================================
-- Creates all tables with proper data types, constraints, defaults
-- Run AFTER 01_create_database.sql
-- =============================================================

SET NOCOUNT ON;
GO

USE AssureManagerDB;
GO

PRINT '======================================================';
PRINT ' Creating AssureManagerDB Schema...';
PRINT '======================================================';
GO

SET NOCOUNT ON;
GO

/* ============================================================== 
   Person Domain: Personen en gerelateerde entiteiten 
   - Bevat de hoofdtabel Person (met subtypes NaturalPerson en LegalPerson)
   - Inclusief contactgegevens (Address, Phone, Email, etc.)
   - Lookups: Language, Title, PhoneType, SocialType, ProfessionalStatus, PersonType
   ============================================================== */
CREATE TABLE Person (
    person_id          UNIQUEIDENTIFIER NOT NULL 
                       CONSTRAINT DF_Person_id DEFAULT (NEWSEQUENTIALID()),
    person_kind        NVARCHAR(10)  NOT NULL,   -- 'NATURAL' of 'LEGAL'
    dossier            NVARCHAR(50)  NULL,
    language_code      CHAR(2)       NULL,       -- FK: references Language(language_code)
    nationality        NVARCHAR(80)  NULL,
    subagent_person_id UNIQUEIDENTIFIER NULL,    -- FK: references Person(person_id)
    manager_person_id  UNIQUEIDENTIFIER NULL,    -- FK: references Person(person_id)
    portfolio_person_id UNIQUEIDENTIFIER NULL,   -- FK: references Person(person_id)
    created_at         DATETIME2(0)  NOT NULL 
                       CONSTRAINT DF_Person_created DEFAULT (SYSUTCDATETIME()),
    updated_at         DATETIME2(0)  NOT NULL 
                       CONSTRAINT DF_Person_updated DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Person PRIMARY KEY (person_id),
    CONSTRAINT CK_Person_Kind CHECK (person_kind IN ('NATURAL','LEGAL'))
);

CREATE TABLE NaturalPerson (
    person_id         UNIQUEIDENTIFIER NOT NULL,  -- PK & FK: Person
    first_name        NVARCHAR(100) NULL,
    last_name         NVARCHAR(100) NULL,
    birth_date        DATE          NULL,
    birth_place       NVARCHAR(120) NULL,
    death_date        DATE          NULL,
    gender            NVARCHAR(20)  NULL,
    marital_status    NVARCHAR(50)  NULL,
    national_number   NVARCHAR(30)  NULL,
    passport_number   NVARCHAR(30)  NULL,
    id_card_number    NVARCHAR(30)  NULL,
    id_card_valid_from DATE        NULL,
    id_card_valid_to   DATE        NULL,
    title_code        NVARCHAR(10)  NULL,        -- FK: references Title(title_code)
    CONSTRAINT PK_NaturalPerson PRIMARY KEY (person_id),
    CONSTRAINT CK_NaturalPerson_Lifespan CHECK (
        death_date IS NULL OR birth_date IS NULL OR death_date >= birth_date
    )
    /* FK to Person defined in 02_constraints.sql */
);

CREATE TABLE LegalPerson (
    person_id          UNIQUEIDENTIFIER NOT NULL, -- PK & FK: Person
    incorporation_date DATE          NULL,
    closing_date       DATE          NULL,
    legal_form         NVARCHAR(120) NULL,
    CONSTRAINT PK_LegalPerson PRIMARY KEY (person_id),
    CONSTRAINT CK_LegalPerson_Dates CHECK (
        closing_date IS NULL OR incorporation_date IS NULL OR closing_date >= incorporation_date
    )
    /* FK to Person defined in 02_constraints.sql */
);

CREATE TABLE EconomicActivity (
    economic_activity_id UNIQUEIDENTIFIER NOT NULL 
                         CONSTRAINT DF_EconomicActivity_id DEFAULT (NEWID()),
    person_id            UNIQUEIDENTIFIER NOT NULL, -- FK: references Person(person_id)
    profession           NVARCHAR(150) NULL,
    professional_status_code NVARCHAR(30) NULL,     -- FK: references ProfessionalStatus(professional_status_code)
    kbo_number           NVARCHAR(30)  NULL,
    vat_number           NVARCHAR(30)  NULL,
    paritair_comite_code NVARCHAR(10)  NULL,
    CONSTRAINT PK_EconomicActivity PRIMARY KEY (economic_activity_id)
);

CREATE TABLE EconomicActivity_Nacebel (
    economic_activity_id UNIQUEIDENTIFIER NOT NULL, -- FK: references EconomicActivity(economic_activity_id)
    nacebel_code         NVARCHAR(10) NOT NULL,
    CONSTRAINT PK_EconomicActivity_Nacebel PRIMARY KEY (economic_activity_id, nacebel_code)
    /* Both FKs defined in 02_constraints.sql */
);

CREATE TABLE Person_PersonType (
    person_id        UNIQUEIDENTIFIER NOT NULL,  -- FK: references Person(person_id)
    person_type_code NVARCHAR(60)     NOT NULL,  -- FK: references PersonType(person_type_code)
    CONSTRAINT PK_Person_PersonType PRIMARY KEY (person_id, person_type_code)
    /* Both FKs defined in 02_constraints.sql */
);

CREATE TABLE PersonAddressRole (
    address_role_code NVARCHAR(20)  NOT NULL,
    label_nl          NVARCHAR(120) NOT NULL,
    label_fr          NVARCHAR(120) NULL,
    is_active         BIT           NOT NULL 
                      CONSTRAINT DF_PersonAddressRole_is_active DEFAULT (1),
    CONSTRAINT PK_PersonAddressRole PRIMARY KEY (address_role_code)
);

CREATE TABLE Address (
    address_id        UNIQUEIDENTIFIER NOT NULL 
                     CONSTRAINT DF_Address_id DEFAULT (NEWID()),
    person_id         UNIQUEIDENTIFIER NOT NULL,  -- FK: references Person(person_id)
    address_role_code NVARCHAR(20)  NOT NULL,      -- FK: references PersonAddressRole(address_role_code)
    street            NVARCHAR(200) NOT NULL,
    house_number      NVARCHAR(30)  NULL,
    box               NVARCHAR(30)  NULL,
    postal_code       NVARCHAR(20)  NOT NULL,
    city              NVARCHAR(120) NOT NULL,
    country           NVARCHAR(80)  NOT NULL,
    country_code      CHAR(2)       NOT NULL 
                     CONSTRAINT DF_Address_country_code DEFAULT ('BE'),
    remark            NVARCHAR(400) NULL,
    is_primary        BIT           NOT NULL 
                     CONSTRAINT DF_Address_is_primary DEFAULT (0),
    created_at        DATETIME2(0)  NOT NULL 
                     CONSTRAINT DF_Address_created DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Address PRIMARY KEY (address_id)
);

CREATE TABLE Phone (
    phone_id         UNIQUEIDENTIFIER NOT NULL 
                    CONSTRAINT DF_Phone_id DEFAULT (NEWID()),
    person_id        UNIQUEIDENTIFIER NOT NULL,  -- FK: references Person(person_id)
    phone_number     NVARCHAR(50)  NOT NULL,
    phone_type_code  NVARCHAR(20)  NOT NULL,     -- FK: references PhoneType(phone_type_code)
    is_primary       BIT           NOT NULL 
                    CONSTRAINT DF_Phone_is_primary DEFAULT (0),
    comment          NVARCHAR(200) NULL,
    created_at       DATETIME2(0)  NOT NULL 
                    CONSTRAINT DF_Phone_created DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Phone PRIMARY KEY (phone_id)
);

CREATE TABLE Email (
    email_id   UNIQUEIDENTIFIER NOT NULL 
               CONSTRAINT DF_Email_id DEFAULT (NEWID()),
    person_id  UNIQUEIDENTIFIER NOT NULL,  -- FK: references Person(person_id)
    email      NVARCHAR(320) NOT NULL,
    comment    NVARCHAR(200) NULL,
    CONSTRAINT PK_Email PRIMARY KEY (email_id)
);

CREATE TABLE SocialMedia (
    social_id         UNIQUEIDENTIFIER NOT NULL 
                      CONSTRAINT DF_SocialMedia_id DEFAULT (NEWID()),
    person_id         UNIQUEIDENTIFIER NOT NULL,  -- FK: references Person(person_id)
    social_type_code  NVARCHAR(20)  NOT NULL,     -- FK: references SocialType(social_type_code)
    url               NVARCHAR(400) NOT NULL,
    description       NVARCHAR(200) NULL,
    CONSTRAINT PK_SocialMedia PRIMARY KEY (social_id)
);

CREATE TABLE BankAccount (
    bank_account_id UNIQUEIDENTIFIER NOT NULL 
                    CONSTRAINT DF_BankAccount_id DEFAULT (NEWID()),
    person_id       UNIQUEIDENTIFIER NOT NULL,  -- FK: references Person(person_id)
    iban            NVARCHAR(34)  NOT NULL,
    bic             NVARCHAR(11)  NULL,
    bank            NVARCHAR(120) NOT NULL,
    remark          NVARCHAR(200) NULL,
    CONSTRAINT PK_BankAccount PRIMARY KEY (bank_account_id)
);

CREATE TABLE DriverLicense (
    driver_license_id UNIQUEIDENTIFIER NOT NULL 
                      CONSTRAINT DF_DriverLicense_id DEFAULT (NEWID()),
    person_id         UNIQUEIDENTIFIER NOT NULL,  -- FK: references Person(person_id)
    license_number    NVARCHAR(50)  NOT NULL,
    license_type      NVARCHAR(30)  NOT NULL,
    start_date        DATE          NOT NULL,
    CONSTRAINT PK_DriverLicense PRIMARY KEY (driver_license_id)
);

-- Lookups for Person domain:
CREATE TABLE Language (
    language_code    CHAR(2)      NOT NULL,
    language_label_nl NVARCHAR(80) NOT NULL,
    language_label_fr NVARCHAR(80) NULL,
    CONSTRAINT PK_Language PRIMARY KEY (language_code),
    CONSTRAINT UQ_Language_label_nl UNIQUE (language_label_nl),
    CONSTRAINT UQ_Language_label_fr UNIQUE (language_label_fr)
);

CREATE TABLE Title (
    title_code     NVARCHAR(10) NOT NULL,
    title_label_nl NVARCHAR(40) NOT NULL,
    title_label_fr NVARCHAR(40) NULL,
    CONSTRAINT PK_Title PRIMARY KEY (title_code),
    CONSTRAINT UQ_Title_label_nl UNIQUE (title_label_nl),
    CONSTRAINT UQ_Title_label_fr UNIQUE (title_label_fr)
);

CREATE TABLE PhoneType (
    phone_type_code     NVARCHAR(20) NOT NULL,
    phone_type_label_nl NVARCHAR(40) NOT NULL,
    phone_type_label_fr NVARCHAR(40) NULL,
    CONSTRAINT PK_PhoneType PRIMARY KEY (phone_type_code),
    CONSTRAINT UQ_PhoneType_label_nl UNIQUE (phone_type_label_nl),
    CONSTRAINT UQ_PhoneType_label_fr UNIQUE (phone_type_label_fr)
);

CREATE TABLE SocialType (
    social_type_code     NVARCHAR(20) NOT NULL,
    social_type_label_nl NVARCHAR(40) NOT NULL,
    social_type_label_fr NVARCHAR(40) NULL,
    CONSTRAINT PK_SocialType PRIMARY KEY (social_type_code),
    CONSTRAINT UQ_SocialType_label_nl UNIQUE (social_type_label_nl),
    CONSTRAINT UQ_SocialType_label_fr UNIQUE (social_type_label_fr)
);

CREATE TABLE ProfessionalStatus (
    professional_status_code NVARCHAR(30) NOT NULL,
    professional_status_label_nl NVARCHAR(100) NOT NULL,
    professional_status_label_fr NVARCHAR(100) NULL,
    CONSTRAINT PK_ProfessionalStatus PRIMARY KEY (professional_status_code),
    CONSTRAINT UQ_ProfessionalStatus_label_nl UNIQUE (professional_status_label_nl),
    CONSTRAINT UQ_ProfessionalStatus_label_fr UNIQUE (professional_status_label_fr)
);

CREATE TABLE PersonType (
    person_type_code     NVARCHAR(60)  NOT NULL,
    person_type_label_nl NVARCHAR(120) NOT NULL,
    person_type_label_fr NVARCHAR(120) NULL,
    CONSTRAINT PK_PersonType PRIMARY KEY (person_type_code),
    CONSTRAINT UQ_PersonType_label_nl UNIQUE (person_type_label_nl),
    CONSTRAINT UQ_PersonType_label_fr UNIQUE (person_type_label_fr)
);
GO

/* ============================================================== 
   PersonRelation Domain: Relaties tussen personen 
   - PersonRelation: koppelt twee personen met een relatiertype (familiaal, zakelijk, enz.)
   - PersonRelation_Person: join-table (kwalificeert elke PersonRelation met 2 personen in rol 'From' (F) en 'To' (T))
   - PersonRelationType: definieert type relaties (vb. 'SPOUSE', 'CHILD', 'EMPLOYEE')
   ============================================================== */
CREATE TABLE PersonRelation (
    person_relation_id UNIQUEIDENTIFIER NOT NULL 
                       CONSTRAINT DF_PersonRelation_id DEFAULT (NEWSEQUENTIALID()),
    relation_type_code NVARCHAR(50) NOT NULL,   -- FK: references PersonRelationType(relation_type_code)
    start_date         DATE         NULL,
    end_date           DATE         NULL,
    CONSTRAINT PK_PersonRelation PRIMARY KEY (person_relation_id)
);

CREATE TABLE PersonRelation_Person (
    person_relation_id UNIQUEIDENTIFIER NOT NULL,  -- FK: references PersonRelation(person_relation_id)
    person_role        CHAR(1)        NOT NULL,    -- 'F' (From) of 'T' (To) rol
    person_id          UNIQUEIDENTIFIER NOT NULL,  -- FK: references Person(person_id)
    CONSTRAINT PK_PersonRelation_Person PRIMARY KEY (person_relation_id, person_role),
    CONSTRAINT CK_PersonRelation_Role CHECK (person_role IN ('F','T'))
);

CREATE TABLE PersonRelationType (
    relation_type_code NVARCHAR(50) NOT NULL,
    relation_category  NVARCHAR(20) NOT NULL,
    label_nl           NVARCHAR(160) NOT NULL,
    label_fr           NVARCHAR(160) NULL,
    is_active          BIT NOT NULL 
                       CONSTRAINT DF_PersonRelationType_is_active DEFAULT (1),
    CONSTRAINT PK_PersonRelationType PRIMARY KEY (relation_type_code)
);
GO

/* ============================================================== 
   Institution Domain: Instellingen (verzekeraars, banken, etc.) 
   - Institution: entiteiten zoals verzekeringsmaatschappijen, banken
   - InstitutionIdentifier: externe codes/ID's per instelling (bv. KBO, FSMA nr.)
   - InstitutionAddress: adressen van instellingen met adressrole (hoofdzetel, facturatie, enz.)
   - Lookups: InstitutionRole (mogelijk type van relatie in context van contracten), 
              InstitutionIdentifierType (types van externe IDs), InstitutionAddressRole (adresrollen voor instellingen)
   ============================================================== */
CREATE TABLE Institution (
    institution_id   UNIQUEIDENTIFIER NOT NULL 
                     CONSTRAINT DF_Institution_id DEFAULT (NEWID()),
    institution_code NVARCHAR(80)  NOT NULL,
    name             NVARCHAR(200) NOT NULL,
    created_at       DATETIME2(0)  NOT NULL 
                     CONSTRAINT DF_Institution_created DEFAULT (SYSUTCDATETIME()),
    updated_at       DATETIME2(0)  NOT NULL 
                     CONSTRAINT DF_Institution_updated DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Institution PRIMARY KEY (institution_id),
    CONSTRAINT UQ_Institution_code UNIQUE (institution_code)
);

CREATE TABLE InstitutionRole (
    institution_role_code NVARCHAR(20)  NOT NULL,
    label_nl              NVARCHAR(160) NOT NULL,
    label_fr              NVARCHAR(160) NULL,
    is_active             BIT           NOT NULL 
                          CONSTRAINT DF_InstitutionRole_is_active DEFAULT (1),
    CONSTRAINT PK_InstitutionRole PRIMARY KEY (institution_role_code)
);

CREATE TABLE InstitutionIdentifierType (
    id_type_code NVARCHAR(20)  NOT NULL,
    label_nl     NVARCHAR(160) NOT NULL,
    label_fr     NVARCHAR(160) NULL,
    is_active    BIT           NOT NULL 
                 CONSTRAINT DF_InstitutionIdentifierType_is_active DEFAULT (1),
    CONSTRAINT PK_InstitutionIdentifierType PRIMARY KEY (id_type_code)
);

CREATE TABLE InstitutionAddressRole (
    address_role_code NVARCHAR(20)  NOT NULL,
    label_nl          NVARCHAR(120) NOT NULL,
    label_fr          NVARCHAR(120) NULL,
    is_active         BIT           NOT NULL 
                      CONSTRAINT DF_InstitutionAddressRole_is_active DEFAULT (1),
    CONSTRAINT PK_InstitutionAddressRole PRIMARY KEY (address_role_code)
);

CREATE TABLE InstitutionIdentifier (
    institution_id UNIQUEIDENTIFIER NOT NULL,  -- FK: references Institution(institution_id)
    id_type_code   NVARCHAR(20) NOT NULL,      -- FK: references InstitutionIdentifierType(id_type_code)
    id_value       NVARCHAR(80) NOT NULL,
    valid_from     DATE        NOT NULL,
    valid_to       DATE        NULL,
    CONSTRAINT PK_InstitutionIdentifier PRIMARY KEY (institution_id, id_type_code, id_value)
);

CREATE TABLE InstitutionAddress (
    institution_address_id UNIQUEIDENTIFIER NOT NULL 
                           CONSTRAINT DF_InstitutionAddress_id DEFAULT (NEWID()),
    institution_id         UNIQUEIDENTIFIER NOT NULL,  -- FK: references Institution(institution_id)
    address_role_code      NVARCHAR(20)  NOT NULL,      -- FK: references InstitutionAddressRole(address_role_code)
    street                 NVARCHAR(200) NOT NULL,
    house_number           NVARCHAR(30)  NOT NULL,
    box                    NVARCHAR(30)  NULL,
    postal_code            NVARCHAR(20)  NOT NULL,
    city                   NVARCHAR(120) NOT NULL,
    country                NVARCHAR(80)  NOT NULL,
    country_code           CHAR(2)       NOT NULL 
                           CONSTRAINT DF_InstitutionAddress_country_code DEFAULT ('BE'),
    remark                 NVARCHAR(400) NULL,
    is_primary             BIT           NOT NULL 
                           CONSTRAINT DF_InstitutionAddress_is_primary DEFAULT (0),
    created_at             DATETIME2(0)  NOT NULL 
                           CONSTRAINT DF_InstitutionAddress_created DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_InstitutionAddress PRIMARY KEY (institution_address_id)
);
GO

/* ============================================================== 
   Object Domain: Verzekerbare Objecten (algemene object-tabel + specifieke subtypes)
   - Object: hoofdtabel voor een object (voertuig, onroerend goed, lening, enz.)
   - Specifieke subtypes: ObjectVehicle, ObjectRealEstate (+ BurglaryProtection), ObjectLoan, ObjectPerson, ObjectThing, ObjectActivity
   - Lookups: ObjectType, VehicleType, UsageType, FuelType, DriveType, LicensePlateType, RealEstateType, InsuredRole, UseTypeRealEstate, ResidenceType, DestinationType, NatureType, ConstructionType, RoofType, AdjacencyType, OccupancyLevel, BurglaryProtectionType, ObjectPersonSubtype, WorkerRiskClass, EmployeeRiskClass, AgeCategory, ObjectThingSubtype, ThingRiskCategory, ThingMaterialType, ObjectActivitySubtype, ActivityRiskLevel
   ============================================================== */
CREATE TABLE Object (
    object_id      UNIQUEIDENTIFIER NOT NULL 
                   CONSTRAINT DF_Object_id DEFAULT (NEWSEQUENTIALID()),
    object_type_id UNIQUEIDENTIFIER NOT NULL,  -- FK: references ObjectType(object_type_id)
    description    NVARCHAR(255) NOT NULL,
    status         NVARCHAR(30)  NOT NULL,
    start_date     DATE          NOT NULL,
    end_date       DATE          NULL,
    created_at     DATETIME2(3)  NOT NULL 
                   CONSTRAINT DF_Object_created DEFAULT (SYSUTCDATETIME()),
    updated_at     DATETIME2(3)  NOT NULL 
                   CONSTRAINT DF_Object_updated DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Object PRIMARY KEY (object_id),
    CONSTRAINT CK_Object_DateRange CHECK (
        end_date IS NULL OR end_date >= start_date
    )
);

CREATE TABLE ObjectVehicle (
    object_id               UNIQUEIDENTIFIER NOT NULL,  -- PK & FK: references Object(object_id)
    vehicle_type_code       NVARCHAR(60)  NOT NULL,      -- FK: references VehicleType(vehicle_type_code)
    usage_type_code         NVARCHAR(40)  NOT NULL,      -- FK: references UsageType(usage_type_code)
    plate_type_code         NVARCHAR(40)  NOT NULL,      -- FK: references LicensePlateType(plate_type_code)
    brand                   NVARCHAR(100) NOT NULL,
    model                   NVARCHAR(100) NOT NULL,
    chassis_number          NVARCHAR(40)  NOT NULL,
    build_year              INT           NOT NULL,
    first_commissioning_date DATE         NOT NULL,
    registration_date       DATE          NOT NULL,
    license_plate           NVARCHAR(20)  NOT NULL,
    fuel_type_code          NVARCHAR(40)  NULL,         -- FK: references FuelType(fuel_type_code)
    drive_type_code         NVARCHAR(20)  NULL,         -- FK: references DriveType(drive_type_code)
    finance_institution_id  UNIQUEIDENTIFIER NULL,      -- FK: references Institution(institution_id)
    is_financed             BIT NOT NULL 
                           CONSTRAINT DF_ObjectVehicle_is_financed DEFAULT (0),
    insured_value_ex_vat    DECIMAL(18,2) NULL,
    insured_value_inc_vat   DECIMAL(18,2) NULL,
    catalog_value_ex_vat    DECIMAL(18,2) NULL,
    catalog_value_inc_vat   DECIMAL(18,2) NULL,
    vat_exemption_pct       DECIMAL(5,2)  NULL,
    accessories_value       DECIMAL(18,2) NULL,
    pvg_number              NVARCHAR(40)  NULL,
    eu_pvg_number           NVARCHAR(40)  NULL,
    adr_code                NVARCHAR(40)  NULL,
    engine_cc               INT           NULL,
    power_kw                INT           NULL,
    power_hp                INT           NULL,
    plate_cancellation_date DATE          NULL,
    CONSTRAINT PK_ObjectVehicle PRIMARY KEY (object_id),
    CONSTRAINT CK_ObjectVehicle_Financing CHECK (
        (is_financed = 0 AND finance_institution_id IS NULL)
        OR (is_financed = 1 AND finance_institution_id IS NOT NULL)
    )
);

CREATE TABLE ObjectRealEstate (
    object_id                     UNIQUEIDENTIFIER NOT NULL,  -- PK & FK: references Object(object_id)
    -- A. Algemene gegevens
    realestate_type_code          NVARCHAR(80)  NOT NULL,     -- FK: references RealEstateType(realestate_type_code)
    description                   NVARCHAR(255) NULL,
    use_type_code                 NVARCHAR(80)  NOT NULL,     -- FK: references UseTypeRealEstate(use_type_code)
    insured_role_code             NVARCHAR(80)  NOT NULL,     -- FK: references InsuredRole(insured_role_code)
    is_risk_address_policyholder  BIT NOT NULL 
                                 CONSTRAINT DF_ObjectRealEstate_is_risk_address_policyholder DEFAULT (0),
    residence_type_code           NVARCHAR(80)  NULL,         -- FK: references ResidenceType(residence_type_code)
    destination_type_code         NVARCHAR(80)  NULL,         -- FK: references DestinationType(destination_type_code)
    -- B. Locatie van het risico (adres)
    street                        NVARCHAR(200) NOT NULL,
    number                        NVARCHAR(30)  NOT NULL,
    box                           NVARCHAR(30)  NULL,
    postal_code                   NVARCHAR(20)  NOT NULL,
    city                          NVARCHAR(120) NOT NULL,
    country_code                  CHAR(2)       NOT NULL 
                                 CONSTRAINT DF_ObjectRealEstate_country_code DEFAULT ('BE'),
    -- C. Bouwkundige details
    adjacency_type_code           NVARCHAR(80)  NULL,         -- FK: references AdjacencyType(adjacency_type_code)
    occupancy_level_code          NVARCHAR(80)  NULL,         -- FK: references OccupancyLevel(occupancy_level_code)
    construction_type_code        NVARCHAR(80)  NULL,         -- FK: references ConstructionType(construction_type_code)
    roof_type_code                NVARCHAR(80)  NULL,         -- FK: references RoofType(roof_type_code)
    build_year                    INT           NULL,
    is_under_construction         BIT NOT NULL 
                                 CONSTRAINT DF_ObjectRealEstate_is_under_construction DEFAULT (0),
    provisional_delivery_date     DATE          NULL,
    floors_count                 INT           NULL,
    apartment_count              INT           NULL,
    has_solar_panels             BIT NOT NULL 
                                 CONSTRAINT DF_ObjectRealEstate_has_solar_panels DEFAULT (0),
    has_flammable_materials      BIT NOT NULL 
                                 CONSTRAINT DF_ObjectRealEstate_has_flammable_materials DEFAULT (0),
    flammable_materials_pct      DECIMAL(5,2)   NULL,
    -- D. Verzekerde kapitalen & indexatie (ABEX)
    abex_index_building          INT           NULL,
    capital_building             DECIMAL(18,2) NULL,
    abex_index_roof              INT           NULL,
    capital_roof                 DECIMAL(18,2) NULL,
    CONSTRAINT PK_ObjectRealEstate PRIMARY KEY (object_id),
    CONSTRAINT CK_ObjectRealEstate_FlammablePct CHECK (
        flammable_materials_pct IS NULL OR flammable_materials_pct BETWEEN 0 AND 100
    )
);

CREATE TABLE ObjectRealEstate_BurglaryProtection (
    object_id                   UNIQUEIDENTIFIER NOT NULL,  -- FK: references ObjectRealEstate(object_id)
    burglary_protection_type_code NVARCHAR(80) NOT NULL,    -- FK: references BurglaryProtectionType(burglary_protection_type_code)
    CONSTRAINT PK_ObjectRealEstate_BurglaryProtection PRIMARY KEY (object_id, burglary_protection_type_code)
);

CREATE TABLE ObjectLoan (
    object_id                UNIQUEIDENTIFIER NOT NULL,  -- PK & FK: references Object(object_id)
    principal_amount         DECIMAL(18,2) NOT NULL,     -- initieel geleend bedrag
    interest_rate_pct        DECIMAL(5,2)  NOT NULL,     -- rentevoet in %
    interest_periodicity_code NVARCHAR(40) NOT NULL,     -- FK: references Periodicity(periodicity_code) (rente/aflossingsfrequentie)
    duration_type_code       NVARCHAR(20) NOT NULL,      -- FK: references DurationType(duration_type_code) (looptijd type)
    start_date               DATE         NOT NULL,
    end_date                 DATE         NULL,
    remark                   NVARCHAR(255) NULL,
    CONSTRAINT PK_ObjectLoan PRIMARY KEY (object_id),
    CONSTRAINT CK_ObjectLoan_Dates CHECK (
        end_date IS NULL OR end_date >= start_date
    )
);

CREATE TABLE ObjectPerson (
    object_id             UNIQUEIDENTIFIER NOT NULL,  -- PK & FK: references Object(object_id)
    subtype_code          NVARCHAR(80) NOT NULL,      -- FK: references ObjectPersonSubtype(subtype_code)
    description           NVARCHAR(255) NULL,
    is_policyholder       BIT NOT NULL 
                         CONSTRAINT DF_ObjectPerson_is_policyholder DEFAULT (0),
    worker_risk_class_code   NVARCHAR(80) NULL,       -- FK: references WorkerRiskClass(worker_risk_class_code)
    employee_risk_class_code NVARCHAR(80) NULL,       -- FK: references EmployeeRiskClass(employee_risk_class_code)
    person_count          INT        NULL,
    nacebel_code          NVARCHAR(10) NULL,          -- NACE-sector (indien van toepassing)
    person_id             UNIQUEIDENTIFIER NULL,      -- FK: references Person(person_id) (voor individuele persoon-objecten)
    person_relation_id    UNIQUEIDENTIFIER NULL,      -- FK: references PersonRelation(person_relation_id) (voor groep van personen)
    age_category_code     NVARCHAR(40) NULL,          -- FK: references AgeCategory(age_category_code)
    CONSTRAINT PK_ObjectPerson PRIMARY KEY (object_id),
    CONSTRAINT CK_ObjectPerson_IndividualOrGroup CHECK (
        -- Voor individuele persoonsobjecten: person_id moet gevuld en person_count=1
        (subtype_code NOT IN ('PERS_IND','PERS_ACT') OR 
         (person_id IS NOT NULL AND person_relation_id IS NULL AND ISNULL(person_count,1) = 1))
        AND 
        -- Voor groepsobjecten: person_relation moet gevuld en minstens 2 personen
        (subtype_code NOT IN ('GROEP_COL','GROEP_ARB','GROEP_BED','GROEP_POB','GROEP_GEZIN','GEZIN_PRIV') OR 
         (person_id IS NULL AND person_relation_id IS NOT NULL AND ISNULL(person_count,0) >= 2))
    )
);

CREATE TABLE ObjectThing (
    object_id          UNIQUEIDENTIFIER NOT NULL,  -- PK & FK: references Object(object_id)
    subtype_code       NVARCHAR(80)  NOT NULL,     -- FK: references ObjectThingSubtype(subtype_code)
    description        NVARCHAR(255) NULL,
    brand              NVARCHAR(120) NULL,
    model              NVARCHAR(120) NULL,
    serial_number      NVARCHAR(120) NULL,
    value_insured      DECIMAL(18,2) NULL,
    value_new          DECIMAL(18,2) NULL,
    value_current      DECIMAL(18,2) NULL,
    risk_category_code NVARCHAR(40)  NULL,         -- FK: references ThingRiskCategory(risk_category_code)
    material_type_code NVARCHAR(40)  NULL,         -- FK: references ThingMaterialType(material_type_code)
    flammable_pct      DECIMAL(5,2)  NULL,
    location_street    NVARCHAR(200) NULL,
    location_number    NVARCHAR(30)  NULL,
    location_box       NVARCHAR(30)  NULL,
    location_postal_code NVARCHAR(20) NULL,
    location_city      NVARCHAR(120) NULL,
    location_country_code CHAR(2) NULL 
                     CONSTRAINT DF_ObjectThing_location_country DEFAULT ('BE'),
    CONSTRAINT PK_ObjectThing PRIMARY KEY (object_id),
    CONSTRAINT CK_ObjectThing_FlammablePct CHECK (
        flammable_pct IS NULL OR flammable_pct BETWEEN 0 AND 100
    )
);

CREATE TABLE ObjectActivity (
    object_id            UNIQUEIDENTIFIER NOT NULL,  -- PK & FK: references Object(object_id)
    activity_type_code   NVARCHAR(80)  NOT NULL,     -- FK: references ObjectActivitySubtype(activity_type_code)
    description          NVARCHAR(255) NULL,
    start_datetime       DATETIME2(0) NOT NULL,
    end_datetime         DATETIME2(0) NOT NULL,
    participant_count    INT          NULL,
    age_category_code    NVARCHAR(40) NULL,         -- FK: references AgeCategory(age_category_code)
    risk_level_code      NVARCHAR(40) NULL,         -- FK: references ActivityRiskLevel(risk_level_code)
    location_street      NVARCHAR(200) NULL,
    location_number      NVARCHAR(30)  NULL,
    location_box         NVARCHAR(30)  NULL,
    location_postal_code NVARCHAR(20)  NULL,
    location_city        NVARCHAR(120) NULL,
    location_country_code CHAR(2)     NULL 
                       CONSTRAINT DF_ObjectActivity_country DEFAULT ('BE'),
    CONSTRAINT PK_ObjectActivity PRIMARY KEY (object_id),
    CONSTRAINT CK_ObjectActivity_Dates CHECK (end_datetime >= start_datetime),
    CONSTRAINT CK_ObjectActivity_Participants CHECK (participant_count IS NULL OR participant_count >= 0)
);

-- Lookups for Object domain:
CREATE TABLE ObjectType (
    object_type_id UNIQUEIDENTIFIER NOT NULL 
                   CONSTRAINT DF_ObjectType_id DEFAULT (NEWSEQUENTIALID()),
    code           NVARCHAR(40) NOT NULL,
    label          NVARCHAR(120) NOT NULL,
    label_fr       NVARCHAR(120) NULL,
    CONSTRAINT PK_ObjectType PRIMARY KEY (object_type_id),
    CONSTRAINT UQ_ObjectType_code UNIQUE (code)
);

CREATE TABLE VehicleType (
    vehicle_type_code NVARCHAR(60) NOT NULL,
    label_nl          NVARCHAR(160) NOT NULL,
    label_fr          NVARCHAR(160) NULL,
    CONSTRAINT PK_VehicleType PRIMARY KEY (vehicle_type_code)
);

CREATE TABLE UsageType (
    usage_type_code NVARCHAR(40) NOT NULL,
    label_nl        NVARCHAR(160) NOT NULL,
    label_fr        NVARCHAR(160) NULL,
    CONSTRAINT PK_UsageType PRIMARY KEY (usage_type_code)
);

CREATE TABLE FuelType (
    fuel_type_code NVARCHAR(40) NOT NULL,
    label_nl       NVARCHAR(160) NOT NULL,
    label_fr       NVARCHAR(160) NULL,
    CONSTRAINT PK_FuelType PRIMARY KEY (fuel_type_code)
);

CREATE TABLE DriveType (
    drive_type_code NVARCHAR(20) NOT NULL,
    label_nl        NVARCHAR(160) NOT NULL,
    label_fr        NVARCHAR(160) NULL,
    CONSTRAINT PK_DriveType PRIMARY KEY (drive_type_code)
);

CREATE TABLE LicensePlateType (
    plate_type_code NVARCHAR(40) NOT NULL,
    label_nl        NVARCHAR(160) NOT NULL,
    label_fr        NVARCHAR(160) NULL,
    CONSTRAINT PK_LicensePlateType PRIMARY KEY (plate_type_code)
);

CREATE TABLE RealEstateType (
    realestate_type_code NVARCHAR(80) NOT NULL,
    label_nl             NVARCHAR(200) NOT NULL,
    label_fr             NVARCHAR(200) NULL,
    is_active            BIT          NOT NULL 
                         CONSTRAINT DF_RealEstateType_is_active DEFAULT (1),
    CONSTRAINT PK_RealEstateType PRIMARY KEY (realestate_type_code)
);

CREATE TABLE InsuredRole (
    insured_role_code NVARCHAR(80) NOT NULL,
    label_nl          NVARCHAR(200) NOT NULL,
    label_fr          NVARCHAR(200) NULL,
    is_active         BIT          NOT NULL 
                     CONSTRAINT DF_InsuredRole_is_active DEFAULT (1),
    CONSTRAINT PK_InsuredRole PRIMARY KEY (insured_role_code)
);

CREATE TABLE UseTypeRealEstate (
    use_type_code NVARCHAR(80) NOT NULL,
    label_nl      NVARCHAR(200) NOT NULL,
    label_fr      NVARCHAR(200) NULL,
    is_active     BIT          NOT NULL 
                 CONSTRAINT DF_UseTypeRealEstate_is_active DEFAULT (1),
    CONSTRAINT PK_UseTypeRealEstate PRIMARY KEY (use_type_code)
);

/* ---------- ResidenceOccupancyType ---------- */
CREATE TABLE ResidenceOccupancyType (
    residence_occupancy_type_code NVARCHAR(80) NOT NULL,
    label_nl                      NVARCHAR(200) NOT NULL,
    label_fr                      NVARCHAR(200) NULL,
    is_active                     BIT          NOT NULL 
                                  CONSTRAINT DF_ResidenceOccupancyType_is_active DEFAULT (1),
    CONSTRAINT PK_ResidenceOccupancyType PRIMARY KEY (residence_occupancy_type_code)
);
GO

CREATE TABLE ResidenceType (
    residence_type_code NVARCHAR(80) NOT NULL,
    label_nl            NVARCHAR(200) NOT NULL,
    label_fr            NVARCHAR(200) NULL,
    is_active           BIT          NOT NULL 
                       CONSTRAINT DF_ResidenceType_is_active DEFAULT (1),
    CONSTRAINT PK_ResidenceType PRIMARY KEY (residence_type_code)
);

CREATE TABLE DestinationType (
    destination_type_code NVARCHAR(80) NOT NULL,
    label_nl              NVARCHAR(200) NOT NULL,
    label_fr              NVARCHAR(200) NULL,
    is_active             BIT          NOT NULL 
                         CONSTRAINT DF_DestinationType_is_active DEFAULT (1),
    CONSTRAINT PK_DestinationType PRIMARY KEY (destination_type_code)
);

CREATE TABLE NatureType (
    nature_type_code NVARCHAR(80) NOT NULL,
    label_nl         NVARCHAR(200) NOT NULL,
    label_fr         NVARCHAR(200) NULL,
    is_active        BIT          NOT NULL 
                    CONSTRAINT DF_NatureType_is_active DEFAULT (1),
    CONSTRAINT PK_NatureType PRIMARY KEY (nature_type_code)
);

CREATE TABLE ConstructionType (
    construction_type_code NVARCHAR(80) NOT NULL,
    label_nl               NVARCHAR(200) NOT NULL,
    label_fr               NVARCHAR(200) NULL,
    is_active              BIT          NOT NULL 
                         CONSTRAINT DF_ConstructionType_is_active DEFAULT (1),
    CONSTRAINT PK_ConstructionType PRIMARY KEY (construction_type_code)
);

CREATE TABLE RoofType (
    roof_type_code NVARCHAR(80) NOT NULL,
    label_nl       NVARCHAR(200) NOT NULL,
    label_fr       NVARCHAR(200) NULL,
    is_active      BIT          NOT NULL 
                   CONSTRAINT DF_RoofType_is_active DEFAULT (1),
    CONSTRAINT PK_RoofType PRIMARY KEY (roof_type_code)
);

CREATE TABLE AdjacencyType (
    adjacency_type_code NVARCHAR(80) NOT NULL,
    label_nl            NVARCHAR(200) NOT NULL,
    label_fr            NVARCHAR(200) NULL,
    is_active           BIT          NOT NULL 
                      CONSTRAINT DF_AdjacencyType_is_active DEFAULT (1),
    CONSTRAINT PK_AdjacencyType PRIMARY KEY (adjacency_type_code)
);

CREATE TABLE OccupancyLevel (
    occupancy_level_code NVARCHAR(80) NOT NULL,
    label_nl             NVARCHAR(240) NOT NULL,
    label_fr             NVARCHAR(240) NULL,
    is_active            BIT          NOT NULL 
                        CONSTRAINT DF_OccupancyLevel_is_active DEFAULT (1),
    CONSTRAINT PK_OccupancyLevel PRIMARY KEY (occupancy_level_code)
);

CREATE TABLE BurglaryProtectionType (
    burglary_protection_type_code NVARCHAR(80) NOT NULL,
    label_nl                      NVARCHAR(240) NOT NULL,
    label_fr                      NVARCHAR(240) NULL,
    is_active                     BIT          NOT NULL 
                                 CONSTRAINT DF_BurglaryProtectionType_is_active DEFAULT (1),
    CONSTRAINT PK_BurglaryProtectionType PRIMARY KEY (burglary_protection_type_code)
);

CREATE TABLE ObjectPersonSubtype (
    subtype_code NVARCHAR(80) NOT NULL,
    label_nl     NVARCHAR(200) NOT NULL,
    label_fr     NVARCHAR(200) NULL,
    CONSTRAINT PK_ObjectPersonSubtype PRIMARY KEY (subtype_code)
);

CREATE TABLE WorkerRiskClass (
    worker_risk_class_code NVARCHAR(80) NOT NULL,
    label_nl               NVARCHAR(200) NOT NULL,
    label_fr               NVARCHAR(200) NULL,
    CONSTRAINT PK_WorkerRiskClass PRIMARY KEY (worker_risk_class_code)
);

CREATE TABLE EmployeeRiskClass (
    employee_risk_class_code NVARCHAR(80) NOT NULL,
    label_nl                 NVARCHAR(200) NOT NULL,
    label_fr                 NVARCHAR(200) NULL,
    CONSTRAINT PK_EmployeeRiskClass PRIMARY KEY (employee_risk_class_code)
);

CREATE TABLE AgeCategory (
    age_category_code NVARCHAR(40) NOT NULL,
    label_nl          NVARCHAR(120) NOT NULL,
    label_fr          NVARCHAR(120) NULL,
    CONSTRAINT PK_AgeCategory PRIMARY KEY (age_category_code)
);

CREATE TABLE ObjectThingSubtype (
    subtype_code NVARCHAR(80) NOT NULL,
    label_nl     NVARCHAR(200) NOT NULL,
    label_fr     NVARCHAR(200) NULL,
    CONSTRAINT PK_ObjectThingSubtype PRIMARY KEY (subtype_code)
);

CREATE TABLE ThingRiskCategory (
    risk_category_code NVARCHAR(40) NOT NULL,
    label_nl           NVARCHAR(120) NOT NULL,
    label_fr           NVARCHAR(120) NULL,
    CONSTRAINT PK_ThingRiskCategory PRIMARY KEY (risk_category_code)
);

CREATE TABLE ThingMaterialType (
    material_type_code NVARCHAR(40) NOT NULL,
    label_nl           NVARCHAR(120) NOT NULL,
    label_fr           NVARCHAR(120) NULL,
    CONSTRAINT PK_ThingMaterialType PRIMARY KEY (material_type_code)
);

CREATE TABLE ObjectActivitySubtype (
    activity_type_code NVARCHAR(80) NOT NULL,
    label_nl           NVARCHAR(200) NOT NULL,
    label_fr           NVARCHAR(200) NULL,
    CONSTRAINT PK_ObjectActivitySubtype PRIMARY KEY (activity_type_code)
);

CREATE TABLE ActivityRiskLevel (
    risk_level_code NVARCHAR(40) NOT NULL,
    label_nl        NVARCHAR(120) NOT NULL,
    label_fr        NVARCHAR(120) NULL,
    CONSTRAINT PK_ActivityRiskLevel PRIMARY KEY (risk_level_code)
);
GO

/* ============================================================== 
   Contract Domain: Contracten (verzekeringspolissen en kredietcontracten) 
   - Contract: hoofdtabel voor contract (uniek contractnummer)
   - ContractVersion: versies van contract (bv. hernieuwingen, wijzigingen)
   - Contract_Party: koppelcontract met betrokken personen (verzekeringsnemer, verzekerd, kredietnemer, etc.)
   - Contract_Object: koppelcontract met verzekerde objecten
   - ContractVersion_Object: historische koppeling van objecten per contractversie
   - ContractTakeover: gegevens voor overnames van polissen (in- of uitgaand)
   - Lookups: ContractDomain (domein, bijv. 'INSURANCE' vs 'LOAN'), ContractType, ContractStatus, ContractVersionStatus, Periodicity, CollectionMethod, DurationType, TakeoverDirection, TakeoverSourceType, ContractPartyRole, ContractObjectStatus
   ============================================================== */
CREATE TABLE Contract (
    contract_id           UNIQUEIDENTIFIER NOT NULL 
                          CONSTRAINT DF_Contract_id DEFAULT (NEWSEQUENTIALID()),
    contract_number       NVARCHAR(40) NOT NULL,
    contract_domain_code  NVARCHAR(40) NOT NULL,   -- FK: references ContractDomain(contract_domain_code)
    contract_type_code    NVARCHAR(80) NOT NULL,   -- FK: references ContractType(contract_type_code)
    contract_status_code  NVARCHAR(40) NOT NULL,   -- FK: references ContractStatus(contract_status_code)
    company_id            UNIQUEIDENTIFIER NULL,   -- FK: references Institution(institution_id) (verzekeraar/maatschappij)
    handling_company_id   UNIQUEIDENTIFIER NULL,   -- FK: references Institution(institution_id) (beheermaatschappij/tussenpersoon)
    start_date            DATE         NOT NULL,
    end_date              DATE         NULL,
    created_at            DATETIME2(0) NOT NULL 
                          CONSTRAINT DF_Contract_created DEFAULT (SYSUTCDATETIME()),
    updated_at            DATETIME2(0) NOT NULL 
                          CONSTRAINT DF_Contract_updated DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Contract PRIMARY KEY (contract_id),
    CONSTRAINT UQ_Contract_number UNIQUE (contract_number)
);

CREATE TABLE ContractVersion (
    contract_version_id       UNIQUEIDENTIFIER NOT NULL 
                              CONSTRAINT DF_ContractVersion_id DEFAULT (NEWSEQUENTIALID()),
    contract_id               UNIQUEIDENTIFIER NOT NULL,   -- FK: references Contract(contract_id)
    version_no                INT          NOT NULL,
    effective_from            DATE         NOT NULL,
    effective_to              DATE         NULL,
    status_code               NVARCHAR(20) NOT NULL,       -- FK: references ContractVersionStatus(status_code)
    continuation_type_code    NVARCHAR(20) NULL,           -- bijv. type van voortzetting (verlenging, wijziging)
    duration_type_code        NVARCHAR(20) NOT NULL,       -- FK: references DurationType(duration_type_code)
    periodicity_code          NVARCHAR(40) NOT NULL,       -- FK: references Periodicity(periodicity_code)
    collection_method_code    NVARCHAR(20) NOT NULL,       -- FK: references CollectionMethod(collection_method_code)
    initial_start_date        DATE         NULL,
    parent_contract_id        UNIQUEIDENTIFIER NULL,       -- bij splitsing/overname, FK: references Contract(contract_id)
    company_endorsement_number NVARCHAR(40) NULL,
    coinsurance_participation_pct DECIMAL(5,2) NULL,
    created_at                DATETIME2(0) NOT NULL 
                              CONSTRAINT DF_ContractVersion_created DEFAULT (SYSUTCDATETIME()),
    updated_at                DATETIME2(0) NOT NULL 
                              CONSTRAINT DF_ContractVersion_updated DEFAULT (SYSUTCDATETIME()),
    manager_person_id         UNIQUEIDENTIFIER NULL,       -- intern verantwoordelijke persoon, FK: references Person(person_id)
    CONSTRAINT PK_ContractVersion PRIMARY KEY (contract_version_id)
);

CREATE TABLE Contract_Party (
    contract_id            UNIQUEIDENTIFIER NOT NULL,  -- FK: references Contract(contract_id)
    person_id              UNIQUEIDENTIFIER NOT NULL,  -- FK: references Person(person_id)
    contract_party_role_code NVARCHAR(40) NOT NULL,    -- FK: references ContractPartyRole(contract_party_role_code)
    is_primary             BIT NOT NULL 
                           CONSTRAINT DF_ContractParty_is_primary DEFAULT (0),
    created_at             DATETIME2(0) NOT NULL 
                           CONSTRAINT DF_ContractParty_created DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Contract_Party PRIMARY KEY (contract_id, person_id, contract_party_role_code)
);

CREATE TABLE Contract_Object (
    contract_id              UNIQUEIDENTIFIER NOT NULL,  -- FK: references Contract(contract_id)
    object_id                UNIQUEIDENTIFIER NOT NULL,  -- FK: references Object(object_id)
    contract_object_status_code NVARCHAR(20) NOT NULL,   -- FK: references ContractObjectStatus(contract_object_status_code)
    is_primary               BIT NOT NULL 
                             CONSTRAINT DF_ContractObject_is_primary DEFAULT (0),
    to_date                  DATE NULL,
    created_at               DATETIME2(0) NOT NULL 
                             CONSTRAINT DF_ContractObject_created DEFAULT (SYSUTCDATETIME()),
    updated_at               DATETIME2(0) NOT NULL 
                             CONSTRAINT DF_ContractObject_updated DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Contract_Object PRIMARY KEY (contract_id, object_id)
);

CREATE TABLE ContractVersion_Object (
    contract_version_id UNIQUEIDENTIFIER NOT NULL,  -- FK: references ContractVersion(contract_version_id)
    contract_id         UNIQUEIDENTIFIER NOT NULL,  -- FK: references Contract(contract_id)
    object_id           UNIQUEIDENTIFIER NOT NULL,  -- FK: references Object(object_id)
    CONSTRAINT PK_ContractVersion_Object PRIMARY KEY (contract_version_id, object_id)
);

CREATE TABLE ContractTakeover (
    contract_version_id         UNIQUEIDENTIFIER NOT NULL,  -- FK: references ContractVersion(contract_version_id)
    takeover_direction_code     NVARCHAR(20) NOT NULL,      -- FK: references TakeoverDirection(takeover_direction_code)
    takeover_source_type_code   NVARCHAR(40) NOT NULL,      -- FK: references TakeoverSourceType(takeover_source_type_code)
    other_institution_id        UNIQUEIDENTIFIER NULL,      -- FK: references Institution(institution_id) (externe maatschappij)
    other_policy_number         NVARCHAR(40) NULL,
    other_policy_start_date     DATE NULL,
    other_policy_end_date       DATE NULL,
    related_contract_version_id UNIQUEIDENTIFIER NULL,      -- voor interne overnames binnen eigen database
    CONSTRAINT PK_ContractTakeover PRIMARY KEY (contract_version_id)
);

-- Lookups for Contract domain:
CREATE TABLE ContractDomain (
    contract_domain_code NVARCHAR(40) NOT NULL,
    label_nl             NVARCHAR(200) NOT NULL,
    label_fr             NVARCHAR(200) NULL,
    is_active            BIT NOT NULL 
                        CONSTRAINT DF_ContractDomain_is_active DEFAULT (1),
    CONSTRAINT PK_ContractDomain PRIMARY KEY (contract_domain_code)
);

CREATE TABLE ContractVersionStatus (
    status_code    NVARCHAR(20)  NOT NULL,
    status_label   NVARCHAR(100) NOT NULL,
    status_label_fr NVARCHAR(100) NULL,
    is_active      BIT NOT NULL 
                   CONSTRAINT DF_ContractVersionStatus_is_active DEFAULT (1),
    CONSTRAINT PK_ContractVersionStatus PRIMARY KEY (status_code)
);

CREATE TABLE ContractStatus (
    contract_status_code NVARCHAR(40)  NOT NULL,
    status_label         NVARCHAR(100) NOT NULL,
    status_label_fr      NVARCHAR(100) NULL,
    is_active            BIT NOT NULL 
                         CONSTRAINT DF_ContractStatus_is_active DEFAULT (1),
    CONSTRAINT PK_ContractStatus PRIMARY KEY (contract_status_code)
);

CREATE TABLE Periodicity (
    periodicity_code NVARCHAR(40)  NOT NULL,
    periodicity_label NVARCHAR(100) NOT NULL,
    periodicity_label_fr NVARCHAR(100) NULL,
    is_active        BIT NOT NULL 
                     CONSTRAINT DF_Periodicity_is_active DEFAULT (1),
    CONSTRAINT PK_Periodicity PRIMARY KEY (periodicity_code)
);

CREATE TABLE CollectionMethod (
    collection_method_code NVARCHAR(20)  NOT NULL,
    collection_method_label NVARCHAR(100) NOT NULL,
    collection_method_label_fr NVARCHAR(100) NULL,
    is_active             BIT NOT NULL 
                          CONSTRAINT DF_CollectionMethod_is_active DEFAULT (1),
    CONSTRAINT PK_CollectionMethod PRIMARY KEY (collection_method_code)
);

CREATE TABLE DurationType (
    duration_type_code NVARCHAR(20) NOT NULL,
    label_nl           NVARCHAR(40) NOT NULL,
    label_fr           NVARCHAR(40) NULL,
    is_active          BIT NOT NULL 
                      CONSTRAINT DF_DurationType_is_active DEFAULT (1),
    CONSTRAINT PK_DurationType PRIMARY KEY (duration_type_code)
);

CREATE TABLE ContractType (
    contract_type_code  NVARCHAR(80) NOT NULL,
    contract_domain_code NVARCHAR(40) NOT NULL,   -- FK: references ContractDomain(contract_domain_code)
    contract_type_name   NVARCHAR(100) NOT NULL,
    contract_type_name_fr NVARCHAR(100) NULL,
    is_active            BIT NOT NULL 
                         CONSTRAINT DF_ContractType_is_active DEFAULT (1),
    CONSTRAINT PK_ContractType PRIMARY KEY (contract_type_code)
);

CREATE TABLE TakeoverDirection (
    takeover_direction_code NVARCHAR(20) NOT NULL,
    label_nl                NVARCHAR(100) NOT NULL,
    label_fr                NVARCHAR(100) NULL,
    is_active               BIT NOT NULL 
                           CONSTRAINT DF_TakeoverDirection_is_active DEFAULT (1),
    CONSTRAINT PK_TakeoverDirection PRIMARY KEY (takeover_direction_code)
);

CREATE TABLE TakeoverSourceType (
    takeover_source_type_code NVARCHAR(40) NOT NULL,
    label_nl                  NVARCHAR(100) NOT NULL,
    label_fr                  NVARCHAR(100) NULL,
    is_active                 BIT NOT NULL 
                             CONSTRAINT DF_TakeoverSourceType_is_active DEFAULT (1),
    CONSTRAINT PK_TakeoverSourceType PRIMARY KEY (takeover_source_type_code)
);

CREATE TABLE ContractPartyRole (
    contract_party_role_code NVARCHAR(40) NOT NULL,
    role_label               NVARCHAR(100) NOT NULL,
    role_label_fr            NVARCHAR(100) NULL,
    is_active                BIT NOT NULL 
                             CONSTRAINT DF_ContractPartyRole_is_active DEFAULT (1),
    CONSTRAINT PK_ContractPartyRole PRIMARY KEY (contract_party_role_code)
);

CREATE TABLE ContractObjectStatus (
    contract_object_status_code NVARCHAR(20) NOT NULL,
    status_label                NVARCHAR(100) NOT NULL,
    status_label_fr             NVARCHAR(100) NULL,
    is_active                   BIT NOT NULL DEFAULT (1),
    CONSTRAINT PK_ContractObjectStatus PRIMARY KEY (contract_object_status_code)
);

-- Coverage domain: Dekkingen (verzekeringsdekkingen) en mapping naar contractdomeinen
CREATE TABLE lookup_coverage (
    coverage_code NVARCHAR(40)  NOT NULL,
    label_nl      NVARCHAR(200) NOT NULL,
    label_fr      NVARCHAR(200) NULL,
    is_active     BIT NOT NULL DEFAULT (1),
    CONSTRAINT PK_lookup_coverage PRIMARY KEY (coverage_code)
);

CREATE TABLE coverage_domain (
    coverage_code        NVARCHAR(40) NOT NULL,  -- FK: references lookup_coverage(coverage_code)
    contract_domain_code NVARCHAR(40) NOT NULL,  -- FK: references ContractDomain(contract_domain_code)
    CONSTRAINT PK_coverage_domain PRIMARY KEY (coverage_code, contract_domain_code)
);
GO

/* ============================================================== 
   Claim Domain: Schadedossiers 
   - Claim: schadegeval (vb. verzekeringsclaim of schademelding)
   - Claim_Party: betrokken personen per claim (aangever, verzekerde, tegenpartij, etc.)
   - Claim_Object: betrokken objecten per claim
   - Claim_Circumstance: omstandigheden/oorzaken (bv. brand, diefstal) per claim
   - Lookups: ClaimStatus, ClaimPartyRole, ClaimCircumstanceType, ClaimPaymentMethod
   ============================================================== */
CREATE TABLE Claim (
    claim_id           UNIQUEIDENTIFIER NOT NULL 
                       CONSTRAINT DF_Claim_id DEFAULT (NEWSEQUENTIALID()),
    claim_number       NVARCHAR(50) NOT NULL,
    contract_id        UNIQUEIDENTIFIER NOT NULL,   -- FK: references Contract(contract_id)
    coverage_code      NVARCHAR(40) NOT NULL,       -- FK: references lookup_coverage(coverage_code)
    claim_status_code  NVARCHAR(40) NOT NULL,       -- FK: references ClaimStatus(claim_status_code)
    claims_handler_id  UNIQUEIDENTIFIER NULL,       -- interne behandelaar, FK: references Person(person_id)
    incident_date      DATE         NULL,
    reported_date      DATE         NOT NULL,
    closed_date        DATE         NULL,
    description        NVARCHAR(500) NULL,
    paid_amount        DECIMAL(18,2) NULL,
    payment_method_code NVARCHAR(40) NULL,          -- FK: references ClaimPaymentMethod(payment_method_code)
    created_at         DATETIME2(0) NOT NULL 
                       CONSTRAINT DF_Claim_created DEFAULT (SYSUTCDATETIME()),
    updated_at         DATETIME2(0) NOT NULL 
                       CONSTRAINT DF_Claim_updated DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Claim PRIMARY KEY (claim_id),
    CONSTRAINT UQ_Claim_number UNIQUE (claim_number),
    -- Consistency checks within a claim record:
    CONSTRAINT CK_Claim_ClosedStatusDate CHECK (
        (closed_date IS NULL OR claim_status_code = 'CLOSED')
        AND (claim_status_code <> 'CLOSED' OR closed_date IS NOT NULL)
    ),
    CONSTRAINT CK_Claim_PaymentMethod CHECK (
        NOT (paid_amount > 0 AND payment_method_code IS NULL)
    ),
    CONSTRAINT CK_Claim_PaidAmountNonNegative CHECK (
        paid_amount IS NULL OR paid_amount >= 0
    )
);

CREATE TABLE Claim_Party (
    claim_id            UNIQUEIDENTIFIER NOT NULL,  -- FK: references Claim(claim_id)
    person_id           UNIQUEIDENTIFIER NOT NULL,  -- FK: references Person(person_id)
    claim_party_role_code NVARCHAR(40) NOT NULL,    -- FK: references ClaimPartyRole(claim_party_role_code)
    is_primary          BIT NOT NULL 
                       CONSTRAINT DF_Claim_Party_is_primary DEFAULT (0),
    created_at          DATETIME2(0) NOT NULL 
                       CONSTRAINT DF_Claim_Party_created DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Claim_Party PRIMARY KEY (claim_id, person_id, claim_party_role_code)
);

CREATE TABLE Claim_Object (
    claim_id   UNIQUEIDENTIFIER NOT NULL,  -- FK: references Claim(claim_id)
    object_id  UNIQUEIDENTIFIER NOT NULL,  -- FK: references Object(object_id)
    is_primary BIT NOT NULL 
               CONSTRAINT DF_Claim_Object_is_primary DEFAULT (0),
    created_at DATETIME2(0) NOT NULL 
               CONSTRAINT DF_Claim_Object_created DEFAULT (SYSUTCDATETIME()),
    updated_at DATETIME2(0) NOT NULL 
               CONSTRAINT DF_Claim_Object_updated DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Claim_Object PRIMARY KEY (claim_id, object_id)
);

CREATE TABLE Claim_Circumstance (
    claim_id                    UNIQUEIDENTIFIER NOT NULL,  -- FK: references Claim(claim_id)
    claim_circumstance_type_code NVARCHAR(40) NOT NULL,     -- FK: references ClaimCircumstanceType(claim_circumstance_type_code)
    is_primary                  BIT NOT NULL 
                                CONSTRAINT DF_Claim_Circumstance_is_primary DEFAULT (0),
    created_at                  DATETIME2(0) NOT NULL 
                                CONSTRAINT DF_Claim_Circumstance_created DEFAULT (SYSUTCDATETIME()),
    updated_at                  DATETIME2(0) NOT NULL 
                                CONSTRAINT DF_Claim_Circumstance_updated DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Claim_Circumstance PRIMARY KEY (claim_id, claim_circumstance_type_code)
);

-- Lookups for Claim domain:
CREATE TABLE ClaimStatus (
    claim_status_code NVARCHAR(40)  NOT NULL,
    status_label      NVARCHAR(100) NOT NULL,
    status_label_fr   NVARCHAR(100) NULL,
    is_active         BIT          NOT NULL 
                      CONSTRAINT DF_ClaimStatus_is_active DEFAULT (1),
    CONSTRAINT PK_ClaimStatus PRIMARY KEY (claim_status_code)
);

CREATE TABLE ClaimPartyRole (
    claim_party_role_code NVARCHAR(40)  NOT NULL,
    role_label            NVARCHAR(100) NOT NULL,
    role_label_fr         NVARCHAR(100) NULL,
    is_active             BIT          NOT NULL 
                          CONSTRAINT DF_ClaimPartyRole_is_active DEFAULT (1),
    CONSTRAINT PK_ClaimPartyRole PRIMARY KEY (claim_party_role_code)
);

CREATE TABLE ClaimCircumstanceType (
    claim_circumstance_type_code NVARCHAR(40) NOT NULL,
    circumstance_label           NVARCHAR(100) NOT NULL,
    circumstance_label_fr        NVARCHAR(100) NULL,
    is_active                    BIT          NOT NULL 
                                CONSTRAINT DF_ClaimCircumstanceType_is_active DEFAULT (1),
    CONSTRAINT PK_ClaimCircumstanceType PRIMARY KEY (claim_circumstance_type_code)
);

CREATE TABLE ClaimPaymentMethod (
    payment_method_code NVARCHAR(40)  NOT NULL,
    method_label        NVARCHAR(100) NOT NULL,
    method_label_fr     NVARCHAR(100) NULL,
    is_active           BIT          NOT NULL 
                        CONSTRAINT DF_ClaimPaymentMethod_is_active DEFAULT (1),
    CONSTRAINT PK_ClaimPaymentMethod PRIMARY KEY (payment_method_code)
);


PRINT '';
PRINT '======================================================';
PRINT ' Schema creation complete!';
PRINT '======================================================';
GO
