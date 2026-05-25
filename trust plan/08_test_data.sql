-- =============================================================
-- AssureManager Comprehensive Test Data
-- Belgisch Verzekeringsbeheersysteem - Realistische testdata
-- =============================================================

SET NOCOUNT ON;
GO

USE AssureManagerDB;
GO

PRINT '==============================================================';
PRINT ' AssureManager - Uitgebreide testdata wordt ingevoegd...      ';
PRINT '==============================================================';
GO

-- =============================================================
-- A. Ontbrekende referentiedata
-- =============================================================

-- Referentiedata: VehicleType
PRINT 'Invoegen referentiedata: VehicleType...';
MERGE VehicleType AS t USING (VALUES
    (N'PERSONENWAGEN', N'Personenwagen'),
    (N'BESTELWAGEN', N'Bestelwagen'),
    (N'4X4', N'4x4 / SUV'),
    (N'MOTORFIETS', N'Motorfiets'),
    (N'BROMFIETS', N'Bromfiets'),
    (N'LICHTE_VRACHT', N'Lichte vrachtwagen'),
    (N'ZWARE_VRACHT', N'Zware vrachtwagen'),
    (N'CARAVAN', N'Caravan'),
    (N'CAMPER', N'Camper'),
    (N'LANDIG', N'Land- en bosbouwwerktuig')
) AS s(vehicle_type_code, label_nl)
ON t.vehicle_type_code = s.vehicle_type_code
WHEN MATCHED THEN UPDATE SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(vehicle_type_code, label_nl) VALUES(s.vehicle_type_code, s.label_nl);
GO

-- Referentiedata: UsageType
PRINT 'Invoegen referentiedata: UsageType...';
MERGE UsageType AS t USING (VALUES
    (N'PRIV_PLEZIER', N'Prive en plezier'),
    (N'WOON_WERK', N'Woon-werkverkeer'),
    (N'BEROEP', N'Beroepsmatig'),
    (N'ALGEMENE_DOELEINDEN', N'Algemene doeleinden'),
    (N'TAXI', N'Taxi/vervoer personen'),
    (N'HUUR', N'Huur/verhuur'),
    (N'LEASING', N'Leasing'),
    (N'OMNIUM', N'Omnium (casco)'),
    (N'BROMFIETS_PART', N'Bromfiets particulier'),
    (N'MOTOR_PART', N'Motorfiets particulier')
) AS s(usage_type_code, label_nl)
ON t.usage_type_code = s.usage_type_code
WHEN MATCHED THEN UPDATE SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(usage_type_code, label_nl) VALUES(s.usage_type_code, s.label_nl);
GO

-- Referentiedata: FuelType
PRINT 'Invoegen referentiedata: FuelType...';
MERGE FuelType AS t USING (VALUES
    (N'BENZINE', N'Benzine'),
    (N'DIESEL', N'Diesel'),
    (N'ELEKTRISCH', N'Elektrisch'),
    (N'HYBRIDE', N'Hybride'),
    (N'LPG', N'LPG'),
    (N'CNG', N'CNG / Aardgas'),
    (N'WATERSTOF', N'Waterstof')
) AS s(fuel_type_code, label_nl)
ON t.fuel_type_code = s.fuel_type_code
WHEN MATCHED THEN UPDATE SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(fuel_type_code, label_nl) VALUES(s.fuel_type_code, s.label_nl);
GO

-- Referentiedata: DriveType
PRINT 'Invoegen referentiedata: DriveType...';
MERGE DriveType AS t USING (VALUES
    (N'VLO', N'Voorwielaandrijving'),
    (N'ACH', N'Achterwielaandrijving'),
    (N'4X4', N'4x4 All-wheel drive'),
    (N'4X2', N'4x2'),
    (N'4X4_SELECT', N'4x4 selectief')
) AS s(drive_type_code, label_nl)
ON t.drive_type_code = s.drive_type_code
WHEN MATCHED THEN UPDATE SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(drive_type_code, label_nl) VALUES(s.drive_type_code, s.label_nl);
GO

-- Referentiedata: LicensePlateType
PRINT 'Invoegen referentiedata: LicensePlateType...';
MERGE LicensePlateType AS t USING (VALUES
    (N'EUROPEES', N'Europees formaat wit'),
    (N'BELGIE', N'Belgisch formaat rood'),
    (N'TIJDELIJK', N'Tijdelijke plaat'),
    (N'EXPORT', N'Exportplaat'),
    (N'HANDELAAR', N'Handelaarsplaat'),
    (N'TEST', N'Testritplaat'),
    (N'DIPLOMATIEK', N'Diplomatieke plaat'),
    (N'MILITAIR', N'Militaire plaat')
) AS s(plate_type_code, label_nl)
ON t.plate_type_code = s.plate_type_code
WHEN MATCHED THEN UPDATE SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(plate_type_code, label_nl) VALUES(s.plate_type_code, s.label_nl);
GO

-- Referentiedata: PersonType
PRINT 'Invoegen referentiedata: PersonType...';
MERGE PersonType AS t USING (VALUES
    (N'NATUURLIJK', N'Natuurlijk persoon'),
    (N'RECHTSPERSOON', N'Rechtspersoon'),
    (N'KLANT', N'Klant'),
    (N'LEVERANCIER', N'Leverancier'),
    (N'PROSPECT', N'Prospect'),
    (N'MEDEWERKER', N'Medewerker'),
    (N'MAKELAAR', N'Makelaar Tussenpersoon'),
    (N'EXPERT', N'Expert Schadebeoordelaar'),
    (N'ADVOCAAT', N'Advocaat'),
    (N'NOTARIS', N'Notaris')
) AS s(person_type_code, person_type_label_nl)
ON t.person_type_code = s.person_type_code
WHEN MATCHED THEN UPDATE SET t.person_type_label_nl = s.person_type_label_nl
WHEN NOT MATCHED THEN INSERT(person_type_code, person_type_label_nl) VALUES(s.person_type_code, s.person_type_label_nl);
GO

-- Referentiedata: ObjectActivitySubtype
PRINT 'Invoegen referentiedata: ObjectActivitySubtype...';
MERGE ObjectActivitySubtype AS t USING (VALUES
    (N'FEEST', N'Feest Party'),
    (N'CONCERT', N'Concert Muziekevenement'),
    (N'SPORT_MANIFESTATIE', N'Sportmanifestatie'),
    (N'BEURS', N'Beurs Expositie'),
    (N'TOERNOOI', N'Toernooi'),
    (N'CORPORATE', N'Corporate event'),
    (N'BRUILOFT', N'Bruiloft'),
    (N'CONFERENTIE', N'Conferentie Seminarie'),
    (N'FESTIVAL', N'Festival'),
    (N'OPENDEURDAG', N'Opendeurdag')
) AS s(activity_type_code, label_nl)
ON t.activity_type_code = s.activity_type_code
WHEN MATCHED THEN UPDATE SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(activity_type_code, label_nl) VALUES(s.activity_type_code, s.label_nl);
GO

-- Referentiedata: ActivityRiskLevel
PRINT 'Invoegen referentiedata: ActivityRiskLevel...';
MERGE ActivityRiskLevel AS t USING (VALUES
    (N'LAAG', N'Laag risico'),
    (N'MIDDEN', N'Middelmatig risico'),
    (N'HOOG', N'Hoog risico'),
    (N'ZEER_HOOG', N'Zeer hoog risico'),
    (N'UITERST_HOOG', N'Uiterst hoog risico')
) AS s(risk_level_code, label_nl)
ON t.risk_level_code = s.risk_level_code
WHEN MATCHED THEN UPDATE SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(risk_level_code, label_nl) VALUES(s.risk_level_code, s.label_nl);
GO

-- =============================================================
-- B. 50 Natuurlijke Personen
-- Realistische Belgische namen met RRN-nummers
-- =============================================================

-- Persoon 1: Jan De Vries
-- Rijksregisternummer: 60.01.01-001.97
-- Geboren: 01/01/1960 te Mechelen
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('219711d4-f1e9-5b7c-84bc-490a41110884', 'NATURAL', 'DS-1000', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('219711d4-f1e9-5b7c-84bc-490a41110884', N'Jan', N'De Vries', '1960-01-01', N'Mechelen', N'Mannelijk', 'MR', N'60.01.01-001.97');

-- Persoon 2: Pieter Janssens
-- Rijksregisternummer: 61.02.02-002.94
-- Geboren: 02/02/1961 te Brussel
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('7268581b-0dbd-52b1-b752-40aebb63d0a5', 'NATURAL', 'DS-1001', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('7268581b-0dbd-52b1-b752-40aebb63d0a5', N'Pieter', N'Janssens', '1961-02-02', N'Brussel', N'Mannelijk', 'MR', N'61.02.02-002.94');

-- Persoon 3: Thomas Peeters
-- Rijksregisternummer: 62.03.03-003.91
-- Geboren: 03/03/1962 te Gent
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('767455ff-6716-57b8-8b1b-07625f980552', 'NATURAL', 'DS-1002', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('767455ff-6716-57b8-8b1b-07625f980552', N'Thomas', N'Peeters', '1962-03-03', N'Gent', N'Mannelijk', 'MR', N'62.03.03-003.91');

-- Persoon 4: Bart Maes
-- Rijksregisternummer: 63.04.04-004.88
-- Geboren: 04/04/1963 te Antwerpen
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('6ef2fb59-c4d6-509d-82b7-86ba6954d512', 'NATURAL', 'DS-1003', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('6ef2fb59-c4d6-509d-82b7-86ba6954d512', N'Bart', N'Maes', '1963-04-04', N'Antwerpen', N'Mannelijk', 'MR', N'63.04.04-004.88');

-- Persoon 5: Koen Jacobs
-- Rijksregisternummer: 64.05.05-005.85
-- Geboren: 05/05/1964 te Leuven
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('f2ebd19a-69e8-50cc-bc6f-290e94deb79a', 'NATURAL', 'DS-1004', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('f2ebd19a-69e8-50cc-bc6f-290e94deb79a', N'Koen', N'Jacobs', '1964-05-05', N'Leuven', N'Mannelijk', 'MR', N'64.05.05-005.85');

-- Persoon 6: Filip Willems
-- Rijksregisternummer: 65.06.06-006.82
-- Geboren: 06/06/1965 te Hasselt
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('8dbcaf2e-12f0-51a4-ac0d-1e65bd18488a', 'NATURAL', 'DS-1005', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('8dbcaf2e-12f0-51a4-ac0d-1e65bd18488a', N'Filip', N'Willems', '1965-06-06', N'Hasselt', N'Mannelijk', 'MR', N'65.06.06-006.82');

-- Persoon 7: David Claes
-- Rijksregisternummer: 66.07.07-007.79
-- Geboren: 07/07/1966 te Brugge
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('d421bbf2-d9ea-5c6c-94e1-822811b8482f', 'NATURAL', 'DS-1006', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('d421bbf2-d9ea-5c6c-94e1-822811b8482f', N'David', N'Claes', '1966-07-07', N'Brugge', N'Mannelijk', 'MR', N'66.07.07-007.79');

-- Persoon 8: Jeroen Goossens
-- Rijksregisternummer: 67.08.08-008.76
-- Geboren: 08/08/1967 te Namen
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('c54ae5ab-b164-5d26-ab0e-1226a794ba00', 'NATURAL', 'DS-1007', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('c54ae5ab-b164-5d26-ab0e-1226a794ba00', N'Jeroen', N'Goossens', '1967-08-08', N'Namen', N'Mannelijk', 'MR', N'67.08.08-008.76');

-- Persoon 9: Stefan Wouters
-- Rijksregisternummer: 68.09.09-009.73
-- Geboren: 09/09/1968 te Luik
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('2918c7dc-bf8a-5adf-a342-2f427ea33ad2', 'NATURAL', 'DS-1008', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('2918c7dc-bf8a-5adf-a342-2f427ea33ad2', N'Stefan', N'Wouters', '1968-09-09', N'Luik', N'Mannelijk', 'MR', N'68.09.09-009.73');

-- Persoon 10: Wouter De Smet
-- Rijksregisternummer: 69.10.10-010.70
-- Geboren: 10/10/1969 te Kortrijk
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('06d5be89-2291-5bb5-9a22-906efcffbfca', 'NATURAL', 'DS-1009', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('06d5be89-2291-5bb5-9a22-906efcffbfca', N'Wouter', N'De Smet', '1969-10-10', N'Kortrijk', N'Mannelijk', 'MR', N'69.10.10-010.70');

-- Persoon 11: Tim Vermeulen
-- Rijksregisternummer: 70.11.11-011.67
-- Geboren: 11/11/1970 te Oostende
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('5485d4fb-5fe5-5d99-bddd-cd9ca895e3e7', 'NATURAL', 'DS-1010', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('5485d4fb-5fe5-5d99-bddd-cd9ca895e3e7', N'Tim', N'Vermeulen', '1970-11-11', N'Oostende', N'Mannelijk', 'MR', N'70.11.11-011.67');

-- Persoon 12: Jonas Van den Berg
-- Rijksregisternummer: 71.12.12-012.64
-- Geboren: 12/12/1971 te Sint-Niklaas
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('0f0f2938-e0e5-5dd6-aac5-f9c21720495d', 'NATURAL', 'DS-1011', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('0f0f2938-e0e5-5dd6-aac5-f9c21720495d', N'Jonas', N'Van den Berg', '1971-12-12', N'Sint-Niklaas', N'Mannelijk', 'MR', N'71.12.12-012.64');

-- Persoon 13: Bram Martens
-- Rijksregisternummer: 72.01.13-013.61
-- Geboren: 13/01/1972 te Genk
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('31572584-1fed-582a-9c35-e4c7812029e6', 'NATURAL', 'DS-1012', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('31572584-1fed-582a-9c35-e4c7812029e6', N'Bram', N'Martens', '1972-01-13', N'Genk', N'Mannelijk', 'MR', N'72.01.13-013.61');

-- Persoon 14: Tom Hermans
-- Rijksregisternummer: 73.02.14-014.58
-- Geboren: 14/02/1973 te Turnhout
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('255fbd61-4611-58f5-8a9d-5a1d9d900509', 'NATURAL', 'DS-1013', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('255fbd61-4611-58f5-8a9d-5a1d9d900509', N'Tom', N'Hermans', '1973-02-14', N'Turnhout', N'Mannelijk', 'MR', N'73.02.14-014.58');

-- Persoon 15: Nick Moons
-- Rijksregisternummer: 74.03.15-015.55
-- Geboren: 15/03/1974 te Lier
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('ece43643-6bf6-5ba3-aa12-86b4e6f28c98', 'NATURAL', 'DS-1014', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('ece43643-6bf6-5ba3-aa12-86b4e6f28c98', N'Nick', N'Moons', '1974-03-15', N'Lier', N'Mannelijk', 'MR', N'74.03.15-015.55');

-- Persoon 16: Dries Van Dam
-- Rijksregisternummer: 75.04.16-016.52
-- Geboren: 16/04/1975 te Aalst
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('a457648d-1590-5e2f-b8bf-a23785c04f64', 'NATURAL', 'DS-1015', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('a457648d-1590-5e2f-b8bf-a23785c04f64', N'Dries', N'Van Dam', '1975-04-16', N'Aalst', N'Mannelijk', 'MR', N'75.04.16-016.52');

-- Persoon 17: Kevin Hendrickx
-- Rijksregisternummer: 76.05.17-017.49
-- Geboren: 17/05/1976 te Vilvoorde
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('e2f6b781-f674-5f9d-8b42-126c1bee3960', 'NATURAL', 'DS-1016', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('e2f6b781-f674-5f9d-8b42-126c1bee3960', N'Kevin', N'Hendrickx', '1976-05-17', N'Vilvoorde', N'Mannelijk', 'MR', N'76.05.17-017.49');

-- Persoon 18: Lucas Desmet
-- Rijksregisternummer: 77.06.18-018.46
-- Geboren: 18/06/1977 te Herentals
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('c6ad9b62-ec86-53f5-a4b6-013a6d736cf5', 'NATURAL', 'DS-1017', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('c6ad9b62-ec86-53f5-a4b6-013a6d736cf5', N'Lucas', N'Desmet', '1977-06-18', N'Herentals', N'Mannelijk', 'MR', N'77.06.18-018.46');

-- Persoon 19: Mathias Vandenberghe
-- Rijksregisternummer: 78.07.19-019.43
-- Geboren: 19/07/1978 te Mol
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('e70a286c-911f-5e09-b03c-0931a765f2f7', 'NATURAL', 'DS-1018', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('e70a286c-911f-5e09-b03c-0931a765f2f7', N'Mathias', N'Vandenberghe', '1978-07-19', N'Mol', N'Mannelijk', 'MR', N'78.07.19-019.43');

-- Persoon 20: Sven De Backer
-- Rijksregisternummer: 79.08.20-020.40
-- Geboren: 20/08/1979 te Aarschot
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('2967832c-6861-5b2e-90bd-7601cade376f', 'NATURAL', 'DS-1019', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('2967832c-6861-5b2e-90bd-7601cade376f', N'Sven', N'De Backer', '1979-08-20', N'Aarschot', N'Mannelijk', 'MR', N'79.08.20-020.40');

-- Persoon 21: Bjorn Smets
-- Rijksregisternummer: 80.09.21-021.37
-- Geboren: 21/09/1980 te Tienen
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('e094bb9e-83a3-5264-9a36-5feb477fe2b4', 'NATURAL', 'DS-1020', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('e094bb9e-83a3-5264-9a36-5feb477fe2b4', N'Bjorn', N'Smets', '1980-09-21', N'Tienen', N'Mannelijk', 'MR', N'80.09.21-021.37');

-- Persoon 22: Gert Verhoeven
-- Rijksregisternummer: 81.10.22-022.34
-- Geboren: 22/10/1981 te Sint-Truiden
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('7ca7f3fb-f978-5ca7-ac09-18c47085b64f', 'NATURAL', 'DS-1021', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('7ca7f3fb-f978-5ca7-ac09-18c47085b64f', N'Gert', N'Verhoeven', '1981-10-22', N'Sint-Truiden', N'Mannelijk', 'MR', N'81.10.22-022.34');

-- Persoon 23: Hans Laurent
-- Rijksregisternummer: 82.11.23-023.31
-- Geboren: 23/11/1982 te Tongeren
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('54380520-048a-553e-9b82-c25ea502a113', 'NATURAL', 'DS-1022', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('54380520-048a-553e-9b82-c25ea502a113', N'Hans', N'Laurent', '1982-11-23', N'Tongeren', N'Mannelijk', 'MR', N'82.11.23-023.31');

-- Persoon 24: Joeri Dupont
-- Rijksregisternummer: 83.12.24-024.28
-- Geboren: 24/12/1983 te Sint-Pieters-Leeuw
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('acbb80cd-970f-54be-807c-3acece52e150', 'NATURAL', 'DS-1023', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('acbb80cd-970f-54be-807c-3acece52e150', N'Joeri', N'Dupont', '1983-12-24', N'Sint-Pieters-Leeuw', N'Mannelijk', 'MR', N'83.12.24-024.28');

-- Persoon 25: Kris Martin
-- Rijksregisternummer: 84.01.25-025.25
-- Geboren: 25/01/1984 te Dilbeek
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('10839728-a402-5e53-b47e-591900ca1d56', 'NATURAL', 'DS-1024', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('10839728-a402-5e53-b47e-591900ca1d56', N'Kris', N'Martin', '1984-01-25', N'Dilbeek', N'Mannelijk', 'MR', N'84.01.25-025.25');

-- Persoon 26: Lars Lambert
-- Rijksregisternummer: 85.02.26-026.22
-- Geboren: 26/02/1985 te Halle
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('d4206c62-2be6-5450-bcd5-c43fe3463f2a', 'NATURAL', 'DS-1025', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('d4206c62-2be6-5450-bcd5-c43fe3463f2a', N'Lars', N'Lambert', '1985-02-26', N'Halle', N'Mannelijk', 'MR', N'85.02.26-026.22');

-- Persoon 27: Pascale Simon
-- Rijksregisternummer: 86.03.27-027.19
-- Geboren: 27/03/1986 te Berchem
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('375d8d17-ca43-59a4-86e1-5a47fe1cfed3', 'NATURAL', 'DS-1026', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('375d8d17-ca43-59a4-86e1-5a47fe1cfed3', N'Pascale', N'Simon', '1986-03-27', N'Berchem', N'Vrouwelijk', 'MRS', N'86.03.27-027.19');

-- Persoon 28: Riet Lefevre
-- Rijksregisternummer: 87.04.28-028.16
-- Geboren: 28/04/1987 te Deurne
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('656aa8fc-7e79-5ca1-bcbb-8a8fd46538c3', 'NATURAL', 'DS-1027', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('656aa8fc-7e79-5ca1-bcbb-8a8fd46538c3', N'Riet', N'Lefevre', '1987-04-28', N'Deurne', N'Vrouwelijk', 'MRS', N'87.04.28-028.16');

-- Persoon 29: Sara Dubois
-- Rijksregisternummer: 88.05.01-029.13
-- Geboren: 01/05/1988 te Anderlecht
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('eb00cae9-803c-5162-86c2-9e3a21ad4d4f', 'NATURAL', 'DS-1028', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('eb00cae9-803c-5162-86c2-9e3a21ad4d4f', N'Sara', N'Dubois', '1988-05-01', N'Anderlecht', N'Vrouwelijk', 'MRS', N'88.05.01-029.13');

-- Persoon 30: Tine Moreau
-- Rijksregisternummer: 89.06.02-030.10
-- Geboren: 02/06/1989 te Schaarbeek
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('51eb00ad-860f-586b-8f93-b076bf073683', 'NATURAL', 'DS-1029', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('51eb00ad-860f-586b-8f93-b076bf073683', N'Tine', N'Moreau', '1989-06-02', N'Schaarbeek', N'Vrouwelijk', 'MRS', N'89.06.02-030.10');

-- Persoon 31: Marie De Vries
-- Rijksregisternummer: 90.07.03-031.07
-- Geboren: 03/07/1990 te Antwerpen
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('b1d210cc-ae2e-551a-b0ea-32b380583aa0', 'NATURAL', 'DS-1030', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('b1d210cc-ae2e-551a-b0ea-32b380583aa0', N'Marie', N'De Vries', '1990-07-03', N'Antwerpen', N'Vrouwelijk', 'MRS', N'90.07.03-031.07');

-- Persoon 32: Sofie Janssens
-- Rijksregisternummer: 91.08.04-032.04
-- Geboren: 04/08/1991 te Kapellen
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('a9c72bff-21c7-514d-afe4-d90b7fd0734c', 'NATURAL', 'DS-1031', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('a9c72bff-21c7-514d-afe4-d90b7fd0734c', N'Sofie', N'Janssens', '1991-08-04', N'Kapellen', N'Vrouwelijk', 'MRS', N'91.08.04-032.04');

-- Persoon 33: Lotte Peeters
-- Rijksregisternummer: 92.09.05-033.01
-- Geboren: 05/09/1992 te Kontich
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('94d4279a-d4bc-546b-8483-62b3d48fadc9', 'NATURAL', 'DS-1032', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('94d4279a-d4bc-546b-8483-62b3d48fadc9', N'Lotte', N'Peeters', '1992-09-05', N'Kontich', N'Vrouwelijk', 'MRS', N'92.09.05-033.01');

-- Persoon 34: Emma Maes
-- Rijksregisternummer: 93.10.06-034.98
-- Geboren: 06/10/1993 te Mortsel
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('e9fa3f32-8a88-58f7-aa16-19c078b73812', 'NATURAL', 'DS-1033', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('e9fa3f32-8a88-58f7-aa16-19c078b73812', N'Emma', N'Maes', '1993-10-06', N'Mortsel', N'Vrouwelijk', 'MRS', N'93.10.06-034.98');

-- Persoon 35: Ann Jacobs
-- Rijksregisternummer: 94.11.07-035.95
-- Geboren: 07/11/1994 te Zoersel
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('5aa15f2f-d6e3-5834-9b99-ce48aab774c2', 'NATURAL', 'DS-1034', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('5aa15f2f-d6e3-5834-9b99-ce48aab774c2', N'Ann', N'Jacobs', '1994-11-07', N'Zoersel', N'Vrouwelijk', 'MRS', N'94.11.07-035.95');

-- Persoon 36: Sarah Willems
-- Rijksregisternummer: 95.12.08-036.92
-- Geboren: 08/12/1995 te Kalmthout
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('e162f9ae-c21f-5642-99c5-9a9ac7fe0ffa', 'NATURAL', 'DS-1035', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('e162f9ae-c21f-5642-99c5-9a9ac7fe0ffa', N'Sarah', N'Willems', '1995-12-08', N'Kalmthout', N'Vrouwelijk', 'MRS', N'95.12.08-036.92');

-- Persoon 37: Laura Claes
-- Rijksregisternummer: 96.01.09-037.89
-- Geboren: 09/01/1996 te Brasschaat
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('7e25fdf9-3052-52e7-8753-d64356fdade7', 'NATURAL', 'DS-1036', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('7e25fdf9-3052-52e7-8753-d64356fdade7', N'Laura', N'Claes', '1996-01-09', N'Brasschaat', N'Vrouwelijk', 'MRS', N'96.01.09-037.89');

-- Persoon 38: Nina Goossens
-- Rijksregisternummer: 97.02.10-038.86
-- Geboren: 10/02/1997 te Schoten
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('3ecbc905-9da6-5b0b-9f39-dc903be90d58', 'NATURAL', 'DS-1037', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('3ecbc905-9da6-5b0b-9f39-dc903be90d58', N'Nina', N'Goossens', '1997-02-10', N'Schoten', N'Vrouwelijk', 'MRS', N'97.02.10-038.86');

-- Persoon 39: Karen Wouters
-- Rijksregisternummer: 98.03.11-039.83
-- Geboren: 11/03/1998 te Borgerhout
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('12ea6164-808c-5aa4-ab79-956ddd949d5e', 'NATURAL', 'DS-1038', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('12ea6164-808c-5aa4-ab79-956ddd949d5e', N'Karen', N'Wouters', '1998-03-11', N'Borgerhout', N'Vrouwelijk', 'MRS', N'98.03.11-039.83');

-- Persoon 40: Lisa De Smet
-- Rijksregisternummer: 99.04.12-040.80
-- Geboren: 12/04/1999 te Antwerpen
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('cf9fe55e-fcdd-553e-8bc7-f1e799743ce5', 'NATURAL', 'DS-1039', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('cf9fe55e-fcdd-553e-8bc7-f1e799743ce5', N'Lisa', N'De Smet', '1999-04-12', N'Antwerpen', N'Vrouwelijk', 'MRS', N'99.04.12-040.80');

-- Persoon 41: Elise Vermeulen
-- Rijksregisternummer: 60.05.13-041.77
-- Geboren: 13/05/1960 te Zwijndrecht
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('88275840-7a64-5c38-91b3-167e286f560d', 'NATURAL', 'DS-1040', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('88275840-7a64-5c38-91b3-167e286f560d', N'Elise', N'Vermeulen', '1960-05-13', N'Zwijndrecht', N'Vrouwelijk', 'MRS', N'60.05.13-041.77');

-- Persoon 42: Hanne Van den Berg
-- Rijksregisternummer: 61.06.14-042.74
-- Geboren: 14/06/1961 te Boom
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('abeaecc5-308d-5d45-9eb1-21caed5274ff', 'NATURAL', 'DS-1041', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('abeaecc5-308d-5d45-9eb1-21caed5274ff', N'Hanne', N'Van den Berg', '1961-06-14', N'Boom', N'Vrouwelijk', 'MRS', N'61.06.14-042.74');

-- Persoon 43: Charlotte Martens
-- Rijksregisternummer: 62.07.15-043.71
-- Geboren: 15/07/1962 te Sint-Katelijne-Waver
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('e77a50fb-c6c7-5c28-aaeb-b64672bd3a88', 'NATURAL', 'DS-1042', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('e77a50fb-c6c7-5c28-aaeb-b64672bd3a88', N'Charlotte', N'Martens', '1962-07-15', N'Sint-Katelijne-Waver', N'Vrouwelijk', 'MRS', N'62.07.15-043.71');

-- Persoon 44: Stephanie Hermans
-- Rijksregisternummer: 63.08.16-044.68
-- Geboren: 16/08/1963 te Hever
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('ecbb77f5-a7db-558a-b13a-42fd2094023e', 'NATURAL', 'DS-1043', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('ecbb77f5-a7db-558a-b13a-42fd2094023e', N'Stephanie', N'Hermans', '1963-08-16', N'Hever', N'Vrouwelijk', 'MRS', N'63.08.16-044.68');

-- Persoon 45: Julie Moons
-- Rijksregisternummer: 64.09.17-045.65
-- Geboren: 17/09/1964 te Rijmenam
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('e32a64f6-c0df-580e-bbd4-18dca5aa25cb', 'NATURAL', 'DS-1044', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('e32a64f6-c0df-580e-bbd4-18dca5aa25cb', N'Julie', N'Moons', '1964-09-17', N'Rijmenam', N'Vrouwelijk', 'MRS', N'64.09.17-045.65');

-- Persoon 46: An Van Dam
-- Rijksregisternummer: 65.10.18-046.62
-- Geboren: 18/10/1965 te Willebroek
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('e881e046-e826-5fdf-aee9-d7ef20db2171', 'NATURAL', 'DS-1045', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('e881e046-e826-5fdf-aee9-d7ef20db2171', N'An', N'Van Dam', '1965-10-18', N'Willebroek', N'Vrouwelijk', 'MRS', N'65.10.18-046.62');

-- Persoon 47: Clara Hendrickx
-- Rijksregisternummer: 66.11.19-047.59
-- Geboren: 19/11/1966 te Reet
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('1b0efd79-d7eb-5f8a-bad6-66c8d683363c', 'NATURAL', 'DS-1046', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('1b0efd79-d7eb-5f8a-bad6-66c8d683363c', N'Clara', N'Hendrickx', '1966-11-19', N'Reet', N'Vrouwelijk', 'MRS', N'66.11.19-047.59');

-- Persoon 48: Els Desmet
-- Rijksregisternummer: 67.12.20-048.56
-- Geboren: 20/12/1967 te Puurs
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('686d7d6b-464a-5c2e-983b-467383404638', 'NATURAL', 'DS-1047', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('686d7d6b-464a-5c2e-983b-467383404638', N'Els', N'Desmet', '1967-12-20', N'Puurs', N'Vrouwelijk', 'MRS', N'67.12.20-048.56');

-- Persoon 49: Fien Vandenberghe
-- Rijksregisternummer: 68.01.21-049.53
-- Geboren: 21/01/1968 te Bornem
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('af92e0ba-9be1-5452-ac95-69f85d04ad74', 'NATURAL', 'DS-1048', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('af92e0ba-9be1-5452-ac95-69f85d04ad74', N'Fien', N'Vandenberghe', '1968-01-21', N'Bornem', N'Vrouwelijk', 'MRS', N'68.01.21-049.53');

-- Persoon 50: Hanne De Backer
-- Rijksregisternummer: 69.02.22-050.50
-- Geboren: 22/02/1969 te Sint-Amands
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('356e6f20-40fd-5f52-8c7c-a7f81d3f1990', 'NATURAL', 'DS-1049', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place, gender, title_code, national_number)
VALUES ('356e6f20-40fd-5f52-8c7c-a7f81d3f1990', N'Hanne', N'De Backer', '1969-02-22', N'Sint-Amands', N'Vrouwelijk', 'MRS', N'69.02.22-050.50');

PRINT '50 natuurlijke personen ingevoegd.';
GO

-- =============================================================
-- C. 30 Rechtspersonen
-- Belgische bedrijven met KBO-nummers
-- =============================================================

-- Rechtspersoon 1: De Vries Verzekeringen BV
-- KBO-nummer: BE 0400.000.000
-- Rechtsvorm: BV
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('3b48a949-5c44-50da-91e7-6fc728cd9efe', 'LEGAL', 'DS-2000', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('3b48a949-5c44-50da-91e7-6fc728cd9efe', '1990-01-01', N'BV');

-- Rechtspersoon 2: Janssens Consultancy BVBA
-- KBO-nummer: BE 0400.100.101
-- Rechtsvorm: BVBA
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('a3671e77-d7bb-585a-a448-7502bd4e76a6', 'LEGAL', 'DS-2001', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('a3671e77-d7bb-585a-a448-7502bd4e76a6', '1991-02-02', N'BVBA');

-- Rechtspersoon 3: Peeters Group BV
-- KBO-nummer: BE 0400.200.202
-- Rechtsvorm: BV
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('3abca959-e7f6-5fcb-a863-634279e1c837', 'LEGAL', 'DS-2002', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('3abca959-e7f6-5fcb-a863-634279e1c837', '1992-03-03', N'BV');

-- Rechtspersoon 4: Maes Holding NV
-- KBO-nummer: BE 0400.300.303
-- Rechtsvorm: NV
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('6c8d4d1f-aedb-5dad-b385-02ee2c37862d', 'LEGAL', 'DS-2003', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('6c8d4d1f-aedb-5dad-b385-02ee2c37862d', '1993-04-04', N'NV');

-- Rechtspersoon 5: Jacobs Logistics BV
-- KBO-nummer: BE 0400.400.404
-- Rechtsvorm: BV
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('04d877fb-dbbf-5695-8ff9-eb6a39435ec7', 'LEGAL', 'DS-2004', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('04d877fb-dbbf-5695-8ff9-eb6a39435ec7', '1994-05-05', N'BV');

-- Rechtspersoon 6: Willems Engineering BVBA
-- KBO-nummer: BE 0400.500.505
-- Rechtsvorm: BVBA
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('c00f1a58-7e96-5163-b7ba-cd2447bd10de', 'LEGAL', 'DS-2005', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('c00f1a58-7e96-5163-b7ba-cd2447bd10de', '1995-06-06', N'BVBA');

-- Rechtspersoon 7: Claes IT Solutions BV
-- KBO-nummer: BE 0400.600.606
-- Rechtsvorm: BV
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('991e2044-f65e-59e7-9aa7-aca0480964e7', 'LEGAL', 'DS-2006', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('991e2044-f65e-59e7-9aa7-aca0480964e7', '1996-07-07', N'BV');

-- Rechtspersoon 8: Goossens Bouw BV
-- KBO-nummer: BE 0400.700.707
-- Rechtsvorm: BV
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('14c5ccbc-89cf-5c44-b7e7-29b06d259abc', 'LEGAL', 'DS-2007', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('14c5ccbc-89cf-5c44-b7e7-29b06d259abc', '1997-08-08', N'BV');

-- Rechtspersoon 9: Wouters Retail NV
-- KBO-nummer: BE 0400.800.808
-- Rechtsvorm: NV
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('89c4f9fd-dd84-5d2d-858c-258a704f5e61', 'LEGAL', 'DS-2008', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('89c4f9fd-dd84-5d2d-858c-258a704f5e61', '1998-09-09', N'NV');

-- Rechtspersoon 10: De Smet Pharma NV
-- KBO-nummer: BE 0400.900.909
-- Rechtsvorm: NV
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('b4a7ca2a-d48b-5263-91a4-20e5a5dd46b7', 'LEGAL', 'DS-2009', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('b4a7ca2a-d48b-5263-91a4-20e5a5dd46b7', '1999-10-10', N'NV');

-- Rechtspersoon 11: Vermeulen Advies BV
-- KBO-nummer: BE 0401.001.010
-- Rechtsvorm: BV
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('9c252156-2f74-5e40-a546-b06451d644bb', 'LEGAL', 'DS-2010', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('9c252156-2f74-5e40-a546-b06451d644bb', '2000-11-11', N'BV');

-- Rechtspersoon 12: Van den Berg Transport BV
-- KBO-nummer: BE 0401.101.111
-- Rechtsvorm: BV
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('ea676367-9ce6-5ddf-88b3-01b7448863cf', 'LEGAL', 'DS-2011', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('ea676367-9ce6-5ddf-88b3-01b7448863cf', '2001-12-12', N'BV');

-- Rechtspersoon 13: Martens Horeca BVBA
-- KBO-nummer: BE 0401.201.212
-- Rechtsvorm: BVBA
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('f394a7ee-4516-5eda-94be-6cbfc295962d', 'LEGAL', 'DS-2012', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('f394a7ee-4516-5eda-94be-6cbfc295962d', '2002-01-13', N'BVBA');

-- Rechtspersoon 14: Hermans Autos BV
-- KBO-nummer: BE 0401.301.313
-- Rechtsvorm: BV
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('8ff1d038-f9b7-5fa0-8a9e-983f7231aa0c', 'LEGAL', 'DS-2013', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('8ff1d038-f9b7-5fa0-8a9e-983f7231aa0c', '2003-02-14', N'BV');

-- Rechtspersoon 15: Moons Consulting BV
-- KBO-nummer: BE 0401.401.414
-- Rechtsvorm: BV
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('20ecd889-e82d-5e3b-8d53-30b27c48ac83', 'LEGAL', 'DS-2014', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('20ecd889-e82d-5e3b-8d53-30b27c48ac83', '2004-03-15', N'BV');

-- Rechtspersoon 16: Van Dam Projects NV
-- KBO-nummer: BE 0401.501.515
-- Rechtsvorm: NV
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('3247f51a-b5e6-5032-89c4-07f5959fd455', 'LEGAL', 'DS-2015', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('3247f51a-b5e6-5032-89c4-07f5959fd455', '2005-04-16', N'NV');

-- Rechtspersoon 17: Hendrickx Media BV
-- KBO-nummer: BE 0401.601.616
-- Rechtsvorm: BV
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('68b80efe-45b2-570d-aec1-276848865fb8', 'LEGAL', 'DS-2016', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('68b80efe-45b2-570d-aec1-276848865fb8', '2006-05-17', N'BV');

-- Rechtspersoon 18: Desmet Foods BVBA
-- KBO-nummer: BE 0401.701.717
-- Rechtsvorm: BVBA
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('8ec3e9ff-6edc-59d3-916a-8c9bf11193e9', 'LEGAL', 'DS-2017', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('8ec3e9ff-6edc-59d3-916a-8c9bf11193e9', '2007-06-18', N'BVBA');

-- Rechtspersoon 19: Vandenberghe Energy NV
-- KBO-nummer: BE 0401.801.818
-- Rechtsvorm: NV
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('840a663b-9633-5af4-ad27-4b4422a4cfec', 'LEGAL', 'DS-2018', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('840a663b-9633-5af4-ad27-4b4422a4cfec', '2008-07-19', N'NV');

-- Rechtspersoon 20: De Backer Legal BV
-- KBO-nummer: BE 0401.901.919
-- Rechtsvorm: BV
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('af66737e-f2b9-5370-b42a-659e687139ac', 'LEGAL', 'DS-2019', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('af66737e-f2b9-5370-b42a-659e687139ac', '2009-08-20', N'BV');

-- Rechtspersoon 21: Smets Consulting BV
-- KBO-nummer: BE 0402.002.020
-- Rechtsvorm: BV
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('078c5ddc-92b3-5802-9d13-f015bbb4d88e', 'LEGAL', 'DS-2020', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('078c5ddc-92b3-5802-9d13-f015bbb4d88e', '2010-09-21', N'BV');

-- Rechtspersoon 22: Verhoeven Healthcare BVBA
-- KBO-nummer: BE 0402.102.121
-- Rechtsvorm: BVBA
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('71e7a6d0-7fce-5ae8-9573-03308d171690', 'LEGAL', 'DS-2021', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('71e7a6d0-7fce-5ae8-9573-03308d171690', '2011-10-22', N'BVBA');

-- Rechtspersoon 23: Laurent Fashion BV
-- KBO-nummer: BE 0402.202.222
-- Rechtsvorm: BV
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('f122ccf7-6284-5eac-a61d-2967557ae8c9', 'LEGAL', 'DS-2022', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('f122ccf7-6284-5eac-a61d-2967557ae8c9', '2012-11-23', N'BV');

-- Rechtspersoon 24: Dupont Chemicals NV
-- KBO-nummer: BE 0402.302.323
-- Rechtsvorm: NV
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('636a5d26-0c39-5a09-a6e7-8811d53c0318', 'LEGAL', 'DS-2023', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('636a5d26-0c39-5a09-a6e7-8811d53c0318', '2013-12-24', N'NV');

-- Rechtspersoon 25: Martin Logistics BV
-- KBO-nummer: BE 0402.402.424
-- Rechtsvorm: BV
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('951951e9-c892-5d3c-b020-532ebc2f2366', 'LEGAL', 'DS-2024', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('951951e9-c892-5d3c-b020-532ebc2f2366', '2014-01-25', N'BV');

-- Rechtspersoon 26: Lambert Consulting BVBA
-- KBO-nummer: BE 0402.502.525
-- Rechtsvorm: BVBA
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('c0146502-2f88-5913-b145-a6c7cb7c08b5', 'LEGAL', 'DS-2025', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('c0146502-2f88-5913-b145-a6c7cb7c08b5', '2015-02-26', N'BVBA');

-- Rechtspersoon 27: Simon Construction NV
-- KBO-nummer: BE 0402.602.626
-- Rechtsvorm: NV
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('b62f5b68-3d2c-5792-9db9-b227fcb7de91', 'LEGAL', 'DS-2026', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('b62f5b68-3d2c-5792-9db9-b227fcb7de91', '2016-03-27', N'NV');

-- Rechtspersoon 28: Lefevre Insurance BV
-- KBO-nummer: BE 0402.702.727
-- Rechtsvorm: BV
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('ab45849f-6e62-54a1-8e7e-e1556d252c07', 'LEGAL', 'DS-2027', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('ab45849f-6e62-54a1-8e7e-e1556d252c07', '2017-04-28', N'BV');

-- Rechtspersoon 29: Dubont Trading NV
-- KBO-nummer: BE 0402.802.828
-- Rechtsvorm: NV
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('a5d973cf-abdf-5c44-bb1e-2fe539d28fb2', 'LEGAL', 'DS-2028', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('a5d973cf-abdf-5c44-bb1e-2fe539d28fb2', '2018-05-01', N'NV');

-- Rechtspersoon 30: Moreau Real Estate NV
-- KBO-nummer: BE 0402.902.929
-- Rechtsvorm: NV
INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality, created_at, updated_at)
VALUES ('b1c38d1e-dccb-5a55-af82-895fe2d17653', 'LEGAL', 'DS-2029', 'NL', 'Belg', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
VALUES ('b1c38d1e-dccb-5a55-af82-895fe2d17653', '2019-06-02', N'NV');

PRINT '30 rechtspersonen ingevoegd.';
GO

-- =============================================================
-- D. 80 Adressen
-- Woningadres, werkadres, facturatieadres, correspondentieadres
-- =============================================================

-- Adres 1: Nationalestraat 1 bus 1, 2800 Mechelen
-- Type: Woningadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('fe4da872-850c-549c-85a2-7d696e4b43cc', '219711d4-f1e9-5b7c-84bc-490a41110884', 'RESIDENTIEE', N'Nationalestraat', N'1', N'1', N'2800', N'Mechelen', 'Belgie', 'BE', 1, SYSUTCDATETIME());

-- Adres 2: Hoogstraat 2, 1000 Brussel
-- Type: Werkadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('b7462896-8a49-5b59-abf5-7620d79ff603', '7268581b-0dbd-52b1-b752-40aebb63d0a5', 'BEROEP', N'Hoogstraat', N'2', NULL, N'1000', N'Brussel', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 3: Kerkstraat 3, 9000 Gent
-- Type: Facturatieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('7e8c4af2-f780-5c8f-981a-8cf2eb76cd31', '767455ff-6716-57b8-8b1b-07625f980552', 'FACTURATIE', N'Kerkstraat', N'3', NULL, N'9000', N'Gent', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 4: Dorpstraat 4 bus 4, 2000 Antwerpen
-- Type: Correspondentieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('802e3bd5-b225-5534-8226-885ef6d32c75', '6ef2fb59-c4d6-509d-82b7-86ba6954d512', 'KORRESPONDENTIE', N'Dorpstraat', N'4', N'4', N'2000', N'Antwerpen', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 5: Stationsstraat 5, 3000 Leuven
-- Type: Bezoekadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('f2b130a9-b7f7-520b-88cb-da79c4c4287c', 'f2ebd19a-69e8-50cc-bc6f-290e94deb79a', 'BEZOEK', N'Stationsstraat', N'5', NULL, N'3000', N'Leuven', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 6: Markt 6, 3500 Hasselt
-- Type: Woningadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('6a67b38c-419d-5c74-96fa-26c130c8dbd6', '8dbcaf2e-12f0-51a4-ac0d-1e65bd18488a', 'RESIDENTIEE', N'Markt', N'6', NULL, N'3500', N'Hasselt', 'Belgie', 'BE', 1, SYSUTCDATETIME());

-- Adres 7: Grote Markt 7 bus 7, 8000 Brugge
-- Type: Werkadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('4f1372e0-f573-5185-b122-b5ae853a768b', 'd421bbf2-d9ea-5c6c-94e1-822811b8482f', 'BEROEP', N'Grote Markt', N'7', N'7', N'8000', N'Brugge', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 8: Koning Albertstraat 8, 5000 Namen
-- Type: Facturatieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('5ee5114c-f12d-5b3e-ba47-38feb180f11f', 'c54ae5ab-b164-5d26-ab0e-1226a794ba00', 'FACTURATIE', N'Koning Albertstraat', N'8', NULL, N'5000', N'Namen', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 9: Bondgenotenlaan 9, 4000 Luik
-- Type: Correspondentieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('120d6e45-5caf-539f-b4d4-b0cf75dc7056', '2918c7dc-bf8a-5adf-a342-2f427ea33ad2', 'KORRESPONDENTIE', N'Bondgenotenlaan', N'9', NULL, N'4000', N'Luik', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 10: Brusselsesteenweg 10 bus 10, 8500 Kortrijk
-- Type: Bezoekadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('c4b20757-525c-52cc-84b3-d58e6c3f2e14', '06d5be89-2291-5bb5-9a22-906efcffbfca', 'BEZOEK', N'Brusselsesteenweg', N'10', N'10', N'8500', N'Kortrijk', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 11: Gentsesteenweg 11, 8400 Oostende
-- Type: Woningadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('c65d6ac3-c1e6-5008-90f5-68a3e671378e', '5485d4fb-5fe5-5d99-bddd-cd9ca895e3e7', 'RESIDENTIEE', N'Gentsesteenweg', N'11', NULL, N'8400', N'Oostende', 'Belgie', 'BE', 1, SYSUTCDATETIME());

-- Adres 12: Antwerpsesteenweg 12, 9100 Sint-Niklaas
-- Type: Werkadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('d8fbb8a8-72de-599f-8c4e-6ab39a96d4b9', '0f0f2938-e0e5-5dd6-aac5-f9c21720495d', 'BEROEP', N'Antwerpsesteenweg', N'12', NULL, N'9100', N'Sint-Niklaas', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 13: Leuvensesteenweg 13 bus 13, 3600 Genk
-- Type: Facturatieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('122ac4ac-a972-5fc3-b689-8f50dc8cf1c7', '31572584-1fed-582a-9c35-e4c7812029e6', 'FACTURATIE', N'Leuvensesteenweg', N'13', N'13', N'3600', N'Genk', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 14: Mechelsesteenweg 14, 2300 Turnhout
-- Type: Correspondentieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('80994fcc-badc-52e1-bc54-5cf6d0d8b634', '255fbd61-4611-58f5-8a9d-5a1d9d900509', 'KORRESPONDENTIE', N'Mechelsesteenweg', N'14', NULL, N'2300', N'Turnhout', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 15: Luiksesteenweg 15, 2500 Lier
-- Type: Bezoekadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('8f752a6d-a829-5458-9686-25307f13a31b', 'ece43643-6bf6-5ba3-aa12-86b4e6f28c98', 'BEZOEK', N'Luiksesteenweg', N'15', NULL, N'2500', N'Lier', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 16: Nieuwstraat 16 bus 16, 9300 Aalst
-- Type: Woningadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('9908874c-11ee-543c-b4ba-90edfbfd4012', 'a457648d-1590-5e2f-b8bf-a23785c04f64', 'RESIDENTIEE', N'Nieuwstraat', N'16', N'16', N'9300', N'Aalst', 'Belgie', 'BE', 1, SYSUTCDATETIME());

-- Adres 17: Zuidstraat 17, 1800 Vilvoorde
-- Type: Werkadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('6c4c1729-492f-5fca-9229-915dee93772e', 'e2f6b781-f674-5f9d-8b42-126c1bee3960', 'BEROEP', N'Zuidstraat', N'17', NULL, N'1800', N'Vilvoorde', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 18: Noordstraat 18, 2200 Herentals
-- Type: Facturatieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('ed9c7441-4da2-5a34-b7e8-4b6bfba09632', 'c6ad9b62-ec86-53f5-a4b6-013a6d736cf5', 'FACTURATIE', N'Noordstraat', N'18', NULL, N'2200', N'Herentals', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 19: Oude Baan 19 bus 19, 2400 Mol
-- Type: Correspondentieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('ed754116-07a4-5945-872f-fb414efefb81', 'e70a286c-911f-5e09-b03c-0931a765f2f7', 'KORRESPONDENTIE', N'Oude Baan', N'19', N'19', N'2400', N'Mol', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 20: Nieuwe Baan 20, 3200 Aarschot
-- Type: Bezoekadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('86fc5b98-2d12-5a3a-8261-eae83ac306b2', '2967832c-6861-5b2e-90bd-7601cade376f', 'BEZOEK', N'Nieuwe Baan', N'20', NULL, N'3200', N'Aarschot', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 21: Kapucijnenstraat 21, 3300 Tienen
-- Type: Woningadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('a9227413-c3e3-5422-a5a9-6d9d309abb51', 'e094bb9e-83a3-5264-9a36-5feb477fe2b4', 'RESIDENTIEE', N'Kapucijnenstraat', N'21', NULL, N'3300', N'Tienen', 'Belgie', 'BE', 1, SYSUTCDATETIME());

-- Adres 22: Bosstraat 22 bus 2, 3800 Sint-Truiden
-- Type: Werkadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('2273dba5-b0ab-5393-b6b1-d490758d831e', '7ca7f3fb-f978-5ca7-ac09-18c47085b64f', 'BEROEP', N'Bosstraat', N'22', N'2', N'3800', N'Sint-Truiden', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 23: Dreef 23, 3700 Tongeren
-- Type: Facturatieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('7ad0ddfe-4fc4-5cb1-aaea-7bb06a695bbb', '54380520-048a-553e-9b82-c25ea502a113', 'FACTURATIE', N'Dreef', N'23', NULL, N'3700', N'Tongeren', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 24: Parklaan 24, 1600 Sint-Pieters-Leeuw
-- Type: Correspondentieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('6a7c2e0e-3fb4-5167-b84f-ac49a512b8a7', 'acbb80cd-970f-54be-807c-3acece52e150', 'KORRESPONDENTIE', N'Parklaan', N'24', NULL, N'1600', N'Sint-Pieters-Leeuw', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 25: Ringlaan 25 bus 5, 1700 Dilbeek
-- Type: Bezoekadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('899dae6b-c9db-5a7e-ac00-1d87350dcf36', '10839728-a402-5e53-b47e-591900ca1d56', 'BEZOEK', N'Ringlaan', N'25', N'5', N'1700', N'Dilbeek', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 26: Eikenlaan 26, 1500 Halle
-- Type: Woningadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('dfb7aa9e-91dc-57cc-bb38-58ccc6894974', 'd4206c62-2be6-5450-bcd5-c43fe3463f2a', 'RESIDENTIEE', N'Eikenlaan', N'26', NULL, N'1500', N'Halle', 'Belgie', 'BE', 1, SYSUTCDATETIME());

-- Adres 27: Kastanjedreef 27, 2600 Berchem
-- Type: Werkadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('6f047e86-05b3-5050-968d-778a16d54a92', '375d8d17-ca43-59a4-86e1-5a47fe1cfed3', 'BEROEP', N'Kastanjedreef', N'27', NULL, N'2600', N'Berchem', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 28: Beukenlaan 28 bus 8, 2100 Deurne
-- Type: Facturatieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('4fd3be39-3094-5828-b312-816bb0f5da86', '656aa8fc-7e79-5ca1-bcbb-8a8fd46538c3', 'FACTURATIE', N'Beukenlaan', N'28', N'8', N'2100', N'Deurne', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 29: Elsstraat 29, 1070 Anderlecht
-- Type: Correspondentieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('70ccf073-c199-5427-8ef8-7e792a9261de', 'eb00cae9-803c-5162-86c2-9e3a21ad4d4f', 'KORRESPONDENTIE', N'Elsstraat', N'29', NULL, N'1070', N'Anderlecht', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 30: Spoordreef 30, 1030 Schaarbeek
-- Type: Bezoekadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('02918f5d-f854-5ce3-abec-78309b2b99cd', '51eb00ad-860f-586b-8f93-b076bf073683', 'BEZOEK', N'Spoordreef', N'30', NULL, N'1030', N'Schaarbeek', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 31: Industrielaan 31 bus 11, 2018 Antwerpen
-- Type: Woningadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('d4d73967-ceaa-592e-9a30-253ce620446f', 'b1d210cc-ae2e-551a-b0ea-32b380583aa0', 'RESIDENTIEE', N'Industrielaan', N'31', N'11', N'2018', N'Antwerpen', 'Belgie', 'BE', 1, SYSUTCDATETIME());

-- Adres 32: Handelsstraat 32, 2950 Kapellen
-- Type: Werkadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('26d54d5b-72b1-508a-bbaa-cb01e1643fdf', 'a9c72bff-21c7-514d-afe4-d90b7fd0734c', 'BEROEP', N'Handelsstraat', N'32', NULL, N'2950', N'Kapellen', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 33: Zavelstraat 33, 2550 Kontich
-- Type: Facturatieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('c65209c3-17b6-5c94-b146-9273e0bfe4a9', '94d4279a-d4bc-546b-8483-62b3d48fadc9', 'FACTURATIE', N'Zavelstraat', N'33', NULL, N'2550', N'Kontich', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 34: Molenstraat 34 bus 14, 2640 Mortsel
-- Type: Correspondentieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('9b910262-a004-5774-9c5f-46e266450124', 'e9fa3f32-8a88-58f7-aa16-19c078b73812', 'KORRESPONDENTIE', N'Molenstraat', N'34', N'14', N'2640', N'Mortsel', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 35: Schoolstraat 35, 2980 Zoersel
-- Type: Bezoekadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('bc8b6114-ad73-553a-9453-ebbea3e01ce1', '5aa15f2f-d6e3-5834-9b99-ce48aab774c2', 'BEZOEK', N'Schoolstraat', N'35', NULL, N'2980', N'Zoersel', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 36: Sportlaan 36, 2920 Kalmthout
-- Type: Woningadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('e1a18b11-a7f5-528d-81dc-784a4634ccab', 'e162f9ae-c21f-5642-99c5-9a9ac7fe0ffa', 'RESIDENTIEE', N'Sportlaan', N'36', NULL, N'2920', N'Kalmthout', 'Belgie', 'BE', 1, SYSUTCDATETIME());

-- Adres 37: Cultuurstraat 37 bus 17, 2930 Brasschaat
-- Type: Werkadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('35f6b4a7-3bd7-58af-8bab-f52c5bed07f8', '7e25fdf9-3052-52e7-8753-d64356fdade7', 'BEROEP', N'Cultuurstraat', N'37', N'17', N'2930', N'Brasschaat', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 38: Winkelstraat 38, 2900 Schoten
-- Type: Facturatieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('75d52a52-999c-5999-8634-eee9447a71b1', '3ecbc905-9da6-5b0b-9f39-dc903be90d58', 'FACTURATIE', N'Winkelstraat', N'38', NULL, N'2900', N'Schoten', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 39: Diamantstraat 39, 2140 Borgerhout
-- Type: Correspondentieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('490fbd3f-1eb0-50f7-a46a-040fcac60439', '12ea6164-808c-5aa4-ab79-956ddd949d5e', 'KORRESPONDENTIE', N'Diamantstraat', N'39', NULL, N'2140', N'Borgerhout', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 40: Zilversparrenlaan 40 bus 20, 2050 Antwerpen
-- Type: Bezoekadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('fb88182c-0c25-59bf-b9c7-48eb16eb55d3', 'cf9fe55e-fcdd-553e-8bc7-f1e799743ce5', 'BEZOEK', N'Zilversparrenlaan', N'40', N'20', N'2050', N'Antwerpen', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 41: Nationalestraat 41, 2070 Zwijndrecht
-- Type: Woningadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('d9d33f47-0f52-596d-b1d0-b8a4362b3b15', '88275840-7a64-5c38-91b3-167e286f560d', 'RESIDENTIEE', N'Nationalestraat', N'41', NULL, N'2070', N'Zwijndrecht', 'Belgie', 'BE', 1, SYSUTCDATETIME());

-- Adres 42: Hoogstraat 42, 2850 Boom
-- Type: Werkadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('37b3328a-1dcf-580f-83f0-68c87ce9099a', 'abeaecc5-308d-5d45-9eb1-21caed5274ff', 'BEROEP', N'Hoogstraat', N'42', NULL, N'2850', N'Boom', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 43: Kerkstraat 43 bus 3, 2860 Sint-Katelijne-Waver
-- Type: Facturatieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('b9bff0b2-c23d-552d-b4d5-2f5ed0d88487', 'e77a50fb-c6c7-5c28-aaeb-b64672bd3a88', 'FACTURATIE', N'Kerkstraat', N'43', N'3', N'2860', N'Sint-Katelijne-Waver', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 44: Dorpstraat 44, 2811 Hever
-- Type: Correspondentieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('f1bf74bf-e66c-557b-bb40-29315a537df4', 'ecbb77f5-a7db-558a-b13a-42fd2094023e', 'KORRESPONDENTIE', N'Dorpstraat', N'44', NULL, N'2811', N'Hever', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 45: Stationsstraat 45, 2820 Rijmenam
-- Type: Bezoekadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('71ad45a7-04d1-5d67-bb5f-b9f62eb2b5df', 'e32a64f6-c0df-580e-bbd4-18dca5aa25cb', 'BEZOEK', N'Stationsstraat', N'45', NULL, N'2820', N'Rijmenam', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 46: Markt 46 bus 6, 2830 Willebroek
-- Type: Woningadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('923488c3-36da-5497-82c1-ba15e53276b0', 'e881e046-e826-5fdf-aee9-d7ef20db2171', 'RESIDENTIEE', N'Markt', N'46', N'6', N'2830', N'Willebroek', 'Belgie', 'BE', 1, SYSUTCDATETIME());

-- Adres 47: Grote Markt 47, 2840 Reet
-- Type: Werkadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('ba6c555a-4072-5545-9efe-145eda942012', '1b0efd79-d7eb-5f8a-bad6-66c8d683363c', 'BEROEP', N'Grote Markt', N'47', NULL, N'2840', N'Reet', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 48: Koning Albertstraat 48, 2870 Puurs
-- Type: Facturatieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('a3eec6da-cc35-5e27-a67b-88739cd30e1e', '686d7d6b-464a-5c2e-983b-467383404638', 'FACTURATIE', N'Koning Albertstraat', N'48', NULL, N'2870', N'Puurs', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 49: Bondgenotenlaan 49 bus 9, 2880 Bornem
-- Type: Correspondentieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('c32a135b-54c0-5035-8a2d-c5a68cc7505b', 'af92e0ba-9be1-5452-ac95-69f85d04ad74', 'KORRESPONDENTIE', N'Bondgenotenlaan', N'49', N'9', N'2880', N'Bornem', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 50: Brusselsesteenweg 50, 2890 Sint-Amands
-- Type: Bezoekadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('df45ba46-b5ba-5538-8468-af48dc9725d9', '356e6f20-40fd-5f52-8c7c-a7f81d3f1990', 'BEZOEK', N'Brusselsesteenweg', N'50', NULL, N'2890', N'Sint-Amands', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 51: Gentsesteenweg 51, 2940 Stabroek
-- Type: Woningadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('42384a52-fcc6-58af-b10a-52b68d22983a', '3b48a949-5c44-50da-91e7-6fc728cd9efe', 'RESIDENTIEE', N'Gentsesteenweg', N'51', NULL, N'2940', N'Stabroek', 'Belgie', 'BE', 1, SYSUTCDATETIME());

-- Adres 52: Antwerpsesteenweg 52 bus 12, 2960 Brecht
-- Type: Werkadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('cdccd254-a987-51d7-b1d8-dcff6d2312b9', 'a3671e77-d7bb-585a-a448-7502bd4e76a6', 'BEROEP', N'Antwerpsesteenweg', N'52', N'12', N'2960', N'Brecht', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 53: Leuvensesteenweg 53, 2970 s Gravenwezel
-- Type: Facturatieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('26931fd7-895a-5118-86eb-d178279af0a4', '3abca959-e7f6-5fcb-a863-634279e1c837', 'FACTURATIE', N'Leuvensesteenweg', N'53', NULL, N'2970', N's Gravenwezel', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 54: Mechelsesteenweg 54, 2990 Loenhout
-- Type: Correspondentieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('f6ef746a-ffe4-5361-b061-6ad0c5f881c9', '6c8d4d1f-aedb-5dad-b385-02ee2c37862d', 'KORRESPONDENTIE', N'Mechelsesteenweg', N'54', NULL, N'2990', N'Loenhout', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 55: Luiksesteenweg 55 bus 15, 2800 Mechelen
-- Type: Bezoekadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('5481437c-f4b7-5192-82dd-17659cfe5747', '04d877fb-dbbf-5695-8ff9-eb6a39435ec7', 'BEZOEK', N'Luiksesteenweg', N'55', N'15', N'2800', N'Mechelen', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 56: Nieuwstraat 56, 1000 Brussel
-- Type: Woningadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('a5af32a4-c345-5fd2-832c-a13efba37fe5', 'c00f1a58-7e96-5163-b7ba-cd2447bd10de', 'RESIDENTIEE', N'Nieuwstraat', N'56', NULL, N'1000', N'Brussel', 'Belgie', 'BE', 1, SYSUTCDATETIME());

-- Adres 57: Zuidstraat 57, 9000 Gent
-- Type: Werkadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('1dc07e51-a968-555e-9408-b51a5a0c25ec', '991e2044-f65e-59e7-9aa7-aca0480964e7', 'BEROEP', N'Zuidstraat', N'57', NULL, N'9000', N'Gent', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 58: Noordstraat 58 bus 18, 2000 Antwerpen
-- Type: Facturatieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('477bf120-1944-5ecc-97a9-d880ab924b25', '14c5ccbc-89cf-5c44-b7e7-29b06d259abc', 'FACTURATIE', N'Noordstraat', N'58', N'18', N'2000', N'Antwerpen', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 59: Oude Baan 59, 3000 Leuven
-- Type: Correspondentieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('78563fac-f002-5916-b63d-1ef175302742', '89c4f9fd-dd84-5d2d-858c-258a704f5e61', 'KORRESPONDENTIE', N'Oude Baan', N'59', NULL, N'3000', N'Leuven', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 60: Nieuwe Baan 60, 3500 Hasselt
-- Type: Bezoekadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('7c6fe077-1833-5ce1-be4c-d4e9b1b70dd0', 'b4a7ca2a-d48b-5263-91a4-20e5a5dd46b7', 'BEZOEK', N'Nieuwe Baan', N'60', NULL, N'3500', N'Hasselt', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 61: Kapucijnenstraat 61 bus 1, 8000 Brugge
-- Type: Woningadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('24ded231-20a3-5e28-8974-d64fd7ee43d0', '9c252156-2f74-5e40-a546-b06451d644bb', 'RESIDENTIEE', N'Kapucijnenstraat', N'61', N'1', N'8000', N'Brugge', 'Belgie', 'BE', 1, SYSUTCDATETIME());

-- Adres 62: Bosstraat 62, 5000 Namen
-- Type: Werkadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('5de84eae-7ca5-5cc4-9f3f-46e1db3a6e06', 'ea676367-9ce6-5ddf-88b3-01b7448863cf', 'BEROEP', N'Bosstraat', N'62', NULL, N'5000', N'Namen', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 63: Dreef 63, 4000 Luik
-- Type: Facturatieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('f7b18cc8-3732-50ad-9ea7-2a1ebed993e5', 'f394a7ee-4516-5eda-94be-6cbfc295962d', 'FACTURATIE', N'Dreef', N'63', NULL, N'4000', N'Luik', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 64: Parklaan 64 bus 4, 8500 Kortrijk
-- Type: Correspondentieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('afc45d32-7fb6-5752-9256-da89fe549e8e', '8ff1d038-f9b7-5fa0-8a9e-983f7231aa0c', 'KORRESPONDENTIE', N'Parklaan', N'64', N'4', N'8500', N'Kortrijk', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 65: Ringlaan 65, 8400 Oostende
-- Type: Bezoekadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('aaf3ab9a-64fe-5931-ac3f-e4f1f71b221a', '20ecd889-e82d-5e3b-8d53-30b27c48ac83', 'BEZOEK', N'Ringlaan', N'65', NULL, N'8400', N'Oostende', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 66: Eikenlaan 66, 9100 Sint-Niklaas
-- Type: Woningadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('00132878-3b8a-5811-b01b-674dcacaeb83', '3247f51a-b5e6-5032-89c4-07f5959fd455', 'RESIDENTIEE', N'Eikenlaan', N'66', NULL, N'9100', N'Sint-Niklaas', 'Belgie', 'BE', 1, SYSUTCDATETIME());

-- Adres 67: Kastanjedreef 67 bus 7, 3600 Genk
-- Type: Werkadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('fd44c6ba-61ee-551e-b99b-4caf31f04ea6', '68b80efe-45b2-570d-aec1-276848865fb8', 'BEROEP', N'Kastanjedreef', N'67', N'7', N'3600', N'Genk', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 68: Beukenlaan 68, 2300 Turnhout
-- Type: Facturatieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('03067dd1-19cd-507e-bfaf-eb1e2e990eba', '8ec3e9ff-6edc-59d3-916a-8c9bf11193e9', 'FACTURATIE', N'Beukenlaan', N'68', NULL, N'2300', N'Turnhout', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 69: Elsstraat 69, 2500 Lier
-- Type: Correspondentieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('6d2389e7-413c-590e-90f9-ef14db978f2f', '840a663b-9633-5af4-ad27-4b4422a4cfec', 'KORRESPONDENTIE', N'Elsstraat', N'69', NULL, N'2500', N'Lier', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 70: Spoordreef 70 bus 10, 9300 Aalst
-- Type: Bezoekadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('1a602811-d770-5c55-98f1-3fd3c63e835e', 'af66737e-f2b9-5370-b42a-659e687139ac', 'BEZOEK', N'Spoordreef', N'70', N'10', N'9300', N'Aalst', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 71: Industrielaan 71, 1800 Vilvoorde
-- Type: Woningadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('ddba4e9f-8e70-5829-a15a-87c587aaf13e', '078c5ddc-92b3-5802-9d13-f015bbb4d88e', 'RESIDENTIEE', N'Industrielaan', N'71', NULL, N'1800', N'Vilvoorde', 'Belgie', 'BE', 1, SYSUTCDATETIME());

-- Adres 72: Handelsstraat 72, 2200 Herentals
-- Type: Werkadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('72e09dd4-1ef2-596b-8f16-3d264b2ddf7c', '71e7a6d0-7fce-5ae8-9573-03308d171690', 'BEROEP', N'Handelsstraat', N'72', NULL, N'2200', N'Herentals', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 73: Zavelstraat 73 bus 13, 2400 Mol
-- Type: Facturatieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('7f5b74c1-5390-5012-99cd-b459e667e264', 'f122ccf7-6284-5eac-a61d-2967557ae8c9', 'FACTURATIE', N'Zavelstraat', N'73', N'13', N'2400', N'Mol', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 74: Molenstraat 74, 3200 Aarschot
-- Type: Correspondentieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('7549eee5-a8c6-5863-ba6f-cb25cf40757d', '636a5d26-0c39-5a09-a6e7-8811d53c0318', 'KORRESPONDENTIE', N'Molenstraat', N'74', NULL, N'3200', N'Aarschot', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 75: Schoolstraat 75, 3300 Tienen
-- Type: Bezoekadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('68bb8fac-d100-545b-bb6e-3895e5ce62fa', '951951e9-c892-5d3c-b020-532ebc2f2366', 'BEZOEK', N'Schoolstraat', N'75', NULL, N'3300', N'Tienen', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 76: Sportlaan 76 bus 16, 3800 Sint-Truiden
-- Type: Woningadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('24d82e5e-8222-51ff-8c44-922801aa15af', 'c0146502-2f88-5913-b145-a6c7cb7c08b5', 'RESIDENTIEE', N'Sportlaan', N'76', N'16', N'3800', N'Sint-Truiden', 'Belgie', 'BE', 1, SYSUTCDATETIME());

-- Adres 77: Cultuurstraat 77, 3700 Tongeren
-- Type: Werkadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('6a43ec93-9d7f-5bee-bfc3-84c499ed918d', 'b62f5b68-3d2c-5792-9db9-b227fcb7de91', 'BEROEP', N'Cultuurstraat', N'77', NULL, N'3700', N'Tongeren', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 78: Winkelstraat 78, 1600 Sint-Pieters-Leeuw
-- Type: Facturatieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('12a21c11-3e08-5e5a-9cab-33e3d2c64a1e', 'ab45849f-6e62-54a1-8e7e-e1556d252c07', 'FACTURATIE', N'Winkelstraat', N'78', NULL, N'1600', N'Sint-Pieters-Leeuw', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 79: Diamantstraat 79 bus 19, 1700 Dilbeek
-- Type: Correspondentieadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('018e87f2-3f6a-5258-9c32-d6dde9bd4403', 'a5d973cf-abdf-5c44-bb1e-2fe539d28fb2', 'KORRESPONDENTIE', N'Diamantstraat', N'79', N'19', N'1700', N'Dilbeek', 'Belgie', 'BE', 0, SYSUTCDATETIME());

-- Adres 80: Zilversparrenlaan 80, 1500 Halle
-- Type: Bezoekadres
INSERT INTO Address (address_id, person_id, address_role_code, street, house_number, box, postal_code, city, country, country_code, is_primary, created_at)
VALUES ('42203301-de70-5fc8-bef1-97b39cfe5e99', 'b1c38d1e-dccb-5a55-af82-895fe2d17653', 'BEZOEK', N'Zilversparrenlaan', N'80', NULL, N'1500', N'Halle', 'Belgie', 'BE', 0, SYSUTCDATETIME());

PRINT '80 adressen ingevoegd.';
GO

-- =============================================================
-- E. 60 Telefoonnummers
-- Belgische formaten: +32 X XXX XX XX (vast) en +32 4XX XX XX XX (mobiel)
-- =============================================================

-- Telefoon 1: +32 2 100 10 10 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('e76ea5c2-026c-5d15-bb4d-91d68ae62610', '219711d4-f1e9-5b7c-84bc-490a41110884', N'+32 2 100 10 10', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 2: +32 482 11 11 11 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('39c3944f-50b0-5844-9abe-dd279e2de0d9', '7268581b-0dbd-52b1-b752-40aebb63d0a5', N'+32 482 11 11 11', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 3: +32 4 102 12 12 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('80b08857-a8da-5ad3-a3b5-86d6c333e144', '767455ff-6716-57b8-8b1b-07625f980552', N'+32 4 102 12 12', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 4: +32 474 13 13 13 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('1b617940-9ab4-511b-8b9d-d32c159df707', '6ef2fb59-c4d6-509d-82b7-86ba6954d512', N'+32 474 13 13 13', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 5: +32 6 104 14 14 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('73750fa3-dd2c-5b20-bf75-c699eacbc740', 'f2ebd19a-69e8-50cc-bc6f-290e94deb79a', N'+32 6 104 14 14', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 6: +32 496 15 15 15 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('109446aa-6ee3-5129-8c3e-51d68b7b5565', '8dbcaf2e-12f0-51a4-ac0d-1e65bd18488a', N'+32 496 15 15 15', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 7: +32 8 106 16 16 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('c75ba2bb-efb1-5033-b7ed-4f85727889d8', 'd421bbf2-d9ea-5c6c-94e1-822811b8482f', N'+32 8 106 16 16', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 8: +32 488 17 17 17 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('f66a7373-8874-5738-989d-84f5d807079e', 'c54ae5ab-b164-5d26-ab0e-1226a794ba00', N'+32 488 17 17 17', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 9: +32 2 108 18 18 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('3540c359-4b4a-5303-8643-72899d26c074', '2918c7dc-bf8a-5adf-a342-2f427ea33ad2', N'+32 2 108 18 18', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 10: +32 471 19 19 19 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('e9761b7b-6e1a-5a23-a548-20bd4f65e3a2', '06d5be89-2291-5bb5-9a22-906efcffbfca', N'+32 471 19 19 19', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 11: +32 4 110 20 20 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('3646b056-69bd-54f9-8ffa-812506330fb0', '5485d4fb-5fe5-5d99-bddd-cd9ca895e3e7', N'+32 4 110 20 20', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 12: +32 493 21 21 21 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('bd8054bc-af0b-5418-bf6b-80335aec0ba0', '0f0f2938-e0e5-5dd6-aac5-f9c21720495d', N'+32 493 21 21 21', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 13: +32 6 112 22 22 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('cc7adc48-4cec-5ce1-9673-65b05e90b3e9', '31572584-1fed-582a-9c35-e4c7812029e6', N'+32 6 112 22 22', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 14: +32 485 23 23 23 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('bf70b231-d3a2-5064-afcd-9494d3764ead', '255fbd61-4611-58f5-8a9d-5a1d9d900509', N'+32 485 23 23 23', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 15: +32 8 114 24 24 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('94f36d0f-2716-53d7-b0ab-96c38e5f9d9e', 'ece43643-6bf6-5ba3-aa12-86b4e6f28c98', N'+32 8 114 24 24', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 16: +32 477 25 25 25 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('4a5a1e25-e93e-5e81-abe4-62733aae1f30', 'a457648d-1590-5e2f-b8bf-a23785c04f64', N'+32 477 25 25 25', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 17: +32 2 116 26 26 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('dec53cc6-93bb-5bc3-b6b6-1c3c8a698277', 'e2f6b781-f674-5f9d-8b42-126c1bee3960', N'+32 2 116 26 26', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 18: +32 499 27 27 27 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('f394b7ae-3b59-55ec-bbde-c75dcd1586e1', 'c6ad9b62-ec86-53f5-a4b6-013a6d736cf5', N'+32 499 27 27 27', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 19: +32 4 118 28 28 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('17437ca0-9910-5ab0-ba40-fce0255cc019', 'e70a286c-911f-5e09-b03c-0931a765f2f7', N'+32 4 118 28 28', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 20: +32 482 29 29 29 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('b77bfd07-dbd2-5926-8531-eda9ff36cdf9', '2967832c-6861-5b2e-90bd-7601cade376f', N'+32 482 29 29 29', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 21: +32 6 120 30 30 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('24600137-be1d-587c-aedd-bd3591c0fcaf', 'e094bb9e-83a3-5264-9a36-5feb477fe2b4', N'+32 6 120 30 30', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 22: +32 474 31 31 31 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('ebd6e692-6827-5ad0-a87a-ed59b6a0880d', '7ca7f3fb-f978-5ca7-ac09-18c47085b64f', N'+32 474 31 31 31', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 23: +32 8 122 32 32 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('eb3b44bc-a4db-5337-94d9-6adc26c37e81', '54380520-048a-553e-9b82-c25ea502a113', N'+32 8 122 32 32', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 24: +32 496 33 33 33 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('ef88aea7-8ac5-57ee-9b5b-4d2d1597f856', 'acbb80cd-970f-54be-807c-3acece52e150', N'+32 496 33 33 33', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 25: +32 2 124 34 34 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('b63b6f0d-8bbf-5739-b4b8-5ce0c0a46513', '10839728-a402-5e53-b47e-591900ca1d56', N'+32 2 124 34 34', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 26: +32 488 35 35 35 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('49aa61f5-0789-5c04-96f8-3565c8f19d4b', 'd4206c62-2be6-5450-bcd5-c43fe3463f2a', N'+32 488 35 35 35', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 27: +32 4 126 36 36 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('95f939c7-c84c-5360-a033-c6af613bfe34', '375d8d17-ca43-59a4-86e1-5a47fe1cfed3', N'+32 4 126 36 36', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 28: +32 471 37 37 37 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('420b0232-d807-54fd-a49f-3415340fe352', '656aa8fc-7e79-5ca1-bcbb-8a8fd46538c3', N'+32 471 37 37 37', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 29: +32 6 128 38 38 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('7d57a9b0-f5f5-503b-a5a4-91cdc7a5e998', 'eb00cae9-803c-5162-86c2-9e3a21ad4d4f', N'+32 6 128 38 38', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 30: +32 493 39 39 39 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('cd55cedb-dde6-5b43-ac07-43eabde6434b', '51eb00ad-860f-586b-8f93-b076bf073683', N'+32 493 39 39 39', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 31: +32 8 130 40 40 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('bb443c97-b907-5d41-9651-ca52f8c56940', 'b1d210cc-ae2e-551a-b0ea-32b380583aa0', N'+32 8 130 40 40', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 32: +32 485 41 41 41 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('822e8ee2-6500-5c56-a07a-20eb3f04fc20', 'a9c72bff-21c7-514d-afe4-d90b7fd0734c', N'+32 485 41 41 41', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 33: +32 2 132 42 42 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('298cac33-30a7-59db-b920-49acda2f2078', '94d4279a-d4bc-546b-8483-62b3d48fadc9', N'+32 2 132 42 42', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 34: +32 477 43 43 43 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('69f0be87-4f54-5ad5-84ff-5963804d96b5', 'e9fa3f32-8a88-58f7-aa16-19c078b73812', N'+32 477 43 43 43', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 35: +32 4 134 44 44 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('1dfab014-e102-583d-b8b8-9514886f3c62', '5aa15f2f-d6e3-5834-9b99-ce48aab774c2', N'+32 4 134 44 44', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 36: +32 499 45 45 45 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('711d5971-d9a1-55ba-a33e-96cc1bb54ac4', 'e162f9ae-c21f-5642-99c5-9a9ac7fe0ffa', N'+32 499 45 45 45', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 37: +32 6 136 46 46 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('a440a617-8623-5464-aaf7-5d58053ce169', '7e25fdf9-3052-52e7-8753-d64356fdade7', N'+32 6 136 46 46', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 38: +32 482 47 47 47 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('e0cab999-1c7f-5742-9d35-749eddd323da', '3ecbc905-9da6-5b0b-9f39-dc903be90d58', N'+32 482 47 47 47', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 39: +32 8 138 48 48 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('dd6d7717-c488-5e42-acc7-3ba449f2da0b', '12ea6164-808c-5aa4-ab79-956ddd949d5e', N'+32 8 138 48 48', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 40: +32 474 49 49 49 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('713db5e3-b3c2-5b20-8d54-2a31d2d54a3b', 'cf9fe55e-fcdd-553e-8bc7-f1e799743ce5', N'+32 474 49 49 49', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 41: +32 2 140 50 50 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('658eb30b-4bfd-5bdb-9a24-360fe34f5efc', '88275840-7a64-5c38-91b3-167e286f560d', N'+32 2 140 50 50', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 42: +32 496 51 51 51 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('cd2f3b09-769f-56f9-9086-04465e0d3c35', 'abeaecc5-308d-5d45-9eb1-21caed5274ff', N'+32 496 51 51 51', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 43: +32 4 142 52 52 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('bca84077-2d2b-5fe9-92e6-a243506f5c2a', 'e77a50fb-c6c7-5c28-aaeb-b64672bd3a88', N'+32 4 142 52 52', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 44: +32 488 53 53 53 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('73050e0d-d74a-55d4-9801-9f812b257198', 'ecbb77f5-a7db-558a-b13a-42fd2094023e', N'+32 488 53 53 53', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 45: +32 6 144 54 54 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('299fff83-4da5-5ff6-9af3-9e3e06a3b9b6', 'e32a64f6-c0df-580e-bbd4-18dca5aa25cb', N'+32 6 144 54 54', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 46: +32 471 55 55 55 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('0f090856-5e89-55f1-af5b-de39f2bd4e08', 'e881e046-e826-5fdf-aee9-d7ef20db2171', N'+32 471 55 55 55', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 47: +32 8 146 56 56 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('1b1daae5-f60c-5aa0-ad60-6e4d6622863a', '1b0efd79-d7eb-5f8a-bad6-66c8d683363c', N'+32 8 146 56 56', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 48: +32 493 57 57 57 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('2a41dbdd-6b86-5bea-9cde-f7afe119da3f', '686d7d6b-464a-5c2e-983b-467383404638', N'+32 493 57 57 57', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 49: +32 2 148 58 58 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('6c087398-6d5b-5dbd-a74c-3daf2b378a73', 'af92e0ba-9be1-5452-ac95-69f85d04ad74', N'+32 2 148 58 58', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 50: +32 485 59 59 59 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('410ad27f-5d8c-5554-9c63-b9c560209510', '356e6f20-40fd-5f52-8c7c-a7f81d3f1990', N'+32 485 59 59 59', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 51: +32 4 150 60 60 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('a3ed1188-001b-5db3-bcaa-51fbb49ee5af', '3b48a949-5c44-50da-91e7-6fc728cd9efe', N'+32 4 150 60 60', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 52: +32 477 61 61 61 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('17a063aa-34c8-5ce0-838b-27681beb8723', 'a3671e77-d7bb-585a-a448-7502bd4e76a6', N'+32 477 61 61 61', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 53: +32 6 152 62 62 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('6b66512f-cc2f-5fab-bea3-cc5a9797213e', '3abca959-e7f6-5fcb-a863-634279e1c837', N'+32 6 152 62 62', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 54: +32 499 63 63 63 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('122f4a82-192e-5bc9-aa13-7a8092116a52', '6c8d4d1f-aedb-5dad-b385-02ee2c37862d', N'+32 499 63 63 63', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 55: +32 8 154 64 64 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('ee6d6420-8731-5d3d-9187-c464fd2d1de0', '04d877fb-dbbf-5695-8ff9-eb6a39435ec7', N'+32 8 154 64 64', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 56: +32 482 65 65 65 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('8bd421e4-ba0d-57ec-839a-151688d28428', 'c00f1a58-7e96-5163-b7ba-cd2447bd10de', N'+32 482 65 65 65', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 57: +32 2 156 66 66 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('5cf2f402-e775-51f0-ade9-25b0b6722153', '991e2044-f65e-59e7-9aa7-aca0480964e7', N'+32 2 156 66 66', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 58: +32 474 67 67 67 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('9f5b7941-2348-50db-af42-7841d16c8874', '14c5ccbc-89cf-5c44-b7e7-29b06d259abc', N'+32 474 67 67 67', 'MOBILE', 0, SYSUTCDATETIME());

-- Telefoon 59: +32 4 158 68 68 (Vast nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('b729d417-0bf0-5c0b-8aba-a13c4ad6fbbf', '89c4f9fd-dd84-5d2d-858c-258a704f5e61', N'+32 4 158 68 68', 'LANDLINE', 1, SYSUTCDATETIME());

-- Telefoon 60: +32 496 69 69 69 (Mobiel nummer)
INSERT INTO Phone (phone_id, person_id, phone_number, phone_type_code, is_primary, created_at)
VALUES ('5f6020dd-894d-5369-9376-a4a800eb8116', 'b4a7ca2a-d48b-5263-91a4-20e5a5dd46b7', N'+32 496 69 69 69', 'MOBILE', 0, SYSUTCDATETIME());

PRINT '60 telefoonnummers ingevoegd.';
GO

-- =============================================================
-- F. 60 E-mailadressen
-- =============================================================

-- E-mail 1: jan.de.vries0@gmail.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('ec12f661-3d5b-5b3b-9b72-02f50e241d00', '219711d4-f1e9-5b7c-84bc-490a41110884', N'jan.de.vries0@gmail.com', NULL);

-- E-mail 2: pieter.janssens0@hotmail.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('c730eb46-66b2-5507-a1a4-e1d0f00ae941', '7268581b-0dbd-52b1-b752-40aebb63d0a5', N'pieter.janssens0@hotmail.com', NULL);

-- E-mail 3: thomas.peeters0@outlook.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('6176cad8-6106-59fa-ab54-241b6f927253', '767455ff-6716-57b8-8b1b-07625f980552', N'thomas.peeters0@outlook.com', NULL);

-- E-mail 4: bart.maes0@yahoo.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('112881c6-a617-56f2-a57f-7c1eacb78ef9', '6ef2fb59-c4d6-509d-82b7-86ba6954d512', N'bart.maes0@yahoo.com', NULL);

-- E-mail 5: koen.jacobs0@telenet.be
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('1b0ef0ac-acd3-507d-a608-9168e443299c', 'f2ebd19a-69e8-50cc-bc6f-290e94deb79a', N'koen.jacobs0@telenet.be', NULL);

-- E-mail 6: filip.willems0@proximus.be
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('99cc67d0-5224-5ad7-b866-5b7ea7203344', '8dbcaf2e-12f0-51a4-ac0d-1e65bd18488a', N'filip.willems0@proximus.be', NULL);

-- E-mail 7: david.claes0@skynet.be
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('8637c7a5-2ed2-56bb-b74b-3ef2315d6f73', 'd421bbf2-d9ea-5c6c-94e1-822811b8482f', N'david.claes0@skynet.be', NULL);

-- E-mail 8: jeroen.goossens0@live.be
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('07cb1c87-efc5-561a-8b1d-8bee65a558a3', 'c54ae5ab-b164-5d26-ab0e-1226a794ba00', N'jeroen.goossens0@live.be', NULL);

-- E-mail 9: stefan.wouters0@msn.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('4028ffa2-6ad1-5816-b2ea-d1a2b2ef7719', '2918c7dc-bf8a-5adf-a342-2f427ea33ad2', N'stefan.wouters0@msn.com', NULL);

-- E-mail 10: wouter.de.smet0@icloud.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('a108acc6-f23f-5695-89af-26b50f87ea2c', '06d5be89-2291-5bb5-9a22-906efcffbfca', N'wouter.de.smet0@icloud.com', NULL);

-- E-mail 11: tim.vermeulen0@gmail.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('24c5e0c3-f1a7-5894-a03c-3f353614b5a8', '5485d4fb-5fe5-5d99-bddd-cd9ca895e3e7', N'tim.vermeulen0@gmail.com', NULL);

-- E-mail 12: jonas.van.den.berg0@hotmail.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('3a8a6a52-5465-52fb-a4ab-5fab18909f89', '0f0f2938-e0e5-5dd6-aac5-f9c21720495d', N'jonas.van.den.berg0@hotmail.com', NULL);

-- E-mail 13: bram.martens0@outlook.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('c9dc3ea3-423b-574e-a2b2-3768b8441308', '31572584-1fed-582a-9c35-e4c7812029e6', N'bram.martens0@outlook.com', NULL);

-- E-mail 14: tom.hermans0@yahoo.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('e1908173-ea33-58da-a2ec-6a7512563c88', '255fbd61-4611-58f5-8a9d-5a1d9d900509', N'tom.hermans0@yahoo.com', NULL);

-- E-mail 15: nick.moons0@telenet.be
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('a3bb2771-f9e4-596a-9868-b84810eec9ea', 'ece43643-6bf6-5ba3-aa12-86b4e6f28c98', N'nick.moons0@telenet.be', NULL);

-- E-mail 16: dries.van.dam0@proximus.be
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('5de3f70d-c293-5351-b2a5-3d087883743c', 'a457648d-1590-5e2f-b8bf-a23785c04f64', N'dries.van.dam0@proximus.be', NULL);

-- E-mail 17: kevin.hendrickx0@skynet.be
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('0e55b7ea-55ed-5684-a8c6-0a3902f96be6', 'e2f6b781-f674-5f9d-8b42-126c1bee3960', N'kevin.hendrickx0@skynet.be', NULL);

-- E-mail 18: lucas.desmet0@live.be
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('d2496011-8982-5a4e-9f0b-238032cdde4f', 'c6ad9b62-ec86-53f5-a4b6-013a6d736cf5', N'lucas.desmet0@live.be', NULL);

-- E-mail 19: mathias.vandenberghe0@msn.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('ec1afe04-72fe-5c2a-881f-ef471185c061', 'e70a286c-911f-5e09-b03c-0931a765f2f7', N'mathias.vandenberghe0@msn.com', NULL);

-- E-mail 20: sven.de.backer0@icloud.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('07832f5f-84cb-53f5-b391-84adffd7f625', '2967832c-6861-5b2e-90bd-7601cade376f', N'sven.de.backer0@icloud.com', NULL);

-- E-mail 21: bjorn.smets0@gmail.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('df986e19-5cb8-50b6-8acc-28efeef5a61c', 'e094bb9e-83a3-5264-9a36-5feb477fe2b4', N'bjorn.smets0@gmail.com', NULL);

-- E-mail 22: gert.verhoeven0@hotmail.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('d0236bd3-56db-5f07-af62-5992b195c56d', '7ca7f3fb-f978-5ca7-ac09-18c47085b64f', N'gert.verhoeven0@hotmail.com', NULL);

-- E-mail 23: hans.laurent0@outlook.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('01662b7b-d009-5cdc-a31d-3911c0243de6', '54380520-048a-553e-9b82-c25ea502a113', N'hans.laurent0@outlook.com', NULL);

-- E-mail 24: joeri.dupont0@yahoo.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('3d0a3571-9e53-579f-b38d-0a463bf170d6', 'acbb80cd-970f-54be-807c-3acece52e150', N'joeri.dupont0@yahoo.com', NULL);

-- E-mail 25: kris.martin0@telenet.be
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('69a2da92-34af-5ab6-82df-38b408ff8dfd', '10839728-a402-5e53-b47e-591900ca1d56', N'kris.martin0@telenet.be', NULL);

-- E-mail 26: lars.lambert0@proximus.be
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('65d99610-1bdb-5b9a-9617-36dd3d99930f', 'd4206c62-2be6-5450-bcd5-c43fe3463f2a', N'lars.lambert0@proximus.be', NULL);

-- E-mail 27: pascale.simon0@skynet.be
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('65b1e7ff-76c2-5c54-8426-bfc7e966ac20', '375d8d17-ca43-59a4-86e1-5a47fe1cfed3', N'pascale.simon0@skynet.be', NULL);

-- E-mail 28: riet.lefevre0@live.be
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('97a3c781-596c-57f8-92cf-3bdf6a7303cf', '656aa8fc-7e79-5ca1-bcbb-8a8fd46538c3', N'riet.lefevre0@live.be', NULL);

-- E-mail 29: sara.dubois0@msn.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('bde65b6b-dc0e-585a-a3f5-b5ba12b50e68', 'eb00cae9-803c-5162-86c2-9e3a21ad4d4f', N'sara.dubois0@msn.com', NULL);

-- E-mail 30: tine.moreau0@icloud.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('de961e6a-b6e3-5c83-a313-d25029e356ae', '51eb00ad-860f-586b-8f93-b076bf073683', N'tine.moreau0@icloud.com', NULL);

-- E-mail 31: marie.de.vries0@gmail.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('906de31a-485f-55ac-9358-c3c96ab355a6', 'b1d210cc-ae2e-551a-b0ea-32b380583aa0', N'marie.de.vries0@gmail.com', NULL);

-- E-mail 32: sofie.janssens0@hotmail.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('40c7562b-857c-5a0a-9db0-534767a39386', 'a9c72bff-21c7-514d-afe4-d90b7fd0734c', N'sofie.janssens0@hotmail.com', NULL);

-- E-mail 33: lotte.peeters0@outlook.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('ceae18bd-3d74-5f5e-8c67-adc43c946220', '94d4279a-d4bc-546b-8483-62b3d48fadc9', N'lotte.peeters0@outlook.com', NULL);

-- E-mail 34: emma.maes0@yahoo.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('056c9a22-2164-53bd-ba7e-7d06d1ec01f7', 'e9fa3f32-8a88-58f7-aa16-19c078b73812', N'emma.maes0@yahoo.com', NULL);

-- E-mail 35: ann.jacobs0@telenet.be
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('1f1a798e-4f8d-50f7-9810-0f7d33c356d7', '5aa15f2f-d6e3-5834-9b99-ce48aab774c2', N'ann.jacobs0@telenet.be', NULL);

-- E-mail 36: sarah.willems0@proximus.be
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('2b34c91c-5548-5b44-958f-83e6637518ca', 'e162f9ae-c21f-5642-99c5-9a9ac7fe0ffa', N'sarah.willems0@proximus.be', NULL);

-- E-mail 37: laura.claes0@skynet.be
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('c0170c01-815e-5c02-a9fe-4b9d4c03b896', '7e25fdf9-3052-52e7-8753-d64356fdade7', N'laura.claes0@skynet.be', NULL);

-- E-mail 38: nina.goossens0@live.be
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('7b236f67-12e9-5f83-8d55-fc422934b06f', '3ecbc905-9da6-5b0b-9f39-dc903be90d58', N'nina.goossens0@live.be', NULL);

-- E-mail 39: karen.wouters0@msn.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('3eef2a91-9831-5b9d-ab06-27c08522e073', '12ea6164-808c-5aa4-ab79-956ddd949d5e', N'karen.wouters0@msn.com', NULL);

-- E-mail 40: lisa.de.smet0@icloud.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('ac0e5b7e-f0ad-542e-9104-76b12e061d4b', 'cf9fe55e-fcdd-553e-8bc7-f1e799743ce5', N'lisa.de.smet0@icloud.com', NULL);

-- E-mail 41: elise.vermeulen0@gmail.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('0225fc13-7d26-5050-9d1f-c52e664e330f', '88275840-7a64-5c38-91b3-167e286f560d', N'elise.vermeulen0@gmail.com', NULL);

-- E-mail 42: hanne.van.den.berg0@hotmail.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('63999cef-5431-5427-98d2-a2a32c220a2a', 'abeaecc5-308d-5d45-9eb1-21caed5274ff', N'hanne.van.den.berg0@hotmail.com', NULL);

-- E-mail 43: charlotte.martens0@outlook.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('87ee8c25-1a7e-5f0e-bc9e-5e7594d07713', 'e77a50fb-c6c7-5c28-aaeb-b64672bd3a88', N'charlotte.martens0@outlook.com', NULL);

-- E-mail 44: stephanie.hermans0@yahoo.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('b136c33d-7aef-5a23-a58d-ec2ec4721dc9', 'ecbb77f5-a7db-558a-b13a-42fd2094023e', N'stephanie.hermans0@yahoo.com', NULL);

-- E-mail 45: julie.moons0@telenet.be
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('c36db8ad-b447-5522-adaa-e2d16a1deb9b', 'e32a64f6-c0df-580e-bbd4-18dca5aa25cb', N'julie.moons0@telenet.be', NULL);

-- E-mail 46: an.van.dam0@proximus.be
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('a30010ca-7ca9-5756-b44b-163288a19661', 'e881e046-e826-5fdf-aee9-d7ef20db2171', N'an.van.dam0@proximus.be', NULL);

-- E-mail 47: clara.hendrickx0@skynet.be
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('b75a0210-3645-5d69-bd4d-03909954157a', '1b0efd79-d7eb-5f8a-bad6-66c8d683363c', N'clara.hendrickx0@skynet.be', NULL);

-- E-mail 48: els.desmet0@live.be
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('eae98d1d-2cc9-50fb-a338-b9c188829125', '686d7d6b-464a-5c2e-983b-467383404638', N'els.desmet0@live.be', NULL);

-- E-mail 49: fien.vandenberghe0@msn.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('5441282c-c3cb-56f4-8cfe-a1425cddf470', 'af92e0ba-9be1-5452-ac95-69f85d04ad74', N'fien.vandenberghe0@msn.com', NULL);

-- E-mail 50: hanne.de.backer0@icloud.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('2c798132-cd12-5ff4-88ac-6f3606397d53', '356e6f20-40fd-5f52-8c7c-a7f81d3f1990', N'hanne.de.backer0@icloud.com', NULL);

-- E-mail 51: jan.de.vries1@gmail.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('185de0bb-a650-5adf-b369-c6835d0ab5f3', '219711d4-f1e9-5b7c-84bc-490a41110884', N'jan.de.vries1@gmail.com', NULL);

-- E-mail 52: pieter.janssens1@hotmail.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('193fb6d6-4772-5265-aadb-81ae97d779ca', '7268581b-0dbd-52b1-b752-40aebb63d0a5', N'pieter.janssens1@hotmail.com', NULL);

-- E-mail 53: thomas.peeters1@outlook.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('0a481999-f0c5-52df-94d9-91fe29c8fece', '767455ff-6716-57b8-8b1b-07625f980552', N'thomas.peeters1@outlook.com', NULL);

-- E-mail 54: bart.maes1@yahoo.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('27d0f7ba-a0f1-5b1c-90c7-f9abbd571abc', '6ef2fb59-c4d6-509d-82b7-86ba6954d512', N'bart.maes1@yahoo.com', NULL);

-- E-mail 55: koen.jacobs1@telenet.be
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('b2a8cd67-0578-5773-ae80-f45a9c0009df', 'f2ebd19a-69e8-50cc-bc6f-290e94deb79a', N'koen.jacobs1@telenet.be', NULL);

-- E-mail 56: filip.willems1@proximus.be
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('7c75d53d-129d-585c-b3a8-7f7b7fc2a705', '8dbcaf2e-12f0-51a4-ac0d-1e65bd18488a', N'filip.willems1@proximus.be', NULL);

-- E-mail 57: david.claes1@skynet.be
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('39f53d46-6116-5c58-962b-f8197a7f05f5', 'd421bbf2-d9ea-5c6c-94e1-822811b8482f', N'david.claes1@skynet.be', NULL);

-- E-mail 58: jeroen.goossens1@live.be
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('99195637-c201-5d9b-9822-72cca0d61fdb', 'c54ae5ab-b164-5d26-ab0e-1226a794ba00', N'jeroen.goossens1@live.be', NULL);

-- E-mail 59: stefan.wouters1@msn.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('d99c550c-9721-5e24-8120-29c86211b8e3', '2918c7dc-bf8a-5adf-a342-2f427ea33ad2', N'stefan.wouters1@msn.com', NULL);

-- E-mail 60: wouter.de.smet1@icloud.com
INSERT INTO Email (email_id, person_id, email, comment)
VALUES ('77420c39-4f05-5ef5-84a2-455d96d0d5f2', '06d5be89-2291-5bb5-9a22-906efcffbfca', N'wouter.de.smet1@icloud.com', NULL);

PRINT '60 e-mailadressen ingevoegd.';
GO

-- =============================================================
-- G. 20 Instellingen
-- 8 Verzekeringsmaatschappijen, 5 Banken, 4 Tussenpersonen, 3 Garages
-- =============================================================

-- Instelling 1: AG Insurance SA
-- Type: Verzekeringsmaatschappij
-- KBO: BE 0403.149.444
INSERT INTO Institution (institution_id, institution_code, name, created_at, updated_at)
VALUES ('32eaa733-aa65-5a24-a3c7-f26a5e4ac984', N'AG_INS', N'AG Insurance SA', SYSUTCDATETIME(), SYSUTCDATETIME());

-- Instelling 2: Allianz Benelux
-- Type: Verzekeringsmaatschappij
-- KBO: BE 0400.039.585
INSERT INTO Institution (institution_id, institution_code, name, created_at, updated_at)
VALUES ('fd24c8bc-50ee-564a-ad64-226f6682f40e', N'ALLIANZ', N'Allianz Benelux', SYSUTCDATETIME(), SYSUTCDATETIME());

-- Instelling 3: AXA Belgium
-- Type: Verzekeringsmaatschappij
-- KBO: BE 0404.547.238
INSERT INTO Institution (institution_id, institution_code, name, created_at, updated_at)
VALUES ('35cbc940-709f-5dcd-87d1-dbea18ae6df5', N'AXA_BE', N'AXA Belgium', SYSUTCDATETIME(), SYSUTCDATETIME());

-- Instelling 4: Baloise Insurance
-- Type: Verzekeringsmaatschappij
-- KBO: BE 0404.110.188
INSERT INTO Institution (institution_id, institution_code, name, created_at, updated_at)
VALUES ('239bb32c-b140-5d5b-9768-29f706468de6', N'BALOISE', N'Baloise Insurance', SYSUTCDATETIME(), SYSUTCDATETIME());

-- Instelling 5: Ethias SA
-- Type: Verzekeringsmaatschappij
-- KBO: BE 0404.506.178
INSERT INTO Institution (institution_id, institution_code, name, created_at, updated_at)
VALUES ('742f978f-ae20-5b80-b224-719d7f076027', N'ETHIAS', N'Ethias SA', SYSUTCDATETIME(), SYSUTCDATETIME());

-- Instelling 6: Federale Assurance
-- Type: Verzekeringsmaatschappij
-- KBO: BE 0401.147.807
INSERT INTO Institution (institution_id, institution_code, name, created_at, updated_at)
VALUES ('797f738f-8c2c-53fa-bd88-19ab6154c655', N'FEDERALE', N'Federale Assurance', SYSUTCDATETIME(), SYSUTCDATETIME());

-- Instelling 7: NN Insurance Belgium
-- Type: Verzekeringsmaatschappij
-- KBO: BE 0400.055.939
INSERT INTO Institution (institution_id, institution_code, name, created_at, updated_at)
VALUES ('d1253b8e-1b5f-5a1c-8e3d-16effd1beb47', N'NN_INS', N'NN Insurance Belgium', SYSUTCDATETIME(), SYSUTCDATETIME());

-- Instelling 8: P&V Assurances
-- Type: Verzekeringsmaatschappij
-- KBO: BE 0418.888.131
INSERT INTO Institution (institution_id, institution_code, name, created_at, updated_at)
VALUES ('41ff067a-5982-5dde-beb9-ca35ccbe3109', N'PV_ASS', N'P&V Assurances', SYSUTCDATETIME(), SYSUTCDATETIME());

-- Instelling 9: KBC Bank NV
-- Type: Bank
-- KBO: BE 0403.227.515
INSERT INTO Institution (institution_id, institution_code, name, created_at, updated_at)
VALUES ('fc094039-65f6-5ca5-84b0-33ef03ab14db', N'KBC', N'KBC Bank NV', SYSUTCDATETIME(), SYSUTCDATETIME());

-- Instelling 10: BNP Paribas Fortis
-- Type: Bank
-- KBO: BE 0403.199.702
INSERT INTO Institution (institution_id, institution_code, name, created_at, updated_at)
VALUES ('4147cf5f-4691-50f2-9f10-6ccf2dac0928', N'BNP', N'BNP Paribas Fortis', SYSUTCDATETIME(), SYSUTCDATETIME());

-- Instelling 11: ING Belgium
-- Type: Bank
-- KBO: BE 0403.320.223
INSERT INTO Institution (institution_id, institution_code, name, created_at, updated_at)
VALUES ('217fe698-147d-5e61-8260-dd6641a036e7', N'ING', N'ING Belgium', SYSUTCDATETIME(), SYSUTCDATETIME());

-- Instelling 12: Belfius Bank
-- Type: Bank
-- KBO: BE 0403.211.876
INSERT INTO Institution (institution_id, institution_code, name, created_at, updated_at)
VALUES ('8e461a7e-2059-5b75-8e57-3cd2244bfce9', N'BELFIUS', N'Belfius Bank', SYSUTCDATETIME(), SYSUTCDATETIME());

-- Instelling 13: Argenta Spaarbank
-- Type: Bank
-- KBO: BE 0403.228.767
INSERT INTO Institution (institution_id, institution_code, name, created_at, updated_at)
VALUES ('3400fe07-018d-59e2-bbaf-92dde2aea67e', N'ARGENTA', N'Argenta Spaarbank', SYSUTCDATETIME(), SYSUTCDATETIME());

-- Instelling 14: Van Dessel Verzekeringen
-- Type: Dienstverlener
-- KBO: BE 0475.123.456
INSERT INTO Institution (institution_id, institution_code, name, created_at, updated_at)
VALUES ('95004e35-d095-591e-92b5-eddca13a68cb', N'VDESSEL', N'Van Dessel Verzekeringen', SYSUTCDATETIME(), SYSUTCDATETIME());

-- Instelling 15: De Bruin Makelaars
-- Type: Dienstverlener
-- KBO: BE 0476.234.567
INSERT INTO Institution (institution_id, institution_code, name, created_at, updated_at)
VALUES ('85ec606f-d619-5391-beed-8a9112d1147b', N'DBRUIN', N'De Bruin Makelaars', SYSUTCDATETIME(), SYSUTCDATETIME());

-- Instelling 16: Peeters & Partners
-- Type: Dienstverlener
-- KBO: BE 0477.345.678
INSERT INTO Institution (institution_id, institution_code, name, created_at, updated_at)
VALUES ('8f91a8dc-2d6e-5605-a8b2-475edb225110', N'PPARTN', N'Peeters & Partners', SYSUTCDATETIME(), SYSUTCDATETIME());

-- Instelling 17: Assurantie Kantoor Mechelen
-- Type: Dienstverlener
-- KBO: BE 0478.456.789
INSERT INTO Institution (institution_id, institution_code, name, created_at, updated_at)
VALUES ('dcc6cb9c-16f8-5313-b948-0d6aed21087b', N'AKMECH', N'Assurantie Kantoor Mechelen', SYSUTCDATETIME(), SYSUTCDATETIME());

-- Instelling 18: Carrosserie Mechelen
-- Type: Dienstverlener
-- KBO: BE 0489.567.890
INSERT INTO Institution (institution_id, institution_code, name, created_at, updated_at)
VALUES ('7967d45c-3b43-55a0-ba70-28cfa1bc93fa', N'CARMEC', N'Carrosserie Mechelen', SYSUTCDATETIME(), SYSUTCDATETIME());

-- Instelling 19: Autohuur Brussel
-- Type: Dienstverlener
-- KBO: BE 0490.678.901
INSERT INTO Institution (institution_id, institution_code, name, created_at, updated_at)
VALUES ('2f7527d1-2eb1-5c75-bab9-6962918d714e', N'AUTOBXL', N'Autohuur Brussel', SYSUTCDATETIME(), SYSUTCDATETIME());

-- Instelling 20: Garage De Smet
-- Type: Dienstverlener
-- KBO: BE 0491.789.012
INSERT INTO Institution (institution_id, institution_code, name, created_at, updated_at)
VALUES ('f5e665ae-b6d7-5479-b1fd-e4af0c0d98a1', N'GARDSM', N'Garage De Smet', SYSUTCDATETIME(), SYSUTCDATETIME());

-- KBO-nummers voor instellingen
INSERT INTO InstitutionIdentifier (institution_id, id_type_code, id_value, valid_from)
VALUES ('32eaa733-aa65-5a24-a3c7-f26a5e4ac984', 'KBO', N'0403149444', '2000-01-01');

INSERT INTO InstitutionIdentifier (institution_id, id_type_code, id_value, valid_from)
VALUES ('fd24c8bc-50ee-564a-ad64-226f6682f40e', 'KBO', N'0400039585', '2000-01-01');

INSERT INTO InstitutionIdentifier (institution_id, id_type_code, id_value, valid_from)
VALUES ('35cbc940-709f-5dcd-87d1-dbea18ae6df5', 'KBO', N'0404547238', '2000-01-01');

INSERT INTO InstitutionIdentifier (institution_id, id_type_code, id_value, valid_from)
VALUES ('239bb32c-b140-5d5b-9768-29f706468de6', 'KBO', N'0404110188', '2000-01-01');

INSERT INTO InstitutionIdentifier (institution_id, id_type_code, id_value, valid_from)
VALUES ('742f978f-ae20-5b80-b224-719d7f076027', 'KBO', N'0404506178', '2000-01-01');

INSERT INTO InstitutionIdentifier (institution_id, id_type_code, id_value, valid_from)
VALUES ('797f738f-8c2c-53fa-bd88-19ab6154c655', 'KBO', N'0401147807', '2000-01-01');

INSERT INTO InstitutionIdentifier (institution_id, id_type_code, id_value, valid_from)
VALUES ('d1253b8e-1b5f-5a1c-8e3d-16effd1beb47', 'KBO', N'0400055939', '2000-01-01');

INSERT INTO InstitutionIdentifier (institution_id, id_type_code, id_value, valid_from)
VALUES ('41ff067a-5982-5dde-beb9-ca35ccbe3109', 'KBO', N'0418888131', '2000-01-01');

INSERT INTO InstitutionIdentifier (institution_id, id_type_code, id_value, valid_from)
VALUES ('fc094039-65f6-5ca5-84b0-33ef03ab14db', 'KBO', N'0403227515', '2000-01-01');

INSERT INTO InstitutionIdentifier (institution_id, id_type_code, id_value, valid_from)
VALUES ('4147cf5f-4691-50f2-9f10-6ccf2dac0928', 'KBO', N'0403199702', '2000-01-01');

INSERT INTO InstitutionIdentifier (institution_id, id_type_code, id_value, valid_from)
VALUES ('217fe698-147d-5e61-8260-dd6641a036e7', 'KBO', N'0403320223', '2000-01-01');

INSERT INTO InstitutionIdentifier (institution_id, id_type_code, id_value, valid_from)
VALUES ('8e461a7e-2059-5b75-8e57-3cd2244bfce9', 'KBO', N'0403211876', '2000-01-01');

INSERT INTO InstitutionIdentifier (institution_id, id_type_code, id_value, valid_from)
VALUES ('3400fe07-018d-59e2-bbaf-92dde2aea67e', 'KBO', N'0403228767', '2000-01-01');

INSERT INTO InstitutionIdentifier (institution_id, id_type_code, id_value, valid_from)
VALUES ('95004e35-d095-591e-92b5-eddca13a68cb', 'KBO', N'0475123456', '2000-01-01');

INSERT INTO InstitutionIdentifier (institution_id, id_type_code, id_value, valid_from)
VALUES ('85ec606f-d619-5391-beed-8a9112d1147b', 'KBO', N'0476234567', '2000-01-01');

INSERT INTO InstitutionIdentifier (institution_id, id_type_code, id_value, valid_from)
VALUES ('8f91a8dc-2d6e-5605-a8b2-475edb225110', 'KBO', N'0477345678', '2000-01-01');

INSERT INTO InstitutionIdentifier (institution_id, id_type_code, id_value, valid_from)
VALUES ('dcc6cb9c-16f8-5313-b948-0d6aed21087b', 'KBO', N'0478456789', '2000-01-01');

INSERT INTO InstitutionIdentifier (institution_id, id_type_code, id_value, valid_from)
VALUES ('7967d45c-3b43-55a0-ba70-28cfa1bc93fa', 'KBO', N'0489567890', '2000-01-01');

INSERT INTO InstitutionIdentifier (institution_id, id_type_code, id_value, valid_from)
VALUES ('2f7527d1-2eb1-5c75-bab9-6962918d714e', 'KBO', N'0490678901', '2000-01-01');

INSERT INTO InstitutionIdentifier (institution_id, id_type_code, id_value, valid_from)
VALUES ('f5e665ae-b6d7-5479-b1fd-e4af0c0d98a1', 'KBO', N'0491789012', '2000-01-01');

-- Adressen voor instellingen
INSERT INTO InstitutionAddress (institution_address_id, institution_id, address_role_code, street, house_number, postal_code, city, country, country_code, is_primary, created_at)
VALUES (NEWID(), '32eaa733-aa65-5a24-a3c7-f26a5e4ac984', 'HQ', N'Nationalestraat', N'1', N'2800', N'Mechelen', 'Belgie', 'BE', 1, SYSUTCDATETIME());

INSERT INTO InstitutionAddress (institution_address_id, institution_id, address_role_code, street, house_number, postal_code, city, country, country_code, is_primary, created_at)
VALUES (NEWID(), 'fd24c8bc-50ee-564a-ad64-226f6682f40e', 'HQ', N'Hoogstraat', N'2', N'1000', N'Brussel', 'Belgie', 'BE', 1, SYSUTCDATETIME());

INSERT INTO InstitutionAddress (institution_address_id, institution_id, address_role_code, street, house_number, postal_code, city, country, country_code, is_primary, created_at)
VALUES (NEWID(), '35cbc940-709f-5dcd-87d1-dbea18ae6df5', 'HQ', N'Kerkstraat', N'3', N'9000', N'Gent', 'Belgie', 'BE', 1, SYSUTCDATETIME());

INSERT INTO InstitutionAddress (institution_address_id, institution_id, address_role_code, street, house_number, postal_code, city, country, country_code, is_primary, created_at)
VALUES (NEWID(), '239bb32c-b140-5d5b-9768-29f706468de6', 'HQ', N'Dorpstraat', N'4', N'2000', N'Antwerpen', 'Belgie', 'BE', 1, SYSUTCDATETIME());

INSERT INTO InstitutionAddress (institution_address_id, institution_id, address_role_code, street, house_number, postal_code, city, country, country_code, is_primary, created_at)
VALUES (NEWID(), '742f978f-ae20-5b80-b224-719d7f076027', 'HQ', N'Stationsstraat', N'5', N'3000', N'Leuven', 'Belgie', 'BE', 1, SYSUTCDATETIME());

INSERT INTO InstitutionAddress (institution_address_id, institution_id, address_role_code, street, house_number, postal_code, city, country, country_code, is_primary, created_at)
VALUES (NEWID(), '797f738f-8c2c-53fa-bd88-19ab6154c655', 'HQ', N'Markt', N'6', N'3500', N'Hasselt', 'Belgie', 'BE', 1, SYSUTCDATETIME());

INSERT INTO InstitutionAddress (institution_address_id, institution_id, address_role_code, street, house_number, postal_code, city, country, country_code, is_primary, created_at)
VALUES (NEWID(), 'd1253b8e-1b5f-5a1c-8e3d-16effd1beb47', 'HQ', N'Grote Markt', N'7', N'8000', N'Brugge', 'Belgie', 'BE', 1, SYSUTCDATETIME());

INSERT INTO InstitutionAddress (institution_address_id, institution_id, address_role_code, street, house_number, postal_code, city, country, country_code, is_primary, created_at)
VALUES (NEWID(), '41ff067a-5982-5dde-beb9-ca35ccbe3109', 'HQ', N'Koning Albertstraat', N'8', N'5000', N'Namen', 'Belgie', 'BE', 1, SYSUTCDATETIME());

INSERT INTO InstitutionAddress (institution_address_id, institution_id, address_role_code, street, house_number, postal_code, city, country, country_code, is_primary, created_at)
VALUES (NEWID(), 'fc094039-65f6-5ca5-84b0-33ef03ab14db', 'HQ', N'Bondgenotenlaan', N'9', N'4000', N'Luik', 'Belgie', 'BE', 1, SYSUTCDATETIME());

INSERT INTO InstitutionAddress (institution_address_id, institution_id, address_role_code, street, house_number, postal_code, city, country, country_code, is_primary, created_at)
VALUES (NEWID(), '4147cf5f-4691-50f2-9f10-6ccf2dac0928', 'HQ', N'Brusselsesteenweg', N'10', N'8500', N'Kortrijk', 'Belgie', 'BE', 1, SYSUTCDATETIME());

INSERT INTO InstitutionAddress (institution_address_id, institution_id, address_role_code, street, house_number, postal_code, city, country, country_code, is_primary, created_at)
VALUES (NEWID(), '217fe698-147d-5e61-8260-dd6641a036e7', 'HQ', N'Gentsesteenweg', N'11', N'8400', N'Oostende', 'Belgie', 'BE', 1, SYSUTCDATETIME());

INSERT INTO InstitutionAddress (institution_address_id, institution_id, address_role_code, street, house_number, postal_code, city, country, country_code, is_primary, created_at)
VALUES (NEWID(), '8e461a7e-2059-5b75-8e57-3cd2244bfce9', 'HQ', N'Antwerpsesteenweg', N'12', N'9100', N'Sint-Niklaas', 'Belgie', 'BE', 1, SYSUTCDATETIME());

INSERT INTO InstitutionAddress (institution_address_id, institution_id, address_role_code, street, house_number, postal_code, city, country, country_code, is_primary, created_at)
VALUES (NEWID(), '3400fe07-018d-59e2-bbaf-92dde2aea67e', 'HQ', N'Leuvensesteenweg', N'13', N'3600', N'Genk', 'Belgie', 'BE', 1, SYSUTCDATETIME());

INSERT INTO InstitutionAddress (institution_address_id, institution_id, address_role_code, street, house_number, postal_code, city, country, country_code, is_primary, created_at)
VALUES (NEWID(), '95004e35-d095-591e-92b5-eddca13a68cb', 'HQ', N'Mechelsesteenweg', N'14', N'2300', N'Turnhout', 'Belgie', 'BE', 1, SYSUTCDATETIME());

INSERT INTO InstitutionAddress (institution_address_id, institution_id, address_role_code, street, house_number, postal_code, city, country, country_code, is_primary, created_at)
VALUES (NEWID(), '85ec606f-d619-5391-beed-8a9112d1147b', 'HQ', N'Luiksesteenweg', N'15', N'2500', N'Lier', 'Belgie', 'BE', 1, SYSUTCDATETIME());

INSERT INTO InstitutionAddress (institution_address_id, institution_id, address_role_code, street, house_number, postal_code, city, country, country_code, is_primary, created_at)
VALUES (NEWID(), '8f91a8dc-2d6e-5605-a8b2-475edb225110', 'HQ', N'Nieuwstraat', N'16', N'9300', N'Aalst', 'Belgie', 'BE', 1, SYSUTCDATETIME());

INSERT INTO InstitutionAddress (institution_address_id, institution_id, address_role_code, street, house_number, postal_code, city, country, country_code, is_primary, created_at)
VALUES (NEWID(), 'dcc6cb9c-16f8-5313-b948-0d6aed21087b', 'HQ', N'Zuidstraat', N'17', N'1800', N'Vilvoorde', 'Belgie', 'BE', 1, SYSUTCDATETIME());

INSERT INTO InstitutionAddress (institution_address_id, institution_id, address_role_code, street, house_number, postal_code, city, country, country_code, is_primary, created_at)
VALUES (NEWID(), '7967d45c-3b43-55a0-ba70-28cfa1bc93fa', 'HQ', N'Noordstraat', N'18', N'2200', N'Herentals', 'Belgie', 'BE', 1, SYSUTCDATETIME());

INSERT INTO InstitutionAddress (institution_address_id, institution_id, address_role_code, street, house_number, postal_code, city, country, country_code, is_primary, created_at)
VALUES (NEWID(), '2f7527d1-2eb1-5c75-bab9-6962918d714e', 'HQ', N'Oude Baan', N'19', N'2400', N'Mol', 'Belgie', 'BE', 1, SYSUTCDATETIME());

INSERT INTO InstitutionAddress (institution_address_id, institution_id, address_role_code, street, house_number, postal_code, city, country, country_code, is_primary, created_at)
VALUES (NEWID(), 'f5e665ae-b6d7-5479-b1fd-e4af0c0d98a1', 'HQ', N'Nieuwe Baan', N'20', N'3200', N'Aarschot', 'Belgie', 'BE', 1, SYSUTCDATETIME());

PRINT '20 instellingen ingevoegd.';
GO

-- =============================================================
-- H. 100 Objecten
-- 40 Voertuigen, 20 Onroerend goed, 15 Leningen, 15 Zaken, 10 Activiteiten
-- =============================================================

-- H.1 Voertuigen (40 stuks)

-- Voertuig 1: BMW 3-Serie (2015) - 1-ADH-100
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('558570a8-3cea-5fc8-abba-8d4defa4d822', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'BMW 3-Serie', N'ACTIEF', '2015-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('558570a8-3cea-5fc8-abba-8d4defa4d822', N'PERSONENWAGEN', N'PRIV_PLEZIER', N'EUROPEES', N'BMW', N'3-Serie', N'WVWZZZ1JZ300000', 2015, '2015-03-01', '2015-03-01', N'1-ADH-100', N'BENZINE', N'VLO', 0, NULL, 1200, 60);

-- Voertuig 2: Audi A4 (2016) - 2-BEI-101
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('6b294aa4-eba1-5957-b452-c46cfcd080fd', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Audi A4', N'ACTIEF', '2016-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('6b294aa4-eba1-5957-b452-c46cfcd080fd', N'BESTELWAGEN', N'WOON_WERK', N'BELGIE', N'Audi', N'A4', N'WVWZZZ1JZ300001', 2016, '2016-03-01', '2016-03-01', N'2-BEI-101', N'DIESEL', N'ACH', 1, '4147cf5f-4691-50f2-9f10-6ccf2dac0928', 1300, 65);

-- Voertuig 3: Mercedes C-Klasse (2017) - 3-CFJ-102
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('91d71aba-820f-57c3-b8b9-eaab0fd65fbf', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Mercedes C-Klasse', N'ACTIEF', '2017-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('91d71aba-820f-57c3-b8b9-eaab0fd65fbf', N'4X4', N'BEROEP', N'EUROPEES', N'Mercedes', N'C-Klasse', N'WVWZZZ1JZ300002', 2017, '2017-03-01', '2017-03-01', N'3-CFJ-102', N'ELEKTRISCH', N'4X4', 2, NULL, 1400, 70);

-- Voertuig 4: Volkswagen Golf (2018) - 4-DGK-103
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('4e4bc4f2-ee4f-568a-958b-2ae5e9ba2536', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Volkswagen Golf', N'ACTIEF', '2018-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('4e4bc4f2-ee4f-568a-958b-2ae5e9ba2536', N'MOTORFIETS', N'ALGEMENE_DOELEINDEN', N'BELGIE', N'Volkswagen', N'Golf', N'WVWZZZ1JZ300003', 2018, '2018-03-01', '2018-03-01', N'4-DGK-103', N'HYBRIDE', N'VLO', 0, NULL, 1500, 75);

-- Voertuig 5: Peugeot 308 (2019) - 5-EHL-104
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('806ad90f-fbde-53ff-8b75-7de469399de6', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Peugeot 308', N'ACTIEF', '2019-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('806ad90f-fbde-53ff-8b75-7de469399de6', N'PERSONENWAGEN', N'PRIV_PLEZIER', N'EUROPEES', N'Peugeot', N'308', N'WVWZZZ1JZ300004', 2019, '2019-03-01', '2019-03-01', N'5-EHL-104', N'BENZINE', N'ACH', 1, '3400fe07-018d-59e2-bbaf-92dde2aea67e', 1600, 80);

-- Voertuig 6: Renault Clio (2020) - 6-FIM-105
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('f97da18f-a51b-5ead-9b4d-291be9fc82a6', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Renault Clio', N'ACTIEF', '2020-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('f97da18f-a51b-5ead-9b4d-291be9fc82a6', N'BESTELWAGEN', N'WOON_WERK', N'BELGIE', N'Renault', N'Clio', N'WVWZZZ1JZ300005', 2020, '2020-03-01', '2020-03-01', N'6-FIM-105', N'DIESEL', N'4X4', 2, NULL, 1700, 85);

-- Voertuig 7: Ford Focus (2021) - 7-GJN-106
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('299f4bb7-59a7-5e38-b095-c8c908a6931c', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Ford Focus', N'ACTIEF', '2021-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('299f4bb7-59a7-5e38-b095-c8c908a6931c', N'4X4', N'BEROEP', N'EUROPEES', N'Ford', N'Focus', N'WVWZZZ1JZ300006', 2021, '2021-03-01', '2021-03-01', N'7-GJN-106', N'ELEKTRISCH', N'VLO', 0, NULL, 1800, 90);

-- Voertuig 8: Opel Astra (2022) - 8-HKO-107
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('fbb5d528-e3ae-5579-8a29-b0c8de0ea628', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Opel Astra', N'ACTIEF', '2022-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('fbb5d528-e3ae-5579-8a29-b0c8de0ea628', N'MOTORFIETS', N'ALGEMENE_DOELEINDEN', N'BELGIE', N'Opel', N'Astra', N'WVWZZZ1JZ300007', 2022, '2022-03-01', '2022-03-01', N'8-HKO-107', N'HYBRIDE', N'ACH', 1, '217fe698-147d-5e61-8260-dd6641a036e7', 1900, 95);

-- Voertuig 9: Volvo V60 (2023) - 9-ILP-108
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('10218115-9b35-552d-8b7d-19f8a2649c5d', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Volvo V60', N'ACTIEF', '2023-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('10218115-9b35-552d-8b7d-19f8a2649c5d', N'PERSONENWAGEN', N'PRIV_PLEZIER', N'EUROPEES', N'Volvo', N'V60', N'WVWZZZ1JZ300008', 2023, '2023-03-01', '2023-03-01', N'9-ILP-108', N'BENZINE', N'4X4', 2, NULL, 2000, 100);

-- Voertuig 10: Toyota Corolla (2015) - 1-JMQ-109
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('16a7a99b-0ec4-51e5-888a-f2a9232b4785', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Toyota Corolla', N'ACTIEF', '2015-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('16a7a99b-0ec4-51e5-888a-f2a9232b4785', N'BESTELWAGEN', N'WOON_WERK', N'BELGIE', N'Toyota', N'Corolla', N'WVWZZZ1JZ300009', 2015, '2015-03-01', '2015-03-01', N'1-JMQ-109', N'DIESEL', N'VLO', 0, NULL, 2100, 105);

-- Voertuig 11: Nissan Qashqai (2016) - 2-KNR-110
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('8fd3e52e-3b42-5baf-8d15-4a2b4b6d783a', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Nissan Qashqai', N'ACTIEF', '2016-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('8fd3e52e-3b42-5baf-8d15-4a2b4b6d783a', N'4X4', N'BEROEP', N'EUROPEES', N'Nissan', N'Qashqai', N'WVWZZZ1JZ300010', 2016, '2016-03-01', '2016-03-01', N'2-KNR-110', N'ELEKTRISCH', N'ACH', 1, 'fc094039-65f6-5ca5-84b0-33ef03ab14db', 2200, 110);

-- Voertuig 12: Hyundai i30 (2017) - 3-LOS-111
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('0e3da740-b6c5-5fee-87bd-db8ef5987af7', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Hyundai i30', N'ACTIEF', '2017-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('0e3da740-b6c5-5fee-87bd-db8ef5987af7', N'MOTORFIETS', N'ALGEMENE_DOELEINDEN', N'BELGIE', N'Hyundai', N'i30', N'WVWZZZ1JZ300011', 2017, '2017-03-01', '2017-03-01', N'3-LOS-111', N'HYBRIDE', N'4X4', 2, NULL, 2300, 115);

-- Voertuig 13: Kia Sportage (2018) - 4-MPT-112
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('0596830f-5f5c-5724-9387-4f6eb0b1b081', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Kia Sportage', N'ACTIEF', '2018-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('0596830f-5f5c-5724-9387-4f6eb0b1b081', N'PERSONENWAGEN', N'PRIV_PLEZIER', N'EUROPEES', N'Kia', N'Sportage', N'WVWZZZ1JZ300012', 2018, '2018-03-01', '2018-03-01', N'4-MPT-112', N'BENZINE', N'VLO', 0, NULL, 2400, 120);

-- Voertuig 14: Citroen C4 (2019) - 5-NQU-113
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('ec766974-349a-5cd1-b49f-1604f8ba1485', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Citroen C4', N'ACTIEF', '2019-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('ec766974-349a-5cd1-b49f-1604f8ba1485', N'BESTELWAGEN', N'WOON_WERK', N'BELGIE', N'Citroen', N'C4', N'WVWZZZ1JZ300013', 2019, '2019-03-01', '2019-03-01', N'5-NQU-113', N'DIESEL', N'ACH', 1, '8e461a7e-2059-5b75-8e57-3cd2244bfce9', 2500, 125);

-- Voertuig 15: Skoda Octavia (2020) - 6-ORV-114
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('8bd19ed5-024a-5885-9283-d4ca74b626d6', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Skoda Octavia', N'ACTIEF', '2020-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('8bd19ed5-024a-5885-9283-d4ca74b626d6', N'4X4', N'BEROEP', N'EUROPEES', N'Skoda', N'Octavia', N'WVWZZZ1JZ300014', 2020, '2020-03-01', '2020-03-01', N'6-ORV-114', N'ELEKTRISCH', N'4X4', 2, NULL, 2600, 130);

-- Voertuig 16: Seat Ibiza (2021) - 7-PSW-115
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('35ed7061-976a-5d58-964a-901a499da662', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Seat Ibiza', N'ACTIEF', '2021-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('35ed7061-976a-5d58-964a-901a499da662', N'MOTORFIETS', N'ALGEMENE_DOELEINDEN', N'BELGIE', N'Seat', N'Ibiza', N'WVWZZZ1JZ300015', 2021, '2021-03-01', '2021-03-01', N'7-PSW-115', N'HYBRIDE', N'VLO', 0, NULL, 2700, 135);

-- Voertuig 17: Mazda CX-5 (2022) - 8-QTX-116
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('3dadec00-6232-5954-9d74-9f70af79749f', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Mazda CX-5', N'ACTIEF', '2022-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('3dadec00-6232-5954-9d74-9f70af79749f', N'PERSONENWAGEN', N'PRIV_PLEZIER', N'EUROPEES', N'Mazda', N'CX-5', N'WVWZZZ1JZ300016', 2022, '2022-03-01', '2022-03-01', N'8-QTX-116', N'BENZINE', N'ACH', 1, '4147cf5f-4691-50f2-9f10-6ccf2dac0928', 2800, 140);

-- Voertuig 18: Honda Civic (2023) - 9-RUY-117
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('529f6c6d-4171-55ee-b58a-01a2d8c72280', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Honda Civic', N'ACTIEF', '2023-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('529f6c6d-4171-55ee-b58a-01a2d8c72280', N'BESTELWAGEN', N'WOON_WERK', N'BELGIE', N'Honda', N'Civic', N'WVWZZZ1JZ300017', 2023, '2023-03-01', '2023-03-01', N'9-RUY-117', N'DIESEL', N'4X4', 2, NULL, 2900, 145);

-- Voertuig 19: Fiat 500 (2015) - 1-SVZ-118
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('9bf6710d-b2cf-5bac-89bb-322ec4461f1b', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Fiat 500', N'ACTIEF', '2015-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('9bf6710d-b2cf-5bac-89bb-322ec4461f1b', N'4X4', N'BEROEP', N'EUROPEES', N'Fiat', N'500', N'WVWZZZ1JZ300018', 2015, '2015-03-01', '2015-03-01', N'1-SVZ-118', N'ELEKTRISCH', N'VLO', 0, NULL, 3000, 150);

-- Voertuig 20: Jeep Compass (2016) - 2-TWA-119
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('68142668-8d38-5598-a76e-37e7916cf365', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Jeep Compass', N'ACTIEF', '2016-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('68142668-8d38-5598-a76e-37e7916cf365', N'MOTORFIETS', N'ALGEMENE_DOELEINDEN', N'BELGIE', N'Jeep', N'Compass', N'WVWZZZ1JZ300019', 2016, '2016-03-01', '2016-03-01', N'2-TWA-119', N'HYBRIDE', N'ACH', 1, '3400fe07-018d-59e2-bbaf-92dde2aea67e', 3100, 155);

-- Voertuig 21: MINI Cooper (2017) - 3-UXB-120
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('6a1ebfb0-0dcb-5de2-b9eb-7cd453ef1a23', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'MINI Cooper', N'ACTIEF', '2017-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('6a1ebfb0-0dcb-5de2-b9eb-7cd453ef1a23', N'PERSONENWAGEN', N'PRIV_PLEZIER', N'EUROPEES', N'MINI', N'Cooper', N'WVWZZZ1JZ300020', 2017, '2017-03-01', '2017-03-01', N'3-UXB-120', N'BENZINE', N'4X4', 2, NULL, 1200, 60);

-- Voertuig 22: Lexus RX (2018) - 4-VYC-121
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('72f38622-655c-5a5a-ad7f-c197c83c89f4', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Lexus RX', N'ACTIEF', '2018-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('72f38622-655c-5a5a-ad7f-c197c83c89f4', N'BESTELWAGEN', N'WOON_WERK', N'BELGIE', N'Lexus', N'RX', N'WVWZZZ1JZ300021', 2018, '2018-03-01', '2018-03-01', N'4-VYC-121', N'DIESEL', N'VLO', 0, NULL, 1300, 65);

-- Voertuig 23: Suzuki Swift (2019) - 5-WZD-122
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('848eb7b7-f1ce-508e-81e0-e19468fc4f48', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Suzuki Swift', N'ACTIEF', '2019-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('848eb7b7-f1ce-508e-81e0-e19468fc4f48', N'4X4', N'BEROEP', N'EUROPEES', N'Suzuki', N'Swift', N'WVWZZZ1JZ300022', 2019, '2019-03-01', '2019-03-01', N'5-WZD-122', N'ELEKTRISCH', N'ACH', 1, '217fe698-147d-5e61-8260-dd6641a036e7', 1400, 70);

-- Voertuig 24: Mitsubishi Outlander (2020) - 6-XAE-123
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('af601801-ab14-5cf3-97ea-51560afdb543', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Mitsubishi Outlander', N'ACTIEF', '2020-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('af601801-ab14-5cf3-97ea-51560afdb543', N'MOTORFIETS', N'ALGEMENE_DOELEINDEN', N'BELGIE', N'Mitsubishi', N'Outlander', N'WVWZZZ1JZ300023', 2020, '2020-03-01', '2020-03-01', N'6-XAE-123', N'HYBRIDE', N'4X4', 2, NULL, 1500, 75);

-- Voertuig 25: Dacia Sandero (2021) - 7-YBF-124
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('223e7a3f-bc1a-5bcf-9ca1-b391dad07921', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Dacia Sandero', N'ACTIEF', '2021-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('223e7a3f-bc1a-5bcf-9ca1-b391dad07921', N'PERSONENWAGEN', N'PRIV_PLEZIER', N'EUROPEES', N'Dacia', N'Sandero', N'WVWZZZ1JZ300024', 2021, '2021-03-01', '2021-03-01', N'7-YBF-124', N'BENZINE', N'VLO', 0, NULL, 1600, 80);

-- Voertuig 26: Tesla Model 3 (2022) - 8-ZCG-125
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('6df53817-4228-5afe-ab55-3d262c87efc6', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Tesla Model 3', N'ACTIEF', '2022-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('6df53817-4228-5afe-ab55-3d262c87efc6', N'BESTELWAGEN', N'WOON_WERK', N'BELGIE', N'Tesla', N'Model 3', N'WVWZZZ1JZ300025', 2022, '2022-03-01', '2022-03-01', N'8-ZCG-125', N'DIESEL', N'ACH', 1, 'fc094039-65f6-5ca5-84b0-33ef03ab14db', 1700, 85);

-- Voertuig 27: Porsche Cayenne (2023) - 9-ADH-126
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('4da34bf8-1ca4-5fa2-aa0c-d5283825af48', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Porsche Cayenne', N'ACTIEF', '2023-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('4da34bf8-1ca4-5fa2-aa0c-d5283825af48', N'4X4', N'BEROEP', N'EUROPEES', N'Porsche', N'Cayenne', N'WVWZZZ1JZ300026', 2023, '2023-03-01', '2023-03-01', N'9-ADH-126', N'ELEKTRISCH', N'4X4', 2, NULL, 1800, 90);

-- Voertuig 28: Jaguar XF (2015) - 1-BEI-127
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('ebd80d21-326c-56d8-b9fd-04336f5e6f15', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Jaguar XF', N'ACTIEF', '2015-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('ebd80d21-326c-56d8-b9fd-04336f5e6f15', N'MOTORFIETS', N'ALGEMENE_DOELEINDEN', N'BELGIE', N'Jaguar', N'XF', N'WVWZZZ1JZ300027', 2015, '2015-03-01', '2015-03-01', N'1-BEI-127', N'HYBRIDE', N'VLO', 0, NULL, 1900, 95);

-- Voertuig 29: Land Rover Evoque (2016) - 2-CFJ-128
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('81fbc9d6-3e2c-5c66-b47d-6c72ce92042e', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Land Rover Evoque', N'ACTIEF', '2016-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('81fbc9d6-3e2c-5c66-b47d-6c72ce92042e', N'PERSONENWAGEN', N'PRIV_PLEZIER', N'EUROPEES', N'Land Rover', N'Evoque', N'WVWZZZ1JZ300028', 2016, '2016-03-01', '2016-03-01', N'2-CFJ-128', N'BENZINE', N'ACH', 1, '8e461a7e-2059-5b75-8e57-3cd2244bfce9', 2000, 100);

-- Voertuig 30: Alfa Romeo Giulia (2017) - 3-DGK-129
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('e7abaa11-8d92-5716-be9c-fdf3bb49bcf9', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Alfa Romeo Giulia', N'ACTIEF', '2017-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('e7abaa11-8d92-5716-be9c-fdf3bb49bcf9', N'BESTELWAGEN', N'WOON_WERK', N'BELGIE', N'Alfa Romeo', N'Giulia', N'WVWZZZ1JZ300029', 2017, '2017-03-01', '2017-03-01', N'3-DGK-129', N'DIESEL', N'4X4', 2, NULL, 2100, 105);

-- Voertuig 31: BMW 3-Serie (2018) - 4-EHL-130
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('1cfd803a-4572-5666-aa7b-ab4cc5578604', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'BMW 3-Serie', N'ACTIEF', '2018-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('1cfd803a-4572-5666-aa7b-ab4cc5578604', N'4X4', N'BEROEP', N'EUROPEES', N'BMW', N'3-Serie', N'WVWZZZ1JZ300030', 2018, '2018-03-01', '2018-03-01', N'4-EHL-130', N'ELEKTRISCH', N'VLO', 0, NULL, 2200, 110);

-- Voertuig 32: Audi A4 (2019) - 5-FIM-131
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('122e0229-c581-5130-85fe-eae9415dbff1', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Audi A4', N'ACTIEF', '2019-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('122e0229-c581-5130-85fe-eae9415dbff1', N'MOTORFIETS', N'ALGEMENE_DOELEINDEN', N'BELGIE', N'Audi', N'A4', N'WVWZZZ1JZ300031', 2019, '2019-03-01', '2019-03-01', N'5-FIM-131', N'HYBRIDE', N'ACH', 1, '4147cf5f-4691-50f2-9f10-6ccf2dac0928', 2300, 115);

-- Voertuig 33: Mercedes C-Klasse (2020) - 6-GJN-132
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('33c9e6de-fa7a-5bf3-acf3-42e1120faa16', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Mercedes C-Klasse', N'ACTIEF', '2020-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('33c9e6de-fa7a-5bf3-acf3-42e1120faa16', N'PERSONENWAGEN', N'PRIV_PLEZIER', N'EUROPEES', N'Mercedes', N'C-Klasse', N'WVWZZZ1JZ300032', 2020, '2020-03-01', '2020-03-01', N'6-GJN-132', N'BENZINE', N'4X4', 2, NULL, 2400, 120);

-- Voertuig 34: Volkswagen Golf (2021) - 7-HKO-133
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('115d05f7-d54f-5aaf-9f3b-29a1cebae9a5', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Volkswagen Golf', N'ACTIEF', '2021-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('115d05f7-d54f-5aaf-9f3b-29a1cebae9a5', N'BESTELWAGEN', N'WOON_WERK', N'BELGIE', N'Volkswagen', N'Golf', N'WVWZZZ1JZ300033', 2021, '2021-03-01', '2021-03-01', N'7-HKO-133', N'DIESEL', N'VLO', 0, NULL, 2500, 125);

-- Voertuig 35: Peugeot 308 (2022) - 8-ILP-134
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('34dc6137-79b7-5fc4-b741-e7093fa10e86', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Peugeot 308', N'ACTIEF', '2022-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('34dc6137-79b7-5fc4-b741-e7093fa10e86', N'4X4', N'BEROEP', N'EUROPEES', N'Peugeot', N'308', N'WVWZZZ1JZ300034', 2022, '2022-03-01', '2022-03-01', N'8-ILP-134', N'ELEKTRISCH', N'ACH', 1, '3400fe07-018d-59e2-bbaf-92dde2aea67e', 2600, 130);

-- Voertuig 36: Renault Clio (2023) - 9-JMQ-135
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('125559ab-8112-55f5-ad01-8b144852a716', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Renault Clio', N'ACTIEF', '2023-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('125559ab-8112-55f5-ad01-8b144852a716', N'MOTORFIETS', N'ALGEMENE_DOELEINDEN', N'BELGIE', N'Renault', N'Clio', N'WVWZZZ1JZ300035', 2023, '2023-03-01', '2023-03-01', N'9-JMQ-135', N'HYBRIDE', N'4X4', 2, NULL, 2700, 135);

-- Voertuig 37: Ford Focus (2015) - 1-KNR-136
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('8eb9013c-61ef-53e7-88c3-c737b8e939de', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Ford Focus', N'ACTIEF', '2015-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('8eb9013c-61ef-53e7-88c3-c737b8e939de', N'PERSONENWAGEN', N'PRIV_PLEZIER', N'EUROPEES', N'Ford', N'Focus', N'WVWZZZ1JZ300036', 2015, '2015-03-01', '2015-03-01', N'1-KNR-136', N'BENZINE', N'VLO', 0, NULL, 2800, 140);

-- Voertuig 38: Opel Astra (2016) - 2-LOS-137
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('adc24fc2-4681-5e42-b806-d929fc56a923', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Opel Astra', N'ACTIEF', '2016-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('adc24fc2-4681-5e42-b806-d929fc56a923', N'BESTELWAGEN', N'WOON_WERK', N'BELGIE', N'Opel', N'Astra', N'WVWZZZ1JZ300037', 2016, '2016-03-01', '2016-03-01', N'2-LOS-137', N'DIESEL', N'ACH', 1, '217fe698-147d-5e61-8260-dd6641a036e7', 2900, 145);

-- Voertuig 39: Volvo V60 (2017) - 3-MPT-138
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('5ded38e6-9ec2-52ed-a889-9460aeab7612', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Volvo V60', N'ACTIEF', '2017-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('5ded38e6-9ec2-52ed-a889-9460aeab7612', N'4X4', N'BEROEP', N'EUROPEES', N'Volvo', N'V60', N'WVWZZZ1JZ300038', 2017, '2017-03-01', '2017-03-01', N'3-MPT-138', N'ELEKTRISCH', N'4X4', 2, NULL, 3000, 150);

-- Voertuig 40: Toyota Corolla (2018) - 4-NQU-139
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('1dcadab7-642f-5652-bb86-7bfec6113a04', 'b21bda85-31d2-5f73-98b8-b168646ac573', N'Toyota Corolla', N'ACTIEF', '2018-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectVehicle (object_id, vehicle_type_code, usage_type_code, plate_type_code, brand, model, chassis_number, build_year, first_commissioning_date, registration_date, license_plate, fuel_type_code, drive_type_code, is_financed, finance_institution_id, engine_cc, power_kw)
VALUES ('1dcadab7-642f-5652-bb86-7bfec6113a04', N'MOTORFIETS', N'ALGEMENE_DOELEINDEN', N'BELGIE', N'Toyota', N'Corolla', N'WVWZZZ1JZ300039', 2018, '2018-03-01', '2018-03-01', N'4-NQU-139', N'HYBRIDE', N'VLO', 0, NULL, 3100, 155);

-- H.2 Onroerend goed (20 stuks)

-- Onroerend goed 1: Appartement te Gent
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('615f71fb-69d4-55c3-b981-1d6b4d2f5a13', 'cb423856-6c6d-529d-b470-b640b0ca57ef', N'Appartement te Gent', N'ACTIEF', '2000-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectRealEstate (object_id, realestate_type_code, description, use_type_code, insured_role_code, residence_type_code, street, number, box, postal_code, city, country_code, adjacency_type_code, occupancy_level_code, construction_type_code, roof_type_code, build_year, is_under_construction, floors_count, apartment_count, has_solar_panels, capital_building)
VALUES ('615f71fb-69d4-55c3-b981-1d6b4d2f5a13', N'GEBOUW', N'Appartement te Gent', N'PRIVAAT', N'EIGENAAR', N'APPARTEMENT', N'Nationalestraat', N'10', N'1', N'2800', N'Mechelen', 'BE', N'ALLEENSTAAND', N'REGELMATIGE_BEWONING', N'HARDE_MATERIALEN', N'TRADITIONEEL', 1950, 0, 1, 1, 0, 150000);

-- Onroerend goed 2: Rijwoning te Mechelen
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('b3d11086-792f-522f-885b-08104b53e591', 'cb423856-6c6d-529d-b470-b640b0ca57ef', N'Rijwoning te Mechelen', N'ACTIEF', '2001-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectRealEstate (object_id, realestate_type_code, description, use_type_code, insured_role_code, residence_type_code, street, number, box, postal_code, city, country_code, adjacency_type_code, occupancy_level_code, construction_type_code, roof_type_code, build_year, is_under_construction, floors_count, apartment_count, has_solar_panels, capital_building)
VALUES ('b3d11086-792f-522f-885b-08104b53e591', N'GOEDEREN', N'Rijwoning te Mechelen', N'BEROEP', N'HUURDER_UITBATER', N'EENGEZINSWONING', N'Hoogstraat', N'11', NULL, N'1000', N'Brussel', 'BE', N'BEIDE_ZIJDEN', N'ONREGELMATIGE_BEWONING', N'HALF_LICHTE_MATERIALEN', N'TRADITIONEEL_OP_ONBRANDBARE_SCHEIDING', 1951, 0, 2, NULL, 1, 160000);

-- Onroerend goed 3: Villa te Knokke
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('b75600bb-8343-5a0c-914a-516fb4186231', 'cb423856-6c6d-529d-b470-b640b0ca57ef', N'Villa te Knokke', N'ACTIEF', '2002-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectRealEstate (object_id, realestate_type_code, description, use_type_code, insured_role_code, residence_type_code, street, number, box, postal_code, city, country_code, adjacency_type_code, occupancy_level_code, construction_type_code, roof_type_code, build_year, is_under_construction, floors_count, apartment_count, has_solar_panels, capital_building)
VALUES ('b75600bb-8343-5a0c-914a-516fb4186231', N'FONDSEN_EN_WAARDEN', N'Villa te Knokke', N'PRIVAAT_PLUS_BEROEP', N'MEDE_EIGENAAR', N'VILLA', N'Kerkstraat', N'12', NULL, N'9000', N'Gent', 'BE', N'BELENDEND', N'GEEN_BEWONING', N'HOUTEN_CONSTRUCTIE', N'ANDERE', 1952, 0, 3, NULL, 2, 170000);

-- Onroerend goed 4: Studio te Brussel
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('76942766-06cc-5cfa-a65d-4b57a4dfdb91', 'cb423856-6c6d-529d-b470-b640b0ca57ef', N'Studio te Brussel', N'ACTIEF', '2003-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectRealEstate (object_id, realestate_type_code, description, use_type_code, insured_role_code, residence_type_code, street, number, box, postal_code, city, country_code, adjacency_type_code, occupancy_level_code, construction_type_code, roof_type_code, build_year, is_under_construction, floors_count, apartment_count, has_solar_panels, capital_building)
VALUES ('76942766-06cc-5cfa-a65d-4b57a4dfdb91', N'BEDRIJF_UITOEFENEN_ACTIVITEIT', N'Studio te Brussel', N'HANDEL', N'EIGENAAR_UITBATER', N'BUILDING', N'Dorpstraat', N'13', N'4', N'2000', N'Antwerpen', 'BE', N'INGESLOTEN', N'REGELMATIGE_BEWONING', N'GECOMPARTIMENTEERD_GEBOUW', N'TRADITIONEEL', 1953, 0, 4, 4, 3, 180000);

-- Onroerend goed 5: Huis te Hasselt
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('de112aea-ba63-5bc0-a737-f31865981105', 'cb423856-6c6d-529d-b470-b640b0ca57ef', N'Huis te Hasselt', N'ACTIEF', '2004-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectRealEstate (object_id, realestate_type_code, description, use_type_code, insured_role_code, residence_type_code, street, number, box, postal_code, city, country_code, adjacency_type_code, occupancy_level_code, construction_type_code, roof_type_code, build_year, is_under_construction, floors_count, apartment_count, has_solar_panels, capital_building)
VALUES ('de112aea-ba63-5bc0-a737-f31865981105', N'GEBOUW', N'Huis te Hasselt', N'PRIVAAT', N'EIGENAAR', N'MEERGEZINSWONING', N'Stationsstraat', N'14', NULL, N'3000', N'Leuven', 'BE', N'ALLEENSTAAND', N'ONREGELMATIGE_BEWONING', N'HARDE_MATERIALEN', N'TRADITIONEEL_OP_ONBRANDBARE_SCHEIDING', 1954, 0, 1, NULL, 0, 190000);

-- Onroerend goed 6: Appartement te Leuven
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('94bd7e5e-ddc3-5deb-bc68-57e1985d49a9', 'cb423856-6c6d-529d-b470-b640b0ca57ef', N'Appartement te Leuven', N'ACTIEF', '2005-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectRealEstate (object_id, realestate_type_code, description, use_type_code, insured_role_code, residence_type_code, street, number, box, postal_code, city, country_code, adjacency_type_code, occupancy_level_code, construction_type_code, roof_type_code, build_year, is_under_construction, floors_count, apartment_count, has_solar_panels, capital_building)
VALUES ('94bd7e5e-ddc3-5deb-bc68-57e1985d49a9', N'GOEDEREN', N'Appartement te Leuven', N'BEROEP', N'HUURDER_UITBATER', N'STUDENTENKOT', N'Markt', N'15', NULL, N'3500', N'Hasselt', 'BE', N'BEIDE_ZIJDEN', N'GEEN_BEWONING', N'HALF_LICHTE_MATERIALEN', N'ANDERE', 1955, 0, 2, NULL, 1, 200000);

-- Onroerend goed 7: Woning te Antwerpen
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('13599ed2-4e5b-5c7a-aa46-d37daeeaeb14', 'cb423856-6c6d-529d-b470-b640b0ca57ef', N'Woning te Antwerpen', N'ACTIEF', '2006-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectRealEstate (object_id, realestate_type_code, description, use_type_code, insured_role_code, residence_type_code, street, number, box, postal_code, city, country_code, adjacency_type_code, occupancy_level_code, construction_type_code, roof_type_code, build_year, is_under_construction, floors_count, apartment_count, has_solar_panels, capital_building)
VALUES ('13599ed2-4e5b-5c7a-aa46-d37daeeaeb14', N'FONDSEN_EN_WAARDEN', N'Woning te Antwerpen', N'PRIVAAT_PLUS_BEROEP', N'MEDE_EIGENAAR', N'APPARTEMENT', N'Grote Markt', N'16', N'7', N'8000', N'Brugge', 'BE', N'BELENDEND', N'REGELMATIGE_BEWONING', N'HOUTEN_CONSTRUCTIE', N'TRADITIONEEL', 1956, 0, 3, 7, 2, 210000);

-- Onroerend goed 8: Handelspand te Brugge
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('bad588cd-1a55-5b97-bf75-9600e44197f7', 'cb423856-6c6d-529d-b470-b640b0ca57ef', N'Handelspand te Brugge', N'ACTIEF', '2007-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectRealEstate (object_id, realestate_type_code, description, use_type_code, insured_role_code, residence_type_code, street, number, box, postal_code, city, country_code, adjacency_type_code, occupancy_level_code, construction_type_code, roof_type_code, build_year, is_under_construction, floors_count, apartment_count, has_solar_panels, capital_building)
VALUES ('bad588cd-1a55-5b97-bf75-9600e44197f7', N'BEDRIJF_UITOEFENEN_ACTIVITEIT', N'Handelspand te Brugge', N'HANDEL', N'EIGENAAR_UITBATER', N'EENGEZINSWONING', N'Koning Albertstraat', N'17', NULL, N'5000', N'Namen', 'BE', N'INGESLOTEN', N'ONREGELMATIGE_BEWONING', N'GECOMPARTIMENTEERD_GEBOUW', N'TRADITIONEEL_OP_ONBRANDBARE_SCHEIDING', 1957, 0, 4, NULL, 3, 220000);

-- Onroerend goed 9: Duplex te Oostende
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('cd5c0f4c-6bef-5bc9-8ec1-60ccdf62372d', 'cb423856-6c6d-529d-b470-b640b0ca57ef', N'Duplex te Oostende', N'ACTIEF', '2008-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectRealEstate (object_id, realestate_type_code, description, use_type_code, insured_role_code, residence_type_code, street, number, box, postal_code, city, country_code, adjacency_type_code, occupancy_level_code, construction_type_code, roof_type_code, build_year, is_under_construction, floors_count, apartment_count, has_solar_panels, capital_building)
VALUES ('cd5c0f4c-6bef-5bc9-8ec1-60ccdf62372d', N'GEBOUW', N'Duplex te Oostende', N'PRIVAAT', N'EIGENAAR', N'VILLA', N'Bondgenotenlaan', N'18', NULL, N'4000', N'Luik', 'BE', N'ALLEENSTAAND', N'GEEN_BEWONING', N'HARDE_MATERIALEN', N'ANDERE', 1958, 0, 1, NULL, 0, 230000);

-- Onroerend goed 10: Kantoor te Luik
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('efe275b5-92e1-5547-9147-1f646ff72b1e', 'cb423856-6c6d-529d-b470-b640b0ca57ef', N'Kantoor te Luik', N'ACTIEF', '2009-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectRealEstate (object_id, realestate_type_code, description, use_type_code, insured_role_code, residence_type_code, street, number, box, postal_code, city, country_code, adjacency_type_code, occupancy_level_code, construction_type_code, roof_type_code, build_year, is_under_construction, floors_count, apartment_count, has_solar_panels, capital_building)
VALUES ('efe275b5-92e1-5547-9147-1f646ff72b1e', N'GOEDEREN', N'Kantoor te Luik', N'BEROEP', N'HUURDER_UITBATER', N'BUILDING', N'Brusselsesteenweg', N'19', N'10', N'8500', N'Kortrijk', 'BE', N'BEIDE_ZIJDEN', N'REGELMATIGE_BEWONING', N'HALF_LICHTE_MATERIALEN', N'TRADITIONEEL', 1959, 0, 2, 2, 1, 240000);

-- Onroerend goed 11: Appartement te Kortrijk
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('164a524c-acfe-512e-b16e-167eb2af0e54', 'cb423856-6c6d-529d-b470-b640b0ca57ef', N'Appartement te Kortrijk', N'ACTIEF', '2010-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectRealEstate (object_id, realestate_type_code, description, use_type_code, insured_role_code, residence_type_code, street, number, box, postal_code, city, country_code, adjacency_type_code, occupancy_level_code, construction_type_code, roof_type_code, build_year, is_under_construction, floors_count, apartment_count, has_solar_panels, capital_building)
VALUES ('164a524c-acfe-512e-b16e-167eb2af0e54', N'FONDSEN_EN_WAARDEN', N'Appartement te Kortrijk', N'PRIVAAT_PLUS_BEROEP', N'MEDE_EIGENAAR', N'MEERGEZINSWONING', N'Gentsesteenweg', N'20', NULL, N'8400', N'Oostende', 'BE', N'BELENDEND', N'ONREGELMATIGE_BEWONING', N'HOUTEN_CONSTRUCTIE', N'TRADITIONEEL_OP_ONBRANDBARE_SCHEIDING', 1960, 0, 3, NULL, 2, 250000);

-- Onroerend goed 12: Woning te Sint-Niklaas
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('f4b2b140-7d18-5cfc-8783-c00d5c61068f', 'cb423856-6c6d-529d-b470-b640b0ca57ef', N'Woning te Sint-Niklaas', N'ACTIEF', '2011-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectRealEstate (object_id, realestate_type_code, description, use_type_code, insured_role_code, residence_type_code, street, number, box, postal_code, city, country_code, adjacency_type_code, occupancy_level_code, construction_type_code, roof_type_code, build_year, is_under_construction, floors_count, apartment_count, has_solar_panels, capital_building)
VALUES ('f4b2b140-7d18-5cfc-8783-c00d5c61068f', N'BEDRIJF_UITOEFENEN_ACTIVITEIT', N'Woning te Sint-Niklaas', N'HANDEL', N'EIGENAAR_UITBATER', N'STUDENTENKOT', N'Antwerpsesteenweg', N'21', NULL, N'9100', N'Sint-Niklaas', 'BE', N'INGESLOTEN', N'GEEN_BEWONING', N'GECOMPARTIMENTEERD_GEBOUW', N'ANDERE', 1961, 0, 4, NULL, 3, 260000);

-- Onroerend goed 13: Villa te Turnhout
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('043f339a-d4c5-5104-b7be-f50bd11e5b09', 'cb423856-6c6d-529d-b470-b640b0ca57ef', N'Villa te Turnhout', N'ACTIEF', '2012-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectRealEstate (object_id, realestate_type_code, description, use_type_code, insured_role_code, residence_type_code, street, number, box, postal_code, city, country_code, adjacency_type_code, occupancy_level_code, construction_type_code, roof_type_code, build_year, is_under_construction, floors_count, apartment_count, has_solar_panels, capital_building)
VALUES ('043f339a-d4c5-5104-b7be-f50bd11e5b09', N'GEBOUW', N'Villa te Turnhout', N'PRIVAAT', N'EIGENAAR', N'APPARTEMENT', N'Leuvensesteenweg', N'22', N'3', N'3600', N'Genk', 'BE', N'ALLEENSTAAND', N'REGELMATIGE_BEWONING', N'HARDE_MATERIALEN', N'TRADITIONEEL', 1962, 0, 1, 5, 0, 270000);

-- Onroerend goed 14: Appartement te Lier
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('32fe6532-a4c3-5c28-ba34-f6a1c694f531', 'cb423856-6c6d-529d-b470-b640b0ca57ef', N'Appartement te Lier', N'ACTIEF', '2013-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectRealEstate (object_id, realestate_type_code, description, use_type_code, insured_role_code, residence_type_code, street, number, box, postal_code, city, country_code, adjacency_type_code, occupancy_level_code, construction_type_code, roof_type_code, build_year, is_under_construction, floors_count, apartment_count, has_solar_panels, capital_building)
VALUES ('32fe6532-a4c3-5c28-ba34-f6a1c694f531', N'GOEDEREN', N'Appartement te Lier', N'BEROEP', N'HUURDER_UITBATER', N'EENGEZINSWONING', N'Mechelsesteenweg', N'23', NULL, N'2300', N'Turnhout', 'BE', N'BEIDE_ZIJDEN', N'ONREGELMATIGE_BEWONING', N'HALF_LICHTE_MATERIALEN', N'TRADITIONEEL_OP_ONBRANDBARE_SCHEIDING', 1963, 0, 2, NULL, 1, 280000);

-- Onroerend goed 15: Huis te Aalst
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('6f891de6-35c0-5e68-b47b-231c98f32994', 'cb423856-6c6d-529d-b470-b640b0ca57ef', N'Huis te Aalst', N'ACTIEF', '2014-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectRealEstate (object_id, realestate_type_code, description, use_type_code, insured_role_code, residence_type_code, street, number, box, postal_code, city, country_code, adjacency_type_code, occupancy_level_code, construction_type_code, roof_type_code, build_year, is_under_construction, floors_count, apartment_count, has_solar_panels, capital_building)
VALUES ('6f891de6-35c0-5e68-b47b-231c98f32994', N'FONDSEN_EN_WAARDEN', N'Huis te Aalst', N'PRIVAAT_PLUS_BEROEP', N'MEDE_EIGENAAR', N'VILLA', N'Luiksesteenweg', N'24', NULL, N'2500', N'Lier', 'BE', N'BELENDEND', N'GEEN_BEWONING', N'HOUTEN_CONSTRUCTIE', N'ANDERE', 1964, 0, 3, NULL, 2, 290000);

-- Onroerend goed 16: Penthouse te Gent
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('4a619506-7899-5192-848f-61ad7619dc1f', 'cb423856-6c6d-529d-b470-b640b0ca57ef', N'Penthouse te Gent', N'ACTIEF', '2015-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectRealEstate (object_id, realestate_type_code, description, use_type_code, insured_role_code, residence_type_code, street, number, box, postal_code, city, country_code, adjacency_type_code, occupancy_level_code, construction_type_code, roof_type_code, build_year, is_under_construction, floors_count, apartment_count, has_solar_panels, capital_building)
VALUES ('4a619506-7899-5192-848f-61ad7619dc1f', N'BEDRIJF_UITOEFENEN_ACTIVITEIT', N'Penthouse te Gent', N'HANDEL', N'EIGENAAR_UITBATER', N'BUILDING', N'Nieuwstraat', N'25', N'6', N'9300', N'Aalst', 'BE', N'INGESLOTEN', N'REGELMATIGE_BEWONING', N'GECOMPARTIMENTEERD_GEBOUW', N'TRADITIONEEL', 1965, 0, 4, 8, 3, 300000);

-- Onroerend goed 17: Studio te Leuven
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('0dbf8fa0-50ba-548d-a74c-f383e8269840', 'cb423856-6c6d-529d-b470-b640b0ca57ef', N'Studio te Leuven', N'ACTIEF', '2016-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectRealEstate (object_id, realestate_type_code, description, use_type_code, insured_role_code, residence_type_code, street, number, box, postal_code, city, country_code, adjacency_type_code, occupancy_level_code, construction_type_code, roof_type_code, build_year, is_under_construction, floors_count, apartment_count, has_solar_panels, capital_building)
VALUES ('0dbf8fa0-50ba-548d-a74c-f383e8269840', N'GEBOUW', N'Studio te Leuven', N'PRIVAAT', N'EIGENAAR', N'MEERGEZINSWONING', N'Zuidstraat', N'26', NULL, N'1800', N'Vilvoorde', 'BE', N'ALLEENSTAAND', N'ONREGELMATIGE_BEWONING', N'HARDE_MATERIALEN', N'TRADITIONEEL_OP_ONBRANDBARE_SCHEIDING', 1966, 0, 1, NULL, 0, 310000);

-- Onroerend goed 18: Woning te Mechelen
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('dcefdf4f-1512-5d96-a686-9b9eaa872107', 'cb423856-6c6d-529d-b470-b640b0ca57ef', N'Woning te Mechelen', N'ACTIEF', '2017-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectRealEstate (object_id, realestate_type_code, description, use_type_code, insured_role_code, residence_type_code, street, number, box, postal_code, city, country_code, adjacency_type_code, occupancy_level_code, construction_type_code, roof_type_code, build_year, is_under_construction, floors_count, apartment_count, has_solar_panels, capital_building)
VALUES ('dcefdf4f-1512-5d96-a686-9b9eaa872107', N'GOEDEREN', N'Woning te Mechelen', N'BEROEP', N'HUURDER_UITBATER', N'STUDENTENKOT', N'Noordstraat', N'27', NULL, N'2200', N'Herentals', 'BE', N'BEIDE_ZIJDEN', N'GEEN_BEWONING', N'HALF_LICHTE_MATERIALEN', N'ANDERE', 1967, 0, 2, NULL, 1, 320000);

-- Onroerend goed 19: Appartement te Brussel
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('5f3b9485-2080-5683-9698-3fa3409761fb', 'cb423856-6c6d-529d-b470-b640b0ca57ef', N'Appartement te Brussel', N'ACTIEF', '2018-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectRealEstate (object_id, realestate_type_code, description, use_type_code, insured_role_code, residence_type_code, street, number, box, postal_code, city, country_code, adjacency_type_code, occupancy_level_code, construction_type_code, roof_type_code, build_year, is_under_construction, floors_count, apartment_count, has_solar_panels, capital_building)
VALUES ('5f3b9485-2080-5683-9698-3fa3409761fb', N'FONDSEN_EN_WAARDEN', N'Appartement te Brussel', N'PRIVAAT_PLUS_BEROEP', N'MEDE_EIGENAAR', N'APPARTEMENT', N'Oude Baan', N'28', N'9', N'2400', N'Mol', 'BE', N'BELENDEND', N'REGELMATIGE_BEWONING', N'HOUTEN_CONSTRUCTIE', N'TRADITIONEEL', 1968, 0, 3, 3, 2, 330000);

-- Onroerend goed 20: Loft te Antwerpen
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('8d527865-8882-5b4d-b43c-728aeac75130', 'cb423856-6c6d-529d-b470-b640b0ca57ef', N'Loft te Antwerpen', N'ACTIEF', '2019-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectRealEstate (object_id, realestate_type_code, description, use_type_code, insured_role_code, residence_type_code, street, number, box, postal_code, city, country_code, adjacency_type_code, occupancy_level_code, construction_type_code, roof_type_code, build_year, is_under_construction, floors_count, apartment_count, has_solar_panels, capital_building)
VALUES ('8d527865-8882-5b4d-b43c-728aeac75130', N'BEDRIJF_UITOEFENEN_ACTIVITEIT', N'Loft te Antwerpen', N'HANDEL', N'EIGENAAR_UITBATER', N'EENGEZINSWONING', N'Nieuwe Baan', N'29', NULL, N'3200', N'Aarschot', 'BE', N'INGESLOTEN', N'ONREGELMATIGE_BEWONING', N'GECOMPARTIMENTEERD_GEBOUW', N'TRADITIONEEL_OP_ONBRANDBARE_SCHEIDING', 1969, 0, 4, NULL, 3, 340000);

-- H.3 Leningen (15 stuks)

-- Lening 1: Hypothecaire lening - 200,000 EUR
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('87e0d31d-3151-5a15-8ea2-a5b05e7da3ff', '33ad6a42-4c27-577b-a529-c8c17761c114', N'Hypothecaire lening - 200,000 EUR', N'ACTIEF', '2018-01-01', '2038-01-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectLoan (object_id, principal_amount, interest_rate_pct, interest_periodicity_code, duration_type_code, start_date, end_date, remark)
VALUES ('87e0d31d-3151-5a15-8ea2-a5b05e7da3ff', 200000, 1.5, N'MAANDELIJKS', N'JAREN', '2018-01-01', '2038-01-01', NULL);

-- Lening 2: Hypothecaire lening - 210,000 EUR
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('a5e9807b-33ad-54c4-a629-ba644a8375f9', '33ad6a42-4c27-577b-a529-c8c17761c114', N'Hypothecaire lening - 210,000 EUR', N'ACTIEF', '2019-02-01', '2039-02-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectLoan (object_id, principal_amount, interest_rate_pct, interest_periodicity_code, duration_type_code, start_date, end_date, remark)
VALUES ('a5e9807b-33ad-54c4-a629-ba644a8375f9', 210000, 1.6, N'JAARLIJKS', N'JAREN', '2019-02-01', '2039-02-01', NULL);

-- Lening 3: Hypothecaire lening - 220,000 EUR
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('8b5c8c98-6f1e-51a2-8eac-beea56efa9b0', '33ad6a42-4c27-577b-a529-c8c17761c114', N'Hypothecaire lening - 220,000 EUR', N'ACTIEF', '2020-03-01', '2040-03-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectLoan (object_id, principal_amount, interest_rate_pct, interest_periodicity_code, duration_type_code, start_date, end_date, remark)
VALUES ('8b5c8c98-6f1e-51a2-8eac-beea56efa9b0', 220000, 1.7, N'DRIEMAANDELIJKS', N'JAREN', '2020-03-01', '2040-03-01', NULL);

-- Lening 4: Hypothecaire lening - 230,000 EUR
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('e91796d3-b49f-525b-80ab-7d1b79fb70ae', '33ad6a42-4c27-577b-a529-c8c17761c114', N'Hypothecaire lening - 230,000 EUR', N'ACTIEF', '2021-04-01', '2041-04-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectLoan (object_id, principal_amount, interest_rate_pct, interest_periodicity_code, duration_type_code, start_date, end_date, remark)
VALUES ('e91796d3-b49f-525b-80ab-7d1b79fb70ae', 230000, 1.8, N'MAANDELIJKS', N'JAREN', '2021-04-01', '2041-04-01', NULL);

-- Lening 5: Hypothecaire lening - 240,000 EUR
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('c4528d77-bfb9-5f57-8a3d-677a99bdd76e', '33ad6a42-4c27-577b-a529-c8c17761c114', N'Hypothecaire lening - 240,000 EUR', N'ACTIEF', '2022-05-01', '2042-05-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectLoan (object_id, principal_amount, interest_rate_pct, interest_periodicity_code, duration_type_code, start_date, end_date, remark)
VALUES ('c4528d77-bfb9-5f57-8a3d-677a99bdd76e', 240000, 1.9, N'JAARLIJKS', N'JAREN', '2022-05-01', '2042-05-01', NULL);

-- Lening 6: Hypothecaire lening - 250,000 EUR
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('3c1e02b1-ac11-5085-9797-6f50336b2555', '33ad6a42-4c27-577b-a529-c8c17761c114', N'Hypothecaire lening - 250,000 EUR', N'ACTIEF', '2018-06-01', '2043-06-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectLoan (object_id, principal_amount, interest_rate_pct, interest_periodicity_code, duration_type_code, start_date, end_date, remark)
VALUES ('3c1e02b1-ac11-5085-9797-6f50336b2555', 250000, 2.0, N'DRIEMAANDELIJKS', N'JAREN', '2018-06-01', '2043-06-01', NULL);

-- Lening 7: Hypothecaire lening - 260,000 EUR
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('03260abd-5a25-5ac0-a58f-4f90607aecdd', '33ad6a42-4c27-577b-a529-c8c17761c114', N'Hypothecaire lening - 260,000 EUR', N'ACTIEF', '2019-07-01', '2044-07-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectLoan (object_id, principal_amount, interest_rate_pct, interest_periodicity_code, duration_type_code, start_date, end_date, remark)
VALUES ('03260abd-5a25-5ac0-a58f-4f90607aecdd', 260000, 2.1, N'MAANDELIJKS', N'JAREN', '2019-07-01', '2044-07-01', NULL);

-- Lening 8: Hypothecaire lening - 270,000 EUR
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('5e83e615-03ae-5813-a4d3-323ec7f29932', '33ad6a42-4c27-577b-a529-c8c17761c114', N'Hypothecaire lening - 270,000 EUR', N'ACTIEF', '2020-08-01', '2045-08-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectLoan (object_id, principal_amount, interest_rate_pct, interest_periodicity_code, duration_type_code, start_date, end_date, remark)
VALUES ('5e83e615-03ae-5813-a4d3-323ec7f29932', 270000, 2.2, N'JAARLIJKS', N'JAREN', '2020-08-01', '2045-08-01', NULL);

-- Lening 9: Afbetalingslening - 50,000 EUR
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('15e0803b-5520-5be3-8db8-4582fa539e88', '33ad6a42-4c27-577b-a529-c8c17761c114', N'Afbetalingslening - 50,000 EUR', N'ACTIEF', '2021-09-01', '2022-09-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectLoan (object_id, principal_amount, interest_rate_pct, interest_periodicity_code, duration_type_code, start_date, end_date, remark)
VALUES ('15e0803b-5520-5be3-8db8-4582fa539e88', 50000, 2.3, N'DRIEMAANDELIJKS', N'JAREN', '2021-09-01', '2022-09-01', NULL);

-- Lening 10: Afbetalingslening - 55,000 EUR
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('0d846405-0557-5a0d-b168-30fd676d1444', '33ad6a42-4c27-577b-a529-c8c17761c114', N'Afbetalingslening - 55,000 EUR', N'ACTIEF', '2022-10-01', '2023-10-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectLoan (object_id, principal_amount, interest_rate_pct, interest_periodicity_code, duration_type_code, start_date, end_date, remark)
VALUES ('0d846405-0557-5a0d-b168-30fd676d1444', 55000, 2.4, N'MAANDELIJKS', N'JAREN', '2022-10-01', '2023-10-01', NULL);

-- Lening 11: Afbetalingslening - 10,000 EUR
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('d6236a06-0bb1-5564-b657-65af89c82a0b', '33ad6a42-4c27-577b-a529-c8c17761c114', N'Afbetalingslening - 10,000 EUR', N'ACTIEF', '2018-11-01', '2024-11-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectLoan (object_id, principal_amount, interest_rate_pct, interest_periodicity_code, duration_type_code, start_date, end_date, remark)
VALUES ('d6236a06-0bb1-5564-b657-65af89c82a0b', 10000, 2.5, N'JAARLIJKS', N'JAREN', '2018-11-01', '2024-11-01', NULL);

-- Lening 12: Afbetalingslening - 15,000 EUR
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('d241fc48-aea1-5529-9a4b-9067da989008', '33ad6a42-4c27-577b-a529-c8c17761c114', N'Afbetalingslening - 15,000 EUR', N'ACTIEF', '2019-12-01', '2025-12-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectLoan (object_id, principal_amount, interest_rate_pct, interest_periodicity_code, duration_type_code, start_date, end_date, remark)
VALUES ('d241fc48-aea1-5529-9a4b-9067da989008', 15000, 2.6, N'DRIEMAANDELIJKS', N'JAREN', '2019-12-01', '2025-12-01', NULL);

-- Lening 13: Afbetalingslening - 20,000 EUR
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('e5286717-7d5b-5bfb-aa4f-1f3ad3ecfa91', '33ad6a42-4c27-577b-a529-c8c17761c114', N'Afbetalingslening - 20,000 EUR', N'ACTIEF', '2020-01-01', '2026-01-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectLoan (object_id, principal_amount, interest_rate_pct, interest_periodicity_code, duration_type_code, start_date, end_date, remark)
VALUES ('e5286717-7d5b-5bfb-aa4f-1f3ad3ecfa91', 20000, 2.7, N'MAANDELIJKS', N'JAREN', '2020-01-01', '2026-01-01', NULL);

-- Lening 14: Afbetalingslening - 25,000 EUR
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('ff437f05-bf1b-5171-b58e-5349b6fae16e', '33ad6a42-4c27-577b-a529-c8c17761c114', N'Afbetalingslening - 25,000 EUR', N'ACTIEF', '2021-02-01', '2027-02-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectLoan (object_id, principal_amount, interest_rate_pct, interest_periodicity_code, duration_type_code, start_date, end_date, remark)
VALUES ('ff437f05-bf1b-5171-b58e-5349b6fae16e', 25000, 2.8, N'JAARLIJKS', N'JAREN', '2021-02-01', '2027-02-01', NULL);

-- Lening 15: Afbetalingslening - 30,000 EUR
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('df2750c1-b88b-5002-b829-0eae37b84374', '33ad6a42-4c27-577b-a529-c8c17761c114', N'Afbetalingslening - 30,000 EUR', N'ACTIEF', '2022-03-01', '2021-03-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectLoan (object_id, principal_amount, interest_rate_pct, interest_periodicity_code, duration_type_code, start_date, end_date, remark)
VALUES ('df2750c1-b88b-5002-b829-0eae37b84374', 30000, 2.9000000000000004, N'DRIEMAANDELIJKS', N'JAREN', '2022-03-01', '2021-03-01', NULL);

-- H.4 Zaken (15 stuks)

-- Zaak 1: Schilderij (Van Gogh Collectie)
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('ddc14d7e-1ef0-57a3-9f17-a79aa53bd2ed', '74bf64cc-d649-588c-bbe1-079602a995d4', N'Schilderij', N'ACTIEF', '2020-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectThing (object_id, subtype_code, description, brand, serial_number, value_insured, value_new, risk_category_code, material_type_code, location_street, location_number, location_postal_code, location_city)
VALUES ('ddc14d7e-1ef0-57a3-9f17-a79aa53bd2ed', N'INBOEDEL', N'Schilderij', N'Van Gogh Collectie', N'SN100000', 2000, 3000, N'LOW', N'METAAL', N'Nationalestraat', N'10', N'2800', N'Mechelen');

-- Zaak 2: Juwelen (Cartier)
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('1c26613e-5cab-573b-8b15-e7caaf3d8296', '74bf64cc-d649-588c-bbe1-079602a995d4', N'Juwelen', N'ACTIEF', '2020-02-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectThing (object_id, subtype_code, description, brand, serial_number, value_insured, value_new, risk_category_code, material_type_code, location_street, location_number, location_postal_code, location_city)
VALUES ('1c26613e-5cab-573b-8b15-e7caaf3d8296', N'GOEDEREN', N'Juwelen', N'Cartier', N'SN100001', 2500, 3600, N'MEDIUM', N'HOUT', N'Hoogstraat', N'11', N'1000', N'Brussel');

-- Zaak 3: Laptop (Apple MacBook Pro)
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('cddfbce9-a943-5705-862a-e692cc7475d0', '74bf64cc-d649-588c-bbe1-079602a995d4', N'Laptop', N'ACTIEF', '2020-03-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectThing (object_id, subtype_code, description, brand, serial_number, value_insured, value_new, risk_category_code, material_type_code, location_street, location_number, location_postal_code, location_city)
VALUES ('cddfbce9-a943-5705-862a-e692cc7475d0', N'VOORWERP', N'Laptop', N'Apple MacBook Pro', N'SN100002', 3000, 4200, N'HIGH', N'KUNSTSTOF', N'Kerkstraat', N'12', N'9000', N'Gent');

-- Zaak 4: FietS (Trek)
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('37a236da-893a-5235-8011-505c0eb996d9', '74bf64cc-d649-588c-bbe1-079602a995d4', N'FietS', N'ACTIEF', '2020-04-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectThing (object_id, subtype_code, description, brand, serial_number, value_insured, value_new, risk_category_code, material_type_code, location_street, location_number, location_postal_code, location_city)
VALUES ('37a236da-893a-5235-8011-505c0eb996d9', N'ACCESSOIRES', N'FietS', N'Trek', N'SN100003', 3500, 4800, N'LOW', N'GEMENGD', N'Dorpstraat', N'13', N'2000', N'Antwerpen');

-- Zaak 5: Camera (Canon EOS)
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('28ccd192-1129-5fef-83cb-efa5d333eaff', '74bf64cc-d649-588c-bbe1-079602a995d4', N'Camera', N'ACTIEF', '2020-05-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectThing (object_id, subtype_code, description, brand, serial_number, value_insured, value_new, risk_category_code, material_type_code, location_street, location_number, location_postal_code, location_city)
VALUES ('28ccd192-1129-5fef-83cb-efa5d333eaff', N'DIER', N'Camera', N'Canon EOS', N'SN100004', 4000, 5400, N'MEDIUM', N'METAAL', N'Stationsstraat', N'14', N'3000', N'Leuven');

-- Zaak 6: Horloge (Omega)
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('971d6a4c-f3d0-5bd2-bc1b-ddfd950c5ed8', '74bf64cc-d649-588c-bbe1-079602a995d4', N'Horloge', N'ACTIEF', '2020-06-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectThing (object_id, subtype_code, description, brand, serial_number, value_insured, value_new, risk_category_code, material_type_code, location_street, location_number, location_postal_code, location_city)
VALUES ('971d6a4c-f3d0-5bd2-bc1b-ddfd950c5ed8', N'FONDSEN', N'Horloge', N'Omega', N'SN100005', 4500, 6000, N'HIGH', N'HOUT', N'Markt', N'15', N'3500', N'Hasselt');

-- Zaak 7: TV (Samsung QLED)
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('d1b113c8-4616-54e2-9e03-99a1a7c02634', '74bf64cc-d649-588c-bbe1-079602a995d4', N'TV', N'ACTIEF', '2020-07-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectThing (object_id, subtype_code, description, brand, serial_number, value_insured, value_new, risk_category_code, material_type_code, location_street, location_number, location_postal_code, location_city)
VALUES ('d1b113c8-4616-54e2-9e03-99a1a7c02634', N'INBOEDEL', N'TV', N'Samsung QLED', N'SN100006', 5000, 6600, N'LOW', N'KUNSTSTOF', N'Grote Markt', N'16', N'8000', N'Brugge');

-- Zaak 8: Audio Apparatuur (Bose)
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('c84b5445-2f5f-531c-b453-9fa5643171df', '74bf64cc-d649-588c-bbe1-079602a995d4', N'Audio Apparatuur', N'ACTIEF', '2020-08-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectThing (object_id, subtype_code, description, brand, serial_number, value_insured, value_new, risk_category_code, material_type_code, location_street, location_number, location_postal_code, location_city)
VALUES ('c84b5445-2f5f-531c-b453-9fa5643171df', N'GOEDEREN', N'Audio Apparatuur', N'Bose', N'SN100007', 5500, 7200, N'MEDIUM', N'GEMENGD', N'Koning Albertstraat', N'17', N'5000', N'Namen');

-- Zaak 9: Tablet (iPad Pro)
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('93dc469c-49d3-5492-a1cb-923a09c1d49d', '74bf64cc-d649-588c-bbe1-079602a995d4', N'Tablet', N'ACTIEF', '2020-09-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectThing (object_id, subtype_code, description, brand, serial_number, value_insured, value_new, risk_category_code, material_type_code, location_street, location_number, location_postal_code, location_city)
VALUES ('93dc469c-49d3-5492-a1cb-923a09c1d49d', N'VOORWERP', N'Tablet', N'iPad Pro', N'SN100008', 6000, 7800, N'HIGH', N'METAAL', N'Bondgenotenlaan', N'18', N'4000', N'Luik');

-- Zaak 10: Smartphone (iPhone 15)
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('9f28272a-af06-5c97-8e38-7633b432b498', '74bf64cc-d649-588c-bbe1-079602a995d4', N'Smartphone', N'ACTIEF', '2020-10-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectThing (object_id, subtype_code, description, brand, serial_number, value_insured, value_new, risk_category_code, material_type_code, location_street, location_number, location_postal_code, location_city)
VALUES ('9f28272a-af06-5c97-8e38-7633b432b498', N'ACCESSOIRES', N'Smartphone', N'iPhone 15', N'SN100009', 6500, 8400, N'LOW', N'HOUT', N'Brusselsesteenweg', N'19', N'8500', N'Kortrijk');

-- Zaak 11: Gaming Console (PlayStation 5)
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('0b8455bf-4548-5ac4-9cd6-f19888bfa2c9', '74bf64cc-d649-588c-bbe1-079602a995d4', N'Gaming Console', N'ACTIEF', '2020-11-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectThing (object_id, subtype_code, description, brand, serial_number, value_insured, value_new, risk_category_code, material_type_code, location_street, location_number, location_postal_code, location_city)
VALUES ('0b8455bf-4548-5ac4-9cd6-f19888bfa2c9', N'DIER', N'Gaming Console', N'PlayStation 5', N'SN100010', 7000, 9000, N'MEDIUM', N'KUNSTSTOF', N'Gentsesteenweg', N'20', N'8400', N'Oostende');

-- Zaak 12: Fitness Apparatuur (Technogym)
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('d03b6fab-5563-524c-9f09-6ca091d46fd2', '74bf64cc-d649-588c-bbe1-079602a995d4', N'Fitness Apparatuur', N'ACTIEF', '2020-12-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectThing (object_id, subtype_code, description, brand, serial_number, value_insured, value_new, risk_category_code, material_type_code, location_street, location_number, location_postal_code, location_city)
VALUES ('d03b6fab-5563-524c-9f09-6ca091d46fd2', N'FONDSEN', N'Fitness Apparatuur', N'Technogym', N'SN100011', 7500, 9600, N'HIGH', N'GEMENGD', N'Antwerpsesteenweg', N'21', N'9100', N'Sint-Niklaas');

-- Zaak 13: Keukenapparatuur (KitchenAid)
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('3051a98b-f0ae-5844-8c0e-7585805529f4', '74bf64cc-d649-588c-bbe1-079602a995d4', N'Keukenapparatuur', N'ACTIEF', '2020-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectThing (object_id, subtype_code, description, brand, serial_number, value_insured, value_new, risk_category_code, material_type_code, location_street, location_number, location_postal_code, location_city)
VALUES ('3051a98b-f0ae-5844-8c0e-7585805529f4', N'INBOEDEL', N'Keukenapparatuur', N'KitchenAid', N'SN100012', 8000, 10200, N'LOW', N'METAAL', N'Leuvensesteenweg', N'22', N'3600', N'Genk');

-- Zaak 14: Gereedschap (Bosch Professional)
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('7b418d3e-15e8-5fb6-b1bc-120847eee7a1', '74bf64cc-d649-588c-bbe1-079602a995d4', N'Gereedschap', N'ACTIEF', '2020-02-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectThing (object_id, subtype_code, description, brand, serial_number, value_insured, value_new, risk_category_code, material_type_code, location_street, location_number, location_postal_code, location_city)
VALUES ('7b418d3e-15e8-5fb6-b1bc-120847eee7a1', N'GOEDEREN', N'Gereedschap', N'Bosch Professional', N'SN100013', 8500, 10800, N'MEDIUM', N'HOUT', N'Mechelsesteenweg', N'23', N'2300', N'Turnhout');

-- Zaak 15: Boekencollectie (Eerste Drukken)
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('72024023-c63c-59a6-9ac4-a5219c779ec2', '74bf64cc-d649-588c-bbe1-079602a995d4', N'Boekencollectie', N'ACTIEF', '2020-03-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectThing (object_id, subtype_code, description, brand, serial_number, value_insured, value_new, risk_category_code, material_type_code, location_street, location_number, location_postal_code, location_city)
VALUES ('72024023-c63c-59a6-9ac4-a5219c779ec2', N'VOORWERP', N'Boekencollectie', N'Eerste Drukken', N'SN100014', 9000, 11400, N'HIGH', N'KUNSTSTOF', N'Luiksesteenweg', N'24', N'2500', N'Lier');

-- H.5 Activiteiten (10 stuks)

-- Activiteit 1: Zomerfestival Brussel
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('e249f6f9-1d6b-53d1-a3e3-052c8b709dea', '124a9039-35b7-5efd-a21a-9fecffad98c6', N'Zomerfestival Brussel', N'ACTIEF', '2024-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectActivity (object_id, activity_type_code, description, start_datetime, end_datetime, participant_count, age_category_code, risk_level_code, location_street, location_number, location_postal_code, location_city)
VALUES ('e249f6f9-1d6b-53d1-a3e3-052c8b709dea', N'FEEST', N'Zomerfestival Brussel', '2024-01-10 10:00:00', '2024-01-10 18:00:00', 50, N'VOLW', N'LAAG', N'Nationalestraat', N'1', N'2800', N'Mechelen');

-- Activiteit 2: Rock Werchter
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('4fe5335f-eec7-5a1d-8377-0ccb8709cf20', '124a9039-35b7-5efd-a21a-9fecffad98c6', N'Rock Werchter', N'ACTIEF', '2024-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectActivity (object_id, activity_type_code, description, start_datetime, end_datetime, participant_count, age_category_code, risk_level_code, location_street, location_number, location_postal_code, location_city)
VALUES ('4fe5335f-eec7-5a1d-8377-0ccb8709cf20', N'CONCERT', N'Rock Werchter', '2024-02-11 11:00:00', '2024-02-11 19:00:00', 51, N'GEMENGD', N'MIDDEN', N'Hoogstraat', N'2', N'1000', N'Brussel');

-- Activiteit 3: Marathon Brussel
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('f391531d-3f8f-538c-a209-1658b489bbb7', '124a9039-35b7-5efd-a21a-9fecffad98c6', N'Marathon Brussel', N'ACTIEF', '2024-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectActivity (object_id, activity_type_code, description, start_datetime, end_datetime, participant_count, age_category_code, risk_level_code, location_street, location_number, location_postal_code, location_city)
VALUES ('f391531d-3f8f-538c-a209-1658b489bbb7', N'SPORT_MANIFESTATIE', N'Marathon Brussel', '2024-03-12 12:00:00', '2024-03-12 20:00:00', 52, N'VOLW', N'HOOG', N'Kerkstraat', N'3', N'9000', N'Gent');

-- Activiteit 4: Antwerpse Beurs
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('bd5262f3-1efe-5f38-9ebd-63a2fa369b81', '124a9039-35b7-5efd-a21a-9fecffad98c6', N'Antwerpse Beurs', N'ACTIEF', '2024-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectActivity (object_id, activity_type_code, description, start_datetime, end_datetime, participant_count, age_category_code, risk_level_code, location_street, location_number, location_postal_code, location_city)
VALUES ('bd5262f3-1efe-5f38-9ebd-63a2fa369b81', N'BEURS', N'Antwerpse Beurs', '2024-04-13 13:00:00', '2024-04-13 21:00:00', 53, N'GEMENGD', N'LAAG', N'Dorpstraat', N'4', N'2000', N'Antwerpen');

-- Activiteit 5: Gentse Feesten
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('07e29055-21a8-522f-826d-b908708f3498', '124a9039-35b7-5efd-a21a-9fecffad98c6', N'Gentse Feesten', N'ACTIEF', '2024-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectActivity (object_id, activity_type_code, description, start_datetime, end_datetime, participant_count, age_category_code, risk_level_code, location_street, location_number, location_postal_code, location_city)
VALUES ('07e29055-21a8-522f-826d-b908708f3498', N'TOERNOOI', N'Gentse Feesten', '2024-05-14 14:00:00', '2024-05-14 22:00:00', 54, N'VOLW', N'MIDDEN', N'Stationsstraat', N'5', N'3000', N'Leuven');

-- Activiteit 6: VIP Corporate Event
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('5cb08ac5-b422-5955-b0e8-0ffc7eb8d85e', '124a9039-35b7-5efd-a21a-9fecffad98c6', N'VIP Corporate Event', N'ACTIEF', '2024-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectActivity (object_id, activity_type_code, description, start_datetime, end_datetime, participant_count, age_category_code, risk_level_code, location_street, location_number, location_postal_code, location_city)
VALUES ('5cb08ac5-b422-5955-b0e8-0ffc7eb8d85e', N'FEEST', N'VIP Corporate Event', '2024-06-15 15:00:00', '2024-06-15 23:00:00', 55, N'GEMENGD', N'HOOG', N'Markt', N'6', N'3500', N'Hasselt');

-- Activiteit 7: Sportdag Mechelen
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('9d8780bf-1cc7-5700-9bfe-387149f0bcb0', '124a9039-35b7-5efd-a21a-9fecffad98c6', N'Sportdag Mechelen', N'ACTIEF', '2024-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectActivity (object_id, activity_type_code, description, start_datetime, end_datetime, participant_count, age_category_code, risk_level_code, location_street, location_number, location_postal_code, location_city)
VALUES ('9d8780bf-1cc7-5700-9bfe-387149f0bcb0', N'CONCERT', N'Sportdag Mechelen', '2024-07-16 16:00:00', '2024-07-16 18:00:00', 56, N'VOLW', N'LAAG', N'Grote Markt', N'7', N'8000', N'Brugge');

-- Activiteit 8: Kerstmarkt Leuven
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('b4872d9a-2bfc-5f2c-9463-83c6452a89f6', '124a9039-35b7-5efd-a21a-9fecffad98c6', N'Kerstmarkt Leuven', N'ACTIEF', '2024-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectActivity (object_id, activity_type_code, description, start_datetime, end_datetime, participant_count, age_category_code, risk_level_code, location_street, location_number, location_postal_code, location_city)
VALUES ('b4872d9a-2bfc-5f2c-9463-83c6452a89f6', N'SPORT_MANIFESTATIE', N'Kerstmarkt Leuven', '2024-08-17 17:00:00', '2024-08-17 19:00:00', 57, N'GEMENGD', N'MIDDEN', N'Koning Albertstraat', N'8', N'5000', N'Namen');

-- Activiteit 9: Nieuwjaarsreceptie
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('b76ff5de-bc8c-5a03-9959-b63b664ce80c', '124a9039-35b7-5efd-a21a-9fecffad98c6', N'Nieuwjaarsreceptie', N'ACTIEF', '2024-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectActivity (object_id, activity_type_code, description, start_datetime, end_datetime, participant_count, age_category_code, risk_level_code, location_street, location_number, location_postal_code, location_city)
VALUES ('b76ff5de-bc8c-5a03-9959-b63b664ce80c', N'BEURS', N'Nieuwjaarsreceptie', '2024-09-18 10:00:00', '2024-09-18 20:00:00', 58, N'VOLW', N'HOOG', N'Bondgenotenlaan', N'9', N'4000', N'Luik');

-- Activiteit 10: Benefietconcert Hasselt
INSERT INTO [Object] (object_id, object_type_id, description, status, start_date, end_date, created_at, updated_at)
VALUES ('b62fe2e6-d51c-5479-a726-87c9f762e6ef', '124a9039-35b7-5efd-a21a-9fecffad98c6', N'Benefietconcert Hasselt', N'ACTIEF', '2024-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO ObjectActivity (object_id, activity_type_code, description, start_datetime, end_datetime, participant_count, age_category_code, risk_level_code, location_street, location_number, location_postal_code, location_city)
VALUES ('b62fe2e6-d51c-5479-a726-87c9f762e6ef', N'TOERNOOI', N'Benefietconcert Hasselt', '2024-10-19 11:00:00', '2024-10-19 21:00:00', 59, N'GEMENGD', N'LAAG', N'Brusselsesteenweg', N'10', N'8500', N'Kortrijk');

PRINT '100 objecten ingevoegd.';
GO

-- =============================================================
-- I. 50 Contracten
-- 15 Auto, 10 Brand, 8 Leven, 5 Hospitalisatie,
-- 5 Arbeidsongevallen, 4 Rechtsbijstand, 3 Diversen
-- =============================================================

-- Contract 1: CNT-2020-1000 (Auto)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('9bd88578-ff20-50f1-87ec-24569c4eca21', N'CNT-2020-1000', N'AUTO', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'LOPEND', '32eaa733-aa65-5a24-a3c7-f26a5e4ac984', '95004e35-d095-591e-92b5-eddca13a68cb', '2020-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('9bd88578-ff20-50f1-87ec-24569c4eca21', '219711d4-f1e9-5b7c-84bc-490a41110884', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('9bd88578-ff20-50f1-87ec-24569c4eca21', '558570a8-3cea-5fc8-abba-8d4defa4d822', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('9bd88578-ff20-50f1-87ec-24569c4eca21', '6b294aa4-eba1-5957-b452-c46cfcd080fd', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 2: CNT-2021-1001 (Auto)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('26b69ff1-94a5-590d-9cfe-a821cc88a92f', N'CNT-2021-1001', N'AUTO', N'AUTO_MOTORFIETSEN', N'GESCHORST', 'fd24c8bc-50ee-564a-ad64-226f6682f40e', NULL, '2021-02-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('26b69ff1-94a5-590d-9cfe-a821cc88a92f', '7268581b-0dbd-52b1-b752-40aebb63d0a5', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('26b69ff1-94a5-590d-9cfe-a821cc88a92f', '6b294aa4-eba1-5957-b452-c46cfcd080fd', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('26b69ff1-94a5-590d-9cfe-a821cc88a92f', '91d71aba-820f-57c3-b8b9-eaab0fd65fbf', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 3: CNT-2022-1002 (Auto)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('567782bb-e9b9-5d2f-a83b-4f5aaca39557', N'CNT-2022-1002', N'AUTO', N'AUTO_LICHTE_VRACHTWAGENS', N'OPGEZEGD', '35cbc940-709f-5dcd-87d1-dbea18ae6df5', NULL, '2022-03-01', '2023-03-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('567782bb-e9b9-5d2f-a83b-4f5aaca39557', '767455ff-6716-57b8-8b1b-07625f980552', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('567782bb-e9b9-5d2f-a83b-4f5aaca39557', '91d71aba-820f-57c3-b8b9-eaab0fd65fbf', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('567782bb-e9b9-5d2f-a83b-4f5aaca39557', '4e4bc4f2-ee4f-568a-958b-2ae5e9ba2536', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 4: CNT-2023-1003 (Auto)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('79c4c636-42d3-5539-9f02-8fe1b33e78ef', N'CNT-2023-1003', N'AUTO', N'AUTO_BROMFIETSEN', N'IN_WIJZIGING', '239bb32c-b140-5d5b-9768-29f706468de6', 'dcc6cb9c-16f8-5313-b948-0d6aed21087b', '2023-04-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('79c4c636-42d3-5539-9f02-8fe1b33e78ef', '6ef2fb59-c4d6-509d-82b7-86ba6954d512', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('79c4c636-42d3-5539-9f02-8fe1b33e78ef', '4e4bc4f2-ee4f-568a-958b-2ae5e9ba2536', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('79c4c636-42d3-5539-9f02-8fe1b33e78ef', '806ad90f-fbde-53ff-8b75-7de469399de6', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 5: CNT-2024-1004 (Auto)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('7f4d66d3-5564-54f5-920f-bdbf1332f7ac', N'CNT-2024-1004', N'AUTO', N'AUTO_VERKEER_EN_INZITTENDEN', N'NIE_ACTIEF', '742f978f-ae20-5b80-b224-719d7f076027', NULL, '2024-05-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('7f4d66d3-5564-54f5-920f-bdbf1332f7ac', 'f2ebd19a-69e8-50cc-bc6f-290e94deb79a', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('7f4d66d3-5564-54f5-920f-bdbf1332f7ac', '806ad90f-fbde-53ff-8b75-7de469399de6', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('7f4d66d3-5564-54f5-920f-bdbf1332f7ac', 'f97da18f-a51b-5ead-9b4d-291be9fc82a6', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 6: CNT-2020-1005 (Auto)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('afa51f46-aa03-5d3c-84fe-d4caff90e8e7', N'CNT-2020-1005', N'AUTO', N'AUTO_VRACHTWAGENS_V_E_R_VERVOER_EIGEN_REK', N'LOPEND', '797f738f-8c2c-53fa-bd88-19ab6154c655', NULL, '2020-06-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('afa51f46-aa03-5d3c-84fe-d4caff90e8e7', '8dbcaf2e-12f0-51a4-ac0d-1e65bd18488a', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('afa51f46-aa03-5d3c-84fe-d4caff90e8e7', 'f97da18f-a51b-5ead-9b4d-291be9fc82a6', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('afa51f46-aa03-5d3c-84fe-d4caff90e8e7', '299f4bb7-59a7-5e38-b095-c8c908a6931c', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 7: CNT-2021-1006 (Auto)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('5a27c7eb-59cd-59d9-8d13-8871b698011b', N'CNT-2021-1006', N'AUTO', N'AUTO_BIJZONDERE_VOERTUIGEN', N'GESCHORST', 'd1253b8e-1b5f-5a1c-8e3d-16effd1beb47', '8f91a8dc-2d6e-5605-a8b2-475edb225110', '2021-07-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('5a27c7eb-59cd-59d9-8d13-8871b698011b', 'd421bbf2-d9ea-5c6c-94e1-822811b8482f', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('5a27c7eb-59cd-59d9-8d13-8871b698011b', '299f4bb7-59a7-5e38-b095-c8c908a6931c', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('5a27c7eb-59cd-59d9-8d13-8871b698011b', 'fbb5d528-e3ae-5579-8a29-b0c8de0ea628', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 8: CNT-2022-1007 (Auto)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('7d77bd60-07e9-592b-a0d3-83a58e0d76e0', N'CNT-2022-1007', N'AUTO', N'AUTO_GEMENGDE_VLOOT', N'OPGEZEGD', '41ff067a-5982-5dde-beb9-ca35ccbe3109', NULL, '2022-08-01', '2023-08-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('7d77bd60-07e9-592b-a0d3-83a58e0d76e0', 'c54ae5ab-b164-5d26-ab0e-1226a794ba00', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('7d77bd60-07e9-592b-a0d3-83a58e0d76e0', 'fbb5d528-e3ae-5579-8a29-b0c8de0ea628', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('7d77bd60-07e9-592b-a0d3-83a58e0d76e0', '10218115-9b35-552d-8b7d-19f8a2649c5d', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 9: CNT-2023-1008 (Auto)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('0a2b4116-728f-5fcb-856a-f9aebd1b4053', N'CNT-2023-1008', N'AUTO', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'IN_WIJZIGING', '32eaa733-aa65-5a24-a3c7-f26a5e4ac984', NULL, '2023-09-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('0a2b4116-728f-5fcb-856a-f9aebd1b4053', '2918c7dc-bf8a-5adf-a342-2f427ea33ad2', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('0a2b4116-728f-5fcb-856a-f9aebd1b4053', '10218115-9b35-552d-8b7d-19f8a2649c5d', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('0a2b4116-728f-5fcb-856a-f9aebd1b4053', '16a7a99b-0ec4-51e5-888a-f2a9232b4785', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 10: CNT-2024-1009 (Auto)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('23d7848e-7bf7-5431-b154-6999759ff3f5', N'CNT-2024-1009', N'AUTO', N'AUTO_MOTORFIETSEN', N'NIE_ACTIEF', 'fd24c8bc-50ee-564a-ad64-226f6682f40e', '85ec606f-d619-5391-beed-8a9112d1147b', '2024-10-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('23d7848e-7bf7-5431-b154-6999759ff3f5', '06d5be89-2291-5bb5-9a22-906efcffbfca', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('23d7848e-7bf7-5431-b154-6999759ff3f5', '16a7a99b-0ec4-51e5-888a-f2a9232b4785', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('23d7848e-7bf7-5431-b154-6999759ff3f5', '8fd3e52e-3b42-5baf-8d15-4a2b4b6d783a', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 11: CNT-2020-1010 (Auto)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('26c26abf-e932-5d49-ae97-8c656011a98a', N'CNT-2020-1010', N'AUTO', N'AUTO_LICHTE_VRACHTWAGENS', N'LOPEND', '35cbc940-709f-5dcd-87d1-dbea18ae6df5', NULL, '2020-11-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('26c26abf-e932-5d49-ae97-8c656011a98a', '5485d4fb-5fe5-5d99-bddd-cd9ca895e3e7', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('26c26abf-e932-5d49-ae97-8c656011a98a', '8fd3e52e-3b42-5baf-8d15-4a2b4b6d783a', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('26c26abf-e932-5d49-ae97-8c656011a98a', '0e3da740-b6c5-5fee-87bd-db8ef5987af7', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 12: CNT-2021-1011 (Auto)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('ce94b359-72bb-5f98-b7a7-572c00905c28', N'CNT-2021-1011', N'AUTO', N'AUTO_BROMFIETSEN', N'GESCHORST', '239bb32c-b140-5d5b-9768-29f706468de6', NULL, '2021-12-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('ce94b359-72bb-5f98-b7a7-572c00905c28', '0f0f2938-e0e5-5dd6-aac5-f9c21720495d', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('ce94b359-72bb-5f98-b7a7-572c00905c28', '0e3da740-b6c5-5fee-87bd-db8ef5987af7', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('ce94b359-72bb-5f98-b7a7-572c00905c28', '0596830f-5f5c-5724-9387-4f6eb0b1b081', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 13: CNT-2022-1012 (Auto)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('5c531e71-3553-576a-8819-a952c3831ff3', N'CNT-2022-1012', N'AUTO', N'AUTO_VERKEER_EN_INZITTENDEN', N'OPGEZEGD', '742f978f-ae20-5b80-b224-719d7f076027', '95004e35-d095-591e-92b5-eddca13a68cb', '2022-01-01', '2023-01-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('5c531e71-3553-576a-8819-a952c3831ff3', '31572584-1fed-582a-9c35-e4c7812029e6', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('5c531e71-3553-576a-8819-a952c3831ff3', '0596830f-5f5c-5724-9387-4f6eb0b1b081', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('5c531e71-3553-576a-8819-a952c3831ff3', 'ec766974-349a-5cd1-b49f-1604f8ba1485', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 14: CNT-2023-1013 (Auto)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('e58d5d12-3a2a-54fa-8548-06d6e6b46d05', N'CNT-2023-1013', N'AUTO', N'AUTO_VRACHTWAGENS_V_E_R_VERVOER_EIGEN_REK', N'IN_WIJZIGING', '797f738f-8c2c-53fa-bd88-19ab6154c655', NULL, '2023-02-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('e58d5d12-3a2a-54fa-8548-06d6e6b46d05', '255fbd61-4611-58f5-8a9d-5a1d9d900509', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('e58d5d12-3a2a-54fa-8548-06d6e6b46d05', 'ec766974-349a-5cd1-b49f-1604f8ba1485', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('e58d5d12-3a2a-54fa-8548-06d6e6b46d05', '8bd19ed5-024a-5885-9283-d4ca74b626d6', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 15: CNT-2024-1014 (Auto)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('ee370942-43bd-5119-805c-db8214a75fa5', N'CNT-2024-1014', N'AUTO', N'AUTO_BIJZONDERE_VOERTUIGEN', N'NIE_ACTIEF', 'd1253b8e-1b5f-5a1c-8e3d-16effd1beb47', NULL, '2024-03-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('ee370942-43bd-5119-805c-db8214a75fa5', 'ece43643-6bf6-5ba3-aa12-86b4e6f28c98', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('ee370942-43bd-5119-805c-db8214a75fa5', '8bd19ed5-024a-5885-9283-d4ca74b626d6', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('ee370942-43bd-5119-805c-db8214a75fa5', '35ed7061-976a-5d58-964a-901a499da662', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 16: CNT-2020-1015 (Brand eenvoudig)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('b27af111-a480-5a90-867b-d94b6276e206', N'CNT-2020-1015', N'BRAND_EENVOUDIG', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'LOPEND', '41ff067a-5982-5dde-beb9-ca35ccbe3109', 'dcc6cb9c-16f8-5313-b948-0d6aed21087b', '2020-04-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('b27af111-a480-5a90-867b-d94b6276e206', 'a457648d-1590-5e2f-b8bf-a23785c04f64', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('b27af111-a480-5a90-867b-d94b6276e206', '4a619506-7899-5192-848f-61ad7619dc1f', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('b27af111-a480-5a90-867b-d94b6276e206', '0dbf8fa0-50ba-548d-a74c-f383e8269840', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 17: CNT-2021-1016 (Brand eenvoudig)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('01a6fb3c-ea6c-559a-be42-cf0626645e29', N'CNT-2021-1016', N'BRAND_EENVOUDIG', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'GESCHORST', '32eaa733-aa65-5a24-a3c7-f26a5e4ac984', NULL, '2021-05-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('01a6fb3c-ea6c-559a-be42-cf0626645e29', 'e2f6b781-f674-5f9d-8b42-126c1bee3960', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('01a6fb3c-ea6c-559a-be42-cf0626645e29', '0dbf8fa0-50ba-548d-a74c-f383e8269840', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('01a6fb3c-ea6c-559a-be42-cf0626645e29', 'dcefdf4f-1512-5d96-a686-9b9eaa872107', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 18: CNT-2022-1017 (Brand eenvoudig)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('38f7a504-71b6-5c93-9fd0-41656e619040', N'CNT-2022-1017', N'BRAND_EENVOUDIG', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'OPGEZEGD', 'fd24c8bc-50ee-564a-ad64-226f6682f40e', NULL, '2022-06-01', '2023-06-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('38f7a504-71b6-5c93-9fd0-41656e619040', 'c6ad9b62-ec86-53f5-a4b6-013a6d736cf5', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('38f7a504-71b6-5c93-9fd0-41656e619040', 'dcefdf4f-1512-5d96-a686-9b9eaa872107', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('38f7a504-71b6-5c93-9fd0-41656e619040', '5f3b9485-2080-5683-9698-3fa3409761fb', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 19: CNT-2023-1018 (Brand eenvoudig)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('8b30a3ac-f23c-5a04-8884-b3320e8cbe02', N'CNT-2023-1018', N'BRAND_EENVOUDIG', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'IN_WIJZIGING', '35cbc940-709f-5dcd-87d1-dbea18ae6df5', '8f91a8dc-2d6e-5605-a8b2-475edb225110', '2023-07-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('8b30a3ac-f23c-5a04-8884-b3320e8cbe02', 'e70a286c-911f-5e09-b03c-0931a765f2f7', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('8b30a3ac-f23c-5a04-8884-b3320e8cbe02', '5f3b9485-2080-5683-9698-3fa3409761fb', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('8b30a3ac-f23c-5a04-8884-b3320e8cbe02', '8d527865-8882-5b4d-b43c-728aeac75130', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 20: CNT-2024-1019 (Brand eenvoudig)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('39dfad21-e1c0-54ac-9da9-cb7714f7860b', N'CNT-2024-1019', N'BRAND_EENVOUDIG', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'NIE_ACTIEF', '239bb32c-b140-5d5b-9768-29f706468de6', NULL, '2024-08-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('39dfad21-e1c0-54ac-9da9-cb7714f7860b', '2967832c-6861-5b2e-90bd-7601cade376f', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('39dfad21-e1c0-54ac-9da9-cb7714f7860b', '8d527865-8882-5b4d-b43c-728aeac75130', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 21: CNT-2020-1020 (Brand eenvoudig)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('53abdc1a-66f2-5abb-947f-7b49af80c106', N'CNT-2020-1020', N'BRAND_EENVOUDIG', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'LOPEND', '742f978f-ae20-5b80-b224-719d7f076027', NULL, '2020-09-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('53abdc1a-66f2-5abb-947f-7b49af80c106', 'e094bb9e-83a3-5264-9a36-5feb477fe2b4', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('53abdc1a-66f2-5abb-947f-7b49af80c106', '615f71fb-69d4-55c3-b981-1d6b4d2f5a13', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('53abdc1a-66f2-5abb-947f-7b49af80c106', 'b3d11086-792f-522f-885b-08104b53e591', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 22: CNT-2021-1021 (Brand eenvoudig)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('2a8146f0-4ee1-51cc-8401-f83e62f3dcef', N'CNT-2021-1021', N'BRAND_EENVOUDIG', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'GESCHORST', '797f738f-8c2c-53fa-bd88-19ab6154c655', '85ec606f-d619-5391-beed-8a9112d1147b', '2021-10-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('2a8146f0-4ee1-51cc-8401-f83e62f3dcef', '7ca7f3fb-f978-5ca7-ac09-18c47085b64f', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('2a8146f0-4ee1-51cc-8401-f83e62f3dcef', 'b3d11086-792f-522f-885b-08104b53e591', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('2a8146f0-4ee1-51cc-8401-f83e62f3dcef', 'b75600bb-8343-5a0c-914a-516fb4186231', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 23: CNT-2022-1022 (Brand eenvoudig)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('e359fe95-8609-5315-ae75-957203219749', N'CNT-2022-1022', N'BRAND_EENVOUDIG', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'OPGEZEGD', 'd1253b8e-1b5f-5a1c-8e3d-16effd1beb47', NULL, '2022-11-01', '2023-11-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('e359fe95-8609-5315-ae75-957203219749', '54380520-048a-553e-9b82-c25ea502a113', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('e359fe95-8609-5315-ae75-957203219749', 'b75600bb-8343-5a0c-914a-516fb4186231', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('e359fe95-8609-5315-ae75-957203219749', '76942766-06cc-5cfa-a65d-4b57a4dfdb91', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 24: CNT-2023-1023 (Brand eenvoudig)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('501069d6-c67f-5011-9249-b2b3ac02101a', N'CNT-2023-1023', N'BRAND_EENVOUDIG', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'IN_WIJZIGING', '41ff067a-5982-5dde-beb9-ca35ccbe3109', NULL, '2023-12-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('501069d6-c67f-5011-9249-b2b3ac02101a', 'acbb80cd-970f-54be-807c-3acece52e150', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('501069d6-c67f-5011-9249-b2b3ac02101a', '76942766-06cc-5cfa-a65d-4b57a4dfdb91', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('501069d6-c67f-5011-9249-b2b3ac02101a', 'de112aea-ba63-5bc0-a737-f31865981105', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 25: CNT-2024-1024 (Brand eenvoudig)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('2f7bef18-260b-5342-9374-cdecef032bf6', N'CNT-2024-1024', N'BRAND_EENVOUDIG', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'NIE_ACTIEF', '32eaa733-aa65-5a24-a3c7-f26a5e4ac984', '95004e35-d095-591e-92b5-eddca13a68cb', '2024-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('2f7bef18-260b-5342-9374-cdecef032bf6', '10839728-a402-5e53-b47e-591900ca1d56', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('2f7bef18-260b-5342-9374-cdecef032bf6', 'de112aea-ba63-5bc0-a737-f31865981105', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('2f7bef18-260b-5342-9374-cdecef032bf6', '94bd7e5e-ddc3-5deb-bc68-57e1985d49a9', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 26: CNT-2020-1025 (Leven en beleggingen)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('b6d49391-c146-573d-b75a-ebc931fffe7f', N'CNT-2020-1025', N'LEVEN_BELEGGINGEN', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'LOPEND', 'fd24c8bc-50ee-564a-ad64-226f6682f40e', NULL, '2020-02-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('b6d49391-c146-573d-b75a-ebc931fffe7f', 'd4206c62-2be6-5450-bcd5-c43fe3463f2a', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('b6d49391-c146-573d-b75a-ebc931fffe7f', 'd6236a06-0bb1-5564-b657-65af89c82a0b', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('b6d49391-c146-573d-b75a-ebc931fffe7f', 'd241fc48-aea1-5529-9a4b-9067da989008', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 27: CNT-2021-1026 (Leven en beleggingen)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('19a4708d-89cf-5342-a302-88ac29a8bae9', N'CNT-2021-1026', N'LEVEN_BELEGGINGEN', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'GESCHORST', '35cbc940-709f-5dcd-87d1-dbea18ae6df5', NULL, '2021-03-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('19a4708d-89cf-5342-a302-88ac29a8bae9', '375d8d17-ca43-59a4-86e1-5a47fe1cfed3', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('19a4708d-89cf-5342-a302-88ac29a8bae9', 'd241fc48-aea1-5529-9a4b-9067da989008', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('19a4708d-89cf-5342-a302-88ac29a8bae9', 'e5286717-7d5b-5bfb-aa4f-1f3ad3ecfa91', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 28: CNT-2022-1027 (Leven en beleggingen)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('cc2fd84e-87f9-5d1a-af10-966f9cd561eb', N'CNT-2022-1027', N'LEVEN_BELEGGINGEN', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'OPGEZEGD', '239bb32c-b140-5d5b-9768-29f706468de6', 'dcc6cb9c-16f8-5313-b948-0d6aed21087b', '2022-04-01', '2023-04-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('cc2fd84e-87f9-5d1a-af10-966f9cd561eb', '656aa8fc-7e79-5ca1-bcbb-8a8fd46538c3', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('cc2fd84e-87f9-5d1a-af10-966f9cd561eb', 'e5286717-7d5b-5bfb-aa4f-1f3ad3ecfa91', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('cc2fd84e-87f9-5d1a-af10-966f9cd561eb', 'ff437f05-bf1b-5171-b58e-5349b6fae16e', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 29: CNT-2023-1028 (Leven en beleggingen)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('1960f2c4-00d4-5c08-b228-5a85a204d8a1', N'CNT-2023-1028', N'LEVEN_BELEGGINGEN', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'IN_WIJZIGING', '742f978f-ae20-5b80-b224-719d7f076027', NULL, '2023-05-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('1960f2c4-00d4-5c08-b228-5a85a204d8a1', 'eb00cae9-803c-5162-86c2-9e3a21ad4d4f', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('1960f2c4-00d4-5c08-b228-5a85a204d8a1', 'ff437f05-bf1b-5171-b58e-5349b6fae16e', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('1960f2c4-00d4-5c08-b228-5a85a204d8a1', 'df2750c1-b88b-5002-b829-0eae37b84374', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 30: CNT-2024-1029 (Leven en beleggingen)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('e7f30465-e7e3-5c29-a301-79694f99c295', N'CNT-2024-1029', N'LEVEN_BELEGGINGEN', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'NIE_ACTIEF', '797f738f-8c2c-53fa-bd88-19ab6154c655', NULL, '2024-06-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('e7f30465-e7e3-5c29-a301-79694f99c295', '51eb00ad-860f-586b-8f93-b076bf073683', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('e7f30465-e7e3-5c29-a301-79694f99c295', 'df2750c1-b88b-5002-b829-0eae37b84374', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 31: CNT-2020-1030 (Leven en beleggingen)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('38fa4950-4301-548e-ab23-15c354acd7c4', N'CNT-2020-1030', N'LEVEN_BELEGGINGEN', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'LOPEND', 'd1253b8e-1b5f-5a1c-8e3d-16effd1beb47', '8f91a8dc-2d6e-5605-a8b2-475edb225110', '2020-07-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('38fa4950-4301-548e-ab23-15c354acd7c4', 'b1d210cc-ae2e-551a-b0ea-32b380583aa0', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('38fa4950-4301-548e-ab23-15c354acd7c4', '87e0d31d-3151-5a15-8ea2-a5b05e7da3ff', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('38fa4950-4301-548e-ab23-15c354acd7c4', 'a5e9807b-33ad-54c4-a629-ba644a8375f9', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 32: CNT-2021-1031 (Leven en beleggingen)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('13e916bf-5aff-55db-81f3-d0b56dafa713', N'CNT-2021-1031', N'LEVEN_BELEGGINGEN', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'GESCHORST', '41ff067a-5982-5dde-beb9-ca35ccbe3109', NULL, '2021-08-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('13e916bf-5aff-55db-81f3-d0b56dafa713', 'a9c72bff-21c7-514d-afe4-d90b7fd0734c', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('13e916bf-5aff-55db-81f3-d0b56dafa713', 'a5e9807b-33ad-54c4-a629-ba644a8375f9', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('13e916bf-5aff-55db-81f3-d0b56dafa713', '8b5c8c98-6f1e-51a2-8eac-beea56efa9b0', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 33: CNT-2022-1032 (Leven en beleggingen)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('4b0612ff-eba5-5726-8264-d7a7bfd4454d', N'CNT-2022-1032', N'LEVEN_BELEGGINGEN', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'OPGEZEGD', '32eaa733-aa65-5a24-a3c7-f26a5e4ac984', NULL, '2022-09-01', '2023-09-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('4b0612ff-eba5-5726-8264-d7a7bfd4454d', '94d4279a-d4bc-546b-8483-62b3d48fadc9', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('4b0612ff-eba5-5726-8264-d7a7bfd4454d', '8b5c8c98-6f1e-51a2-8eac-beea56efa9b0', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('4b0612ff-eba5-5726-8264-d7a7bfd4454d', 'e91796d3-b49f-525b-80ab-7d1b79fb70ae', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 34: CNT-2023-1033 (Hospitalisatie)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('637eb614-c26a-5731-b9dc-94b952fe688b', N'CNT-2023-1033', N'HOSPITALISATIE', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'IN_WIJZIGING', 'fd24c8bc-50ee-564a-ad64-226f6682f40e', '85ec606f-d619-5391-beed-8a9112d1147b', '2023-10-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('637eb614-c26a-5731-b9dc-94b952fe688b', 'e9fa3f32-8a88-58f7-aa16-19c078b73812', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('637eb614-c26a-5731-b9dc-94b952fe688b', '37a236da-893a-5235-8011-505c0eb996d9', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('637eb614-c26a-5731-b9dc-94b952fe688b', '28ccd192-1129-5fef-83cb-efa5d333eaff', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 35: CNT-2024-1034 (Hospitalisatie)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('86b8279a-865f-57f2-a8fd-1bcd753f52fc', N'CNT-2024-1034', N'HOSPITALISATIE', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'NIE_ACTIEF', '35cbc940-709f-5dcd-87d1-dbea18ae6df5', NULL, '2024-11-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('86b8279a-865f-57f2-a8fd-1bcd753f52fc', '5aa15f2f-d6e3-5834-9b99-ce48aab774c2', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('86b8279a-865f-57f2-a8fd-1bcd753f52fc', '28ccd192-1129-5fef-83cb-efa5d333eaff', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('86b8279a-865f-57f2-a8fd-1bcd753f52fc', '971d6a4c-f3d0-5bd2-bc1b-ddfd950c5ed8', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 36: CNT-2020-1035 (Hospitalisatie)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('f0729a78-7b51-5016-ae49-40a9840f7294', N'CNT-2020-1035', N'HOSPITALISATIE', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'LOPEND', '239bb32c-b140-5d5b-9768-29f706468de6', NULL, '2020-12-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('f0729a78-7b51-5016-ae49-40a9840f7294', 'e162f9ae-c21f-5642-99c5-9a9ac7fe0ffa', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('f0729a78-7b51-5016-ae49-40a9840f7294', '971d6a4c-f3d0-5bd2-bc1b-ddfd950c5ed8', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('f0729a78-7b51-5016-ae49-40a9840f7294', 'd1b113c8-4616-54e2-9e03-99a1a7c02634', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 37: CNT-2021-1036 (Hospitalisatie)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('48ae0731-c3e4-5fb8-acc4-b652407aa7cc', N'CNT-2021-1036', N'HOSPITALISATIE', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'GESCHORST', '742f978f-ae20-5b80-b224-719d7f076027', '95004e35-d095-591e-92b5-eddca13a68cb', '2021-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('48ae0731-c3e4-5fb8-acc4-b652407aa7cc', '7e25fdf9-3052-52e7-8753-d64356fdade7', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('48ae0731-c3e4-5fb8-acc4-b652407aa7cc', 'd1b113c8-4616-54e2-9e03-99a1a7c02634', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('48ae0731-c3e4-5fb8-acc4-b652407aa7cc', 'c84b5445-2f5f-531c-b453-9fa5643171df', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 38: CNT-2022-1037 (Hospitalisatie)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('4d1dbeb7-3e1f-5816-b473-73edd969cb8d', N'CNT-2022-1037', N'HOSPITALISATIE', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'OPGEZEGD', '797f738f-8c2c-53fa-bd88-19ab6154c655', NULL, '2022-02-01', '2023-02-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('4d1dbeb7-3e1f-5816-b473-73edd969cb8d', '3ecbc905-9da6-5b0b-9f39-dc903be90d58', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('4d1dbeb7-3e1f-5816-b473-73edd969cb8d', 'c84b5445-2f5f-531c-b453-9fa5643171df', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('4d1dbeb7-3e1f-5816-b473-73edd969cb8d', '93dc469c-49d3-5492-a1cb-923a09c1d49d', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 39: CNT-2023-1038 (Arbeidsongevallen collectief)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('c41bef0c-26ce-52ce-a427-0069bb418a23', N'CNT-2023-1038', N'ARBEIDSONGEVALLEN_COLLECTIEF', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'IN_WIJZIGING', 'd1253b8e-1b5f-5a1c-8e3d-16effd1beb47', NULL, '2023-03-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('c41bef0c-26ce-52ce-a427-0069bb418a23', '12ea6164-808c-5aa4-ab79-956ddd949d5e', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('c41bef0c-26ce-52ce-a427-0069bb418a23', 'b76ff5de-bc8c-5a03-9959-b63b664ce80c', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('c41bef0c-26ce-52ce-a427-0069bb418a23', 'b62fe2e6-d51c-5479-a726-87c9f762e6ef', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 40: CNT-2024-1039 (Arbeidsongevallen collectief)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('df374090-93cf-5522-9087-7a723f7c860f', N'CNT-2024-1039', N'ARBEIDSONGEVALLEN_COLLECTIEF', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'NIE_ACTIEF', '41ff067a-5982-5dde-beb9-ca35ccbe3109', 'dcc6cb9c-16f8-5313-b948-0d6aed21087b', '2024-04-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('df374090-93cf-5522-9087-7a723f7c860f', 'cf9fe55e-fcdd-553e-8bc7-f1e799743ce5', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('df374090-93cf-5522-9087-7a723f7c860f', 'b62fe2e6-d51c-5479-a726-87c9f762e6ef', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 41: CNT-2020-1040 (Arbeidsongevallen collectief)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('7884f8f3-4cbd-5204-9754-062e2f276fba', N'CNT-2020-1040', N'ARBEIDSONGEVALLEN_COLLECTIEF', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'LOPEND', '32eaa733-aa65-5a24-a3c7-f26a5e4ac984', NULL, '2020-05-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('7884f8f3-4cbd-5204-9754-062e2f276fba', '88275840-7a64-5c38-91b3-167e286f560d', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('7884f8f3-4cbd-5204-9754-062e2f276fba', 'e249f6f9-1d6b-53d1-a3e3-052c8b709dea', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('7884f8f3-4cbd-5204-9754-062e2f276fba', '4fe5335f-eec7-5a1d-8377-0ccb8709cf20', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 42: CNT-2021-1041 (Arbeidsongevallen collectief)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('55c63871-034f-53eb-82f4-3c186b9938b1', N'CNT-2021-1041', N'ARBEIDSONGEVALLEN_COLLECTIEF', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'GESCHORST', 'fd24c8bc-50ee-564a-ad64-226f6682f40e', NULL, '2021-06-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('55c63871-034f-53eb-82f4-3c186b9938b1', 'abeaecc5-308d-5d45-9eb1-21caed5274ff', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('55c63871-034f-53eb-82f4-3c186b9938b1', '4fe5335f-eec7-5a1d-8377-0ccb8709cf20', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('55c63871-034f-53eb-82f4-3c186b9938b1', 'f391531d-3f8f-538c-a209-1658b489bbb7', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 43: CNT-2022-1042 (Arbeidsongevallen collectief)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('1c8697f8-ea99-5526-ac70-40efb111755c', N'CNT-2022-1042', N'ARBEIDSONGEVALLEN_COLLECTIEF', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'OPGEZEGD', '35cbc940-709f-5dcd-87d1-dbea18ae6df5', '8f91a8dc-2d6e-5605-a8b2-475edb225110', '2022-07-01', '2023-07-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('1c8697f8-ea99-5526-ac70-40efb111755c', 'e77a50fb-c6c7-5c28-aaeb-b64672bd3a88', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('1c8697f8-ea99-5526-ac70-40efb111755c', 'f391531d-3f8f-538c-a209-1658b489bbb7', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('1c8697f8-ea99-5526-ac70-40efb111755c', 'bd5262f3-1efe-5f38-9ebd-63a2fa369b81', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 44: CNT-2023-1043 (Rechtsbijstand)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('e6750d87-9817-5fe4-b5e6-a2e4f0317a17', N'CNT-2023-1043', N'RECHTSBIJSTAND', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'IN_WIJZIGING', '239bb32c-b140-5d5b-9768-29f706468de6', NULL, '2023-08-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('e6750d87-9817-5fe4-b5e6-a2e4f0317a17', 'ecbb77f5-a7db-558a-b13a-42fd2094023e', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('e6750d87-9817-5fe4-b5e6-a2e4f0317a17', '4e4bc4f2-ee4f-568a-958b-2ae5e9ba2536', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('e6750d87-9817-5fe4-b5e6-a2e4f0317a17', '806ad90f-fbde-53ff-8b75-7de469399de6', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 45: CNT-2024-1044 (Rechtsbijstand)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('719dc3be-2dbb-592d-b587-fcd1aa663cb7', N'CNT-2024-1044', N'RECHTSBIJSTAND', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'NIE_ACTIEF', '742f978f-ae20-5b80-b224-719d7f076027', NULL, '2024-09-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('719dc3be-2dbb-592d-b587-fcd1aa663cb7', 'e32a64f6-c0df-580e-bbd4-18dca5aa25cb', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('719dc3be-2dbb-592d-b587-fcd1aa663cb7', '806ad90f-fbde-53ff-8b75-7de469399de6', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('719dc3be-2dbb-592d-b587-fcd1aa663cb7', 'f97da18f-a51b-5ead-9b4d-291be9fc82a6', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 46: CNT-2020-1045 (Rechtsbijstand)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('579ab4de-2895-5567-adc3-54d0fb8596d8', N'CNT-2020-1045', N'RECHTSBIJSTAND', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'LOPEND', '797f738f-8c2c-53fa-bd88-19ab6154c655', '85ec606f-d619-5391-beed-8a9112d1147b', '2020-10-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('579ab4de-2895-5567-adc3-54d0fb8596d8', 'e881e046-e826-5fdf-aee9-d7ef20db2171', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('579ab4de-2895-5567-adc3-54d0fb8596d8', 'f97da18f-a51b-5ead-9b4d-291be9fc82a6', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('579ab4de-2895-5567-adc3-54d0fb8596d8', '299f4bb7-59a7-5e38-b095-c8c908a6931c', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 47: CNT-2021-1046 (Rechtsbijstand)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('64d6871d-e3d2-5872-a913-8675f942f5c3', N'CNT-2021-1046', N'RECHTSBIJSTAND', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'GESCHORST', 'd1253b8e-1b5f-5a1c-8e3d-16effd1beb47', NULL, '2021-11-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('64d6871d-e3d2-5872-a913-8675f942f5c3', '1b0efd79-d7eb-5f8a-bad6-66c8d683363c', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('64d6871d-e3d2-5872-a913-8675f942f5c3', '299f4bb7-59a7-5e38-b095-c8c908a6931c', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('64d6871d-e3d2-5872-a913-8675f942f5c3', 'fbb5d528-e3ae-5579-8a29-b0c8de0ea628', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 48: CNT-2022-1047 (Diversen)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('2c475f50-deac-5b7b-a666-f7269fca9cb6', N'CNT-2022-1047', N'DIVERSEN', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'OPGEZEGD', '41ff067a-5982-5dde-beb9-ca35ccbe3109', NULL, '2022-12-01', '2023-12-01', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('2c475f50-deac-5b7b-a666-f7269fca9cb6', '686d7d6b-464a-5c2e-983b-467383404638', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('2c475f50-deac-5b7b-a666-f7269fca9cb6', 'cddfbce9-a943-5705-862a-e692cc7475d0', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('2c475f50-deac-5b7b-a666-f7269fca9cb6', '37a236da-893a-5235-8011-505c0eb996d9', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 49: CNT-2023-1048 (Diversen)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('4f4cfd5a-9df3-5e4b-8294-9cb2ca4d4924', N'CNT-2023-1048', N'DIVERSEN', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'IN_WIJZIGING', '32eaa733-aa65-5a24-a3c7-f26a5e4ac984', '95004e35-d095-591e-92b5-eddca13a68cb', '2023-01-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('4f4cfd5a-9df3-5e4b-8294-9cb2ca4d4924', 'af92e0ba-9be1-5452-ac95-69f85d04ad74', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('4f4cfd5a-9df3-5e4b-8294-9cb2ca4d4924', '37a236da-893a-5235-8011-505c0eb996d9', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('4f4cfd5a-9df3-5e4b-8294-9cb2ca4d4924', '28ccd192-1129-5fef-83cb-efa5d333eaff', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Contract 50: CNT-2024-1049 (Diversen)
INSERT INTO Contract (contract_id, contract_number, contract_domain_code, contract_type_code, contract_status_code, company_id, handling_company_id, start_date, end_date, created_at, updated_at)
VALUES ('822c1f41-33bf-5e2d-bdc8-6efe1e22f01d', N'CNT-2024-1049', N'DIVERSEN', N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK', N'NIE_ACTIEF', 'fd24c8bc-50ee-564a-ad64-226f6682f40e', NULL, '2024-02-01', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Party (contract_id, person_id, contract_party_role_code, is_primary, created_at)
VALUES ('822c1f41-33bf-5e2d-bdc8-6efe1e22f01d', '356e6f20-40fd-5f52-8c7c-a7f81d3f1990', 'POLICYHOLDER', 1, SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('822c1f41-33bf-5e2d-bdc8-6efe1e22f01d', '28ccd192-1129-5fef-83cb-efa5d333eaff', 'ACTIVE', 1, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Contract_Object (contract_id, object_id, contract_object_status_code, is_primary, to_date, created_at, updated_at)
VALUES ('822c1f41-33bf-5e2d-bdc8-6efe1e22f01d', '971d6a4c-f3d0-5bd2-bc1b-ddfd950c5ed8', 'ACTIVE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

PRINT '50 contracten ingevoegd.';
GO

-- =============================================================
-- J. 25 Schadeclaims
-- 10 Aanrijding, 5 Brandschade, 4 Diefstal,
-- 3 Waterschade, 3 Glasbreuk
-- =============================================================

-- Claim 1: CLM-2024-5000 - Aanrijding
-- Status: Ingediend
-- Incident: 05/01/2023, Gemeld: 07/01/2023
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('62f6874e-e111-539b-8bf5-c39d38cf8fb7', N'CLM-2024-5000', '9bd88578-ff20-50f1-87ec-24569c4eca21', N'AANRAKING_VOERTUIGEN', N'INGEDIEND', '2023-01-05', '2023-01-07', NULL, N'AANRIJDING - VERKEERSONGEVAL', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('62f6874e-e111-539b-8bf5-c39d38cf8fb7', '219711d4-f1e9-5b7c-84bc-490a41110884', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('62f6874e-e111-539b-8bf5-c39d38cf8fb7', '558570a8-3cea-5fc8-abba-8d4defa4d822', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('62f6874e-e111-539b-8bf5-c39d38cf8fb7', N'VERKEERSONGEVAL', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Claim 2: CLM-2024-5001 - Aanrijding
-- Status: In behandeling
-- Incident: 06/02/2024, Gemeld: 08/02/2024
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('c0eb8ce7-6947-5bf7-b9d4-674e5f411931', N'CLM-2024-5001', '26b69ff1-94a5-590d-9cfe-a821cc88a92f', N'AANRAKING_VOERTUIGEN', N'IN_BEHANDELING', '2024-02-06', '2024-02-08', NULL, N'AANRIJDING - KETTINGBOTSING', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('c0eb8ce7-6947-5bf7-b9d4-674e5f411931', '7268581b-0dbd-52b1-b752-40aebb63d0a5', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('c0eb8ce7-6947-5bf7-b9d4-674e5f411931', '6b294aa4-eba1-5957-b452-c46cfcd080fd', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('c0eb8ce7-6947-5bf7-b9d4-674e5f411931', N'KETTINGBOTSING', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Claim 3: CLM-2024-5002 - Aanrijding
-- Status: Afgehandeld
-- Incident: 07/03/2023, Gemeld: 09/03/2023
-- Uitbetaald: 700.00 EUR
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('460ddd3f-a4b7-5021-a886-23fdc78ee3b9', N'CLM-2024-5002', '567782bb-e9b9-5d2f-a83b-4f5aaca39557', N'AANRAKING_VOERTUIGEN', N'AFGEHANDELD', '2023-03-07', '2023-03-09', '2023-04-07', N'AANRIJDING - TEGENPARTIJ_BOTST_OP_ACHTERZIJDE_VAN_VERZEKERDE', 700, N'CHEQUE', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('460ddd3f-a4b7-5021-a886-23fdc78ee3b9', '767455ff-6716-57b8-8b1b-07625f980552', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('460ddd3f-a4b7-5021-a886-23fdc78ee3b9', '91d71aba-820f-57c3-b8b9-eaab0fd65fbf', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('460ddd3f-a4b7-5021-a886-23fdc78ee3b9', N'TEGENPARTIJ_BOTST_OP_ACHTERZIJDE_VAN_VERZEKERDE', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Claim 4: CLM-2024-5003 - Aanrijding
-- Status: Geweigerd
-- Incident: 08/04/2024, Gemeld: 10/04/2024
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('91afbb13-52b8-5d7d-85d8-6c9cf1ca8b7a', N'CLM-2024-5003', '79c4c636-42d3-5539-9f02-8fe1b33e78ef', N'AANRAKING_VOERTUIGEN', N'GEWEIGERD', '2024-04-08', '2024-04-10', '2024-05-08', N'AANRIJDING - VERZEKERDE_RIJDT_VASTE_HINDERNIS_AAN', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('91afbb13-52b8-5d7d-85d8-6c9cf1ca8b7a', '6ef2fb59-c4d6-509d-82b7-86ba6954d512', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('91afbb13-52b8-5d7d-85d8-6c9cf1ca8b7a', '4e4bc4f2-ee4f-568a-958b-2ae5e9ba2536', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('91afbb13-52b8-5d7d-85d8-6c9cf1ca8b7a', N'VERZEKERDE_RIJDT_VASTE_HINDERNIS_AAN', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Claim 5: CLM-2024-5004 - Aanrijding
-- Status: Ingediend
-- Incident: 09/05/2023, Gemeld: 11/05/2023
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('c2b760b6-e9f8-5822-b0ce-153d8210120a', N'CLM-2024-5004', '7f4d66d3-5564-54f5-920f-bdbf1332f7ac', N'AANRAKING_VOERTUIGEN', N'INGEDIEND', '2023-05-09', '2023-05-11', NULL, N'AANRIJDING - TEGENPARTIJ_SNIJDT_AF_VAN_DE_VERZEKERDE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('c2b760b6-e9f8-5822-b0ce-153d8210120a', 'f2ebd19a-69e8-50cc-bc6f-290e94deb79a', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('c2b760b6-e9f8-5822-b0ce-153d8210120a', '806ad90f-fbde-53ff-8b75-7de469399de6', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('c2b760b6-e9f8-5822-b0ce-153d8210120a', N'TEGENPARTIJ_SNIJDT_AF_VAN_DE_VERZEKERDE', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Claim 6: CLM-2024-5005 - Aanrijding
-- Status: In behandeling
-- Incident: 10/06/2024, Gemeld: 12/06/2024
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('f31356f6-181b-5525-be0d-bc3c33073835', N'CLM-2024-5005', 'afa51f46-aa03-5d3c-84fe-d4caff90e8e7', N'AANRAKING_VOERTUIGEN', N'IN_BEHANDELING', '2024-06-10', '2024-06-12', NULL, N'AANRIJDING - DUBBEL_MANOEUVRE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('f31356f6-181b-5525-be0d-bc3c33073835', '8dbcaf2e-12f0-51a4-ac0d-1e65bd18488a', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('f31356f6-181b-5525-be0d-bc3c33073835', 'f97da18f-a51b-5ead-9b4d-291be9fc82a6', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('f31356f6-181b-5525-be0d-bc3c33073835', N'DUBBEL_MANOEUVRE', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Claim 7: CLM-2024-5006 - Aanrijding
-- Status: Afgehandeld
-- Incident: 11/07/2023, Gemeld: 13/07/2023
-- Uitbetaald: 1,100.00 EUR
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('a004eb08-3039-5a39-9a93-8880088da29c', N'CLM-2024-5006', '5a27c7eb-59cd-59d9-8d13-8871b698011b', N'AANRAKING_VOERTUIGEN', N'AFGEHANDELD', '2023-07-11', '2023-07-13', '2023-08-11', N'AANRIJDING - OP_2_RIJSTROKEN_DOET_VERZEKERDE_MANOEUVRE', 1100, N'BANK_TRANSFER', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('a004eb08-3039-5a39-9a93-8880088da29c', 'd421bbf2-d9ea-5c6c-94e1-822811b8482f', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('a004eb08-3039-5a39-9a93-8880088da29c', '299f4bb7-59a7-5e38-b095-c8c908a6931c', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('a004eb08-3039-5a39-9a93-8880088da29c', N'OP_2_RIJSTROKEN_DOET_VERZEKERDE_MANOEUVRE', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Claim 8: CLM-2024-5007 - Aanrijding
-- Status: Geweigerd
-- Incident: 12/08/2024, Gemeld: 14/08/2024
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('dc38544f-ef20-5486-b670-8c0da306512c', N'CLM-2024-5007', '7d77bd60-07e9-592b-a0d3-83a58e0d76e0', N'AANRAKING_VOERTUIGEN', N'GEWEIGERD', '2024-08-12', '2024-08-14', '2024-09-12', N'AANRIJDING - MANOEUVRE_ENKEL_DOOR_VERZEKERDE_UITGEVOERD', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('dc38544f-ef20-5486-b670-8c0da306512c', 'c54ae5ab-b164-5d26-ab0e-1226a794ba00', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('dc38544f-ef20-5486-b670-8c0da306512c', 'fbb5d528-e3ae-5579-8a29-b0c8de0ea628', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('dc38544f-ef20-5486-b670-8c0da306512c', N'MANOEUVRE_ENKEL_DOOR_VERZEKERDE_UITGEVOERD', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Claim 9: CLM-2024-5008 - Aanrijding
-- Status: Ingediend
-- Incident: 13/09/2023, Gemeld: 15/09/2023
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('6032aedd-6cf4-58ac-b9d7-7dcf98c88b58', N'CLM-2024-5008', '0a2b4116-728f-5fcb-856a-f9aebd1b4053', N'AANRAKING_VOERTUIGEN', N'INGEDIEND', '2023-09-13', '2023-09-15', NULL, N'AANRIJDING - VALPARTIJ', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('6032aedd-6cf4-58ac-b9d7-7dcf98c88b58', '2918c7dc-bf8a-5adf-a342-2f427ea33ad2', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('6032aedd-6cf4-58ac-b9d7-7dcf98c88b58', '10218115-9b35-552d-8b7d-19f8a2649c5d', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('6032aedd-6cf4-58ac-b9d7-7dcf98c88b58', N'VALPARTIJ', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Claim 10: CLM-2024-5009 - Aanrijding
-- Status: In behandeling
-- Incident: 14/10/2024, Gemeld: 16/10/2024
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('003ce029-1bdf-5ba3-961a-c5196d4f626b', N'CLM-2024-5009', '23d7848e-7bf7-5431-b154-6999759ff3f5', N'AANRAKING_VOERTUIGEN', N'IN_BEHANDELING', '2024-10-14', '2024-10-16', NULL, N'AANRIJDING - SCHADE_AAN_DERDEN', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('003ce029-1bdf-5ba3-961a-c5196d4f626b', '06d5be89-2291-5bb5-9a22-906efcffbfca', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('003ce029-1bdf-5ba3-961a-c5196d4f626b', '16a7a99b-0ec4-51e5-888a-f2a9232b4785', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('003ce029-1bdf-5ba3-961a-c5196d4f626b', N'SCHADE_AAN_DERDEN', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Claim 11: CLM-2024-5010 - Brandschade
-- Status: Afgehandeld
-- Incident: 15/11/2023, Gemeld: 17/11/2023
-- Uitbetaald: 1,500.00 EUR
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('ac3792f9-8c24-5296-9c26-0725dca131cc', N'CLM-2024-5010', '26c26abf-e932-5d49-ae97-8c656011a98a', N'BRAND_ALGEMEEN', N'AFGEHANDELD', '2023-11-15', '2023-11-17', '2023-12-15', N'BRANDSCHADE - BRAND', 1500, N'CASH', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('ac3792f9-8c24-5296-9c26-0725dca131cc', '5485d4fb-5fe5-5d99-bddd-cd9ca895e3e7', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('ac3792f9-8c24-5296-9c26-0725dca131cc', '8fd3e52e-3b42-5baf-8d15-4a2b4b6d783a', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('ac3792f9-8c24-5296-9c26-0725dca131cc', N'BRAND', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Claim 12: CLM-2024-5011 - Brandschade
-- Status: Geweigerd
-- Incident: 16/12/2024, Gemeld: 18/12/2024
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('1bc5b4e6-4456-5907-92fd-6b7b2c6db721', N'CLM-2024-5011', 'ce94b359-72bb-5f98-b7a7-572c00905c28', N'BRAND_ALGEMEEN', N'GEWEIGERD', '2024-12-16', '2024-12-18', '2025-01-16', N'BRANDSCHADE - SCHOORSTEENBRAND', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('1bc5b4e6-4456-5907-92fd-6b7b2c6db721', '0f0f2938-e0e5-5dd6-aac5-f9c21720495d', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('1bc5b4e6-4456-5907-92fd-6b7b2c6db721', '0e3da740-b6c5-5fee-87bd-db8ef5987af7', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('1bc5b4e6-4456-5907-92fd-6b7b2c6db721', N'SCHOORSTEENBRAND', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Claim 13: CLM-2024-5012 - Brandschade
-- Status: Ingediend
-- Incident: 17/01/2023, Gemeld: 19/01/2023
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('84504943-501f-599f-b9c6-45b4ac437c97', N'CLM-2024-5012', '5c531e71-3553-576a-8819-a952c3831ff3', N'BRAND_ALGEMEEN', N'INGEDIEND', '2023-01-17', '2023-01-19', NULL, N'BRANDSCHADE - ZELFONTBRANDING', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('84504943-501f-599f-b9c6-45b4ac437c97', '31572584-1fed-582a-9c35-e4c7812029e6', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('84504943-501f-599f-b9c6-45b4ac437c97', '0596830f-5f5c-5724-9387-4f6eb0b1b081', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('84504943-501f-599f-b9c6-45b4ac437c97', N'ZELFONTBRANDING', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Claim 14: CLM-2024-5013 - Brandschade
-- Status: In behandeling
-- Incident: 18/02/2024, Gemeld: 20/02/2024
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('803b3764-addf-556c-a14a-1dbd07cbfeb1', N'CLM-2024-5013', 'e58d5d12-3a2a-54fa-8548-06d6e6b46d05', N'BRAND_ALGEMEEN', N'IN_BEHANDELING', '2024-02-18', '2024-02-20', NULL, N'BRANDSCHADE - ELEKTRICITEIT_KORTSLUITING', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('803b3764-addf-556c-a14a-1dbd07cbfeb1', '255fbd61-4611-58f5-8a9d-5a1d9d900509', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('803b3764-addf-556c-a14a-1dbd07cbfeb1', 'ec766974-349a-5cd1-b49f-1604f8ba1485', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('803b3764-addf-556c-a14a-1dbd07cbfeb1', N'ELEKTRICITEIT_KORTSLUITING', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Claim 15: CLM-2024-5014 - Brandschade
-- Status: Afgehandeld
-- Incident: 19/03/2023, Gemeld: 21/03/2023
-- Uitbetaald: 1,900.00 EUR
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('0b905fe7-4995-5357-91b8-9503d3c626d3', N'CLM-2024-5014', 'ee370942-43bd-5119-805c-db8214a75fa5', N'BRAND_ALGEMEEN', N'AFGEHANDELD', '2023-03-19', '2023-03-21', '2023-04-19', N'BRANDSCHADE - EXPLOSIE', 1900, N'CHEQUE', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('0b905fe7-4995-5357-91b8-9503d3c626d3', 'ece43643-6bf6-5ba3-aa12-86b4e6f28c98', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('0b905fe7-4995-5357-91b8-9503d3c626d3', '8bd19ed5-024a-5885-9283-d4ca74b626d6', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('0b905fe7-4995-5357-91b8-9503d3c626d3', N'EXPLOSIE', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Claim 16: CLM-2024-5015 - Diefstal
-- Status: Geweigerd
-- Incident: 20/04/2024, Gemeld: 22/04/2024
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('16d5b15f-1b69-5b1b-853e-fc6ebafeb2ec', N'CLM-2024-5015', 'b27af111-a480-5a90-867b-d94b6276e206', N'DIEFSTAL', N'GEWEIGERD', '2024-04-20', '2024-04-22', '2024-05-20', N'DIEFSTAL - DIEFSTAL_MET_GEWELD', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('16d5b15f-1b69-5b1b-853e-fc6ebafeb2ec', 'a457648d-1590-5e2f-b8bf-a23785c04f64', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('16d5b15f-1b69-5b1b-853e-fc6ebafeb2ec', '4a619506-7899-5192-848f-61ad7619dc1f', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('16d5b15f-1b69-5b1b-853e-fc6ebafeb2ec', N'DIEFSTAL_MET_GEWELD', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Claim 17: CLM-2024-5016 - Diefstal
-- Status: Ingediend
-- Incident: 21/05/2023, Gemeld: 23/05/2023
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('b8da5141-78f5-550e-a774-16d89f76218b', N'CLM-2024-5016', '01a6fb3c-ea6c-559a-be42-cf0626645e29', N'DIEFSTAL', N'INGEDIEND', '2023-05-21', '2023-05-23', NULL, N'DIEFSTAL - DIEFSTAL', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('b8da5141-78f5-550e-a774-16d89f76218b', 'e2f6b781-f674-5f9d-8b42-126c1bee3960', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('b8da5141-78f5-550e-a774-16d89f76218b', '0dbf8fa0-50ba-548d-a74c-f383e8269840', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('b8da5141-78f5-550e-a774-16d89f76218b', N'DIEFSTAL', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Claim 18: CLM-2024-5017 - Diefstal
-- Status: In behandeling
-- Incident: 22/06/2024, Gemeld: 24/06/2024
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('e21dbbbb-3987-5805-918f-7938f9b4a4e5', N'CLM-2024-5017', '38f7a504-71b6-5c93-9fd0-41656e619040', N'DIEFSTAL', N'IN_BEHANDELING', '2024-06-22', '2024-06-24', NULL, N'DIEFSTAL - DIEFSTAL_VOERTUIG', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('e21dbbbb-3987-5805-918f-7938f9b4a4e5', 'c6ad9b62-ec86-53f5-a4b6-013a6d736cf5', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('e21dbbbb-3987-5805-918f-7938f9b4a4e5', 'dcefdf4f-1512-5d96-a686-9b9eaa872107', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('e21dbbbb-3987-5805-918f-7938f9b4a4e5', N'DIEFSTAL_VOERTUIG', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Claim 19: CLM-2024-5018 - Diefstal
-- Status: Afgehandeld
-- Incident: 23/07/2023, Gemeld: 25/07/2023
-- Uitbetaald: 2,300.00 EUR
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('84718cdb-5eb7-598a-88b8-1b980fb3da79', N'CLM-2024-5018', '8b30a3ac-f23c-5a04-8884-b3320e8cbe02', N'DIEFSTAL', N'AFGEHANDELD', '2023-07-23', '2023-07-25', '2023-08-23', N'DIEFSTAL - INBRAAK', 2300, N'BANK_TRANSFER', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('84718cdb-5eb7-598a-88b8-1b980fb3da79', 'e70a286c-911f-5e09-b03c-0931a765f2f7', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('84718cdb-5eb7-598a-88b8-1b980fb3da79', '5f3b9485-2080-5683-9698-3fa3409761fb', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('84718cdb-5eb7-598a-88b8-1b980fb3da79', N'INBRAAK', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Claim 20: CLM-2024-5019 - Waterschade
-- Status: Geweigerd
-- Incident: 24/08/2024, Gemeld: 26/08/2024
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('9b35dccf-136a-5862-b4cc-52d8990d7fc3', N'CLM-2024-5019', '39dfad21-e1c0-54ac-9da9-cb7714f7860b', N'WATERSCHADE', N'GEWEIGERD', '2024-08-24', '2024-08-26', '2024-09-24', N'WATERSCHADE - WATERSCHADE_DOORGEGEVEN_DOOR_BUREN', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('9b35dccf-136a-5862-b4cc-52d8990d7fc3', '2967832c-6861-5b2e-90bd-7601cade376f', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('9b35dccf-136a-5862-b4cc-52d8990d7fc3', '8d527865-8882-5b4d-b43c-728aeac75130', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('9b35dccf-136a-5862-b4cc-52d8990d7fc3', N'WATERSCHADE_DOORGEGEVEN_DOOR_BUREN', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Claim 21: CLM-2024-5020 - Waterschade
-- Status: Ingediend
-- Incident: 05/09/2023, Gemeld: 07/09/2023
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('3cbf4135-bd82-5891-b160-6e2459f083b3', N'CLM-2024-5020', '53abdc1a-66f2-5abb-947f-7b49af80c106', N'WATERSCHADE', N'INGEDIEND', '2023-09-05', '2023-09-07', NULL, N'WATERSCHADE - LEIDINGBREUK', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('3cbf4135-bd82-5891-b160-6e2459f083b3', 'e094bb9e-83a3-5264-9a36-5feb477fe2b4', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('3cbf4135-bd82-5891-b160-6e2459f083b3', '615f71fb-69d4-55c3-b981-1d6b4d2f5a13', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('3cbf4135-bd82-5891-b160-6e2459f083b3', N'LEIDINGBREUK', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Claim 22: CLM-2024-5021 - Waterschade
-- Status: In behandeling
-- Incident: 06/10/2024, Gemeld: 08/10/2024
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('e054fb05-8dd8-52a8-9eb3-f0e15054a587', N'CLM-2024-5021', '2a8146f0-4ee1-51cc-8401-f83e62f3dcef', N'WATERSCHADE', N'IN_BEHANDELING', '2024-10-06', '2024-10-08', NULL, N'WATERSCHADE - WATERSCHADE', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('e054fb05-8dd8-52a8-9eb3-f0e15054a587', '7ca7f3fb-f978-5ca7-ac09-18c47085b64f', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('e054fb05-8dd8-52a8-9eb3-f0e15054a587', 'b3d11086-792f-522f-885b-08104b53e591', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('e054fb05-8dd8-52a8-9eb3-f0e15054a587', N'WATERSCHADE', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Claim 23: CLM-2024-5022 - Glasbreuk
-- Status: Afgehandeld
-- Incident: 07/11/2023, Gemeld: 09/11/2023
-- Uitbetaald: 2,700.00 EUR
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('31013809-5e6e-5fdf-aa2e-29f2a2201859', N'CLM-2024-5022', 'e359fe95-8609-5315-ae75-957203219749', N'GLASBRAAK', N'AFGEHANDELD', '2023-11-07', '2023-11-09', '2023-12-07', N'GLASBREUK - GLASBRAAK_VANDALISME', 2700, N'CASH', SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('31013809-5e6e-5fdf-aa2e-29f2a2201859', '54380520-048a-553e-9b82-c25ea502a113', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('31013809-5e6e-5fdf-aa2e-29f2a2201859', 'b75600bb-8343-5a0c-914a-516fb4186231', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('31013809-5e6e-5fdf-aa2e-29f2a2201859', N'GLASBRAAK_VANDALISME', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Claim 24: CLM-2024-5023 - Glasbreuk
-- Status: Geweigerd
-- Incident: 08/12/2024, Gemeld: 10/12/2024
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('10e3471d-b278-524c-8e68-ce9ad0b0aef6', N'CLM-2024-5023', '501069d6-c67f-5011-9249-b2b3ac02101a', N'GLASBRAAK', N'GEWEIGERD', '2024-12-08', '2024-12-10', '2025-01-08', N'GLASBREUK - PROJECTIE_BESCHADIGD_WEGDEK', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('10e3471d-b278-524c-8e68-ce9ad0b0aef6', 'acbb80cd-970f-54be-807c-3acece52e150', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('10e3471d-b278-524c-8e68-ce9ad0b0aef6', '76942766-06cc-5cfa-a65d-4b57a4dfdb91', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('10e3471d-b278-524c-8e68-ce9ad0b0aef6', N'PROJECTIE_BESCHADIGD_WEGDEK', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

-- Claim 25: CLM-2024-5024 - Glasbreuk
-- Status: Ingediend
-- Incident: 09/01/2023, Gemeld: 11/01/2023
INSERT INTO Claim (claim_id, claim_number, contract_id, coverage_code, claim_status_code, incident_date, reported_date, closed_date, description, paid_amount, payment_method_code, created_at, updated_at)
VALUES ('38333caa-55b9-533e-913d-cfadda431549', N'CLM-2024-5024', '2f7bef18-260b-5342-9374-cdecef032bf6', N'GLASBRAAK', N'INGEDIEND', '2023-01-09', '2023-01-11', NULL, N'GLASBREUK - GLASBRAAK', 0, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Party (claim_id, person_id, claim_party_role_code, is_primary, created_at)
VALUES ('38333caa-55b9-533e-913d-cfadda431549', '10839728-a402-5e53-b47e-591900ca1d56', 'INSURED', 1, SYSUTCDATETIME());
INSERT INTO Claim_Object (claim_id, object_id, is_primary, created_at, updated_at)
VALUES ('38333caa-55b9-533e-913d-cfadda431549', 'de112aea-ba63-5bc0-a737-f31865981105', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO Claim_Circumstance (claim_id, claim_circumstance_type_code, is_primary, created_at, updated_at)
VALUES ('38333caa-55b9-533e-913d-cfadda431549', N'GLASBRAAK', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

PRINT '25 schadeclaims ingevoegd.';
GO

-- =============================================================
-- VERIFICATIE
-- =============================================================

PRINT '=== TEST DATA VERIFICATIE ===';

SELECT 'Personen' as Entiteit, COUNT(*) as Aantal FROM Person WHERE person_kind = 'NATURAL'
UNION ALL SELECT 'Rechtspersonen', COUNT(*) FROM Person WHERE person_kind = 'LEGAL'
UNION ALL SELECT 'Adressen', COUNT(*) FROM Address
UNION ALL SELECT 'Telefoons', COUNT(*) FROM Phone
UNION ALL SELECT 'Emails', COUNT(*) FROM Email
UNION ALL SELECT 'Instellingen', COUNT(*) FROM Institution
UNION ALL SELECT 'Objecten', COUNT(*) FROM [Object]
UNION ALL SELECT 'Contracten', COUNT(*) FROM Contract
UNION ALL SELECT 'Schadeclaims', COUNT(*) FROM Claim;

-- Detail per object type
SELECT 'Voertuigen' as Categorie, COUNT(*) as Aantal FROM [Object] o
JOIN ObjectType ot ON o.object_type_id = ot.object_type_id WHERE ot.code = 'VEHICLE'
UNION ALL
SELECT 'Onroerend goed', COUNT(*) FROM [Object] o
JOIN ObjectType ot ON o.object_type_id = ot.object_type_id WHERE ot.code = 'REAL_ESTATE'
UNION ALL
SELECT 'Leningen', COUNT(*) FROM [Object] o
JOIN ObjectType ot ON o.object_type_id = ot.object_type_id WHERE ot.code = 'LOAN'
UNION ALL
SELECT 'Zaken', COUNT(*) FROM [Object] o
JOIN ObjectType ot ON o.object_type_id = ot.object_type_id WHERE ot.code = 'THING'
UNION ALL
SELECT 'Activiteiten', COUNT(*) FROM [Object] o
JOIN ObjectType ot ON o.object_type_id = ot.object_type_id WHERE ot.code = 'ACTIVITY';

-- Detail per contract domein
SELECT contract_domain_code as Domein, COUNT(*) as Aantal FROM Contract GROUP BY contract_domain_code;

-- Detail per claim status
SELECT claim_status_code as Status, COUNT(*) as Aantal FROM Claim GROUP BY claim_status_code;

PRINT '==============================================================';
PRINT ' Test data verificatie voltooid!                              ';
PRINT '==============================================================';
GO