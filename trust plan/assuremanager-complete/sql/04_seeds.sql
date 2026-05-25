-- =============================================================
-- AssureManager Seed Data
-- Belgian Insurance Reference Data (Dutch/Flemish)
-- =============================================================
-- Run AFTER 03_constraints.sql
-- Contains: lookup tables, reference data, coverage mappings
-- =============================================================

SET NOCOUNT ON;
GO

USE AssureManagerDB;
GO

PRINT '======================================================';
PRINT ' Inserting seed data...';
PRINT '======================================================';
GO


/* ---------- PersonAddressRole ---------- */
MERGE PersonAddressRole AS t
USING (VALUES
    (N'RESIDENTIEE', N'Residentieel', N'Residentiel', 1),
    (N'BEROEP',      N'Beroep',       N'Professionel', 1),
    (N'FACTURATIE',  N'Facturatie',   N'Facturation', 1),
    (N'KORRESPONDENTIE', N'Korrespondentie', N'Correspondance', 1),
    (N'BEZOEK',      N'Bezoek',       N'Visite', 1)
) AS s(address_role_code, label_nl, label_fr, is_active)
ON t.address_role_code = s.address_role_code
WHEN MATCHED THEN UPDATE
    SET t.label_nl = s.label_nl, t.label_fr = s.label_fr, t.is_active = s.is_active
WHEN NOT MATCHED THEN INSERT(address_role_code, label_nl, label_fr, is_active)
    VALUES(s.address_role_code, s.label_nl, s.label_fr, s.is_active);
GO

PRINT 'PersonAddressRole seeds inserted.';
GO

-- Deel 1/4: Basis Lookuptabellen en ObjectType seeds

SET NOCOUNT ON;
GO

/* ---------- Taalcodes ---------- */
MERGE Language AS t
USING (VALUES
    (N'DA', N'Deens', NULL),
    (N'DE', N'Duits', NULL),
    (N'EN', N'Engels', NULL),
    (N'FR', N'Frans', N'Francais'),
    (N'EL', N'Grieks', NULL),
    (N'IT', N'Italiaans', NULL),
    (N'NL', N'Nederlands', NULL),
    (N'PT', N'Portugees', NULL),
    (N'ES', N'Spaans', NULL),
    (N'TR', N'Turks', NULL),
    (N'PL', N'Pools', NULL),
    (N'RO', N'Roemeens', NULL),
    (N'RU', N'Russisch', NULL)
) AS s(language_code, language_label_nl, language_label_fr)
ON t.language_code = s.language_code
WHEN MATCHED THEN UPDATE
    SET t.language_label_nl = s.language_label_nl, t.language_label_fr = s.language_label_fr
WHEN NOT MATCHED THEN INSERT(language_code, language_label_nl, language_label_fr)
    VALUES(s.language_code, s.language_label_nl, s.language_label_fr);

/* ---------- Aanspreektitels ---------- */
MERGE Title AS t
USING (VALUES
    (N'MR',  N'Mijnheer', NULL),
    (N'MRS', N'Mevrouw', N'Madame')
) AS s(title_code, title_label_nl, title_label_fr)
ON t.title_code = s.title_code
WHEN MATCHED THEN UPDATE
    SET t.title_label_nl = s.title_label_nl, t.title_label_fr = s.title_label_fr
WHEN NOT MATCHED THEN INSERT(title_code, title_label_nl, title_label_fr)
    VALUES(s.title_code, s.title_label_nl, s.title_label_fr);

/* ---------- Telefoontypen ---------- */
MERGE PhoneType AS t
USING (VALUES
    (N'LANDLINE', N'Vast', N'Fixe'),
    (N'MOBILE',   N'Mobiel', N'Mobile'),
    (N'FAX',      N'Fax', N'Fax'),
    (N'OTHER',    N'Overige', N'Autre')
) AS s(phone_type_code, phone_type_label_nl, phone_type_label_fr)
ON t.phone_type_code = s.phone_type_code
WHEN MATCHED THEN UPDATE
    SET t.phone_type_label_nl = s.phone_type_label_nl, t.phone_type_label_fr = s.phone_type_label_fr
WHEN NOT MATCHED THEN INSERT(phone_type_code, phone_type_label_nl, phone_type_label_fr)
    VALUES(s.phone_type_code, s.phone_type_label_nl, s.phone_type_label_fr);

/* ---------- Social Media Typen ---------- */
MERGE SocialType AS t
USING (VALUES
    (N'FACEBOOK',  N'Facebook', N'Facebook'),
    (N'TWITTER',   N'Twitter', N'Twitter'),
    (N'LINKEDIN',  N'LinkedIn', N'LinkedIn'),
    (N'INSTAGRAM', N'Instagram', N'Instagram'),
    (N'OTHER',     N'Andere', N'Autre')
) AS s(social_type_code, social_type_label_nl, social_type_label_fr)
ON t.social_type_code = s.social_type_code
WHEN MATCHED THEN UPDATE
    SET t.social_type_label_nl = s.social_type_label_nl, t.social_type_label_fr = s.social_type_label_fr
WHEN NOT MATCHED THEN INSERT(social_type_code, social_type_label_nl, social_type_label_fr)
    VALUES(s.social_type_code, s.social_type_label_nl, s.social_type_label_fr);

/* ---------- Professionele Statussen ---------- */
MERGE ProfessionalStatus AS t
USING (VALUES
    (N'CIVIL_SERVANT', N'Ambtenaar', NULL),
    (N'WORKER',        N'Arbeider', N'Ouvrier'),
    (N'EMPLOYEE',      N'Bediende', N'Employe'),
    (N'RETIRED',       N'Gepensioneerd', N'Retraite'),
    (N'RENTIER',       N'Rentenier', N'Rentier'),
    (N'STUDENT',       N'Student', N'Etudiant'),
    (N'UNEMPLOYED',    N'Werkloos', N'Chomeur'),
    (N'SELF_EMPLOYED', N'Zelfstandige', N'Independant')
) AS s(professional_status_code, professional_status_label_nl, professional_status_label_fr)
ON t.professional_status_code = s.professional_status_code
WHEN MATCHED THEN UPDATE
    SET t.professional_status_label_nl = s.professional_status_label_nl, t.professional_status_label_fr = s.professional_status_label_fr
WHEN NOT MATCHED THEN INSERT(professional_status_code, professional_status_label_nl, professional_status_label_fr)
    VALUES(s.professional_status_code, s.professional_status_label_nl, s.professional_status_label_fr);

/* ---------- ObjectType (hoofdtypes) ---------- */
MERGE ObjectType AS t
USING (VALUES
    (N'VEHICLE',     N'Voertuig'),
    (N'REAL_ESTATE', N'Onroerend goed'),
    (N'PERSON',      N'Persoon'),
    (N'THING',       N'Zaken'),
    (N'ACTIVITY',    N'Activiteit'),
    (N'LOAN',        N'Lening')
) AS s(code, label)
ON t.code = s.code
WHEN MATCHED THEN UPDATE 
    SET t.label = s.label
WHEN NOT MATCHED THEN INSERT(code, label)
    VALUES(s.code, s.label);

/* ---------- RealEstateType ---------- */
MERGE RealEstateType AS t
USING (VALUES
    (N'BEDRIJF_UITOEFENEN_ACTIVITEIT', N'Bedrijf (uitoefenen activiteit)'),
    (N'FONDSEN_EN_WAARDEN',            N'Fondsen en Waarden'),
    (N'GEBOUW',                        N'Gebouw'),
    (N'GOEDEREN',                      N'Goederen')
) AS s(realestate_type_code, label_nl)
ON t.realestate_type_code = s.realestate_type_code
WHEN MATCHED THEN UPDATE 
    SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(realestate_type_code, label_nl)
    VALUES(s.realestate_type_code, s.label_nl);

/* ---------- InsuredRole (Verzekerde rol) ---------- */
MERGE InsuredRole AS t
USING (VALUES
    (N'AANNEMER',                       N'Aannemer'),
    (N'BEWAARDER',                      N'Bewaarder'),
    (N'BOUWHEER',                       N'Bouwheer'),
    (N'EIGENAAR',                       N'Eigenaar'),
    (N'EIGENAAR_NIET_UITBATER',         N'Eigenaar - niet-uitbater'),
    (N'EIGENAAR_UITBATER',              N'Eigenaar - uitbater'),
    (N'GEDEELTELIJKE_GEBRUIKER',        N'Gedeeltelijke gebruiker'),
    (N'GEDEELTELIJKE_HUURDER',          N'Gedeeltelijke huurder'),
    (N'GRATIS_GEBRUIKER',               N'Gratis gebruiker'),
    (N'HUURDER_NIET_UITBATER',          N'Huurder - niet-uitbater'),
    (N'HUURDER_UITBATER',               N'Huurder - uitbater'),
    (N'HYPOTHECAIR_SCHULDEISER',        N'Hypothecair schuldeiser'),
    (N'MEDE_EIGENAAR',                  N'Mede-eigenaar'),
    (N'MEDEHUURDERS',                   N'Medehuurders'),
    (N'NAAKTE_EIGENAAR',                N'Naakte eigenaar'),
    (N'NIET_INWONEND_EIGENAAR',         N'Niet-inwonend eigenaar'),
    (N'ONDERHUURDER',                   N'Onderhuurder'),
    (N'TOTALE_GEBRUIKER',               N'Totale gebruiker'),
    (N'TOTALE_HUURDER',                 N'Totale huurder'),
    (N'VOOR_REKENING_VAN_WIE_HET_BEHOORT', N'Voor rekening van wie het behoort'),
    (N'VRUCHTGEBRUIKER',                N'Vruchtgebruiker')
) AS s(insured_role_code, label_nl)
ON t.insured_role_code = s.insured_role_code
WHEN MATCHED THEN UPDATE
    SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(insured_role_code, label_nl)
    VALUES(s.insured_role_code, s.label_nl);

/* ---------- UseTypeRealEstate ---------- */
MERGE UseTypeRealEstate AS t
USING (VALUES
    (N'BEROEP',                   N'Beroep'),
    (N'GARAGE',                   N'Garage'),
    (N'HANDEL',                   N'Handel'),
    (N'MAGAZIJN_GEEN_HANDELSDOELEINDEN', N'Magazijn - geen handelsdoeleinden'),
    (N'PRIVAAT',                  N'Privaat'),
    (N'PRIVAAT_PLUS_BEROEP',      N'Privaat + beroep'),
    (N'VRIJ_BEROEP',              N'Vrij beroep')
) AS s(use_type_code, label_nl)
ON t.use_type_code = s.use_type_code
WHEN MATCHED THEN UPDATE 
    SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(use_type_code, label_nl)
    VALUES(s.use_type_code, s.label_nl);

/* ---------- ResidenceOccupancyType ---------- */
MERGE ResidenceOccupancyType AS t
USING (VALUES
    (N'ANDERE_VERBLIJFPLAATS', N'Andere verblijfplaats'),
    (N'HOOFDVERBLIJFPLAATS',   N'Hoofdverblijfplaats'),
    (N'TWEEDE_VERBLIJFPLAATS', N'Tweede verblijfplaats')
) AS s(residence_occupancy_type_code, label_nl)
ON t.residence_occupancy_type_code = s.residence_occupancy_type_code
WHEN MATCHED THEN UPDATE 
    SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(residence_occupancy_type_code, label_nl)
    VALUES(s.residence_occupancy_type_code, s.label_nl);

/* ---------- ResidenceType ---------- */
MERGE ResidenceType AS t
USING (VALUES
    (N'APPARTEMENT',         N'Appartement'),
    (N'BUILDING',            N'Building'),
    (N'BUREEL',              N'Bureel'),
    (N'CHALET',              N'Chalet'),
    (N'EENGEZINSWONING',     N'Eengezinswoning'),
    (N'GARAGE',              N'Garage'),
    (N'GEWEZEN_BEDRIJFSGEBOUW', N'Gewezen bedrijfsgebouw'),
    (N'KASTEEL',             N'Kasteel'),
    (N'MEERGEZINSWONING',    N'Meergezinswoning'),
    (N'STUDENTENKOT',        N'Studentenkot'),
    (N'VILLA',               N'Villa'),
    (N'WOONCARAVAN',         N'Wooncaravan')
) AS s(residence_type_code, label_nl)
ON t.residence_type_code = s.residence_type_code
WHEN MATCHED THEN UPDATE 
    SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(residence_type_code, label_nl)
    VALUES(s.residence_type_code, s.label_nl);

/* ---------- DestinationType ---------- */
MERGE DestinationType AS t
USING (VALUES
    (N'AF_TEBREKEN',                  N'Af te breken'),
    (N'BURELEN',                      N'Burelen'),
    (N'FABRIEK',                      N'Fabriek'),
    (N'GARAGEBOX',                    N'Garagebox'),
    (N'GEBOUW_VOOR_HANDELSBEURZEN',   N'Gebouw voor handelsbeurzen'),
    (N'GEMEENSCHAPSGEBOUW',           N'Gemeenschapsgebouw'),
    (N'GEMEENSCHAPSZAAL',             N'Gemeenschapszaal'),
    (N'HANDELSGALERIJ',               N'Handelsgalerij'),
    (N'HANDELSHUIS',                  N'Handelshuis'),
    (N'LABORATORIUM',                 N'Laboratorium'),
    (N'LOODS',                        N'Loods'),
    (N'MAGAZIJN',                     N'Magazijn'),
    (N'MAGAZIJN_EN_BURELEN',          N'Magazijn en burelen'),
    (N'MANEGE_STOETERIJ',             N'Manege/stoeterij'),
    (N'NIET_GEBRUIKT_LEEG',           N'Niet gebruikt (leeg)'),
    (N'ONDERWIJS_OPLEIDING',          N'Onderwijs/opleiding'),
    (N'OPWARMINGS_DROOG_OF_WASPLAATS', N'Opwarmings-, droog- of wasplaats'),
    (N'POLYVALENTE_ZAAL',             N'Polyvalente zaal'),
    (N'SCHOUWSPELZAAL',               N'Schouwspelzaal'),
    (N'SCHUUR',                       N'Schuur'),
    (N'SPORTZAAL',                    N'Sportzaal'),
    (N'STALLINGEN',                   N'Stallingen'),
    (N'TENTOONSTELLINGSZAAL',         N'Tentoonstellingszaal'),
    (N'VERZORGINGSCENTRUM',           N'Verzorgingscentrum'),
    (N'WERKPLAATS',                   N'Werkplaats'),
    (N'ZWEMBAD',                      N'Zwembad')
) AS s(destination_type_code, label_nl)
ON t.destination_type_code = s.destination_type_code
WHEN MATCHED THEN UPDATE 
    SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(destination_type_code, label_nl)
    VALUES(s.destination_type_code, s.label_nl);

/* ---------- NatureType ---------- */
MERGE NatureType AS t
USING (VALUES
    (N'ABDIJ',                           N'Abdij'),
    (N'BEJAARDENTEHUIS',                 N'Bejaardentehuis'),
    (N'BIOSCOOP',                        N'Bioscoop'),
    (N'BOERDERIJ',                       N'Boerderij'),
    (N'CULTUREEL_CENTRUM',               N'Cultureel centrum'),
    (N'FABRIEK_IN_BAKSTEEN_EN_PANNEN',   N'Fabriek in baksteen en pannen'),
    (N'FABRIEK_MET_INDUSTRIELE_LOODSEN', N'Fabriek met industriële loodsen'),
    (N'GEBOUW_VOOR_HANDELSBEURZEN',      N'Gebouw voor handelsbeurzen'),
    (N'GEKLASSEERDE_WOONST',             N'Geklasseerde woonst'),
    (N'HANDELSHUIS',                     N'Handelshuis'),
    (N'HOOGSPANNINGSCABINE',             N'Hoogspanningscabine'),
    (N'HOTEL',                           N'Hotel'),
    (N'INDUSTRIELE_LOODS',               N'Industriële loods'),
    (N'KAZERNE',                         N'Kazerne'),
    (N'KERK',                            N'Kerk'),
    (N'KLOOSTER',                        N'Klooster'),
    (N'LOODS_IN_BAKSTEEN_EN_PANNEN',     N'Loods in baksteen en pannen'),
    (N'MIDDELEEUWSE_OMWALLING',          N'Middeleeuwse omwalling'),
    (N'MOTEL',                           N'Motel'),
    (N'MUSEUM',                          N'Museum'),
    (N'ONDERWIJSINSTELLING',             N'Onderwijsinstelling'),
    (N'OPBLAASBARE_STRUCTUUR',           N'Opblaasbare structuur'),
    (N'POLYVALENTE_ZAAL',                N'Polyvalente zaal'),
    (N'RELIGIEUS_BOUWWERK',              N'Religieus bouwwerk'),
    (N'SCHOUWSPELZAAL',                  N'Schouwspelzaal'),
    (N'SERRE',                           N'Serre'),
    (N'SHOPPINGCENTER',                  N'Shoppingcenter'),
    (N'STADION',                         N'Stadion'),
    (N'STATION',                         N'Station'),
    (N'TENTEN_EN_CIRCUSTENTEN',          N'Tenten en circustenten'),
    (N'TENTOONSTELLINGSZAAL',            N'Tentoonstellingszaal'),
    (N'THEATER',                         N'Theater'),
    (N'WERKFEEST',                       N'Werkfeest'),
    (N'WOLKENKRABBER',                   N'Wolkenkrabber'),
    (N'ZIEKENHUIS',                      N'Ziekenhuis')
) AS s(nature_type_code, label_nl)
ON t.nature_type_code = s.nature_type_code
WHEN MATCHED THEN UPDATE 
    SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(nature_type_code, label_nl)
    VALUES(s.nature_type_code, s.label_nl);

/* ---------- ConstructionType ---------- */
MERGE ConstructionType AS t
USING (VALUES
    (N'FLATGEBOUW',                        N'Flatgebouw'),
    (N'GECOMPARTIMENTEERD_GEBOUW',         N'Gecompartimenteerd gebouw'),
    (N'HALF_LICHTE_MATERIALEN',            N'Half-lichte materialen'),
    (N'HARDE_MATERIALEN',                  N'Harde materialen'),
    (N'HOUTEN_CONSTRUCTIE',                N'Houten constructie'),
    (N'KUNSTSTOFCONSTRUCTIE',              N'Kunststofconstructie'),
    (N'LICHTE_MATERIALEN',                 N'Lichte materialen'),
    (N'MET_BRANDBARE_NIVEAUSCHEIDINGEN',   N'Met brandbare niveauscheidingen'),
    (N'MET_ONBRANDBARE_NIVEAUSCHEIDINGEN', N'Met onbrandbare niveauscheidingen'),
    (N'ONBEPAALD',                         N'Onbepaald'),
    (N'OPBLAASBARE_STRUCTUUR',             N'Opblaasbare structuur'),
    (N'TENT',                              N'Tent')
) AS s(construction_type_code, label_nl)
ON t.construction_type_code = s.construction_type_code
WHEN MATCHED THEN UPDATE 
    SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(construction_type_code, label_nl)
    VALUES(s.construction_type_code, s.label_nl);

/* ---------- RoofType ---------- */
MERGE RoofType AS t
USING (VALUES
    (N'ANDERE',                           N'Andere'),
    (N'RIET',                             N'Riet'),
    (N'RIET_MET_BRANDBARE_SCHEIDING',     N'Riet met brandbare scheiding'),
    (N'RIET_OP_ONBRANDBARE_SCHEIDING',    N'Riet op onbrandbare scheiding'),
    (N'TRADITIONEEL',                     N'Traditioneel'),
    (N'TRADITIONEEL_MET_BRANDBARE_SCHEIDING',  N'Traditioneel met brandbare scheiding'),
    (N'TRADITIONEEL_OP_ONBRANDBARE_SCHEIDING', N'Traditioneel op onbrandbare scheiding')
) AS s(roof_type_code, label_nl)
ON t.roof_type_code = s.roof_type_code
WHEN MATCHED THEN UPDATE
    SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(roof_type_code, label_nl)
    VALUES(s.roof_type_code, s.label_nl);

/* ---------- AdjacencyType ---------- */
MERGE AdjacencyType AS t
USING (VALUES
    (N'ALLEENSTAAND',                   N'Alleenstaand'),
    (N'ALLEENSTAAND_GT_20M',            N'Alleenstaand > 20m'),
    (N'ALLEENSTAAND_GT_50M',            N'Alleenstaand > 50m'),
    (N'ALLEENSTAAND_LT_50M',            N'Alleenstaand < 50m'),
    (N'BEIDE_ZIJDEN',                   N'Beide zijden'),
    (N'BELENDEND',                      N'Belendend'),
    (N'DRIE_ZIJDEN_VOLLEDIG_BELENDEND', N'Drie zijden (volledig belendend)'),
    (N'EEN_ZIJDE_GEDEELTELIJK_BELENDEND', N'Eén zijde (gedeeltelijk belendend)'),
    (N'INGESLOTEN',                     N'Ingesloten'),
    (N'NEEN',                           N'Neen')
) AS s(adjacency_type_code, label_nl)
ON t.adjacency_type_code = s.adjacency_type_code
WHEN MATCHED THEN UPDATE
    SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(adjacency_type_code, label_nl)
    VALUES(s.adjacency_type_code, s.label_nl);

/* ---------- OccupancyLevel ---------- */
MERGE OccupancyLevel AS t
USING (VALUES
    (N'GEDURENDE_MEER_DAN_3_MAANDEN_AANEENSLUITEND_ONBEWOOND', N'Gedurende meer dan 3 maanden aaneensluitend onbewoond'),
    (N'GEDURENDE_MEER_DAN_3_MAANDEN_ONBEWOOND',               N'Gedurende meer dan 3 maanden onbewoond'),
    (N'GEEN_BEWONING',                                       N'Geen bewoning'),
    (N'ONREGELMATIGE_BEWONING',                              N'Onregelmatige bewoning'),
    (N'REGELMATIGE_BEWONING',                                N'Regelmatige bewoning')
) AS s(occupancy_level_code, label_nl)
ON t.occupancy_level_code = s.occupancy_level_code
WHEN MATCHED THEN UPDATE
    SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(occupancy_level_code, label_nl)
    VALUES(s.occupancy_level_code, s.label_nl);

/* ---------- BurglaryProtectionType ---------- */
MERGE BurglaryProtectionType AS t
USING (VALUES
    (N'ALARM_ERKEND',      N'Alarm erkend'),
    (N'ALARM_NIET_ERKEND', N'Alarm niet erkend'),
    (N'BEWAKINGSDIENST',   N'Bewakingsdienst'),
    (N'EXTERN_TRALIEWERK', N'Extern traliewerk'),
    (N'GEEN_ALARM',        N'Geen alarm'),
    (N'GOED_SLOT',         N'Goed slot')
) AS s(burglary_protection_type_code, label_nl)
ON t.burglary_protection_type_code = s.burglary_protection_type_code
WHEN MATCHED THEN UPDATE
    SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(burglary_protection_type_code, label_nl)
    VALUES(s.burglary_protection_type_code, s.label_nl);

/* ---------- ObjectPerson, ObjectThing domein Lookups ---------- */
MERGE ObjectPersonSubtype AS t
USING (VALUES
    (N'GEZIN_PRIV',  N'Gezin (privé leven)'),
    (N'GROEP_COL',   N'Groep personen (collectief)'),
    (N'GROEP_ARB',   N'Groep personen - Arbeiders'),
    (N'GROEP_BED',   N'Groep personen - Bedienden'),
    (N'GROEP_POB',   N'Groep personen - Privé- en openbare bedrijven'),
    (N'GROEP_GEZIN', N'Groep personen - gezin'),
    (N'PERS_IND',    N'Persoon (individu)'),
    (N'PERS_ACT',    N'Persoon (uitoefenen activiteit)')
) AS s(subtype_code, label_nl)
ON t.subtype_code = s.subtype_code
WHEN MATCHED THEN UPDATE 
    SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(subtype_code, label_nl)
    VALUES(s.subtype_code, s.label_nl);

MERGE WorkerRiskClass AS t
USING (VALUES
    (N'WERF',         N'Arbeider op de werf'),
    (N'ZONDER_VERPL', N'Arbeider zonder verplaatsingen'),
    (N'CHAUFFEUR',    N'Chauffeur'),
    (N'HUISBEW',      N'Huisbewaarders'),
    (N'KEUKEN',       N'Keukenpersoneel'),
    (N'SCHOON_OND',   N'Schoonmaak- en onderhoudspersoneel')
) AS s(worker_risk_class_code, label_nl)
ON t.worker_risk_class_code = s.worker_risk_class_code
WHEN MATCHED THEN UPDATE 
    SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(worker_risk_class_code, label_nl)
    VALUES(s.worker_risk_class_code, s.label_nl);

MERGE EmployeeRiskClass AS t
USING (VALUES
    (N'SPORT_AND',   N'Andere sportbeoefenaar dan voetballer'),
    (N'MANUEEL',     N'Bediende die manueel werk verricht'),
    (N'OCCAS_OPD',   N'Bediende met occasionele opdrachten buiten de onderneming'),
    (N'REGEL_OPD',   N'Bediende met regelmatige opdrachten buiten de onderneming'),
    (N'ZONDER_VERPL',N'Bediende zonder verplaatsingen'),
    (N'THUIS',       N'Thuiswerkende bediende'),
    (N'VERKOPER',    N'Verkoper'),
    (N'VERPLEGING',  N'Verplegend personeel'),
    (N'REIZEND',     N'Vertegenwoordiger, reizend personeel, loopjongens'),
    (N'VOETBAL_BET', N'Voetballer - betaalde sportbeoefenaar'),
    (N'VOETBAL_MIN', N'Voetballer - niet onderworpen - plafond min'),
    (N'VOETBAL_PLUS',N'Voetballer - niet onderworpen - plafond plus')
) AS s(employee_risk_class_code, label_nl)
ON t.employee_risk_class_code = s.employee_risk_class_code
WHEN MATCHED THEN UPDATE 
    SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(employee_risk_class_code, label_nl)
    VALUES(s.employee_risk_class_code, s.label_nl);

MERGE AgeCategory AS t
USING (VALUES
    (N'KIND',   N'Kinderen'),
    (N'VOLW',   N'Volwassenen'),
    (N'SENIOR', N'Senioren'),
    (N'GEMENGD', N'Gemengd')
) AS s(age_category_code, label_nl)
ON t.age_category_code = s.age_category_code
WHEN MATCHED THEN UPDATE 
    SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(age_category_code, label_nl)
    VALUES(s.age_category_code, s.label_nl);

MERGE ObjectThingSubtype AS t
USING (VALUES
    (N'INBOEDEL',    N'Inboedel'),
    (N'GOEDEREN',    N'Goederen'),
    (N'MATERIEEL',   N'Materieel'),
    (N'MACHINES',    N'Machines en toestellen'),
    (N'ACCESSOIRES', N'Accessoires'),
    (N'VOORWERP',    N'Voorwerp'),
    (N'DIER',        N'Dier'),
    (N'OOGST',       N'Oogst'),
    (N'FONDSEN',     N'Fondsen en waarden'),
    (N'BEDRIJFSUITR', N'Bedrijfsuitrusting')
) AS s(subtype_code, label_nl)
ON t.subtype_code = s.subtype_code
WHEN MATCHED THEN UPDATE 
    SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(subtype_code, label_nl)
    VALUES(s.subtype_code, s.label_nl);

MERGE ThingRiskCategory AS t
USING (VALUES
    (N'LOW',    N'Laag risico'),
    (N'MEDIUM', N'Midden risico'),
    (N'HIGH',   N'Hoog risico')
) AS s(risk_category_code, label_nl)
ON t.risk_category_code = s.risk_category_code
WHEN MATCHED THEN UPDATE 
    SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(risk_category_code, label_nl)
    VALUES(s.risk_category_code, s.label_nl);

MERGE ThingMaterialType AS t
USING (VALUES
    (N'METAAL',    N'Metaal'),
    (N'HOUT',      N'Hout'),
    (N'KUNSTSTOF', N'Kunststof'),
    (N'GEMENGD',   N'Gemengd'),
    (N'OVERIG',    N'Overig')
) AS s(material_type_code, label_nl)
ON t.material_type_code = s.material_type_code
WHEN MATCHED THEN UPDATE 
    SET t.label_nl = s.label_nl
WHEN NOT MATCHED THEN INSERT(material_type_code, label_nl)
    VALUES(s.material_type_code, s.label_nl);
	
	
	
	
	
	
	
-- Deel 2/4: Institution en Contract gerelateerde seeds

/* ---------- Institution Roles ---------- */
MERGE InstitutionRole AS t
USING (VALUES
    (N'INSURER',         N'Verzekeringsmaatschappij', 1),
    (N'REINSURER',       N'Herverzekeraar', 1),
    (N'BANK',            N'Bank', 1),
    (N'CREDIT_PROVIDER', N'Kredietverstrekker', 1),
    (N'LEASING_COMPANY', N'Leasingmaatschappij', 1),
    (N'MGA',             N'Managing General Agent', 1),
    (N'TPA',             N'Third-Party Administrator', 1),
    (N'ASSISTANCE',      N'Bijstandsmaatschappij', 1),
    (N'CLAIMS_HANDLER',  N'Schadebeheerder', 1),
    (N'WHOLESALER',      N'Volmacht/Wholesaler', 1),
    (N'SERVICE_PROVIDER',N'Dienstverlener', 1)
) AS s(institution_role_code, label_nl, is_active)
ON t.institution_role_code = s.institution_role_code
WHEN MATCHED THEN UPDATE 
    SET t.label_nl = s.label_nl,
        t.is_active = s.is_active
WHEN NOT MATCHED THEN INSERT(institution_role_code, label_nl, is_active)
    VALUES(s.institution_role_code, s.label_nl, s.is_active);

/* ---------- Institution Identifier Types ---------- */
MERGE InstitutionIdentifierType AS t
USING (VALUES
    (N'VAT',   N'BTW-nummer', 1),
    (N'KBO',   N'KBO/BCE-nummer', 1),
    (N'LEI',   N'Legal Entity Identifier', 1),
    (N'BIC',   N'Bank Identifier Code', 1),
    (N'SWIFT', N'SWIFT-code', 1),
    (N'FSMA',  N'FSMA-registratienummer', 1),
    (N'DUNS',  N'D-U-N-S Number', 1)
) AS s(id_type_code, label_nl, is_active)
ON t.id_type_code = s.id_type_code
WHEN MATCHED THEN UPDATE 
    SET t.label_nl = s.label_nl,
        t.is_active = s.is_active
WHEN NOT MATCHED THEN INSERT(id_type_code, label_nl, is_active)
    VALUES(s.id_type_code, s.label_nl, s.is_active);

/* ---------- Institution Address Roles ---------- */
MERGE InstitutionAddressRole AS t
USING (VALUES
    (N'HQ',       N'Hoofdkantoor', 1),
    (N'BRANCH',   N'Filiaal', 1),
    (N'CLAIMS',   N'Schade-adres', 1),
    (N'BILLING',  N'Facturatie-adres', 1),
    (N'LEGAL',    N'Juridisch', 1),
    (N'CORRESP',  N'Correspondentie', 1)
) AS s(address_role_code, label_nl, is_active)
ON t.address_role_code = s.address_role_code
WHEN MATCHED THEN UPDATE 
    SET t.label_nl = s.label_nl,
        t.is_active = s.is_active
WHEN NOT MATCHED THEN INSERT(address_role_code, label_nl, is_active)
    VALUES(s.address_role_code, s.label_nl, s.is_active);

/* ---------- Contract Domains ---------- */
MERGE ContractDomain AS t
USING (VALUES
    (N'ARBEIDSONGEVALLEN_COLLECTIEF', N'Arbeidsongevallen en collectieve verzekeringen', 1),
    (N'AUTO',                        N'Auto', 1),
    (N'BA_ANDERE_PART',              N'BA andere dan particulieren', 1),
    (N'BA_PART',                     N'BA particulieren', 1),
    (N'BELEGGING_23_26',             N'Belegging en Takken 23 en 26', 1),
    (N'BIJSTAND',                    N'Bijstand', 1),
    (N'BRAND_BIJZONDERE',            N'Brand bijzondere risico’s', 1),
    (N'BRAND_EENVOUDIG',             N'Brand eenvoudige risico’s', 1),
    (N'DIVERSEN',                    N'Diversen', 1),
    (N'GEEN_DOMEIN',                 N'Geen domein', 1),
    (N'HOSPITALISATIE',              N'Hospitalisatie en gezondheidszorgen', 1),
    (N'INDIVIDUELE',                 N'Individuele', 1),
    (N'LENING',                      N'Lening', 1),
    (N'LEVEN_BELEGGINGEN',           N'Leven en beleggingen', 1),
    (N'MULTI_DOMEIN',                N'Multi-domein', 1),
    (N'OBJECTIEVE_AANSPRAK',         N'Objectieve aansprakelijkheid en - van onroerende goederen', 1),
    (N'RECHTSBIJSTAND',              N'Rechtsbijstand', 1),
    (N'REIS',                        N'Reis', 1),
    (N'TRANSPORT_MARINE',            N'Transport & marine', 1)
) AS s(contract_domain_code, label_nl, is_active)
ON t.contract_domain_code = s.contract_domain_code
WHEN MATCHED THEN UPDATE 
    SET t.label_nl = s.label_nl,
        t.is_active = s.is_active
WHEN NOT MATCHED THEN INSERT(contract_domain_code, label_nl, is_active)
    VALUES(s.contract_domain_code, s.label_nl, s.is_active);

/* ---------- ContractVersionStatus ---------- */
MERGE ContractVersionStatus AS t
USING (VALUES
    (N'DRAFT',     N'Ontwerp', 1),
    (N'ACTIVE',    N'Actief', 1),
    (N'CANCELLED', N'Geannuleerd', 1),
    (N'EXPIRED',   N'Vervallen', 1)
) AS s(status_code, status_label, is_active)
ON t.status_code = s.status_code
WHEN MATCHED THEN UPDATE 
    SET t.status_label = s.status_label,
        t.is_active = s.is_active
WHEN NOT MATCHED THEN INSERT(status_code, status_label, is_active)
    VALUES(s.status_code, s.status_label, s.is_active);

/* ---------- ContractStatus ---------- */
MERGE ContractStatus AS t
USING (VALUES
    (N'LOPEND',              N'Lopend', 1),
    (N'GESCHORST',           N'Geschorst', 1),
    (N'OPGEZEGD',            N'Opgezegd', 1),
    (N'VERNIETIGD',          N'Vernietigd', 1),
    (N'GEMANDATEERD',        N'Gemandateerd', 1),
    (N'IN_WIJZIGING',        N'In wijziging / Opmaak', 1),
    (N'NIET_ACTIEF',         N'Niet actief', 1),
    (N'GEARCHIVEERD',        N'Gearchiveerd', 1),
    (N'BUITEN_PORTEFEUILLE', N'Buiten portefeuille', 1)
) AS s(contract_status_code, status_label, is_active)
ON t.contract_status_code = s.contract_status_code
WHEN MATCHED THEN UPDATE 
    SET t.status_label = s.status_label,
        t.is_active = s.is_active
WHEN NOT MATCHED THEN INSERT(contract_status_code, status_label, is_active)
    VALUES(s.contract_status_code, s.status_label, s.is_active);

/* ---------- Periodicity (premieperioden) ---------- */
MERGE Periodicity AS t
USING (VALUES
    (N'DRIEMAANDELIJKS', N'Driemaandelijks', 1),
    (N'ENIGE_PREMIE',    N'Enige premie', 1),
    (N'GEEN',            N'Geen', 1),
    (N'JAARLIJKS',       N'Jaarlijks', 1),
    (N'MAANDELIJKS',     N'Maandelijks', 1),
    (N'OP_AFREKENING',   N'Op afrekening', 1),
    (N'TWEEMAANDELIJKS', N'Tweemaandelijks', 1),
    (N'VRIJ',            N'Vrij', 1),
    (N'ZESMAANDELIJKS',  N'Zesmaandelijks', 1),
    (N'ZONDER_PREMIE',   N'Zonder premie', 1)
) AS s(periodicity_code, periodicity_label, is_active)
ON t.periodicity_code = s.periodicity_code
WHEN MATCHED THEN UPDATE 
    SET t.periodicity_label = s.periodicity_label,
        t.is_active = s.is_active
WHEN NOT MATCHED THEN INSERT(periodicity_code, periodicity_label, is_active)
    VALUES(s.periodicity_code, s.periodicity_label, s.is_active);

/* ---------- CollectionMethod (inningswijze) ---------- */
MERGE CollectionMethod AS t
USING (VALUES
    (N'MAATSCHAPPIJ', N'Maatschappij', 1),
    (N'PRODUCENT',   N'Producent', 1)
) AS s(collection_method_code, collection_method_label, is_active)
ON t.collection_method_code = s.collection_method_code
WHEN MATCHED THEN UPDATE 
    SET t.collection_method_label = s.collection_method_label,
        t.is_active = s.is_active
WHEN NOT MATCHED THEN INSERT(collection_method_code, collection_method_label, is_active)
    VALUES(s.collection_method_code, s.collection_method_label, s.is_active);

/* ---------- DurationType (duur eenheden) ---------- */
MERGE DurationType AS t
USING (VALUES
    (N'UUR',     N'Uur', 1),
    (N'DAGEN',   N'Dagen', 1),
    (N'WEKEN',   N'Weken', 1),
    (N'MAANDEN', N'Maanden', 1),
    (N'JAREN',   N'Jaren', 1)
) AS s(duration_type_code, label_nl, is_active)
ON t.duration_type_code = s.duration_type_code
WHEN MATCHED THEN UPDATE 
    SET t.label_nl = s.label_nl,
        t.is_active = s.is_active
WHEN NOT MATCHED THEN INSERT(duration_type_code, label_nl, is_active)
    VALUES(s.duration_type_code, s.label_nl, s.is_active);

/* ---------- ContractType (soorten contracten, gekoppeld aan domein) ---------- */
MERGE ContractType AS t
USING (VALUES
    (N'AUTO_BIJZONDERE_VOERTUIGEN',            N'AUTO', N'Bijzondere voertuigen', 1),
    (N'AUTO_BROMFIETSEN',                      N'AUTO', N'Bromfietsen', 1),
    (N'AUTO_GEMENGDE_VLOOT',                   N'AUTO', N'Gemengde vloot', 1),
    (N'AUTO_HANDELAARPLATEN_EN_PROEFRITTENPLATEN', N'AUTO', N'Handelaarplaten en Proefrittenplaten', 1),
    (N'AUTO_LICHTE_VRACHTWAGENS',              N'AUTO', N'Lichte Vrachtwagens', 1),
    (N'AUTO_MOTORFIETSEN',                     N'AUTO', N'Motorfietsen', 1),
    (N'AUTO_TOERISME_EN_ZAKEN_GEMENGD_GEBRUIK',N'AUTO', N'Toerisme en Zaken, gemengd gebruik', 1),
    (N'AUTO_VERKEER_EN_INZITTENDEN',           N'AUTO', N'Verkeer & Inzittenden', 1),
    (N'AUTO_VERVOER_VAN_PERSONEN',             N'AUTO', N'Vervoer van Personen', 1),
    (N'AUTO_VRACHTWAGENS_V_E_R_VERVOER_EIGEN_REK', N'AUTO', N'Vrachtwagens, V.E.R. (Vervoer Eigen Rek.)', 1)
) AS s(contract_type_code, contract_domain_code, contract_type_name, is_active)
ON t.contract_type_code = s.contract_type_code
WHEN MATCHED THEN UPDATE 
    SET t.contract_domain_code = s.contract_domain_code,
        t.contract_type_name = s.contract_type_name,
        t.is_active = s.is_active
WHEN NOT MATCHED THEN INSERT(contract_type_code, contract_domain_code, contract_type_name, is_active)
    VALUES(s.contract_type_code, s.contract_domain_code, s.contract_type_name, s.is_active);

/* ---------- TakeoverDirection ---------- */
MERGE TakeoverDirection AS t
USING (VALUES
    (N'INBOUND',  N'Inkomend (jouw contract neemt over)', 1),
    (N'OUTBOUND', N'Uitgaand (jouw contract wordt overgenomen)', 1)
) AS s(takeover_direction_code, label_nl, is_active)
ON t.takeover_direction_code = s.takeover_direction_code
WHEN MATCHED THEN UPDATE 
    SET t.label_nl = s.label_nl,
        t.is_active = s.is_active
WHEN NOT MATCHED THEN INSERT(takeover_direction_code, label_nl, is_active)
    VALUES(s.takeover_direction_code, s.label_nl, s.is_active);

/* ---------- TakeoverSourceType ---------- */
MERGE TakeoverSourceType AS t
USING (VALUES
    (N'EXTERNAL_COMPANY', N'Externe maatschappij/polis', 1),
    (N'INTERNAL_POLICY',  N'Interne policy (in dit systeem)', 1)
) AS s(takeover_source_type_code, label_nl, is_active)
ON t.takeover_source_type_code = s.takeover_source_type_code
WHEN MATCHED THEN UPDATE 
    SET t.label_nl = s.label_nl,
        t.is_active = s.is_active
WHEN NOT MATCHED THEN INSERT(takeover_source_type_code, label_nl, is_active)
    VALUES(s.takeover_source_type_code, s.label_nl, s.is_active);

/* ---------- ContractPartyRole ---------- */
MERGE ContractPartyRole AS t
USING (VALUES
    (N'POLICYHOLDER',   N'Verzekeringnemer', 1),
    (N'CO_POLICYHOLDER',N'Medeverzekeringnemer', 1),
    (N'BORROWER',       N'Kredietnemer', 1),
    (N'CO_BORROWER',    N'Medekredietnemer', 1),
    (N'GUARANTOR',      N'Borgsteller', 1),
    (N'BENEFICIARY',    N'Begunstigde', 1),
    (N'LEGAL_REP',      N'Wettelijke vertegenwoordiger', 1)
) AS s(contract_party_role_code, role_label, is_active)
ON t.contract_party_role_code = s.contract_party_role_code
WHEN MATCHED THEN UPDATE 
    SET t.role_label = s.role_label,
        t.is_active = s.is_active
WHEN NOT MATCHED THEN INSERT(contract_party_role_code, role_label, is_active)
    VALUES(s.contract_party_role_code, s.role_label, s.is_active);

/* ---------- ContractObjectStatus ---------- */
MERGE ContractObjectStatus AS t
USING (VALUES
    (N'ACTIVE',   N'Actief', 1),
    (N'INACTIVE', N'Niet actief', 1),
    (N'SUSPENDED',N'Geschorst', 1),
    (N'EXCLUDED', N'Uitgesloten', 1)
) AS s(contract_object_status_code, status_label, is_active)
ON t.contract_object_status_code = s.contract_object_status_code
WHEN MATCHED THEN UPDATE 
    SET t.status_label = s.status_label,
        t.is_active = s.is_active
WHEN NOT MATCHED THEN INSERT(contract_object_status_code, status_label, is_active)
    VALUES(s.contract_object_status_code, s.status_label, s.is_active);

	
	
	
	
-- Deel 3/4: Dekkingscodes en hun koppeling aan contractdomeinen

/* ---------- Dekkingen (lookup_coverage) ---------- */
MERGE lookup_coverage AS t
USING (VALUES
    (N'AANRAKING_VOERTUIGEN',           N'Aanraking voertuigen',               1),
    (N'AANRANDING',                     N'Aanranding',                         1),
    (N'AANRIJDING_MET_WILD_VOERTUIG',   N'Aanrijding met wild (Voertuig)',     1),
    (N'AANSLAGEN_EN_ARBEIDSCONFLICTEN', N'Aanslagen en Arbeidsconflicten',     1),
    (N'AANSLAGEN_EN_TERRORISME',        N'Aanslagen en Terrorisme',            1),
    (N'AANVULLENDE_WAARBORGEN',         N'Aanvullende waarborgen',             1),
    (N'AANVULLENDE_WAARBORGEN_BRAND',   N'Aanvullende waarborgen (Brand)',     1),
    (N'AARDBEVING',                     N'Aardbeving',                         1),
    (N'ABR_SCHADE_AAN_BESTAAND_GOED',   N'ABR – Schade aan bestaand goed',     1),
    (N'AFHANKELIJKHEID',                N'Afhankelijkheid',                    1),
    (N'AFSTAND_VAN_VERHAAL',            N'Afstand van verhaal',                1),
    (N'ALLE_BOUWWERF_RISICO_S',         N'Alle Bouwwerf Risico’s',            1),
    (N'ALLE_RISICO_S',                  N'Alle Risico’s',                      1),
    (N'ALLE_RISICO_S_TRANSPORT',        N'Alle risico’s (Transport)',         1),
    (N'AMBULANTE_MEDISCHE_KOSTEN',      N'Ambulante medische kosten',          1),
    (N'ANNULERING',                     N'Annulering',                         1),
    (N'ARBEIDSONGEVALLEN',              N'Arbeidsongevallen',                  1),
    (N'ARBEIDSRISICO',                  N'Arbeidsrisico',                      1),
    (N'ARBEIDSRISICO_EXCEDENT',         N'Arbeidsrisico (excedent)',           1),
    (N'AVRH',                           N'AVRH',                               1),
    (N'AVRI_KAPITAAL',                  N'AVRI kapitaal',                      1),
    (N'AVRI_PREMIE',                    N'AVRI premie',                        1),
    (N'AVRI_RENTE',                     N'AVRI rente',                         1),
    (N'AVRI_VASTE_KOSTEN',              N'AVRI vaste kosten',                  1),
    (N'AVRI_VOORSCHOT',                 N'AVRI voorschot',                     1),
    (N'AVRO',                           N'AVRO',                               1),
    (N'AVRO_INVALIDITEIT',              N'AVRO Invaliditeit',                  1),
    (N'AVR_H',                          N'AVR H',                              1),
    (N'AV_FAMILIALE',                   N'AV Familiale',                       1),
    (N'BANKWAARBORG',                   N'Bankwaarborg',                       1),
    (N'BA_ALGEMEEN',                    N'BA Algemeen',                        1),
    (N'BA_BEROEP',                      N'BA Beroep',                          1),
    (N'BA_BEWAARNE_MER',                N'BA Bewaarneemer',                    1),
    (N'BA_BEZITTINGEN',                 N'BA Bezittingen',                     1),
    (N'BA_BURENHINDER_CONTRACTUEEL_VERWORVEN', N'BA Burenhinder, contractueel verworven', 1),
    (N'BA_COMMISSIONAIR_EXPEDITEUR',    N'BA Commissionair/Expediteur',        1),
    (N'BA_EIGENAAR_JACHTGEBIED',        N'BA Eigenaar jachtgebied',            1),
    (N'BA_GEZIN_KB',                    N'BA Gezin (KB)',                      1),
    (N'BA_GEZIN_KB_WAARBORGUITBREIDINGEN', N'BA Gezin (KB + waarborguitbreidingen)', 1),
    (N'BA_IMMATERI_LE_GEVOLGSCHADE',    N'BA Immateriële gevolgschade',        1),
    (N'BA_INDIRECTE_VERLIEZEN',         N'BA Indirecte Verliezen',             1),
    (N'BA_INITIAL_PUBLIC_OFFERING',     N'BA Initial Public Offering',         1),
    (N'BA_JACHTWACHTER',                N'BA Jachtwachter',                    1),
    (N'BA_JAGERS',                      N'BA Jagers',                          1),
    (N'BA_LASTHEBBERS_VAN_VENNOOTSCHAPPEN', N'BA Lasthebbers van vennootschappen', 1),
    (N'BA_LICHAMELIJKE_SCHADE',         N'BA Lichamelijke schade',             1),
    (N'BA_MATERI_LE_SCHADE',            N'BA Materiële schade',                1),
    (N'BA_MILIEU',                      N'BA Milieu',                          1),
    (N'BA_MOTORVOERTUIG',               N'BA Motorvoertuig',                   1),
    (N'BA_NA_LEVERING',                 N'BA Na Levering',                     1),
    (N'BA_ONSTOFFELIJKE_SCHADE',        N'BA Onstoffelijke schade',            1),
    (N'BA_PRODUCTEN',                   N'BA Producten',                       1),
    (N'BA_TEN_OPZICHTE_VAN_WATERSKI_RS', N'BA ten opzichte van waterskiërs',   1),
    (N'BA_TOEVERTROUWDE_VOORWERPEN',    N'BA Toevertrouwde voorwerpen',        1),
    (N'BA_TOEVERTROUWD_GEREEDSCHAP',    N'BA Toevertrouwd gereedschap',        1),
    (N'BA_UITBATING',                   N'BA Uitbating',                       1),
    (N'BA_VERVOERDER',                  N'BA Vervoerder',                      1),
    (N'BA_WERKING',                     N'BA Werking',                         1),
    (N'BEDRIJFSSCHADE',                 N'Bedrijfsschade',                     1),
    (N'BEGRAFENISKOSTEN',               N'Begrafeniskosten',                   1),
    (N'BEHANDELINGSKOSTEN_VAN_ZWARE_ZIEKTEN', N'Behandelingskosten van zware ziekten', 1),
    (N'BEMESTINGSSCHADE',               N'Bemestingsschade',                   1),
    (N'BESCHADIGING_ONROERENDE',        N'Beschadiging onroerende goederen',   1),
    (N'BESCHADIGING_ROERENDE_GOEDEREN', N'Beschadiging roerende goederen',     1),
    (N'BESTENDIGE_INVALIDITEIT',        N'Bestendige invaliditeit',            1),
    (N'BESTUURDER',                     N'Bestuurder',                         1),
    (N'BIJSTAND',                       N'Bijstand',                           1),
    (N'BRANDWONDEN',                    N'Brandwonden',                        1),
    (N'BRAND_ALGEMEEN',                 N'Brand Algemeen',                     1),
    (N'BRAND_ALLEEN',                   N'Brand alleen',                       1),
    (N'BRAND_VOERTUIG',                 N'Brand (Voertuig)',                   1),
    (N'BRAND_ZONDER_FLEXA_B_S_R',       N'Brand (zonder FLEXA - B.S.R.)',      1),
    (N'B_A_WERF',                       N'B.A. Werf',                          1),
    (N'CASCO_EN_MACHINES',              N'Casco en machines',                  1),
    (N'CASCO_VAN_HET_VERVOERMIDDEL',    N'Casco (van het vervoermiddel)',      1),
    (N'COLLECTIEVE_ONGEVALLEN',         N'Collectieve Ongevallen',             1),
    (N'COMMERCI_LE_ONBRUIKBAARHEID',    N'Commerciële onbruikbaarheid',        1),
    (N'CONTROLEVERZEKERING',            N'Controleverzekering',                1),
    (N'DAGVERGOEDING_HOSPITALISATIE',   N'Dagvergoeding hospitalisatie',       1),
    (N'DIEFSTAL',                       N'Diefstal',                           1),
    (N'DIEFSTAL_VAN_WAARDEN',           N'Diefstal van waarden',               1),
    (N'DIEFSTAL_VOERTUIG',              N'Diefstal (Voertuig)',                1),
    (N'DIERENVERZEKERINGEN',            N'Dierenverzekeringen',                1),
    (N'EIGEN_SCHADE',                   N'Eigen Schade',                       1),
    (N'ELEKTRICITEIT',                  N'Elektriciteit',                      1),
    (N'ELEKTRICITEIT_ELECTRONICA',      N'Elektriciteit & Elektronica',        1),
    (N'EXCEDENT',                       N'Excedent',                           1),
    (N'EXPERTISEKOSTEN',                N'Expertisekosten',                    1),
    (N'EXPERTISE_KOSTEN_BEDRIJFSSCHADE', N'Expertisekosten (Bedrijfsschade)',  1),
    (N'FINANCIERING',                   N'Financiering',                       1),
    (N'GEBRUIKSDERVING',                N'Gebruiksderving',                    1),
    (N'GEDEELTELIJKE_OMNIUM',           N'Gedeeltelijke Omnium',               1),
    (N'GELDELIJKE_VERLIEZEN',           N'Geldelijke verliezen',               1),
    (N'GEMENGDE_LEVEN',                 N'Gemengde (leven)',                   1),
    (N'GEWAARBORGD_INKOMEN',            N'Gewaarborgd inkomen',                1),
    (N'GEWAARBORGD_INKOMEN_COLLECTIEVE_VERZEKERINGEN', N'Gewaarborgd inkomen (Collectieve Verzekeringen)', 1),
    (N'GEWAARBORGD_LOON',               N'Gewaarborgd loon',                   1),
    (N'GEWAARBORGD_LOON_BEDR_S',        N'Gewaarborgd loon (Bedr. personeel)', 1),
    (N'GLASBRAAK',                      N'Glasbraak',                          1),
    (N'GLASBRAAK_VOERTUIG',             N'Glasbraak (Voertuig)',               1),
    (N'HUISPERSONEEL',                  N'Huispersoneel',                      1),
    (N'HUWELIJKSVOORZORG',              N'Huwelijksvoorzorg',                  1),
    (N'HYPOTHECAIR_KREDIET',            N'Hypothecair krediet',                1),
    (N'INBRAAKSCHADE',                  N'Inbraakschade',                      1),
    (N'INBRAAKS_CHADE',                 N'Inbraakschade (variant spelling)',   1),
    (N'INDIRECTE_VERLIEZEN',            N'Indirecte Verliezen',                1),
    (N'INSOLVENTIE_VAN_DERDEN',         N'Insolventie van derden',             1),
    (N'INSTORTING_B_S_R',               N'Instorting (B.S.R.)',                1),
    (N'INTERN_MISBRUIK_EN_FRAUDE',      N'Intern misbruik en fraude',          1),
    (N'INTREKKING_RIJBEWIJS',           N'Intrekking rijbewijs',               1),
    (N'INVESTERINGSKREDIET',            N'Investeringskrediet',                1),
    (N'INZITTENDEN',                    N'Inzittenden',                        1),
    (N'JONGEREN_BIJKOMENDE',            N'Jongeren, bijkomende (verzekering)', 1),
    (N'KASKREDIET',                     N'Kaskrediet',                         1),
    (N'KLOPJACHTEN',                    N'Klopjachten',                        1),
    (N'KOSTEN_VAN_HULPMIDDELEN_EN_AANPASSING', N'Kosten van hulpmiddelen en aanpassing', 1),
    (N'KOSTEN_VAN_REPATRI_RING_EN_UITVAART',   N'Kosten van repatriëring en uitvaart', 1),
    (N'LENING_ALGEMEEN',               N'Lening algemeen',                    1),
    (N'LEVEN',                         N'Leven',                              1),
    (N'LEVENSLANGE',                   N'Levenslange',                        1),
    (N'LEVERANCIERSAFHANKELIJKHEID',   N'Leveranciersafhankelijkheid',        1),
    (N'LEVERANCIERS_AANSPRAKELIJKHEID', N'Leveranciers­aansprakelijkheid',    1),
    (N'LITT_E',                        N'Litt.E',                             1),
    (N'LITT_I',                        N'Litt.I',                             1),
    (N'MACHINEBREUK',                  N'Machinebreuk',                       1),
    (N'MEDISCHE_CONTROLE',             N'Medische Controle',                  1),
    (N'MEDISCHE_KOSTEN',               N'Medische Kosten',                    1),
    (N'MONTAGE',                       N'Montage',                            1),
    (N'NATUURKRACHTEN_VOERTUIG',       N'Natuurkrachten (Voertuig)',          1),
    (N'NATUURRAMPEN_SPECIFIEK',        N'Natuurrampen (specifiek)',           1),
    (N'NATUURRAMPEN_TARIFICATIEBUREAU', N'Natuurrampen (Tarificatiebureau)',  1),
    (N'OBJECTIEVE_AANSPRAKELIJKHEID_BRAND_ONTPLOFFING', N'Objectieve Aansprakelijkheid Brand & Ontploffing', 1),
    (N'ONGEVALLEN_ALGEMEEN',           N'Ongevallen algemeen',                1),
    (N'ONGEVALLEN_PRIV_LEVEN',         N'Ongevallen privé leven',             1),
    (N'ONGEVALLEN_PRIV_L_VEN',         N'Ongevallen privéléven (spelling)',    1),
    (N'OPZOEKINGS_EN_REDDINGSKOSTEN',  N'Opzoekings- en Reddingskosten',      1),
    (N'OPZOEKING_REDDING_BERGING_EN_OPRUIMING', N'Opzoeking, redding, berging en opruiming', 1),
    (N'OVERLIJDEN',                    N'Overlijden',                         1),
    (N'OVERLIJDEN_NA_ONGEVAL',         N'Overlijden na ongeval',              1),
    (N'OVERSTROMING',                  N'Overstroming',                       1),
    (N'PENSIOENSPAREN',                N'Pensioensparen',                     1),
    (N'PERSOONLIJK_KREDIET',           N'Persoonlijk krediet',                1),
    (N'PLASTISCHE_CHIRURGIE',          N'Plastische chirurgie',               1),
    (N'PRE_EN_POST_HOSPITALISATIEKOSTEN', N'Pre- en post-hospitalisatiekosten', 1),
    (N'RECALL_EN_OPSPORINGSKOSTEN',    N'Recall- en opsporingskosten',        1),
    (N'RECHTSBIJSTAND',                N'Rechtsbijstand',                     1),
    (N'RECHTSBIJSTAND_BEROEP',         N'Rechtsbijstand beroep',              1),
    (N'RECHTSBIJSTAND_BEWONING',       N'Rechtsbijstand bewoning',            1),
    (N'RECHTSBIJSTAND_CONSUMENTENRECHT', N'Rechtsbijstand consumentenrecht',  1),
    (N'RECHTSBIJSTAND_KB',             N'Rechtsbijstand (KB)',                1),
    (N'RECHTSBIJSTAND_PRIV_LEVEN',     N'Rechtsbijstand privé leven',         1),
    (N'RECHTSBIJSTAND_VERKEER',        N'Rechtsbijstand verkeer',             1),
    (N'RECHTSBIJSTAND_VOERTUIG',       N'Rechtsbijstand (Voertuig)',          1),
    (N'REISGOED',                      N'Reisgoed',                           1),
    (N'REISONGEVALLEN',                N'Reis ongevallen',                    1),
    (N'REISVERZEKERING',               N'Reisverzekering',                    1),
    (N'RENTE_VOOR_VASTE_KOSTEN',       N'Rente voor vaste kosten',            1),
    (N'REPATRI_RING',                  N'Repatriëring',                       1),
    (N'ROOKSCHADE',                    N'Rookschade',                         1),
    (N'SANERING',                      N'Sanering',                           1),
    (N'SCHADE_AAN_BOUWWERKEN',         N'Schade aan bouwwerken',              1),
    (N'SCHULDSALDO',                   N'Schuldsaldo',                        1),
    (N'SNEEUWDRUK_B_S_R',              N'Sneeuwdruk (B.S.R.)',                1),
    (N'SOLIDARITEIT_VAPZ',             N'Solidariteit VAPZ',                  1),
    (N'SPRINKLERLEKKAGE',              N'Sprinklerlekkage',                   1),
    (N'SPROEISCHADE',                  N'Sproeischade',                       1),
    (N'STAKING_OPROER',                N'Staking & Oproer',                   1),
    (N'STORM_EN_HAGEL_B_S_R',          N'Storm en Hagel (B.S.R.)',            1),
    (N'STORM_HAGEL_EN_SNEEUWDRUK',     N'Storm, Hagel en Sneeuwdruk',         1),
    (N'STRAFRECHTELIJKE_BORG',         N'Strafrechtelijke borg',              1),
    (N'TANDBEHANDELINGSKOSTEN',        N'Tandbehandelingskosten',             1),
    (N'TECHNISCHE_VERZEKERINGEN',      N'Technische Verzekeringen',           1),
    (N'TIENJARIGE_AANSPRAKELIJKHEID_GEBOUW', N'Tienjarige Aansprakelijkheid Gebouw', 1),
    (N'TIJDELIJKE_INVALIDITEIT',       N'Tijdelijke invaliditeit',            1),
    (N'UITBREIDINGEN_BA_GEZIN',        N'Uitbreidingen BA Gezin',             1),
    (N'UITVAART',                      N'Uitvaart',                           1),
    (N'VANDALISME_EN_KWAADWILLIGHEID', N'Vandalisme en kwaadwilligheid',      1),
    (N'VANDALISME_VOERTUIG',           N'Vandalisme (Voertuig)',              1),
    (N'VERBLIJF_VAN_GOEDEREN',         N'Verblijf van goederen',              1),
    (N'VERBLIJF_VAN_WAARDEN_BIJ_AANGESTELDE', N'Verblijf van waarden bij aangestelde', 1),
    (N'VERBLIJF_VAN_WAARDEN_BUITEN_KLUIS',    N'Verblijf van waarden buiten kluis', 1),
    (N'VERBLIJF_VAN_WAARDEN_IN_BANKKLUIS',    N'Verblijf van waarden in bankkluis', 1),
    (N'VERBLIJF_VAN_WAARDEN_IN_EIGEN_KLUIS',  N'Verblijf van waarden in eigen kluis', 1),
    (N'VERBLIJF_VAN_WAARDEVOLLE_VOORWERPEN_IN_VITRINE', N'Verblijf van waardevolle voorwerpen in vitrine', 1),
    (N'VERBLIJF_WAARDEN_IN_KASSA',     N'Verblijf waarden in kassa',           1),
    (N'VERHAAL_VAN_BUREN',             N'Verhaal van buren',                  1),
    (N'VERKEERSRISICO_S_EN_AANSLAGEN', N'Verkeersrisico’s en aanslagen',      1),
    (N'VERLIES_VAN_HET_VLIEGBREVET',   N'Verlies van het vliegbrevet',        1),
    (N'VERVANGINGSKOSTEN',             N'Vervangingskosten',                  1),
    (N'VERVOERDE_GOEDEREN',            N'Vervoerde goederen',                 1),
    (N'VERVOER_VAN_WAARDEN',           N'Vervoer van waarden',                1),
    (N'VERZEKERINGSBON',               N'Verzekeringsbon',                    1),
    (N'VOERTUIGEN_IN_RUST',            N'Voertuigen in rust',                 1),
    (N'VOERTUIGEN_OVERAL',             N'Voertuigen overal',                  1),
    (N'VOLLEDIGE_OMNIUM',              N'Volledige Omnium',                   1),
    (N'WAARBORG_LEVERANCIER',          N'Waarborg leverancier',               1),
    (N'WACHTCONTRACT',                 N'Wachtcontract',                      1),
    (N'WATERSCHADE',                   N'Waterschade',                        1),
    (N'WEDERSAMENSTELLINGSKOSTEN',     N'Wedersamenstellingskosten',          1),
    (N'WEDER_SAMENSTELLINGS_KOSTEN',   N'Wedersamenstellingskosten (alt. spelling)', 1),
    (N'WEG_VAN_EN_NAAR_HET_WERK',      N'Weg van en naar het werk',           1),
    (N'WEG_VAN_EN_NAAR_HET_WERK_EXCEDENT', N'Weg van en naar het werk (excedent)', 1),
    (N'WIJZIGING_VAN_TEMPERATUUR',     N'Wijziging van temperatuur',          1),
    (N'ZIEKENHUISOPNAME',              N'Ziekenhuisopname',                   1),
    (N'ZIEKTE',                        N'Ziekte',                             1),
    (N'ZIEKTEN_COLLECTIEVE_VERZEKERINGEN', N'Ziekten (Collectieve Verzekeringen)', 1),
    (N'ZORGVERZEKERING',               N'Zorgverzekering',                    1)
) AS s(coverage_code, label_nl, is_active)
ON t.coverage_code = s.coverage_code
WHEN MATCHED THEN UPDATE
    SET t.label_nl = s.label_nl,
        t.is_active = s.is_active
WHEN NOT MATCHED THEN INSERT(coverage_code, label_nl, is_active)
    VALUES(s.coverage_code, s.label_nl, s.is_active);

/* ---------- Koppelingen Dekking ↔ ContractDomain (coverage_domain) ---------- */
MERGE coverage_domain AS t
USING (VALUES
 (N'AANRAKING_VOERTUIGEN', N'BRAND_BIJZONDERE'),
 (N'AANRAKING_VOERTUIGEN', N'BRAND_EENVOUDIG'),
 (N'AANRAKING_VOERTUIGEN', N'GEEN_DOMEIN'),
 (N'AANRAKING_VOERTUIGEN', N'MULTI_DOMEIN'),
 (N'AANRANDING', N'BIJSTAND'),
 (N'AANRANDING', N'GEEN_DOMEIN'),
 (N'AANRANDING', N'INDIVIDUELE'),
 (N'AANRANDING', N'MULTI_DOMEIN'),
 (N'AANRANDING', N'REIS'),
 (N'AANRIJDING_MET_WILD_VOERTUIG', N'GEEN_DOMEIN'),
 (N'AANRIJDING_MET_WILD_VOERTUIG', N'MULTI_DOMEIN'),
 (N'AANSLAGEN_EN_ARBEIDSCONFLICTEN', N'BRAND_BIJZONDERE'),
 (N'AANSLAGEN_EN_ARBEIDSCONFLICTEN', N'BRAND_EENVOUDIG'),
 (N'AANSLAGEN_EN_ARBEIDSCONFLICTEN', N'GEEN_DOMEIN'),
 (N'AANSLAGEN_EN_ARBEIDSCONFLICTEN', N'MULTI_DOMEIN'),
 (N'AANSLAGEN_EN_TERRORISME', N'BRAND_BIJZONDERE'),
 (N'AANSLAGEN_EN_TERRORISME', N'BRAND_EENVOUDIG'),
 (N'AANSLAGEN_EN_TERRORISME', N'GEEN_DOMEIN'),
 (N'AANSLAGEN_EN_TERRORISME', N'MULTI_DOMEIN'),
 (N'AANVULLENDE_WAARBORGEN', N'BA_PART'),
 (N'AANVULLENDE_WAARBORGEN', N'BELEGGING_23_26'),
 (N'AANVULLENDE_WAARBORGEN', N'BIJSTAND'),
 (N'AANVULLENDE_WAARBORGEN', N'BRAND_BIJZONDERE'),
 (N'AANVULLENDE_WAARBORGEN', N'BRAND_EENVOUDIG'),
 (N'AANVULLENDE_WAARBORGEN', N'DIVERSEN'),
 (N'AANVULLENDE_WAARBORGEN', N'GEEN_DOMEIN'),
 (N'AANVULLENDE_WAARBORGEN', N'HOSPITALISATIE'),
 (N'AANVULLENDE_WAARBORGEN', N'INDIVIDUELE'),
 (N'AANVULLENDE_WAARBORGEN', N'LEVEN_BELEGGINGEN'),
 (N'AANVULLENDE_WAARBORGEN', N'MULTI_DOMEIN'),
 (N'AANVULLENDE_WAARBORGEN', N'OBJECTIEVE_AANSPRAK'),
 (N'AANVULLENDE_WAARBORGEN', N'RECHTSBIJSTAND'),
 (N'AANVULLENDE_WAARBORGEN', N'REIS'),
 (N'AANVULLENDE_WAARBORGEN', N'TRANSPORT_MARINE'),
 (N'AANVULLENDE_WAARBORGEN_BRAND', N'BRAND_BIJZONDERE'),
 (N'AANVULLENDE_WAARBORGEN_BRAND', N'BRAND_EENVOUDIG'),
 (N'AANVULLENDE_WAARBORGEN_BRAND', N'DIVERSEN'),
 (N'AANVULLENDE_WAARBORGEN_BRAND', N'GEEN_DOMEIN'),
 (N'AANVULLENDE_WAARBORGEN_BRAND', N'MULTI_DOMEIN'),
 (N'AARDBEVING', N'BRAND_BIJZONDERE'),
 (N'AARDBEVING', N'BRAND_EENVOUDIG'),
 (N'AARDBEVING', N'GEEN_DOMEIN'),
 (N'AARDBEVING', N'MULTI_DOMEIN'),
 (N'ABR_SCHADE_AAN_BESTAAND_GOED', N'BRAND_EENVOUDIG'),
 (N'ABR_SCHADE_AAN_BESTAAND_GOED', N'DIVERSEN'),
 (N'ABR_SCHADE_AAN_BESTAAND_GOED', N'GEEN_DOMEIN'),
 (N'ABR_SCHADE_AAN_BESTAAND_GOED', N'MULTI_DOMEIN'),
 (N'AFHANKELIJKHEID', N'GEEN_DOMEIN'),
 (N'AFHANKELIJKHEID', N'LEVEN_BELEGGINGEN'),
 (N'AFHANKELIJKHEID', N'MULTI_DOMEIN'),
 (N'AFSTAND_VAN_VERHAAL', N'BA_PART'),
 (N'AFSTAND_VAN_VERHAAL', N'BRAND_BIJZONDERE'),
 (N'AFSTAND_VAN_VERHAAL', N'BRAND_EENVOUDIG'),
 (N'AFSTAND_VAN_VERHAAL', N'DIVERSEN'),
 (N'AFSTAND_VAN_VERHAAL', N'GEEN_DOMEIN'),
 (N'AFSTAND_VAN_VERHAAL', N'INDIVIDUELE'),
 (N'AFSTAND_VAN_VERHAAL', N'MULTI_DOMEIN'),
 (N'AFSTAND_VAN_VERHAAL', N'TRANSPORT_MARINE'),
 (N'ALLE_BOUWWERF_RISICO_S', N'BRAND_EENVOUDIG'),
 (N'ALLE_BOUWWERF_RISICO_S', N'DIVERSEN'),
 (N'ALLE_BOUWWERF_RISICO_S', N'GEEN_DOMEIN'),
 (N'ALLE_BOUWWERF_RISICO_S', N'MULTI_DOMEIN'),
 (N'ALLE_RISICO_S', N'BIJSTAND'),
 (N'ALLE_RISICO_S', N'BRAND_BIJZONDERE'),
 (N'ALLE_RISICO_S', N'BRAND_EENVOUDIG'),
 (N'ALLE_RISICO_S', N'DIVERSEN'),
 (N'ALLE_RISICO_S', N'GEEN_DOMEIN'),
 (N'ALLE_RISICO_S', N'MULTI_DOMEIN'),
 (N'ALLE_RISICO_S', N'REIS'),
 (N'ALLE_RISICO_S_TRANSPORT', N'DIVERSEN'),
 (N'ALLE_RISICO_S_TRANSPORT', N'GEEN_DOMEIN'),
 (N'ALLE_RISICO_S_TRANSPORT', N'MULTI_DOMEIN'),
 (N'ALLE_RISICO_S_TRANSPORT', N'TRANSPORT_MARINE'),
 (N'AMBULANTE_MEDISCHE_KOSTEN', N'GEEN_DOMEIN'),
 (N'AMBULANTE_MEDISCHE_KOSTEN', N'HOSPITALISATIE'),
 (N'AMBULANTE_MEDISCHE_KOSTEN', N'INDIVIDUELE'),
 (N'AMBULANTE_MEDISCHE_KOSTEN', N'MULTI_DOMEIN'),
 (N'ANNULERING', N'BIJSTAND'),
 (N'ANNULERING', N'GEEN_DOMEIN'),
 (N'ANNULERING', N'MULTI_DOMEIN'),
 (N'ANNULERING', N'REIS'),
 (N'ARBEIDSONGEVALLEN', N'GEEN_DOMEIN'),
 (N'ARBEIDSONGEVALLEN', N'MULTI_DOMEIN'),
 (N'ARBEIDSRISICO', N'GEEN_DOMEIN'),
 (N'ARBEIDSRISICO', N'MULTI_DOMEIN'),
 (N'ARBEIDSRISICO_EXCEDENT', N'GEEN_DOMEIN'),
 (N'ARBEIDSRISICO_EXCEDENT', N'MULTI_DOMEIN'),
 (N'AVRH', N'GEEN_DOMEIN'),
 (N'AVRH', N'LEVEN_BELEGGINGEN'),
 (N'AVRH', N'MULTI_DOMEIN'),
 (N'AVRI_KAPITAAL', N'BELEGGING_23_26'),
 (N'AVRI_KAPITAAL', N'GEEN_DOMEIN'),
 (N'AVRI_KAPITAAL', N'LEVEN_BELEGGINGEN'),
 (N'AVRI_KAPITAAL', N'MULTI_DOMEIN'),
 (N'AVRI_PREMIE', N'BELEGGING_23_26'),
 (N'AVRI_PREMIE', N'GEEN_DOMEIN'),
 (N'AVRI_PREMIE', N'LEVEN_BELEGGINGEN'),
 (N'AVRI_PREMIE', N'MULTI_DOMEIN'),
 (N'AVRI_RENTE', N'BELEGGING_23_26'),
 (N'AVRI_RENTE', N'GEEN_DOMEIN'),
 (N'AVRI_RENTE', N'LEVEN_BELEGGINGEN'),
 (N'AVRI_RENTE', N'MULTI_DOMEIN'),
 (N'AVRI_VASTE_KOSTEN', N'BELEGGING_23_26'),
 (N'AVRI_VASTE_KOSTEN', N'GEEN_DOMEIN'),
 (N'AVRI_VASTE_KOSTEN', N'LEVEN_BELEGGINGEN'),
 (N'AVRI_VASTE_KOSTEN', N'MULTI_DOMEIN'),
 (N'AVRI_VOORSCHOT', N'BELEGGING_23_26'),
 (N'AVRI_VOORSCHOT', N'GEEN_DOMEIN'),
 (N'AVRI_VOORSCHOT', N'LEVEN_BELEGGINGEN'),
 (N'AVRI_VOORSCHOT', N'MULTI_DOMEIN'),
 (N'AVRO', N'BELEGGING_23_26'),
 (N'AVRO', N'GEEN_DOMEIN'),
 (N'AVRO', N'LEVEN_BELEGGINGEN'),
 (N'AVRO', N'MULTI_DOMEIN'),
 (N'AVRO_INVALIDITEIT', N'GEEN_DOMEIN'),
 (N'AVRO_INVALIDITEIT', N'LEVEN_BELEGGINGEN'),
 (N'AVRO_INVALIDITEIT', N'MULTI_DOMEIN'),
 (N'AVR_H', N'BELEGGING_23_26'),
 (N'AV_FAMILIALE', N'GEEN_DOMEIN'),
 (N'AV_FAMILIALE', N'LEVEN_BELEGGINGEN'),
 (N'AV_FAMILIALE', N'MULTI_DOMEIN'),
 (N'BANKWAARBORG', N'DIVERSEN'),
 (N'BANKWAARBORG', N'GEEN_DOMEIN'),
 (N'BA_ALGEMEEN', N'BA_PART'),
 (N'BA_ALGEMEEN', N'BIJSTAND'),
 (N'BA_ALGEMEEN', N'DIVERSEN'),
 (N'BA_ALGEMEEN', N'GEEN_DOMEIN'),
 (N'BA_ALGEMEEN', N'INDIVIDUELE'),
 (N'BA_ALGEMEEN', N'MULTI_DOMEIN'),
 (N'BA_ALGEMEEN', N'OBJECTIEVE_AANSPRAK'),
 (N'BA_ALGEMEEN', N'REIS'),
 (N'BA_ALGEMEEN', N'TRANSPORT_MARINE'),
 (N'BA_BEROEP', N'BA_PART'),
 (N'BA_BEROEP', N'GEEN_DOMEIN'),
 (N'BA_BEROEP', N'MULTI_DOMEIN'),
 (N'BA_BEROEP', N'OBJECTIEVE_AANSPRAK'),
 (N'BA_BEWAARNE_MER', N'GEEN_DOMEIN'),
 (N'BA_BEWAARNE_MER', N'MULTI_DOMEIN'),
 (N'BA_BEZITTINGEN', N'BRAND_BIJZONDERE'),
 (N'BA_BEZITTINGEN', N'BRAND_EENVOUDIG'),
 (N'BA_BEZITTINGEN', N'GEEN_DOMEIN'),
 (N'BA_BEZITTINGEN', N'MULTI_DOMEIN'),
 (N'BA_BEZITTINGEN', N'OBJECTIEVE_AANSPRAK'),
 (N'BA_BURENHINDER_CONTRACTUEEL_VERWORVEN', N'DIVERSEN'),
 (N'BA_BURENHINDER_CONTRACTUEEL_VERWORVEN', N'GEEN_DOMEIN'),
 (N'BA_BURENHINDER_CONTRACTUEEL_VERWORVEN', N'MULTI_DOMEIN'),
 (N'BA_COMMISSIONAIR_EXPEDITEUR', N'GEEN_DOMEIN'),
 (N'BA_COMMISSIONAIR_EXPEDITEUR', N'MULTI_DOMEIN'),
 (N'BA_COMMISSIONAIR_EXPEDITEUR', N'TRANSPORT_MARINE'),
 (N'BA_EIGENAAR_JACHTGEBIED', N'BA_PART'),
 (N'BA_EIGENAAR_JACHTGEBIED', N'GEEN_DOMEIN'),
 (N'BA_EIGENAAR_JACHTGEBIED', N'MULTI_DOMEIN'),
 (N'BA_GEZIN_KB', N'BA_PART'),
 (N'BA_GEZIN_KB', N'GEEN_DOMEIN'),
 (N'BA_GEZIN_KB', N'MULTI_DOMEIN'),
 (N'BA_GEZIN_KB_WAARBORGUITBREIDINGEN', N'BA_PART'),
 (N'BA_GEZIN_KB_WAARBORGUITBREIDINGEN', N'GEEN_DOMEIN'),
 (N'BA_GEZIN_KB_WAARBORGUITBREIDINGEN', N'MULTI_DOMEIN'),
 (N'BA_IMMATERI_LE_GEVOLGSCHADE', N'BA_PART'),
 (N'BA_IMMATERI_LE_GEVOLGSCHADE', N'GEEN_DOMEIN'),
 (N'BA_IMMATERI_LE_GEVOLGSCHADE', N'MULTI_DOMEIN'),
 (N'BA_IMMATERI_LE_GEVOLGSCHADE', N'OBJECTIEVE_AANSPRAK'),
 (N'BA_INDIRECTE_VERLIEZEN', N'GEEN_DOMEIN'),
 (N'BA_INDIRECTE_VERLIEZEN', N'MULTI_DOMEIN'),
 (N'BA_INDIRECTE_VERLIEZEN', N'OBJECTIEVE_AANSPRAK'),
 (N'BA_INITIAL_PUBLIC_OFFERING', N'GEEN_DOMEIN'),
 (N'BA_INITIAL_PUBLIC_OFFERING', N'MULTI_DOMEIN'),
 (N'BA_JACHTWACHTER', N'BA_PART'),
 (N'BA_JACHTWACHTER', N'GEEN_DOMEIN'),
 (N'BA_JACHTWACHTER', N'MULTI_DOMEIN'),
 (N'BA_JAGERS', N'BA_PART'),
 (N'BA_JAGERS', N'GEEN_DOMEIN'),
 (N'BA_JAGERS', N'MULTI_DOMEIN'),
 (N'BA_LASTHEBBERS_VAN_VENNOOTSCHAPPEN', N'GEEN_DOMEIN'),
 (N'BA_LASTHEBBERS_VAN_VENNOOTSCHAPPEN', N'MULTI_DOMEIN'),
 (N'BA_LICHAMELIJKE_SCHADE', N'BA_PART'),
 (N'BA_LICHAMELIJKE_SCHADE', N'GEEN_DOMEIN'),
 (N'BA_LICHAMELIJKE_SCHADE', N'MULTI_DOMEIN'),
 (N'BA_LICHAMELIJKE_SCHADE', N'OBJECTIEVE_AANSPRAK'),
 (N'BA_MATERI_LE_SCHADE', N'BA_PART'),
 (N'BA_MATERI_LE_SCHADE', N'GEEN_DOMEIN'),
 (N'BA_MATERI_LE_SCHADE', N'MULTI_DOMEIN'),
 (N'BA_MATERI_LE_SCHADE', N'OBJECTIEVE_AANSPRAK'),
 (N'BA_MILIEU', N'BA_PART'),
 (N'BA_MILIEU', N'GEEN_DOMEIN'),
 (N'BA_MILIEU', N'MULTI_DOMEIN'),
 (N'BA_MILIEU', N'OBJECTIEVE_AANSPRAK'),
 (N'BA_MOTORVOERTUIG', N'GEEN_DOMEIN'),
 (N'BA_MOTORVOERTUIG', N'MULTI_DOMEIN'),
 (N'BA_NA_LEVERING', N'GEEN_DOMEIN'),
 (N'BA_NA_LEVERING', N'MULTI_DOMEIN'),
 (N'BA_ONSTOFFELIJKE_SCHADE', N'BA_PART'),
 (N'BA_ONSTOFFELIJKE_SCHADE', N'GEEN_DOMEIN'),
 (N'BA_ONSTOFFELIJKE_SCHADE', N'MULTI_DOMEIN'),
 (N'BA_ONSTOFFELIJKE_SCHADE', N'OBJECTIEVE_AANSPRAK'),
 (N'BA_PRODUCTEN', N'GEEN_DOMEIN'),
 (N'BA_PRODUCTEN', N'MULTI_DOMEIN'),
 (N'BA_TEN_OPZICHTE_VAN_WATERSKI_RS', N'BA_PART'),
 (N'BA_TEN_OPZICHTE_VAN_WATERSKI_RS', N'GEEN_DOMEIN'),
 (N'BA_TEN_OPZICHTE_VAN_WATERSKI_RS', N'MULTI_DOMEIN'),
 (N'BA_TEN_OPZICHTE_VAN_WATERSKI_RS', N'TRANSPORT_MARINE'),
 (N'BA_TOEVERTROUWDE_VOORWERPEN', N'BA_PART'),
 (N'BA_TOEVERTROUWDE_VOORWERPEN', N'GEEN_DOMEIN'),
 (N'BA_TOEVERTROUWDE_VOORWERPEN', N'MULTI_DOMEIN'),
 (N'BA_TOEVERTROUWDE_VOORWERPEN', N'OBJECTIEVE_AANSPRAK'),
 (N'BA_TOEVERTROUWD_GEREEDSCHAP', N'BA_PART'),
 (N'BA_TOEVERTROUWD_GEREEDSCHAP', N'GEEN_DOMEIN'),
 (N'BA_TOEVERTROUWD_GEREEDSCHAP', N'MULTI_DOMEIN'),
 (N'BA_TOEVERTROUWD_GEREEDSCHAP', N'OBJECTIEVE_AANSPRAK'),
 (N'BA_UITBATING', N'BIJSTAND'),
 (N'BA_UITBATING', N'GEEN_DOMEIN'),
 (N'BA_UITBATING', N'MULTI_DOMEIN'),
 (N'BA_UITBATING', N'OBJECTIEVE_AANSPRAK'),
 (N'BA_UITBATING', N'REIS'),
 (N'BA_VERVOERDER', N'GEEN_DOMEIN'),
 (N'BA_VERVOERDER', N'MULTI_DOMEIN'),
 (N'BA_VERVOERDER', N'TRANSPORT_MARINE'),
 (N'BA_WERKING', N'GEEN_DOMEIN'),
 (N'BA_WERKING', N'MULTI_DOMEIN'),
 (N'BA_WERKING', N'TRANSPORT_MARINE'),
 (N'BEDRIJFSSCHADE', N'BRAND_BIJZONDERE'),
 (N'BEDRIJFSSCHADE', N'BRAND_EENVOUDIG'),
 (N'BEDRIJFSSCHADE', N'GEEN_DOMEIN'),
 (N'BEDRIJFSSCHADE', N'MULTI_DOMEIN'),
 (N'BEGRAFENISKOSTEN', N'GEEN_DOMEIN'),
 (N'BEGRAFENISKOSTEN', N'INDIVIDUELE'),
 (N'BEGRAFENISKOSTEN', N'MULTI_DOMEIN'),
 (N'BEHANDELINGSKOSTEN_VAN_ZWARE_ZIEKTEN', N'GEEN_DOMEIN'),
 (N'BEHANDELINGSKOSTEN_VAN_ZWARE_ZIEKTEN', N'HOSPITALISATIE'),
 (N'BEHANDELINGSKOSTEN_VAN_ZWARE_ZIEKTEN', N'INDIVIDUELE'),
 (N'BEHANDELINGSKOSTEN_VAN_ZWARE_ZIEKTEN', N'MULTI_DOMEIN'),
 (N'BEMESTINGSSCHADE', N'GEEN_DOMEIN'),
 (N'BEMESTINGSSCHADE', N'MULTI_DOMEIN'),
 (N'BESCHADIGING_ONROERENDE', N'BRAND_BIJZONDERE'),
 (N'BESCHADIGING_ONROERENDE', N'BRAND_EENVOUDIG'),
 (N'BESCHADIGING_ONROERENDE', N'GEEN_DOMEIN'),
 (N'BESCHADIGING_ONROERENDE', N'MULTI_DOMEIN'),
 (N'BESCHADIGING_ROERENDE_GOEDEREN', N'BRAND_BIJZONDERE'),
 (N'BESCHADIGING_ROERENDE_GOEDEREN', N'BRAND_EENVOUDIG'),
 (N'BESCHADIGING_ROERENDE_GOEDEREN', N'GEEN_DOMEIN'),
 (N'BESCHADIGING_ROERENDE_GOEDEREN', N'MULTI_DOMEIN'),
 (N'BESTENDIGE_INVALIDITEIT', N'BIJSTAND'),
 (N'BESTENDIGE_INVALIDITEIT', N'GEEN_DOMEIN'),
 (N'BESTENDIGE_INVALIDITEIT', N'INDIVIDUELE'),
 (N'BESTENDIGE_INVALIDITEIT', N'MULTI_DOMEIN'),
 (N'BESTENDIGE_INVALIDITEIT', N'REIS'),
 (N'BESTENDIGE_INVALIDITEIT', N'TRANSPORT_MARINE'),
 (N'BESTUURDER', N'GEEN_DOMEIN'),
 (N'BESTUURDER', N'INDIVIDUELE'),
 (N'BESTUURDER', N'MULTI_DOMEIN'),
 (N'BIJSTAND', N'BA_PART'),
 (N'BIJSTAND', N'BIJSTAND'),
 (N'BIJSTAND', N'BRAND_BIJZONDERE'),
 (N'BIJSTAND', N'BRAND_EENVOUDIG'),
 (N'BIJSTAND', N'DIVERSEN'),
 (N'BIJSTAND', N'GEEN_DOMEIN'),
 (N'BIJSTAND', N'HOSPITALISATIE'),
 (N'BIJSTAND', N'INDIVIDUELE'),
 (N'BIJSTAND', N'LEVEN_BELEGGINGEN'),
 (N'BIJSTAND', N'MULTI_DOMEIN'),
 (N'BIJSTAND', N'RECHTSBIJSTAND'),
 (N'BIJSTAND', N'REIS'),
 (N'BIJSTAND', N'TRANSPORT_MARINE'),
 (N'BRANDWONDEN', N'BRAND_BIJZONDERE'),
 (N'BRANDWONDEN', N'BRAND_EENVOUDIG'),
 (N'BRANDWONDEN', N'GEEN_DOMEIN'),
 (N'BRANDWONDEN', N'MULTI_DOMEIN'),
 (N'BRAND_ALGEMEEN', N'BRAND_BIJZONDERE'),
 (N'BRAND_ALGEMEEN', N'BRAND_EENVOUDIG'),
 (N'BRAND_ALGEMEEN', N'GEEN_DOMEIN'),
 (N'BRAND_ALGEMEEN', N'MULTI_DOMEIN'),
 (N'BRAND_ALLEEN', N'BRAND_BIJZONDERE'),
 (N'BRAND_ALLEEN', N'BRAND_EENVOUDIG'),
 (N'BRAND_ALLEEN', N'GEEN_DOMEIN'),
 (N'BRAND_ALLEEN', N'MULTI_DOMEIN'),
 (N'BRAND_VOERTUIG', N'GEEN_DOMEIN'),
 (N'BRAND_VOERTUIG', N'MULTI_DOMEIN'),
 (N'BRAND_VOERTUIG', N'TRANSPORT_MARINE'),
 (N'BRAND_ZONDER_FLEXA_B_S_R', N'BRAND_BIJZONDERE'),
 (N'BRAND_ZONDER_FLEXA_B_S_R', N'DIVERSEN'),
 (N'BRAND_ZONDER_FLEXA_B_S_R', N'GEEN_DOMEIN'),
 (N'BRAND_ZONDER_FLEXA_B_S_R', N'MULTI_DOMEIN'),
 (N'B_A_WERF', N'BA_PART'),
 (N'B_A_WERF', N'BRAND_EENVOUDIG'),
 (N'B_A_WERF', N'GEEN_DOMEIN'),
 (N'B_A_WERF', N'MULTI_DOMEIN'),
 (N'B_A_WERF', N'OBJECTIEVE_AANSPRAK'),
 (N'CASCO_EN_MACHINES', N'BA_PART'),
 (N'CASCO_EN_MACHINES', N'GEEN_DOMEIN'),
 (N'CASCO_EN_MACHINES', N'MULTI_DOMEIN'),
 (N'CASCO_EN_MACHINES', N'TRANSPORT_MARINE'),
 (N'CASCO_VAN_HET_VERVOERMIDDEL', N'BA_PART'),
 (N'CASCO_VAN_HET_VERVOERMIDDEL', N'GEEN_DOMEIN'),
 (N'CASCO_VAN_HET_VERVOERMIDDEL', N'MULTI_DOMEIN'),
 (N'CASCO_VAN_HET_VERVOERMIDDEL', N'TRANSPORT_MARINE'),
 (N'COLLECTIEVE_ONGEVALLEN', N'BIJSTAND'),
 (N'COLLECTIEVE_ONGEVALLEN', N'GEEN_DOMEIN'),
 (N'COLLECTIEVE_ONGEVALLEN', N'MULTI_DOMEIN'),
 (N'COLLECTIEVE_ONGEVALLEN', N'REIS'),
 (N'COMMERCI_LE_ONBRUIKBAARHEID', N'BRAND_EENVOUDIG'),
 (N'COMMERCI_LE_ONBRUIKBAARHEID', N'GEEN_DOMEIN'),
 (N'COMMERCI_LE_ONBRUIKBAARHEID', N'MULTI_DOMEIN'),
 (N'CONTROLEVERZEKERING', N'DIVERSEN'),
 (N'CONTROLEVERZEKERING', N'GEEN_DOMEIN'),
 (N'CONTROLEVERZEKERING', N'MULTI_DOMEIN'),
 (N'DAGVERGOEDING_HOSPITALISATIE', N'GEEN_DOMEIN'),
 (N'DAGVERGOEDING_HOSPITALISATIE', N'HOSPITALISATIE'),
 (N'DAGVERGOEDING_HOSPITALISATIE', N'INDIVIDUELE'),
 (N'DAGVERGOEDING_HOSPITALISATIE', N'MULTI_DOMEIN'),
 (N'DIEFSTAL', N'BRAND_BIJZONDERE'),
 (N'DIEFSTAL', N'BRAND_EENVOUDIG'),
 (N'DIEFSTAL', N'DIVERSEN'),
 (N'DIEFSTAL', N'GEEN_DOMEIN'),
 (N'DIEFSTAL', N'MULTI_DOMEIN'),
 (N'DIEFSTAL', N'TRANSPORT_MARINE'),
 (N'DIEFSTAL_VAN_WAARDEN', N'BIJSTAND'),
 (N'DIEFSTAL_VAN_WAARDEN', N'BRAND_BIJZONDERE'),
 (N'DIEFSTAL_VAN_WAARDEN', N'BRAND_EENVOUDIG'),
 (N'DIEFSTAL_VAN_WAARDEN', N'DIVERSEN'),
 (N'DIEFSTAL_VAN_WAARDEN', N'GEEN_DOMEIN'),
 (N'DIEFSTAL_VAN_WAARDEN', N'MULTI_DOMEIN'),
 (N'DIEFSTAL_VAN_WAARDEN', N'REIS'),
 (N'DIEFSTAL_VAN_WAARDEN', N'TRANSPORT_MARINE'),
 (N'DIEFSTAL_VOERTUIG', N'GEEN_DOMEIN'),
 (N'DIEFSTAL_VOERTUIG', N'MULTI_DOMEIN'),
 (N'DIEFSTAL_VOERTUIG', N'TRANSPORT_MARINE'),
 (N'DIERENVERZEKERINGEN', N'BRAND_BIJZONDERE'),
 (N'DIERENVERZEKERINGEN', N'BRAND_EENVOUDIG'),
 (N'DIERENVERZEKERINGEN', N'DIVERSEN'),
 (N'DIERENVERZEKERINGEN', N'GEEN_DOMEIN'),
 (N'DIERENVERZEKERINGEN', N'MULTI_DOMEIN'),
 (N'EIGEN_SCHADE', N'DIVERSEN'),
 (N'EIGEN_SCHADE', N'GEEN_DOMEIN'),
 (N'EIGEN_SCHADE', N'MULTI_DOMEIN'),
 (N'ELEKTRICITEIT', N'BRAND_BIJZONDERE'),
 (N'ELEKTRICITEIT', N'BRAND_EENVOUDIG'),
 (N'ELEKTRICITEIT', N'GEEN_DOMEIN'),
 (N'ELEKTRICITEIT', N'MULTI_DOMEIN'),
 (N'ELEKTRICITEIT_ELECTRONICA', N'BRAND_BIJZONDERE'),
 (N'ELEKTRICITEIT_ELECTRONICA', N'BRAND_EENVOUDIG'),
 (N'ELEKTRICITEIT_ELECTRONICA', N'DIVERSEN'),
 (N'ELEKTRICITEIT_ELECTRONICA', N'GEEN_DOMEIN'),
 (N'ELEKTRICITEIT_ELECTRONICA', N'MULTI_DOMEIN'),
 (N'EXCEDENT', N'GEEN_DOMEIN'),
 (N'EXCEDENT', N'MULTI_DOMEIN'),
 (N'EXPERTISEKOSTEN', N'BRAND_BIJZONDERE'),
 (N'EXPERTISEKOSTEN', N'BRAND_EENVOUDIG'),
 (N'EXPERTISEKOSTEN', N'DIVERSEN'),
 (N'EXPERTISEKOSTEN', N'GEEN_DOMEIN'),
 (N'EXPERTISEKOSTEN', N'MULTI_DOMEIN'),
 (N'EXPERTISEKOSTEN', N'TRANSPORT_MARINE'),
 (N'EXPERTISE_KOSTEN_BEDRIJFSSCHADE', N'BRAND_BIJZONDERE'),
 (N'EXPERTISE_KOSTEN_BEDRIJFSSCHADE', N'BRAND_EENVOUDIG'),
 (N'EXPERTISE_KOSTEN_BEDRIJFSSCHADE', N'GEEN_DOMEIN'),
 (N'EXPERTISE_KOSTEN_BEDRIJFSSCHADE', N'MULTI_DOMEIN'),
 (N'FINANCIERING', N'GEEN_DOMEIN'),
 (N'GEBRUIKSDERVING', N'GEEN_DOMEIN'),
 (N'GEBRUIKSDERVING', N'MULTI_DOMEIN'),
 (N'GEDEELTELIJKE_OMNIUM', N'GEEN_DOMEIN'),
 (N'GEDEELTELIJKE_OMNIUM', N'MULTI_DOMEIN'),
 (N'GELDELIJKE_VERLIEZEN', N'BA_PART'),
 (N'GELDELIJKE_VERLIEZEN', N'BIJSTAND'),
 (N'GELDELIJKE_VERLIEZEN', N'BRAND_BIJZONDERE'),
 (N'GELDELIJKE_VERLIEZEN', N'BRAND_EENVOUDIG'),
 (N'GELDELIJKE_VERLIEZEN', N'DIVERSEN'),
 (N'GELDELIJKE_VERLIEZEN', N'GEEN_DOMEIN'),
 (N'GELDELIJKE_VERLIEZEN', N'HOSPITALISATIE'),
 (N'GELDELIJKE_VERLIEZEN', N'INDIVIDUELE'),
 (N'GELDELIJKE_VERLIEZEN', N'LEVEN_BELEGGINGEN'),
 (N'GELDELIJKE_VERLIEZEN', N'MULTI_DOMEIN'),
 (N'GELDELIJKE_VERLIEZEN', N'RECHTSBIJSTAND'),
 (N'GELDELIJKE_VERLIEZEN', N'REIS'),
 (N'GEMENGDE_LEVEN', N'GEEN_DOMEIN'),
 (N'GEMENGDE_LEVEN', N'LEVEN_BELEGGINGEN'),
 (N'GEMENGDE_LEVEN', N'MULTI_DOMEIN'),
 (N'GEWAARBORGD_INKOMEN', N'GEEN_DOMEIN'),
 (N'GEWAARBORGD_INKOMEN', N'INDIVIDUELE'),
 (N'GEWAARBORGD_INKOMEN', N'MULTI_DOMEIN'),
 (N'GEWAARBORGD_INKOMEN_COLLECTIEVE_VERZEKERINGEN', N'GEEN_DOMEIN'),
 (N'GEWAARBORGD_INKOMEN_COLLECTIEVE_VERZEKERINGEN', N'MULTI_DOMEIN'),
 (N'GEWAARBORGD_LOON', N'GEEN_DOMEIN'),
 (N'GEWAARBORGD_LOON', N'MULTI_DOMEIN'),
 (N'GEWAARBORGD_LOON_BEDR_S', N'BRAND_BIJZONDERE'),
 (N'GEWAARBORGD_LOON_BEDR_S', N'BRAND_EENVOUDIG'),
 (N'GEWAARBORGD_LOON_BEDR_S', N'DIVERSEN'),
 (N'GEWAARBORGD_LOON_BEDR_S', N'GEEN_DOMEIN'),
 (N'GEWAARBORGD_LOON_BEDR_S', N'MULTI_DOMEIN'),
 (N'GLASBRAAK', N'BRAND_BIJZONDERE'),
 (N'GLASBRAAK', N'BRAND_EENVOUDIG'),
 (N'GLASBRAAK', N'GEEN_DOMEIN'),
 (N'GLASBRAAK', N'MULTI_DOMEIN'),
 (N'GLASBRAAK_VOERTUIG', N'GEEN_DOMEIN'),
 (N'GLASBRAAK_VOERTUIG', N'MULTI_DOMEIN'),
 (N'HUISPERSONEEL', N'BA_PART'),
 (N'HUISPERSONEEL', N'GEEN_DOMEIN'),
 (N'HUISPERSONEEL', N'MULTI_DOMEIN'),
 (N'HUWELIJKSVOORZORG', N'GEEN_DOMEIN'),
 (N'HUWELIJKSVOORZORG', N'LEVEN_BELEGGINGEN'),
 (N'HUWELIJKSVOORZORG', N'MULTI_DOMEIN'),
 (N'HYPOTHECAIR_KREDIET', N'GEEN_DOMEIN'),
 (N'INBRAAKSCHADE', N'MULTI_DOMEIN'),
 (N'INBRAAKS_CHADE', N'BRAND_BIJZONDERE'),
 (N'INBRAAKS_CHADE', N'BRAND_EENVOUDIG'),
 (N'INBRAAKS_CHADE', N'GEEN_DOMEIN'),
 (N'INDIRECTE_VERLIEZEN', N'BRAND_BIJZONDERE'),
 (N'INDIRECTE_VERLIEZEN', N'BRAND_EENVOUDIG'),
 (N'INDIRECTE_VERLIEZEN', N'GEEN_DOMEIN'),
 (N'INDIRECTE_VERLIEZEN', N'MULTI_DOMEIN'),
 (N'INSOLVENTIE_VAN_DERDEN', N'BA_PART'),
 (N'INSOLVENTIE_VAN_DERDEN', N'BRAND_EENVOUDIG'),
 (N'INSOLVENTIE_VAN_DERDEN', N'GEEN_DOMEIN'),
 (N'INSOLVENTIE_VAN_DERDEN', N'MULTI_DOMEIN'),
 (N'INSOLVENTIE_VAN_DERDEN', N'OBJECTIEVE_AANSPRAK'),
 (N'INSOLVENTIE_VAN_DERDEN', N'RECHTSBIJSTAND'),
 (N'INSOLVENTIE_VAN_DERDEN', N'TRANSPORT_MARINE'),
 (N'INSTORTING_B_S_R', N'BRAND_BIJZONDERE'),
 (N'INSTORTING_B_S_R', N'DIVERSEN'),
 (N'INSTORTING_B_S_R', N'GEEN_DOMEIN'),
 (N'INSTORTING_B_S_R', N'MULTI_DOMEIN'),
 (N'INTERN_MISBRUIK_EN_FRAUDE', N'DIVERSEN'),
 (N'INTERN_MISBRUIK_EN_FRAUDE', N'GEEN_DOMEIN'),
 (N'INTERN_MISBRUIK_EN_FRAUDE', N'MULTI_DOMEIN'),
 (N'INTREKKING_RIJBEWIJS', N'GEEN_DOMEIN'),
 (N'INTREKKING_RIJBEWIJS', N'MULTI_DOMEIN'),
 (N'INTREKKING_RIJBEWIJS', N'RECHTSBIJSTAND'),
 (N'INVESTERINGSKREDIET', N'GEEN_DOMEIN'),
 (N'INZITTENDEN', N'GEEN_DOMEIN'),
 (N'INZITTENDEN', N'INDIVIDUELE'),
 (N'INZITTENDEN', N'MULTI_DOMEIN'),
 (N'INZITTENDEN', N'TRANSPORT_MARINE'),
 (N'JONGEREN_BIJKOMENDE', N'GEEN_DOMEIN'),
 (N'JONGEREN_BIJKOMENDE', N'LEVEN_BELEGGINGEN'),
 (N'JONGEREN_BIJKOMENDE', N'MULTI_DOMEIN'),
 (N'KASKREDIET', N'GEEN_DOMEIN'),
 (N'KLOPJACHTEN', N'BA_PART'),
 (N'KLOPJACHTEN', N'GEEN_DOMEIN'),
 (N'KLOPJACHTEN', N'MULTI_DOMEIN'),
 (N'KOSTEN_VAN_HULPMIDDELEN_EN_AANPASSING', N'DIVERSEN'),
 (N'KOSTEN_VAN_HULPMIDDELEN_EN_AANPASSING', N'GEEN_DOMEIN'),
 (N'KOSTEN_VAN_HULPMIDDELEN_EN_AANPASSING', N'INDIVIDUELE'),
 (N'KOSTEN_VAN_HULPMIDDELEN_EN_AANPASSING', N'MULTI_DOMEIN'),
 (N'KOSTEN_VAN_REPATRI_RING_EN_UITVAART', N'DIVERSEN'),
 (N'KOSTEN_VAN_REPATRI_RING_EN_UITVAART', N'GEEN_DOMEIN'),
 (N'KOSTEN_VAN_REPATRI_RING_EN_UITVAART', N'INDIVIDUELE'),
 (N'KOSTEN_VAN_REPATRI_RING_EN_UITVAART', N'MULTI_DOMEIN'),
 (N'LENING_ALGEMEEN', N'GEEN_DOMEIN'),
 (N'LENING_ALGEMEEN', N'MULTI_DOMEIN'),
 (N'LEVEN', N'BELEGGING_23_26'),
 (N'LEVEN', N'GEEN_DOMEIN'),
 (N'LEVEN', N'LEVEN_BELEGGINGEN'),
 (N'LEVEN', N'MULTI_DOMEIN'),
 (N'LEVENSLANGE', N'GEEN_DOMEIN'),
 (N'LEVENSLANGE', N'LEVEN_BELEGGINGEN'),
 (N'LEVENSLANGE', N'MULTI_DOMEIN'),
 (N'LEVERANCIERSAFHANKELIJKHEID', N'MULTI_DOMEIN'),
 (N'LEVERANCIERS_AANSPRAKELIJKHEID', N'BRAND_BIJZONDERE'),
 (N'LEVERANCIERS_AANSPRAKELIJKHEID', N'BRAND_EENVOUDIG'),
 (N'LEVERANCIERS_AANSPRAKELIJKHEID', N'DIVERSEN'),
 (N'LEVERANCIERS_AANSPRAKELIJKHEID', N'GEEN_DOMEIN'),
 (N'LITT_E', N'DIVERSEN'),
 (N'LITT_E', N'GEEN_DOMEIN'),
 (N'LITT_E', N'MULTI_DOMEIN'),
 (N'LITT_E', N'TRANSPORT_MARINE'),
 (N'LITT_I', N'DIVERSEN'),
 (N'LITT_I', N'GEEN_DOMEIN'),
 (N'LITT_I', N'MULTI_DOMEIN'),
 (N'LITT_I', N'TRANSPORT_MARINE'),
 (N'MACHINEBREUK', N'BRAND_BIJZONDERE'),
 (N'MACHINEBREUK', N'BRAND_EENVOUDIG'),
 (N'MACHINEBREUK', N'DIVERSEN'),
 (N'MACHINEBREUK', N'GEEN_DOMEIN'),
 (N'MACHINEBREUK', N'MULTI_DOMEIN'),
 (N'MACHINEBREUK', N'TRANSPORT_MARINE'),
 (N'MEDISCHE_CONTROLE', N'GEEN_DOMEIN'),
 (N'MEDISCHE_CONTROLE', N'MULTI_DOMEIN'),
 (N'MEDISCHE_KOSTEN', N'BIJSTAND'),
 (N'MEDISCHE_KOSTEN', N'GEEN_DOMEIN'),
 (N'MEDISCHE_KOSTEN', N'HOSPITALISATIE'),
 (N'MEDISCHE_KOSTEN', N'INDIVIDUELE'),
 (N'MEDISCHE_KOSTEN', N'MULTI_DOMEIN'),
 (N'MEDISCHE_KOSTEN', N'REIS'),
 (N'MEDISCHE_KOSTEN', N'TRANSPORT_MARINE'),
 (N'MONTAGE', N'DIVERSEN'),
 (N'MONTAGE', N'GEEN_DOMEIN'),
 (N'MONTAGE', N'MULTI_DOMEIN'),
 (N'NATUURKRACHTEN_VOERTUIG', N'GEEN_DOMEIN'),
 (N'NATUURKRACHTEN_VOERTUIG', N'MULTI_DOMEIN'),
 (N'NATUURRAMPEN_SPECIFIEK', N'BIJSTAND'),
 (N'NATUURRAMPEN_SPECIFIEK', N'BRAND_BIJZONDERE'),
 (N'NATUURRAMPEN_SPECIFIEK', N'BRAND_EENVOUDIG'),
 (N'NATUURRAMPEN_SPECIFIEK', N'GEEN_DOMEIN'),
 (N'NATUURRAMPEN_SPECIFIEK', N'MULTI_DOMEIN'),
 (N'NATUURRAMPEN_SPECIFIEK', N'REIS'),
 (N'NATUURRAMPEN_TARIFICATIEBUREAU', N'BRAND_BIJZONDERE'),
 (N'NATUURRAMPEN_TARIFICATIEBUREAU', N'BRAND_EENVOUDIG'),
 (N'NATUURRAMPEN_TARIFICATIEBUREAU', N'GEEN_DOMEIN'),
 (N'NATUURRAMPEN_TARIFICATIEBUREAU', N'MULTI_DOMEIN'),
 (N'OBJECTIEVE_AANSPRAKELIJKHEID_BRAND_ONTPLOFFING', N'BRAND_BIJZONDERE'),
 (N'OBJECTIEVE_AANSPRAKELIJKHEID_BRAND_ONTPLOFFING', N'BRAND_EENVOUDIG'),
 (N'OBJECTIEVE_AANSPRAKELIJKHEID_BRAND_ONTPLOFFING', N'GEEN_DOMEIN'),
 (N'OBJECTIEVE_AANSPRAKELIJKHEID_BRAND_ONTPLOFFING', N'MULTI_DOMEIN'),
 (N'OBJECTIEVE_AANSPRAKELIJKHEID_BRAND_ONTPLOFFING', N'OBJECTIEVE_AANSPRAK'),
 (N'ONGEVALLEN_ALGEMEEN', N'BIJSTAND'),
 (N'ONGEVALLEN_ALGEMEEN', N'GEEN_DOMEIN'),
 (N'ONGEVALLEN_ALGEMEEN', N'INDIVIDUELE'),
 (N'ONGEVALLEN_ALGEMEEN', N'MULTI_DOMEIN'),
 (N'ONGEVALLEN_ALGEMEEN', N'REIS'),
 (N'ONGEVALLEN_PRIV_LEVEN', N'BIJSTAND'),
 (N'ONGEVALLEN_PRIV_LEVEN', N'GEEN_DOMEIN'),
 (N'ONGEVALLEN_PRIV_LEVEN', N'INDIVIDUELE'),
 (N'ONGEVALLEN_PRIV_LEVEN', N'MULTI_DOMEIN'),
 (N'ONGEVALLEN_PRIV_LEVEN', N'REIS'),
 (N'ONGEVALLEN_PRIV_L_VEN', N'GEEN_DOMEIN'),
 (N'ONGEVALLEN_PRIV_L_VEN', N'MULTI_DOMEIN'),
 (N'ONGEVALLEN_PRIV_L_VEN', N'REIS'),
 (N'OPZOEKINGS_EN_REDDINGSKOSTEN', N'BIJSTAND'),
 (N'OPZOEKINGS_EN_REDDINGSKOSTEN', N'DIVERSEN'),
 (N'OPZOEKINGS_EN_REDDINGSKOSTEN', N'GEEN_DOMEIN'),
 (N'OPZOEKINGS_EN_REDDINGSKOSTEN', N'INDIVIDUELE'),
 (N'OPZOEKINGS_EN_REDDINGSKOSTEN', N'MULTI_DOMEIN'),
 (N'OPZOEKINGS_EN_REDDINGSKOSTEN', N'REIS'),
 (N'OPZOEKINGS_EN_REDDINGSKOSTEN', N'TRANSPORT_MARINE'),
 (N'OPZOEKING_REDDING_BERGING_EN_OPRUIMING', N'BA_PART'),
 (N'OPZOEKING_REDDING_BERGING_EN_OPRUIMING', N'GEEN_DOMEIN'),
 (N'OPZOEKING_REDDING_BERGING_EN_OPRUIMING', N'MULTI_DOMEIN'),
 (N'OPZOEKING_REDDING_BERGING_EN_OPRUIMING', N'TRANSPORT_MARINE'),
 (N'OVERLIJDEN', N'BELEGGING_23_26'),
 (N'OVERLIJDEN', N'GEEN_DOMEIN'),
 (N'OVERLIJDEN', N'LEVEN_BELEGGINGEN'),
 (N'OVERLIJDEN', N'MULTI_DOMEIN'),
 (N'OVERLIJDEN_NA_ONGEVAL', N'BELEGGING_23_26'),
 (N'OVERLIJDEN_NA_ONGEVAL', N'BIJSTAND'),
 (N'OVERLIJDEN_NA_ONGEVAL', N'GEEN_DOMEIN'),
 (N'OVERLIJDEN_NA_ONGEVAL', N'INDIVIDUELE'),
 (N'OVERLIJDEN_NA_ONGEVAL', N'LEVEN_BELEGGINGEN'),
 (N'OVERLIJDEN_NA_ONGEVAL', N'MULTI_DOMEIN'),
 (N'OVERLIJDEN_NA_ONGEVAL', N'REIS'),
 (N'OVERLIJDEN_NA_ONGEVAL', N'TRANSPORT_MARINE'),
 (N'OVERSTROMING', N'BRAND_BIJZONDERE'),
 (N'OVERSTROMING', N'BRAND_EENVOUDIG'),
 (N'OVERSTROMING', N'GEEN_DOMEIN'),
 (N'OVERSTROMING', N'MULTI_DOMEIN'),
 (N'PENSIOENSPAREN', N'BELEGGING_23_26'),
 (N'PENSIOENSPAREN', N'GEEN_DOMEIN'),
 (N'PENSIOENSPAREN', N'LEVEN_BELEGGINGEN'),
 (N'PENSIOENSPAREN', N'MULTI_DOMEIN'),
 (N'PERSOONLIJK_KREDIET', N'GEEN_DOMEIN'),
 (N'PLASTISCHE_CHIRURGIE', N'DIVERSEN'),
 (N'PLASTISCHE_CHIRURGIE', N'GEEN_DOMEIN'),
 (N'PLASTISCHE_CHIRURGIE', N'HOSPITALISATIE'),
 (N'PLASTISCHE_CHIRURGIE', N'INDIVIDUELE'),
 (N'PLASTISCHE_CHIRURGIE', N'MULTI_DOMEIN'),
 (N'PRE_EN_POST_HOSPITALISATIEKOSTEN', N'BIJSTAND'),
 (N'PRE_EN_POST_HOSPITALISATIEKOSTEN', N'GEEN_DOMEIN'),
 (N'PRE_EN_POST_HOSPITALISATIEKOSTEN', N'HOSPITALISATIE'),
 (N'PRE_EN_POST_HOSPITALISATIEKOSTEN', N'INDIVIDUELE'),
 (N'PRE_EN_POST_HOSPITALISATIEKOSTEN', N'MULTI_DOMEIN'),
 (N'PRE_EN_POST_HOSPITALISATIEKOSTEN', N'REIS'),
 (N'RECALL_EN_OPSPORINGSKOSTEN', N'DIVERSEN'),
 (N'RECALL_EN_OPSPORINGSKOSTEN', N'GEEN_DOMEIN'),
 (N'RECALL_EN_OPSPORINGSKOSTEN', N'MULTI_DOMEIN'),
 (N'RECHTSBIJSTAND', N'BIJSTAND'),
 (N'RECHTSBIJSTAND', N'BRAND_BIJZONDERE'),
 (N'RECHTSBIJSTAND', N'BRAND_EENVOUDIG'),
 (N'RECHTSBIJSTAND', N'DIVERSEN'),
 (N'RECHTSBIJSTAND', N'GEEN_DOMEIN'),
 (N'RECHTSBIJSTAND', N'INDIVIDUELE'),
 (N'RECHTSBIJSTAND', N'MULTI_DOMEIN'),
 (N'RECHTSBIJSTAND', N'RECHTSBIJSTAND'),
 (N'RECHTSBIJSTAND', N'REIS'),
 (N'RECHTSBIJSTAND', N'TRANSPORT_MARINE'),
 (N'RECHTSBIJSTAND_BEROEP', N'DIVERSEN'),
 (N'RECHTSBIJSTAND_BEROEP', N'GEEN_DOMEIN'),
 (N'RECHTSBIJSTAND_BEROEP', N'MULTI_DOMEIN'),
 (N'RECHTSBIJSTAND_BEROEP', N'OBJECTIEVE_AANSPRAK'),
 (N'RECHTSBIJSTAND_BEROEP', N'RECHTSBIJSTAND'),
 (N'RECHTSBIJSTAND_BEWONING', N'BRAND_BIJZONDERE'),
 (N'RECHTSBIJSTAND_BEWONING', N'BRAND_EENVOUDIG'),
 (N'RECHTSBIJSTAND_BEWONING', N'GEEN_DOMEIN'),
 (N'RECHTSBIJSTAND_BEWONING', N'MULTI_DOMEIN'),
 (N'RECHTSBIJSTAND_BEWONING', N'RECHTSBIJSTAND'),
 (N'RECHTSBIJSTAND_CONSUMENTENRECHT', N'DIVERSEN'),
 (N'RECHTSBIJSTAND_CONSUMENTENRECHT', N'GEEN_DOMEIN'),
 (N'RECHTSBIJSTAND_CONSUMENTENRECHT', N'MULTI_DOMEIN'),
 (N'RECHTSBIJSTAND_CONSUMENTENRECHT', N'RECHTSBIJSTAND'),
 (N'RECHTSBIJSTAND_KB', N'BA_PART'),
 (N'RECHTSBIJSTAND_KB', N'GEEN_DOMEIN'),
 (N'RECHTSBIJSTAND_KB', N'MULTI_DOMEIN'),
 (N'RECHTSBIJSTAND_KB', N'RECHTSBIJSTAND'),
 (N'RECHTSBIJSTAND_PRIV_LEVEN', N'BA_PART'),
 (N'RECHTSBIJSTAND_PRIV_LEVEN', N'BIJSTAND'),
 (N'RECHTSBIJSTAND_PRIV_LEVEN', N'GEEN_DOMEIN'),
 (N'RECHTSBIJSTAND_PRIV_LEVEN', N'MULTI_DOMEIN'),
 (N'RECHTSBIJSTAND_PRIV_LEVEN', N'RECHTSBIJSTAND'),
 (N'RECHTSBIJSTAND_PRIV_LEVEN', N'REIS'),
 (N'RECHTSBIJSTAND_PRIV_LEVEN', N'TRANSPORT_MARINE'),
 (N'RECHTSBIJSTAND_VERKEER', N'GEEN_DOMEIN'),
 (N'RECHTSBIJSTAND_VERKEER', N'MULTI_DOMEIN'),
 (N'RECHTSBIJSTAND_VERKEER', N'RECHTSBIJSTAND'),
 (N'RECHTSBIJSTAND_VOERTUIG', N'GEEN_DOMEIN'),
 (N'RECHTSBIJSTAND_VOERTUIG', N'MULTI_DOMEIN'),
 (N'REISGOED', N'BIJSTAND'),
 (N'REISGOED', N'GEEN_DOMEIN'),
 (N'REISGOED', N'INDIVIDUELE'),
 (N'REISGOED', N'MULTI_DOMEIN'),
 (N'REISGOED', N'REIS'),
 (N'REISONGVALLEN', N'BIJSTAND'),
 (N'REISONGVALLEN', N'GEEN_DOMEIN'),
 (N'REISONGVALLEN', N'INDIVIDUELE'),
 (N'REISONGVALLEN', N'MULTI_DOMEIN'),
 (N'REISONGVALLEN', N'REIS'),
 (N'REISVERZEKERING', N'BIJSTAND'),
 (N'REISVERZEKERING', N'GEEN_DOMEIN'),
 (N'REISVERZEKERING', N'MULTI_DOMEIN'),
 (N'REISVERZEKERING', N'REIS'),
 (N'RENTE_VOOR_VASTE_KOSTEN', N'GEEN_DOMEIN'),
 (N'RENTE_VOOR_VASTE_KOSTEN', N'INDIVIDUELE'),
 (N'RENTE_VOOR_VASTE_KOSTEN', N'LEVEN_BELEGGINGEN'),
 (N'REPATRI_RING', N'GEEN_DOMEIN'),
 (N'REPATRI_RING', N'MULTI_DOMEIN'),
 (N'REPATRI_RING_BIJ_OORLOGSRISICO_S', N'BIJSTAND'),
 (N'REPATRI_RING_BIJ_OORLOGSRISICO_S', N'GEEN_DOMEIN'),
 (N'REPATRI_RING_BIJ_OORLOGSRISICO_S', N'INDIVIDUELE'),
 (N'REPATRI_RING_BIJ_OORLOGSRISICO_S', N'MULTI_DOMEIN'),
 (N'REPATRI_RING_BIJ_OORLOGSRISICO_S', N'REIS'),
 (N'ROOKSCHADE', N'BRAND_BIJZONDERE'),
 (N'ROOKSCHADE', N'BRAND_EENVOUDIG'),
 (N'ROOKSCHADE', N'GEEN_DOMEIN'),
 (N'ROOKSCHADE', N'MULTI_DOMEIN'),
 (N'SANERING', N'BA_PART'),
 (N'SANERING', N'BRAND_BIJZONDERE'),
 (N'SANERING', N'BRAND_EENVOUDIG'),
 (N'SANERING', N'DIVERSEN'),
 (N'SANERING', N'GEEN_DOMEIN'),
 (N'SANERING', N'MULTI_DOMEIN'),
 (N'SANERING', N'OBJECTIEVE_AANSPRAK'),
 (N'SCHADE_AAN_BOUWWERKEN', N'BRAND_EENVOUDIG'),
 (N'SCHADE_AAN_BOUWWERKEN', N'GEEN_DOMEIN'),
 (N'SCHADE_AAN_BOUWWERKEN', N'MULTI_DOMEIN'),
 (N'SCHULDSALDO', N'BELEGGING_23_26'),
 (N'SCHULDSALDO', N'GEEN_DOMEIN'),
 (N'SCHULDSALDO', N'LEVEN_BELEGGINGEN'),
 (N'SCHULDSALDO', N'MULTI_DOMEIN'),
 (N'SNEEUWDRUK_B_S_R', N'BRAND_BIJZONDERE'),
 (N'SNEEUWDRUK_B_S_R', N'DIVERSEN'),
 (N'SNEEUWDRUK_B_S_R', N'GEEN_DOMEIN'),
 (N'SNEEUWDRUK_B_S_R', N'MULTI_DOMEIN'),
 (N'SOLIDARITEIT_VAPZ', N'GEEN_DOMEIN'),
 (N'SOLIDARITEIT_VAPZ', N'LEVEN_BELEGGINGEN'),
 (N'SOLIDARITEIT_VAPZ', N'MULTI_DOMEIN'),
 (N'SPRINKLERLEKKAGE', N'BRAND_BIJZONDERE'),
 (N'SPRINKLERLEKKAGE', N'BRAND_EENVOUDIG'),
 (N'SPRINKLERLEKKAGE', N'GEEN_DOMEIN'),
 (N'SPRINKLERLEKKAGE', N'MULTI_DOMEIN'),
 (N'SPROEISCHADE', N'GEEN_DOMEIN'),
 (N'SPROEISCHADE', N'MULTI_DOMEIN'),
 (N'STAKING_OPROER', N'BRAND_BIJZONDERE'),
 (N'STAKING_OPROER', N'BRAND_EENVOUDIG'),
 (N'STAKING_OPROER', N'GEEN_DOMEIN'),
 (N'STAKING_OPROER', N'MULTI_DOMEIN'),
 (N'STORM_EN_HAGEL_B_S_R', N'BRAND_BIJZONDERE'),
 (N'STORM_EN_HAGEL_B_S_R', N'DIVERSEN'),
 (N'STORM_EN_HAGEL_B_S_R', N'GEEN_DOMEIN'),
 (N'STORM_EN_HAGEL_B_S_R', N'MULTI_DOMEIN'),
 (N'STORM_HAGEL_EN_SNEEUWDRUK', N'BRAND_BIJZONDERE'),
 (N'STORM_HAGEL_EN_SNEEUWDRUK', N'BRAND_EENVOUDIG'),
 (N'STORM_HAGEL_EN_SNEEUWDRUK', N'GEEN_DOMEIN'),
 (N'STORM_HAGEL_EN_SNEEUWDRUK', N'MULTI_DOMEIN'),
 (N'STRAFRECHTELIJKE_BORG', N'BIJSTAND'),
 (N'STRAFRECHTELIJKE_BORG', N'GEEN_DOMEIN'),
 (N'STRAFRECHTELIJKE_BORG', N'MULTI_DOMEIN'),
 (N'STRAFRECHTELIJKE_BORG', N'RECHTSBIJSTAND'),
 (N'STRAFRECHTELIJKE_BORG', N'REIS'),
 (N'TANDBEHANDELINGSKOSTEN', N'GEEN_DOMEIN'),
 (N'TANDBEHANDELINGSKOSTEN', N'HOSPITALISATIE'),
 (N'TANDBEHANDELINGSKOSTEN', N'INDIVIDUELE'),
 (N'TANDBEHANDELINGSKOSTEN', N'MULTI_DOMEIN'),
 (N'TECHNISCHE_VERZEKERINGEN', N'DIVERSEN'),
 (N'TECHNISCHE_VERZEKERINGEN', N'GEEN_DOMEIN'),
 (N'TECHNISCHE_VERZEKERINGEN', N'MULTI_DOMEIN'),
 (N'TIENJARIGE_AANSPRAKELIJKHEID_GEBOUW', N'DIVERSEN'),
 (N'TIENJARIGE_AANSPRAKELIJKHEID_GEBOUW', N'GEEN_DOMEIN'),
 (N'TIENJARIGE_AANSPRAKELIJKHEID_GEBOUW', N'MULTI_DOMEIN'),
 (N'TIJDELIJKE_INVALIDITEIT', N'BIJSTAND'),
 (N'TIJDELIJKE_INVALIDITEIT', N'GEEN_DOMEIN'),
 (N'TIJDELIJKE_INVALIDITEIT', N'INDIVIDUELE'),
 (N'TIJDELIJKE_INVALIDITEIT', N'MULTI_DOMEIN'),
 (N'TIJDELIJKE_INVALIDITEIT', N'REIS'),
 (N'UITBREIDINGEN_BA_GEZIN', N'BA_PART'),
 (N'UITBREIDINGEN_BA_GEZIN', N'GEEN_DOMEIN'),
 (N'UITBREIDINGEN_BA_GEZIN', N'MULTI_DOMEIN'),
 (N'UITVAART', N'GEEN_DOMEIN'),
 (N'UITVAART', N'LEVEN_BELEGGINGEN'),
 (N'UITVAART', N'MULTI_DOMEIN'),
 (N'VANDALISME_EN_KWAADWILLIGHEID', N'BRAND_BIJZONDERE'),
 (N'VANDALISME_EN_KWAADWILLIGHEID', N'BRAND_EENVOUDIG'),
 (N'VANDALISME_EN_KWAADWILLIGHEID', N'GEEN_DOMEIN'),
 (N'VANDALISME_EN_KWAADWILLIGHEID', N'MULTI_DOMEIN'),
 (N'VANDALISME_VOERTUIG', N'GEEN_DOMEIN'),
 (N'VANDALISME_VOERTUIG', N'MULTI_DOMEIN'),
 (N'VERBLIJF_VAN_GOEDEREN', N'GEEN_DOMEIN'),
 (N'VERBLIJF_VAN_GOEDEREN', N'MULTI_DOMEIN'),
 (N'VERBLIJF_VAN_GOEDEREN', N'TRANSPORT_MARINE'),
 (N'VERBLIJF_VAN_WAARDEN_BIJ_AANGESTELDE', N'BRAND_BIJZONDERE'),
 (N'VERBLIJF_VAN_WAARDEN_BIJ_AANGESTELDE', N'BRAND_EENVOUDIG'),
 (N'VERBLIJF_VAN_WAARDEN_BIJ_AANGESTELDE', N'DIVERSEN'),
 (N'VERBLIJF_VAN_WAARDEN_BIJ_AANGESTELDE', N'GEEN_DOMEIN'),
 (N'VERBLIJF_VAN_WAARDEN_BIJ_AANGESTELDE', N'MULTI_DOMEIN'),
 (N'VERBLIJF_VAN_WAARDEN_BIJ_AANGESTELDE', N'TRANSPORT_MARINE'),
 (N'VERBLIJF_VAN_WAARDEN_BUITEN_KLUIS', N'BRAND_BIJZONDERE'),
 (N'VERBLIJF_VAN_WAARDEN_BUITEN_KLUIS', N'BRAND_EENVOUDIG'),
 (N'VERBLIJF_VAN_WAARDEN_BUITEN_KLUIS', N'DIVERSEN'),
 (N'VERBLIJF_VAN_WAARDEN_BUITEN_KLUIS', N'GEEN_DOMEIN'),
 (N'VERBLIJF_VAN_WAARDEN_BUITEN_KLUIS', N'MULTI_DOMEIN'),
 (N'VERBLIJF_VAN_WAARDEN_BUITEN_KLUIS', N'TRANSPORT_MARINE'),
 (N'VERBLIJF_VAN_WAARDEN_IN_BANKKLUIS', N'BRAND_BIJZONDERE'),
 (N'VERBLIJF_VAN_WAARDEN_IN_BANKKLUIS', N'BRAND_EENVOUDIG'),
 (N'VERBLIJF_VAN_WAARDEN_IN_BANKKLUIS', N'DIVERSEN'),
 (N'VERBLIJF_VAN_WAARDEN_IN_BANKKLUIS', N'GEEN_DOMEIN'),
 (N'VERBLIJF_VAN_WAARDEN_IN_BANKKLUIS', N'MULTI_DOMEIN'),
 (N'VERBLIJF_VAN_WAARDEN_IN_BANKKLUIS', N'TRANSPORT_MARINE'),
 (N'VERBLIJF_VAN_WAARDEN_IN_EIGEN_KLUIS', N'BRAND_BIJZONDERE'),
 (N'VERBLIJF_VAN_WAARDEN_IN_EIGEN_KLUIS', N'BRAND_EENVOUDIG'),
 (N'VERBLIJF_VAN_WAARDEN_IN_EIGEN_KLUIS', N'DIVERSEN'),
 (N'VERBLIJF_VAN_WAARDEN_IN_EIGEN_KLUIS', N'GEEN_DOMEIN'),
 (N'VERBLIJF_VAN_WAARDEN_IN_EIGEN_KLUIS', N'MULTI_DOMEIN'),
 (N'VERBLIJF_VAN_WAARDEN_IN_EIGEN_KLUIS', N'TRANSPORT_MARINE'),
 (N'VERBLIJF_VAN_WAARDEVOLLE_VOORWERPEN_IN_VITRINE', N'BRAND_BIJZONDERE'),
 (N'VERBLIJF_VAN_WAARDEVOLLE_VOORWERPEN_IN_VITRINE', N'BRAND_EENVOUDIG'),
 (N'VERBLIJF_VAN_WAARDEVOLLE_VOORWERPEN_IN_VITRINE', N'DIVERSEN'),
 (N'VERBLIJF_VAN_WAARDEVOLLE_VOORWERPEN_IN_VITRINE', N'GEEN_DOMEIN'),
 (N'VERBLIJF_VAN_WAARDEVOLLE_VOORWERPEN_IN_VITRINE', N'MULTI_DOMEIN'),
 (N'VERBLIJF_VAN_WAARDEVOLLE_VOORWERPEN_IN_VITRINE', N'TRANSPORT_MARINE'),
 (N'VERBLIJF_WAARDEN_IN_KASSA', N'BRAND_BIJZONDERE'),
 (N'VERBLIJF_WAARDEN_IN_KASSA', N'BRAND_EENVOUDIG'),
 (N'VERBLIJF_WAARDEN_IN_KASSA', N'DIVERSEN'),
 (N'VERBLIJF_WAARDEN_IN_KASSA', N'GEEN_DOMEIN'),
 (N'VERBLIJF_WAARDEN_IN_KASSA', N'MULTI_DOMEIN'),
 (N'VERBLIJF_WAARDEN_IN_KASSA', N'TRANSPORT_MARINE'),
 (N'VERHAAL_VAN_BUREN', N'BRAND_BIJZONDERE'),
 (N'VERHAAL_VAN_BUREN', N'BRAND_EENVOUDIG'),
 (N'VERHAAL_VAN_BUREN', N'GEEN_DOMEIN'),
 (N'VERHAAL_VAN_BUREN', N'MULTI_DOMEIN'),
 (N'VERKEERSRISICO_S_EN_AANSLAGEN', N'GEEN_DOMEIN'),
 (N'VERKEERSRISICO_S_EN_AANSLAGEN', N'MULTI_DOMEIN'),
 (N'VERLIES_VAN_HET_VLIEGBREVET', N'GEEN_DOMEIN'),
 (N'VERLIES_VAN_HET_VLIEGBREVET', N'INDIVIDUELE'),
 (N'VERLIES_VAN_HET_VLIEGBREVET', N'MULTI_DOMEIN'),
 (N'VERVANGINGSKOSTEN', N'DIVERSEN'),
 (N'VERVANGINGSKOSTEN', N'GEEN_DOMEIN'),
 (N'VERVANGINGSKOSTEN', N'MULTI_DOMEIN'),
 (N'VERVOERDE_GOEDEREN', N'BA_PART'),
 (N'VERVOERDE_GOEDEREN', N'GEEN_DOMEIN'),
 (N'VERVOERDE_GOEDEREN', N'MULTI_DOMEIN'),
 (N'VERVOERDE_GOEDEREN', N'TRANSPORT_MARINE'),
 (N'VERVOER_VAN_WAARDEN', N'BRAND_BIJZONDERE'),
 (N'VERVOER_VAN_WAARDEN', N'BRAND_EENVOUDIG'),
 (N'VERVOER_VAN_WAARDEN', N'DIVERSEN'),
 (N'VERVOER_VAN_WAARDEN', N'GEEN_DOMEIN'),
 (N'VERVOER_VAN_WAARDEN', N'MULTI_DOMEIN'),
 (N'VERVOER_VAN_WAARDEN', N'TRANSPORT_MARINE'),
 (N'VERZEKERINGSBON', N'GEEN_DOMEIN'),
 (N'VERZEKERINGSBON', N'LEVEN_BELEGGINGEN'),
 (N'VERZEKERINGSBON', N'MULTI_DOMEIN'),
 (N'VOERTUIGEN_IN_RUST', N'BRAND_BIJZONDERE'),
 (N'VOERTUIGEN_IN_RUST', N'BRAND_EENVOUDIG'),
 (N'VOERTUIGEN_IN_RUST', N'GEEN_DOMEIN'),
 (N'VOERTUIGEN_IN_RUST', N'MULTI_DOMEIN'),
 (N'VOERTUIGEN_IN_RUST', N'TRANSPORT_MARINE'),
 (N'VOERTUIGEN_OVERAL', N'BRAND_BIJZONDERE'),
 (N'VOERTUIGEN_OVERAL', N'BRAND_EENVOUDIG'),
 (N'VOERTUIGEN_OVERAL', N'GEEN_DOMEIN'),
 (N'VOERTUIGEN_OVERAL', N'MULTI_DOMEIN'),
 (N'VOERTUIGEN_OVERAL', N'TRANSPORT_MARINE'),
 (N'VOLLEDIGE_OMNIUM', N'GEEN_DOMEIN'),
 (N'VOLLEDIGE_OMNIUM', N'MULTI_DOMEIN'),
 (N'WAARBORG_LEVERANCIER', N'DIVERSEN'),
 (N'WAARBORG_LEVERANCIER', N'GEEN_DOMEIN'),
 (N'WAARBORG_LEVERANCIER', N'MULTI_DOMEIN'),
 (N'WACHTCONTRACT', N'GEEN_DOMEIN'),
 (N'WACHTCONTRACT', N'HOSPITALISATIE'),
 (N'WACHTCONTRACT', N'INDIVIDUELE'),
 (N'WATERSCHADE', N'BRAND_BIJZONDERE'),
 (N'WATERSCHADE', N'BRAND_EENVOUDIG'),
 (N'WATERSCHADE', N'GEEN_DOMEIN'),
 (N'WEDERSAMENSTELLINGSKOSTEN', N'MULTI_DOMEIN'),
 (N'WEDERSAMENSTELLINGSKOSTEN', N'REIS'),
 (N'WEDER_SAMENSTELLINGS_KOSTEN', N'BRAND_BIJZONDERE'),
 (N'WEDER_SAMENSTELLINGS_KOSTEN', N'BRAND_EENVOUDIG'),
 (N'WEDER_SAMENSTELLINGS_KOSTEN', N'DIVERSEN'),
 (N'WEDER_SAMENSTELLINGS_KOSTEN', N'GEEN_DOMEIN'),
 (N'WEG_VAN_EN_NAAR_HET_WERK', N'GEEN_DOMEIN'),
 (N'WEG_VAN_EN_NAAR_HET_WERK', N'MULTI_DOMEIN'),
 (N'WEG_VAN_EN_NAAR_HET_WERK_EXCEDENT', N'GEEN_DOMEIN'),
 (N'WEG_VAN_EN_NAAR_HET_WERK_EXCEDENT', N'MULTI_DOMEIN'),
 (N'WIJZIGING_VAN_TEMPERATUUR', N'BRAND_BIJZONDERE'),
 (N'WIJZIGING_VAN_TEMPERATUUR', N'BRAND_EENVOUDIG'),
 (N'WIJZIGING_VAN_TEMPERATUUR', N'GEEN_DOMEIN'),
 (N'WIJZIGING_VAN_TEMPERATUUR', N'MULTI_DOMEIN'),
 (N'WIJZIGING_VAN_TEMPERATUUR', N'TRANSPORT_MARINE'),
 (N'ZIEKENHUISOPNAME', N'BIJSTAND'),
 (N'ZIEKENHUISOPNAME', N'GEEN_DOMEIN'),
 (N'ZIEKENHUISOPNAME', N'HOSPITALISATIE'),
 (N'ZIEKENHUISOPNAME', N'INDIVIDUELE'),
 (N'ZIEKENHUISOPNAME', N'MULTI_DOMEIN'),
 (N'ZIEKENHUISOPNAME', N'REIS'),
 (N'ZIEKTE', N'BIJSTAND'),
 (N'ZIEKTE', N'GEEN_DOMEIN'),
 (N'ZIEKTE', N'HOSPITALISATIE'),
 (N'ZIEKTE', N'INDIVIDUELE'),
 (N'ZIEKTE', N'LEVEN_BELEGGINGEN'),
 (N'ZIEKTE', N'MULTI_DOMEIN'),
 (N'ZIEKTE', N'REIS'),
 (N'ZIEKTEN_COLLECTIEVE_VERZEKERINGEN', N'GEEN_DOMEIN'),
 (N'ZIEKTEN_COLLECTIEVE_VERZEKERINGEN', N'MULTI_DOMEIN'),
 (N'ZORGVERZEKERING', N'GEEN_DOMEIN'),
 (N'ZORGVERZEKERING', N'HOSPITALISATIE'),
 (N'ZORGVERZEKERING', N'INDIVIDUELE'),
 (N'ZORGVERZEKERING', N'MULTI_DOMEIN')
) AS s(coverage_code, contract_domain_code)
ON (t.coverage_code = s.coverage_code AND t.contract_domain_code = s.contract_domain_code)
WHEN MATCHED THEN UPDATE 
    SET t.coverage_code = s.coverage_code  -- (geen aanvullende velden in mapping)
WHEN NOT MATCHED THEN INSERT(coverage_code, contract_domain_code)
    VALUES(s.coverage_code, s.contract_domain_code);	
	
	
	
	
	
	
	
	
	/* ---------- ClaimStatus (statussen van claims) ---------- */
MERGE ClaimStatus AS target
USING (VALUES 
  (N'INGEDIEND',     N'Ingediend',     1),
  (N'IN_BEHANDELING',N'In behandeling',1),
  (N'AFGEHANDELD',   N'Afgehandeld',   1),
  (N'GEWEIGERD',     N'Geweigerd',     1)
) AS src(claim_status_code, status_label, is_active)
ON target.claim_status_code = src.claim_status_code
WHEN MATCHED THEN 
  UPDATE SET status_label = src.status_label, is_active = src.is_active
WHEN NOT MATCHED THEN 
  INSERT (claim_status_code, status_label, is_active)
  VALUES (src.claim_status_code, src.status_label, src.is_active);

/* ---------- ClaimPartyRole (rollen in claims) ---------- */
MERGE ClaimPartyRole AS target
USING (VALUES 
  (N'INSURED',     N'Verzekerde',        1),
  (N'CLAIMANT',    N'Schadeaangever',    1),
  (N'THIRD_PARTY', N'Tegenpartij',       1),
  (N'BENEFICIARY', N'Begunstigde',       1),
  (N'WITNESS',     N'Getuige',           1)
) AS src(claim_party_role_code, role_label, is_active)
ON target.claim_party_role_code = src.claim_party_role_code
WHEN MATCHED THEN 
  UPDATE SET role_label = src.role_label, is_active = src.is_active
WHEN NOT MATCHED THEN 
  INSERT (claim_party_role_code, role_label, is_active)
  VALUES (src.claim_party_role_code, src.role_label, src.is_active);
  
  /* ---------- ClaimPaymentMethod (betaalwijzen) ---------- */
MERGE ClaimPaymentMethod AS target
USING (VALUES 
  (N'BANK_TRANSFER', N'Overschrijving', 1),
  (N'CASH',          N'Contant',        1),
  (N'CHEQUE',        N'Cheque',         1),
  (N'PAYPAL',        N'PayPal',         1),
  (N'CREDIT_CARD',   N'Kredietkaart',   1),
  (N'OTHER',         N'Andere',         1)
) AS src(payment_method_code, method_label, is_active)
ON target.payment_method_code = src.payment_method_code
WHEN MATCHED THEN 
  UPDATE SET method_label = src.method_label, is_active = src.is_active
WHEN NOT MATCHED THEN 
  INSERT (payment_method_code, method_label, is_active)
  VALUES (src.payment_method_code, src.method_label, src.is_active);
  
  
   /* ---------- ClaimCircumstanceType (soorten omstandigheden) ---------- */
MERGE ClaimCircumstanceType AS target
USING (VALUES
(N'AANDUIDING_EERBAARHEID_OF_PRIVACY', N'Aanduiding eerbaarheid of privacy', 1),
(N'AARDBEVING', N'Aardbeving', 1),
(N'ADOPTIE', N'Adoptie', 1),
(N'AFSNIJDING_ARBEIDSCONTRACT', N'Afsnijding arbeidscontract', 1),
(N'ALPINISME', N'Alpinisme', 1),
(N'ANDERE_VERKEERSRISICOS_VOETGANGERS_FIETSEN_', N'Andere verkeersrisico’s (voetgangers, fietsen, …)', 1),
(N'ANDEREN', N'Anderen', 1),
(N'ARBEIDSONGEVAL', N'Arbeidsongeval', 1),
(N'AANSPRAKELIJKHEID_DOOR_DIEREN', N'Aansprakelijkheid door dieren', 1),
(N'AANSPRAKELIJKHEID_DOOR_VOERTUIGEN', N'Aansprakelijkheid door voertuigen', 1),
(N'BASKET', N'Basket', 1),
(N'BEDREIGING_OF_GEWELDPLEGING', N'Bedreiging of geweldpleging', 1),
(N'BEDRIJFSSCHADE', N'Bedrijfsschade', 1),
(N'BENZINE', N'Benzine', 1),
(N'BEROEPSRISICOS', N'Beroepsrisico’s', 1),
(N'BIJSTAND_PERSONEN', N'Bijstand personen', 1),
(N'BIJSTAND_VOERTUIG', N'Bijstand voertuig', 1),
(N'BLIKSEM', N'Bliksem', 1),
(N'BOOT', N'Boot', 1),
(N'BRAND', N'Brand', 1),
(N'BRAND_AUTO_', N'Brand (Auto)', 1),
(N'BRAND_DOORGEGEVEN_DOOR_BUREN', N'Brand doorgegeven door buren', 1),
(N'BREUK_VAN_SKI', N'Breuk van ski', 1),
(N'BUURTVERSTORING', N'Buurtverstoring', 1),
(N'CAMPING_CARAVANING', N'Camping – caravaning', 1),
(N'CARJACKING', N'Carjacking', 1),
(N'CONSTRUCTIEFOUT', N'Constructiefout', 1),
(N'CONTRACTUEEL', N'Contractueel', 1),
(N'CORROSIE', N'Corrosie', 1),
(N'DAAD_VAN_AANGESTELDE', N'Daad van aangestelde', 1),
(N'DAAD_VAN_DE_VERZEKERDE', N'Daad van de verzekerde', 1),
(N'DAAD_VAN_EEN_DERDE', N'Daad van een derde', 1),
(N'DAAD_VAN_MINDERJARIGE', N'Daad van minderjarige', 1),
(N'DIEFSTAL', N'Diefstal', 1),
(N'DIEFSTAL_BAGAGE_MATERIEEL_BEWAAKT_DOOR_DERDEN', N'Diefstal bagage, materieel – bewaakt door derden', 1),
(N'DIEFSTAL_BAGAGE_MATERIEEL_EIGEN_BEWAKING', N'Diefstal bagage, materieel – eigen bewaking', 1),
(N'DIEFSTAL_BAGAGE_MATERIEEL_ONBEWAAKT', N'Diefstal bagage, materieel – onbewaakt', 1),
(N'DIEFSTAL_BAGAGE_MATERIEEL_VERBLIJFPLAATS', N'Diefstal bagage, materieel – verblijfplaats', 1),
(N'DIEFSTAL_DOOR_EEN_AANGESTELDE', N'Diefstal door een aangestelde', 1),
(N'DIEFSTAL_DOOR_ONBETROUWBAARHEID_VAN_PERSONEEL', N'Diefstal door onbetrouwbaarheid van personeel', 1),
(N'DIEFSTAL_DOOR_VERLIES_VERDWIJNING', N'Diefstal door verlies/verdwijning', 1),
(N'DIEFSTAL_MET_GEWELD', N'Diefstal met geweld', 1),
(N'DIEFSTAL_PERSOONSBEWIJZEN', N'Diefstal persoonsbewijzen', 1),
(N'DIEFSTAL_RADIO', N'Diefstal radio', 1),
(N'DIEFSTAL_REISZAKEN', N'Diefstal reiszaken', 1),
(N'DIEFSTAL_SLEUTELS', N'Diefstal sleutels', 1),
(N'DIEFSTAL_TOEBEHOREN', N'Diefstal toebehoren', 1),
(N'DIEFSTAL_VOERTUIG', N'Diefstal voertuig', 1),
(N'DIEREN', N'Dieren', 1),
(N'DUBBEL_MANOEUVRE', N'Dubbel manoeuvre', 1),
(N'DUIKEN', N'Duiken', 1),
(N'EINDE_LEASING', N'Einde leasing', 1),
(N'ELEKTRICITEIT', N'Elektriciteit', 1),
(N'ELEKTRICITEIT_ANDERE', N'Elektriciteit – andere', 1),
(N'ELEKTRICITEIT_INDUCTIE', N'Elektriciteit – inductie', 1),
(N'ELEKTRICITEIT_KORTSLUITING', N'Elektriciteit – kortsluiting', 1),
(N'ELEKTRICITEIT_OVERSPANNING', N'Elektriciteit – overspanning', 1),
(N'ELEKTRICITEIT_TE_STERKE_ELEKTRISCHE_STROOM', N'Elektriciteit – te sterke elektrische stroom', 1),
(N'ELEKTRICITEITSRISICO', N'Elektriciteitsrisico', 1),
(N'FABRICAGEFOUT', N'Fabricagefout', 1),
(N'FIETS_B_A_', N'Fiets (B.A.)', 1),
(N'FIETS_ONGEVALLEN_', N'Fiets (Ongevallen)', 1),
(N'FOUT_IN_HET_ONTWERP', N'Fout in het ontwerp', 1),
(N'FOUT_IN_UITVOERING', N'Fout in uitvoering', 1),
(N'FOUTIEVE_BERICHTGEVING', N'Foutieve berichtgeving', 1),
(N'FOUTIEVE_INFORMATIE_OF_BRON', N'Foutieve informatie of bron', 1),
(N'FOUTIEVE_WERKING_SPRINKLER', N'Foutieve werking sprinkler', 1),
(N'FYSIEKE_AANTASTING', N'Fysieke aantasting', 1),
(N'GAS', N'Gas', 1),
(N'GEBOUWEN_TERREINEN', N'Gebouwen – terreinen', 1),
(N'GEDEELTELIJKE_DIEFSTAL', N'Gedeeltelijke diefstal', 1),
(N'GEKARAKTERISEERD_ONGEVAL', N'Gekarakteriseerd ongeval', 1),
(N'GEPARKEERDE_TEGENPARTIJ_AANGEREDEN_DOOR_VERZEKERDE', N'Geparkeerde tegenpartij aangereden door verzekerde', 1),
(N'GEPARKEERDE_VERZEKERDE_AANGEREDEN_DOOR_GEKENDE_TEGENPARTIJ', N'Geparkeerde verzekerde aangereden door gekende tegenpartij', 1),
(N'GEPARKEERDE_VERZEKERDE_AANGEREDEN_DOOR_ONBEKENDE_TEGENPARTIJ', N'Geparkeerde verzekerde aangereden door onbekende tegenpartij', 1),
(N'GEVECHTSSPORT', N'Gevechtssport', 1),
(N'GLASBRAAK', N'Glasbraak', 1),
(N'GLASBRAAK_VANDALISME', N'Glasbraak – vandalisme', 1),
(N'GRONDVERPLAATSING', N'Grondverplaatsing', 1),
(N'GRONDWERKEN', N'Grondwerken', 1),
(N'GROTE_NATUURRAMP', N'Grote natuurramp', 1),
(N'GYMNASTIEK_EN_ATLETIEK', N'Gymnastiek en atletiek', 1),
(N'HAGEL', N'Hagel', 1),
(N'HEIMELIJKE_BINNENDRINGING', N'Heimelijke binnendringing', 1),
(N'HOMEJACKING', N'Homejacking', 1),
(N'HOND', N'Hond', 1),
(N'HOSPITALISATIE', N'Hospitalisatie', 1),
(N'HUISHOUDELIJKE_SCHADE', N'Huishoudelijke schade', 1),
(N'HUISZWAM', N'Huiszwam', 1),
(N'IMPLOSIE', N'Implosie', 1),
(N'IMPLOSIE_ELEKTRICITEIT', N'Implosie – elektriciteit', 1),
(N'IMPLOSIE_FABRICAGE', N'Implosie – fabricage', 1),
(N'IMPLOSIE_GAS', N'Implosie – gas', 1),
(N'IMPLOSIE_MENSELIJKE_OORZAAK', N'Implosie – menselijke oorzaak', 1),
(N'IMPLOSIE_ONDERHOUDSGEBREK', N'Implosie – onderhoudsgebrek', 1),
(N'IMPLOSIE_VANDALISME', N'Implosie – vandalisme', 1),
(N'INBRAAK', N'Inbraak', 1),
(N'INBRAAK_VOERTUIG_ZONDER_VERDWIJNING_VOERTUIG', N'Inbraak voertuig zonder verdwijning voertuig', 1),
(N'INKLIMMING', N'Inklimming', 1),
(N'INSIJPELING', N'Insijpeling', 1),
(N'INSTORTING', N'Instorting', 1),
(N'INTERNE_OORZAAK', N'Interne oorzaak', 1),
(N'INTREKKING_VERLOF_NOODZAKELIJKE_AANWEZIGHEID_VRIJ_BEROEP', N'Intrekking verlof, noodzakelijke aanwezigheid vrij beroep', 1),
(N'INVALIDITEIT', N'Invaliditeit', 1),
(N'INVALIDITEIT_BELEMMERT_DE_REIS', N'Invaliditeit belemmert de reis', 1),
(N'INVALIDITEIT_DOOR_ONGEVAL', N'Invaliditeit door ongeval', 1),
(N'KETTINGBOTSING', N'Kettingbotsing', 1),
(N'KIDNAPPING', N'Kidnapping', 1),
(N'KWAAD_OPZET', N'Kwaad opzet', 1),
(N'LADEN_AFL_ADEN_OVERLADEN', N'Laden, afl aden, overladen', 1),
(N'LEIDINGBREUK', N'Leidingbreuk', 1),
(N'LICHAMELIJKE_SCHADE_DERDEN_VEROORZAAKT_DOOR_GEBOUW', N'Lichamelijke schade derden veroorzaakt door gebouw', 1),
(N'LICHAMELIJKE_SCHADE_DERDEN_VEROORZAAKT_DOOR_INHOUD', N'Lichamelijke schade derden veroorzaakt door inhoud', 1),
(N'LICHAMELIJKE_SCHADE_DERDEN_VEROORZAAKT_DOOR_STOEP', N'Lichamelijke schade derden veroorzaakt door stoep', 1),
(N'LIFT_EN_GOEDERENLIFT', N'Lift en goederenlift', 1),
(N'LOCK_OUT', N'Lock-out', 1),
(N'MANOEUVRE_ENKEL_DOOR_TEGENPARTIJ_UITGEVOERD', N'Manoeuvre – enkel door tegenpartij uitgevoerd', 1),
(N'MANOEUVRE_ENKEL_DOOR_VERZEKERDE_UITGEVOERD', N'Manoeuvre – enkel door verzekerde uitgevoerd', 1),
(N'MILITAIRE_OPDRACHT', N'Militaire opdracht', 1),
(N'NATUURKRACHT', N'Natuurkracht', 1),
(N'NEERSTORTING_VOORWERPEN', N'Neerstorting voorwerpen', 1),
(N'NIET_LEVERING', N'Niet levering', 1),
(N'NUCLEAIRE_RISICOS', N'Nucleaire risico’s', 1),
(N'OMSTANDIGHEDEN_LOS_VAN_DE_ACTIVITEIT', N'Omstandigheden los van de activiteit', 1),
(N'ONBESCHIKBAARHEID_HULPVERLENER', N'Onbeschikbaarheid hulpverlener', 1),
(N'ONBESCHIKBAARHEID_VAN_DE_VERBLIJFPLAATS', N'Onbeschikbaarheid van de verblijfplaats', 1),
(N'ONDER_INDIVIDUEEL_TOEZICHT', N'Onder individueel toezicht', 1),
(N'ONDERHOUDSGEBREK', N'Onderhoudsgebrek', 1),
(N'ONGEKENDE_OMSTANDIGHEDEN', N'Ongekende omstandigheden', 1),
(N'ONGEVAL_OF_ZIEKTE_EX_PARTNER', N'Ongeval of ziekte ex-partner', 1),
(N'ONGEVAL_OUDER_TOT_3DE_GRAAD_', N'Ongeval ouder (tot 3de graad)', 1),
(N'ONTMIJNING', N'Ontmijning', 1),
(N'ONTPLOFFING', N'Ontploffing', 1),
(N'ONTPLOFFING_DOORGEGEVEN_DOOR_BUREN', N'Ontploffing – doorgegeven door buren', 1),
(N'ONTPLOFFING_ELEKTRICITEIT', N'Ontploffing – elektriciteit', 1),
(N'ONTPLOFFING_FABRICAGE', N'Ontploffing – fabricage', 1),
(N'ONTPLOFFING_GAS', N'Ontploffing – gas', 1),
(N'ONTPLOFFING_MENSELIJKE_OORZAAK', N'Ontploffing – menselijke oorzaak', 1),
(N'ONTPLOFFING_ONDERHOUDSGEBREK', N'Ontploffing – onderhoudsgebrek', 1),
(N'ONTPLOFFING_SPRINGSTOF', N'Ontploffing – springstof', 1),
(N'ONTPLOFFING_VANDALISME', N'Ontploffing – vandalisme', 1),
(N'ONTSLAG_LASTHEBBENDE_OUDER_MEEREIZEND_KIND', N'Ontslag (lasthebbende) ouder meereizend kind', 1),
(N'ONTVLAMBARE_VLOEISTOFFEN', N'Ontvlambare vloeistoffen', 1),
(N'OP_2_RIJSTROKEN_DOET_TEGENPARTIJ_1_MANOEUVRE', N'Op 2 rijstroken, doet tegenpartij 1 manoeuvre', 1),
(N'OP_2_RIJSTROKEN_DOET_VERZEKERDE_MANOEUVRE', N'Op 2 rijstroken, doet verzekerde manoeuvre', 1),
(N'OP_2_RIJSTROKEN_VERANDERT_TEGENPARTIJ_VAN_RIJSTROOK', N'Op 2 rijstroken, verandert tegenpartij van rijstrook', 1),
(N'OP_2_RIJSTROKEN_VERANDERT_VERZEKERDE_VAN_RIJSTROOK', N'Op 2 rijstroken, verandert verzekerde van rijstrook', 1),
(N'OP_2_RIJSTROKEN_VERLAAT_TEGENPARTIJ_DE_TUNNEL', N'Op 2 rijstroken, verlaat tegenpartij de tunnel', 1),
(N'OP_2_RIJSTROKEN_VERLAAT_VERZEKERDE_DE_TUNNEL', N'Op 2 rijstroken, verlaat verzekerde de tunnel', 1),
(N'OPNAME_IN_RUSTHUIS', N'Opname in rusthuis', 1),
(N'OPEISING_DOOR_AUTORITEITEN', N'Opeising door autoriteiten', 1),
(N'OPROEPING_JURY_GETUIGE_EXAMEN', N'Oproeping jury, getuige, examen', 1),
(N'OPWERPEN_VAN_STENEN', N'Opwerpen van stenen', 1),
(N'ORGAANTRANSPLANTATIE', N'Orgaantransplantatie', 1),
(N'OVERDRACHT_VOERTUIG_LEASING_', N'Overdracht voertuig (leasing)', 1),
(N'OVERLIJDEN', N'Overlijden', 1),
(N'OVERLIJDEN_DOOR_ONGEVAL', N'Overlijden door ongeval', 1),
(N'OVERLIJDEN_OF_HOSPITALISATIE_IN_OPVANGENDE_FAMILIE', N'Overlijden of hospitalisatie in opvangende familie', 1),
(N'OVERLIJDEN_OUDER_TOT_3DE_GRAAD_', N'Overlijden ouder (tot 3de graad)', 1),
(N'OVERSCHRIJDING_MANDAAT', N'Overschrijding mandaat', 1),
(N'OVERSCHRIJDING_TERMIJN_EN_', N'Overschrijding termijn(en)', 1),
(N'OVERSTROMING', N'Overstroming', 1),
(N'OVERTREDING', N'Overtreding', 1),
(N'PAARDEN', N'Paarden', 1),
(N'PAARDRIJDEN', N'Paardrijden', 1),
(N'PARACHUTISME', N'Parachutisme', 1),
(N'PARKING', N'Parking', 1),
(N'PECH', N'Pech', 1),
(N'PERSDELICT', N'Persdelict', 1),
(N'PRIV_ONGEVAL', N'Privé-ongeval', 1),
(N'PRIV_LEVEN', N'Privéleven', 1),
(N'PRIV_LEVEN_ONGEVALLEN_', N'Privéleven (Ongevallen)', 1),
(N'PRIV_WEG', N'Privéweg', 1),
(N'PROCEDUREFOUT', N'Procedurefout', 1),
(N'PROJECTIE_BESCHADIGD_WEGDEK', N'Projectie – beschadigd wegdek', 1),
(N'RISICOS_MOTO_50_CC_', N'Risico’s moto (+ 50 cc)', 1),
(N'RISICOS_MOTO_50_CC_', N'Risico’s moto (– 50 cc)', 1),
(N'ROOKSCHADE', N'Rookschade', 1),
(N'SABOTAGE', N'Sabotage', 1),
(N'SCHADE_AAN_AANGRENZENDE_GEBOUWEN', N'Schade aan aangrenzende gebouwen', 1),
(N'SCHADE_AAN_BAGAGE_OF_MATERIEEL', N'Schade aan bagage of materieel', 1),
(N'SCHADE_AAN_DERDEN', N'Schade aan derden', 1),
(N'SCHADE_AAN_ONROEREND_GOED', N'Schade aan onroerend goed', 1),
(N'SCHADE_AAN_VERVOERDE_GOEDEREN', N'Schade aan vervoerde goederen', 1),
(N'SCHADE_ANDERE_LICHAMELIJKE_DERDEN_VEROORZAAKT_DOOR_GEBOUW', N'Schade andere lichamelijke derden veroorzaakt door gebouw', 1),
(N'SCHADE_ANDERE_LICHAMELIJKE_DERDEN_VEROORZAAKT_DOOR_INHOUD', N'Schade andere lichamelijke derden veroorzaakt door inhoud', 1),
(N'SCHADE_ANDERE_LICHAMELIJKE_DERDEN_VEROORZAAKT_DOOR_STOEP', N'Schade andere lichamelijke derden veroorzaakt door stoep', 1),
(N'SCHADE_DOOR_WATER', N'Schade door water', 1),
(N'SCHADE_DOOR_WERKTUIGEN', N'Schade door werktuigen', 1),
(N'SCHADE_DOOR_MOTORWERKTUIGEN', N'Schade door motorwerktuigen', 1),
(N'SCHADE_TEN_GEVOLGE_VAN_GRONDWATER', N'Schade ten gevolge van grondwater', 1),
(N'SCHADE_ZWAKKE_WEGGEBRUIKER', N'Schade zwakke weggebruiker', 1),
(N'SCHEIDING', N'Scheiding', 1),
(N'SCHENDING_AUTEURSRECHT', N'Schending auteursrecht', 1),
(N'SCHOORSTEENBRAND', N'Schoorsteenbrand', 1),
(N'SKI', N'Ski', 1),
(N'SLECHT_UITGEVOERDE_WERKEN', N'Slecht uitgevoerde werken', 1),
(N'SLECHTE_EIGENSCHAP_OF_GEBREK_MATERIAAL', N'Slechte eigenschap of gebrek materiaal', 1),
(N'SLIP_PEN_', N'Slip(pen)', 1),
(N'SLIP_PEN_VAN_DE_TEGENPARTIJ', N'Slip(pen) van de tegenpartij', 1),
(N'SNEEUWDRUK', N'Sneeuwdruk', 1),
(N'SPELEOLOGIE', N'Speleologie', 1),
(N'SPORT_B_A_', N'Sport (B.A.)', 1),
(N'SPORT_ONGEVALLEN_', N'Sport (Ongevallen)', 1),
(N'SPROEIEN_EN_UITSTROOIEN', N'Sproeien en uitstrooien', 1),
(N'STAKING', N'Staking', 1),
(N'STILSTAANDE_TEGENPARTIJ_AANGEREDEN_DOOR_VERZEKERDE', N'Stilstaande tegenpartij aangereden door verzekerde', 1),
(N'STILSTAANDE_VERZEKERDE_AANGEREDEN_DOOR_GEKENDE_TEGENPARTIJ', N'Stilstaande verzekerde aangereden door gekende tegenpartij', 1),
(N'STILSTAANDE_VERZEKERDE_AANGEREDEN_DOOR_ONBEKENDE_TEGENPARTIJ', N'Stilstaande verzekerde aangereden door onbekende tegenpartij', 1),
(N'STOOKOLIE', N'Stookolie', 1),
(N'STORM', N'Storm', 1),
(N'STRAFRECHTELIJKE_DAAD_VAN_DE_DERDE', N'Strafrechtelijke daad van de derde', 1),
(N'STRAFRECHTELIJKE_DAAD_VAN_DE_VERZEKERDE', N'Strafrechtelijke daad van de verzekerde', 1),
(N'STUWING_OVERLOPEN_RIOLEN', N'Stuwing, overlopen riolen', 1),
(N'SUPERSONISCHE_KNAL', N'Supersonische knal', 1),
(N'TEGENPARTIJ_BOTST_OP_ACHTERZIJDE_VAN_VERZEKERDE', N'Tegenpartij botst op achterzijde van verzekerde', 1),
(N'TEGENPARTIJ_EN_VERZEKERDE_VERANDEREN_VAN_RIJSTROOK', N'Tegenpartij en verzekerde veranderen van rijstrook', 1),
(N'TEGENPARTIJ_HEEFT_VERKEERSLICHTEN_NIET_GERESPECTEERD', N'Tegenpartij heeft verkeerslichten niet gerespecteerd', 1),
(N'TEGENPARTIJ_HEEFT_VOORRANG_OP_HOOFDWEG', N'Tegenpartij heeft voorrang op hoofdweg', 1),
(N'TEGENPARTIJ_KOMT_VAN_EEN_NRICHTINGSSTRAAT', N'Tegenpartij komt van een éénrichtingsstraat', 1),
(N'TEGENPARTIJ_MAAKT_RECHTSOMKEER', N'Tegenpartij maakt rechtsomkeer', 1),
(N'TEGENPARTIJ_NEGEERT_BORD_C1_NRICHTINGSSTRAAT_', N'Tegenpartij negeert bord C1 (éénrichtingsstraat)', 1),
(N'TEGENPARTIJ_OPENT_ZIJN_DEUR_OP_DE_VERZEKERDE', N'Tegenpartij opent zijn deur op de verzekerde', 1),
(N'TEGENPARTIJ_RIJDT_ACHTERUIT_TEGEN_VERZEKERDE', N'Tegenpartij rijdt achteruit tegen verzekerde', 1),
(N'TEGENPARTIJ_RIJDT_WEG_UIT_PARKEERSTAND', N'Tegenpartij rijdt weg uit parkeerstand', 1),
(N'TEGENPARTIJ_SNIJDT_AF_VAN_DE_VERZEKERDE', N'Tegenpartij snijdt af van de verzekerde', 1),
(N'TEGENPARTIJ_VERTREKT_NA_STILSTAND_TE_HEBBEN', N'Tegenpartij vertrekt na stilstand te hebben', 1),
(N'TERRORISME', N'Terrorisme', 1),
(N'TIJDENS_HET_LADEN', N'Tijdens het laden', 1),
(N'TIJDENS_HET_TRANSPORT', N'Tijdens het transport', 1),
(N'UITHANGBORD_AFDAK_PUBLICITEITSBORD', N'Uithangbord, afdak, publiciteitsbord', 1),
(N'VAL_VAN_DE_LADING_VAN_DE_TEGENPARTIJ', N'Val van de lading van de tegenpartij', 1),
(N'VALPARTIJ', N'Valpartij', 1),
(N'VAL_VAN_TV_ANTENNE', N'Val van TV-antenne', 1),
(N'VAL_VAN_ANDERE_DELEN_VAN_HET_GEBOUW', N'Val van andere delen van het gebouw', 1),
(N'VAL_VAN_ANDERE_VOORWERPEN', N'Val van andere voorwerpen', 1),
(N'VALSE_OF_GESTOLEN_SLEUTELS', N'Valse of gestolen sleutels', 1),
(N'VANDALISME', N'Vandalisme', 1),
(N'VANDALISME_AUTO_', N'Vandalisme (Auto)', 1),
(N'VERBINTENIS_ARBEIDSCONTRACT', N'Verbintenis arbeidscontract', 1),
(N'VERDWIJNING', N'Verdwijning', 1),
(N'VERFINSTALLATIE', N'Verfinstallatie', 1),
(N'VERKEERSONGEVAL', N'Verkeersongeval', 1),
(N'VERLIES', N'Verlies', 1),
(N'VERLIES_VAN_LADING', N'Verlies van lading', 1),
(N'VEROORZAAKT_DOOR_DE_CONSTRUCTIE', N'Veroorzaakt door de constructie', 1),
(N'VERVUILING', N'Vervuiling', 1),
(N'VERZ_VERTREKT_NA_STILSTAND_OF_VERLAAT_PARKEERPLAATS', N'Verz. vertrekt na stilstand of verlaat parkeerplaats', 1),
(N'VERZEKERDE_TEGENPARTIJ_RIJDEN_OP_MIDDELSTE_VERKEERSSTROOK', N'Verzekerde & tegenpartij rijden op middelste verkeersstrook', 1),
(N'VERZEKERDE_BOTST_OP_ACHTERZIJDE_VAN_TEGENPARTIJ', N'Verzekerde botst op achterzijde van tegenpartij', 1),
(N'VERZEKERDE_DRAAIT_LINKS_EN_TEGENPARTIJ_RECHTS', N'Verzekerde draait links en tegenpartij rechts', 1),
(N'VERZEKERDE_DRAAIT_RECHTS_EN_TEGENPARTIJ_LINKS', N'Verzekerde draait rechts en tegenpartij links', 1),
(N'VERZEKERDE_HEEFT_VERKEERSLICHTEN_NIET_GERESPECTEERD', N'Verzekerde heeft verkeerslichten niet gerespecteerd', 1),
(N'VERZEKERDE_HEEFT_VOORRANG_OP_DE_HOOFDWEG', N'Verzekerde heeft voorrang op de hoofdweg', 1),
(N'VERZEKERDE_KOMT_VAN_EEN_NRICHTINGSSTRAAT', N'Verzekerde komt van een éénrichtingsstraat', 1),
(N'VERZEKERDE_MAAKT_RECHTSOMKEER', N'Verzekerde maakt rechtsomkeer', 1),
(N'VERZEKERDE_NEGEERT_BORD_C1_NRICHTINGSSTRAAT_', N'Verzekerde negeert bord C1 (éénrichtingsstraat)', 1),
(N'VERZEKERDE_OPENT_DEUR_OP_TEGENPARTIJ', N'Verzekerde opent deur op tegenpartij', 1),
(N'VERZEKERDE_PARKEERT_ACHTERAAN_AANGEREDEN_DOOR_TEGENPARTIJ', N'Verzekerde parkeert, achteraan aangereden door tegenpartij', 1),
(N'VERZEKERDE_RIJDT_ACHTERUIT_TEGEN_TEGENPARTIJ', N'Verzekerde rijdt achteruit tegen tegenpartij', 1),
(N'VERZEKERDE_RIJDT_EEN_BEWEGENDE_HINDERNIS_AAN', N'Verzekerde rijdt een bewegende hindernis aan', 1),
(N'VERZEKERDE_RIJDT_EEN_ZWAKKE_WEGGEBRUIKER_AAN', N'Verzekerde rijdt een zwakke weggebruiker aan', 1),
(N'VERZEKERDE_RIJDT_OP_EEN_UITHOLLING', N'Verzekerde rijdt op een uitholling', 1),
(N'VERZEKERDE_RIJDT_TEGENPARTIJ_AAN_KOMENDE_UIT_TEGENOVERGESTELDE_RICHTING', N'Verzekerde rijdt tegenpartij aan komende uit tegenovergestelde richting', 1),
(N'VERZEKERDE_RIJDT_VASTE_HINDERNIS_AAN', N'Verzekerde rijdt vaste hindernis aan', 1),
(N'VERZEKERDE_RIJDT_VASTE_HINDERNIS_AAN_GEKENDE_TEGENPARTIJ_', N'Verzekerde rijdt vaste hindernis aan (gekende tegenpartij)', 1),
(N'VERZEKERDE_RIJDT_WEG_UIT_PARKEERSTAND', N'Verzekerde rijdt weg uit parkeerstand', 1),
(N'VERZEKERDE_SNIJDT_DE_WEG_AF_VAN_DE_TEGENPARTIJ', N'Verzekerde snijdt de weg af van de tegenpartij', 1),
(N'VERZUIM', N'Verzuim', 1),
(N'VLIEGTUIG', N'Vliegtuig', 1),
(N'VOEDSELVERGIFTIGING', N'Voedselvergiftiging', 1),
(N'VOERTUIGEN_BESTUURD_DOOR_MINDERJARIGEN', N'Voertuigen bestuurd door minderjarigen', 1),
(N'VOETBAL', N'Voetbal', 1),
(N'VOLKSBEWEGING', N'Volksbeweging', 1),
(N'VOLLEDIGE_DIEFSTAL', N'Volledige diefstal', 1),
(N'VOORAFGAANDE_ZIEKTE', N'Voorafgaande ziekte', 1),
(N'VOORRANG_VAN_RECHTS_VOOR_DE_TEGENPARTIJ', N'Voorrang van rechts voor de tegenpartij', 1),
(N'VOORRANG_VAN_RECHTS_VOOR_VERZEKERDE', N'Voorrang van rechts voor verzekerde', 1),
(N'VOORRANGSRECHT_TEGENP_VOORRANG_VERZ_MET_BELEMMERD_ZICHT', N'Voorrangsrecht – tegenp. voorrang, verz. met belemmerd zicht', 1),
(N'VOORRANGSRECHT_TEGENPARTIJ_KOMT_OP_DE_RIJWEG', N'Voorrangsrecht – tegenpartij komt op de rijweg', 1),
(N'VOORRANGSRECHT_TEGENPARTIJ_NOG_NIET_OP_HET_KRUISPUNT', N'Voorrangsrecht – tegenpartij nog niet op het kruispunt', 1),
(N'VOORRANGSRECHT_VERZ_VOORRANG_TEGENP_MET_BELEMMERD_ZICHT', N'Voorrangsrecht – verz. voorrang, tegenp. met belemmerd zicht', 1),
(N'VOORRANGSRECHT_VERZEKERDE_HEEFT_VOORRANG_VAN_RECHTS', N'Voorrangsrecht – verzekerde heeft voorrang van rechts', 1),
(N'VOORRANGSRECHT_VERZEKERDE_KOMT_OP_DE_RIJWEG', N'Voorrangsrecht – verzekerde komt op de rijweg', 1),
(N'VOORRANGSRECHT_VERZEKERDE_NOG_NIET_OP_HET_KRUISPUNT', N'Voorrangsrecht – verzekerde nog niet op het kruispunt', 1),
(N'VOORWAARTS_RIJDEN_TIJDENS_MANOEUVRE_TEGEN_VOORWERP_DIER', N'Voorwaarts rijden tijdens manoeuvre tegen voorwerp/dier', 1),
(N'VOORWAARTS_RIJDEN_TIJDENS_VERKEER_TEGEN_VOORWERP_DIER', N'Voorwaarts rijden tijdens verkeer tegen voorwerp/dier', 1),
(N'WAPENS', N'Wapens', 1),
(N'WATERSCHADE', N'Waterschade', 1),
(N'WATERSCHADE_DOORGEGEVEN_DOOR_BUREN', N'Waterschade – doorgegeven door buren', 1),
(N'WATERSCHADE_VERWARMING', N'Waterschade – verwarming', 1),
(N'WATERSCHADE_WAS_AFWAS', N'Waterschade – was/afwas', 1),
(N'WEGSTROMING_BRANDSTOF', N'Wegstroming brandstof', 1),
(N'WEIGERING_VISUM', N'Weigering visum', 1),
(N'WERKEN_MET_OPEN_VLAM_LASWERKEN', N'Werken met open vlam, laswerken', 1),
(N'WIJZIGING_ARBEIDSCONTRACT_OF_BEROEPSMATIG', N'Wijziging arbeidscontract of beroepsmatig', 1),
(N'WIJZIGING_TEMPERATUUR', N'Wijziging temperatuur', 1),
(N'WILD_EN_OF_DIEREN', N'Wild en/of dieren', 1),
(N'ZELFONTBRANDING', N'Zelfontbranding', 1),
(N'ZIEKTE', N'Ziekte', 1),
(N'ZIEKTE_OUDER_TOT_3DE_GRAAD_', N'Ziekte ouder (tot 3de graad)', 1),
(N'ZIJDELINGS_CONTACT_TIJDENS_MANOEUVRE_MET_VOORWERP_DIER', N'Zijdelings contact tijdens manoeuvre met voorwerp/dier', 1),
(N'ZIJDELINGS_CONTACT_TIJDENS_VERKEER_MET_VOORWERP_DIER', N'Zijdelings contact tijdens verkeer met voorwerp/dier', 1),
(N'ZWANGERSCHAP', N'Zwangerschap', 1)
) AS source (claim_circumstance_type_code, circumstance_label, is_active)
ON target.claim_circumstance_type_code = source.claim_circumstance_type_code
WHEN MATCHED THEN UPDATE SET target.circumstance_label = source.circumstance_label, target.is_active = source.is_active
WHEN NOT MATCHED THEN INSERT (claim_circumstance_type_code, circumstance_label, is_active) VALUES (source.claim_circumstance_type_code, source.circumstance_label, source.is_active);


PRINT '';
PRINT '======================================================';
PRINT ' Seed data insertion complete!';
PRINT '======================================================';
GO
