SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [YafesPars];
GO

PRINT 'Running optional migration: 018__seed_demo_data.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @TenantId UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000000001';
    DECLARE @UserAdmin UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000000101';
    DECLARE @UserBroker UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000000102';
    DECLARE @UserClaim UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000000103';
    DECLARE @Person1 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000001001';
    DECLARE @Person2 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000001002';
    DECLARE @Person3 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000001003';
    DECLARE @Person4 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000001004';
    DECLARE @Person5 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000001005';
    DECLARE @Legal1 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000001101';
    DECLARE @Legal2 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000001102';
    DECLARE @Inst1 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000002001';
    DECLARE @Inst2 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000002002';
    DECLARE @Inst3 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000002003';
    DECLARE @Vehicle1 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000003001';
    DECLARE @Vehicle2 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000003002';
    DECLARE @Vehicle3 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000003003';
    DECLARE @Estate1 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000003101';
    DECLARE @Estate2 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000003102';
    DECLARE @Contract1 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000004001';
    DECLARE @Contract2 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000004002';
    DECLARE @Contract3 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000004003';
    DECLARE @Contract4 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000004004';
    DECLARE @Version1 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000004101';
    DECLARE @Version2 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000004102';
    DECLARE @Claim1 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000005001';
    DECLARE @Claim2 UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000005002';

    IF NOT EXISTS (SELECT 1 FROM core.Tenant WHERE tenant_id = @TenantId)
    BEGIN
        INSERT INTO core.Tenant (
            tenant_id,
            tenant_code,
            legal_name,
            display_name,
            vat_number,
            country_code,
            default_language
        )
        VALUES (
            @TenantId,
            N'DEMO-BE-BROKER',
            N'Yafes Demo Broker BV',
            N'Yafes Demo Broker',
            N'BE0123456789',
            'BE',
            'nl'
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM person.Person WHERE person_id = @Person1)
        INSERT INTO person.Person (person_id, tenant_id, person_kind, dossier, language_code, nationality)
        VALUES (@Person1, @TenantId, N'NATURAL', N'DEMO-P-001', 'nl', N'Belgian');
    IF NOT EXISTS (SELECT 1 FROM person.NaturalPerson WHERE person_id = @Person1)
        INSERT INTO person.NaturalPerson (person_id, first_name, last_name, birth_date, title_code)
        VALUES (@Person1, N'Jan', N'Peeters', '1982-04-12', N'MR');

    IF NOT EXISTS (SELECT 1 FROM person.Person WHERE person_id = @Person2)
        INSERT INTO person.Person (person_id, tenant_id, person_kind, dossier, language_code, nationality)
        VALUES (@Person2, @TenantId, N'NATURAL', N'DEMO-P-002', 'fr', N'Belgian');
    IF NOT EXISTS (SELECT 1 FROM person.NaturalPerson WHERE person_id = @Person2)
        INSERT INTO person.NaturalPerson (person_id, first_name, last_name, birth_date, title_code)
        VALUES (@Person2, N'Marie', N'Dubois', '1976-08-21', N'MRS');

    IF NOT EXISTS (SELECT 1 FROM person.Person WHERE person_id = @Person3)
        INSERT INTO person.Person (person_id, tenant_id, person_kind, dossier, language_code, nationality)
        VALUES (@Person3, @TenantId, N'NATURAL', N'DEMO-P-003', 'nl', N'Belgian');
    IF NOT EXISTS (SELECT 1 FROM person.NaturalPerson WHERE person_id = @Person3)
        INSERT INTO person.NaturalPerson (person_id, first_name, last_name, birth_date, title_code)
        VALUES (@Person3, N'Anke', N'Janssens', '1990-01-08', N'MRS');

    IF NOT EXISTS (SELECT 1 FROM person.Person WHERE person_id = @Person4)
        INSERT INTO person.Person (person_id, tenant_id, person_kind, dossier, language_code, nationality)
        VALUES (@Person4, @TenantId, N'NATURAL', N'DEMO-P-004', 'fr', N'Belgian');
    IF NOT EXISTS (SELECT 1 FROM person.NaturalPerson WHERE person_id = @Person4)
        INSERT INTO person.NaturalPerson (person_id, first_name, last_name, birth_date, title_code)
        VALUES (@Person4, N'Luc', N'Martin', '1969-11-03', N'MR');

    IF NOT EXISTS (SELECT 1 FROM person.Person WHERE person_id = @Person5)
        INSERT INTO person.Person (person_id, tenant_id, person_kind, dossier, language_code, nationality)
        VALUES (@Person5, @TenantId, N'NATURAL', N'DEMO-P-005', 'nl', N'Belgian');
    IF NOT EXISTS (SELECT 1 FROM person.NaturalPerson WHERE person_id = @Person5)
        INSERT INTO person.NaturalPerson (person_id, first_name, last_name, birth_date, title_code)
        VALUES (@Person5, N'Sofie', N'Vermeulen', '1987-06-19', N'MRS');

    IF NOT EXISTS (SELECT 1 FROM person.Person WHERE person_id = @Legal1)
        INSERT INTO person.Person (person_id, tenant_id, person_kind, dossier, language_code, nationality)
        VALUES (@Legal1, @TenantId, N'LEGAL', N'DEMO-L-001', 'nl', N'Belgian');
    IF NOT EXISTS (SELECT 1 FROM person.LegalPerson WHERE person_id = @Legal1)
        INSERT INTO person.LegalPerson (person_id, incorporation_date, legal_form)
        VALUES (@Legal1, '2014-02-01', N'BV');

    IF NOT EXISTS (SELECT 1 FROM person.Person WHERE person_id = @Legal2)
        INSERT INTO person.Person (person_id, tenant_id, person_kind, dossier, language_code, nationality)
        VALUES (@Legal2, @TenantId, N'LEGAL', N'DEMO-L-002', 'fr', N'Belgian');
    IF NOT EXISTS (SELECT 1 FROM person.LegalPerson WHERE person_id = @Legal2)
        INSERT INTO person.LegalPerson (person_id, incorporation_date, legal_form)
        VALUES (@Legal2, '2019-09-15', N'SRL');

    IF NOT EXISTS (SELECT 1 FROM core.AppUser WHERE user_id = @UserAdmin)
        INSERT INTO core.AppUser (user_id, tenant_id, email, display_name, person_id)
        VALUES (@UserAdmin, @TenantId, N'admin@yafes-demo.be', N'Demo Admin', @Person1);
    IF NOT EXISTS (SELECT 1 FROM core.AppUser WHERE user_id = @UserBroker)
        INSERT INTO core.AppUser (user_id, tenant_id, email, display_name, person_id)
        VALUES (@UserBroker, @TenantId, N'broker@yafes-demo.be', N'Demo Broker', @Person3);
    IF NOT EXISTS (SELECT 1 FROM core.AppUser WHERE user_id = @UserClaim)
        INSERT INTO core.AppUser (user_id, tenant_id, email, display_name, person_id)
        VALUES (@UserClaim, @TenantId, N'claims@yafes-demo.be', N'Demo Claim Handler', @Person5);

    INSERT INTO core.UserRole (user_id, role_id)
    SELECT @UserAdmin, r.role_id
    FROM core.Role r
    WHERE r.tenant_id IS NULL
      AND r.role_code = N'BROKER_ADMIN'
      AND NOT EXISTS (
        SELECT 1
        FROM core.UserRole ur
        WHERE ur.user_id = @UserAdmin
          AND ur.role_id = r.role_id
      );

    INSERT INTO core.UserRole (user_id, role_id)
    SELECT @UserBroker, r.role_id
    FROM core.Role r
    WHERE r.tenant_id IS NULL
      AND r.role_code = N'BROKER_USER'
      AND NOT EXISTS (
        SELECT 1
        FROM core.UserRole ur
        WHERE ur.user_id = @UserBroker
          AND ur.role_id = r.role_id
      );

    INSERT INTO core.UserRole (user_id, role_id)
    SELECT @UserClaim, r.role_id
    FROM core.Role r
    WHERE r.tenant_id IS NULL
      AND r.role_code = N'CLAIM_HANDLER'
      AND NOT EXISTS (
        SELECT 1
        FROM core.UserRole ur
        WHERE ur.user_id = @UserClaim
          AND ur.role_id = r.role_id
      );

    IF NOT EXISTS (SELECT 1 FROM institution.Institution WHERE institution_id = @Inst1)
        INSERT INTO institution.Institution (institution_id, tenant_id, institution_code, name, legal_name, vat_number, created_by_user_id)
        VALUES (@Inst1, @TenantId, N'AG-BE', N'AG Insurance', N'AG Insurance NV', N'BE0404494849', @UserAdmin);
    IF NOT EXISTS (SELECT 1 FROM institution.Institution WHERE institution_id = @Inst2)
        INSERT INTO institution.Institution (institution_id, tenant_id, institution_code, name, legal_name, vat_number, created_by_user_id)
        VALUES (@Inst2, @TenantId, N'KBC-BE', N'KBC Bank', N'KBC Bank NV', N'BE0462920226', @UserAdmin);
    IF NOT EXISTS (SELECT 1 FROM institution.Institution WHERE institution_id = @Inst3)
        INSERT INTO institution.Institution (institution_id, tenant_id, institution_code, name, legal_name, vat_number, created_by_user_id)
        VALUES (@Inst3, @TenantId, N'ETHIAS-BE', N'Ethias', N'Ethias NV', N'BE0404485063', @UserAdmin);

    IF NOT EXISTS (SELECT 1 FROM risk.InsurableObject WHERE insurable_object_id = @Vehicle1)
        INSERT INTO risk.InsurableObject (insurable_object_id, tenant_id, object_type_code, description, status_code, start_date, created_by_user_id)
        VALUES (@Vehicle1, @TenantId, N'VEHICLE', N'Volkswagen Golf', N'ACTIVE', '2025-01-01', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM risk.InsurableVehicle WHERE insurable_object_id = @Vehicle1)
        INSERT INTO risk.InsurableVehicle (insurable_object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code)
        VALUES (@Vehicle1, N'CAR', N'PRIVATE', N'NORMAL', N'Volkswagen', N'Golf', N'WVWZZZ1KZ9W000001', 2022, '2022-02-01', '2022-02-12', N'1ABC123', N'PETROL', N'FWD');

    IF NOT EXISTS (SELECT 1 FROM risk.InsurableObject WHERE insurable_object_id = @Vehicle2)
        INSERT INTO risk.InsurableObject (insurable_object_id, tenant_id, object_type_code, description, status_code, start_date, created_by_user_id)
        VALUES (@Vehicle2, @TenantId, N'VEHICLE', N'Tesla Model 3', N'ACTIVE', '2025-01-01', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM risk.InsurableVehicle WHERE insurable_object_id = @Vehicle2)
        INSERT INTO risk.InsurableVehicle (insurable_object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code)
        VALUES (@Vehicle2, N'CAR', N'PRIVATE', N'NORMAL', N'Tesla', N'Model 3', N'5YJ3E7EBXJF000002', 2023, '2023-03-10', '2023-03-20', N'2XYZ456', N'ELECTRIC', N'AWD');

    IF NOT EXISTS (SELECT 1 FROM risk.InsurableObject WHERE insurable_object_id = @Vehicle3)
        INSERT INTO risk.InsurableObject (insurable_object_id, tenant_id, object_type_code, description, status_code, start_date, created_by_user_id)
        VALUES (@Vehicle3, @TenantId, N'VEHICLE', N'Ford Transit', N'ACTIVE', '2025-01-01', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM risk.InsurableVehicle WHERE insurable_object_id = @Vehicle3)
        INSERT INTO risk.InsurableVehicle (insurable_object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code)
        VALUES (@Vehicle3, N'VAN', N'PROFESSIONAL', N'NORMAL', N'Ford', N'Transit', N'WF0XXXTTGXK000003', 2021, '2021-05-12', '2021-05-20', N'3BUS789', N'DIESEL', N'RWD');

    IF NOT EXISTS (SELECT 1 FROM risk.InsurableObject WHERE insurable_object_id = @Estate1)
        INSERT INTO risk.InsurableObject (insurable_object_id, tenant_id, object_type_code, description, status_code, start_date, created_by_user_id)
        VALUES (@Estate1, @TenantId, N'REAL_ESTATE', N'Family home Antwerp', N'ACTIVE', '2025-01-01', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM risk.InsurableRealEstate WHERE insurable_object_id = @Estate1)
        INSERT INTO risk.InsurableRealEstate (insurable_object_id, realestate_type_code, use_type_code, insured_role_code, street, number, postal_code, city, build_year, capital_building)
        VALUES (@Estate1, N'HOUSE', N'PRIVATE', N'OWNER', N'Mechelsesteenweg', N'120', N'2018', N'Antwerpen', 1998, 350000.00);

    IF NOT EXISTS (SELECT 1 FROM risk.InsurableObject WHERE insurable_object_id = @Estate2)
        INSERT INTO risk.InsurableObject (insurable_object_id, tenant_id, object_type_code, description, status_code, start_date, created_by_user_id)
        VALUES (@Estate2, @TenantId, N'REAL_ESTATE', N'Apartment Brussels', N'ACTIVE', '2025-01-01', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM risk.InsurableRealEstate WHERE insurable_object_id = @Estate2)
        INSERT INTO risk.InsurableRealEstate (insurable_object_id, realestate_type_code, use_type_code, insured_role_code, street, number, postal_code, city, build_year, capital_building)
        VALUES (@Estate2, N'APARTMENT', N'PRIVATE', N'OWNER', N'Avenue Louise', N'250', N'1050', N'Brussels', 2008, 280000.00);

    IF NOT EXISTS (SELECT 1 FROM policy.Contract WHERE contract_id = @Contract1)
        INSERT INTO policy.Contract (contract_id, tenant_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, start_date, created_by_user_id)
        VALUES (@Contract1, @TenantId, N'POL-2026-0001', N'MOTOR', N'AUTO_BA', N'ACTIVE', @Inst1, '2026-01-01', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM policy.Contract WHERE contract_id = @Contract2)
        INSERT INTO policy.Contract (contract_id, tenant_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, start_date, created_by_user_id)
        VALUES (@Contract2, @TenantId, N'POL-2026-0002', N'MOTOR', N'AUTO_BA', N'ACTIVE', @Inst3, '2026-02-01', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM policy.Contract WHERE contract_id = @Contract3)
        INSERT INTO policy.Contract (contract_id, tenant_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, start_date, created_by_user_id)
        VALUES (@Contract3, @TenantId, N'POL-2026-0003', N'FIRE', N'FIRE_HOME', N'ACTIVE', @Inst1, '2026-03-01', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM policy.Contract WHERE contract_id = @Contract4)
        INSERT INTO policy.Contract (contract_id, tenant_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, start_date, created_by_user_id)
        VALUES (@Contract4, @TenantId, N'POL-2026-0004', N'FAMILY', N'FAMILY_RC', N'QUOTE', @Inst3, '2026-04-01', @UserBroker);

    IF NOT EXISTS (SELECT 1 FROM policy.ContractVersion WHERE contract_version_id = @Version1)
        INSERT INTO policy.ContractVersion (contract_version_id, contract_id, version_no, effective_from, contract_version_status_code, duration_type_code, periodicity_code, collection_method_code, created_by_user_id)
        VALUES (@Version1, @Contract1, 1, '2026-01-01', N'ACTIVE', N'INDEFINITE', N'YEARLY', N'DIRECT_DEBIT', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM policy.ContractVersion WHERE contract_version_id = @Version2)
        INSERT INTO policy.ContractVersion (contract_version_id, contract_id, version_no, effective_from, contract_version_status_code, duration_type_code, periodicity_code, collection_method_code, created_by_user_id)
        VALUES (@Version2, @Contract3, 1, '2026-03-01', N'ACTIVE', N'INDEFINITE', N'YEARLY', N'BANK_TRANSFER', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM policy.ContractVersion WHERE contract_version_id = '10000000-0000-0000-0000-000000004103')
        INSERT INTO policy.ContractVersion (contract_version_id, contract_id, version_no, effective_from, contract_version_status_code, duration_type_code, periodicity_code, collection_method_code, created_by_user_id)
        VALUES ('10000000-0000-0000-0000-000000004103', @Contract2, 1, '2026-02-01', N'ACTIVE', N'INDEFINITE', N'YEARLY', N'DIRECT_DEBIT', @UserBroker);

    IF NOT EXISTS (SELECT 1 FROM policy.ContractParty WHERE contract_id = @Contract1 AND person_id = @Person1 AND contract_party_role_code = N'POLICYHOLDER')
        INSERT INTO policy.ContractParty (contract_id, person_id, contract_party_role_code, is_primary)
        VALUES (@Contract1, @Person1, N'POLICYHOLDER', 1);
    IF NOT EXISTS (SELECT 1 FROM policy.ContractObject WHERE contract_id = @Contract1 AND insurable_object_id = @Vehicle1)
        INSERT INTO policy.ContractObject (contract_id, insurable_object_id, contract_object_status_code, is_primary)
        VALUES (@Contract1, @Vehicle1, N'ACTIVE', 1);
    IF NOT EXISTS (SELECT 1 FROM policy.ContractParty WHERE contract_id = @Contract2 AND person_id = @Person3 AND contract_party_role_code = N'POLICYHOLDER')
        INSERT INTO policy.ContractParty (contract_id, person_id, contract_party_role_code, is_primary)
        VALUES (@Contract2, @Person3, N'POLICYHOLDER', 1);
    IF NOT EXISTS (SELECT 1 FROM policy.ContractObject WHERE contract_id = @Contract2 AND insurable_object_id = @Vehicle2)
        INSERT INTO policy.ContractObject (contract_id, insurable_object_id, contract_object_status_code, is_primary)
        VALUES (@Contract2, @Vehicle2, N'ACTIVE', 1);
    IF NOT EXISTS (SELECT 1 FROM policy.ContractParty WHERE contract_id = @Contract3 AND person_id = @Person2 AND contract_party_role_code = N'POLICYHOLDER')
        INSERT INTO policy.ContractParty (contract_id, person_id, contract_party_role_code, is_primary)
        VALUES (@Contract3, @Person2, N'POLICYHOLDER', 1);
    IF NOT EXISTS (SELECT 1 FROM policy.ContractObject WHERE contract_id = @Contract3 AND insurable_object_id = @Estate1)
        INSERT INTO policy.ContractObject (contract_id, insurable_object_id, contract_object_status_code, is_primary)
        VALUES (@Contract3, @Estate1, N'ACTIVE', 1);

    IF NOT EXISTS (SELECT 1 FROM claim.Claim WHERE claim_id = @Claim1)
        INSERT INTO claim.Claim (claim_id, tenant_id, claim_number, contract_id, coverage_code, claim_status_code, claims_handler_id, incident_date, reported_date, description, reserved_amount, created_by_user_id)
        VALUES (@Claim1, @TenantId, N'CLM-2026-0001', @Contract1, N'AUTO_LIABILITY', N'OPEN', @Person5, '2026-05-10', '2026-05-11', N'Minor parking accident.', 1500.00, @UserClaim);
    IF NOT EXISTS (SELECT 1 FROM claim.Claim WHERE claim_id = @Claim2)
        INSERT INTO claim.Claim (claim_id, tenant_id, claim_number, contract_id, coverage_code, claim_status_code, claims_handler_id, incident_date, reported_date, closed_date, description, paid_amount, reserved_amount, payment_method_code, created_by_user_id)
        VALUES (@Claim2, @TenantId, N'CLM-2026-0002', @Contract3, N'FIRE_BUILDING', N'CLOSED', @Person5, '2026-04-01', '2026-04-02', '2026-04-20', N'Water damage in kitchen.', 2400.00, 0.00, N'BANK_TRANSFER', @UserClaim);

    IF NOT EXISTS (SELECT 1 FROM tasking.Task WHERE task_id = '10000000-0000-0000-0000-000000006001')
        INSERT INTO tasking.Task (task_id, tenant_id, title, related_entity_type, related_entity_id, assigned_to_user_id, created_by_user_id, task_priority_code, task_status_code, due_at_utc)
        VALUES ('10000000-0000-0000-0000-000000006001', @TenantId, N'Renew policy POL-2026-0001', N'POLICY', @Contract1, @UserBroker, @UserAdmin, N'HIGH', N'OPEN', '2026-12-01T09:00:00');
    IF NOT EXISTS (SELECT 1 FROM tasking.Task WHERE task_id = '10000000-0000-0000-0000-000000006002')
        INSERT INTO tasking.Task (task_id, tenant_id, title, related_entity_type, related_entity_id, assigned_to_user_id, created_by_user_id, task_priority_code, task_status_code, due_at_utc)
        VALUES ('10000000-0000-0000-0000-000000006002', @TenantId, N'Follow up claim CLM-2026-0001', N'CLAIM', @Claim1, @UserClaim, @UserAdmin, N'NORMAL', N'IN_PROGRESS', '2026-06-15T10:00:00');
    IF NOT EXISTS (SELECT 1 FROM tasking.Task WHERE task_id = '10000000-0000-0000-0000-000000006003')
        INSERT INTO tasking.Task (task_id, tenant_id, title, related_entity_type, related_entity_id, assigned_to_user_id, created_by_user_id, task_priority_code, task_status_code, due_at_utc)
        VALUES ('10000000-0000-0000-0000-000000006003', @TenantId, N'Collect signed mandate', N'PERSON', @Person2, @UserBroker, @UserAdmin, N'NORMAL', N'OPEN', '2026-06-20T12:00:00');
    IF NOT EXISTS (SELECT 1 FROM tasking.Task WHERE task_id = '10000000-0000-0000-0000-000000006004')
        INSERT INTO tasking.Task (task_id, tenant_id, title, related_entity_type, related_entity_id, assigned_to_user_id, created_by_user_id, task_priority_code, task_status_code, due_at_utc)
        VALUES ('10000000-0000-0000-0000-000000006004', @TenantId, N'Verify vehicle plate', N'RISK_OBJECT', @Vehicle3, @UserBroker, @UserAdmin, N'LOW', N'OPEN', '2026-06-25T09:00:00');
    IF NOT EXISTS (SELECT 1 FROM tasking.Task WHERE task_id = '10000000-0000-0000-0000-000000006005')
        INSERT INTO tasking.Task (task_id, tenant_id, title, related_entity_type, related_entity_id, assigned_to_user_id, created_by_user_id, task_priority_code, task_status_code, due_at_utc)
        VALUES ('10000000-0000-0000-0000-000000006005', @TenantId, N'Review quote POL-2026-0004', N'POLICY', @Contract4, @UserBroker, @UserAdmin, N'NORMAL', N'WAITING', '2026-07-01T14:00:00');

    IF NOT EXISTS (SELECT 1 FROM document.Document WHERE document_id = '10000000-0000-0000-0000-000000007001')
        INSERT INTO document.Document (document_id, tenant_id, owner_entity_type, owner_entity_id, document_type_code, file_name, file_extension, mime_type, file_size_bytes, storage_provider, storage_key, uploaded_by_user_id)
        VALUES ('10000000-0000-0000-0000-000000007001', @TenantId, N'PERSON', @Person1, N'ID_CARD', N'jan-peeters-id.pdf', N'.pdf', N'application/pdf', 125000, N'demo', N'demo/person/jan-peeters-id.pdf', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM document.Document WHERE document_id = '10000000-0000-0000-0000-000000007002')
        INSERT INTO document.Document (document_id, tenant_id, owner_entity_type, owner_entity_id, document_type_code, file_name, file_extension, mime_type, file_size_bytes, storage_provider, storage_key, uploaded_by_user_id)
        VALUES ('10000000-0000-0000-0000-000000007002', @TenantId, N'POLICY', @Contract1, N'POLICY_DOCUMENT', N'POL-2026-0001.pdf', N'.pdf', N'application/pdf', 245000, N'demo', N'demo/policy/POL-2026-0001.pdf', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM document.Document WHERE document_id = '10000000-0000-0000-0000-000000007003')
        INSERT INTO document.Document (document_id, tenant_id, owner_entity_type, owner_entity_id, document_type_code, file_name, file_extension, mime_type, file_size_bytes, storage_provider, storage_key, uploaded_by_user_id)
        VALUES ('10000000-0000-0000-0000-000000007003', @TenantId, N'CLAIM', @Claim1, N'CLAIM_REPORT', N'CLM-2026-0001-report.pdf', N'.pdf', N'application/pdf', 180000, N'demo', N'demo/claim/CLM-2026-0001-report.pdf', @UserClaim);
    IF NOT EXISTS (SELECT 1 FROM document.Document WHERE document_id = '10000000-0000-0000-0000-000000007004')
        INSERT INTO document.Document (document_id, tenant_id, owner_entity_type, owner_entity_id, document_type_code, file_name, file_extension, mime_type, file_size_bytes, storage_provider, storage_key, uploaded_by_user_id)
        VALUES ('10000000-0000-0000-0000-000000007004', @TenantId, N'RISK_OBJECT', @Vehicle1, N'GREEN_CARD', N'green-card-1ABC123.pdf', N'.pdf', N'application/pdf', 97000, N'demo', N'demo/risk/green-card-1ABC123.pdf', @UserBroker);
    IF NOT EXISTS (SELECT 1 FROM document.Document WHERE document_id = '10000000-0000-0000-0000-000000007005')
        INSERT INTO document.Document (document_id, tenant_id, owner_entity_type, owner_entity_id, document_type_code, file_name, file_extension, mime_type, file_size_bytes, storage_provider, storage_key, uploaded_by_user_id)
        VALUES ('10000000-0000-0000-0000-000000007005', @TenantId, N'INSTITUTION', @Inst1, N'SIGNED_CONTRACT', N'ag-broker-agreement.pdf', N'.pdf', N'application/pdf', 310000, N'demo', N'demo/institution/ag-broker-agreement.pdf', @UserAdmin);

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'018__seed_demo_data.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'018__seed_demo_data.sql',
            N'SUCCESS'
        );
    END;

    COMMIT TRANSACTION;
    PRINT 'Optional demo data migration completed successfully.';
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
