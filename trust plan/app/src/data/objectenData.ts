// ====== Types ======

export interface Voertuig {
  id: string
  merk: string
  model: string
  type: 'Personenauto' | 'Bestelwagen' | 'Motorfiets' | 'Aanhangwagen' | 'Camper' | 'Oldtimer'
  subtype: string
  bouwjaar: number
  chassisnummer: string
  kenteken: string
  brandstof: 'Benzine' | 'Diesel' | 'Hybride' | 'Elektrisch'
  kmStand: number
  transmissie: 'Automaat' | 'Manueel'
  kleur: string
  vermogenPk: number
  vermogenKw: number
  cilinderinhoud: number
  aantalDeuren: number
  zitplaatsen: number
  co2Uitstoot: number
  euroNorm: string
  gewicht: number
  aandrijving: 'Voorwiel' | 'Achterwiel' | '4x4'
  kentekenType: string
  apkVervaldatum: string
  eersteInschrijving: string
  financiering: 'Kas' | 'Lening' | 'Leasing'
  aankoopprijs: number
  huidigeWaarde: number
  eigenaar: string
  contractRef?: string
}

export interface OnroerendGoed {
  id: string
  type: 'Appartement' | 'Eengezinswoning' | 'Villa' | 'Bureel' | 'Handelspand' | 'Industrieel' | 'Garagebox' | 'Grond'
  adres: string
  stad: string
  postcode: string
  bouwjaar: number
  gebruikstype: 'Eigen woonst' | 'Verhuur' | 'Beroepsmatig' | 'Gemengd'
  verzekerdeRol: string
  oppervlakte: number
  aantalVerdiepingen: number
  constructieType: string
  dakType: string
  nabijheid: 'Open bebouwing' | 'Halfopen bebouwing' | 'Gesloten bebouwing' | 'Rijwoning'
  bezettingsgraad: string
  capitalen: number
  kadasterNummer: string
  brandblusser: boolean
  alarmSysteem: boolean
  rolluiken: boolean
  eigenaar: string
  contractRef?: string
}

export interface Lening {
  id: string
  type: 'Hypothecaire lening' | 'Lening op afbetaling' | 'Kredietlijn' | 'Werkingskrediet' | 'Leasing'
  hoofdsom: number
  rentevoet: number
  periodiciteit: 'Maandelijks' | 'Trimestrieel' | 'Jaarlijks'
  looptijd: number
  looptijdType: 'Jaar' | 'Maand'
  startdatum: string
  einddatum: string
  bank: string
  restKapitaal: number
  status: 'Actief' | 'Afgelost' | 'Vervallen'
  begunstigde: string
  contractRef?: string
}

export interface Zaak {
  id: string
  subtype: 'Elektronica' | 'Kunst' | 'Edelstenen' | 'Meubilair' | 'Werktuigen' | 'Overig'
  merk: string
  model: string
  beschrijving: string
  serienummer: string
  verzekerdeWaarde: number
  nieuwwaarde: number
  huidigeWaarde: number
  materiaaltype: string
  risicocategorie: 'Laag' | 'Middel' | 'Hoog'
  eigenaar: string
  contractRef?: string
}

export interface Activiteit {
  id: string
  type: 'Evenement' | 'Wielerwedstrijd' | 'Concert' | 'Festival' | 'Sportevent' | 'Beurs' | 'Catering'
  beschrijving: string
  startdatum: string
  einddatum: string
  startTijd: string
  eindTijd: string
  locatie: string
  deelnemers: number
  leeftijdscategorie: string
  risiconiveau: 'Laag' | 'Middel' | 'Hoog'
  organisator: string
  contractRef?: string
}

export interface PersoonArbeidsongeval {
  id: string
  subtype: 'Werknemer' | 'Zaakvoerder' | 'Statutair' | 'Gedetacheerd' | 'Student'
  beschrijving: string
  aantalPersonen: number
  risicoklasse: 'Klasse 1' | 'Klasse 2' | 'Klasse 3' | 'Klasse 4'
  naceCode: string
  leeftijdscategorie: string
  geslacht: 'M' | 'V' | 'X'
  startdatum: string
  contractRef?: string
}

// ====== Mock Data: Voertuigen (15+) ======

export const voertuigenData: Voertuig[] = [
  {
    id: 'V-2024-0001', merk: 'Mercedes-Benz', model: 'C-Klasse Break d', type: 'Personenauto', subtype: 'Break',
    bouwjaar: 2022, chassisnummer: 'WDD2052012F123456', kenteken: '1-ABC-234',
    brandstof: 'Diesel', kmStand: 45200, transmissie: 'Automaat', kleur: 'Zwart metallic',
    vermogenPk: 150, vermogenKw: 110, cilinderinhoud: 1950, aantalDeuren: 5, zitplaatsen: 5,
    co2Uitstoot: 128, euroNorm: 'Euro 6d', gewicht: 1580, aandrijving: 'Achterwiel',
    kentekenType: 'Personenwagen', apkVervaldatum: '15/03/2026', eersteInschrijving: '15/03/2022',
    financiering: 'Lening', aankoopprijs: 42500, huidigeWaarde: 32800,
    eigenaar: 'Peeters, Jan', contractRef: '#VC-2024-004892',
  },
  {
    id: 'V-2024-0002', merk: 'BMW', model: '320d Touring', type: 'Personenauto', subtype: 'Touring',
    bouwjaar: 2021, chassisnummer: 'WBA8E1C50JK123456', kenteken: '1-DEF-567',
    brandstof: 'Diesel', kmStand: 67800, transmissie: 'Automaat', kleur: 'Alpinweiss',
    vermogenPk: 190, vermogenKw: 140, cilinderinhoud: 1995, aantalDeuren: 5, zitplaatsen: 5,
    co2Uitstoot: 135, euroNorm: 'Euro 6d', gewicht: 1620, aandrijving: 'Achterwiel',
    kentekenType: 'Personenwagen', apkVervaldatum: '22/07/2025', eersteInschrijving: '22/07/2021',
    financiering: 'Leasing', aankoopprijs: 38900, huidigeWaarde: 28500,
    eigenaar: 'Dubois, Marie', contractRef: '#VC-2024-004905',
  },
  {
    id: 'V-2024-0003', merk: 'Volkswagen', model: 'Golf VIII 1.5 TSI', type: 'Personenauto', subtype: 'Hatchback',
    bouwjaar: 2023, chassisnummer: 'WVWZZZCDZNW123456', kenteken: '1-GHI-890',
    brandstof: 'Benzine', kmStand: 23100, transmissie: 'Automaat', kleur: 'Atlantikblauw',
    vermogenPk: 150, vermogenKw: 110, cilinderinhoud: 1498, aantalDeuren: 5, zitplaatsen: 5,
    co2Uitstoot: 142, euroNorm: 'Euro 6d', gewicht: 1340, aandrijving: 'Voorwiel',
    kentekenType: 'Personenwagen', apkVervaldatum: '10/01/2026', eersteInschrijving: '10/01/2023',
    financiering: 'Kas', aankoopprijs: 28900, huidigeWaarde: 24200,
    eigenaar: 'Janssens, Pieter', contractRef: '#VC-2024-004821',
  },
  {
    id: 'V-2024-0004', merk: 'Peugeot', model: '208 Allure 1.2 PureTech', type: 'Personenauto', subtype: 'Hatchback',
    bouwjaar: 2023, chassisnummer: 'VF3CCHNPXKT123456', kenteken: '2-JKL-123',
    brandstof: 'Benzine', kmStand: 18900, transmissie: 'Manueel', kleur: 'Elixir Rood',
    vermogenPk: 100, vermogenKw: 74, cilinderinhoud: 1199, aantalDeuren: 5, zitplaatsen: 5,
    co2Uitstoot: 120, euroNorm: 'Euro 6d', gewicht: 1090, aandrijving: 'Voorwiel',
    kentekenType: 'Personenwagen', apkVervaldatum: '05/04/2026', eersteInschrijving: '05/04/2023',
    financiering: 'Lening', aankoopprijs: 22500, huidigeWaarde: 19800,
    eigenaar: 'Vermeiren, Anna', contractRef: '#VC-2024-004789',
  },
  {
    id: 'V-2024-0005', merk: 'Audi', model: 'A4 Avant 35 TDI', type: 'Personenauto', subtype: 'Avant',
    bouwjaar: 2022, chassisnummer: 'WAUZZZF44NN123456', kenteken: '1-MNO-456',
    brandstof: 'Diesel', kmStand: 54300, transmissie: 'Automaat', kleur: 'Mythoszwart',
    vermogenPk: 163, vermogenKw: 120, cilinderinhoud: 1968, aantalDeuren: 5, zitplaatsen: 5,
    co2Uitstoot: 130, euroNorm: 'Euro 6d', gewicht: 1600, aandrijving: 'Voorwiel',
    kentekenType: 'Personenwagen', apkVervaldatum: '18/09/2025', eersteInschrijving: '18/09/2022',
    financiering: 'Leasing', aankoopprijs: 39500, huidigeWaarde: 29800,
    eigenaar: 'Peeters, Hilde', contractRef: '#VC-2024-004712',
  },
  {
    id: 'V-2024-0006', merk: 'Yamaha', model: 'MT-07', type: 'Motorfiets', subtype: 'Naked',
    bouwjaar: 2021, chassisnummer: 'JYADJ2310KA123456', kenteken: 'M-ABC-12',
    brandstof: 'Benzine', kmStand: 12400, transmissie: 'Manueel', kleur: 'Tech Black',
    vermogenPk: 75, vermogenKw: 55, cilinderinhoud: 689, aantalDeuren: 0, zitplaatsen: 2,
    co2Uitstoot: 85, euroNorm: 'Euro 5', gewicht: 184, aandrijving: 'Achterwiel',
    kentekenType: 'Motorfiets', apkVervaldatum: '30/06/2025', eersteInschrijving: '30/06/2021',
    financiering: 'Kas', aankoopprijs: 7499, huidigeWaarde: 5800,
    eigenaar: 'De Boer BVBA', contractRef: '#VC-2024-004698',
  },
  {
    id: 'V-2024-0007', merk: 'BMW', model: 'R 1250 GS', type: 'Motorfiets', subtype: 'Adventure',
    bouwjaar: 2022, chassisnummer: 'WB10C0108M6Z12345', kenteken: 'M-DEF-34',
    brandstof: 'Benzine', kmStand: 8500, transmissie: 'Manueel', kleur: 'Rallye Blauw',
    vermogenPk: 136, vermogenKw: 100, cilinderinhoud: 1254, aantalDeuren: 0, zitplaatsen: 2,
    co2Uitstoot: 92, euroNorm: 'Euro 5', gewicht: 249, aandrijving: 'Achterwiel',
    kentekenType: 'Motorfiets', apkVervaldatum: '14/11/2025', eersteInschrijving: '14/11/2022',
    financiering: 'Lening', aankoopprijs: 18500, huidigeWaarde: 14200,
    eigenaar: 'Lucas Peeters', contractRef: '#VC-2024-004654',
  },
  {
    id: 'V-2024-0008', merk: 'Hapert', model: 'Azure L-1', type: 'Aanhangwagen', subtype: 'Aanhangwagen',
    bouwjaar: 2020, chassisnummer: 'YE2AP1210H1234567', kenteken: 'A-GHI-56',
    brandstof: 'Benzine', kmStand: 0, transmissie: 'Manueel', kleur: 'Verzinkt',
    vermogenPk: 0, vermogenKw: 0, cilinderinhoud: 0, aantalDeuren: 0, zitplaatsen: 0,
    co2Uitstoot: 0, euroNorm: '-', gewicht: 350, aandrijving: 'Voorwiel',
    kentekenType: 'Aanhangwagen', apkVervaldatum: '20/08/2025', eersteInschrijving: '20/08/2020',
    financiering: 'Kas', aankoopprijs: 3200, huidigeWaarde: 2400,
    eigenaar: 'Janssens, Pieter',
  },
  {
    id: 'V-2024-0009', merk: 'Volvo', model: 'XC60 B4', type: 'Personenauto', subtype: 'SUV',
    bouwjaar: 2023, chassisnummer: 'YV1UZKRL1N1234567', kenteken: '1-PQR-789',
    brandstof: 'Hybride', kmStand: 31200, transmissie: 'Automaat', kleur: 'Denim Blue',
    vermogenPk: 197, vermogenKw: 145, cilinderinhoud: 1969, aantalDeuren: 5, zitplaatsen: 5,
    co2Uitstoot: 55, euroNorm: 'Euro 6d', gewicht: 1820, aandrijving: '4x4',
    kentekenType: 'Personenwagen', apkVervaldatum: '02/05/2026', eersteInschrijving: '02/05/2023',
    financiering: 'Leasing', aankoopprijs: 52000, huidigeWaarde: 41500,
    eigenaar: 'BVBA De Boer', contractRef: '#VC-2024-004601',
  },
  {
    id: 'V-2024-0010', merk: 'Toyota', model: 'Corolla TS 1.8 Hybrid', type: 'Personenauto', subtype: 'Touring Sports',
    bouwjaar: 2023, chassisnummer: 'JTDKAMFU0N3123456', kenteken: '2-STU-012',
    brandstof: 'Hybride', kmStand: 27400, transmissie: 'Automaat', kleur: 'Bi-tone Zwart',
    vermogenPk: 122, vermogenKw: 90, cilinderinhoud: 1798, aantalDeuren: 5, zitplaatsen: 5,
    co2Uitstoot: 102, euroNorm: 'Euro 6d', gewicht: 1380, aandrijving: 'Voorwiel',
    kentekenType: 'Personenwagen', apkVervaldatum: '19/07/2026', eersteInschrijving: '19/07/2023',
    financiering: 'Lening', aankoopprijs: 31500, huidigeWaarde: 26800,
    eigenaar: 'Michiels, Sarah', contractRef: '#VC-2024-004589',
  },
  {
    id: 'V-2024-0011', merk: 'Renault', model: 'Clio V 1.0 TCe', type: 'Personenauto', subtype: 'Hatchback',
    bouwjaar: 2021, chassisnummer: 'VF1RJA00512345678', kenteken: '1-VWX-345',
    brandstof: 'Benzine', kmStand: 45600, transmissie: 'Manueel', kleur: 'Orange Valencia',
    vermogenPk: 90, vermogenKw: 67, cilinderinhoud: 999, aantalDeuren: 5, zitplaatsen: 5,
    co2Uitstoot: 118, euroNorm: 'Euro 6d', gewicht: 1050, aandrijving: 'Voorwiel',
    kentekenType: 'Personenwagen', apkVervaldatum: '08/12/2025', eersteInschrijving: '08/12/2021',
    financiering: 'Kas', aankoopprijs: 16800, huidigeWaarde: 11200,
    eigenaar: 'Maes, Koen', contractRef: '#VC-2024-004521',
  },
  {
    id: 'V-2024-0012', merk: 'Mercedes-Benz', model: 'Sprinter 316 CDI', type: 'Bestelwagen', subtype: 'Bestelwagen',
    bouwjaar: 2020, chassisnummer: 'WDB9061312K123456', kenteken: '1-YZA-678',
    brandstof: 'Diesel', kmStand: 89100, transmissie: 'Automaat', kleur: 'Zwart',
    vermogenPk: 163, vermogenKw: 120, cilinderinhoud: 2143, aantalDeuren: 4, zitplaatsen: 3,
    co2Uitstoot: 185, euroNorm: 'Euro 6', gewicht: 2600, aandrijving: 'Voorwiel',
    kentekenType: 'Bestelwagen', apkVervaldatum: '25/04/2025', eersteInschrijving: '25/04/2020',
    financiering: 'Leasing', aankoopprijs: 48500, huidigeWaarde: 32500,
    eigenaar: 'NV Verzekerd Goed', contractRef: '#VC-2024-004487',
  },
  {
    id: 'V-2024-0013', merk: 'Porsche', model: '911 Carrera S', type: 'Personenauto', subtype: 'Coupe',
    bouwjaar: 2022, chassisnummer: 'WP0ZZZ99ZNS123456', kenteken: '2-BCD-901',
    brandstof: 'Benzine', kmStand: 8200, transmissie: 'Automaat', kleur: 'Guards Red',
    vermogenPk: 450, vermogenKw: 331, cilinderinhoud: 2981, aantalDeuren: 2, zitplaatsen: 4,
    co2Uitstoot: 210, euroNorm: 'Euro 6d', gewicht: 1450, aandrijving: 'Achterwiel',
    kentekenType: 'Personenwagen', apkVervaldatum: '03/10/2025', eersteInschrijving: '03/10/2022',
    financiering: 'Kas', aankoopprijs: 125000, huidigeWaarde: 98000,
    eigenaar: 'Peeters, Hilde', contractRef: '#VC-2024-004312',
  },
  {
    id: 'V-2024-0014', merk: 'Hyundai', model: 'Kona Electric', type: 'Personenauto', subtype: 'SUV',
    bouwjaar: 2023, chassisnummer: 'TMAJ3813AKJ123456', kenteken: '1-EFG-234',
    brandstof: 'Elektrisch', kmStand: 15600, transmissie: 'Automaat', kleur: 'Cyber Gray',
    vermogenPk: 204, vermogenKw: 150, cilinderinhoud: 0, aantalDeuren: 5, zitplaatsen: 5,
    co2Uitstoot: 0, euroNorm: '-', gewicht: 1680, aandrijving: 'Voorwiel',
    kentekenType: 'Personenwagen', apkVervaldatum: '11/02/2026', eersteInschrijving: '11/02/2023',
    financiering: 'Lening', aankoopprijs: 38900, huidigeWaarde: 31200,
    eigenaar: 'Wouters, Emma', contractRef: '#VC-2024-004278',
  },
  {
    id: 'V-2024-0015', merk: 'Tesla', model: 'Model 3 Long Range', type: 'Personenauto', subtype: 'Sedan',
    bouwjaar: 2024, chassisnummer: 'LRW3E7ET9NC123456', kenteken: '2-HIJ-567',
    brandstof: 'Elektrisch', kmStand: 4200, transmissie: 'Automaat', kleur: 'Pearl White',
    vermogenPk: 450, vermogenKw: 331, cilinderinhoud: 0, aantalDeuren: 4, zitplaatsen: 5,
    co2Uitstoot: 0, euroNorm: '-', gewicht: 1845, aandrijving: '4x4',
    kentekenType: 'Personenwagen', apkVervaldatum: '28/06/2026', eersteInschrijving: '28/06/2024',
    financiering: 'Leasing', aankoopprijs: 54800, huidigeWaarde: 49800,
    eigenaar: 'NV Verzekerd Goed', contractRef: '#VC-2024-004156',
  },
  {
    id: 'V-2024-0016', merk: 'Citroën', model: '2CV6', type: 'Oldtimer', subtype: 'Oldtimer',
    bouwjaar: 1987, chassisnummer: 'VF7AZKA00KA123456', kenteken: 'O-ABC-45',
    brandstof: 'Benzine', kmStand: 120500, transmissie: 'Manueel', kleur: 'Vert Delos',
    vermogenPk: 29, vermogenKw: 21, cilinderinhoud: 602, aantalDeuren: 4, zitplaatsen: 4,
    co2Uitstoot: 0, euroNorm: '-', gewicht: 560, aandrijving: 'Voorwiel',
    kentekenType: 'Oldtimer', apkVervaldatum: '01/01/2026', eersteInschrijving: '01/04/1987',
    financiering: 'Kas', aankoopprijs: 8500, huidigeWaarde: 12000,
    eigenaar: 'Peeters, Jan',
  },
]

// ====== Mock Data: Onroerende Goederen (10+) ======

export const onroerendGoedData: OnroerendGoed[] = [
  {
    id: 'O-2024-0001', type: 'Eengezinswoning', adres: 'Kerkstraat 12', stad: 'Mechelen', postcode: '2800',
    bouwjaar: 1985, gebruikstype: 'Eigen woonst', verzekerdeRol: 'Eigenaar-bewoner',
    oppervlakte: 185, aantalVerdiepingen: 2, constructieType: 'Baksteen', dakType: 'Zadeldak',
    nabijheid: 'Halfopen bebouwing', bezettingsgraad: 'Bewoond', capitalen: 485000,
    kadasterNummer: 'MECH-1234-56', brandblusser: true, alarmSysteem: true, rolluiken: false,
    eigenaar: 'Peeters, Jan', contractRef: '#VC-2024-004892',
  },
  {
    id: 'O-2024-0002', type: 'Appartement', adres: 'Rue du Marché 45/3', stad: 'Brussel', postcode: '1000',
    bouwjaar: 2005, gebruikstype: 'Eigen woonst', verzekerdeRol: 'Eigenaar-bewoner',
    oppervlakte: 92, aantalVerdiepingen: 1, constructieType: 'Beton', dakType: 'Plat dak',
    nabijheid: 'Gesloten bebouwing', bezettingsgraad: 'Bewoond', capitalen: 320000,
    kadasterNummer: 'BRUX-5678-90', brandblusser: true, alarmSysteem: true, rolluiken: true,
    eigenaar: 'Dubois, Marie', contractRef: '#VC-2024-004905',
  },
  {
    id: 'O-2024-0003', type: 'Eengezinswoning', adres: 'Dorpstraat 8', stad: 'Gent', postcode: '9000',
    bouwjaar: 1998, gebruikstype: 'Eigen woonst', verzekerdeRol: 'Eigenaar-bewoner',
    oppervlakte: 210, aantalVerdiepingen: 2, constructieType: 'Baksteen', dakType: 'Mansardedak',
    nabijheid: 'Open bebouwing', bezettingsgraad: 'Bewoond', capitalen: 525000,
    kadasterNummer: 'GENT-3456-78', brandblusser: true, alarmSysteem: false, rolluiken: true,
    eigenaar: 'Janssens, Pieter', contractRef: '#VC-2024-004821',
  },
  {
    id: 'O-2024-0004', type: 'Garagebox', adres: 'Stationsplein 3B', stad: 'Hasselt', postcode: '3500',
    bouwjaar: 2010, gebruikstype: 'Eigen woonst', verzekerdeRol: 'Eigenaar-bewoner',
    oppervlakte: 18, aantalVerdiepingen: 1, constructieType: 'Beton', dakType: 'Plat dak',
    nabijheid: 'Gesloten bebouwing', bezettingsgraad: 'Garage', capitalen: 35000,
    kadasterNummer: 'HASL-9012-34', brandblusser: false, alarmSysteem: true, rolluiken: true,
    eigenaar: 'Vermeiren, Anna',
  },
  {
    id: 'O-2024-0005', type: 'Bureel', adres: 'Industrielaan 45', stad: 'Mechelen', postcode: '2800',
    bouwjaar: 2015, gebruikstype: 'Beroepsmatig', verzekerdeRol: 'Huurder',
    oppervlakte: 450, aantalVerdiepingen: 1, constructieType: 'Staal/Beton', dakType: 'Plat dak',
    nabijheid: 'Open bebouwing', bezettingsgraad: 'Actief', capitalen: 890000,
    kadasterNummer: 'MECH-7890-12', brandblusser: true, alarmSysteem: true, rolluiken: true,
    eigenaar: 'BVBA De Boer', contractRef: '#VC-2024-004601',
  },
  {
    id: 'O-2024-0006', type: 'Villa', adres: 'Kasteeldreef 7', stad: 'Knokke-Heist', postcode: '8300',
    bouwjaar: 2008, gebruikstype: 'Eigen woonst', verzekerdeRol: 'Eigenaar-bewoner',
    oppervlakte: 340, aantalVerdiepingen: 3, constructieType: 'Baksteen', dakType: 'Zadeldak',
    nabijheid: 'Open bebouwing', bezettingsgraad: 'Bewoond', capitalen: 1250000,
    kadasterNummer: 'KNOK-1111-22', brandblusser: true, alarmSysteem: true, rolluiken: true,
    eigenaar: 'Peeters, Hilde', contractRef: '#VC-2024-004312',
  },
  {
    id: 'O-2024-0007', type: 'Handelspand', adres: 'Stationsstraat 23', stad: 'Leuven', postcode: '3000',
    bouwjaar: 1995, gebruikstype: 'Beroepsmatig', verzekerdeRol: 'Eigenaar-verhuurder',
    oppervlakte: 220, aantalVerdiepingen: 2, constructieType: 'Baksteen', dakType: 'Zadeldak',
    nabijheid: 'Halfopen bebouwing', bezettingsgraad: 'Verhuurd', capitalen: 675000,
    kadasterNummer: 'LEUV-3333-44', brandblusser: true, alarmSysteem: true, rolluiken: true,
    eigenaar: 'De Boer BVBA', contractRef: '#VC-2024-004487',
  },
  {
    id: 'O-2024-0008', type: 'Appartement', adres: 'Nieuwpoortlaan 88/4', stad: 'Nieuwpoort', postcode: '8620',
    bouwjaar: 2018, gebruikstype: 'Verhuur', verzekerdeRol: 'Eigenaar-verhuurder',
    oppervlakte: 68, aantalVerdiepingen: 1, constructieType: 'Beton', dakType: 'Plat dak',
    nabijheid: 'Gesloten bebouwing', bezettingsgraad: 'Verhuurd', capitalen: 245000,
    kadasterNummer: 'NIEU-5555-66', brandblusser: true, alarmSysteem: false, rolluiken: false,
    eigenaar: 'Michiels, Sarah', contractRef: '#VC-2024-004589',
  },
  {
    id: 'O-2024-0009', type: 'Industrieel', adres: 'Zonevaart 12', stad: 'Antwerpen', postcode: '2030',
    bouwjaar: 2002, gebruikstype: 'Beroepsmatig', verzekerdeRol: 'Huurder',
    oppervlakte: 2800, aantalVerdiepingen: 1, constructieType: 'Staal', dakType: 'Plat dak',
    nabijheid: 'Open bebouwing', bezettingsgraad: 'Actief', capitalen: 2100000,
    kadasterNummer: 'ANTW-7777-88', brandblusser: true, alarmSysteem: true, rolluiken: false,
    eigenaar: 'NV Verzekerd Goed', contractRef: '#VC-2024-004156',
  },
  {
    id: 'O-2024-0010', type: 'Grond', adres: 'Bosdreef 1', stad: 'Genk', postcode: '3600',
    bouwjaar: 0, gebruikstype: 'Eigen woonst', verzekerdeRol: 'Eigenaar',
    oppervlakte: 1200, aantalVerdiepingen: 0, constructieType: '-', dakType: '-',
    nabijheid: 'Open bebouwing', bezettingsgraad: 'Onbebouwd', capitalen: 180000,
    kadasterNummer: 'GENK-9999-00', brandblusser: false, alarmSysteem: false, rolluiken: false,
    eigenaar: 'Maes, Koen',
  },
]

// ====== Mock Data: Leningen (8+) ======

export const leningenData: Lening[] = [
  {
    id: 'L-2024-0001', type: 'Hypothecaire lening', hoofdsom: 285000, rentevoet: 3.25,
    periodiciteit: 'Maandelijks', looptijd: 20, looptijdType: 'Jaar',
    startdatum: '15/03/2020', einddatum: '15/03/2040', bank: 'KBC',
    restKapitaal: 198450, status: 'Actief', begunstigde: 'Peeters, Jan',
    contractRef: '#VC-2024-004892',
  },
  {
    id: 'L-2024-0002', type: 'Lening op afbetaling', hoofdsom: 35000, rentevoet: 4.50,
    periodiciteit: 'Maandelijks', looptijd: 5, looptijdType: 'Jaar',
    startdatum: '01/06/2022', einddatum: '01/06/2027', bank: 'ING',
    restKapitaal: 12800, status: 'Actief', begunstigde: 'Dubois, Marie',
    contractRef: '#VC-2024-004905',
  },
  {
    id: 'L-2024-0003', type: 'Hypothecaire lening', hoofdsom: 420000, rentevoet: 2.85,
    periodiciteit: 'Maandelijks', looptijd: 25, looptijdType: 'Jaar',
    startdatum: '10/09/2019', einddatum: '10/09/2044', bank: 'BNP Paribas',
    restKapitaal: 356200, status: 'Actief', begunstigde: 'BVBA De Boer',
    contractRef: '#VC-2024-004601',
  },
  {
    id: 'L-2024-0004', type: 'Leasing', hoofdsom: 28500, rentevoet: 3.90,
    periodiciteit: 'Maandelijks', looptijd: 4, looptijdType: 'Jaar',
    startdatum: '22/07/2021', einddatum: '22/07/2025', bank: 'KBC',
    restKapitaal: 14200, status: 'Actief', begunstigde: 'Janssens, Pieter',
    contractRef: '#VC-2024-004821',
  },
  {
    id: 'L-2024-0005', type: 'Kredietlijn', hoofdsom: 100000, rentevoet: 2.15,
    periodiciteit: 'Trimestrieel', looptijd: 10, looptijdType: 'Jaar',
    startdatum: '05/01/2021', einddatum: '05/01/2031', bank: 'ING',
    restKapitaal: 67500, status: 'Actief', begunstigde: 'BVBA De Boer',
    contractRef: '#VC-2024-004487',
  },
  {
    id: 'L-2024-0006', type: 'Werkingskrediet', hoofdsom: 250000, rentevoet: 3.45,
    periodiciteit: 'Trimestrieel', looptijd: 7, looptijdType: 'Jaar',
    startdatum: '18/04/2023', einddatum: '18/04/2030', bank: 'Belfius',
    restKapitaal: 198700, status: 'Actief', begunstigde: 'NV Verzekerd Goed',
    contractRef: '#VC-2024-004156',
  },
  {
    id: 'L-2024-0007', type: 'Hypothecaire lening', hoofdsom: 175000, rentevoet: 1.85,
    periodiciteit: 'Maandelijks', looptijd: 15, looptijdType: 'Jaar',
    startdatum: '01/10/2021', einddatum: '01/10/2036', bank: 'Argenta',
    restKapitaal: 142300, status: 'Actief', begunstigde: 'Vermeiren, Anna',
    contractRef: '#VC-2024-004789',
  },
  {
    id: 'L-2024-0008', type: 'Lening op afbetaling', hoofdsom: 50000, rentevoet: 3.75,
    periodiciteit: 'Maandelijks', looptijd: 7, looptijdType: 'Jaar',
    startdatum: '12/11/2022', einddatum: '12/11/2029', bank: 'Crelan',
    restKapitaal: 32100, status: 'Actief', begunstigde: 'Peeters, Hilde',
    contractRef: '#VC-2024-004712',
  },
]

// ====== Mock Data: Zaken (10+) ======

export const zakenData: Zaak[] = [
  {
    id: 'Z-2024-0001', subtype: 'Elektronica', merk: 'Apple', model: 'MacBook Pro 16" M3 Max',
    beschrijving: 'Laptop voor professioneel gebruik', serienummer: 'FVFKJ1234567',
    verzekerdeWaarde: 4200, nieuwwaarde: 4499, huidigeWaarde: 3800,
    materiaaltype: 'Aluminium', risicocategorie: 'Middel', eigenaar: 'De Boer BVBA',
    contractRef: '#VC-2024-004698',
  },
  {
    id: 'Z-2024-0002', subtype: 'Kunst', merk: 'René Magritte', model: 'Zonder Titel (1962)',
    beschrijving: 'Origineel olieverf op doek — privécollectie', serienummer: 'RM-1962-0045',
    verzekerdeWaarde: 185000, nieuwwaarde: 220000, huidigeWaarde: 195000,
    materiaaltype: 'Olieverf/Doek', risicocategorie: 'Hoog', eigenaar: 'Peeters, Hilde',
    contractRef: '#VC-2024-004312',
  },
  {
    id: 'Z-2024-0003', subtype: 'Edelstenen', merk: 'Cartier', model: 'Diamanten Collier',
    beschrijving: 'Platina collier met briljant geslepen diamanten', serienummer: 'CT-8842-DP',
    verzekerdeWaarde: 78000, nieuwwaarde: 95000, huidigeWaarde: 85000,
    materiaaltype: 'Platina/Diamant', risicocategorie: 'Hoog', eigenaar: 'Dubois, Marie',
    contractRef: '#VC-2024-004905',
  },
  {
    id: 'Z-2024-0004', subtype: 'Elektronica', merk: 'Sony', model: 'A7R V + 24-70mm GM',
    beschrijving: 'Professionele camera set voor fotostudio', serienummer: 'SNYA7R5001234',
    verzekerdeWaarde: 5600, nieuwwaarde: 6200, huidigeWaarde: 4800,
    materiaaltype: 'Metaal/Kunststof', risicocategorie: 'Middel', eigenaar: 'Wouters, Emma',
    contractRef: '#VC-2024-004278',
  },
  {
    id: 'Z-2024-0005', subtype: 'Werktuigen', merk: 'Hilti', model: 'TE 70-ATC/AVS',
    beschrijving: 'Professionele boorhamer voor bouwwerf', serienummer: 'HTI-TE70-5678',
    verzekerdeWaarde: 2800, nieuwwaarde: 3200, huidigeWaarde: 2100,
    materiaaltype: 'Staal/Kunststof', risicocategorie: 'Middel', eigenaar: 'BVBA De Boer',
    contractRef: '#VC-2024-004601',
  },
  {
    id: 'Z-2024-0006', subtype: 'Meubilair', merk: 'B&B Italia', model: 'Camaleonda Sofa',
    beschrijving: 'Modulaire sofa — woonkamer', serienummer: 'BBI-CAM-2023-8901',
    verzekerdeWaarde: 12500, nieuwwaarde: 14800, huidigeWaarde: 11500,
    materiaaltype: 'Stof/Hout', risicocategorie: 'Laag', eigenaar: 'Peeters, Jan',
    contractRef: '#VC-2024-004892',
  },
  {
    id: 'Z-2024-0007', subtype: 'Elektronica', merk: 'Samsung', model: 'Neo QLED 85" 8K',
    beschrijving: 'Smart TV — vergaderruimte', serienummer: 'SAMSUNG85QN900C',
    verzekerdeWaarde: 5200, nieuwwaarde: 5999, huidigeWaarde: 4500,
    materiaaltype: 'Kunststof/Glas', risicocategorie: 'Middel', eigenaar: 'NV Verzekerd Goed',
    contractRef: '#VC-2024-004487',
  },
  {
    id: 'Z-2024-0008', subtype: 'Overig', merk: 'Rolex', model: 'Submariner Date 126610LN',
    beschrijving: 'Polshorloge — verzamelstuk', serienummer: 'RSC-2022-78901',
    verzekerdeWaarde: 12500, nieuwwaarde: 14000, huidigeWaarde: 13500,
    materiaaltype: 'Roestvrij staal', risicocategorie: 'Hoog', eigenaar: 'Janssens, Pieter',
    contractRef: '#VC-2024-004821',
  },
  {
    id: 'Z-2024-0009', subtype: 'Kunst', merk: 'Pierre Alechinsky', model: 'Abstracte Compositie (1978)',
    beschrijving: 'Aquarel en inkt op papier', serienummer: 'PA-1978-0012',
    verzekerdeWaarde: 45000, nieuwwaarde: 55000, huidigeWaarde: 48000,
    materiaaltype: 'Inkt/Papier', risicocategorie: 'Hoog', eigenaar: 'Michiels, Sarah',
    contractRef: '#VC-2024-004589',
  },
  {
    id: 'Z-2024-0010', subtype: 'Werktuigen', merk: 'Makita', model: 'DHP486RTJ',
    beschrijving: 'Accu boorschroefmachine set', serienummer: 'MKTDHP486-3344',
    verzekerdeWaarde: 380, nieuwwaarde: 450, huidigeWaarde: 310,
    materiaaltype: 'Kunststof/Metaal', risicocategorie: 'Laag', eigenaar: 'Maes, Koen',
  },
  {
    id: 'Z-2024-0011', subtype: 'Elektronica', merk: 'DJI', model: 'Matrice 350 RTK',
    beschrijving: 'Professionele drone met thermische camera', serienummer: 'DJI-M350-2023-5566',
    verzekerdeWaarde: 12800, nieuwwaarde: 14999, huidigeWaarde: 10500,
    materiaaltype: 'Koolstofvezel', risicocategorie: 'Hoog', eigenaar: 'NV Verzekerd Goed',
    contractRef: '#VC-2024-004156',
  },
]

// ====== Mock Data: Activiteiten (10+) ======

export const activiteitenData: Activiteit[] = [
  {
    id: 'AC-2024-0001', type: 'Evenement', beschrijving: 'Jubileumfeest 25 jaar BVBA De Boer',
    startdatum: '15/06/2025', einddatum: '15/06/2025', startTijd: '18:00', eindTijd: '02:00',
    locatie: 'Kasteel van Beieren, Brugge', deelnemers: 120, leeftijdscategorie: '21-65',
    risiconiveau: 'Middel', organisator: 'De Boer BVBA',
    contractRef: '#VC-2024-004601',
  },
  {
    id: 'AC-2024-0002', type: 'Wielerwedstrijd', beschrijving: 'Amateur wielerwedstrijd — provincie kampioenschap',
    startdatum: '22/09/2025', einddatum: '22/09/2025', startTijd: '09:00', eindTijd: '16:00',
    locatie: 'Vlaamse Ardennen, Oudenaarde', deelnemers: 85, leeftijdscategorie: '19-50',
    risiconiveau: 'Hoog', organisator: 'Wielerclub De Pedaal',
    contractRef: '#VC-2024-004654',
  },
  {
    id: 'AC-2024-0003', type: 'Concert', beschrijving: 'Bedrijfsconcert — jaarlijkse klantenavond',
    startdatum: '12/12/2025', einddatum: '12/12/2025', startTijd: '19:30', eindTijd: '23:00',
    locatie: 'Ancienne Belgique, Brussel', deelnemers: 350, leeftijdscategorie: 'All',
    risiconiveau: 'Middel', organisator: 'NV Verzekerd Goed',
    contractRef: '#VC-2024-004487',
  },
  {
    id: 'AC-2024-0004', type: 'Festival', beschrijving: 'Zomerfestival — 3-daags muziekevent',
    startdatum: '18/07/2025', einddatum: '20/07/2025', startTijd: '14:00', eindTijd: '02:00',
    locatie: 'De Lilse Bergen, Lille', deelnemers: 5000, leeftijdscategorie: '18-35',
    risiconiveau: 'Hoog', organisator: 'Festival Events BV',
  },
  {
    id: 'AC-2024-0005', type: 'Sportevent', beschrijving: 'Bedrijfsvoetbaltoernooi',
    startdatum: '10/05/2025', einddatum: '10/05/2025', startTijd: '10:00', eindTijd: '20:00',
    locatie: 'Sportcomplex Park, Mechelen', deelnemers: 200, leeftijdscategorie: '18-55',
    risiconiveau: 'Middel', organisator: 'De Boer BVBA',
    contractRef: '#VC-2024-004601',
  },
  {
    id: 'AC-2024-0006', type: 'Beurs', beschrijving: 'Vakbeurs Verzekeringen 2025',
    startdatum: '03/03/2025', einddatum: '05/03/2025', startTijd: '09:00', eindTijd: '18:00',
    locatie: 'Flanders Expo, Gent', deelnemers: 2500, leeftijdscategorie: '25-65',
    risiconiveau: 'Laag', organisator: 'Assuralia',
    contractRef: '#VC-2024-004892',
  },
  {
    id: 'AC-2024-0007', type: 'Catering', beschrijving: 'Huwelijksreceptie — 120 personen',
    startdatum: '28/06/2025', einddatum: '28/06/2025', startTijd: '16:00', eindTijd: '23:00',
    locatie: 'Kasteel Wijnegem, Antwerpen', deelnemers: 120, leeftijdscategorie: 'All',
    risiconiveau: 'Laag', organisator: 'Catering Delice',
  },
  {
    id: 'AC-2024-0008', type: 'Evenement', beschrijving: 'Charity gala — goed doel',
    startdatum: '08/11/2025', einddatum: '08/11/2025', startTijd: '19:00', eindTijd: '01:00',
    locatie: 'Hotel Metropole, Brussel', deelnemers: 250, leeftijdscategorie: '25-70',
    risiconiveau: 'Laag', organisator: 'Peeters, Jan',
    contractRef: '#VC-2024-004892',
  },
  {
    id: 'AC-2024-0009', type: 'Sportevent', beschrijving: 'Marathon voor teambuilding',
    startdatum: '14/09/2025', einddatum: '14/09/2025', startTijd: '08:00', eindTijd: '16:00',
    locatie: 'Kustmarathon, Oostende', deelnemers: 45, leeftijdscategorie: '20-55',
    risiconiveau: 'Middel', organisator: 'Janssens, Pieter',
  },
  {
    id: 'AC-2024-0010', type: 'Wielerwedstrijd', beschrijving: 'Jeugdwielerwedstrijd — regio',
    startdatum: '05/04/2025', einddatum: '05/04/2025', startTijd: '10:00', eindTijd: '14:00',
    locatie: 'Wielerbaan Heusden-Zolder', deelnemers: 40, leeftijdscategorie: '12-18',
    risiconiveau: 'Middel', organisator: 'Wielerclub De Pedaal',
  },
]

// ====== Mock Data: Persoon Arbeidsongeval (8+) ======

export const persoonArbeidsongevalData: PersoonArbeidsongeval[] = [
  {
    id: 'PAO-2024-0001', subtype: 'Werknemer', beschrijving: 'Productiemedewerker — magazijn',
    aantalPersonen: 8, risicoklasse: 'Klasse 2', naceCode: 'NACE-46121',
    leeftijdscategorie: '25-34', geslacht: 'M', startdatum: '01/01/2024',
    contractRef: '#VC-2024-004601',
  },
  {
    id: 'PAO-2024-0002', subtype: 'Zaakvoerder', beschrijving: 'Zaakvoerder — administratief kantoor',
    aantalPersonen: 1, risicoklasse: 'Klasse 1', naceCode: 'NACE-69201',
    leeftijdscategorie: '45-54', geslacht: 'M', startdatum: '01/03/2020',
    contractRef: '#VC-2024-004487',
  },
  {
    id: 'PAO-2024-0003', subtype: 'Statutair', beschrijving: 'Account manager — buitendienst',
    aantalPersonen: 3, risicoklasse: 'Klasse 2', naceCode: 'NACE-46121',
    leeftijdscategorie: '35-44', geslacht: 'V', startdatum: '01/06/2023',
    contractRef: '#VC-2024-004905',
  },
  {
    id: 'PAO-2024-0004', subtype: 'Werknemer', beschrijving: 'Chauffeur — vrachtwagenbestuurder',
    aantalPersonen: 4, risicoklasse: 'Klasse 3', naceCode: 'NACE-49410',
    leeftijdscategorie: '35-44', geslacht: 'M', startdatum: '01/01/2022',
    contractRef: '#VC-2024-004601',
  },
  {
    id: 'PAO-2024-0005', subtype: 'Gedetacheerd', beschrijving: 'IT-consultant — op locatie bij klant',
    aantalPersonen: 2, risicoklasse: 'Klasse 1', naceCode: 'NACE-62010',
    leeftijdscategorie: '25-34', geslacht: 'X', startdatum: '01/09/2024',
    contractRef: '#VC-2024-004698',
  },
  {
    id: 'PAO-2024-0006', subtype: 'Student', beschrijving: 'Jobstudent — horeca zomerperiode',
    aantalPersonen: 6, risicoklasse: 'Klasse 2', naceCode: 'NACE-56301',
    leeftijdscategorie: '18-24', geslacht: 'V', startdatum: '01/07/2024',
    contractRef: '#VC-2024-004654',
  },
  {
    id: 'PAO-2024-0007', subtype: 'Werknemer', beschrijving: 'Heftruckbestuurder — productiehal',
    aantalPersonen: 2, risicoklasse: 'Klasse 3', naceCode: 'NACE-28220',
    leeftijdscategorie: '45-54', geslacht: 'M', startdatum: '01/04/2023',
    contractRef: '#VC-2024-004487',
  },
  {
    id: 'PAO-2024-0008', subtype: 'Zaakvoerder', beschrijving: 'Zaakvoerder — bouwbedrijf',
    aantalPersonen: 1, risicoklasse: 'Klasse 4', naceCode: 'NACE-41201',
    leeftijdscategorie: '35-44', geslacht: 'M', startdatum: '01/02/2019',
    contractRef: '#VC-2024-004821',
  },
]

// ====== KPI Data ======

export const objectenKPIs = {
  totaal: 3421,
  voertuigen: 892,
  onroerendGoed: 456,
  leningen: 234,
  zaken: 1203,
  activiteiten: 636,
}

// ====== Helper: format currency ======

export function formatCurrency(value: number): string {
  return new Intl.NumberFormat('nl-BE', {
    style: 'currency',
    currency: 'EUR',
    minimumFractionDigits: 0,
  }).format(value)
}
