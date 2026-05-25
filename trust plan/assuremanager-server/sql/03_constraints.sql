-- =============================================================
-- AssureManager Database Constraints
-- Foreign Keys, Unique Constraints, Check Constraints
-- =============================================================
-- Run AFTER 02_schema.sql
-- =============================================================

SET NOCOUNT ON;
GO

USE AssureManagerDB;
GO

PRINT '======================================================';
PRINT ' Applying constraints...';
PRINT '======================================================';
GO

-- 02_constraints.sql - Add constraints (Foreign Keys, Unique, Check) to the database schema.
-- This script assumes all tables are created (see 02_schema.sql).
-- Constraints zijn gegroepeerd per functioneel domein voor overzichtelijkheid.

-- =============================================================
-- Person Domain Constraints
-- =============================================================
ALTER TABLE Person
    ADD CONSTRAINT FK_Person_Language FOREIGN KEY (language_code) REFERENCES Language(language_code),
    ADD CONSTRAINT FK_Person_Subagent FOREIGN KEY (subagent_person_id) REFERENCES Person(person_id),
    ADD CONSTRAINT FK_Person_Manager FOREIGN KEY (manager_person_id) REFERENCES Person(person_id),
    ADD CONSTRAINT FK_Person_Portfolio FOREIGN KEY (portfolio_person_id) REFERENCES Person(person_id);

ALTER TABLE NaturalPerson
    ADD CONSTRAINT FK_NaturalPerson_Person FOREIGN KEY (person_id) REFERENCES Person(person_id),
    ADD CONSTRAINT FK_NaturalPerson_Title FOREIGN KEY (title_code) REFERENCES Title(title_code);

ALTER TABLE LegalPerson
    ADD CONSTRAINT FK_LegalPerson_Person FOREIGN KEY (person_id) REFERENCES Person(person_id);

ALTER TABLE EconomicActivity
    ADD CONSTRAINT FK_EconomicActivity_Person FOREIGN KEY (person_id) REFERENCES Person(person_id),
    ADD CONSTRAINT FK_EconomicActivity_ProfStatus FOREIGN KEY (professional_status_code) REFERENCES ProfessionalStatus(professional_status_code);

ALTER TABLE EconomicActivity_Nacebel
    ADD CONSTRAINT FK_EconomicActivityNacebel_Activity FOREIGN KEY (economic_activity_id) REFERENCES EconomicActivity(economic_activity_id);
    -- Note: If a NACEBEL lookup table exists, add a FOREIGN KEY for nacebel_code here.

ALTER TABLE Person_PersonType
    ADD CONSTRAINT FK_PersonPersonType_Person FOREIGN KEY (person_id) REFERENCES Person(person_id),
    ADD CONSTRAINT FK_PersonPersonType_Type FOREIGN KEY (person_type_code) REFERENCES PersonType(person_type_code);

ALTER TABLE Address
    ADD CONSTRAINT FK_Address_Person FOREIGN KEY (person_id) REFERENCES Person(person_id),
    ADD CONSTRAINT FK_Address_AddressRole FOREIGN KEY (address_role_code) REFERENCES PersonAddressRole(address_role_code);

ALTER TABLE Phone
    ADD CONSTRAINT FK_Phone_Person FOREIGN KEY (person_id) REFERENCES Person(person_id),
    ADD CONSTRAINT FK_Phone_PhoneType FOREIGN KEY (phone_type_code) REFERENCES PhoneType(phone_type_code);

ALTER TABLE Email
    ADD CONSTRAINT FK_Email_Person FOREIGN KEY (person_id) REFERENCES Person(person_id);

ALTER TABLE SocialMedia
    ADD CONSTRAINT FK_SocialMedia_Person FOREIGN KEY (person_id) REFERENCES Person(person_id),
    ADD CONSTRAINT FK_SocialMedia_SocialType FOREIGN KEY (social_type_code) REFERENCES SocialType(social_type_code);

ALTER TABLE BankAccount
    ADD CONSTRAINT FK_BankAccount_Person FOREIGN KEY (person_id) REFERENCES Person(person_id);

ALTER TABLE DriverLicense
    ADD CONSTRAINT FK_DriverLicense_Person FOREIGN KEY (person_id) REFERENCES Person(person_id);

-- Additional Person domain constraints: Unique and Check constraints
ALTER TABLE Person
    ADD CONSTRAINT UQ_Person_Dossier UNIQUE (dossier);

-- NOTE: CK_NaturalPerson_Lifespan is already defined in 02_schema.sql (line 63-65)
-- ALTER TABLE NaturalPerson
--     ADD CONSTRAINT CK_NaturalPerson_Lifespan CHECK (...);

ALTER TABLE LegalPerson
    ADD CONSTRAINT CK_LegalPerson_DateOrder CHECK (closing_date IS NULL OR incorporation_date IS NULL OR closing_date >= incorporation_date);

GO

-- =============================================================
-- PersonRelation Domain Constraints
-- =============================================================
ALTER TABLE PersonRelation
    ADD CONSTRAINT FK_PersonRelation_RelationType FOREIGN KEY (relation_type_code) REFERENCES PersonRelationType(relation_type_code);

ALTER TABLE PersonRelation_Person
    ADD CONSTRAINT FK_PersonRelationPerson_Relation FOREIGN KEY (person_relation_id) REFERENCES PersonRelation(person_relation_id),
    ADD CONSTRAINT FK_PersonRelationPerson_Person FOREIGN KEY (person_id) REFERENCES Person(person_id);

GO

-- =============================================================
-- Institution Domain Constraints
-- =============================================================
ALTER TABLE InstitutionIdentifier
    ADD CONSTRAINT FK_InstitutionIdentifier_Institution FOREIGN KEY (institution_id) REFERENCES Institution(institution_id),
    ADD CONSTRAINT FK_InstitutionIdentifier_IdentifierType FOREIGN KEY (id_type_code) REFERENCES InstitutionIdentifierType(id_type_code);

ALTER TABLE InstitutionAddress
    ADD CONSTRAINT FK_InstitutionAddress_Institution FOREIGN KEY (institution_id) REFERENCES Institution(institution_id),
    ADD CONSTRAINT FK_InstitutionAddress_AddressRole FOREIGN KEY (address_role_code) REFERENCES InstitutionAddressRole(address_role_code);

-- Additional Institution domain constraints: Unique constraints
ALTER TABLE InstitutionIdentifier
    ADD CONSTRAINT UQ_InstitutionIdentifier_Type UNIQUE (institution_id, id_type_code);

GO

-- =============================================================
-- Object Domain Constraints
-- =============================================================
ALTER TABLE Object
    ADD CONSTRAINT FK_Object_ObjectType FOREIGN KEY (object_type_id) REFERENCES ObjectType(object_type_id);

ALTER TABLE ObjectVehicle
    ADD CONSTRAINT FK_ObjectVehicle_Object FOREIGN KEY (object_id) REFERENCES Object(object_id),
    ADD CONSTRAINT FK_ObjectVehicle_VehicleType FOREIGN KEY (vehicle_type_code) REFERENCES VehicleType(vehicle_type_code),
    ADD CONSTRAINT FK_ObjectVehicle_UsageType FOREIGN KEY (usage_type_code) REFERENCES UsageType(usage_type_code),
    ADD CONSTRAINT FK_ObjectVehicle_PlateType FOREIGN KEY (plate_type_code) REFERENCES LicensePlateType(plate_type_code),
    ADD CONSTRAINT FK_ObjectVehicle_FuelType FOREIGN KEY (fuel_type_code) REFERENCES FuelType(fuel_type_code),
    ADD CONSTRAINT FK_ObjectVehicle_DriveType FOREIGN KEY (drive_type_code) REFERENCES DriveType(drive_type_code),
    ADD CONSTRAINT FK_ObjectVehicle_FinanceInstitution FOREIGN KEY (finance_institution_id) REFERENCES Institution(institution_id);

ALTER TABLE ObjectRealEstate
    ADD CONSTRAINT FK_ObjectRealEstate_Object FOREIGN KEY (object_id) REFERENCES Object(object_id),
    ADD CONSTRAINT FK_ObjectRealEstate_Type FOREIGN KEY (realestate_type_code) REFERENCES RealEstateType(realestate_type_code),
    ADD CONSTRAINT FK_ObjectRealEstate_UseType FOREIGN KEY (use_type_code) REFERENCES UseTypeRealEstate(use_type_code),
    ADD CONSTRAINT FK_ObjectRealEstate_InsuredRole FOREIGN KEY (insured_role_code) REFERENCES InsuredRole(insured_role_code),
    ADD CONSTRAINT FK_ObjectRealEstate_ResidenceType FOREIGN KEY (residence_type_code) REFERENCES ResidenceType(residence_type_code),
    ADD CONSTRAINT FK_ObjectRealEstate_DestinationType FOREIGN KEY (destination_type_code) REFERENCES DestinationType(destination_type_code),
    ADD CONSTRAINT FK_ObjectRealEstate_AdjacencyType FOREIGN KEY (adjacency_type_code) REFERENCES AdjacencyType(adjacency_type_code),
    ADD CONSTRAINT FK_ObjectRealEstate_OccupancyLevel FOREIGN KEY (occupancy_level_code) REFERENCES OccupancyLevel(occupancy_level_code),
    ADD CONSTRAINT FK_ObjectRealEstate_ConstructionType FOREIGN KEY (construction_type_code) REFERENCES ConstructionType(construction_type_code),
    ADD CONSTRAINT FK_ObjectRealEstate_RoofType FOREIGN KEY (roof_type_code) REFERENCES RoofType(roof_type_code);

ALTER TABLE ObjectRealEstate_BurglaryProtection
    ADD CONSTRAINT FK_ObjectRealEstateBurglaryProtection_ObjectRealEstate FOREIGN KEY (object_id) REFERENCES ObjectRealEstate(object_id),
    ADD CONSTRAINT FK_ObjectRealEstateBurglaryProtection_Type FOREIGN KEY (burglary_protection_type_code) REFERENCES BurglaryProtectionType(burglary_protection_type_code);

ALTER TABLE ObjectLoan
    ADD CONSTRAINT FK_ObjectLoan_Object FOREIGN KEY (object_id) REFERENCES Object(object_id),
    ADD CONSTRAINT FK_ObjectLoan_Periodicity FOREIGN KEY (interest_periodicity_code) REFERENCES Periodicity(periodicity_code),
    ADD CONSTRAINT FK_ObjectLoan_DurationType FOREIGN KEY (duration_type_code) REFERENCES DurationType(duration_type_code);

ALTER TABLE ObjectPerson
    ADD CONSTRAINT FK_ObjectPerson_Object FOREIGN KEY (object_id) REFERENCES Object(object_id),
    ADD CONSTRAINT FK_ObjectPerson_Subtype FOREIGN KEY (subtype_code) REFERENCES ObjectPersonSubtype(subtype_code),
    ADD CONSTRAINT FK_ObjectPerson_WorkerRiskClass FOREIGN KEY (worker_risk_class_code) REFERENCES WorkerRiskClass(worker_risk_class_code),
    ADD CONSTRAINT FK_ObjectPerson_EmployeeRiskClass FOREIGN KEY (employee_risk_class_code) REFERENCES EmployeeRiskClass(employee_risk_class_code),
    ADD CONSTRAINT FK_ObjectPerson_Person FOREIGN KEY (person_id) REFERENCES Person(person_id),
    ADD CONSTRAINT FK_ObjectPerson_PersonRelation FOREIGN KEY (person_relation_id) REFERENCES PersonRelation(person_relation_id),
    ADD CONSTRAINT FK_ObjectPerson_AgeCategory FOREIGN KEY (age_category_code) REFERENCES AgeCategory(age_category_code);

ALTER TABLE ObjectThing
    ADD CONSTRAINT FK_ObjectThing_Object FOREIGN KEY (object_id) REFERENCES Object(object_id),
    ADD CONSTRAINT FK_ObjectThing_Subtype FOREIGN KEY (subtype_code) REFERENCES ObjectThingSubtype(subtype_code),
    ADD CONSTRAINT FK_ObjectThing_RiskCategory FOREIGN KEY (risk_category_code) REFERENCES ThingRiskCategory(risk_category_code),
    ADD CONSTRAINT FK_ObjectThing_MaterialType FOREIGN KEY (material_type_code) REFERENCES ThingMaterialType(material_type_code);

ALTER TABLE ObjectActivity
    ADD CONSTRAINT FK_ObjectActivity_Object FOREIGN KEY (object_id) REFERENCES Object(object_id),
    ADD CONSTRAINT FK_ObjectActivity_Subtype FOREIGN KEY (activity_type_code) REFERENCES ObjectActivitySubtype(activity_type_code),
    ADD CONSTRAINT FK_ObjectActivity_AgeCategory FOREIGN KEY (age_category_code) REFERENCES AgeCategory(age_category_code),
    ADD CONSTRAINT FK_ObjectActivity_RiskLevel FOREIGN KEY (risk_level_code) REFERENCES ActivityRiskLevel(risk_level_code);

GO

-- =============================================================
-- Contract Domain Constraints
-- =============================================================
ALTER TABLE Contract
    ADD CONSTRAINT FK_Contract_ContractDomain FOREIGN KEY (contract_domain_code) REFERENCES ContractDomain(contract_domain_code),
    ADD CONSTRAINT FK_Contract_ContractType FOREIGN KEY (contract_type_code) REFERENCES ContractType(contract_type_code),
    ADD CONSTRAINT FK_Contract_ContractStatus FOREIGN KEY (contract_status_code) REFERENCES ContractStatus(contract_status_code),
    ADD CONSTRAINT FK_Contract_Company_Institution FOREIGN KEY (company_id) REFERENCES Institution(institution_id),
    ADD CONSTRAINT FK_Contract_HandlingCompany_Institution FOREIGN KEY (handling_company_id) REFERENCES Institution(institution_id);

ALTER TABLE ContractVersion
    ADD CONSTRAINT FK_ContractVersion_Contract FOREIGN KEY (contract_id) REFERENCES Contract(contract_id),
    ADD CONSTRAINT FK_ContractVersion_VersionStatus FOREIGN KEY (status_code) REFERENCES ContractVersionStatus(status_code),
    -- If a ContinuationType lookup table exists, add FOREIGN KEY for continuation_type_code
    ADD CONSTRAINT FK_ContractVersion_DurationType FOREIGN KEY (duration_type_code) REFERENCES DurationType(duration_type_code),
    ADD CONSTRAINT FK_ContractVersion_Periodicity FOREIGN KEY (periodicity_code) REFERENCES Periodicity(periodicity_code),
    ADD CONSTRAINT FK_ContractVersion_CollectionMethod FOREIGN KEY (collection_method_code) REFERENCES CollectionMethod(collection_method_code),
    ADD CONSTRAINT FK_ContractVersion_ParentContract FOREIGN KEY (parent_contract_id) REFERENCES Contract(contract_id),
    ADD CONSTRAINT FK_ContractVersion_ManagerPerson FOREIGN KEY (manager_person_id) REFERENCES Person(person_id);

ALTER TABLE Contract_Party
    ADD CONSTRAINT FK_ContractParty_Contract FOREIGN KEY (contract_id) REFERENCES Contract(contract_id),
    ADD CONSTRAINT FK_ContractParty_Person FOREIGN KEY (person_id) REFERENCES Person(person_id),
    ADD CONSTRAINT FK_ContractParty_Role FOREIGN KEY (contract_party_role_code) REFERENCES ContractPartyRole(contract_party_role_code);

ALTER TABLE Contract_Object
    ADD CONSTRAINT FK_ContractObject_Contract FOREIGN KEY (contract_id) REFERENCES Contract(contract_id),
    ADD CONSTRAINT FK_ContractObject_Object FOREIGN KEY (object_id) REFERENCES Object(object_id),
    ADD CONSTRAINT FK_ContractObject_Status FOREIGN KEY (contract_object_status_code) REFERENCES ContractObjectStatus(contract_object_status_code);

ALTER TABLE ContractVersion_Object
    ADD CONSTRAINT FK_ContractVersionObject_Version FOREIGN KEY (contract_version_id) REFERENCES ContractVersion(contract_version_id),
    ADD CONSTRAINT FK_ContractVersionObject_Contract FOREIGN KEY (contract_id) REFERENCES Contract(contract_id),
    ADD CONSTRAINT FK_ContractVersionObject_Object FOREIGN KEY (object_id) REFERENCES Object(object_id);

ALTER TABLE ContractTakeover
    ADD CONSTRAINT FK_ContractTakeover_ContractVersion FOREIGN KEY (contract_version_id) REFERENCES ContractVersion(contract_version_id),
    ADD CONSTRAINT FK_ContractTakeover_Direction FOREIGN KEY (takeover_direction_code) REFERENCES TakeoverDirection(takeover_direction_code),
    ADD CONSTRAINT FK_ContractTakeover_SourceType FOREIGN KEY (takeover_source_type_code) REFERENCES TakeoverSourceType(takeover_source_type_code),
    ADD CONSTRAINT FK_ContractTakeover_OtherInstitution FOREIGN KEY (other_institution_id) REFERENCES Institution(institution_id),
    ADD CONSTRAINT FK_ContractTakeover_RelatedVersion FOREIGN KEY (related_contract_version_id) REFERENCES ContractVersion(contract_version_id);

ALTER TABLE ContractType
    ADD CONSTRAINT FK_ContractType_ContractDomain FOREIGN KEY (contract_domain_code) REFERENCES ContractDomain(contract_domain_code);

-- Additional Contract domain constraints: Unique constraints
ALTER TABLE ContractVersion
    ADD CONSTRAINT UQ_ContractVersion_PerContract UNIQUE (contract_id, version_no);

GO

-- =============================================================
-- Coverage Domain Constraints
-- =============================================================
ALTER TABLE coverage_domain
    ADD CONSTRAINT FK_CoverageDomain_Coverage FOREIGN KEY (coverage_code) REFERENCES lookup_coverage(coverage_code),
    ADD CONSTRAINT FK_CoverageDomain_ContractDomain FOREIGN KEY (contract_domain_code) REFERENCES ContractDomain(contract_domain_code);

GO

-- =============================================================
-- Claim Domain Constraints
-- =============================================================
ALTER TABLE Claim
    ADD CONSTRAINT FK_Claim_Contract FOREIGN KEY (contract_id) REFERENCES Contract(contract_id),
    ADD CONSTRAINT FK_Claim_Coverage FOREIGN KEY (coverage_code) REFERENCES lookup_coverage(coverage_code),
    ADD CONSTRAINT FK_Claim_Status FOREIGN KEY (claim_status_code) REFERENCES ClaimStatus(claim_status_code),
    ADD CONSTRAINT FK_Claim_HandlerPerson FOREIGN KEY (claims_handler_id) REFERENCES Person(person_id),
    ADD CONSTRAINT FK_Claim_PaymentMethod FOREIGN KEY (payment_method_code) REFERENCES ClaimPaymentMethod(payment_method_code);

ALTER TABLE Claim_Party
    ADD CONSTRAINT FK_ClaimParty_Claim FOREIGN KEY (claim_id) REFERENCES Claim(claim_id),
    ADD CONSTRAINT FK_ClaimParty_Person FOREIGN KEY (person_id) REFERENCES Person(person_id),
    ADD CONSTRAINT FK_ClaimParty_Role FOREIGN KEY (claim_party_role_code) REFERENCES ClaimPartyRole(claim_party_role_code);

ALTER TABLE Claim_Object
    ADD CONSTRAINT FK_ClaimObject_Claim FOREIGN KEY (claim_id) REFERENCES Claim(claim_id),
    ADD CONSTRAINT FK_ClaimObject_Object FOREIGN KEY (object_id) REFERENCES Object(object_id);

ALTER TABLE Claim_Circumstance
    ADD CONSTRAINT FK_ClaimCircumstance_Claim FOREIGN KEY (claim_id) REFERENCES Claim(claim_id),
    ADD CONSTRAINT FK_ClaimCircumstance_CircumstanceType FOREIGN KEY (claim_circumstance_type_code) REFERENCES ClaimCircumstanceType(claim_circumstance_type_code);

-- Additional Claim domain constraints: Check constraints
ALTER TABLE Claim
    ADD CONSTRAINT CK_Claim_ClosedStatusDate CHECK (
        (closed_date IS NULL OR claim_status_code = 'CLOSED')
        AND (claim_status_code <> 'CLOSED' OR closed_date IS NOT NULL)
    ),
    ADD CONSTRAINT CK_Claim_PaymentMethod CHECK (
        NOT (paid_amount > 0 AND payment_method_code IS NULL)
    );

GO


PRINT '';
PRINT '======================================================';
PRINT ' Constraints applied successfully!';
PRINT '======================================================';
GO
