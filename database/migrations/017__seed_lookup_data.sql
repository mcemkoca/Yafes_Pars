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

    MERGE risk.ResidenceType AS target
    USING (VALUES
        (N'PRIMARY', N'Hoofdverblijf', N'Residence principale', 10),
        (N'SECONDARY', N'Tweede verblijf', N'Residence secondaire', 20),
        (N'RENTAL', N'Huurwoning', N'Logement locatif', 30)
    ) AS source (residence_type_code, label_nl, label_fr, sort_order)
    ON target.residence_type_code = source.residence_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (residence_type_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.residence_type_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.DestinationType AS target
    USING (VALUES
        (N'PRIVATE_HOME', N'Privewoning', N'Habitation privee', 10),
        (N'HOLIDAY_HOME', N'Vakantiewoning', N'Maison de vacances', 20),
        (N'RENTAL_PROPERTY', N'Verhuurpand', N'Bien locatif', 30),
        (N'BUSINESS_PREMISES', N'Bedrijfsgebouw', N'Locaux professionnels', 40)
    ) AS source (destination_type_code, label_nl, label_fr, sort_order)
    ON target.destination_type_code = source.destination_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (destination_type_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.destination_type_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.AdjacencyType AS target
    USING (VALUES
        (N'DETACHED', N'Vrijstaand', N'Quatre facades', 10),
        (N'SEMI_DETACHED', N'Halfopen bebouwing', N'Trois facades', 20),
        (N'ROW_HOUSE', N'Rijwoning', N'Maison mitoyenne', 30),
        (N'APARTMENT_BLOCK', N'Appartementengebouw', N'Immeuble a appartements', 40)
    ) AS source (adjacency_type_code, label_nl, label_fr, sort_order)
    ON target.adjacency_type_code = source.adjacency_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (adjacency_type_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.adjacency_type_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.OccupancyLevel AS target
    USING (VALUES
        (N'OWNER_OCCUPIED', N'Bewoond door eigenaar', N'Occupe par proprietaire', 10),
        (N'TENANT_OCCUPIED', N'Bewoond door huurder', N'Occupe par locataire', 20),
        (N'VACANT', N'Leegstaand', N'Inoccupe', 30),
        (N'SEASONAL', N'Seizoensgebruik', N'Usage saisonnier', 40)
    ) AS source (occupancy_level_code, label_nl, label_fr, sort_order)
    ON target.occupancy_level_code = source.occupancy_level_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (occupancy_level_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.occupancy_level_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.ConstructionType AS target
    USING (VALUES
        (N'TRADITIONAL', N'Traditionele bouw', N'Construction traditionnelle', 10),
        (N'WOOD_FRAME', N'Houtskeletbouw', N'Ossature bois', 20),
        (N'STEEL_FRAME', N'Staalskeletbouw', N'Ossature acier', 30),
        (N'MIXED', N'Gemengde constructie', N'Construction mixte', 40)
    ) AS source (construction_type_code, label_nl, label_fr, sort_order)
    ON target.construction_type_code = source.construction_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (construction_type_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.construction_type_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.RoofType AS target
    USING (VALUES
        (N'TILE', N'Dakpannen', N'Tuiles', 10),
        (N'SLATE', N'Leien', N'Ardoises', 20),
        (N'FLAT', N'Plat dak', N'Toit plat', 30),
        (N'METAL', N'Metalen dak', N'Toit metallique', 40)
    ) AS source (roof_type_code, label_nl, label_fr, sort_order)
    ON target.roof_type_code = source.roof_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (roof_type_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.roof_type_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.BurglaryProtectionType AS target
    USING (VALUES
        (N'STANDARD_LOCKS', N'Standaardsloten', N'Serrures standard', 10),
        (N'ALARM', N'Alarmsysteem', N'Systeme alarme', 20),
        (N'CAMERA', N'Camerabewaking', N'Videosurveillance', 30),
        (N'CERTIFIED_DOORS', N'Gecertificeerde deuren', N'Portes certifiees', 40)
    ) AS source (burglary_protection_type_code, label_nl, label_fr, sort_order)
    ON target.burglary_protection_type_code = source.burglary_protection_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (burglary_protection_type_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.burglary_protection_type_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.InsurablePersonSubtype AS target
    USING (VALUES
        (N'PERS_IND', N'Individuele persoon', N'Personne individuelle', 10),
        (N'PERS_ACT', N'Actieve persoon', N'Personne active', 20),
        (N'GROEP_COL', N'Collectieve groep', N'Groupe collectif', 30),
        (N'GROEP_ARB', N'Arbeidersgroep', N'Groupe ouvriers', 40),
        (N'GROEP_BED', N'Bediendengroep', N'Groupe employes', 50),
        (N'GROEP_POB', N'Personeelsgroep', N'Groupe personnel', 60),
        (N'GROEP_GEZIN', N'Gezinsgroep', N'Groupe familial', 70),
        (N'GEZIN_PRIV', N'Privegezin', N'Famille privee', 80)
    ) AS source (subtype_code, label_nl, label_fr, sort_order)
    ON target.subtype_code = source.subtype_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (subtype_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.subtype_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.WorkerRiskClass AS target
    USING (VALUES
        (N'LOW', N'Lage arbeidersrisico', N'Risque ouvrier faible', 10),
        (N'MEDIUM', N'Middelmatig arbeidersrisico', N'Risque ouvrier moyen', 20),
        (N'HIGH', N'Hoog arbeidersrisico', N'Risque ouvrier eleve', 30)
    ) AS source (worker_risk_class_code, label_nl, label_fr, sort_order)
    ON target.worker_risk_class_code = source.worker_risk_class_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (worker_risk_class_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.worker_risk_class_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.EmployeeRiskClass AS target
    USING (VALUES
        (N'OFFICE', N'Kantoorbediende', N'Employe bureau', 10),
        (N'FIELD', N'Buitendienst', N'Service externe', 20),
        (N'MANAGEMENT', N'Leidinggevend', N'Direction', 30)
    ) AS source (employee_risk_class_code, label_nl, label_fr, sort_order)
    ON target.employee_risk_class_code = source.employee_risk_class_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (employee_risk_class_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.employee_risk_class_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.AgeCategory AS target
    USING (VALUES
        (N'CHILD', N'Kind', N'Enfant', 10),
        (N'ADULT', N'Volwassene', N'Adulte', 20),
        (N'SENIOR', N'Senior', N'Senior', 30)
    ) AS source (age_category_code, label_nl, label_fr, sort_order)
    ON target.age_category_code = source.age_category_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (age_category_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.age_category_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.InsurableThingSubtype AS target
    USING (VALUES
        (N'JEWELRY', N'Juwelen', N'Bijoux', 10),
        (N'ART', N'Kunst', N'Art', 20),
        (N'ELECTRONICS', N'Elektronica', N'Electronique', 30),
        (N'EQUIPMENT', N'Materieel', N'Materiel', 40)
    ) AS source (subtype_code, label_nl, label_fr, sort_order)
    ON target.subtype_code = source.subtype_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (subtype_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.subtype_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.ThingRiskCategory AS target
    USING (VALUES
        (N'LOW', N'Laag risico', N'Risque faible', 10),
        (N'MEDIUM', N'Middelmatig risico', N'Risque moyen', 20),
        (N'HIGH', N'Hoog risico', N'Risque eleve', 30)
    ) AS source (risk_category_code, label_nl, label_fr, sort_order)
    ON target.risk_category_code = source.risk_category_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (risk_category_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.risk_category_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.ThingMaterialType AS target
    USING (VALUES
        (N'METAL', N'Metaal', N'Metal', 10),
        (N'WOOD', N'Hout', N'Bois', 20),
        (N'GLASS', N'Glas', N'Verre', 30),
        (N'MIXED', N'Gemengd', N'Mixte', 40)
    ) AS source (material_type_code, label_nl, label_fr, sort_order)
    ON target.material_type_code = source.material_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (material_type_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.material_type_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.InsurableActivitySubtype AS target
    USING (VALUES
        (N'SPORT', N'Sportactiviteit', N'Activite sportive', 10),
        (N'EVENT', N'Evenement', N'Evenement', 20),
        (N'PROFESSIONAL_ACTIVITY', N'Beroepsactiviteit', N'Activite professionnelle', 30),
        (N'VOLUNTEER', N'Vrijwilligersactiviteit', N'Activite benevole', 40)
    ) AS source (activity_type_code, label_nl, label_fr, sort_order)
    ON target.activity_type_code = source.activity_type_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (activity_type_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.activity_type_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE risk.ActivityRiskLevel AS target
    USING (VALUES
        (N'LOW', N'Laag', N'Faible', 10),
        (N'MEDIUM', N'Middelmatig', N'Moyen', 20),
        (N'HIGH', N'Hoog', N'Eleve', 30)
    ) AS source (risk_level_code, label_nl, label_fr, sort_order)
    ON target.risk_level_code = source.risk_level_code
    WHEN MATCHED THEN UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr, sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN INSERT (risk_level_code, label_nl, label_fr, sort_order, is_active)
        VALUES (source.risk_level_code, source.label_nl, source.label_fr, source.sort_order, 1);

    MERGE policy.ContractDomain AS target
    USING (VALUES
        (N'MOTOR', N'Motor', N'Auto', N'Motor', N'Trafik', 10),
        (N'AUTO', N'Auto', N'Auto', N'Auto', N'Auto', 15),
        (N'FIRE', N'Brand', N'Incendie', N'Fire', N'Yangin', 20),
        (N'FAMILY', N'Familie', N'Famille', N'Family', N'Aile', 30),
        (N'LIABILITY', N'Aansprakelijkheid', N'Responsabilite', N'Liability', N'Sorumluluk', 35),
        (N'LEGAL_PROTECTION', N'Rechtsbijstand', N'Protection juridique', N'Legal protection', N'Hukuki koruma', 38),
        (N'HEALTH', N'Gezondheid', N'Sante', N'Health', N'Saglik', 40),
        (N'LIFE', N'Leven', N'Vie', N'Life', N'Hayat', 45),
        (N'LOAN', N'Lening', N'Pret', N'Loan', N'Kredi', 50),
        (N'BUSINESS', N'Onderneming', N'Entreprise', N'Business', N'Isletme', 55),
        (N'TRAVEL', N'Reis', N'Voyage', N'Travel', N'Seyahat', 60),
        (N'GENERAL', N'Algemeen', N'General', N'General', N'Genel', 70)
    ) AS source (contract_domain_code, label_nl, label_fr, label_en, label_tr, sort_order)
    ON target.contract_domain_code = source.contract_domain_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, sort_order = source.sort_order,
            is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (contract_domain_code, label_nl, label_fr, label_en, label_tr, sort_order, is_active)
        VALUES (source.contract_domain_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.sort_order, 1);

    MERGE coverage.Coverage AS target
    USING (VALUES
        (N'BA_AUTO', N'BA Auto', N'RC Auto', N'Motor liability', N'Trafik sorumluluk', N'Verplichte burgerlijke aansprakelijkheid voor voertuigen.', 10),
        (N'AUTO_LIABILITY', N'BA Auto legacy', N'RC Auto legacy', N'Motor liability legacy', N'Trafik sorumluluk legacy', N'Compatibele code voor bestaande auto aansprakelijkheid.', 11),
        (N'OMNIUM', N'Omnium', N'Omnium', N'Comprehensive motor', N'Kapsamli kasko', N'Uitgebreide voertuigschade dekking.', 20),
        (N'MINI_OMNIUM', N'Mini omnium', N'Mini omnium', N'Limited comprehensive motor', N'Sinirli kasko', N'Beperkte voertuigschade dekking.', 30),
        (N'DRIVER_PROTECTION', N'Bestuurdersbescherming', N'Protection conducteur', N'Driver protection', N'Surucu koruma', N'Bescherming voor de bestuurder.', 40),
        (N'LEGAL_PROTECTION_AUTO', N'Rechtsbijstand auto', N'Protection juridique auto', N'Auto legal protection', N'Arac hukuki koruma', N'Rechtsbijstand voor voertuigschades.', 50),
        (N'LEGAL_ASSISTANCE', N'Rechtsbijstand algemeen', N'Protection juridique generale', N'General legal assistance', N'Genel hukuki yardim', N'Algemene rechtsbijstand.', 55),
        (N'FIRE_BUILDING', N'Brand gebouw', N'Incendie batiment', N'Fire building', N'Bina yangin', N'Gebouwschade door brand.', 60),
        (N'FIRE_CONTENTS', N'Brand inhoud', N'Incendie contenu', N'Fire contents', N'Esya yangin', N'Inboedelschade door brand.', 70),
        (N'THEFT', N'Diefstal', N'Vol', N'Theft', N'Hirsizlik', N'Diefstal en inbraakschade.', 80),
        (N'GLASS_BREAKAGE', N'Glasbreuk', N'Bris de vitre', N'Glass breakage', N'Cam kirilmasi', N'Glasbreuk aan gebouw of inhoud.', 90),
        (N'WATER_DAMAGE', N'Waterschade', N'Degats des eaux', N'Water damage', N'Su hasari', N'Schade door waterlekken.', 100),
        (N'FAMILY_LIABILITY', N'Familiale BA', N'RC familiale', N'Family liability', N'Aile sorumluluk', N'Burgerlijke aansprakelijkheid priveleven.', 110),
        (N'LEGAL_PROTECTION_PRIVATE', N'Rechtsbijstand prive', N'Protection juridique privee', N'Private legal protection', N'Ozel hukuki koruma', N'Rechtsbijstand voor priveleven.', 120),
        (N'HOSPITALIZATION', N'Hospitalisatie', N'Hospitalisation', N'Hospitalization', N'Hastane', N'Hospitalisatiekosten.', 130),
        (N'LIFE_COVER', N'Levensdekking', N'Couverture vie', N'Life cover', N'Hayat teminati', N'Kapitaal bij overlijden of leven.', 140),
        (N'OUTSTANDING_BALANCE', N'Saldo schuldsaldo', N'Solde restant du', N'Outstanding balance', N'Kalan borc', N'Bescherming van openstaand kredietsaldo.', 150),
        (N'BUSINESS_LIABILITY', N'BA onderneming', N'RC entreprise', N'Business liability', N'Isletme sorumluluk', N'Aansprakelijkheid voor ondernemingen.', 160),
        (N'TRAVEL_ASSISTANCE', N'Reisbijstand', N'Assistance voyage', N'Travel assistance', N'Seyahat yardimi', N'Bijstand tijdens reizen.', 170),
        (N'CLAIM_ASSISTANCE', N'Bijstand schade', N'Assistance sinistre', N'Claim assistance', N'Hasar yardimi', N'Operationele schadebijstand.', 180)
    ) AS source (coverage_code, label_nl, label_fr, label_en, label_tr, description, sort_order)
    ON target.coverage_code = source.coverage_code
    WHEN MATCHED THEN
        UPDATE SET label_nl = source.label_nl, label_fr = source.label_fr,
            label_en = source.label_en, label_tr = source.label_tr, description = source.description,
            sort_order = source.sort_order, is_active = 1
    WHEN NOT MATCHED THEN
        INSERT (coverage_code, label_nl, label_fr, label_en, label_tr, description, sort_order, is_active)
        VALUES (source.coverage_code, source.label_nl, source.label_fr, source.label_en, source.label_tr, source.description, source.sort_order, 1);

    MERGE coverage.CoverageDomain AS target
    USING (VALUES
        (N'BA_AUTO', N'AUTO', 1, 10),
        (N'AUTO_LIABILITY', N'AUTO', 0, 11),
        (N'OMNIUM', N'AUTO', 0, 20),
        (N'MINI_OMNIUM', N'AUTO', 0, 30),
        (N'DRIVER_PROTECTION', N'AUTO', 0, 40),
        (N'LEGAL_PROTECTION_AUTO', N'AUTO', 0, 50),
        (N'BA_AUTO', N'MOTOR', 1, 12),
        (N'AUTO_LIABILITY', N'MOTOR', 0, 13),
        (N'OMNIUM', N'MOTOR', 0, 22),
        (N'MINI_OMNIUM', N'MOTOR', 0, 32),
        (N'DRIVER_PROTECTION', N'MOTOR', 0, 42),
        (N'LEGAL_PROTECTION_AUTO', N'MOTOR', 0, 52),
        (N'LEGAL_PROTECTION_AUTO', N'LEGAL_PROTECTION', 0, 55),
        (N'LEGAL_ASSISTANCE', N'LEGAL_PROTECTION', 1, 60),
        (N'LEGAL_ASSISTANCE', N'BUSINESS', 0, 65),
        (N'FIRE_BUILDING', N'FIRE', 1, 70),
        (N'FIRE_CONTENTS', N'FIRE', 0, 80),
        (N'THEFT', N'FIRE', 0, 90),
        (N'GLASS_BREAKAGE', N'FIRE', 0, 100),
        (N'WATER_DAMAGE', N'FIRE', 0, 110),
        (N'FAMILY_LIABILITY', N'FAMILY', 1, 120),
        (N'FAMILY_LIABILITY', N'LIABILITY', 1, 125),
        (N'LEGAL_PROTECTION_PRIVATE', N'FAMILY', 0, 130),
        (N'LEGAL_PROTECTION_PRIVATE', N'LEGAL_PROTECTION', 0, 135),
        (N'HOSPITALIZATION', N'HEALTH', 1, 140),
        (N'LIFE_COVER', N'LIFE', 1, 150),
        (N'OUTSTANDING_BALANCE', N'LOAN', 1, 160),
        (N'BUSINESS_LIABILITY', N'BUSINESS', 1, 170),
        (N'BUSINESS_LIABILITY', N'LIABILITY', 0, 175),
        (N'TRAVEL_ASSISTANCE', N'TRAVEL', 1, 180),
        (N'CLAIM_ASSISTANCE', N'GENERAL', 0, 190)
    ) AS source (coverage_code, contract_domain_code, is_default, sort_order)
    ON target.coverage_code = source.coverage_code
       AND target.contract_domain_code = source.contract_domain_code
    WHEN MATCHED THEN
        UPDATE SET is_default = source.is_default, sort_order = source.sort_order
    WHEN NOT MATCHED THEN
        INSERT (coverage_code, contract_domain_code, is_default, sort_order)
        VALUES (source.coverage_code, source.contract_domain_code, source.is_default, source.sort_order);

    MERGE coverage.CoveragePackage AS target
    USING (VALUES
        (N'AUTO_BASIC', N'AUTO', N'Auto basis', N'Verplichte BA auto met basis rechtsbijstand.'),
        (N'AUTO_FULL', N'AUTO', N'Auto volledig', N'BA auto, omnium, bestuurdersbescherming en rechtsbijstand.'),
        (N'HOME_BASIC', N'FIRE', N'Woning basis', N'Brand gebouw en inhoud.'),
        (N'HOME_FULL', N'FIRE', N'Woning volledig', N'Brand, diefstal, glasbreuk en waterschade.'),
        (N'FAMILY_BASIC', N'FAMILY', N'Familie basis', N'Familiale aansprakelijkheid en prive rechtsbijstand.'),
        (N'BUSINESS_BASIC', N'BUSINESS', N'Onderneming basis', N'Basis aansprakelijkheid voor ondernemingen.')
    ) AS source (package_code, contract_domain_code, package_name, description)
    ON target.package_code = source.package_code
    WHEN MATCHED THEN
        UPDATE SET contract_domain_code = source.contract_domain_code,
            package_name = source.package_name,
            description = source.description,
            is_active = 1,
            updated_at_utc = SYSUTCDATETIME()
    WHEN NOT MATCHED THEN
        INSERT (package_code, contract_domain_code, package_name, description, is_active)
        VALUES (source.package_code, source.contract_domain_code, source.package_name, source.description, 1);

    MERGE coverage.CoveragePackageItem AS target
    USING (
        SELECT
            cp.coverage_package_id,
            item.coverage_code,
            item.is_mandatory,
            item.sort_order
        FROM (VALUES
            (N'AUTO_BASIC', N'BA_AUTO', 1, 10),
            (N'AUTO_BASIC', N'LEGAL_PROTECTION_AUTO', 0, 20),
            (N'AUTO_FULL', N'BA_AUTO', 1, 10),
            (N'AUTO_FULL', N'OMNIUM', 1, 20),
            (N'AUTO_FULL', N'DRIVER_PROTECTION', 0, 30),
            (N'AUTO_FULL', N'LEGAL_PROTECTION_AUTO', 0, 40),
            (N'HOME_BASIC', N'FIRE_BUILDING', 1, 10),
            (N'HOME_BASIC', N'FIRE_CONTENTS', 0, 20),
            (N'HOME_FULL', N'FIRE_BUILDING', 1, 10),
            (N'HOME_FULL', N'FIRE_CONTENTS', 1, 20),
            (N'HOME_FULL', N'THEFT', 0, 30),
            (N'HOME_FULL', N'GLASS_BREAKAGE', 0, 40),
            (N'HOME_FULL', N'WATER_DAMAGE', 0, 50),
            (N'FAMILY_BASIC', N'FAMILY_LIABILITY', 1, 10),
            (N'FAMILY_BASIC', N'LEGAL_PROTECTION_PRIVATE', 0, 20),
            (N'BUSINESS_BASIC', N'BUSINESS_LIABILITY', 1, 10),
            (N'BUSINESS_BASIC', N'LEGAL_ASSISTANCE', 0, 20)
        ) AS item (package_code, coverage_code, is_mandatory, sort_order)
        INNER JOIN coverage.CoveragePackage cp
            ON cp.package_code = item.package_code
    ) AS source
    ON target.coverage_package_id = source.coverage_package_id
       AND target.coverage_code = source.coverage_code
    WHEN MATCHED THEN
        UPDATE SET is_mandatory = source.is_mandatory, sort_order = source.sort_order
    WHEN NOT MATCHED THEN
        INSERT (coverage_package_id, coverage_code, is_mandatory, sort_order)
        VALUES (source.coverage_package_id, source.coverage_code, source.is_mandatory, source.sort_order);

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
