-- =============================================================
-- AssureManager Test Data Script
-- Belgische testdata voor verzekeringsbeheersysteem
-- =============================================================
-- Run AFTER 04_seeds.sql
-- Bevat: 300+ testrecords over alle domeinen
-- =============================================================

SET NOCOUNT ON;
GO

USE AssureManagerDB;
GO

PRINT '=======================================================';
PRINT ' Starten van testdata-invoer...';
PRINT '=======================================================';
GO

-- =============================================================
-- SECTIE 10: Referentie/Lookup records (100 records)
-- Nieuwe lookup-waarden voor nog niet-geseede tabellen
-- Deze worden eerst ingevoerd zodat latere secties ernaar kunnen refereren
-- =============================================================
PRINT 'Sectie 10: Referentie en lookup records invoeren...';
GO

/* ---------- VehicleType (12 records) ---------- */
INSERT INTO VehicleType (vehicle_type_code, label_nl, label_fr)
VALUES
  ('PERSONENWAGEN', N'Personenwagen', N'Voiture de tourisme'),
  ('BESTELWAGEN', N'Bestelwagen', N'Vehicule utilitaire'),
  ('VRACHTWAGEN', N'Vrachtwagen', N'Camion'),
  ('MOTORFIETS', N'Motorfiets', N'Motocyclette'),
  ('BROMFIETS', N'Bromfiets', N'Cyclomoteur'),
  ('CARAVAN', N'Caravan', N'Caravane'),
  ('AANHANGWAGEN', N'Aanhanger', N'Remorque'),
  ('LAND_BOSBOUW_VOERTUIG', N'Land- en bosbouwtrekker', N'Tracteur agricole et forestier'),
  ('KAMPEERAUTO', N'Kampeerauto', N'Camping-car'),
  ('MINIBUS', N'Minibus', N'Minibus'),
  ('MOTORRIJTUIG_BEPERKT', N'Motorrijtuig met beperkte snelheid', N'Vehicule a vitesse limitee'),
  ('BIJZONDER_VOERTUIG', N'Bijzonder voertuig', N'Vehicule special');
GO

/* ---------- UsageType (10 records) ---------- */
INSERT INTO UsageType (usage_type_code, label_nl, label_fr)
VALUES
  ('PRIVWG', N'Privaat woon-werkverkeer', N'Usage prive'),
  ('BEROEP', N'Beroepsmatig gebruik', N'Usage professionnel'),
  ('PRIV_PLUS_BER', N'Privaat + beroepsmatig', N'Prive + professionnel'),
  ('PUB_VERV', N'Publiek vervoer', N'Transport public'),
  ('VERHUUR', N'Verhuur zonder chauffeur', N'Location sans chauffeur'),
  ('LEER', N'Leerrijtuig', N'Vehicule ecole'),
  ('OMNIUM_JONG', N'Omium jonge bestuurder', N'Omium jeune conducteur'),
  ('TAXI', N'Taxi', N'Taxi'),
  ('ZAKELIJK', N'Zakelijk gebruik', N'Usage commercial'),
  ('WELZIJN', N'Welzijnsvervoer', N'Transport social');
GO

/* ---------- FuelType (8 records) ---------- */
INSERT INTO FuelType (fuel_type_code, label_nl, label_fr)
VALUES
  ('BENZINE', N'Benzine', N'Essence'),
  ('DIESEL', N'Diesel', N'Diesel'),
  ('ELEKTRISCH', N'Elektrisch', N'Electrique'),
  ('HYBRIDE', N'Hybride', N'Hybride'),
  ('LPG', N'LPG', N'GPL'),
  ('CNG', N'CNG (aardgas)', N'GNC'),
  ('WATERSTOF', N'Waterstof', N'Hydrogene'),
  ('PHEV', N'Plug-in hybride', N'Hybride rechargeable');
GO

/* ---------- DriveType (5 records) ---------- */
INSERT INTO DriveType (drive_type_code, label_nl, label_fr)
VALUES
  ('VOORWIEL', N'Voorwielaandrijving', N'Traction avant'),
  ('ACHTERWIEL', N'Achterwielaandrijving', N'Traction arriere'),
  ('VIERWIEL', N'Vierwielaandrijving', N'Traction integrale'),
  ('TWEEWIEL', N'Tweetakt', N'Deux temps'),
  ('ALL_WHEEL', N'All-wheel drive', N'All-wheel drive');
GO

/* ---------- LicensePlateType (5 records) ---------- */
INSERT INTO LicensePlateType (plate_type_code, label_nl, label_fr)
VALUES
  ('EUROPEES', N'Europees', N'Europeen'),
  ('BELG_KORT', N'Belgisch kort', N'Belge court'),
  ('HANDELAAR', N'Handelaar', N'Commercant'),
  ('TESTPLAAT', N'Testplaat', N'Plaque dessai'),
  ('EXPORT', N'Export', N'Export');
GO

/* ---------- ObjectActivitySubtype (10 records) ---------- */
INSERT INTO ObjectActivitySubtype (activity_type_code, label_nl, label_fr)
VALUES
  ('EVENEMENT', N'Evenement', N'Evenement'),
  ('SPORT', N'Sportactiviteit', N'Activite sportive'),
  ('CULTUUR', N'Culturele activiteit', N'Activite culturelle'),
  ('OPLEIDING', N'Opleiding/Cursus', N'Formation'),
  ('FEEST', N'Feest/Receptie', N'Fete/Reception'),
  ('CONFERENTIE', N'Conferentie/Seminarie', N'Conference/Seminaire'),
  ('VAKANTIE', N'Vakantie/Kamp', N'Vacances/Camp'),
  ('MARKT', N'Markt/Braderie', N'Marche/Braderie'),
  ('CONCERT', N'Concert/Optreden', N'Concert/Spectacle'),
  ('EXPOSITIE', N'Expositie/Beurs', N'Exposition/Salon');
GO

/* ---------- ActivityRiskLevel (5 records) ---------- */
INSERT INTO ActivityRiskLevel (risk_level_code, label_nl, label_fr)
VALUES
  ('LAAG', N'Laag risico', N'Risque faible'),
  ('MEDIUM_RL', N'Middelmatig risico', N'Risque moyen'),
  ('HOOG', N'Hoog risico', N'Risque eleve'),
  ('ZEER_HOOG', N'Zeer hoog risico', N'Risque tres eleve'),
  ('AANPASBAAR', N'Aanpasbaar risico', N'Risque adaptable');
GO

/* ---------- PersonType (15 records) ---------- */
INSERT INTO PersonType (person_type_code, person_type_label_nl, person_type_label_fr)
VALUES
  ('VERZEKERINGSNEMER', N'Verzekeringnemer', N'Assure'),
  ('VERZEKERDE_PT', N'Verzekerde', N'Assure'),
  ('BEGUNSTIGDE_PT', N'Begunstigde', N'Beneficiaire'),
  ('BETALER', N'Betaler', N'Payeur'),
  ('ADVISEUR', N'Adviseur', N'Conseiller'),
  ('SCHADEBEHANDELAAR_PT', N'Schadebehandelaar', N'Gestionnaire de sinistres'),
  ('EXPERT_PT', N'Expert', N'Expert'),
  ('RECHTSGEMACHTIGDE', N'Rechtsgemachtigde', N'Mandataire'),
  ('ERFGENAAM', N'Erfgenaam', N'Heritier'),
  ('LEIDINGGEVENDE', N'Leidinggevende', N'Cadre'),
  ('BEMIDDELAAR_PT', N'Bemiddelaar', N'Intermediaire'),
  ('NOTARIS_PT', N'Notaris', N'Notaire'),
  ('MAKELAAR', N'Makelaar', N'Courtier'),
  ('HUURDER_PT', N'Huurder', N'Locataire'),
  ('VERNIEUWER', N'Vernieuwer', N'Renouvelleur');
GO

/* ---------- PersonRelationType (15 records) ---------- */
INSERT INTO PersonRelationType (relation_type_code, relation_category, label_nl, label_fr, is_active)
VALUES
  ('ECHTGENOOT', N'FAMILIAAL', N'Echtgenoot/Echtgenote', N'Epoux/Epouse', 1),
  ('SAMENWONENDE', N'FAMILIAAL', N'Samenwonende partner', N'Partenaire cohabitant', 1),
  ('KIND', N'FAMILIAAL', N'Kind', N'Enfant', 1),
  ('OUDER', N'FAMILIAAL', N'Ouder', N'Parent', 1),
  ('BROER_ZUS', N'FAMILIAAL', N'Broer/Zus', N'Frere/Soeur', 1),
  ('WERKGEVER', N'WERK', N'Werkgever', N'Employeur', 1),
  ('WERKNEMER_REL', N'WERK', N'Werknemer', N'Employe', 1),
  ('ZELFSTANDIG_PARTNER', N'WERK', N'Zelfstandige partner', N'Partenaire independant', 1),
  ('AANDEELHOUDER', N'ZAKELIJK', N'Aandeelhouder', N'Actionnaire', 1),
  ('ZAAKVOERDER', N'ZAKELIJK', N'Zaakvoerder', N'Gerant', 1),
  ('BESTUURDER_REL', N'ZAKELIJK', N'Bestuurder', N'Administrateur', 1),
  ('VENNOOTSCHAP', N'ZAKELIJK', N'Venootschap', N'Societe', 1),
  ('HYPOTHECAIRE_SCHULDEISER', N'FINANCIEEL', N'Hypothecaire schuldeiser', N'Creancier hypothecaire', 1),
  ('KREDIETGEVER', N'FINANCIEEL', N'Kredietgever', N'Preteur', 1),
  ('KREDIETNEMER', N'FINANCIEEL', N'Kredietnemer', N'Emprunteur', 1);
GO

/* ---------- Extra ContractTypes voor andere domeinen (10 records) ---------- */
INSERT INTO ContractType (contract_type_code, contract_domain_code, contract_type_name, contract_type_name_fr, is_active)
VALUES
  ('BRAND_EG_WONING', 'BRAND_EENVOUDIG', N'Brand eenvoudige risico's - Woning', N'Incendie risques simples - Habitation', 1),
  ('BRAND_EG_APP', 'BRAND_EENVOUDIG', N'Brand eenvoudige risico's - Appartement', N'Incendie risques simples - Appartement', 1),
  ('BRAND_BZ_BEDRIJF', 'BRAND_BIJZONDERE', N'Brand bijzondere risico's - Bedrijf', N'Incendie risques speciaux - Entreprise', 1),
  ('HOSP_ZIEKENFONDS', 'HOSPITALISATIE', N'Hospitalisatie - Ziekenfonds', N'Hospitalisation - Mutualite', 1),
  ('HOSP_PARTICULIER', 'HOSPITALISATIE', N'Hospitalisatie - Particulier', N'Hospitalisation - Particulier', 1),
  ('LEVEN_OVERLIJDEN', 'LEVEN_BELEGGINGEN', N'Leven - Overlijdensverzekering', N'Vie - Assurance deces', 1),
  ('LEVEN_SPL', 'LEVEN_BELEGGINGEN', N'Leven - Spaarverzekering', N'Vie - Assurance epargne', 1),
  ('REIS_KORT', 'REIS', N'Reisverzekering kort', N'Assurance voyage courte', 1),
  ('REIS_LANG', 'REIS', N'Reisverzekering lang', N'Assurance voyage longue', 1),
  ('RECHTS_PART', 'RECHTSBIJSTAND', N'Rechtsbijstand particulier', N'Assurance protection juridique particulier', 1),
  ('LENING_HYPOTHECAIR', 'LENING', N'Hypothecair krediet', N'Credit hypothecaire', 1);
GO

/* ---------- Person_PersonType koppelingen (15 records) ---------- */
INSERT INTO Person_PersonType (person_id, person_type_code)
VALUES
  ('P0000000-0000-0000-0000-000000000001', 'VERZEKERINGSNEMER'),
  ('P0000000-0000-0000-0000-000000000002', 'VERZEKERINGSNEMER'),
  ('P0000000-0000-0000-0000-000000000003', 'VERZEKERDE_PT'),
  ('P0000000-0000-0000-0000-000000000004', 'VERZEKERINGSNEMER'),
  ('P0000000-0000-0000-0000-000000000005', 'VERZEKERDE_PT'),
  ('P0000000-0000-0000-0000-000000000006', 'BEGUNSTIGDE_PT'),
  ('P0000000-0000-0000-0000-000000000007', 'ADVISEUR'),
  ('P0000000-0000-0000-0000-000000000008', 'VERZEKERINGSNEMER'),
  ('P0000000-0000-0000-0000-000000000009', 'SCHADEBEHANDELAAR_PT'),
  ('P0000000-0000-0000-0000-000000000010', 'EXPERT_PT'),
  ('P0000000-0000-0000-0000-000000000011', 'BEMIDDELAAR_PT'),
  ('P0000000-0000-0000-0000-000000000012', 'VERZEKERINGSNEMER'),
  ('P0000000-0000-0000-0000-000000000013', 'RECHTSGEMACHTIGDE'),
  ('P0000000-0000-0000-0000-000000000014', 'VERZEKERDE_PT'),
  ('P0000000-0000-0000-0000-000000000015', 'NOTARIS_PT');
GO
PRINT '100 referentie/lookup records ingevoerd.';
GO

-- =============================================================
-- SECTIE 1: Natuurlijke personen (20 records)
-- =============================================================
PRINT 'Sectie 1: Natuurlijke personen invoeren...';
GO

INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES
  ('P0000000-0000-0000-0000-000000000001', 'NATURAL', 'DOS001', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000002', 'NATURAL', 'DOS002', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000003', 'NATURAL', 'DOS003', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000004', 'NATURAL', 'DOS004', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000005', 'NATURAL', 'DOS005', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000006', 'NATURAL', 'DOS006', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000007', 'NATURAL', 'DOS007', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000008', 'NATURAL', 'DOS008', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000009', 'NATURAL', 'DOS009', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000010', 'NATURAL', 'DOS010', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000011', 'NATURAL', 'DOS011', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000012', 'NATURAL', 'DOS012', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000013', 'NATURAL', 'DOS013', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000014', 'NATURAL', 'DOS014', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000015', 'NATURAL', 'DOS015', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000016', 'NATURAL', 'DOS016', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000017', 'NATURAL', 'DOS017', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000018', 'NATURAL', 'DOS018', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000019', 'NATURAL', 'DOS019', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000020', 'NATURAL', 'DOS020', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
GO

INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, marital_status, national_number, title_code)
VALUES
  ('P0000000-0000-0000-0000-000000000001', N'Jan', N'De Vries', '1985-07-15', N'Mechelen', 'MALE', 'GEHUWD', '85.07.15-123.45', 'MR'),
  ('P0000000-0000-0000-0000-000000000002', N'Marie', N'Peeters', '1991-04-22', N'Brussel', 'FEMALE', 'GEHUWD', '91.04.22-678.90', 'MRS'),
  ('P0000000-0000-0000-0000-000000000003', N'Pieter', N'Janssens', '1978-11-03', N'Antwerpen', 'MALE', 'SAMENWONEND', '78.11.03-234.56', 'MR'),
  ('P0000000-0000-0000-0000-000000000004', N'Sofie', N'Maes', '1988-02-14', N'Gent', 'FEMALE', 'ONGEBONDEN', '88.02.14-789.01', 'MRS'),
  ('P0000000-0000-0000-0000-000000000005', N'Thomas', N'Willems', '1995-09-28', N'Leuven', 'MALE', 'ONGEBONDEN', '95.09.28-345.67', 'MR'),
  ('P0000000-0000-0000-0000-000000000006', N'Ann', N'Mertens', '1982-06-10', N'Hasselt', 'FEMALE', 'GEHUWD', '82.06.10-890.12', 'MRS'),
  ('P0000000-0000-0000-0000-000000000007', N'Luc', N'Vermeulen', '1975-01-20', N'Brugge', 'MALE', 'GESCHIEDEN', '75.01.20-456.78', 'MR'),
  ('P0000000-0000-0000-0000-000000000008', N'Eva', N'De Smet', '1990-12-05', N'Mechelen', 'FEMALE', 'SAMENWONEND', '90.12.05-901.23', 'MRS'),
  ('P0000000-0000-0000-0000-000000000009', N'Bart', N'Jacobs', '1987-08-18', N'Brussel', 'MALE', 'GEHUWD', '87.08.18-567.89', 'MR'),
  ('P0000000-0000-0000-0000-000000000010', N'Karin', N'Claes', '1993-03-25', N'Antwerpen', 'FEMALE', 'ONGEBONDEN', '93.03.25-012.34', 'MRS'),
  ('P0000000-0000-0000-0000-000000000011', N'Steven', N'Goossens', '1980-05-12', N'Gent', 'MALE', 'GEHUWD', '80.05.12-567.89', 'MR'),
  ('P0000000-0000-0000-0000-000000000012', N'Inge', N'Lamberts', '1986-10-30', N'Leuven', 'FEMALE', 'SAMENWONEND', '86.10.30-123.45', 'MRS'),
  ('P0000000-0000-0000-0000-000000000013', N'Patrick', N'Wouters', '1972-04-08', N'Hasselt', 'MALE', 'GESCHIEDEN', '72.04.08-678.90', 'MR'),
  ('P0000000-0000-0000-0000-000000000014', N'Nathalie', N'Dubois', '1989-07-19', N'Brugge', 'FEMALE', 'GEHUWD', '89.07.19-234.56', 'MRS'),
  ('P0000000-0000-0000-0000-000000000015', N'Marc', N'Hendricks', '1977-11-23', N'Mechelen', 'MALE', 'GEHUWD', '77.11.23-789.01', 'MR'),
  ('P0000000-0000-0000-0000-000000000016', N'Sandra', N'Martens', '1992-01-14', N'Brussel', 'FEMALE', 'ONGEBONDEN', '92.01.14-345.67', 'MRS'),
  ('P0000000-0000-0000-0000-000000000017', N'Dirk', N'Peters', '1984-09-06', N'Antwerpen', 'MALE', 'SAMENWONEND', '84.09.06-890.12', 'MR'),
  ('P0000000-0000-0000-0000-000000000018', N'Christel', N'Aerts', '1981-03-17', N'Gent', 'FEMALE', 'GEHUWD', '81.03.17-456.78', 'MRS'),
  ('P0000000-0000-0000-0000-000000000019', N'Frank', N'Smets', '1979-12-01', N'Leuven', 'MALE', 'GESCHIEDEN', '79.12.01-901.23', 'MR'),
  ('P0000000-0000-0000-0000-000000000020', N'Isabelle', N'Bosmans', '1994-06-09', N'Brugge', 'FEMALE', 'SAMENWONEND', '94.06.09-567.89', 'MRS');
GO

INSERT INTO EconomicActivity (economic_activity_id, person_id, profession, professional_status_code, kbo_number, vat_number)
VALUES
  ('EA000000-0000-0000-0000-000000000001', 'P0000000-0000-0000-0000-000000000001', N'Bedrijfsleider', 'SELF_EMPLOYED', NULL, NULL),
  ('EA000000-0000-0000-0000-000000000002', 'P0000000-0000-0000-0000-000000000002', N'Marketingmanager', 'EMPLOYEE', NULL, NULL),
  ('EA000000-0000-0000-0000-000000000003', 'P0000000-0000-0000-0000-000000000003', N'Bouwtechnicus', 'WORKER', NULL, NULL),
  ('EA000000-0000-0000-0000-000000000004', 'P0000000-0000-0000-0000-000000000004', N'Softwareontwikkelaar', 'EMPLOYEE', NULL, NULL),
  ('EA000000-0000-0000-0000-000000000005', 'P0000000-0000-0000-0000-000000000005', N'Student Informatica', 'STUDENT', NULL, NULL),
  ('EA000000-0000-0000-0000-000000000006', 'P0000000-0000-0000-0000-000000000006', N'Verpleegkundige', 'EMPLOYEE', NULL, NULL),
  ('EA000000-0000-0000-0000-000000000007', 'P0000000-0000-0000-0000-000000000007', N'Bedrijfsconsultant', 'SELF_EMPLOYED', N'BE 0123.456.789', N'BE 0123.456.789'),
  ('EA000000-0000-0000-0000-000000000008', 'P0000000-0000-0000-0000-000000000008', N'Grafisch ontwerper', 'SELF_EMPLOYED', N'BE 0456.789.012', N'BE 0456.789.012'),
  ('EA000000-0000-0000-0000-000000000009', 'P0000000-0000-0000-0000-000000000009', N'Accountant', 'EMPLOYEE', NULL, NULL),
  ('EA000000-0000-0000-0000-000000000010', 'P0000000-0000-0000-0000-000000000010', N'Projectmanager', 'EMPLOYEE', NULL, NULL),
  ('EA000000-0000-0000-0000-000000000011', 'P0000000-0000-0000-0000-000000000011', N'Elektricien', 'WORKER', NULL, NULL),
  ('EA000000-0000-0000-0000-000000000012', 'P0000000-0000-0000-0000-000000000012', N'Leerkracht', 'CIVIL_SERVANT', NULL, NULL),
  ('EA000000-0000-0000-0000-000000000013', 'P0000000-0000-0000-0000-000000000013', N'Gepensioneerd', 'RETIRED', NULL, NULL),
  ('EA000000-0000-0000-0000-000000000014', 'P0000000-0000-0000-0000-000000000014', N'HR-manager', 'EMPLOYEE', NULL, NULL),
  ('EA000000-0000-0000-0000-000000000015', 'P0000000-0000-0000-0000-000000000015', N'Advocaat', 'SELF_EMPLOYED', N'BE 0789.012.345', N'BE 0789.012.345'),
  ('EA000000-0000-0000-0000-000000000016', 'P0000000-0000-0000-0000-000000000016', N'Verkoopmedewerker', 'EMPLOYEE', NULL, NULL),
  ('EA000000-0000-0000-0000-000000000017', 'P0000000-0000-0000-0000-000000000017', N'Technicus', 'WORKER', NULL, NULL),
  ('EA000000-0000-0000-0000-000000000018', 'P0000000-0000-0000-0000-000000000018', N'Administratief medewerker', 'EMPLOYEE', NULL, NULL),
  ('EA000000-0000-0000-0000-000000000019', 'P0000000-0000-0000-0000-000000000019', N'Ondernemer', 'SELF_EMPLOYED', N'BE 0987.654.321', N'BE 0987.654.321'),
  ('EA000000-0000-0000-0000-000000000020', 'P0000000-0000-0000-0000-000000000020', N'Analyst', 'EMPLOYEE', NULL, NULL);
GO
PRINT '20 natuurlijke personen ingevoerd.';
GO

-- =============================================================
-- SECTIE 2: Rechtspersonen (10 records)
-- =============================================================
PRINT 'Sectie 2: Rechtspersonen invoeren...';
GO

INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES
  ('P0000000-0000-0000-0000-000000000021', 'LEGAL', 'DOS021', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000022', 'LEGAL', 'DOS022', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000023', 'LEGAL', 'DOS023', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000024', 'LEGAL', 'DOS024', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000025', 'LEGAL', 'DOS025', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000026', 'LEGAL', 'DOS026', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000027', 'LEGAL', 'DOS027', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000028', 'LEGAL', 'DOS028', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000029', 'LEGAL', 'DOS029', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('P0000000-0000-0000-0000-000000000030', 'LEGAL', 'DOS030', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
GO

INSERT INTO LegalPerson (person_id, incorporation_date, closing_date, legal_form)
VALUES
  ('P0000000-0000-0000-0000-000000000021', '1995-03-10', NULL, N'Naamloze vennootschap'),
  ('P0000000-0000-0000-0000-000000000022', '2002-08-22', NULL, N'Besloten vennootschap'),
  ('P0000000-0000-0000-0000-000000000023', '1998-05-15', NULL, N'Besloten vennootschap met beperkte aansprakelijkheid'),
  ('P0000000-0000-0000-0000-000000000024', '2010-11-30', NULL, N'Commanditaire vennootschap'),
  ('P0000000-0000-0000-0000-000000000025', '1987-02-18', NULL, N'Societe anonyme'),
  ('P0000000-0000-0000-0000-000000000026', '2005-09-05', NULL, N'Naamloze vennootschap'),
  ('P0000000-0000-0000-0000-000000000027', '2012-07-12', NULL, N'Besloten vennootschap'),
  ('P0000000-0000-0000-0000-000000000028', '2000-04-25', NULL, N'Besloten vennootschap met beperkte aansprakelijkheid'),
  ('P0000000-0000-0000-0000-000000000029', '2015-01-08', NULL, N'Naamloze vennootschap'),
  ('P0000000-0000-0000-0000-000000000030', '2008-12-20', NULL, N'Besloten vennootschap');
GO

INSERT INTO EconomicActivity (economic_activity_id, person_id, profession, professional_status_code, kbo_number, vat_number)
VALUES
  ('EA000000-0000-0000-0000-000000000021', 'P0000000-0000-0000-0000-000000000021', N'Bouwbedrijf De Vries NV', 'SELF_EMPLOYED', N'BE 0400.123.456', N'BE 0400.123.456'),
  ('EA000000-0000-0000-0000-000000000022', 'P0000000-0000-0000-0000-000000000022', N'Peeters & Co BV', 'SELF_EMPLOYED', N'BE 0401.234.567', N'BE 0401.234.567'),
  ('EA000000-0000-0000-0000-000000000023', 'P0000000-0000-0000-0000-000000000023', N'Janssens Techniek BVBA', 'SELF_EMPLOYED', N'BE 0402.345.678', N'BE 0402.345.678'),
  ('EA000000-0000-0000-0000-000000000024', 'P0000000-0000-0000-0000-000000000024', N'Maes Consulting CV', 'SELF_EMPLOYED', N'BE 0403.456.789', N'BE 0403.456.789'),
  ('EA000000-0000-0000-0000-000000000025', 'P0000000-0000-0000-0000-000000000025', N'Willems Transport SA', 'SELF_EMPLOYED', N'BE 0404.567.890', N'BE 0404.567.890'),
  ('EA000000-0000-0000-0000-000000000026', 'P0000000-0000-0000-0000-000000000026', N'Mertens vastgoed NV', 'SELF_EMPLOYED', N'BE 0405.678.901', N'BE 0405.678.901'),
  ('EA000000-0000-0000-0000-000000000027', 'P0000000-0000-0000-0000-000000000027', N'Vermeulen Horeca BV', 'SELF_EMPLOYED', N'BE 0406.789.012', N'BE 0406.789.012'),
  ('EA000000-0000-0000-0000-000000000028', 'P0000000-0000-0000-0000-000000000028', N'De Smet Advocaten BVBA', 'SELF_EMPLOYED', N'BE 0407.890.123', N'BE 0407.890.123'),
  ('EA000000-0000-0000-0000-000000000029', 'P0000000-0000-0000-0000-000000000029', N'Jacobs IT Solutions NV', 'SELF_EMPLOYED', N'BE 0408.901.234', N'BE 0408.901.234'),
  ('EA000000-0000-0000-0000-000000000030', 'P0000000-0000-0000-0000-000000000030', N'Claes Logistics BV', 'SELF_EMPLOYED', N'BE 0409.012.345', N'BE 0409.012.345');
GO
PRINT '10 rechtspersonen ingevoerd.';
GO

-- =============================================================
-- SECTIE 3: Adressen (30 records)
-- =============================================================
PRINT 'Sectie 3: Adressen invoeren...';
GO

INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, remark, is_primary, created_at)
VALUES
  ('A0000000-0000-0000-0000-00000000A001', 'P0000000-0000-0000-0000-000000000001', 'RESIDENTIEE', N'Kerkstraat', N'15', N'A', '2800', N'Mechelen', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A002', 'P0000000-0000-0000-0000-000000000001', 'BEROEP', N'Nationalestraat', N'42', NULL, '2800', N'Mechelen', N'Belgie', 'BE', NULL, 0, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A003', 'P0000000-0000-0000-0000-000000000002', 'RESIDENTIEE', N'Avenue Louise', N'88', N'3', '1000', N'Brussel', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A004', 'P0000000-0000-0000-0000-000000000002', 'FACTURATIE', N'Rue Neuve', N'25', NULL, '1000', N'Brussel', N'Belgie', 'BE', NULL, 0, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A005', 'P0000000-0000-0000-0000-000000000003', 'RESIDENTIEE', N'Grote Markt', N'7', NULL, '2000', N'Antwerpen', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A006', 'P0000000-0000-0000-0000-000000000003', 'BEZOEK', N'Meir', N'112', N'2B', '2000', N'Antwerpen', N'Belgie', 'BE', NULL, 0, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A007', 'P0000000-0000-0000-0000-000000000004', 'RESIDENTIEE', N'Veldstraat', N'56', NULL, '9000', N'Gent', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A008', 'P0000000-0000-0000-0000-000000000005', 'RESIDENTIEE', N'Naamsestraat', N'73', N'C', '3000', N'Leuven', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A009', 'P0000000-0000-0000-0000-000000000006', 'RESIDENTIEE', N'Thonissenlaan', N'34', NULL, '3500', N'Hasselt', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A010', 'P0000000-0000-0000-0000-000000000006', 'KORRESPONDENTIE', N'Maastrichterstraat', N'18', N'1', '3500', N'Hasselt', N'Belgie', 'BE', NULL, 0, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A011', 'P0000000-0000-0000-0000-000000000007', 'RESIDENTIEE', N'Steenstraat', N'91', NULL, '8000', N'Brugge', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A012', 'P0000000-0000-0000-0000-000000000008', 'RESIDENTIEE', N'Leuvensesteenweg', N'205', N'D', '2800', N'Mechelen', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A013', 'P0000000-0000-0000-0000-000000000009', 'RESIDENTIEE', N'Wetstraat', N'16', NULL, '1000', N'Brussel', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A014', 'P0000000-0000-0000-0000-000000000009', 'BEROEP', N'Bellardstraat', N'37', N'5', '1000', N'Brussel', N'Belgie', 'BE', NULL, 0, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A015', 'P0000000-0000-0000-0000-000000000010', 'RESIDENTIEE', N'Keyserlei', N'48', NULL, '2000', N'Antwerpen', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A016', 'P0000000-0000-0000-0000-000000000011', 'RESIDENTIEE', N'Vlaanderenstraat', N'62', N'2', '9000', N'Gent', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A017', 'P0000000-0000-0000-0000-000000000012', 'RESIDENTIEE', N'Bondgenotenlaan', N'120', NULL, '3000', N'Leuven', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A018', 'P0000000-0000-0000-0000-000000000013', 'RESIDENTIEE', N'Maastrichterstraat', N'8', N'B', '3500', N'Hasselt', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A019', 'P0000000-0000-0000-0000-000000000014', 'RESIDENTIEE', N'Markt', N'22', NULL, '8000', N'Brugge', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A020', 'P0000000-0000-0000-0000-000000000015', 'RESIDENTIEE', N'Battelsesteenweg', N'145', NULL, '2800', N'Mechelen', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A021', 'P0000000-0000-0000-0000-000000000016', 'RESIDENTIEE', N'Avenue de Tervuren', N'55', N'4', '1000', N'Brussel', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A022', 'P0000000-0000-0000-0000-000000000017', 'RESIDENTIEE', N'Plantin en Moretuslei', N'89', NULL, '2000', N'Antwerpen', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A023', 'P0000000-0000-0000-0000-000000000018', 'RESIDENTIEE', N'Sint-Pietersnieuwstraat', N'77', N'3', '9000', N'Gent', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A024', 'P0000000-0000-0000-0000-000000000019', 'RESIDENTIEE', N'Diestsevest', N'44', NULL, '3000', N'Leuven', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A025', 'P0000000-0000-0000-0000-000000000020', 'RESIDENTIEE', N'Kapucijnenstraat', N'11', N'A', '8000', N'Brugge', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A026', 'P0000000-0000-0000-0000-000000000021', 'RESIDENTIEE', N'Industrielaan', N'55', NULL, '2800', N'Mechelen', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A027', 'P0000000-0000-0000-0000-000000000023', 'RESIDENTIEE', N'Technologielaan', N'12', N'B', '3000', N'Leuven', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A028', 'P0000000-0000-0000-0000-000000000025', 'RESIDENTIEE', N'Havenlaan', N'88', NULL, '2000', N'Antwerpen', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A029', 'P0000000-0000-0000-0000-000000000027', 'RESIDENTIEE', N'Groenplaats', N'33', N'2', '2000', N'Antwerpen', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('A0000000-0000-0000-0000-00000000A030', 'P0000000-0000-0000-0000-000000000029', 'RESIDENTIEE', N'Bruul', N'29', N'5E', '2800', N'Mechelen', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME());
GO
PRINT '30 adressen ingevoerd.';
GO

-- =============================================================
-- SECTIE 4: Telefoonnummers (25 records)
-- =============================================================
PRINT 'Sectie 4: Telefoonnummers invoeren...';
GO

INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, comment, created_at)
VALUES
  ('PH000000-0000-0000-0000-000000000001', 'P0000000-0000-0000-0000-000000000001', '+32 15 123 456', 'LANDLINE', 1, NULL, SYSUTCDATETIME()),
  ('PH000000-0000-0000-0000-000000000002', 'P0000000-0000-0000-0000-000000000001', '+32 478 12 34 56', 'MOBILE', 0, NULL, SYSUTCDATETIME()),
  ('PH000000-0000-0000-0000-000000000003', 'P0000000-0000-0000-0000-000000000002', '+32 2 234 5678', 'LANDLINE', 1, NULL, SYSUTCDATETIME()),
  ('PH000000-0000-0000-0000-000000000004', 'P0000000-0000-0000-0000-000000000002', '+32 495 23 45 67', 'MOBILE', 0, NULL, SYSUTCDATETIME()),
  ('PH000000-0000-0000-0000-000000000005', 'P0000000-0000-0000-0000-000000000003', '+32 3 345 6789', 'MOBILE', 1, NULL, SYSUTCDATETIME()),
  ('PH000000-0000-0000-0000-000000000006', 'P0000000-0000-0000-0000-000000000004', '+32 9 456 7890', 'LANDLINE', 1, NULL, SYSUTCDATETIME()),
  ('PH000000-0000-0000-0000-000000000007', 'P0000000-0000-0000-0000-000000000005', '+32 16 567 8901', 'MOBILE', 1, NULL, SYSUTCDATETIME()),
  ('PH000000-0000-0000-0000-000000000008', 'P0000000-0000-0000-0000-000000000006', '+32 11 678 9012', 'LANDLINE', 1, NULL, SYSUTCDATETIME()),
  ('PH000000-0000-0000-0000-000000000009', 'P0000000-0000-0000-0000-000000000006', '+32 477 34 56 78', 'MOBILE', 0, NULL, SYSUTCDATETIME()),
  ('PH000000-0000-0000-0000-000000000010', 'P0000000-0000-0000-0000-000000000007', '+32 50 789 0123', 'LANDLINE', 1, NULL, SYSUTCDATETIME()),
  ('PH000000-0000-0000-0000-000000000011', 'P0000000-0000-0000-0000-000000000008', '+32 15 890 1234', 'MOBILE', 1, NULL, SYSUTCDATETIME()),
  ('PH000000-0000-0000-0000-000000000012', 'P0000000-0000-0000-0000-000000000009', '+32 2 901 2345', 'LANDLINE', 1, NULL, SYSUTCDATETIME()),
  ('PH000000-0000-0000-0000-000000000013', 'P0000000-0000-0000-0000-000000000010', '+32 3 012 3456', 'MOBILE', 1, NULL, SYSUTCDATETIME()),
  ('PH000000-0000-0000-0000-000000000014', 'P0000000-0000-0000-0000-000000000011', '+32 9 123 4567', 'LANDLINE', 1, NULL, SYSUTCDATETIME()),
  ('PH000000-0000-0000-0000-000000000015', 'P0000000-0000-0000-0000-000000000012', '+32 16 234 5678', 'MOBILE', 1, NULL, SYSUTCDATETIME()),
  ('PH000000-0000-0000-0000-000000000016', 'P0000000-0000-0000-0000-000000000013', '+32 11 345 6789', 'LANDLINE', 1, NULL, SYSUTCDATETIME()),
  ('PH000000-0000-0000-0000-000000000017', 'P0000000-0000-0000-0000-000000000014', '+32 50 456 7890', 'MOBILE', 1, NULL, SYSUTCDATETIME()),
  ('PH000000-0000-0000-0000-000000000018', 'P0000000-0000-0000-0000-000000000015', '+32 15 567 8901', 'LANDLINE', 1, NULL, SYSUTCDATETIME()),
  ('PH000000-0000-0000-0000-000000000019', 'P0000000-0000-0000-0000-000000000016', '+32 2 678 9012', 'MOBILE', 1, NULL, SYSUTCDATETIME()),
  ('PH000000-0000-0000-0000-000000000020', 'P0000000-0000-0000-0000-000000000017', '+32 3 789 0123', 'LANDLINE', 1, NULL, SYSUTCDATETIME()),
  ('PH000000-0000-0000-0000-000000000021', 'P0000000-0000-0000-0000-000000000018', '+32 9 890 1234', 'MOBILE', 1, NULL, SYSUTCDATETIME()),
  ('PH000000-0000-0000-0000-000000000022', 'P0000000-0000-0000-0000-000000000019', '+32 16 901 2345', 'LANDLINE', 1, NULL, SYSUTCDATETIME()),
  ('PH000000-0000-0000-0000-000000000023', 'P0000000-0000-0000-0000-000000000020', '+32 11 012 3456', 'MOBILE', 1, NULL, SYSUTCDATETIME()),
  ('PH000000-0000-0000-0000-000000000024', 'P0000000-0000-0000-0000-000000000021', '+32 15 123 7890', 'LANDLINE', 1, NULL, SYSUTCDATETIME()),
  ('PH000000-0000-0000-0000-000000000025', 'P0000000-0000-0000-0000-000000000021', '+32 479 56 78 90', 'MOBILE', 0, NULL, SYSUTCDATETIME());
GO
PRINT '25 telefoonnummers ingevoerd.';
GO

-- =============================================================
-- SECTIE 5: E-mailadressen (25 records)
-- =============================================================
PRINT 'Sectie 5: E-mailadressen invoeren...';
GO

INSERT INTO Email (email_id, person_id, email, comment)
VALUES
  ('EM000000-0000-0000-0000-000000000001', 'P0000000-0000-0000-0000-000000000001', 'jan.devries@gmail.com', NULL),
  ('EM000000-0000-0000-0000-000000000002', 'P0000000-0000-0000-0000-000000000002', 'marie.peeters@outlook.com', NULL),
  ('EM000000-0000-0000-0000-000000000003', 'P0000000-0000-0000-0000-000000000003', 'pieter.janssens@telenet.be', NULL),
  ('EM000000-0000-0000-0000-000000000004', 'P0000000-0000-0000-0000-000000000004', 'sofie.maes@gmail.com', NULL),
  ('EM000000-0000-0000-0000-000000000005', 'P0000000-0000-0000-0000-000000000005', 'thomas.willems@outlook.com', NULL),
  ('EM000000-0000-0000-0000-000000000006', 'P0000000-0000-0000-0000-000000000006', 'ann.mertens@telenet.be', NULL),
  ('EM000000-0000-0000-0000-000000000007', 'P0000000-0000-0000-0000-000000000007', 'luc.vermeulen@gmail.com', NULL),
  ('EM000000-0000-0000-0000-000000000008', 'P0000000-0000-0000-0000-000000000008', 'eva.desmet@outlook.com', NULL),
  ('EM000000-0000-0000-0000-000000000009', 'P0000000-0000-0000-0000-000000000009', 'bart.jacobs@telenet.be', NULL),
  ('EM000000-0000-0000-0000-000000000010', 'P0000000-0000-0000-0000-000000000010', 'karin.claes@gmail.com', NULL),
  ('EM000000-0000-0000-0000-000000000011', 'P0000000-0000-0000-0000-000000000011', 'steven.goossens@outlook.com', NULL),
  ('EM000000-0000-0000-0000-000000000012', 'P0000000-0000-0000-0000-000000000012', 'inge.lamberts@telenet.be', NULL),
  ('EM000000-0000-0000-0000-000000000013', 'P0000000-0000-0000-0000-000000000013', 'patrick.wouters@gmail.com', NULL),
  ('EM000000-0000-0000-0000-000000000014', 'P0000000-0000-0000-0000-000000000014', 'nathalie.dubois@outlook.com', NULL),
  ('EM000000-0000-0000-0000-000000000015', 'P0000000-0000-0000-0000-000000000015', 'marc.hendricks@telenet.be', NULL),
  ('EM000000-0000-0000-0000-000000000016', 'P0000000-0000-0000-0000-000000000016', 'sandra.martens@gmail.com', NULL),
  ('EM000000-0000-0000-0000-000000000017', 'P0000000-0000-0000-0000-000000000017', 'dirk.peters@outlook.com', NULL),
  ('EM000000-0000-0000-0000-000000000018', 'P0000000-0000-0000-0000-000000000018', 'christel.aerts@telenet.be', NULL),
  ('EM000000-0000-0000-0000-000000000019', 'P0000000-0000-0000-0000-000000000019', 'frank.smets@gmail.com', NULL),
  ('EM000000-0000-0000-0000-000000000020', 'P0000000-0000-0000-0000-000000000020', 'isabelle.bosmans@outlook.com', NULL),
  ('EM000000-0000-0000-0000-000000000021', 'P0000000-0000-0000-0000-000000000021', 'info@bouwdevriesnv.be', NULL),
  ('EM000000-0000-0000-0000-000000000022', 'P0000000-0000-0000-0000-000000000023', 'contact@janssenstechniek.be', NULL),
  ('EM000000-0000-0000-0000-000000000023', 'P0000000-0000-0000-0000-000000000025', 'info@willemstransport.be', NULL),
  ('EM000000-0000-0000-0000-000000000024', 'P0000000-0000-0000-0000-000000000027', 'info@vermeulenhoreca.be', NULL),
  ('EM000000-0000-0000-0000-000000000025', 'P0000000-0000-0000-0000-000000000029', 'contact@jacobsit.be', NULL);
GO
PRINT '25 e-mailadressen ingevoerd.';
GO

-- =============================================================
-- SECTIE 6: Instellingen (10 records)
-- =============================================================
PRINT 'Sectie 6: Instellingen invoeren...';
GO

INSERT INTO Institution (institution_id, institution_code, name, created_at, updated_at)
VALUES
  ('I0000000-0000-0000-0000-000000000001', 'ETHIAS', N'Ethias Verzekeringen', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('I0000000-0000-0000-0000-000000000002', 'AXA_BE', N'AXA Belgium', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('I0000000-0000-0000-0000-000000000003', 'AG_INS', N'AG Insurance', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('I0000000-0000-0000-0000-000000000004', 'BPOST_INS', N'bpost insurance', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('I0000000-0000-0000-0000-000000000005', 'ALLIANZ_BE', N'Allianz Belgium', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('I0000000-0000-0000-0000-000000000006', 'KBC_VERZ', N'KBC Verzekeringen', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('I0000000-0000-0000-0000-000000000007', 'FIDEA', N'Fidea Verzekeringen', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('I0000000-0000-0000-0000-000000000008', 'DELA_BE', N'Dela Belgium', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('I0000000-0000-0000-0000-000000000009', 'DSV', N'DSV Verzekeringen', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('I0000000-0000-0000-0000-000000000010', 'PARTEN_RE', N'Partena Rechtstreekse Verzekeringen', SYSUTCDATETIME(), SYSUTCDATETIME());
GO

INSERT INTO InstitutionIdentifier (institution_id, id_type_code, id_value, valid_from, valid_to)
VALUES
  ('I0000000-0000-0000-0000-000000000001', 'KBO', '0403.444.555', '2020-01-01', NULL),
  ('I0000000-0000-0000-0000-000000000002', 'KBO', '0404.555.666', '2020-01-01', NULL),
  ('I0000000-0000-0000-0000-000000000003', 'KBO', '0405.666.777', '2020-01-01', NULL),
  ('I0000000-0000-0000-0000-000000000004', 'KBO', '0406.777.888', '2020-01-01', NULL),
  ('I0000000-0000-0000-0000-000000000005', 'KBO', '0407.888.999', '2020-01-01', NULL);
GO

INSERT INTO InstitutionAddress (institution_address_id, institution_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, remark, is_primary, created_at)
VALUES
  ('IA000000-0000-0000-0000-00000000001', 'I0000000-0000-0000-0000-000000000001', 'HQ', N'Rue des Croisiers', N'24', NULL, '4000', N'Luik', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('IA000000-0000-0000-0000-00000000002', 'I0000000-0000-0000-0000-000000000002', 'HQ', N'Boulevard du Roi Albert II', N'33', N'5', '1030', N'Brussel', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('IA000000-0000-0000-0000-00000000003', 'I0000000-0000-0000-0000-000000000003', 'HQ', N'Boulevard Emile Jacqmain', N'53', NULL, '1000', N'Brussel', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('IA000000-0000-0000-0000-00000000004', 'I0000000-0000-0000-0000-000000000004', 'HQ', N'Muntcentrum', N'1', NULL, '1000', N'Brussel', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME()),
  ('IA000000-0000-0000-0000-00000000005', 'I0000000-0000-0000-0000-000000000005', 'HQ', N'Prins Boudewijnlaan', N'50', NULL, '2650', N'Edegem', N'Belgie', 'BE', NULL, 1, SYSUTCDATETIME());
GO
PRINT '10 instellingen ingevoerd.';
GO

-- =============================================================
-- SECTIE 7: Objecten (30 records)
-- =============================================================
PRINT 'Sectie 7: Objecten invoeren...';
GO

-- ObjectType GUIDs ophalen (nieuwe batch, dus opnieuw declareren)
DECLARE @VehicleTypeId UNIQUEIDENTIFIER = (SELECT object_type_id FROM ObjectType WHERE code = 'VEHICLE');
DECLARE @RealEstateTypeId UNIQUEIDENTIFIER = (SELECT object_type_id FROM ObjectType WHERE code = 'REAL_ESTATE');
DECLARE @PersonTypeIdObj UNIQUEIDENTIFIER = (SELECT object_type_id FROM ObjectType WHERE code = 'PERSON');
DECLARE @ThingTypeId UNIQUEIDENTIFIER = (SELECT object_type_id FROM ObjectType WHERE code = 'THING');
DECLARE @ActivityTypeId UNIQUEIDENTIFIER = (SELECT object_type_id FROM ObjectType WHERE code = 'ACTIVITY');
DECLARE @LoanTypeId UNIQUEIDENTIFIER = (SELECT object_type_id FROM ObjectType WHERE code = 'LOAN');
GO

-- 12 Voertuigen
DECLARE @VehicleTypeId UNIQUEIDENTIFIER = (SELECT object_type_id FROM ObjectType WHERE code = 'VEHICLE');
INSERT INTO Object (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES
  ('O0000000-0000-0000-0000-000000000001', @VehicleTypeId, N'Personenwagen Toyota Corolla', 'ACTIVE', '2023-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('O0000000-0000-0000-0000-000000000002', @VehicleTypeId, N'Personenwagen BMW 3-Reeks', 'ACTIVE', '2022-06-15', NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('O0000000-0000-0000-0000-000000000003', @VehicleTypeId, N'Bedrijfswagen Volkswagen Transporter', 'ACTIVE', '2023-03-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('O0000000-0000-0000-0000-000000000004', @VehicleTypeId, N'Motorfiets Honda CB500', 'ACTIVE', '2021-08-20', NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('O0000000-0000-0000-0000-000000000005', @VehicleTypeId, N'Personenwagen Mercedes A-Klasse', 'ACTIVE', '2023-05-10', NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('O0000000-0000-0000-0000-000000000006', @VehicleTypeId, N'Personenwagen Peugeot 208', 'ACTIVE', '2022-11-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('O0000000-0000-0000-0000-000000000007', @VehicleTypeId, N'Lichte vrachtwagen Ford Transit', 'ACTIVE', '2023-02-15', NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('O0000000-0000-0000-0000-000000000008', @VehicleTypeId, N'Personenwagen Audi A4', 'ACTIVE', '2022-04-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('O0000000-0000-0000-0000-000000000009', @VehicleTypeId, N'Bromfiets Vespa Primavera', 'ACTIVE', '2023-07-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('O0000000-0000-0000-0000-000000000010', @VehicleTypeId, N'Personenwagen Renault Clio', 'ACTIVE', '2021-12-10', NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('O0000000-0000-0000-0000-000000000011', @VehicleTypeId, N'Bedrijfswagen Mercedes Sprinter', 'ACTIVE', '2023-04-20', NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('O0000000-0000-0000-0000-000000000012', @VehicleTypeId, N'Personenwagen Volvo XC60', 'ACTIVE', '2022-09-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
GO

INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, insured_value_ex_vat, engine_cc, power_kw)
VALUES
  ('O0000000-0000-0000-0000-000000000001', 'PERSONENWAGEN', 'PRIVWG', 'EUROPEES', N'Toyota', N'Corolla', N'JTDBU4EE1B9123456', 2022, '2023-01-01', '2023-01-01', '1-ABC-234', 'BENZINE', 'VOORWIEL', 0, 18500.00, 1598, 97),
  ('O0000000-0000-0000-0000-000000000002', 'PERSONENWAGEN', 'PRIVWG', 'EUROPEES', N'BMW', N'320i', N'WBA8E9C52JK123456', 2022, '2022-06-15', '2022-06-15', '1-BCD-345', 'BENZINE', 'ACHTERWIEL', 0, 28500.00, 1998, 135),
  ('O0000000-0000-0000-0000-000000000003', 'BESTELWAGEN', 'BEROEP', 'EUROPEES', N'Volkswagen', N'Transporter', N'WV1ZZZ7HZPH123456', 2023, '2023-03-01', '2023-03-01', '1-CDE-456', 'DIESEL', 'VOORWIEL', 1, 32500.00, 1968, 110),
  ('O0000000-0000-0000-0000-000000000004', 'MOTORFIETS', 'PRIVWG', 'EUROPEES', N'Honda', N'CB500', N'MLHPC5608K5123456', 2021, '2021-08-20', '2021-08-20', '1-DEF-567', 'BENZINE', 'TWEEWIEL', 0, 5800.00, 471, 35),
  ('O0000000-0000-0000-0000-000000000005', 'PERSONENWAGEN', 'PRIVWG', 'EUROPEES', N'Mercedes', N'A 180', N'WDD1770841J123456', 2023, '2023-05-10', '2023-05-10', '1-EFG-678', 'BENZINE', 'VOORWIEL', 1, 24500.00, 1332, 100),
  ('O0000000-0000-0000-0000-000000000006', 'PERSONENWAGEN', 'PRIVWG', 'EUROPEES', N'Peugeot', N'208', N'VR3UPHNSKLJ123456', 2022, '2022-11-01', '2022-11-01', '1-FGH-789', 'DIESEL', 'VOORWIEL', 0, 16500.00, 1499, 74),
  ('O0000000-0000-0000-0000-000000000007', 'BESTELWAGEN', 'BEROEP', 'EUROPEES', N'Ford', N'Transit', N'WF0XXXERGXJK12345', 2023, '2023-02-15', '2023-02-15', '1-GHI-890', 'DIESEL', 'ACHTERWIEL', 1, 29500.00, 1995, 96),
  ('O0000000-0000-0000-0000-000000000008', 'PERSONENWAGEN', 'PRIVWG', 'EUROPEES', N'Audi', N'A4', N'WAUZZZ8K5FN123456', 2022, '2022-04-01', '2022-04-01', '1-HIJ-901', 'DIESEL', 'VIERWIEL', 0, 31500.00, 1968, 120),
  ('O0000000-0000-0000-0000-000000000009', 'BROMFIETS', 'PRIVWG', 'EUROPEES', N'Vespa', N'Primavera 125', N'ZAPCA010000012345', 2023, '2023-07-01', '2023-07-01', '1-IJK-012', 'BENZINE', NULL, 0, 3200.00, 124, 9),
  ('O0000000-0000-0000-0000-000000000010', 'PERSONENWAGEN', 'PRIVWG', 'EUROPEES', N'Renault', N'Clio', N'VF1R9800X63123456', 2021, '2021-12-10', '2021-12-10', '1-JKL-123', 'BENZINE', 'VOORWIEL', 0, 14500.00, 999, 49),
  ('O0000000-0000-0000-0000-000000000011', 'VRACHTWAGEN', 'BEROEP', 'EUROPEES', N'Mercedes', N'Sprinter 316', N'W1V9076651K123456', 2023, '2023-04-20', '2023-04-20', '1-KLM-234', 'DIESEL', 'ACHTERWIEL', 1, 38500.00, 2143, 120),
  ('O0000000-0000-0000-0000-000000000012', 'PERSONENWAGEN', 'PRIVWG', 'EUROPEES', N'Volvo', N'XC60', N'YV1UZA6DCK1234567', 2022, '2022-09-01', '2022-09-01', '1-LMN-345', 'HYBRIDE', 'VIERWIEL', 0, 42500.00, 1969, 184);
GO

-- 8 Onroerende goederen
DECLARE @RealEstateTypeId UNIQUEIDENTIFIER = (SELECT object_type_id FROM ObjectType WHERE code = 'REAL_ESTATE');
INSERT INTO Object (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES
  ('O0000000-0000-0000-0000-000000000013', @RealEstateTypeId, N'Eengezinswoning Mechelen', 'ACTIVE', '2020-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('O0000000-0000-0000-0000-000000000014', @RealEstateTypeId, N'Appartement Brussel', 'ACTIVE', '2021-06-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('O0000000-0000-0000-0000-000000000015', @RealEstateTypeId, N'Winkelruimte Antwerpen', 'ACTIVE', '2019-03-15', NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('O0000000-0000-0000-0000-000000000016', @RealEstateTypeId, N'Villa Brugge', 'ACTIVE', '2018-08-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('O0000000-0000-0000-0000-000000000017', @RealEstateTypeId, N'Kantoorgebouw Gent', 'ACTIVE', '2022-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('O0000000-0000-0000-0000-000000000018', @RealEstateTypeId, N'Appartement Leuven', 'ACTIVE', '2021-04-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('O0000000-0000-0000-0000-000000000019', @RealEstateTypeId, N'Magazijn Hasselt', 'ACTIVE', '2020-09-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('O0000000-0000-0000-0000-000000000020', @RealEstateTypeId, N'Eengezinswoning Antwerpen', 'ACTIVE', '2019-11-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
GO

INSERT INTO ObjectRealEstate (object_id, realestate_type_code, description, use_type_code, insured_role_code, is_risk_address_policyholder, residence_type_code, destination_type_code, street, number, box, postal_code, city, country_code, adjacency_type_code, occupancy_level_code, construction_type_code, roof_type_code, build_year, is_under_construction, floors_count, apartment_count, has_solar_panels, has_flammable_materials, capital_building)
VALUES
  ('O0000000-0000-0000-0000-000000000013', 'GEBOUW', N'Eengezinswoning Mechelen', 'PRIVAAT', 'EIGENAAR', 1, 'EENGEZINSWONING', 'PRIVAAT', N'Kerkstraat', N'25', NULL, '2800', N'Mechelen', 'BE', 'ALLEENSTAAND', 'REGELMATIGE_BEWONING', 'HARDE_MATERIALEN', 'TRADITIONEEL', 2005, 0, 2, 1, 0, 0, 325000.00),
  ('O0000000-0000-0000-0000-000000000014', 'GEBOUW', N'Appartement Brussel', 'PRIVAAT', 'EIGENAAR_UITBATER', 1, 'APPARTEMENT', 'PRIVAAT', N'Avenue Louise', N'120', N'8', '1000', N'Brussel', 'BE', 'BEIDE_ZIJDEN', 'REGELMATIGE_BEWONING', 'HARDE_MATERIALEN', 'TRADITIONEEL', 1995, 0, 6, 24, 0, 0, 285000.00),
  ('O0000000-0000-0000-0000-000000000015', 'GEBOUW', N'Winkelruimte Antwerpen', 'HANDEL', 'EIGENAAR_UITBATER', 1, NULL, 'HANDELSHUIS', N'Meir', N'45', NULL, '2000', N'Antwerpen', 'BE', 'BELENDEND', 'REGELMATIGE_BEWONING', 'HARDE_MATERIALEN', 'TRADITIONEEL', 1980, 0, 3, 2, 0, 0, 450000.00),
  ('O0000000-0000-0000-0000-000000000016', 'GEBOUW', N'Villa Brugge', 'PRIVAAT', 'EIGENAAR', 1, 'VILLA', 'PRIVAAT', N'Duinbergenlaan', N'88', NULL, '8000', N'Brugge', 'BE', 'ALLEENSTAAND_GT_50M', 'REGELMATIGE_BEWONING', 'HARDE_MATERIALEN', 'TRADITIONEEL', 2010, 0, 2, 1, 1, 0, 685000.00),
  ('O0000000-0000-0000-0000-000000000017', 'GEBOUW', N'Kantoorgebouw Gent', 'BEROEP', 'EIGENAAR_UITBATER', 1, NULL, 'BURELEN', N'Kortrijksesteenweg', N'250', NULL, '9000', N'Gent', 'BE', 'BELENDEND', 'REGELMATIGE_BEWONING', 'HARDE_MATERIALEN', 'TRADITIONEEL', 2008, 0, 4, 8, 1, 0, 750000.00),
  ('O0000000-0000-0000-0000-000000000018', 'GEBOUW', N'Appartement Leuven', 'PRIVAAT', 'EIGENAAR', 1, 'APPARTEMENT', 'PRIVAAT', N'Diestsestraat', N'55', N'3', '3000', N'Leuven', 'BE', 'BEIDE_ZIJDEN', 'REGELMATIGE_BEWONING', 'HARDE_MATERIALEN', 'TRADITIONEEL', 2015, 0, 4, 12, 0, 0, 245000.00),
  ('O0000000-0000-0000-0000-000000000019', 'GEBOUW', N'Magazijn Hasselt', 'HANDEL', 'EIGENAAR', 1, NULL, 'MAGAZIJN', N'Industrielaan', N'42', NULL, '3500', N'Hasselt', 'BE', 'ALLEENSTAAND_GT_20M', 'REGELMATIGE_BEWONING', 'INDUSTRIELE_LOODS', 'TRADITIONEEL', 1998, 0, 1, 1, 0, 0, 520000.00),
  ('O0000000-0000-0000-0000-000000000020', 'GEBOUW', N'Eengezinswoning Antwerpen', 'PRIVAAT', 'EIGENAAR', 1, 'EENGEZINSWONING', 'PRIVAAT', N'Grotesteenweg', N'77', NULL, '2000', N'Antwerpen', 'BE', 'EEN_ZIJDE_GEDEELTELIJK_BELENDEND', 'REGELMATIGE_BEWONING', 'HARDE_MATERIALEN', 'TRADITIONEEL', 1992, 0, 3, 1, 0, 0, 295000.00);
GO

-- 4 Zaken
DECLARE @ThingTypeId UNIQUEIDENTIFIER = (SELECT object_type_id FROM ObjectType WHERE code = 'THING');
INSERT INTO Object (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES
  ('O0000000-0000-0000-0000-000000000021', @ThingTypeId, N'Inboedel woonst Mechelen', 'ACTIVE', '2023-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('O0000000-0000-0000-0000-000000000022', @ThingTypeId, N'Bedrijfsuitrusting bouwbedrijf', 'ACTIVE', '2022-06-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('O0000000-0000-0000-0000-000000000023', @ThingTypeId, N'Elektronische apparatuur kantoor', 'ACTIVE', '2023-03-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('O0000000-0000-0000-0000-000000000024', @ThingTypeId, N'Machines productielijn', 'ACTIVE', '2021-08-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
GO

INSERT INTO ObjectThing (object_id, subtype_code, description, brand, model, serial_number, value_insured, value_new, risk_category_code, material_type_code)
VALUES
  ('O0000000-0000-0000-0000-000000000021', 'INBOEDEL', N'Inboedel woonst Mechelen', NULL, NULL, NULL, 85000.00, 95000.00, 'MEDIUM', 'GEMENGD'),
  ('O0000000-0000-0000-0000-000000000022', 'BEDRIJFSUITR', N'Bedrijfsuitrusting bouwbedrijf', NULL, NULL, NULL, 125000.00, 150000.00, 'HIGH', 'METAAL'),
  ('O0000000-0000-0000-0000-000000000023', 'ACCESSOIRES', N'Elektronische apparatuur kantoor', NULL, NULL, NULL, 35000.00, 42000.00, 'MEDIUM', 'GEMENGD'),
  ('O0000000-0000-0000-0000-000000000024', 'MACHINES', N'Machines productielijn', NULL, NULL, NULL, 180000.00, 220000.00, 'HIGH', 'METAAL');
GO

-- 3 Personen-objecten (Arbeidsongevallen)
DECLARE @PersonTypeIdObj UNIQUEIDENTIFIER = (SELECT object_type_id FROM ObjectType WHERE code = 'PERSON');
INSERT INTO Object (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES
  ('O0000000-0000-0000-0000-000000000025', @PersonTypeIdObj, N'Personeelsleden bouwbedrijf De Vries', 'ACTIVE', '2023-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('O0000000-0000-0000-0000-000000000026', @PersonTypeIdObj, N'Bedienden transportbedrijf', 'ACTIVE', '2023-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('O0000000-0000-0000-0000-000000000027', @PersonTypeIdObj, N'Personeel horecazaak', 'ACTIVE', '2023-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
GO

INSERT INTO ObjectPerson (object_id, subtype_code, description, is_policyholder, worker_risk_class_code, employee_risk_class_code, person_count, nacebel_code)
VALUES
  ('O0000000-0000-0000-0000-000000000025', 'GROEP_ARB', N'Personeelsleden bouwbedrijf De Vries', 0, 'WERF', NULL, 15, '41201'),
  ('O0000000-0000-0000-0000-000000000026', 'GROEP_BED', N'Bedienden transportbedrijf', 0, NULL, 'CHAUFFEUR', 8, '49410'),
  ('O0000000-0000-0000-0000-000000000027', 'GROEP_BED', N'Personeel horecazaak', 0, NULL, 'MANUEEL', 12, '56101');
GO

-- 2 Leningen
DECLARE @LoanTypeId UNIQUEIDENTIFIER = (SELECT object_type_id FROM ObjectType WHERE code = 'LOAN');
INSERT INTO Object (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES
  ('O0000000-0000-0000-0000-000000000028', @LoanTypeId, N'Woonkrediet Mechelen', 'ACTIVE', '2020-01-01', '2040-01-01', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('O0000000-0000-0000-0000-000000000029', @LoanTypeId, N'Investeringskrediet bedrijf', 'ACTIVE', '2022-06-01', '2027-06-01', SYSUTCDATETIME(), SYSUTCDATETIME());
GO

INSERT INTO ObjectLoan (object_id, principal_amount, interest_rate_pct, interest_periodicity_code, duration_type_code, start_date, end_date, remark)
VALUES
  ('O0000000-0000-0000-0000-000000000028', 285000.00, 3.25, 'MAANDELIJKS', 'JAREN', '2020-01-01', '2040-01-01', N'Woonkrediet Eengezinswoning Mechelen'),
  ('O0000000-0000-0000-0000-000000000029', 150000.00, 4.10, 'MAANDELIJKS', 'JAREN', '2022-06-01', '2027-06-01', N'Investeringskrediet materieel');
GO

-- 1 Activiteit
DECLARE @ActivityTypeId UNIQUEIDENTIFIER = (SELECT object_type_id FROM ObjectType WHERE code = 'ACTIVITY');
INSERT INTO Object (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES
  ('O0000000-0000-0000-0000-000000000030', @ActivityTypeId, N'Bedrijfsevenement jaarlijks', 'ACTIVE', '2024-06-15', '2024-06-16', SYSUTCDATETIME(), SYSUTCDATETIME());
GO

INSERT INTO ObjectActivity (object_id, activity_type_code, description, start_datetime, end_datetime, participant_count, age_category_code, risk_level_code, location_street, location_number, location_postal_code, location_city)
VALUES
  ('O0000000-0000-0000-0000-000000000030', 'EVENEMENT', N'Bedrijfsevenement jaarlijks', '2024-06-15T09:00:00', '2024-06-16T18:00:00', 150, 'VOLW', 'MEDIUM_RL', N'Evenementenlaan', N'10', '2800', N'Mechelen');
GO
PRINT '30 objecten ingevoerd (12 voertuigen, 8 onroerende goederen, 4 zaken, 3 personen, 2 leningen, 1 activiteit).';
GO

-- =============================================================
-- SECTIE 8: Contracten (20 records)
-- =============================================================
PRINT 'Sectie 8: Contracten invoeren...';
GO

INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES
  ('C0000000-0000-0000-0000-000000000001', 'POL-2023-0001', 'AUTO', 'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', 'LOPEND', 'I0000000-0000-0000-0000-000000000001', 'I0000000-0000-0000-0000-000000000002', '2023-01-01', '2024-01-01', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000002', 'POL-2023-0002', 'AUTO', 'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', 'LOPEND', 'I0000000-0000-0000-0000-000000000002', 'I0000000-0000-0000-0000-000000000003', '2023-01-01', '2024-01-01', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000003', 'POL-2023-0003', 'AUTO', 'AUTO_LICHTE_VRACHTWAGENS', 'LOPEND', 'I0000000-0000-0000-0000-000000000003', 'I0000000-0000-0000-0000-000000000001', '2023-03-01', '2024-03-01', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000004', 'POL-2023-0004', 'AUTO', 'AUTO_MOTORFIETSEN', 'LOPEND', 'I0000000-0000-0000-0000-000000000001', 'I0000000-0000-0000-0000-000000000004', '2023-04-01', '2024-04-01', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000005', 'POL-2023-0005', 'AUTO', 'AUTO_VRACHTWAGENS_V_E_R_VERVOER_EIGEN_REK', 'LOPEND', 'I0000000-0000-0000-0000-000000000001', 'I0000000-0000-0000-0000-000000000005', '2023-05-01', '2024-05-01', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000006', 'POL-2023-0006', 'AUTO', 'AUTO_VERKEER_EN_INZITTENDEN', 'LOPEND', 'I0000000-0000-0000-0000-000000000004', 'I0000000-0000-0000-0000-000000000006', '2023-01-01', '2024-01-01', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000007', 'POL-2023-0007', 'AUTO', 'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', 'LOPEND', 'I0000000-0000-0000-0000-000000000005', 'I0000000-0000-0000-0000-000000000007', '2023-02-01', '2024-02-01', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000008', 'POL-2023-0008', 'BRAND_BIJZONDERE', 'BRAND_BZ_BEDRIJF', 'LOPEND', 'I0000000-0000-0000-0000-000000000006', 'I0000000-0000-0000-0000-000000000008', '2022-06-15', '2023-06-15', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000009', 'POL-2023-0009', 'LEVEN_BELEGGINGEN', 'LEVEN_OVERLIJDEN', 'LOPEND', 'I0000000-0000-0000-0000-000000000007', 'I0000000-0000-0000-0000-000000000009', '2023-01-01', '2028-01-01', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000010', 'POL-2023-0010', 'HOSPITALISATIE', 'HOSP_PARTICULIER', 'LOPEND', 'I0000000-0000-0000-0000-000000000008', 'I0000000-0000-0000-0000-000000000010', '2023-01-01', '2024-01-01', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000011', 'POL-2023-0011', 'ARBEIDSONGEVALLEN_COLLECTIEF', 'AUTO_VERKEER_EN_INZITTENDEN', 'LOPEND', 'I0000000-0000-0000-0000-000000000009', 'I0000000-0000-0000-0000-000000000001', '2023-01-01', '2024-01-01', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000012', 'POL-2023-0012', 'RECHTSBIJSTAND', 'RECHTS_PART', 'LOPEND', 'I0000000-0000-0000-0000-000000000010', 'I0000000-0000-0000-0000-000000000002', '2023-03-01', '2024-03-01', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000013', 'POL-2023-0013', 'LENING', 'LENING_HYPOTHECAIR', 'LOPEND', 'I0000000-0000-0000-0000-000000000006', 'I0000000-0000-0000-0000-000000000003', '2020-01-01', '2040-01-01', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000014', 'POL-2023-0014', 'REIS', 'REIS_KORT', 'LOPEND', 'I0000000-0000-0000-0000-000000000004', 'I0000000-0000-0000-0000-000000000005', '2023-06-01', '2024-06-01', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000015', 'POL-2023-0015', 'AUTO', 'AUTO_BROMFIETSEN', 'LOPEND', 'I0000000-0000-0000-0000-000000000001', 'I0000000-0000-0000-0000-000000000006', '2023-01-01', '2024-01-01', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000016', 'POL-2023-0016', 'BRAND_EENVOUDIG', 'BRAND_EG_WONING', 'LOPEND', 'I0000000-0000-0000-0000-000000000003', 'I0000000-0000-0000-0000-000000000007', '2023-01-01', '2024-01-01', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000017', 'POL-2023-0017', 'AUTO', 'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', 'LOPEND', 'I0000000-0000-0000-0000-000000000002', 'I0000000-0000-0000-0000-000000000008', '2023-07-01', '2024-07-01', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000018', 'POL-2023-0018', 'BRAND_EENVOUDIG', 'BRAND_EG_APP', 'LOPEND', 'I0000000-0000-0000-0000-000000000005', 'I0000000-0000-0000-0000-000000000009', '2023-01-01', '2024-01-01', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000019', 'POL-2023-0019', 'HOSPITALISATIE', 'HOSP_ZIEKENFONDS', 'LOPEND', 'I0000000-0000-0000-0000-000000000007', 'I0000000-0000-0000-0000-000000000010', '2023-01-01', '2024-01-01', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000020', 'POL-2023-0020', 'LEVEN_BELEGGINGEN', 'LEVEN_SPL', 'LOPEND', 'I0000000-0000-0000-0000-000000000008', 'I0000000-0000-0000-0000-000000000001', '2023-01-01', '2028-01-01', SYSUTCDATETIME(), SYSUTCDATETIME());
GO

INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES
  ('C0000000-0000-0000-0000-000000000001', 'P0000000-0000-0000-0000-000000000001', 'POLICYHOLDER', 1, SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000002', 'P0000000-0000-0000-0000-000000000002', 'POLICYHOLDER', 1, SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000003', 'P0000000-0000-0000-0000-000000000021', 'POLICYHOLDER', 1, SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000004', 'P0000000-0000-0000-0000-000000000003', 'POLICYHOLDER', 1, SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000005', 'P0000000-0000-0000-0000-000000000021', 'POLICYHOLDER', 1, SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000006', 'P0000000-0000-0000-0000-000000000013', 'POLICYHOLDER', 1, SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000007', 'P0000000-0000-0000-0000-000000000014', 'POLICYHOLDER', 1, SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000008', 'P0000000-0000-0000-0000-000000000021', 'POLICYHOLDER', 1, SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000009', 'P0000000-0000-0000-0000-000000000001', 'POLICYHOLDER', 1, SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000010', 'P0000000-0000-0000-0000-000000000006', 'POLICYHOLDER', 1, SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000011', 'P0000000-0000-0000-0000-000000000021', 'POLICYHOLDER', 1, SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000012', 'P0000000-0000-0000-0000-000000000015', 'POLICYHOLDER', 1, SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000013', 'P0000000-0000-0000-0000-000000000001', 'BORROWER', 1, SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000014', 'P0000000-0000-0000-0000-000000000004', 'POLICYHOLDER', 1, SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000015', 'P0000000-0000-0000-0000-000000000005', 'POLICYHOLDER', 1, SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000016', 'P0000000-0000-0000-0000-000000000008', 'POLICYHOLDER', 1, SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000017', 'P0000000-0000-0000-0000-000000000007', 'POLICYHOLDER', 1, SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000018', 'P0000000-0000-0000-0000-000000000019', 'POLICYHOLDER', 1, SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000019', 'P0000000-0000-0000-0000-000000000020', 'POLICYHOLDER', 1, SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000020', 'P0000000-0000-0000-0000-000000000011', 'POLICYHOLDER', 1, SYSUTCDATETIME());
GO

INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES
  ('C0000000-0000-0000-0000-000000000001', 'O0000000-0000-0000-0000-000000000001', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000002', 'O0000000-0000-0000-0000-000000000002', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000003', 'O0000000-0000-0000-0000-000000000003', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000004', 'O0000000-0000-0000-0000-000000000004', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000005', 'O0000000-0000-0000-0000-000000000007', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000006', 'O0000000-0000-0000-0000-000000000013', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000007', 'O0000000-0000-0000-0000-000000000014', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000008', 'O0000000-0000-0000-0000-000000000015', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000009', 'O0000000-0000-0000-0000-000000000001', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000010', 'O0000000-0000-0000-0000-000000000006', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000011', 'O0000000-0000-0000-0000-000000000025', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000012', 'O0000000-0000-0000-0000-000000000001', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000013', 'O0000000-0000-0000-0000-000000000028', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000014', 'O0000000-0000-0000-0000-000000000004', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000015', 'O0000000-0000-0000-0000-000000000009', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000016', 'O0000000-0000-0000-0000-000000000017', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000017', 'O0000000-0000-0000-0000-000000000008', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000018', 'O0000000-0000-0000-0000-000000000019', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000019', 'O0000000-0000-0000-0000-000000000008', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('C0000000-0000-0000-0000-000000000020', 'O0000000-0000-0000-0000-000000000012', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
GO
PRINT '20 contracten ingevoerd.';
GO

-- =============================================================
-- SECTIE 9: Schadeclaims (15 records)
-- =============================================================
PRINT 'Sectie 9: Schadeclaims invoeren...';
GO

INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, claims_handler_id, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES
  ('CL000000-0000-0000-0000-00000000001', 'SCH-2023-0001', 'C0000000-0000-0000-0000-000000000001', 'CASCO_VAN_HET_VERVOERMIDDEL', 'AFGEHANDELD', 'P0000000-0000-0000-0000-000000000009', '2023-03-15', '2023-03-16', '2023-04-20', N'Aanrijding voorzijde, bumper en motorkap beschadigd', 2450.00, 'BANK_TRANSFER', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000002', 'SCH-2023-0002', 'C0000000-0000-0000-0000-000000000002', 'BRAND_VOERTUIG', 'IN_BEHANDELING', 'P0000000-0000-0000-0000-000000000009', '2023-05-22', '2023-05-23', NULL, N'Motorbrand op de E19', NULL, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000003', 'SCH-2023-0003', 'C0000000-0000-0000-0000-000000000003', 'DIEFSTAL_VOERTUIG', 'INGEDIEND', NULL, '2023-06-10', '2023-06-11', NULL, N'Bestelwagen gestolen van parking', NULL, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000004', 'SCH-2023-0004', 'C0000000-0000-0000-0000-000000000001', 'GLASBRAAK_VOERTUIG', 'AFGEHANDELD', 'P0000000-0000-0000-0000-000000000012', '2023-02-08', '2023-02-09', '2023-02-28', N'Voorruit gesprongen door steenslag', 385.50, 'BANK_TRANSFER', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000005', 'SCH-2023-0005', 'C0000000-0000-0000-0000-000000000016', 'WATERSCHADE', 'AFGEHANDELD', 'P0000000-0000-0000-0000-000000000012', '2023-04-12', '2023-04-13', '2023-06-15', N'Waterschade in kelder na hevige regenval', 8750.00, 'BANK_TRANSFER', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000006', 'SCH-2023-0006', 'C0000000-0000-0000-0000-000000000018', 'INBRAAKS_CHADE', 'IN_BEHANDELING', 'P0000000-0000-0000-0000-000000000014', '2023-07-01', '2023-07-02', NULL, N'Inbraak via achterdeur, juwelen en electronica gestolen', NULL, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000007', 'SCH-2023-0007', 'C0000000-0000-0000-0000-000000000008', 'BRAND_ALGEMEEN', 'GEWEIGERD', 'P0000000-0000-0000-0000-000000000014', '2023-01-20', '2023-01-21', '2023-03-10', N'Brand in keuken door achtergebleven frituurpan', 0.00, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000008', 'SCH-2023-0008', 'C0000000-0000-0000-0000-000000000016', 'STORM_EN_HAGEL_B_S_R', 'AFGEHANDELD', 'P0000000-0000-0000-0000-000000000016', '2023-06-18', '2023-06-19', '2023-08-01', N'Hagelschade aan dak en zonnepanelen', 12500.00, 'BANK_TRANSFER', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000009', 'SCH-2023-0009', 'C0000000-0000-0000-0000-000000000010', 'MEDISCHE_KOSTEN', 'AFGEHANDELD', NULL, '2023-03-05', '2023-03-06', '2023-05-20', N'Hospitalisatie na val van ladder', 3450.00, 'BANK_TRANSFER', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000010', 'SCH-2023-0010', 'C0000000-0000-0000-0000-000000000011', 'ARBEIDSONGEVALLEN', 'IN_BEHANDELING', 'P0000000-0000-0000-0000-000000000016', '2023-05-30', '2023-05-31', NULL, N'Arbeidsongeval: gebroken arm op werf', NULL, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000011', 'SCH-2023-0011', 'C0000000-0000-0000-0000-000000000001', 'RECHTSBIJSTAND_VOERTUIG', 'AFGEHANDELD', 'P0000000-0000-0000-0000-000000000018', '2023-02-14', '2023-02-15', '2023-07-01', N'Geschil over aansprakelijkheid aanrijding', 1500.00, 'BANK_TRANSFER', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000012', 'SCH-2023-0012', 'C0000000-0000-0000-0000-000000000013', 'SCHULDSALDO', 'INGEDIEND', NULL, '2023-08-01', '2023-08-02', NULL, N'Overlijden kredietnemer, schuldsaldo-uitkering', NULL, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000013', 'SCH-2023-0013', 'C0000000-0000-0000-0000-000000000014', 'REISGOED', 'AFGEHANDELD', 'P0000000-0000-0000-0000-000000000018', '2023-07-10', '2023-07-11', '2023-09-01', N'Verloren bagage tijdens vliegreis', 850.00, 'BANK_TRANSFER', SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000014', 'SCH-2023-0014', 'C0000000-0000-0000-0000-000000000004', 'VANDALISME_VOERTUIG', 'IN_BEHANDELING', 'P0000000-0000-0000-0000-000000000020', '2023-09-05', '2023-09-06', NULL, N'Motorfiets omver geschopt, schade aan stuur en spiegel', NULL, NULL, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000015', 'SCH-2023-0015', 'C0000000-0000-0000-0000-000000000008', 'ELEKTRICITEIT', 'AFGEHANDELD', 'P0000000-0000-0000-0000-000000000020', '2023-03-20', '2023-03-21', '2023-05-15', N'Elektrische kortsluiting in serverruimte', 18750.00, 'BANK_TRANSFER', SYSUTCDATETIME(), SYSUTCDATETIME());
GO

INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES
  ('CL000000-0000-0000-0000-00000000001', 'P0000000-0000-0000-0000-000000000001', 'INSURED', 1, SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000001', 'P0000000-0000-0000-0000-000000000003', 'THIRD_PARTY', 0, SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000002', 'P0000000-0000-0000-0000-000000000002', 'INSURED', 1, SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000003', 'P0000000-0000-0000-0000-000000000021', 'INSURED', 1, SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000004', 'P0000000-0000-0000-0000-000000000001', 'INSURED', 1, SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000005', 'P0000000-0000-0000-0000-000000000008', 'INSURED', 1, SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000006', 'P0000000-0000-0000-0000-000000000019', 'INSURED', 1, SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000007', 'P0000000-0000-0000-0000-000000000021', 'INSURED', 1, SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000008', 'P0000000-0000-0000-0000-000000000008', 'INSURED', 1, SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000009', 'P0000000-0000-0000-0000-000000000006', 'INSURED', 1, SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000010', 'P0000000-0000-0000-0000-000000000021', 'INSURED', 1, SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000011', 'P0000000-0000-0000-0000-000000000001', 'INSURED', 1, SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000012', 'P0000000-0000-0000-0000-000000000001', 'BENEFICIARY', 1, SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000013', 'P0000000-0000-0000-0000-000000000004', 'INSURED', 1, SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000014', 'P0000000-0000-0000-0000-000000000003', 'INSURED', 1, SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000015', 'P0000000-0000-0000-0000-000000000021', 'INSURED', 1, SYSUTCDATETIME());
GO

INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES
  ('CL000000-0000-0000-0000-00000000001', 'O0000000-0000-0000-0000-000000000001', 1, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000002', 'O0000000-0000-0000-0000-000000000002', 1, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000003', 'O0000000-0000-0000-0000-000000000003', 1, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000004', 'O0000000-0000-0000-0000-000000000001', 1, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000005', 'O0000000-0000-0000-0000-000000000017', 1, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000006', 'O0000000-0000-0000-0000-000000000019', 1, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000007', 'O0000000-0000-0000-0000-000000000015', 1, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000008', 'O0000000-0000-0000-0000-000000000017', 1, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000009', 'O0000000-0000-0000-0000-000000000006', 1, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000010', 'O0000000-0000-0000-0000-000000000025', 1, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000011', 'O0000000-0000-0000-0000-000000000001', 1, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000012', 'O0000000-0000-0000-0000-000000000028', 1, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000013', 'O0000000-0000-0000-0000-000000000004', 1, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000014', 'O0000000-0000-0000-0000-000000000004', 1, SYSUTCDATETIME(), SYSUTCDATETIME()),
  ('CL000000-0000-0000-0000-00000000015', 'O0000000-0000-0000-0000-000000000017', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
GO
PRINT '15 schadeclaims ingevoerd.';
GO

-- =============================================================
-- VERIFICATIE: Tel alle ingevoerde records
-- =============================================================
PRINT '=== VERIFICATIE ===';
GO

SELECT 'Personen (natuurlijk)' as Entiteit, COUNT(*) as Aantal FROM Person WHERE person_kind = 'NATURAL'
UNION ALL SELECT 'Personen (rechtspersoon)', COUNT(*) FROM Person WHERE person_kind = 'LEGAL'
UNION ALL SELECT 'Natuurlijke personen details', COUNT(*) FROM NaturalPerson
UNION ALL SELECT 'Rechtspersonen details', COUNT(*) FROM LegalPerson
UNION ALL SELECT 'Economische activiteiten', COUNT(*) FROM EconomicActivity
UNION ALL SELECT 'Adressen', COUNT(*) FROM Address
UNION ALL SELECT 'Telefoons', COUNT(*) FROM Phone
UNION ALL SELECT 'Emails', COUNT(*) FROM Email
UNION ALL SELECT 'Instellingen', COUNT(*) FROM Institution
UNION ALL SELECT 'Instelling identificatoren', COUNT(*) FROM InstitutionIdentifier
UNION ALL SELECT 'Instelling adressen', COUNT(*) FROM InstitutionAddress
UNION ALL SELECT 'Objecten', COUNT(*) FROM [Object]
UNION ALL SELECT 'Voertuigen', COUNT(*) FROM ObjectVehicle
UNION ALL SELECT 'Onroerende goederen', COUNT(*) FROM ObjectRealEstate
UNION ALL SELECT 'Zaken', COUNT(*) FROM ObjectThing
UNION ALL SELECT 'Personen-objecten', COUNT(*) FROM ObjectPerson
UNION ALL SELECT 'Leningen', COUNT(*) FROM ObjectLoan
UNION ALL SELECT 'Activiteiten', COUNT(*) FROM ObjectActivity
UNION ALL SELECT 'Contracten', COUNT(*) FROM Contract
UNION ALL SELECT 'Contract partijen', COUNT(*) FROM Contract_Party
UNION ALL SELECT 'Contract objecten', COUNT(*) FROM Contract_Object
UNION ALL SELECT 'Schadeclaims', COUNT(*) FROM Claim
UNION ALL SELECT 'Claim partijen', COUNT(*) FROM Claim_Party
UNION ALL SELECT 'Claim objecten', COUNT(*) FROM Claim_Object
UNION ALL SELECT 'Person_PersonType koppelingen', COUNT(*) FROM Person_PersonType
UNION ALL SELECT 'Voertuigtypen', COUNT(*) FROM VehicleType
UNION ALL SELECT 'Gebruikstypen', COUNT(*) FROM UsageType
UNION ALL SELECT 'Brandstoftypes', COUNT(*) FROM FuelType
UNION ALL SELECT 'Aandrijftypen', COUNT(*) FROM DriveType
UNION ALL SELECT 'Nummerplaattypes', COUNT(*) FROM LicensePlateType
UNION ALL SELECT 'Activiteitssubtypes', COUNT(*) FROM ObjectActivitySubtype
UNION ALL SELECT 'Activiteitsrisiconiveaus', COUNT(*) FROM ActivityRiskLevel
UNION ALL SELECT 'Persoonstypes', COUNT(*) FROM PersonType
UNION ALL SELECT 'Persoonrelatietypes', COUNT(*) FROM PersonRelationType
UNION ALL SELECT 'Extra contracttypes', COUNT(*) FROM ContractType WHERE contract_type_code LIKE 'BRAND_%' OR contract_type_code LIKE 'HOSP_%' OR contract_type_code LIKE 'LEVEN_%' OR contract_type_code LIKE 'REIS_%' OR contract_type_code LIKE 'RECHTS_%'
ORDER BY Entiteit;
GO

PRINT '=======================================================';
PRINT ' Testdata-invoer voltooid!';
PRINT '=======================================================';
GO
