SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [YafesPars];
GO

PRINT 'Running migration: 017__seed_lookup_data.sql';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    MERGE ref.Language AS target
    USING (VALUES
        ('nl', N'Nederlands', N'Neerlandais', N'Dutch', N'Felemenkce', 10),
        ('fr', N'Frans', N'Francais', N'French', N'Fransizca', 20),
        ('en', N'Engels', N'Anglais', N'English', N'Ingilizce', 30),
        ('tr', N'Turks', N'Turc', N'Turkish', N'Turkce', 40)
    ) AS source (language_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.language_code = source.language_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (language_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.language_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE ref.Title AS target
    USING (VALUES
        (N'MR', N'Mijnheer', N'Monsieur', N'Mr', N'Bay', 10),
        (N'MRS', N'Mevrouw', N'Madame', N'Mrs', N'Bayan', 20)
    ) AS source (title_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.title_code = source.title_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (title_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.title_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE ref.PhoneType AS target
    USING (VALUES
        (N'MOBILE', N'Mobiel', N'Mobile', N'Mobile', N'Cep', 10),
        (N'LANDLINE', N'Vast', N'Fixe', N'Landline', N'Sabit', 20),
        (N'FAX', N'Fax', N'Fax', N'Fax', N'Faks', 30),
        (N'OTHER', N'Overige', N'Autre', N'Other', N'Diger', 40)
    ) AS source (phone_type_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.phone_type_code = source.phone_type_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (phone_type_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.phone_type_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE ref.SocialType AS target
    USING (VALUES
        (N'LINKEDIN', N'LinkedIn', N'LinkedIn', N'LinkedIn', N'LinkedIn', 10),
        (N'FACEBOOK', N'Facebook', N'Facebook', N'Facebook', N'Facebook', 20),
        (N'INSTAGRAM', N'Instagram', N'Instagram', N'Instagram', N'Instagram', 30),
        (N'OTHER', N'Overige', N'Autre', N'Other', N'Diger', 40)
    ) AS source (social_type_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.social_type_code = source.social_type_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (social_type_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.social_type_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE ref.ProfessionalStatus AS target
    USING (VALUES
        (N'EMPLOYEE', N'Bediende', N'Employe', N'Employee', N'Calisan', 10),
        (N'WORKER', N'Arbeider', N'Ouvrier', N'Worker', N'Isci', 20),
        (N'SELF_EMPLOYED', N'Zelfstandige', N'Independant', N'Self-employed', N'Serbest', 30),
        (N'RETIRED', N'Gepensioneerd', N'Retraite', N'Retired', N'Emekli', 40),
        (N'STUDENT', N'Student', N'Etudiant', N'Student', N'Ogrenci', 50)
    ) AS source (professional_status_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.professional_status_code = source.professional_status_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (professional_status_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.professional_status_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE ref.PersonType AS target
    USING (VALUES
        (N'CUSTOMER', N'Klant', N'Client', N'Customer', N'Musteri', 10),
        (N'PROSPECT', N'Prospect', N'Prospect', N'Prospect', N'Aday', 20),
        (N'SUBAGENT', N'Subagent', N'Sous-agent', N'Subagent', N'Alt acente', 30)
    ) AS source (person_type_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.person_type_code = source.person_type_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (person_type_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.person_type_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE person.PersonAddressRole AS target
    USING (VALUES
        (N'HOME', N'Thuis', N'Domicile', N'Home', N'Ev', 10),
        (N'POSTAL', N'Postadres', N'Adresse postale', N'Postal', N'Posta', 20),
        (N'BILLING', N'Facturatie', N'Facturation', N'Billing', N'Fatura', 30)
    ) AS source (address_role_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.address_role_code = source.address_role_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (address_role_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.address_role_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE person.PersonRelationType AS target
    USING (VALUES
        (N'SPOUSE', N'FAMILY', N'Echtgenoot', N'Conjoint', N'Spouse', N'Es', 10),
        (N'CHILD', N'FAMILY', N'Kind', N'Enfant', N'Child', N'Cocuk', 20),
        (N'EMPLOYER', N'BUSINESS', N'Werkgever', N'Employeur', N'Employer', N'Isveren', 30)
    ) AS source (relation_type_code, relation_category, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.relation_type_code = source.relation_type_code
    WHEN MATCHED THEN
        UPDATE SET relation_category = source.relation_category, label_nl = source.label_nl,
            label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr,
            sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (relation_type_code, relation_category, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.relation_type_code, source.relation_category, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE institution.InstitutionRole AS target
    USING (VALUES
        (N'INSURER', N'Verzekeraar', N'Assureur', N'Insurer', N'Sigortaci', 10),
        (N'BROKER', N'Makelaar', N'Courtier', N'Broker', N'Broker', 20),
        (N'BANK', N'Bank', N'Banque', N'Bank', N'Banka', 30),
        (N'LEASING', N'Leasing', N'Leasing', N'Leasing', N'Leasing', 40)
    ) AS source (institution_role_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.institution_role_code = source.institution_role_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (institution_role_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.institution_role_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE institution.InstitutionIdentifierType AS target
    USING (VALUES
        (N'KBO', N'KBO nummer', N'Numero BCE', N'KBO number', N'KBO no', 10),
        (N'VAT', N'BTW nummer', N'Numero TVA', N'VAT number', N'KDV no', 20),
        (N'FSMA', N'FSMA nummer', N'Numero FSMA', N'FSMA number', N'FSMA no', 30)
    ) AS source (id_type_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.id_type_code = source.id_type_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (id_type_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.id_type_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE institution.InstitutionAddressRole AS target
    USING (VALUES
        (N'HEAD_OFFICE', N'Hoofdzetel', N'Siege social', N'Head office', N'Merkez', 10),
        (N'POSTAL', N'Postadres', N'Adresse postale', N'Postal', N'Posta', 20),
        (N'BILLING', N'Facturatie', N'Facturation', N'Billing', N'Fatura', 30)
    ) AS source (address_role_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.address_role_code = source.address_role_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (address_role_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.address_role_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE risk.InsurableObjectType AS target
    USING (VALUES
        (N'VEHICLE', N'Voertuig', N'Vehicule', N'Vehicle', N'Arac', 10),
        (N'REAL_ESTATE', N'Onroerend goed', N'Immobilier', N'Real estate', N'Gayrimenkul', 20),
        (N'LOAN', N'Lening', N'Pret', N'Loan', N'Kredi', 30),
        (N'PERSON', N'Persoon', N'Personne', N'Person', N'Kisi', 40),
        (N'THING', N'Zaak', N'Objet', N'Thing', N'Esya', 50),
        (N'ACTIVITY', N'Activiteit', N'Activite', N'Activity', N'Etkinlik', 60)
    ) AS source (object_type_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.object_type_code = source.object_type_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (object_type_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.object_type_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE risk.VehicleType AS target
    USING (VALUES
        (N'CAR', N'Personenwagen', N'Voiture', 10),
        (N'VAN', N'Bestelwagen', N'Camionnette', 20),
        (N'MOTORCYCLE', N'Motorfiets', N'Moto', 30)
    ) AS source (vehicle_type_code, label_nl, label_fr, sort_order)
    ON target.vehicle_type_code = source.vehicle_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (vehicle_type_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.vehicle_type_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.UsageType AS target
    USING (VALUES
        (N'PRIVATE', N'Prive', N'Prive', 10),
        (N'PROFESSIONAL', N'Professioneel', N'Professionnel', 20)
    ) AS source (usage_type_code, label_nl, label_fr, sort_order)
    ON target.usage_type_code = source.usage_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (usage_type_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.usage_type_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.FuelType AS target
    USING (VALUES
        (N'PETROL', N'Benzine', N'Essence', 10),
        (N'DIESEL', N'Diesel', N'Diesel', 20),
        (N'ELECTRIC', N'Elektrisch', N'Electrique', 30)
    ) AS source (fuel_type_code, label_nl, label_fr, sort_order)
    ON target.fuel_type_code = source.fuel_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (fuel_type_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.fuel_type_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.DriveType AS target
    USING (VALUES
        (N'FWD', N'Voorwielaandrijving', N'Traction', 10),
        (N'RWD', N'Achterwielaandrijving', N'Propulsion', 20),
        (N'AWD', N'Vierwielaandrijving', N'Integrale', 30)
    ) AS source (drive_type_code, label_nl, label_fr, sort_order)
    ON target.drive_type_code = source.drive_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (drive_type_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.drive_type_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.LicensePlateType AS target
    USING (VALUES
        (N'NORMAL', N'Normaal', N'Normal', 10),
        (N'TEMPORARY', N'Tijdelijk', N'Temporaire', 20)
    ) AS source (plate_type_code, label_nl, label_fr, sort_order)
    ON target.plate_type_code = source.plate_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (plate_type_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.plate_type_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.RealEstateType AS target
    USING (VALUES
        (N'HOUSE', N'Woning', N'Maison', 10),
        (N'APARTMENT', N'Appartement', N'Appartement', 20),
        (N'COMMERCIAL', N'Handelspand', N'Commercial', 30)
    ) AS source (realestate_type_code, label_nl, label_fr, sort_order)
    ON target.realestate_type_code = source.realestate_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (realestate_type_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.realestate_type_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.InsuredRole AS target
    USING (VALUES
        (N'OWNER', N'Eigenaar', N'Proprietaire', 10),
        (N'TENANT', N'Huurder', N'Locataire', 20)
    ) AS source (insured_role_code, label_nl, label_fr, sort_order)
    ON target.insured_role_code = source.insured_role_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (insured_role_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.insured_role_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.UseTypeRealEstate AS target
    USING (VALUES
        (N'PRIVATE', N'Prive gebruik', N'Usage prive', 10),
        (N'COMMERCIAL', N'Commercieel gebruik', N'Usage commercial', 20)
    ) AS source (use_type_code, label_nl, label_fr, sort_order)
    ON target.use_type_code = source.use_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (use_type_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.use_type_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE policy.ContractDomain AS target
    USING (VALUES
        (N'MOTOR', N'Motor', N'Auto', N'Motor', N'Trafik', 10),
        (N'FIRE', N'Brand', N'Incendie', N'Fire', N'Yangin', 20),
        (N'FAMILY', N'Familie', N'Famille', N'Family', N'Aile', 30),
        (N'LOAN', N'Lening', N'Pret', N'Loan', N'Kredi', 40),
        (N'GENERAL', N'Algemeen', N'General', N'General', N'Genel', 50)
    ) AS source (contract_domain_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.contract_domain_code = source.contract_domain_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (contract_domain_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.contract_domain_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE policy.ContractStatus AS target
    USING (VALUES
        (N'DRAFT', N'Concept', N'Brouillon', N'Draft', N'Taslak', 10),
        (N'QUOTE', N'Offerte', N'Offre', N'Quote', N'Teklif', 20),
        (N'ACTIVE', N'Actief', N'Actif', N'Active', N'Aktif', 30),
        (N'SUSPENDED', N'Geschorst', N'Suspendu', N'Suspended', N'Askida', 40),
        (N'CANCELLED', N'Geannuleerd', N'Annule', N'Cancelled', N'Iptal', 50),
        (N'EXPIRED', N'Verlopen', N'Expire', N'Expired', N'Suresi doldu', 60),
        (N'ARCHIVED', N'Gearchiveerd', N'Archive', N'Archived', N'Arsiv', 70)
    ) AS source (contract_status_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.contract_status_code = source.contract_status_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (contract_status_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.contract_status_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE policy.ContractVersionStatus AS target
    USING (VALUES
        (N'DRAFT', N'Concept', N'Brouillon', N'Draft', N'Taslak', 10),
        (N'PENDING_APPROVAL', N'Wacht op goedkeuring', N'En attente', N'Pending approval', N'Onay bekliyor', 20),
        (N'ACTIVE', N'Actief', N'Actif', N'Active', N'Aktif', 30),
        (N'SUPERSEDED', N'Vervangen', N'Remplace', N'Superseded', N'Degisti', 40),
        (N'CANCELLED', N'Geannuleerd', N'Annule', N'Cancelled', N'Iptal', 50)
    ) AS source (contract_version_status_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.contract_version_status_code = source.contract_version_status_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (contract_version_status_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.contract_version_status_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE policy.Periodicity AS target
    USING (VALUES
        (N'MONTHLY', N'Maandelijks', N'Mensuel', N'Monthly', N'Aylik', 10),
        (N'QUARTERLY', N'Driemaandelijks', N'Trimestriel', N'Quarterly', N'Uc aylik', 20),
        (N'YEARLY', N'Jaarlijks', N'Annuel', N'Yearly', N'Yillik', 30)
    ) AS source (periodicity_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.periodicity_code = source.periodicity_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (periodicity_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.periodicity_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE policy.CollectionMethod AS target
    USING (VALUES
        (N'DIRECT_DEBIT', N'Domiciliering', N'Domiciliation', N'Direct debit', N'Otomatik odeme', 10),
        (N'BANK_TRANSFER', N'Overschrijving', N'Virement', N'Bank transfer', N'Havale', 20)
    ) AS source (collection_method_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.collection_method_code = source.collection_method_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (collection_method_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.collection_method_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE policy.DurationType AS target
    USING (VALUES
        (N'FIXED', N'Vast', N'Fixe', N'Fixed', N'Sabit', 10),
        (N'INDEFINITE', N'Onbepaald', N'Indetermine', N'Indefinite', N'Suresiz', 20)
    ) AS source (duration_type_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.duration_type_code = source.duration_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (duration_type_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.duration_type_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE policy.ContractType AS target
    USING (VALUES
        (N'AUTO_BA', N'MOTOR', N'BA Auto', N'RC Auto', N'Motor liability', N'Trafik sorumluluk', 10),
        (N'FIRE_HOME', N'FIRE', N'Brand woning', N'Incendie habitation', N'Home fire', N'Konut yangin', 20),
        (N'FAMILY_RC', N'FAMILY', N'Familiale BA', N'RC familiale', N'Family liability', N'Aile sorumluluk', 30),
        (N'LOAN_PROTECTION', N'LOAN', N'Lening bescherming', N'Protection pret', N'Loan protection', N'Kredi koruma', 40)
    ) AS source (contract_type_code, contract_domain_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.contract_type_code = source.contract_type_code
    WHEN MATCHED THEN
        UPDATE SET contract_domain_code = source.contract_domain_code, label_nl = source.label_nl,
            label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr,
            sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (contract_type_code, contract_domain_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.contract_type_code, source.contract_domain_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE policy.ContractPartyRole AS target
    USING (VALUES
        (N'POLICYHOLDER', N'Verzekeringnemer', N'Preneur', N'Policyholder', N'Police sahibi', 10),
        (N'INSURED', N'Verzekerde', N'Assure', N'Insured', N'Sigortali', 20),
        (N'BENEFICIARY', N'Begunstigde', N'Beneficiaire', N'Beneficiary', N'Lehtar', 30)
    ) AS source (contract_party_role_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.contract_party_role_code = source.contract_party_role_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (contract_party_role_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.contract_party_role_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE policy.ContractObjectStatus AS target
    USING (VALUES
        (N'ACTIVE', N'Actief', N'Actif', N'Active', N'Aktif', 10),
        (N'REMOVED', N'Verwijderd', N'Supprime', N'Removed', N'Kaldirildi', 20)
    ) AS source (contract_object_status_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.contract_object_status_code = source.contract_object_status_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (contract_object_status_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.contract_object_status_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE policy.TakeoverDirection AS target
    USING (VALUES
        (N'IN', N'Inkomend', N'Entrant', 10),
        (N'OUT', N'Uitgaand', N'Sortant', 20)
    ) AS source (takeover_direction_code, label_nl, label_fr, sort_order)
    ON target.takeover_direction_code = source.takeover_direction_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (takeover_direction_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.takeover_direction_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE policy.TakeoverSourceType AS target
    USING (VALUES
        (N'EXTERNAL_COMPANY', N'Externe maatschappij', N'Compagnie externe', 10),
        (N'INTERNAL_POLICY', N'Interne polis', N'Police interne', 20)
    ) AS source (takeover_source_type_code, label_nl, label_fr, sort_order)
    ON target.takeover_source_type_code = source.takeover_source_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (takeover_source_type_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.takeover_source_type_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE claim.ClaimStatus AS target
    USING (VALUES
        (N'OPEN', N'Open', N'Ouvert', N'Open', N'Acik', 10),
        (N'IN_REVIEW', N'In onderzoek', N'En revue', N'In review', N'Incelemede', 20),
        (N'WAITING_DOCUMENTS', N'Wacht op documenten', N'Attente documents', N'Waiting documents', N'Belge bekliyor', 30),
        (N'APPROVED', N'Goedgekeurd', N'Approuve', N'Approved', N'Onaylandi', 40),
        (N'REJECTED', N'Afgewezen', N'Rejete', N'Rejected', N'Reddedildi', 50),
        (N'PAID', N'Betaald', N'Paye', N'Paid', N'Odendi', 60),
        (N'CLOSED', N'Gesloten', N'Ferme', N'Closed', N'Kapali', 70)
    ) AS source (claim_status_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.claim_status_code = source.claim_status_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (claim_status_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.claim_status_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE claim.ClaimPartyRole AS target
    USING (VALUES
        (N'CLAIMANT', N'Eiser', N'Demandeur', N'Claimant', N'Talep eden', 10),
        (N'INSURED', N'Verzekerde', N'Assure', N'Insured', N'Sigortali', 20),
        (N'THIRD_PARTY', N'Derde partij', N'Tiers', N'Third party', N'Ucuncu taraf', 30)
    ) AS source (claim_party_role_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.claim_party_role_code = source.claim_party_role_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (claim_party_role_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.claim_party_role_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE claim.ClaimCircumstanceType AS target
    USING (VALUES
        (N'ACCIDENT', N'Ongeval', N'Accident', N'Accident', N'Kaza', 10),
        (N'THEFT', N'Diefstal', N'Vol', N'Theft', N'Hirsizlik', 20),
        (N'FIRE', N'Brand', N'Incendie', N'Fire', N'Yangin', 30),
        (N'WATER_DAMAGE', N'Waterschade', N'Degats des eaux', N'Water damage', N'Su hasari', 40)
    ) AS source (claim_circumstance_type_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.claim_circumstance_type_code = source.claim_circumstance_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (claim_circumstance_type_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.claim_circumstance_type_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE claim.ClaimPaymentMethod AS target
    USING (VALUES
        (N'BANK_TRANSFER', N'Overschrijving', N'Virement', N'Bank transfer', N'Havale', 10),
        (N'DIRECT_PAYMENT', N'Rechtstreekse betaling', N'Paiement direct', N'Direct payment', N'Dogrudan odeme', 20)
    ) AS source (payment_method_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.payment_method_code = source.payment_method_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (payment_method_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.payment_method_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE tasking.TaskStatus AS target
    USING (VALUES
        (N'OPEN', N'Open', N'Ouvert', N'Open', N'Acik', 10),
        (N'IN_PROGRESS', N'In behandeling', N'En cours', N'In progress', N'Islemde', 20),
        (N'WAITING', N'Wachtend', N'En attente', N'Waiting', N'Bekliyor', 30),
        (N'DONE', N'Klaar', N'Termine', N'Done', N'Tamam', 40),
        (N'CANCELLED', N'Geannuleerd', N'Annule', N'Cancelled', N'Iptal', 50)
    ) AS source (task_status_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.task_status_code = source.task_status_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (task_status_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.task_status_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE tasking.TaskPriority AS target
    USING (VALUES
        (N'LOW', N'Laag', N'Bas', N'Low', N'Dusuk', 10),
        (N'NORMAL', N'Normaal', N'Normal', N'Normal', N'Normal', 20),
        (N'HIGH', N'Hoog', N'Haut', N'High', N'Yuksek', 30),
        (N'URGENT', N'Dringend', N'Urgent', N'Urgent', N'Acil', 40)
    ) AS source (task_priority_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.task_priority_code = source.task_priority_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (task_priority_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.task_priority_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE document.DocumentType AS target
    USING (VALUES
        (N'ID_CARD', N'Identiteitskaart', N'Carte identite', N'ID card', N'Kimlik karti', 10),
        (N'PASSPORT', N'Paspoort', N'Passeport', N'Passport', N'Pasaport', 20),
        (N'POLICY_DOCUMENT', N'Polisdocument', N'Document police', N'Policy document', N'Police dokumani', 30),
        (N'GREEN_CARD', N'Groene kaart', N'Carte verte', N'Green card', N'Yesil kart', 40),
        (N'CLAIM_REPORT', N'Schaderapport', N'Rapport sinistre', N'Claim report', N'Hasar raporu', 50),
        (N'INVOICE', N'Factuur', N'Facture', N'Invoice', N'Fatura', 60),
        (N'PHOTO', N'Foto', N'Photo', N'Photo', N'Fotograf', 70),
        (N'BANK_DOCUMENT', N'Bankdocument', N'Document bancaire', N'Bank document', N'Banka dokumani', 80),
        (N'SIGNED_CONTRACT', N'Getekend contract', N'Contrat signe', N'Signed contract', N'Imzali sozlesme', 90),
        (N'EMAIL_ATTACHMENT', N'E-mail bijlage', N'Piece jointe email', N'Email attachment', N'E-posta eki', 100)
    ) AS source (document_type_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.document_type_code = source.document_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (document_type_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.document_type_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE core.Permission AS target
    USING (VALUES
        (N'person.read', N'Read persons', N'person'),
        (N'person.write', N'Write persons', N'person'),
        (N'person.delete', N'Delete persons', N'person'),
        (N'institution.read', N'Read institutions', N'institution'),
        (N'institution.write', N'Write institutions', N'institution'),
        (N'risk.read', N'Read risks', N'risk'),
        (N'risk.write', N'Write risks', N'risk'),
        (N'policy.read', N'Read policies', N'policy'),
        (N'policy.write', N'Write policies', N'policy'),
        (N'policy.version.create', N'Create policy versions', N'policy'),
        (N'claim.read', N'Read claims', N'claim'),
        (N'claim.write', N'Write claims', N'claim'),
        (N'claim.close', N'Close claims', N'claim'),
        (N'document.upload', N'Upload documents', N'document'),
        (N'document.read', N'Read documents', N'document'),
        (N'admin.lookup.manage', N'Manage lookups', N'admin'),
        (N'admin.user.manage', N'Manage users', N'admin'),
        (N'audit.read', N'Read audit logs', N'audit')
    ) AS source (permission_code, permission_name, module_code)
    ON target.permission_code = source.permission_code
    WHEN MATCHED THEN UPDATE SET permission_name = source.permission_name, module_code = source.module_code, is_active = 1
    WHEN NOT MATCHED THEN INSERT (permission_code, permission_name, module_code, is_active)
        VALUES (source.permission_code, source.permission_name, source.module_code, 1);

    MERGE core.Role AS target
    USING (VALUES
        (N'SYSTEM_ADMIN', N'System administrator', 1),
        (N'BROKER_ADMIN', N'Broker administrator', 1),
        (N'BROKER_USER', N'Broker user', 1),
        (N'CLAIM_HANDLER', N'Claim handler', 1)
    ) AS source (role_code, role_name, is_system_role)
    ON target.tenant_id IS NULL
       AND target.role_code = source.role_code
    WHEN MATCHED THEN UPDATE SET role_name = source.role_name, is_system_role = source.is_system_role, is_active = 1
    WHEN NOT MATCHED THEN INSERT (tenant_id, role_code, role_name, is_system_role, is_active)
        VALUES (NULL, source.role_code, source.role_name, source.is_system_role, 1);

    INSERT INTO core.RolePermission (role_id, permission_code)
    SELECT r.role_id, p.permission_code
    FROM core.Role r
    CROSS JOIN core.Permission p
    WHERE r.tenant_id IS NULL
      AND r.role_code = N'SYSTEM_ADMIN'
      AND NOT EXISTS (
        SELECT 1
        FROM core.RolePermission rp
        WHERE rp.role_id = r.role_id
          AND rp.permission_code = p.permission_code
      );

    INSERT INTO core.RolePermission (role_id, permission_code)
    SELECT r.role_id, p.permission_code
    FROM core.Role r
    INNER JOIN core.Permission p
        ON p.permission_code IN (
            N'person.read', N'person.write',
            N'institution.read', N'institution.write',
            N'risk.read', N'risk.write',
            N'policy.read', N'policy.write', N'policy.version.create',
            N'claim.read', N'claim.write',
            N'document.upload', N'document.read',
            N'admin.lookup.manage', N'admin.user.manage'
        )
    WHERE r.tenant_id IS NULL
      AND r.role_code = N'BROKER_ADMIN'
      AND NOT EXISTS (
        SELECT 1
        FROM core.RolePermission rp
        WHERE rp.role_id = r.role_id
          AND rp.permission_code = p.permission_code
      );

    INSERT INTO core.RolePermission (role_id, permission_code)
    SELECT r.role_id, p.permission_code
    FROM core.Role r
    INNER JOIN core.Permission p
        ON p.permission_code IN (
            N'person.read',
            N'institution.read',
            N'risk.read',
            N'policy.read',
            N'claim.read',
            N'document.read'
        )
    WHERE r.tenant_id IS NULL
      AND r.role_code = N'BROKER_USER'
      AND NOT EXISTS (
        SELECT 1
        FROM core.RolePermission rp
        WHERE rp.role_id = r.role_id
          AND rp.permission_code = p.permission_code
      );

    INSERT INTO core.RolePermission (role_id, permission_code)
    SELECT r.role_id, p.permission_code
    FROM core.Role r
    INNER JOIN core.Permission p
        ON p.permission_code IN (
            N'claim.read',
            N'claim.write',
            N'claim.close',
            N'document.upload',
            N'document.read'
        )
    WHERE r.tenant_id IS NULL
      AND r.role_code = N'CLAIM_HANDLER'
      AND NOT EXISTS (
        SELECT 1
        FROM core.RolePermission rp
        WHERE rp.role_id = r.role_id
          AND rp.permission_code = p.permission_code
      );

    IF NOT EXISTS (
        SELECT 1
        FROM core.SchemaMigration
        WHERE migration_name = N'017__seed_lookup_data.sql'
    )
    BEGIN
        INSERT INTO core.SchemaMigration (
            migration_name,
            execution_status
        )
        VALUES (
            N'017__seed_lookup_data.sql',
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
