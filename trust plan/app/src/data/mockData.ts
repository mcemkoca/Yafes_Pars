// ====== Types ======

export interface Person {
  id: string
  type: 'natuurlijk' | 'rechtspersoon'
  voornaam: string
  achternaam: string
  naam?: string // for rechtspersoon
  rrn: string
  geboortedatum: string
  geslacht: 'M' | 'V' | 'X'
  email: string
  telefoon: string
  adres: string
  postcode: string
  gemeente: string
  land: string
  status: 'actief' | 'inactief' | 'prospect'
  createdAt: string
  updatedAt: string
}

export interface Institution {
  id: string
  naam: string
  type: 'verzekeringsmaatschappij' | 'bank' | 'intermediair' | 'reparatie'
  kbo: string
  adres: string
  postcode: string
  gemeente: string
  email: string
  telefoon: string
  status: 'actief' | 'inactief'
  createdAt: string
}

export interface Vehicle {
  id: string
  merk: string
  model: string
  type: 'personenwagen' | 'bestelwagen' | 'motorfiets' | 'aanhangwagen'
  kenteken: string
  chassisnummer: string
  bouwjaar: number
  brandstof: 'benzine' | 'diesel' | 'hybride' | 'elektrisch'
  kleur: string
  eigenaarId: string
}

export interface RealEstate {
  id: string
  type: 'woning' | 'appartement' | 'handelspand' | 'industrieel'
  adres: string
  postcode: string
  gemeente: string
  bouwjaar: number
  oppervlakte: number
  eigenaarId: string
}

export type AssurObject = Vehicle | RealEstate

export interface Contract {
  id: string
  contractnummer: string
  domein: 'auto' | 'brand' | 'leven' | 'ao' | 'hospitalisatie' | 'diversen'
  status: 'actief' | 'verlopen' | 'vervallen' | 'in_behandeling' | 'annulatie'
  product: string
  maatschappijId: string
  premie: number
  provisie: number
  startdatum: string
  einddatum: string
  verzekerdeNamen: string[]
  objectId?: string
  createdAt: string
}

export interface Schadeclaim {
  id: string
  claimnummer: string
  contractnummer: string
  status: 'nieuw' | 'in_behandeling' | 'in_afwachting_dossier' | 'expert_aangesteld' | 'afgesloten' | 'afgekeurd'
  categorie: string
  beschrijving: string
  datumSchade: string
  datumMelding: string
  bedrag: number
  verzekerdeNaam: string
  urgentie: 'normaal' | 'hoog' | 'kritiek'
  dagenOpen: number
}

export interface Activiteit {
  id: string
  type: 'contract_aangemaakt' | 'claim_bijgewerkt' | 'persoon_toegevoegd' | 'herinnering' | 'verlenging' | 'commissie' | 'object_gekoppeld' | 'batch_export' | 'systeem'
  gebruiker: string
  beschrijving: string
  entityRef?: string
  timestamp: string
  relativeTime: string
}

// ====== Persons ======
export const persons: Person[] = [
  { id: 'P-2024-0001', type: 'natuurlijk', voornaam: 'Jan', achternaam: 'Peeters', rrn: '75.04.12-123.45', geboortedatum: '1975-04-12', geslacht: 'M', email: 'jan.peeters@telenet.be', telefoon: '+32 475 12 34 56', adres: 'Korenmarkt 12', postcode: '2800', gemeente: 'Mechelen', land: 'Belgie', status: 'actief', createdAt: '2024-01-15', updatedAt: '2024-12-01' },
  { id: 'P-2024-0002', type: 'natuurlijk', voornaam: 'Marie', achternaam: 'Dubois', rrn: '82.08.23-234.56', geboortedatum: '1982-08-23', geslacht: 'V', email: 'marie.dubois@proximus.be', telefoon: '+32 486 23 45 67', adres: 'Bondgenotenlaan 45', postcode: '3000', gemeente: 'Leuven', land: 'Belgie', status: 'actief', createdAt: '2024-02-20', updatedAt: '2024-11-28' },
  { id: 'P-2024-0003', type: 'natuurlijk', voornaam: 'Pieter', achternaam: 'Janssens', rrn: '68.11.05-345.67', geboortedatum: '1968-11-05', geslacht: 'M', email: 'pieter.janssens@skynet.be', telefoon: '+32 497 34 56 78', adres: 'Grote Markt 8', postcode: '3500', gemeente: 'Hasselt', land: 'Belgie', status: 'actief', createdAt: '2024-03-10', updatedAt: '2024-12-10' },
  { id: 'P-2024-0004', type: 'rechtspersoon', voornaam: '', achternaam: '', naam: 'BVBA De Boer', rrn: '0403.432.123', geboortedatum: '', geslacht: 'X', email: 'info@deboer.be', telefoon: '+32 3 123 45 67', adres: 'Industrielaan 22', postcode: '2018', gemeente: 'Antwerpen', land: 'Belgie', status: 'actief', createdAt: '2024-01-22', updatedAt: '2024-12-05' },
  { id: 'P-2024-0005', type: 'natuurlijk', voornaam: 'Anna', achternaam: 'Vermeiren', rrn: '90.02.18-456.78', geboortedatum: '1990-02-18', geslacht: 'V', email: 'anna.vermeiren@gmail.com', telefoon: '+32 471 45 67 89', adres: 'Stationsstraat 33', postcode: '9000', gemeente: 'Gent', land: 'Belgie', status: 'actief', createdAt: '2024-04-05', updatedAt: '2024-11-30' },
  { id: 'P-2024-0006', type: 'natuurlijk', voornaam: 'Lucas', achternaam: 'Peeters', rrn: '78.06.30-567.89', geboortedatum: '1978-06-30', geslacht: 'M', email: 'lucas.peeters@outlook.be', telefoon: '+32 472 56 78 90', adres: 'Diestsestraat 67', postcode: '3000', gemeente: 'Leuven', land: 'Belgie', status: 'actief', createdAt: '2024-05-12', updatedAt: '2024-12-08' },
  { id: 'P-2024-0007', type: 'natuurlijk', voornaam: 'Sarah', achternaam: 'Michiels', rrn: '85.09.14-678.90', geboortedatum: '1985-09-14', geslacht: 'V', email: 'sarah.michiels@telenet.be', telefoon: '+32 473 67 89 01', adres: 'Nieuwstraat 5', postcode: '1000', gemeente: 'Brussel', land: 'Belgie', status: 'actief', createdAt: '2024-06-18', updatedAt: '2024-12-03' },
  { id: 'P-2024-0008', type: 'natuurlijk', voornaam: 'Thomas', achternaam: 'Peeters', rrn: '72.01.08-789.01', geboortedatum: '1972-01-08', geslacht: 'M', email: 'thomas.peeters@proximus.be', telefoon: '+32 474 78 90 12', adres: 'Leuvensestraat 19', postcode: '2800', gemeente: 'Mechelen', land: 'Belgie', status: 'actief', createdAt: '2024-07-25', updatedAt: '2024-11-20' },
  { id: 'P-2024-0009', type: 'natuurlijk', voornaam: 'Emma', achternaam: 'Wouters', rrn: '95.03.27-890.12', geboortedatum: '1995-03-27', geslacht: 'V', email: 'emma.wouters@hotmail.com', telefoon: '+32 475 89 01 23', adres: 'Kortrijksesteenweg 88', postcode: '9000', gemeente: 'Gent', land: 'Belgie', status: 'prospect', createdAt: '2024-08-14', updatedAt: '2024-12-12' },
  { id: 'P-2024-0010', type: 'rechtspersoon', voornaam: '', achternaam: '', naam: 'NV Verzekerd Goed', rrn: '0456.789.234', geboortedatum: '', geslacht: 'X', email: 'contact@verzekerdgoed.be', telefoon: '+32 2 234 56 78', adres: 'Louizalaan 120', postcode: '1050', gemeente: 'Brussel', land: 'Belgie', status: 'actief', createdAt: '2024-03-01', updatedAt: '2024-11-15' },
  { id: 'P-2024-0011', type: 'natuurlijk', voornaam: 'Koen', achternaam: 'Maes', rrn: '80.07.19-901.23', geboortedatum: '1980-07-19', geslacht: 'M', email: 'koen.maes@skynet.be', telefoon: '+32 476 01 23 45', adres: 'Steenweg op Brussels 56', postcode: '1700', gemeente: 'Dilbeek', land: 'Belgie', status: 'actief', createdAt: '2024-09-02', updatedAt: '2024-12-06' },
  { id: 'P-2024-0012', type: 'natuurlijk', voornaam: 'Liesbeth', achternaam: 'De Smet', rrn: '77.12.03-012.34', geboortedatum: '1977-12-03', geslacht: 'V', email: 'liesbeth.desmet@telenet.be', telefoon: '+32 477 12 34 56', adres: 'Marktplein 3', postcode: '2200', gemeente: 'Herentals', land: 'Belgie', status: 'actief', createdAt: '2024-09-20', updatedAt: '2024-12-09' },
  { id: 'P-2024-0013', type: 'rechtspersoon', voornaam: '', achternaam: '', naam: 'CVBA Wonen Plus', rrn: '0501.234.567', geboortedatum: '', geslacht: 'X', email: 'info@wonenplus.be', telefoon: '+32 9 345 67 89', adres: 'Sint-Pietersnieuwstraat 77', postcode: '9000', gemeente: 'Gent', land: 'Belgie', status: 'actief', createdAt: '2024-04-15', updatedAt: '2024-11-22' },
  { id: 'P-2024-0014', type: 'natuurlijk', voornaam: 'Bart', achternaam: 'Vandenberghe', rrn: '69.05.22-123.45', geboortedatum: '1969-05-22', geslacht: 'M', email: 'bart.vdb@proximus.be', telefoon: '+32 478 23 45 67', adres: 'Eikenlaan 44', postcode: '2640', gemeente: 'Mortsel', land: 'Belgie', status: 'inactief', createdAt: '2024-10-05', updatedAt: '2024-11-18' },
  { id: 'P-2024-0015', type: 'natuurlijk', voornaam: 'Sofie', achternaam: 'Claes', rrn: '88.10.11-234.56', geboortedatum: '1988-10-11', geslacht: 'V', email: 'sofie.claes@gmail.com', telefoon: '+32 479 34 56 78', adres: 'Bosstraat 21', postcode: '3500', gemeente: 'Hasselt', land: 'Belgie', status: 'actief', createdAt: '2024-10-28', updatedAt: '2024-12-11' },
  { id: 'P-2024-0016', type: 'natuurlijk', voornaam: 'Dirk', achternaam: 'Verhoeven', rrn: '74.04.02-345.67', geboortedatum: '1974-04-02', geslacht: 'M', email: 'dirk.verhoeven@outlook.be', telefoon: '+32 470 45 67 89', adres: 'Kerkstraat 9', postcode: '2800', gemeente: 'Mechelen', land: 'Belgie', status: 'actief', createdAt: '2024-11-10', updatedAt: '2024-12-01' },
  { id: 'P-2024-0017', type: 'natuurlijk', voornaam: 'Nathalie', achternaam: 'Bosmans', rrn: '92.08.15-456.78', geboortedatum: '1992-08-15', geslacht: 'V', email: 'nathalie.bosmans@telenet.be', telefoon: '+32 471 56 78 90', adres: 'Adegemstraat 31', postcode: '2800', gemeente: 'Mechelen', land: 'Belgie', status: 'prospect', createdAt: '2024-11-25', updatedAt: '2024-12-10' },
  { id: 'P-2024-0018', type: 'rechtspersoon', voornaam: '', achternaam: '', naam: 'BV AutoVloot Beheer', rrn: '0734.567.891', geboortedatum: '', geslacht: 'X', email: 'info@autovloot.be', telefoon: '+32 3 456 78 90', adres: 'Noorderlaan 150', postcode: '2030', gemeente: 'Antwerpen', land: 'Belgie', status: 'actief', createdAt: '2024-05-20', updatedAt: '2024-12-04' },
]

// ====== Institutions ======
export const institutions: Institution[] = [
  { id: 'I-001', naam: 'Ethias Verzekeringen', type: 'verzekeringsmaatschappij', kbo: '0403.444.565', adres: 'Rue des Croisiers 24', postcode: '4000', gemeente: 'Luik', email: 'info@ethias.be', telefoon: '04 220 51 11', status: 'actief', createdAt: '2024-01-01' },
  { id: 'I-002', naam: 'AG Insurance', type: 'verzekeringsmaatschappij', kbo: '0404.444.666', adres: 'Boulevard Emile Jacqmain 53', postcode: '1000', gemeente: 'Brussel', email: 'info@aginsurance.be', telefoon: '02 554 41 11', status: 'actief', createdAt: '2024-01-01' },
  { id: 'I-003', naam: 'KBC Verzekeringen', type: 'bank', kbo: '0405.444.777', adres: 'Havenlaan 2', postcode: '1080', gemeente: 'Brussel', email: 'info@kbc.be', telefoon: '016 43 25 11', status: 'actief', createdAt: '2024-01-01' },
  { id: 'I-004', naam: 'Baloise Insurance', type: 'verzekeringsmaatschappij', kbo: '0406.444.888', adres: 'Boulevard Bischoffsheim 11', postcode: '1000', gemeente: 'Brussel', email: 'info@baloise.be', telefoon: '02 542 51 11', status: 'actief', createdAt: '2024-01-01' },
  { id: 'I-005', naam: 'Allianz Belgium', type: 'verzekeringsmaatschappij', kbo: '0407.444.999', adres: 'Boulevard du Souverain 33', postcode: '1170', gemeente: 'Watermaal-Bosvoorde', email: 'info@allianz.be', telefoon: '02 554 92 11', status: 'actief', createdAt: '2024-01-01' },
  { id: 'I-006', naam: 'Federale Verzekering', type: 'verzekeringsmaatschappij', kbo: '0408.444.000', adres: 'Maatschappijlaan 1', postcode: '9000', gemeente: 'Gent', email: 'info@federale.be', telefoon: '09 269 91 11', status: 'actief', createdAt: '2024-01-01' },
  { id: 'I-007', naam: 'Axa Belgium', type: 'verzekeringsmaatschappij', kbo: '0409.444.111', adres: 'Boulevard du Roi Albert II 33', postcode: '1030', gemeente: 'Brussel', email: 'info@axa.be', telefoon: '02 550 21 11', status: 'actief', createdAt: '2024-01-01' },
  { id: 'I-008', naam: 'Argenta Assuranties', type: 'bank', kbo: '0410.444.222', adres: 'Argentalaan 1', postcode: '1930', gemeente: 'Zaventem', email: 'info@argenta.be', telefoon: '02 722 51 11', status: 'actief', createdAt: '2024-01-01' },
  { id: 'I-009', naam: 'Intervoor', type: 'intermediair', kbo: '0411.444.333', adres: 'Liersesteenweg 94', postcode: '2800', gemeente: 'Mechelen', email: 'info@intervoor.be', telefoon: '015 28 51 11', status: 'actief', createdAt: '2024-01-01' },
  { id: 'I-010', naam: 'Vivium Verzekeringen', type: 'verzekeringsmaatschappij', kbo: '0412.444.444', adres: 'Draperiestraat 19', postcode: '2018', gemeente: 'Antwerpen', email: 'info@vivium.be', telefoon: '03 222 51 11', status: 'actief', createdAt: '2024-01-01' },
  { id: 'I-011', naam: 'DKV Belgium', type: 'verzekeringsmaatschappij', kbo: '0413.444.555', adres: 'Mechelsesteenweg 236', postcode: '2018', gemeente: 'Antwerpen', email: 'info@dkv.be', telefoon: '03 287 51 11', status: 'actief', createdAt: '2024-01-01' },
  { id: 'I-012', naam: 'BNP Paribas Cardif', type: 'bank', kbo: '0414.444.666', adres: 'Montagne du Parc 3', postcode: '1000', gemeente: 'Brussel', email: 'info@bnpparibascardif.be', telefoon: '02 429 51 11', status: 'actief', createdAt: '2024-01-01' },
]

// ====== Objects ======
export const vehicles: Vehicle[] = [
  { id: 'O-V-001', merk: 'Mercedes-Benz', model: 'C-Klasse', type: 'personenwagen', kenteken: '1-ABC-234', chassisnummer: 'WDD2050122F123456', bouwjaar: 2022, brandstof: 'diesel', kleur: 'Zwart', eigenaarId: 'P-2024-0006' },
  { id: 'O-V-002', merk: 'BMW', model: 'X3', type: 'personenwagen', kenteken: '2-DEF-567', chassisnummer: '5UXTR7C53L9B12345', bouwjaar: 2023, brandstof: 'benzine', kleur: 'Wit', eigenaarId: 'P-2024-0002' },
  { id: 'O-V-003', merk: 'Volkswagen', model: 'Transporter', type: 'bestelwagen', kenteken: '3-GHI-890', chassisnummer: 'WV1ZZZ7HZPH123456', bouwjaar: 2021, brandstof: 'diesel', kleur: 'Grijs', eigenaarId: 'P-2024-0004' },
  { id: 'O-V-004', merk: 'Audi', model: 'A4', type: 'personenwagen', kenteken: '4-JKL-123', chassisnummer: 'WAUZZZ8K8NA123456', bouwjaar: 2023, brandstof: 'hybride', kleur: 'Blauw', eigenaarId: 'P-2024-0001' },
  { id: 'O-V-005', merk: 'Peugeot', model: '208', type: 'personenwagen', kenteken: '5-MNO-456', chassisnummer: 'VR3UPHNSKTY123456', bouwjaar: 2024, brandstof: 'elektrisch', kleur: 'Rood', eigenaarId: 'P-2024-0005' },
  { id: 'O-V-006', merk: 'Renault', model: 'Trafic', type: 'bestelwagen', kenteken: '6-PQR-789', chassisnummer: 'VF1FL000965123456', bouwjaar: 2022, brandstof: 'diesel', kleur: 'Wit', eigenaarId: 'P-2024-0018' },
  { id: 'O-V-007', merk: 'Tesla', model: 'Model 3', type: 'personenwagen', kenteken: '7-STU-012', chassisnummer: '5YJ3E1EA8PF123456', bouwjaar: 2024, brandstof: 'elektrisch', kleur: 'Wit', eigenaarId: 'P-2024-0012' },
  { id: 'O-V-008', merk: 'Ford', model: 'Focus', type: 'personenwagen', kenteken: '8-VWX-345', chassisnummer: 'WF0NXXGCHNJ123456', bouwjaar: 2021, brandstof: 'benzine', kleur: 'Zilver', eigenaarId: 'P-2024-0007' },
]

export const realEstates: RealEstate[] = [
  { id: 'O-R-001', type: 'woning', adres: 'Korenmarkt 12', postcode: '2800', gemeente: 'Mechelen', bouwjaar: 1985, oppervlakte: 185, eigenaarId: 'P-2024-0001' },
  { id: 'O-R-002', type: 'appartement', adres: 'Bondgenotenlaan 45, bus 3', postcode: '3000', gemeente: 'Leuven', bouwjaar: 2005, oppervlakte: 92, eigenaarId: 'P-2024-0002' },
  { id: 'O-R-003', type: 'handelspand', adres: 'Industrielaan 22', postcode: '2018', gemeente: 'Antwerpen', bouwjaar: 1995, oppervlakte: 450, eigenaarId: 'P-2024-0004' },
  { id: 'O-R-004', type: 'woning', adres: 'Stationsstraat 33', postcode: '9000', gemeente: 'Gent', bouwjaar: 1970, oppervlakte: 210, eigenaarId: 'P-2024-0005' },
  { id: 'O-R-005', type: 'appartement', adres: 'Nieuwstraat 5, bus 12', postcode: '1000', gemeente: 'Brussel', bouwjaar: 2010, oppervlakte: 78, eigenaarId: 'P-2024-0007' },
  { id: 'O-R-006', type: 'woning', adres: 'Eikenlaan 44', postcode: '2640', gemeente: 'Mortsel', bouwjaar: 1992, oppervlakte: 165, eigenaarId: 'P-2024-0014' },
]

export const objects: AssurObject[] = [...vehicles, ...realEstates]

// ====== Contracts ======
export const contracts: Contract[] = [
  { id: 'C-001', contractnummer: 'VC-2024-004892', domein: 'auto', status: 'actief', product: 'Autoverzekering Omnium+', maatschappijId: 'I-001', premie: 1450.00, provisie: 145.00, startdatum: '2024-01-01', einddatum: '2025-01-01', verzekerdeNamen: ['Jan Peeters'], objectId: 'O-V-004', createdAt: '2024-01-01' },
  { id: 'C-002', contractnummer: 'VC-2024-004721', domein: 'brand', status: 'actief', product: 'Woonverzekering Plus', maatschappijId: 'I-002', premie: 890.00, provisie: 89.00, startdatum: '2024-01-15', einddatum: '2025-01-15', verzekerdeNamen: ['Pieter Janssens'], objectId: 'O-R-001', createdAt: '2024-01-15' },
  { id: 'C-003', contractnummer: 'VC-2024-004105', domein: 'auto', status: 'actief', product: 'Autoverzekering BA + Mini-Omnium', maatschappijId: 'I-003', premie: 780.00, provisie: 78.00, startdatum: '2024-02-01', einddatum: '2025-02-01', verzekerdeNamen: ['Marie Dubois'], objectId: 'O-V-002', createdAt: '2024-02-01' },
  { id: 'C-004', contractnummer: 'VC-2024-003892', domein: 'leven', status: 'actief', product: 'Levensverzekering Tijddekking', maatschappijId: 'I-004', premie: 3200.00, provisie: 320.00, startdatum: '2024-03-01', einddatum: '2034-03-01', verzekerdeNamen: ['BVBA De Boer'], objectId: undefined, createdAt: '2024-03-01' },
  { id: 'C-005', contractnummer: 'VC-2024-004156', domein: 'hospitalisatie', status: 'actief', product: 'Hospitalisatie Comfort', maatschappijId: 'I-011', premie: 1250.00, provisie: 125.00, startdatum: '2024-04-01', einddatum: '2025-04-01', verzekerdeNamen: ['Thomas Peeters'], objectId: undefined, createdAt: '2024-04-01' },
  { id: 'C-006', contractnummer: 'VC-2024-003567', domein: 'auto', status: 'actief', product: 'Autoverzekering BA', maatschappijId: 'I-005', premie: 450.00, provisie: 45.00, startdatum: '2024-05-01', einddatum: '2025-05-01', verzekerdeNamen: ['Sarah Michiels'], objectId: 'O-V-008', createdAt: '2024-05-01' },
  { id: 'C-007', contractnummer: 'VC-2024-004890', domein: 'auto', status: 'actief', product: 'Autoverzekering Omnium+', maatschappijId: 'I-001', premie: 2100.00, provisie: 210.00, startdatum: '2024-06-01', einddatum: '2025-06-01', verzekerdeNamen: ['Lucas Peeters'], objectId: 'O-V-001', createdAt: '2024-06-01' },
  { id: 'C-008', contractnummer: 'VC-2024-004678', domein: 'ao', status: 'actief', product: 'Arbeidsongevallen Standaard', maatschappijId: 'I-007', premie: 650.00, provisie: 65.00, startdatum: '2024-07-01', einddatum: '2025-07-01', verzekerdeNamen: ['NV Verzekerd Goed'], objectId: undefined, createdAt: '2024-07-01' },
  { id: 'C-009', contractnummer: 'VC-2024-004345', domein: 'brand', status: 'actief', product: 'Inboedelverzekering', maatschappijId: 'I-006', premie: 320.00, provisie: 32.00, startdatum: '2024-08-01', einddatum: '2025-08-01', verzekerdeNamen: ['Anna Vermeiren'], objectId: 'O-R-004', createdAt: '2024-08-01' },
  { id: 'C-010', contractnummer: 'VC-2024-004123', domein: 'diversen', status: 'actief', product: 'Rechtsbijstand Privé', maatschappijId: 'I-010', premie: 180.00, provisie: 18.00, startdatum: '2024-09-01', einddatum: '2025-09-01', verzekerdeNamen: ['Koen Maes'], objectId: undefined, createdAt: '2024-09-01' },
  { id: 'C-011', contractnummer: 'VC-2024-004001', domein: 'auto', status: 'actief', product: 'Autoverzekering BA + Mini-Omnium', maatschappijId: 'I-003', premie: 920.00, provisie: 92.00, startdatum: '2024-10-01', einddatum: '2025-10-01', verzekerdeNamen: ['Liesbeth De Smet'], objectId: 'O-V-007', createdAt: '2024-10-01' },
  { id: 'C-012', contractnummer: 'VC-2024-003899', domein: 'brand', status: 'actief', product: 'Woonverzekering', maatschappijId: 'I-002', premie: 780.00, provisie: 78.00, startdatum: '2024-11-01', einddatum: '2025-11-01', verzekerdeNamen: ['Sofie Claes'], objectId: 'O-R-006', createdAt: '2024-11-01' },
  { id: 'C-013', contractnummer: 'VC-2024-004234', domein: 'leven', status: 'actief', product: 'Overlijdensdekking', maatschappijId: 'I-004', premie: 480.00, provisie: 48.00, startdatum: '2024-12-01', einddatum: '2034-12-01', verzekerdeNamen: ['Dirk Verhoeven'], objectId: undefined, createdAt: '2024-12-01' },
  { id: 'C-014', contractnummer: 'VC-2024-004567', domein: 'auto', status: 'actief', product: 'Vlootverzekering BA', maatschappijId: 'I-001', premie: 3200.00, provisie: 320.00, startdatum: '2024-06-01', einddatum: '2025-06-01', verzekerdeNamen: ['BV AutoVloot Beheer'], objectId: 'O-V-006', createdAt: '2024-06-01' },
  { id: 'C-015', contractnummer: 'VC-2024-004445', domein: 'hospitalisatie', status: 'actief', product: 'Hospitalisatie Top', maatschappijId: 'I-011', premie: 1850.00, provisie: 185.00, startdatum: '2024-08-15', einddatum: '2025-08-15', verzekerdeNamen: ['Marie Dubois'], objectId: undefined, createdAt: '2024-08-15' },
]

// ====== Schadeclaims ======
export const claims: Schadeclaim[] = [
  { id: 'CL-001', claimnummer: 'SC-2024-00341', contractnummer: 'VC-2024-004892', status: 'in_behandeling', categorie: 'Auto (aanrijding)', beschrijving: 'Aanrijding voorzijde bij rotonde', datumSchade: '2024-12-10', datumMelding: '2024-12-11', bedrag: 4850.00, verzekerdeNaam: 'Jan Peeters', urgentie: 'normaal', dagenOpen: 12 },
  { id: 'CL-002', claimnummer: 'SC-2024-00338', contractnummer: 'VC-2024-004105', status: 'in_behandeling', categorie: 'Brand (waterlekkage)', beschrijving: 'Waterlekkage badkamer plafond', datumSchade: '2024-12-04', datumMelding: '2024-12-05', bedrag: 3200.00, verzekerdeNaam: 'Anna Vermeiren', urgentie: 'normaal', dagenOpen: 18 },
  { id: 'CL-003', claimnummer: 'SC-2024-00325', contractnummer: 'VC-2024-004890', status: 'in_afwachting_dossier', categorie: 'Burgerlijke Aansprakelijkheid', beschrijving: 'Schade aan derde eigendom', datumSchade: '2024-11-18', datumMelding: '2024-11-19', bedrag: 12500.00, verzekerdeNaam: 'BVBA De Boer', urgentie: 'kritiek', dagenOpen: 34 },
  { id: 'CL-004', claimnummer: 'SC-2024-00329', contractnummer: 'VC-2024-003892', status: 'expert_aangesteld', categorie: 'Auto (parkeerschade)', beschrijving: 'Parkeerschade linker achterdeur', datumSchade: '2024-12-14', datumMelding: '2024-12-14', bedrag: 1850.00, verzekerdeNaam: 'Lucas Peeters', urgentie: 'normaal', dagenOpen: 8 },
  { id: 'CL-005', claimnummer: 'SC-2024-00315', contractnummer: 'VC-2024-004001', status: 'nieuw', categorie: 'Auto (steenschade)', beschrijving: 'Steenschade voorruit', datumSchade: '2024-12-18', datumMelding: '2024-12-19', bedrag: 650.00, verzekerdeNaam: 'Liesbeth De Smet', urgentie: 'normaal', dagenOpen: 4 },
  { id: 'CL-006', claimnummer: 'SC-2024-00310', contractnummer: 'VC-2024-004156', status: 'in_behandeling', categorie: 'Hospitalisatie', beschrijving: 'Opname ziekenhuis galloperatie', datumSchade: '2024-12-01', datumMelding: '2024-12-02', bedrag: 2800.00, verzekerdeNaam: 'Thomas Peeters', urgentie: 'normaal', dagenOpen: 21 },
  { id: 'CL-007', claimnummer: 'SC-2024-00298', contractnummer: 'VC-2024-003567', status: 'in_behandeling', categorie: 'Auto (achteraanrijding)', beschrijving: 'Achteraanrijding op E19', datumSchade: '2024-11-25', datumMelding: '2024-11-26', bedrag: 7200.00, verzekerdeNaam: 'Sarah Michiels', urgentie: 'hoog', dagenOpen: 27 },
  { id: 'CL-008', claimnummer: 'SC-2024-00285', contractnummer: 'VC-2024-004678', status: 'afgesloten', categorie: 'Arbeidsongeval', beschrijving: 'Blessure rug op werkvloer', datumSchade: '2024-10-15', datumMelding: '2024-10-16', bedrag: 4500.00, verzekerdeNaam: 'NV Verzekerd Goed', urgentie: 'normaal', dagenOpen: 0 },
  { id: 'CL-009', claimnummer: 'SC-2024-00280', contractnummer: 'VC-2024-004890', status: 'in_afwachting_dossier', categorie: 'Auto (diefstal)', beschrijving: 'Diefstal navigatiesysteem', datumSchade: '2024-11-10', datumMelding: '2024-11-11', bedrag: 950.00, verzekerdeNaam: 'Lucas Peeters', urgentie: 'normaal', dagenOpen: 42 },
  { id: 'CL-010', claimnummer: 'SC-2024-00275', contractnummer: 'VC-2024-004345', status: 'afgesloten', categorie: 'Brand (stormschade)', beschrijving: 'Stormschade dakpannen', datumSchade: '2024-09-20', datumMelding: '2024-09-21', bedrag: 5600.00, verzekerdeNaam: 'Koen Maes', urgentie: 'normaal', dagenOpen: 0 },
  { id: 'CL-011', claimnummer: 'SC-2024-00270', contractnummer: 'VC-2024-004234', status: 'in_behandeling', categorie: 'Auto (aanrijding)', beschrijving: 'Kop-staart botsing', datumSchade: '2024-12-08', datumMelding: '2024-12-09', bedrag: 8900.00, verzekerdeNaam: 'Dirk Verhoeven', urgentie: 'hoog', dagenOpen: 14 },
  { id: 'CL-012', claimnummer: 'SC-2024-00265', contractnummer: 'VC-2024-004123', status: 'in_behandeling', categorie: 'Rechtsbijstand', beschrijving: 'Geschil met aannemer', datumSchade: '2024-12-05', datumMelding: '2024-12-06', bedrag: 2200.00, verzekerdeNaam: 'Koen Maes', urgentie: 'normaal', dagenOpen: 17 },
]

// ====== Recent Activity ======
export const activities: Activiteit[] = [
  { id: 'A-001', type: 'claim_bijgewerkt', gebruiker: 'Marie Dubois', beschrijving: 'heeft schadeclaim #SC-2024-00341 bijgewerkt — status gewijzigd naar \'In behandeling\'', entityRef: '#SC-2024-00341', timestamp: '2024-12-19T14:45:00Z', relativeTime: '3 minuten geleden' },
  { id: 'A-002', type: 'herinnering', gebruiker: 'Systeem', beschrijving: 'heeft herinneringsmail verstuurd voor contract #VC-2024-004721 (vervalt over 14 dagen)', entityRef: '#VC-2024-004721', timestamp: '2024-12-19T14:33:00Z', relativeTime: '15 minuten geleden' },
  { id: 'A-003', type: 'persoon_toegevoegd', gebruiker: 'Pieter Janssens', beschrijving: 'heeft persoon #P-2024-0892 (BVBA De Boer) toegevoegd', entityRef: '#P-2024-0892', timestamp: '2024-12-19T14:16:00Z', relativeTime: '32 minuten geleden' },
  { id: 'A-004', type: 'verlenging', gebruiker: 'Systeem', beschrijving: 'heeft contract #VC-2024-004105 automatisch verlengd', entityRef: '#VC-2024-004105', timestamp: '2024-12-19T13:48:00Z', relativeTime: '1 uur geleden' },
  { id: 'A-005', type: 'commissie', gebruiker: 'Anna Vermeiren', beschrijving: 'heeft commissiebetaling van € 1.240,00 geboekt', entityRef: undefined, timestamp: '2024-12-19T12:45:00Z', relativeTime: '2 uur geleden' },
  { id: 'A-006', type: 'object_gekoppeld', gebruiker: 'Lucas Peeters', beschrijving: 'heeft object Mercedes C-Klasse (1-ABC-234) gekoppeld aan contract #VC-2024-004890', entityRef: 'Mercedes C-Klasse (1-ABC-234)', timestamp: '2024-12-19T11:45:00Z', relativeTime: '3 uur geleden' },
  { id: 'A-007', type: 'batch_export', gebruiker: 'Systeem', beschrijving: 'heeft batch export van 45 contracten voltooid', entityRef: undefined, timestamp: '2024-12-19T09:45:00Z', relativeTime: '5 uur geleden' },
  { id: 'A-008', type: 'contract_aangemaakt', gebruiker: 'Jan Peeters', beschrijving: 'heeft contract #VC-2024-004892 aangemaakt', entityRef: '#VC-2024-004892', timestamp: '2024-12-19T08:30:00Z', relativeTime: '6 uur geleden' },
  { id: 'A-009', type: 'claim_bijgewerkt', gebruiker: 'Marie Dubois', beschrijving: 'heeft schadeclaim #SC-2024-00338 bijgewerkt — expert aangesteld', entityRef: '#SC-2024-00338', timestamp: '2024-12-19T07:15:00Z', relativeTime: '7 uur geleden' },
  { id: 'A-010', type: 'systeem', gebruiker: 'Systeem', beschrijving: 'Automatische backup voltooid — 1.240 records geëxporteerd', entityRef: undefined, timestamp: '2024-12-19T06:00:00Z', relativeTime: '8 uur geleden' },
]

// ====== Dashboard Data ======

export const kpiData = {
  actieveContracten: { value: '1.247', trend: 'up' as const, trendValue: '+3,2%', subtitle: 'vs. vorige maand (1.208)' },
  openSchades: { value: '38', trend: 'down' as const, trendValue: '-12%', subtitle: '5 dringend (>30 dagen)' },
  totaalPersonen: { value: '2.856', trend: 'up' as const, trendValue: '+1,8%', subtitle: '2.143 natuurlijk · 713 rechtspersoon' },
  maandOmzet: { value: '€ 42.680', trend: 'up' as const, trendValue: '+8,5%', subtitle: 'vs. € 39.320 vorige maand' },
  vervallenBinnenkort: { value: '127', trend: 'up' as const, trendValue: '+5', subtitle: 'Contracten vervallen binnen 30 dagen' },
  nieuweDitKwartaal: { value: '312', trend: 'up' as const, trendValue: '+24%', subtitle: 'Nieuwe contracten Q4 2024' },
}

export const monthlyChartData = [
  { maand: 'Jan', contracten: 98, commissie: 32400 },
  { maand: 'Feb', contracten: 102, commissie: 34100 },
  { maand: 'Mrt', contracten: 115, commissie: 38200 },
  { maand: 'Apr', contracten: 108, commissie: 36500 },
  { maand: 'Mei', contracten: 125, commissie: 41800 },
  { maand: 'Jun', contracten: 132, commissie: 44200 },
  { maand: 'Jul', contracten: 128, commissie: 42600 },
  { maand: 'Aug', contracten: 140, commissie: 46800 },
  { maand: 'Sep', contracten: 138, commissie: 45900 },
  { maand: 'Okt', contracten: 145, commissie: 48200 },
  { maand: 'Nov', contracten: 142, commissie: 47100 },
  { maand: 'Dec', contracten: 130, commissie: 42680 },
]

export const claimsByCategory = [
  { name: 'Auto (BA/Mini-Omnium/Omnium)', value: 18, color: '#4A804A' },
  { name: 'Brand/Woning', value: 7, color: '#3B6EA5' },
  { name: 'Burgerlijke Aansprakelijkheid', value: 4, color: '#C8A456' },
  { name: 'Rechtsbijstand', value: 5, color: '#8B5E83' },
  { name: 'Andere', value: 4, color: '#C07A4A' },
]

export const expiringContracts = [
  { id: 'EC-001', contractnummer: '#VC-2024-004721', verzekerde: 'Pieter Janssens', vervaldatum: '2025-01-02', dagenResterend: 14, status: 'error' as const },
  { id: 'EC-002', contractnummer: '#VC-2024-004105', verzekerde: 'Marie Dubois', vervaldatum: '2025-01-08', dagenResterend: 20, status: 'warning' as const },
  { id: 'EC-003', contractnummer: '#VC-2024-003892', verzekerde: 'BVBA De Boer', vervaldatum: '2025-01-15', dagenResterend: 27, status: 'warning' as const },
  { id: 'EC-004', contractnummer: '#VC-2024-004156', verzekerde: 'Thomas Peeters', vervaldatum: '2025-01-22', dagenResterend: 34, status: 'info' as const },
  { id: 'EC-005', contractnummer: '#VC-2024-003567', verzekerde: 'Sarah Michiels', vervaldatum: '2025-01-28', dagenResterend: 40, status: 'info' as const },
]

export const openClaimsSummary = [
  { id: 'OS-001', claimnummer: '#SC-2024-00341', verzekerde: 'Jan Peeters', type: 'Auto (aanrijding)', status: 'in_behandeling', dagenOpen: 12, urgent: false },
  { id: 'OS-002', claimnummer: '#SC-2024-00338', verzekerde: 'Anna Vermeiren', type: 'Brand (waterlekkage)', status: 'in_behandeling', dagenOpen: 18, urgent: false },
  { id: 'OS-003', claimnummer: '#SC-2024-00325', verzekerde: 'BVBA De Boer', type: 'Burgerlijke Aansprakelijkheid', status: 'in_afwachting_dossier', dagenOpen: 34, urgent: true },
  { id: 'OS-004', claimnummer: '#SC-2024-00329', verzekerde: 'Lucas Peeters', type: 'Auto (parkeerschade)', status: 'expert_aangesteld', dagenOpen: 8, urgent: false },
  { id: 'OS-005', claimnummer: 'SC-2024-00315', verzekerde: 'Liesbeth De Smet', type: 'Auto (steenschade)', status: 'nieuw', dagenOpen: 4, urgent: false },
  { id: 'OS-006', claimnummer: 'SC-2024-00298', verzekerde: 'Sarah Michiels', type: 'Auto (achteraanrijding)', status: 'in_behandeling', dagenOpen: 27, urgent: true },
]

// Status label mapping
export const statusLabels: Record<string, string> = {
  actief: 'Actief',
  verlopen: 'Verlopen',
  vervallen: 'Vervallen',
  in_behandeling: 'In behandeling',
  annulatie: 'Annulatie',
  nieuw: 'Nieuw',
  in_afwachting_dossier: 'In afwachting dossier',
  expert_aangesteld: 'Expert aangesteld',
  afgesloten: 'Afgesloten',
  afgekeurd: 'Afgekeurd',
  prospect: 'Prospect',
  inactief: 'Inactief',
}

export const domeinLabels: Record<string, string> = {
  auto: 'Auto',
  brand: 'Brand',
  leven: 'Leven',
  ao: 'AO',
  hospitalisatie: 'Hospitalisatie',
  diversen: 'Diversen',
}
