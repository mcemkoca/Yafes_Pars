/**
 * AssureManager Mock Data
 * Complete mock dataset for fallback when SQL Server is unavailable
 * All data in Dutch/Flemish with Belgian context
 */

const persons = [
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
  { id: 'P-2024-0019', type: 'natuurlijk', voornaam: 'Patrick', achternaam: 'Jacobs', rrn: '67.03.14-111.22', geboortedatum: '1967-03-14', geslacht: 'M', email: 'patrick.jacobs@telenet.be', telefoon: '+32 480 11 22 33', adres: 'Kerkhofstraat 77', postcode: '8500', gemeente: 'Kortrijk', land: 'Belgie', status: 'actief', createdAt: '2024-01-08', updatedAt: '2024-11-25' },
  { id: 'P-2024-0020', type: 'natuurlijk', voornaam: 'Christine', achternaam: 'Lemmens', rrn: '79.07.22-333.44', geboortedatum: '1979-07-22', geslacht: 'V', email: 'christine.lemmens@gmail.com', telefoon: '+32 481 22 33 44', adres: 'Stationsplein 2', postcode: '3800', gemeente: 'Sint-Truiden', land: 'Belgie', status: 'actief', createdAt: '2024-02-14', updatedAt: '2024-12-02' },
  { id: 'P-2024-0021', type: 'natuurlijk', voornaam: 'Wim', achternaam: 'Goossens', rrn: '71.11.09-555.66', geboortedatum: '1971-11-09', geslacht: 'M', email: 'wim.goossens@proximus.be', telefoon: '+32 482 33 44 55', adres: 'Dorpstraat 15', postcode: '2970', gemeente: 'Schilde', land: 'Belgie', status: 'actief', createdAt: '2024-03-22', updatedAt: '2024-11-29' },
  { id: 'P-2024-0022', type: 'rechtspersoon', voornaam: '', achternaam: '', naam: 'NV Technisch Bureau Janssens', rrn: '0412.345.678', geboortedatum: '', geslacht: 'X', email: 'info@tbjanssens.be', telefoon: '+32 9 456 12 34', adres: 'Technologiepark 10', postcode: '9052', gemeente: 'Zwijnaarde', land: 'Belgie', status: 'actief', createdAt: '2024-04-01', updatedAt: '2024-12-03' },
  { id: 'P-2024-0023', type: 'natuurlijk', voornaam: 'Karin', achternaam: 'Willems', rrn: '86.01.30-777.88', geboortedatum: '1986-01-30', geslacht: 'V', email: 'karin.willems@outlook.be', telefoon: '+32 483 44 55 66', adres: 'Molenstraat 28', postcode: '1740', gemeente: 'Ternat', land: 'Belgie', status: 'prospect', createdAt: '2024-05-18', updatedAt: '2024-12-08' },
  { id: 'P-2024-0024', type: 'natuurlijk', voornaam: 'Marc', achternaam: 'Desmet', rrn: '73.06.17-999.00', geboortedatum: '1973-06-17', geslacht: 'M', email: 'marc.desmet@skynet.be', telefoon: '+32 484 55 66 77', adres: 'Wilgenlaan 6', postcode: '8400', gemeente: 'Oostende', land: 'Belgie', status: 'actief', createdAt: '2024-06-10', updatedAt: '2024-12-05' },
  { id: 'P-2024-0025', type: 'natuurlijk', voornaam: 'Els', achternaam: 'Van den Broeck', rrn: '91.12.05-123.99', geboortedatum: '1991-12-05', geslacht: 'V', email: 'els.vandenbroeck@telenet.be', telefoon: '+32 485 66 77 88', adres: 'Eikenstraat 41', postcode: '3070', gemeente: 'Kortenberg', land: 'Belgie', status: 'actief', createdAt: '2024-07-01', updatedAt: '2024-12-01' },
  { id: 'P-2024-0026', type: 'rechtspersoon', voornaam: '', achternaam: '', naam: 'BVBA Constructie Peeters', rrn: '0834.567.123', geboortedatum: '', geslacht: 'X', email: 'info@constructiepeeters.be', telefoon: '+32 3 567 89 01', adres: 'Boulevard Industriel 45', postcode: '1070', gemeente: 'Anderlecht', land: 'Belgie', status: 'actief', createdAt: '2024-08-15', updatedAt: '2024-11-20' },
  { id: 'P-2024-0027', type: 'natuurlijk', voornaam: 'Tom', achternaam: 'Aerts', rrn: '76.09.11-456.77', geboortedatum: '1976-09-11', geslacht: 'M', email: 'tom.aerts@gmail.com', telefoon: '+32 486 77 88 99', adres: 'Hoogstraat 33', postcode: '1500', gemeente: 'Halle', land: 'Belgie', status: 'actief', createdAt: '2024-09-01', updatedAt: '2024-12-10' },
  { id: 'P-2024-0028', type: 'natuurlijk', voornaam: 'Inge', achternaam: 'Martens', rrn: '84.02.28-789.66', geboortedatum: '1984-02-28', geslacht: 'V', email: 'inge.martens@proximus.be', telefoon: '+32 487 88 99 00', adres: 'Schoolstraat 8', postcode: '2460', gemeente: 'Kasterlee', land: 'Belgie', status: 'inactief', createdAt: '2024-10-10', updatedAt: '2024-11-15' },
];

const institutions = [
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
  { id: 'I-013', naam: 'ING Belgique', type: 'bank', kbo: '0415.444.777', adres: 'Avenue Marnix 24', postcode: '1000', gemeente: 'Brussel', email: 'info@ing.be', telefoon: '02 547 12 11', status: 'actief', createdAt: '2024-01-01' },
  { id: 'I-014', naam: 'Delta Lloyd Life', type: 'verzekeringsmaatschappij', kbo: '0416.444.888', adres: 'Generaal Lemanlaan 2', postcode: '1000', gemeente: 'Brussel', email: 'info@deltalloyd.be', telefoon: '02 551 31 11', status: 'actief', createdAt: '2024-01-01' },
  { id: 'I-015', naam: 'Europ Assistance', type: 'verzekeringsmaatschappij', kbo: '0417.444.999', adres: 'Broustinlaan 5', postcode: '1083', gemeente: 'Ganshoren', email: 'info@europassistance.be', telefoon: '02 558 71 11', status: 'actief', createdAt: '2024-01-01' },
  { id: 'I-016', naam: 'Autofix Repair', type: 'reparatie', kbo: '0418.444.000', adres: 'Nijverheidsstraat 45', postcode: '2160', gemeente: 'Wommelgem', email: 'info@autofix.be', telefoon: '03 320 51 11', status: 'actief', createdAt: '2024-01-01' },
];

// ====== Objects ======
const vehicles = [
  { id: 'O-V-001', category: 'voertuig', merk: 'Mercedes-Benz', model: 'C-Klasse', type: 'personenwagen', kenteken: '1-ABC-234', chassisnummer: 'WDD2050122F123456', bouwjaar: 2022, brandstof: 'diesel', kleur: 'Zwart', eigenaarId: 'P-2024-0006' },
  { id: 'O-V-002', category: 'voertuig', merk: 'BMW', model: 'X3', type: 'personenwagen', kenteken: '2-DEF-567', chassisnummer: '5UXTR7C53L9B12345', bouwjaar: 2023, brandstof: 'benzine', kleur: 'Wit', eigenaarId: 'P-2024-0002' },
  { id: 'O-V-003', category: 'voertuig', merk: 'Volkswagen', model: 'Transporter', type: 'bestelwagen', kenteken: '3-GHI-890', chassisnummer: 'WV1ZZZ7HZPH123456', bouwjaar: 2021, brandstof: 'diesel', kleur: 'Grijs', eigenaarId: 'P-2024-0004' },
  { id: 'O-V-004', category: 'voertuig', merk: 'Audi', model: 'A4', type: 'personenwagen', kenteken: '4-JKL-123', chassisnummer: 'WAUZZZ8K8NA123456', bouwjaar: 2023, brandstof: 'hybride', kleur: 'Blauw', eigenaarId: 'P-2024-0001' },
  { id: 'O-V-005', category: 'voertuig', merk: 'Peugeot', model: '208', type: 'personenwagen', kenteken: '5-MNO-456', chassisnummer: 'VR3UPHNSKTY123456', bouwjaar: 2024, brandstof: 'elektrisch', kleur: 'Rood', eigenaarId: 'P-2024-0005' },
  { id: 'O-V-006', category: 'voertuig', merk: 'Renault', model: 'Trafic', type: 'bestelwagen', kenteken: '6-PQR-789', chassisnummer: 'VF1FL000965123456', bouwjaar: 2022, brandstof: 'diesel', kleur: 'Wit', eigenaarId: 'P-2024-0018' },
  { id: 'O-V-007', category: 'voertuig', merk: 'Tesla', model: 'Model 3', type: 'personenwagen', kenteken: '7-STU-012', chassisnummer: '5YJ3E1EA8PF123456', bouwjaar: 2024, brandstof: 'elektrisch', kleur: 'Wit', eigenaarId: 'P-2024-0012' },
  { id: 'O-V-008', category: 'voertuig', merk: 'Ford', model: 'Focus', type: 'personenwagen', kenteken: '8-VWX-345', chassisnummer: 'WF0NXXGCHNJ123456', bouwjaar: 2021, brandstof: 'benzine', kleur: 'Zilver', eigenaarId: 'P-2024-0007' },
  { id: 'O-V-009', category: 'voertuig', merk: 'Yamaha', model: 'MT-07', type: 'motorfiets', kenteken: '9-YZA-678', chassisnummer: 'JYARN23N000012345', bouwjaar: 2023, brandstof: 'benzine', kleur: 'Blauw', eigenaarId: 'P-2024-0011' },
  { id: 'O-V-010', category: 'voertuig', merk: 'Honda', model: 'Civic', type: 'personenwagen', kenteken: '0-BCD-901', chassisnummer: 'SHHFP13402U012345', bouwjaar: 2022, brandstof: 'hybride', kleur: 'Grijs', eigenaarId: 'P-2024-0015' },
];

const realEstates = [
  { id: 'O-R-001', category: 'vastgoed', subtype: 'woning', adres: 'Korenmarkt 12', postcode: '2800', gemeente: 'Mechelen', bouwjaar: 1985, oppervlakte: 185, eigenaarId: 'P-2024-0001' },
  { id: 'O-R-002', category: 'vastgoed', subtype: 'appartement', adres: 'Bondgenotenlaan 45, bus 3', postcode: '3000', gemeente: 'Leuven', bouwjaar: 2005, oppervlakte: 92, eigenaarId: 'P-2024-0002' },
  { id: 'O-R-003', category: 'vastgoed', subtype: 'handelspand', adres: 'Industrielaan 22', postcode: '2018', gemeente: 'Antwerpen', bouwjaar: 1995, oppervlakte: 450, eigenaarId: 'P-2024-0004' },
  { id: 'O-R-004', category: 'vastgoed', subtype: 'woning', adres: 'Stationsstraat 33', postcode: '9000', gemeente: 'Gent', bouwjaar: 1970, oppervlakte: 210, eigenaarId: 'P-2024-0005' },
  { id: 'O-R-005', category: 'vastgoed', subtype: 'appartement', adres: 'Nieuwstraat 5, bus 12', postcode: '1000', gemeente: 'Brussel', bouwjaar: 2010, oppervlakte: 78, eigenaarId: 'P-2024-0007' },
  { id: 'O-R-006', category: 'vastgoed', subtype: 'woning', adres: 'Eikenlaan 44', postcode: '2640', gemeente: 'Mortsel', bouwjaar: 1992, oppervlakte: 165, eigenaarId: 'P-2024-0014' },
];

const loans = [
  { id: 'O-L-001', category: 'lening', subtype: 'hypothecaire_lening', kredietgeverId: 'I-003', kredietnemerId: 'P-2024-0001', bedrag: 285000, looptijdMaanden: 240, maandelijksBedrag: 1425, startdatum: '2020-01-15', einddatum: '2040-01-15', status: 'actief' },
  { id: 'O-L-002', category: 'lening', subtype: 'autolening', kredietgeverId: 'I-003', kredietnemerId: 'P-2024-0002', bedrag: 35000, looptijdMaanden: 60, maandelijksBedrag: 620, startdatum: '2023-03-01', einddatum: '2028-03-01', status: 'actief' },
  { id: 'O-L-003', category: 'lening', subtype: 'hypothecaire_lening', kredietgeverId: 'I-008', kredietnemerId: 'P-2024-0005', bedrag: 410000, looptijdMaanden: 300, maandelijksBedrag: 1650, startdatum: '2019-06-15', einddatum: '2044-06-15', status: 'actief' },
];

const things = [
  { id: 'O-T-001', category: 'ding', beschrijving: 'Fotografie apparatuur set (Canon EOS R5 + lenzen)', waarde: 8500, eigenaarId: 'P-2024-0002' },
  { id: 'O-T-002', category: 'ding', beschrijving: 'Jachtboot Sea Ray 21 SPX', waarde: 42000, eigenaarId: 'P-2024-0011' },
  { id: 'O-T-003', category: 'ding', beschrijving: 'Sieraden collectie (diamanten ring, gouden ketting)', waarde: 15000, eigenaarId: 'P-2024-0007' },
  { id: 'O-T-004', category: 'ding', beschrijving: 'Elektrische fietsen (2x Trek)', waarde: 6800, eigenaarId: 'P-2024-0012' },
];

const activities = [
  { id: 'O-A-001', category: 'activiteit', subtype: 'bouw', beschrijving: 'Renovatieproject keuken + badkamer', locatie: 'Korenmarkt 12, 2800 Mechelen', startdatum: '2024-10-01', einddatum: '2024-12-15', opdrachtgeverId: 'P-2024-0001', status: 'actief' },
  { id: 'O-A-002', category: 'activiteit', subtype: 'evenement', beschrijving: 'Bedrijfsfeest jaarafsluiting 2024', locatie: 'Flanders Expo, 9000 Gent', startdatum: '2024-12-21', einddatum: '2024-12-21', opdrachtgeverId: 'P-2024-0004', status: 'gepland' },
];

const allObjects = [...vehicles, ...realEstates, ...loans, ...things, ...activities];

// ====== Contracts ======
const contracts = [
  { id: 'C-001', contractnummer: 'VC-2024-004892', domein: 'auto', status: 'actief', product: 'Autoverzekering Omnium+', maatschappijId: 'I-001', premie: 1450.00, provisie: 145.00, startdatum: '2024-01-01', einddatum: '2025-01-01', verzekerdeNamen: ['Jan Peeters'], objectId: 'O-V-004', createdAt: '2024-01-01' },
  { id: 'C-002', contractnummer: 'VC-2024-004721', domein: 'brand', status: 'actief', product: 'Woonverzekering Plus', maatschappijId: 'I-002', premie: 890.00, provisie: 89.00, startdatum: '2024-01-15', einddatum: '2025-01-15', verzekerdeNamen: ['Pieter Janssens'], objectId: 'O-R-001', createdAt: '2024-01-15' },
  { id: 'C-003', contractnummer: 'VC-2024-004105', domein: 'auto', status: 'actief', product: 'Autoverzekering BA + Mini-Omnium', maatschappijId: 'I-003', premie: 780.00, provisie: 78.00, startdatum: '2024-02-01', einddatum: '2025-02-01', verzekerdeNamen: ['Marie Dubois'], objectId: 'O-V-002', createdAt: '2024-02-01' },
  { id: 'C-004', contractnummer: 'VC-2024-003892', domein: 'leven', status: 'actief', product: 'Levensverzekering Tijddekking', maatschappijId: 'I-004', premie: 3200.00, provisie: 320.00, startdatum: '2024-03-01', einddatum: '2034-03-01', verzekerdeNamen: ['BVBA De Boer'], objectId: null, createdAt: '2024-03-01' },
  { id: 'C-005', contractnummer: 'VC-2024-004156', domein: 'hospitalisatie', status: 'actief', product: 'Hospitalisatie Comfort', maatschappijId: 'I-011', premie: 1250.00, provisie: 125.00, startdatum: '2024-04-01', einddatum: '2025-04-01', verzekerdeNamen: ['Thomas Peeters'], objectId: null, createdAt: '2024-04-01' },
  { id: 'C-006', contractnummer: 'VC-2024-003567', domein: 'auto', status: 'actief', product: 'Autoverzekering BA', maatschappijId: 'I-005', premie: 450.00, provisie: 45.00, startdatum: '2024-05-01', einddatum: '2025-05-01', verzekerdeNamen: ['Sarah Michiels'], objectId: 'O-V-008', createdAt: '2024-05-01' },
  { id: 'C-007', contractnummer: 'VC-2024-004890', domein: 'auto', status: 'actief', product: 'Autoverzekering Omnium+', maatschappijId: 'I-001', premie: 2100.00, provisie: 210.00, startdatum: '2024-06-01', einddatum: '2025-06-01', verzekerdeNamen: ['Lucas Peeters'], objectId: 'O-V-001', createdAt: '2024-06-01' },
  { id: 'C-008', contractnummer: 'VC-2024-004678', domein: 'ao', status: 'actief', product: 'Arbeidsongevallen Standaard', maatschappijId: 'I-007', premie: 650.00, provisie: 65.00, startdatum: '2024-07-01', einddatum: '2025-07-01', verzekerdeNamen: ['NV Verzekerd Goed'], objectId: null, createdAt: '2024-07-01' },
  { id: 'C-009', contractnummer: 'VC-2024-004345', domein: 'brand', status: 'actief', product: 'Inboedelverzekering', maatschappijId: 'I-006', premie: 320.00, provisie: 32.00, startdatum: '2024-08-01', einddatum: '2025-08-01', verzekerdeNamen: ['Anna Vermeiren'], objectId: 'O-R-004', createdAt: '2024-08-01' },
  { id: 'C-010', contractnummer: 'VC-2024-004123', domein: 'diversen', status: 'actief', product: 'Rechtsbijstand Privé', maatschappijId: 'I-010', premie: 180.00, provisie: 18.00, startdatum: '2024-09-01', einddatum: '2025-09-01', verzekerdeNamen: ['Koen Maes'], objectId: null, createdAt: '2024-09-01' },
  { id: 'C-011', contractnummer: 'VC-2024-004001', domein: 'auto', status: 'actief', product: 'Autoverzekering BA + Mini-Omnium', maatschappijId: 'I-003', premie: 920.00, provisie: 92.00, startdatum: '2024-10-01', einddatum: '2025-10-01', verzekerdeNamen: ['Liesbeth De Smet'], objectId: 'O-V-007', createdAt: '2024-10-01' },
  { id: 'C-012', contractnummer: 'VC-2024-003899', domein: 'brand', status: 'actief', product: 'Woonverzekering', maatschappijId: 'I-002', premie: 780.00, provisie: 78.00, startdatum: '2024-11-01', einddatum: '2025-11-01', verzekerdeNamen: ['Sofie Claes'], objectId: 'O-R-006', createdAt: '2024-11-01' },
  { id: 'C-013', contractnummer: 'VC-2024-004234', domein: 'leven', status: 'actief', product: 'Overlijdensdekking', maatschappijId: 'I-004', premie: 480.00, provisie: 48.00, startdatum: '2024-12-01', einddatum: '2034-12-01', verzekerdeNamen: ['Dirk Verhoeven'], objectId: null, createdAt: '2024-12-01' },
  { id: 'C-014', contractnummer: 'VC-2024-004567', domein: 'auto', status: 'actief', product: 'Vlootverzekering BA', maatschappijId: 'I-001', premie: 3200.00, provisie: 320.00, startdatum: '2024-06-01', einddatum: '2025-06-01', verzekerdeNamen: ['BV AutoVloot Beheer'], objectId: 'O-V-006', createdAt: '2024-06-01' },
  { id: 'C-015', contractnummer: 'VC-2024-004445', domein: 'hospitalisatie', status: 'actief', product: 'Hospitalisatie Top', maatschappijId: 'I-011', premie: 1850.00, provisie: 185.00, startdatum: '2024-08-15', einddatum: '2025-08-15', verzekerdeNamen: ['Marie Dubois'], objectId: null, createdAt: '2024-08-15' },
  { id: 'C-016', contractnummer: 'VC-2024-004111', domein: 'auto', status: 'verlopen', product: 'Autoverzekering BA', maatschappijId: 'I-005', premie: 420.00, provisie: 42.00, startdatum: '2023-01-01', einddatum: '2024-01-01', verzekerdeNamen: ['Bart Vandenberghe'], objectId: 'O-V-008', createdAt: '2023-01-01' },
  { id: 'C-017', contractnummer: 'VC-2024-003778', domein: 'brand', status: 'vervallen', product: 'Woonverzekering Standaard', maatschappijId: 'I-002', premie: 560.00, provisie: 56.00, startdatum: '2022-06-01', einddatum: '2023-06-01', verzekerdeNamen: ['Patrick Jacobs'], objectId: 'O-R-001', createdAt: '2022-06-01' },
  { id: 'C-018', contractnummer: 'VC-2024-004999', domein: 'diversen', status: 'in_behandeling', product: 'Reisverzekering Wereldwijd', maatschappijId: 'I-007', premie: 120.00, provisie: 12.00, startdatum: '2024-12-15', einddatum: '2025-12-15', verzekerdeNamen: ['Emma Wouters'], objectId: null, createdAt: '2024-12-15' },
  { id: 'C-019', contractnummer: 'VC-2024-005123', domein: 'auto', status: 'annulatie', product: 'Autoverzekering Omnium', maatschappijId: 'I-001', premie: 1850.00, provisie: 185.00, startdatum: '2023-05-01', einddatum: '2024-05-01', verzekerdeNamen: ['Inge Martens'], objectId: 'O-V-004', createdAt: '2023-05-01' },
  { id: 'C-020', contractnummer: 'VC-2024-005234', domein: 'leven', status: 'actief', product: 'Groepsverzekering', maatschappijId: 'I-014', premie: 12000.00, provisie: 1200.00, startdatum: '2024-01-01', einddatum: '2029-01-01', verzekerdeNamen: ['NV Technisch Bureau Janssens'], objectId: null, createdAt: '2024-01-01' },
  { id: 'C-021', contractnummer: 'VC-2024-005345', domein: 'hospitalisatie', status: 'actief', product: 'Hospitalisatie Basis', maatschappijId: 'I-011', premie: 890.00, provisie: 89.00, startdatum: '2024-09-01', einddatum: '2025-09-01', verzekerdeNamen: ['Koen Maes'], objectId: null, createdAt: '2024-09-01' },
  { id: 'C-022', contractnummer: 'VC-2024-005456', domein: 'auto', status: 'actief', product: 'Autoverzekering BA + Omnium', maatschappijId: 'I-001', premie: 1680.00, provisie: 168.00, startdatum: '2024-07-01', einddatum: '2025-07-01', verzekerdeNamen: ['Wim Goossens'], objectId: 'O-V-010', createdAt: '2024-07-01' },
  { id: 'C-023', contractnummer: 'VC-2024-005567', domein: 'diversen', status: 'actief', product: 'Burgerlijke Aansprakelijkheid Zakelijk', maatschappijId: 'I-006', premie: 450.00, provisie: 45.00, startdatum: '2024-04-01', einddatum: '2025-04-01', verzekerdeNamen: ['BVBA Constructie Peeters'], objectId: null, createdAt: '2024-04-01' },
];

// ====== Schadeclaims ======
const claims = [
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
  { id: 'CL-013', claimnummer: 'SC-2024-00250', contractnummer: 'VC-2024-004892', status: 'nieuw', categorie: 'Auto (glasbreuk)', beschrijving: 'Glasbreuk zijruit passagier', datumSchade: '2024-12-20', datumMelding: '2024-12-20', bedrag: 340.00, verzekerdeNaam: 'Jan Peeters', urgentie: 'normaal', dagenOpen: 2 },
  { id: 'CL-014', claimnummer: 'SC-2024-00240', contractnummer: 'VC-2024-004105', status: 'afgekeurd', categorie: 'Auto (slijtage)', beschrijving: 'Slijtage motorblok niet gedekt', datumSchade: '2024-08-15', datumMelding: '2024-08-20', bedrag: 4200.00, verzekerdeNaam: 'Marie Dubois', urgentie: 'normaal', dagenOpen: 0 },
  { id: 'CL-015', claimnummer: 'SC-2024-00230', contractnummer: 'VC-2024-005123', status: 'in_behandeling', categorie: 'Auto (aanrijding)', beschrijving: 'T-botsing kruispunt', datumSchade: '2024-11-28', datumMelding: '2024-11-29', bedrag: 11500.00, verzekerdeNaam: 'Wim Goossens', urgentie: 'kritiek', dagenOpen: 25 },
  { id: 'CL-016', claimnummer: 'SC-2024-00220', contractnummer: 'VC-2024-004721', status: 'in_behandeling', categorie: 'Brand (inkoop)', beschrijving: 'Brand in bijgebouw', datumSchade: '2024-12-02', datumMelding: '2024-12-03', bedrag: 18500.00, verzekerdeNaam: 'Pieter Janssens', urgentie: 'hoog', dagenOpen: 20 },
  { id: 'CL-017', claimnummer: 'SC-2024-00210', contractnummer: 'VC-2024-005234', status: 'afgesloten', categorie: 'Arbeidsongeval', beschrijving: 'Vallend object op bouwplaats', datumSchade: '2024-07-12', datumMelding: '2024-07-13', bedrag: 8200.00, verzekerdeNaam: 'BVBA Constructie Peeters', urgentie: 'normaal', dagenOpen: 0 },
  { id: 'CL-018', claimnummer: 'SC-2024-00200', contractnummer: 'VC-2024-003899', status: 'nieuw', categorie: 'Brand (waterlekkage)', beschrijving: 'Waterlekkage kelder', datumSchade: '2024-12-18', datumMelding: '2024-12-19', bedrag: 2100.00, verzekerdeNaam: 'Sofie Claes', urgentie: 'normaal', dagenOpen: 3 },
];

// ====== Dashboard Data ======
const kpiData = {
  actieveContracten: { value: '1.247', trend: 'up', trendValue: '+3,2%', subtitle: 'vs. vorige maand (1.208)' },
  openSchades: { value: '38', trend: 'down', trendValue: '-12%', subtitle: '5 dringend (>30 dagen)' },
  totaalPersonen: { value: '2.856', trend: 'up', trendValue: '+1,8%', subtitle: '2.143 natuurlijk - 713 rechtspersoon' },
  maandOmzet: { value: '\u20ac 42.680', trend: 'up', trendValue: '+8,5%', subtitle: 'vs. \u20ac 39.320 vorige maand' },
  vervallenBinnenkort: { value: '127', trend: 'up', trendValue: '+5', subtitle: 'Contracten vervallen binnen 30 dagen' },
  nieuweDitKwartaal: { value: '312', trend: 'up', trendValue: '+24%', subtitle: 'Nieuwe contracten Q4 2024' },
};

const monthlyChartData = [
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
];

const claimsByCategory = [
  { name: 'Auto (BA/Mini-Omnium/Omnium)', value: 18, color: '#4A804A' },
  { name: 'Brand/Woning', value: 7, color: '#3B6EA5' },
  { name: 'Burgerlijke Aansprakelijkheid', value: 4, color: '#C8A456' },
  { name: 'Rechtsbijstand', value: 5, color: '#8B5E83' },
  { name: 'Andere', value: 4, color: '#C07A4A' },
];

const expiringContracts = [
  { id: 'EC-001', contractnummer: '#VC-2024-004721', verzekerde: 'Pieter Janssens', vervaldatum: '2025-01-02', dagenResterend: 14, status: 'error' },
  { id: 'EC-002', contractnummer: '#VC-2024-004105', verzekerde: 'Marie Dubois', vervaldatum: '2025-01-08', dagenResterend: 20, status: 'warning' },
  { id: 'EC-003', contractnummer: '#VC-2024-003892', verzekerde: 'BVBA De Boer', vervaldatum: '2025-01-15', dagenResterend: 27, status: 'warning' },
  { id: 'EC-004', contractnummer: '#VC-2024-004156', verzekerde: 'Thomas Peeters', vervaldatum: '2025-01-22', dagenResterend: 34, status: 'info' },
  { id: 'EC-005', contractnummer: '#VC-2024-003567', verzekerde: 'Sarah Michiels', vervaldatum: '2025-01-28', dagenResterend: 40, status: 'info' },
];

const openClaimsSummary = [
  { id: 'OS-001', claimnummer: '#SC-2024-00341', verzekerde: 'Jan Peeters', type: 'Auto (aanrijding)', status: 'in_behandeling', dagenOpen: 12, urgent: false },
  { id: 'OS-002', claimnummer: '#SC-2024-00338', verzekerde: 'Anna Vermeiren', type: 'Brand (waterlekkage)', status: 'in_behandeling', dagenOpen: 18, urgent: false },
  { id: 'OS-003', claimnummer: '#SC-2024-00325', verzekerde: 'BVBA De Boer', type: 'Burgerlijke Aansprakelijkheid', status: 'in_afwachting_dossier', dagenOpen: 34, urgent: true },
  { id: 'OS-004', claimnummer: '#SC-2024-00329', verzekerde: 'Lucas Peeters', type: 'Auto (parkeerschade)', status: 'expert_aangesteld', dagenOpen: 8, urgent: false },
  { id: 'OS-005', claimnummer: 'SC-2024-00315', verzekerde: 'Liesbeth De Smet', type: 'Auto (steenschade)', status: 'nieuw', dagenOpen: 4, urgent: false },
  { id: 'OS-006', claimnummer: 'SC-2024-00298', verzekerde: 'Sarah Michiels', type: 'Auto (achteraanrijding)', status: 'in_behandeling', dagenOpen: 27, urgent: true },
];

const recentActivities = [
  { id: 'A-001', type: 'claim_bijgewerkt', gebruiker: 'Marie Dubois', beschrijving: 'heeft schadeclaim #SC-2024-00341 bijgewerkt — status gewijzigd naar \'In behandeling\'', entityRef: '#SC-2024-00341', timestamp: '2024-12-19T14:45:00Z', relativeTime: '3 minuten geleden' },
  { id: 'A-002', type: 'herinnering', gebruiker: 'Systeem', beschrijving: 'heeft herinneringsmail verstuurd voor contract #VC-2024-004721 (vervalt over 14 dagen)', entityRef: '#VC-2024-004721', timestamp: '2024-12-19T14:33:00Z', relativeTime: '15 minuten geleden' },
  { id: 'A-003', type: 'persoon_toegevoegd', gebruiker: 'Pieter Janssens', beschrijving: 'heeft persoon #P-2024-0892 (BVBA De Boer) toegevoegd', entityRef: '#P-2024-0892', timestamp: '2024-12-19T14:16:00Z', relativeTime: '32 minuten geleden' },
  { id: 'A-004', type: 'verlenging', gebruiker: 'Systeem', beschrijving: 'heeft contract #VC-2024-004105 automatisch verlengd', entityRef: '#VC-2024-004105', timestamp: '2024-12-19T13:48:00Z', relativeTime: '1 uur geleden' },
  { id: 'A-005', type: 'commissie', gebruiker: 'Anna Vermeiren', beschrijving: 'heeft commissiebetaling van \u20ac 1.240,00 geboekt', entityRef: null, timestamp: '2024-12-19T12:45:00Z', relativeTime: '2 uur geleden' },
  { id: 'A-006', type: 'object_gekoppeld', gebruiker: 'Lucas Peeters', beschrijving: 'heeft object Mercedes C-Klasse (1-ABC-234) gekoppeld aan contract #VC-2024-004890', entityRef: 'Mercedes C-Klasse (1-ABC-234)', timestamp: '2024-12-19T11:45:00Z', relativeTime: '3 uur geleden' },
  { id: 'A-007', type: 'batch_export', gebruiker: 'Systeem', beschrijving: 'heeft batch export van 45 contracten voltooid', entityRef: null, timestamp: '2024-12-19T09:45:00Z', relativeTime: '5 uur geleden' },
  { id: 'A-008', type: 'contract_aangemaakt', gebruiker: 'Jan Peeters', beschrijving: 'heeft contract #VC-2024-004892 aangemaakt', entityRef: '#VC-2024-004892', timestamp: '2024-12-19T08:30:00Z', relativeTime: '6 uur geleden' },
  { id: 'A-009', type: 'claim_bijgewerkt', gebruiker: 'Marie Dubois', beschrijving: 'heeft schadeclaim #SC-2024-00338 bijgewerkt — expert aangesteld', entityRef: '#SC-2024-00338', timestamp: '2024-12-19T07:15:00Z', relativeTime: '7 uur geleden' },
  { id: 'A-010', type: 'systeem', gebruiker: 'Systeem', beschrijving: 'Automatische backup voltooid — 1.240 records geëxporteerd', entityRef: null, timestamp: '2024-12-19T06:00:00Z', relativeTime: '8 uur geleden' },
];

// ====== Users ======
const users = [
  { id: 'U-001', naam: 'Jan Peeters', email: 'jan.peeters@assuremanager.be', rol: 'beheerder', status: 'actief', laatsteLogin: '2024-12-19T08:30:00Z', createdAt: '2024-01-01' },
  { id: 'U-002', naam: 'Marie Dubois', email: 'marie.dubois@assuremanager.be', rol: 'schadebeheerder', status: 'actief', laatsteLogin: '2024-12-19T14:45:00Z', createdAt: '2024-01-01' },
  { id: 'U-003', naam: 'Pieter Janssens', email: 'pieter.janssens@assuremanager.be', rol: 'commercieel', status: 'actief', laatsteLogin: '2024-12-19T14:16:00Z', createdAt: '2024-01-01' },
  { id: 'U-004', naam: 'Anna Vermeiren', email: 'anna.vermeiren@assuremanager.be', rol: 'financieel', status: 'actief', laatsteLogin: '2024-12-19T12:45:00Z', createdAt: '2024-01-01' },
  { id: 'U-005', naam: 'Lucas Peeters', email: 'lucas.peeters@assuremanager.be', rol: 'commercieel', status: 'actief', laatsteLogin: '2024-12-19T11:45:00Z', createdAt: '2024-02-01' },
  { id: 'U-006', naam: 'Sofie Claes', email: 'sofie.claes@assuremanager.be', rol: 'schadebeheerder', status: 'inactief', laatsteLogin: '2024-11-15T16:20:00Z', createdAt: '2024-03-01' },
  { id: 'U-007', naam: 'System Admin', email: 'admin@assuremanager.be', rol: 'beheerder', status: 'actief', laatsteLogin: '2024-12-19T06:00:00Z', createdAt: '2024-01-01' },
];

// ====== Audit Log ======
const auditLog = [
  { id: 'AL-001', gebruiker: 'Jan Peeters', actie: 'LOGIN', entiteit: 'Gebruiker', entiteitId: 'U-001', detail: 'Gebruiker ingelogd', timestamp: '2024-12-19T08:30:00Z' },
  { id: 'AL-002', gebruiker: 'Marie Dubois', actie: 'UPDATE', entiteit: 'Schadeclaim', entiteitId: 'CL-001', detail: 'Status gewijzigd naar In behandeling', timestamp: '2024-12-19T14:45:00Z' },
  { id: 'AL-003', gebruiker: 'Systeem', actie: 'CREATE', entiteit: 'Contract', entiteitId: 'C-023', detail: 'Contract VC-2024-005567 aangemaakt', timestamp: '2024-12-19T14:30:00Z' },
  { id: 'AL-004', gebruiker: 'Pieter Janssens', actie: 'CREATE', entiteit: 'Persoon', entiteitId: 'P-2024-0025', detail: 'Nieuwe prospect Els Van den Broeck toegevoegd', timestamp: '2024-12-19T14:16:00Z' },
  { id: 'AL-005', gebruiker: 'Systeem', actie: 'UPDATE', entiteit: 'Contract', entiteitId: 'C-003', detail: 'Contract VC-2024-004105 automatisch verlengd', timestamp: '2024-12-19T13:48:00Z' },
  { id: 'AL-006', gebruiker: 'Anna Vermeiren', actie: 'CREATE', entiteit: 'Boeking', entiteitId: 'B-1240', detail: 'Commissiebetaling \u20ac 1.240,00 geboekt', timestamp: '2024-12-19T12:45:00Z' },
  { id: 'AL-007', gebruiker: 'Lucas Peeters', actie: 'UPDATE', entiteit: 'Contract', entiteitId: 'C-007', detail: 'Object O-V-001 gekoppeld aan contract', timestamp: '2024-12-19T11:45:00Z' },
  { id: 'AL-008', gebruiker: 'Systeem', actie: 'EXPORT', entiteit: 'Contract', entiteitId: null, detail: 'Batch export van 45 contracten voltooid', timestamp: '2024-12-19T09:45:00Z' },
  { id: 'AL-009', gebruiker: 'Jan Peeters', actie: 'CREATE', entiteit: 'Contract', entiteitId: 'C-022', detail: 'Contract VC-2024-005456 aangemaakt', timestamp: '2024-12-19T08:30:00Z' },
  { id: 'AL-010', gebruiker: 'Systeem', actie: 'BACKUP', entiteit: 'Systeem', entiteitId: null, detail: 'Automatische backup voltooid - 1.240 records', timestamp: '2024-12-19T06:00:00Z' },
  { id: 'AL-011', gebruiker: 'Marie Dubois', actie: 'UPDATE', entiteit: 'Schadeclaim', entiteitId: 'CL-002', detail: 'Expert aangesteld voor claim SC-2024-00338', timestamp: '2024-12-19T07:15:00Z' },
  { id: 'AL-012', gebruiker: 'Systeem', actie: 'HERINNERING', entiteit: 'Contract', entiteitId: 'C-002', detail: 'Herinneringsmail verstuurd voor contract VC-2024-004721', timestamp: '2024-12-19T05:00:00Z' },
  { id: 'AL-013', gebruiker: 'Jan Peeters', actie: 'DELETE', entiteit: 'Persoon', entiteitId: 'P-2024-0014', detail: 'Persoon Bart Vandenberghe verwijderd (inactief)', timestamp: '2024-12-18T16:30:00Z' },
  { id: 'AL-014', gebruiker: 'Pieter Janssens', actie: 'CREATE', entiteit: 'Schadeclaim', entiteitId: 'CL-018', detail: 'Nieuwe claim SC-2024-00200 aangemaakt', timestamp: '2024-12-18T14:20:00Z' },
  { id: 'AL-015', gebruiker: 'Anna Vermeiren', actie: 'UPDATE', entiteit: 'Instelling', entiteitId: 'I-011', detail: 'DKV Belgium contactgegevens bijgewerkt', timestamp: '2024-12-18T11:10:00Z' },
];

// ====== Settings ======
const settings = {
  bedrijf: {
    naam: 'AssureManager BV',
    adres: 'Verzekeringslaan 1',
    postcode: '2800',
    gemeente: 'Mechelen',
    telefoon: '+32 15 12 34 56',
    email: 'info@assuremanager.be',
    kbo: '0123.456.789',
    btw: 'BE 0123.456.789',
  },
  systeem: {
    taal: 'nl-BE',
    tijdzone: 'Europe/Brussels',
    datumformaat: 'DD/MM/YYYY',
    valuta: 'EUR',
    autoBackup: true,
    backupUur: '02:00',
    sessieTimeout: 30,
  },
  notificaties: {
    emailHerinneringContract: true,
    dagenVoorVervaldatum: 30,
    emailNieuweClaim: true,
    emailCommissie: true,
    pushNotificaties: true,
  },
  rapporten: {
    standaardPeriode: 'huidig_jaar',
    commissiePercentage: 10,
    valutaSymbol: '\u20ac',
    decimaleScheiding: ',',
    duizendScheiding: '.',
  },
};

// Helper functions for filtering and pagination
function paginate(array, page, limit) {
  const pageNum = Math.max(1, parseInt(page) || 1);
  const limitNum = Math.max(1, parseInt(limit) || 20);
  const start = (pageNum - 1) * limitNum;
  return {
    data: array.slice(start, start + limitNum),
    pagination: {
      page: pageNum,
      limit: limitNum,
      total: array.length,
      totalPages: Math.max(1, Math.ceil(array.length / limitNum)),
    }
  };
}

function filterBySearch(array, search, fields) {
  if (!search) return array;
  const s = search.toLowerCase();
  return array.filter(item => fields.some(f => String(item[f] || '').toLowerCase().includes(s)));
}

module.exports = {
  persons,
  institutions,
  vehicles,
  realEstates,
  loans,
  things,
  activities,
  allObjects,
  contracts,
  claims,
  kpiData,
  monthlyChartData,
  claimsByCategory,
  expiringContracts,
  openClaimsSummary,
  recentActivities,
  users,
  auditLog,
  settings,
  paginate,
  filterBySearch,
};
