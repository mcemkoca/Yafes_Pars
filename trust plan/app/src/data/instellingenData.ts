import type { Institution } from './mockData'

// Extended institution types
export type ExtendedInstitutionType =
  | 'verzekeringsmaatschappij'
  | 'bank'
  | 'tussenpersoon'
  | 'reparatiebedrijf'
  | 'expertbureau'
  | 'andere'

// Short type codes for display
export const institutionTypeCode: Record<ExtendedInstitutionType, string> = {
  verzekeringsmaatschappij: 'VM',
  bank: 'BK',
  tussenpersoon: 'TP',
  reparatiebedrijf: 'RB',
  expertbureau: 'EB',
  andere: 'AD',
}

export const institutionTypeLabel: Record<ExtendedInstitutionType, string> = {
  verzekeringsmaatschappij: 'Verzekeringsmaatschappij',
  bank: 'Bank',
  tussenpersoon: 'Tussenpersoon',
  reparatiebedrijf: 'Reparatiebedrijf',
  expertbureau: 'Expertbureau',
  andere: 'Andere',
}

export interface InstitutionDetail extends Omit<Institution, 'type'> {
  type: ExtendedInstitutionType
  typeCode: string
  subtype?: string
  juridischeNaam?: string
  rechtsvorm?: string
  oprichtingsdatum?: string
  fsmaNummer?: string
  fsmaVergunningVerval?: string
  provincie?: string
  land?: string
  telefoonSchade?: string
  fax?: string
  website?: string
  iban?: string
  bic?: string
  hoofdsector?: string
  aantalWerknemers?: number
  notities?: string
  interneRef?: string
  contactpersonen?: { naam: string; functie: string; telefoon: string; email: string; primair: boolean }[]
  contractCount: number
  updatedAt?: string
}

export const institutionenDetails: InstitutionDetail[] = [
  {
    id: 'I-001', naam: 'Ethias', type: 'verzekeringsmaatschappij', typeCode: 'VM',
    juridischeNaam: 'Ethias Verzekeringen NV', rechtsvorm: 'Naamloze Vennootschap',
    kbo: 'BE 0400.123.456', oprichtingsdatum: '15/03/1992',
    fsmaNummer: '012345', fsmaVergunningVerval: '31/12/2025',
    hoofdsector: 'Schadeverzekering', aantalWerknemers: 1250,
    email: 'info@ethias.be', telefoon: '02/505.11.11', telefoonSchade: '02/505.12.34',
    fax: '02/505.11.99', website: 'www.ethias.be',
    adres: 'Voie de l\'Intendance 1', postcode: '1000', gemeente: 'Brussel', provincie: 'Brussel-Hoofdstad', land: 'België',
    iban: 'BE68 5390 0754 7034', bic: 'ETHI BE BB',
    status: 'actief', interneRef: 'ETH-001',
    notities: 'Belangrijkste partner voor schadeverzekeringen',
    createdAt: '2020-01-10', updatedAt: '2024-12-01',
    contractCount: 245,
    contactpersonen: [
      { naam: 'Pierre Dupont', functie: 'Account Manager', telefoon: '02/505.12.34', email: 'pierre.dupont@ethias.be', primair: true },
      { naam: 'Sophie Martin', functie: 'Schadebehandelaar', telefoon: '02/505.13.45', email: 'sophie.martin@ethias.be', primair: false },
      { naam: 'Jan Peeters', functie: 'Technisch Expert', telefoon: '02/505.14.56', email: 'jan.peeters@ethias.be', primair: false },
    ],
  },
  {
    id: 'I-002', naam: 'P&V', type: 'verzekeringsmaatschappij', typeCode: 'VM',
    juridischeNaam: 'P&V Verzekeringen NV', rechtsvorm: 'Naamloze Vennootschap',
    kbo: 'BE 0401.234.567', oprichtingsdatum: '01/01/1900',
    fsmaNummer: '012346', fsmaVergunningVerval: '31/12/2025',
    hoofdsector: 'Levensverzekering', aantalWerknemers: 890,
    email: 'info@pandv.be', telefoon: '02/551.11.11', telefoonSchade: '02/551.12.34',
    website: 'www.pandv.be',
    adres: 'Kantersteen 1', postcode: '1000', gemeente: 'Brussel', provincie: 'Brussel-Hoofdstad', land: 'België',
    iban: 'BE71 9955 5465 7025', bic: 'PAND BE BB',
    status: 'actief', interneRef: 'PNV-001',
    createdAt: '2020-01-10', updatedAt: '2024-11-28',
    contractCount: 198,
    contactpersonen: [
      { naam: 'Philippe Van den Berghe', functie: 'Account Manager', telefoon: '02/551.12.34', email: 'philippe.vdb@pandv.be', primair: true },
    ],
  },
  {
    id: 'I-003', naam: 'AXA Belgium', type: 'verzekeringsmaatschappij', typeCode: 'VM',
    juridischeNaam: 'AXA Belgium NV', rechtsvorm: 'Naamloze Vennootschap',
    kbo: 'BE 0402.345.678', oprichtingsdatum: '22/07/1980',
    fsmaNummer: '012347', fsmaVergunningVerval: '31/12/2025',
    hoofdsector: 'Schadeverzekering', aantalWerknemers: 2100,
    email: 'info@axa.be', telefoon: '02/550.11.11', telefoonSchade: '02/550.12.34',
    website: 'www.axa.be',
    adres: 'Boulevard du Souverain 25', postcode: '1170', gemeente: 'Watermaal-Bosvoorde', provincie: 'Brussel-Hoofdstad', land: 'België',
    iban: 'BE42 1820.1234.5678', bic: 'AXAB BE 22',
    status: 'actief', interneRef: 'AXA-001',
    createdAt: '2020-01-10', updatedAt: '2024-12-05',
    contractCount: 312,
    contactpersonen: [
      { naam: 'Marie Dubois', functie: 'Account Manager', telefoon: '02/550.12.34', email: 'marie.dubois@axa.be', primair: true },
      { naam: 'Lucas Peeters', functie: 'Schadebehandelaar', telefoon: '02/550.13.45', email: 'lucas.peeters@axa.be', primair: false },
    ],
  },
  {
    id: 'I-004', naam: 'Baloise', type: 'verzekeringsmaatschappij', typeCode: 'VM',
    juridischeNaam: 'Baloise Insurance NV', rechtsvorm: 'Naamloze Vennootschap',
    kbo: 'BE 0403.456.789', oprichtingsdatum: '01/04/1863',
    fsmaNummer: '012348', fsmaVergunningVerval: '31/12/2025',
    hoofdsector: 'Schadeverzekering', aantalWerknemers: 1450,
    email: 'info@baloise.be', telefoon: '03/217.11.11', telefoonSchade: '03/217.12.34',
    website: 'www.baloise.be',
    adres: 'Plantin en Moretuslei 1', postcode: '2018', gemeente: 'Antwerpen', provincie: 'Antwerpen', land: 'België',
    iban: 'BE77 3101.1234.5678', bic: 'BALA BE BB',
    status: 'actief', interneRef: 'BAL-001',
    createdAt: '2020-01-10', updatedAt: '2024-11-20',
    contractCount: 156,
    contactpersonen: [
      { naam: 'Pieter Janssens', functie: 'Account Manager', telefoon: '03/217.12.34', email: 'pieter.janssens@baloise.be', primair: true },
    ],
  },
  {
    id: 'I-005', naam: 'AG Insurance', type: 'verzekeringsmaatschappij', typeCode: 'VM',
    juridischeNaam: 'AG Insurance NV', rechtsvorm: 'Naamloze Vennootschap',
    kbo: 'BE 0404.567.890', oprichtingsdatum: '01/09/1989',
    fsmaNummer: '012349', fsmaVergunningVerval: '31/12/2025',
    hoofdsector: 'Levensverzekering', aantalWerknemers: 3200,
    email: 'info@aginsurance.be', telefoon: '02/554.41.11', telefoonSchade: '02/554.42.34',
    website: 'www.aginsurance.be',
    adres: 'Boulevard Emile Jacqmain 53', postcode: '1000', gemeente: 'Brussel', provincie: 'Brussel-Hoofdstad', land: 'België',
    iban: 'BE76 0001.1234.5678', bic: 'AGIB BE BB',
    status: 'actief', interneRef: 'AGI-001',
    createdAt: '2020-01-10', updatedAt: '2024-12-08',
    contractCount: 478,
    contactpersonen: [
      { naam: 'Anna Vermeiren', functie: 'Senior Account Manager', telefoon: '02/554.42.34', email: 'anna.vermeiren@aginsurance.be', primair: true },
      { naam: 'Thomas Peeters', functie: 'Schadebehandelaar', telefoon: '02/554.43.45', email: 'thomas.peeters@aginsurance.be', primair: false },
      { naam: 'Sarah Michiels', functie: 'Technisch Expert', telefoon: '02/554.44.56', email: 'sarah.michiels@aginsurance.be', primair: false },
    ],
  },
  {
    id: 'I-006', naam: 'KBC Verzekeringen', type: 'bank', typeCode: 'BK',
    juridischeNaam: 'KBC Verzekeringen NV', rechtsvorm: 'Naamloze Vennootschap',
    kbo: 'BE 0405.678.901', oprichtingsdatum: '01/01/1932',
    fsmaNummer: '023456', fsmaVergunningVerval: '31/12/2025',
    hoofdsector: 'Bank & Verzekeringen', aantalWerknemers: 8500,
    email: 'info@kbc.be', telefoon: '016/43.25.11', telefoonSchade: '016/43.26.34',
    website: 'www.kbc.be',
    adres: 'Havenlaan 2', postcode: '1080', gemeente: 'Brussel', provincie: 'Brussel-Hoofdstad', land: 'België',
    iban: 'BE31 7350.0416.0635', bic: 'KRED BE BB',
    status: 'actief', interneRef: 'KBC-001',
    createdAt: '2020-01-10', updatedAt: '2024-12-03',
    contractCount: 389,
    contactpersonen: [
      { naam: 'Bart Vandenberghe', functie: 'Relatie Manager', telefoon: '016/43.26.34', email: 'bart.vdb@kbc.be', primair: true },
    ],
  },
  {
    id: 'I-007', naam: 'ING Belgium', type: 'bank', typeCode: 'BK',
    juridischeNaam: 'ING Belgium NV/SA', rechtsvorm: 'Naamloze Vennootschap',
    kbo: 'BE 0406.789.012', oprichtingsdatum: '01/12/1968',
    fsmaNummer: '023457', fsmaVergunningVerval: '31/12/2025',
    hoofdsector: 'Bank & Verzekeringen', aantalWerknemers: 7200,
    email: 'info@ing.be', telefoon: '02/464.21.11', telefoonSchade: '02/464.22.34',
    website: 'www.ing.be',
    adres: 'Marnixlaan 24', postcode: '1000', gemeente: 'Brussel', provincie: 'Brussel-Hoofdstad', land: 'België',
    iban: 'BE05 3101.1234.5678', bic: 'BBRU BE BB',
    status: 'actief', interneRef: 'ING-001',
    createdAt: '2020-01-10', updatedAt: '2024-11-25',
    contractCount: 267,
    contactpersonen: [
      { naam: 'Sofie Claes', functie: 'Account Manager', telefoon: '02/464.22.34', email: 'sofie.claes@ing.be', primair: true },
      { naam: 'Dirk Verhoeven', functie: 'Verzekeringsspecialist', telefoon: '02/464.23.45', email: 'dirk.verhoeven@ing.be', primair: false },
    ],
  },
  {
    id: 'I-008', naam: 'Belfius', type: 'bank', typeCode: 'BK',
    juridischeNaam: 'Belfius Bank & Verzekeringen NV', rechtsvorm: 'Naamloze Vennootschap',
    kbo: 'BE 0407.890.123', oprichtingsdatum: '01/03/1996',
    fsmaNummer: '023458', fsmaVergunningVerval: '31/12/2025',
    hoofdsector: 'Bank & Verzekeringen', aantalWerknemers: 5400,
    email: 'info@belfius.be', telefoon: '02/222.11.11', telefoonSchade: '02/222.12.34',
    website: 'www.belfius.be',
    adres: 'Pachecolaan 44', postcode: '1000', gemeente: 'Brussel', provincie: 'Brussel-Hoofdstad', land: 'België',
    iban: 'BE55 0688.1234.5678', bic: 'GKCC BE BB',
    status: 'actief', interneRef: 'BEL-001',
    createdAt: '2020-01-10', updatedAt: '2024-12-10',
    contractCount: 198,
    contactpersonen: [
      { naam: 'Nathalie Bosmans', functie: 'Verzekeringsadviseur', telefoon: '02/222.12.34', email: 'nathalie.bosmans@belfius.be', primair: true },
    ],
  },
  {
    id: 'I-009', naam: 'BNP Paribas Fortis', type: 'bank', typeCode: 'BK',
    juridischeNaam: 'BNP Paribas Fortis NV', rechtsvorm: 'Naamloze Vennootschap',
    kbo: 'BE 0408.901.234', oprichtingsdatum: '15/02/2009',
    fsmaNummer: '023459', fsmaVergunningVerval: '31/12/2025',
    hoofdsector: 'Bank & Verzekeringen', aantalWerknemers: 6800,
    email: 'info@bnpparibasfortis.be', telefoon: '02/433.31.11', telefoonSchade: '02/433.32.34',
    website: 'www.bnpparibasfortis.be',
    adres: 'Warandeberg 3', postcode: '1000', gemeente: 'Brussel', provincie: 'Brussel-Hoofdstad', land: 'België',
    iban: 'BE31 0018.1234.5678', bic: 'GEBA BE BB',
    status: 'actief', interneRef: 'BNP-001',
    createdAt: '2020-01-10', updatedAt: '2024-12-02',
    contractCount: 234,
    contactpersonen: [
      { naam: 'Koen Maes', functie: 'Verzekeringsconsultant', telefoon: '02/433.32.34', email: 'koen.maes@bnpparibasfortis.be', primair: true },
    ],
  },
  {
    id: 'I-010', naam: 'Argenta', type: 'bank', typeCode: 'BK',
    juridischeNaam: 'Argenta Assuranties NV', rechtsvorm: 'Naamloze Vennootschap',
    kbo: 'BE 0409.012.345', oprichtingsdatum: '01/04/1956',
    fsmaNummer: '023460', fsmaVergunningVerval: '31/12/2025',
    hoofdsector: 'Bank & Verzekeringen', aantalWerknemers: 3200,
    email: 'info@argenta.be', telefoon: '03/217.21.11', telefoonSchade: '03/217.22.34',
    website: 'www.argenta.be',
    adres: 'Argentalaan 1', postcode: '1930', gemeente: 'Zaventem', provincie: 'Vlaams-Brabant', land: 'België',
    iban: 'BE68 7868.1234.5678', bic: 'ARSP BE 22',
    status: 'actief', interneRef: 'ARG-001',
    createdAt: '2020-01-10', updatedAt: '2024-11-30',
    contractCount: 156,
    contactpersonen: [
      { naam: 'Liesbeth De Smet', functie: 'Assurantieadviseur', telefoon: '03/217.22.34', email: 'liesbeth.desmet@argenta.be', primair: true },
    ],
  },
  {
    id: 'I-011', naam: 'Allianz Belgium', type: 'verzekeringsmaatschappij', typeCode: 'VM',
    juridischeNaam: 'Allianz Belgium NV', rechtsvorm: 'Naamloze Vennootschap',
    kbo: 'BE 0410.123.456', oprichtingsdatum: '10/06/1890',
    fsmaNummer: '012350', fsmaVergunningVerval: '31/12/2025',
    hoofdsector: 'Schadeverzekering', aantalWerknemers: 1800,
    email: 'info@allianz.be', telefoon: '02/554.92.11', telefoonSchade: '02/554.93.34',
    website: 'www.allianz.be',
    adres: 'Boulevard du Souverain 33', postcode: '1170', gemeente: 'Watermaal-Bosvoorde', provincie: 'Brussel-Hoofdstad', land: 'België',
    iban: 'BE44 0001.1234.5678', bic: 'ALLZ BE BB',
    status: 'actief', interneRef: 'ALL-001',
    createdAt: '2020-01-10', updatedAt: '2024-12-06',
    contractCount: 198,
    contactpersonen: [
      { naam: 'Lucas Peeters', functie: 'Account Manager', telefoon: '02/554.93.34', email: 'lucas.peeters@allianz.be', primair: true },
    ],
  },
  {
    id: 'I-012', naam: 'Van Dessel Assurantiën', type: 'tussenpersoon', typeCode: 'TP',
    juridischeNaam: 'Van Dessel Assurantiën BVBA', rechtsvorm: 'Besloten Vennootschap',
    kbo: 'BE 0507.123.456', oprichtingsdatum: '01/09/2005',
    fsmaNummer: '034567', fsmaVergunningVerval: '31/12/2025',
    hoofdsector: 'Verzekeringsbemiddeling', aantalWerknemers: 12,
    email: 'info@vandessel.be', telefoon: '014/26.58.90', telefoonSchade: '014/26.58.91',
    website: 'www.vandessel.be',
    adres: 'Stationsstraat 15', postcode: '2200', gemeente: 'Herentals', provincie: 'Antwerpen', land: 'België',
    iban: 'BE55 0011.1234.5678', bic: 'KRED BE BB',
    status: 'actief', interneRef: 'VDS-001',
    createdAt: '2020-01-10', updatedAt: '2024-12-01',
    contractCount: 45,
    contactpersonen: [
      { naam: 'Johan Van Dessel', functie: 'Zaakvoerder', telefoon: '0475/12.34.56', email: 'johan@vandessel.be', primair: true },
      { naam: 'Maria Van Dessel', functie: 'Administratief', telefoon: '0476/23.45.67', email: 'maria@vandessel.be', primair: false },
    ],
  },
  {
    id: 'I-013', naam: 'De Vries Verzekeringen', type: 'tussenpersoon', typeCode: 'TP',
    juridischeNaam: 'De Vries Verzekeringen BV', rechtsvorm: 'Besloten Vennootschap',
    kbo: 'BE 0508.234.567', oprichtingsdatum: '15/04/2010',
    fsmaNummer: '034568', fsmaVergunningVerval: '31/12/2025',
    hoofdsector: 'Verzekeringsbemiddeling', aantalWerknemers: 8,
    email: 'info@devries.be', telefoon: '056/22.34.56', telefoonSchade: '056/22.34.57',
    website: 'www.devries.be',
    adres: 'Markt 8', postcode: '8500', gemeente: 'Kortrijk', provincie: 'West-Vlaanderen', land: 'België',
    iban: 'BE34 0012.1234.5678', bic: 'KRED BE BB',
    status: 'actief', interneRef: 'DVZ-001',
    createdAt: '2020-01-10', updatedAt: '2024-11-28',
    contractCount: 38,
    contactpersonen: [
      { naam: 'Peter De Vries', functie: 'Zaakvoerder', telefoon: '0477/34.56.78', email: 'peter@devries.be', primair: true },
    ],
  },
  {
    id: 'I-014', naam: 'AutoFix Herstelcentrum', type: 'reparatiebedrijf', typeCode: 'RB',
    juridischeNaam: 'AutoFix Herstelcentrum BVBA', rechtsvorm: 'Besloten Vennootschap',
    kbo: 'BE 0609.345.678', oprichtingsdatum: '01/06/2008',
    hoofdsector: 'Voertuigherstel', aantalWerknemers: 15,
    email: 'info@autofix.be', telefoon: '09/234.56.78', telefoonSchade: '09/234.56.79',
    website: 'www.autofix.be',
    adres: 'Industrielaan 22', postcode: '9000', gemeente: 'Gent', provincie: 'Oost-Vlaanderen', land: 'België',
    iban: 'BE22 0013.1234.5678', bic: 'KRED BE BB',
    status: 'actief', interneRef: 'AFX-001',
    createdAt: '2020-01-10', updatedAt: '2024-11-15',
    contractCount: 0,
    contactpersonen: [
      { naam: 'Frank De Smet', functie: 'Zaakvoerder', telefoon: '0478/45.67.89', email: 'frank@autofix.be', primair: true },
    ],
  },
  {
    id: 'I-015', naam: 'Fédérale Assurance', type: 'verzekeringsmaatschappij', typeCode: 'VM',
    juridischeNaam: 'Fédérale Assurance SC', rechtsvorm: 'Samenwerkende Vennootschap',
    kbo: 'BE 0411.234.567', oprichtingsdatum: '01/01/1980',
    fsmaNummer: '012351', fsmaVergunningVerval: '31/12/2025',
    hoofdsector: 'Schadeverzekering', aantalWerknemers: 650,
    email: 'info@federale.be', telefoon: '09/269.91.11', telefoonSchade: '09/269.92.34',
    website: 'www.federale.be',
    adres: 'Maatschappijlaan 1', postcode: '9000', gemeente: 'Gent', provincie: 'Oost-Vlaanderen', land: 'België',
    iban: 'BE11 0001.1234.5678', bic: 'FEDE BE BB',
    status: 'actief', interneRef: 'FED-001',
    createdAt: '2020-01-10', updatedAt: '2024-12-08',
    contractCount: 87,
    contactpersonen: [
      { naam: 'Bart Vandenberghe', functie: 'Account Manager', telefoon: '09/269.92.34', email: 'bart.vdb@federale.be', primair: true },
    ],
  },
  {
    id: 'I-016', naam: 'Schoonjans Expertise', type: 'expertbureau', typeCode: 'EB',
    juridischeNaam: 'Schoonjans Expertise BVBA', rechtsvorm: 'Besloten Vennootschap',
    kbo: 'BE 0610.456.789', oprichtingsdatum: '01/03/2002',
    hoofdsector: ' expertisebureau', aantalWerknemers: 6,
    email: 'info@schoonjansexpertise.be', telefoon: '03/315.67.89', telefoonSchade: '03/315.67.90',
    website: 'www.schoonjansexpertise.be',
    adres: 'Turnhoutsebaan 45', postcode: '2140', gemeente: 'Antwerpen', provincie: 'Antwerpen', land: 'België',
    iban: 'BE33 0014.1234.5678', bic: 'KRED BE BB',
    status: 'actief', interneRef: 'SCH-001',
    createdAt: '2020-01-10', updatedAt: '2024-11-22',
    contractCount: 0,
    contactpersonen: [
      { naam: 'Karel Schoonjans', functie: 'Hoofdexpert', telefoon: '0479/56.78.90', email: 'karel@schoonjansexpertise.be', primair: true },
    ],
  },
]

// Institution cities for filter
export const institutionCities = [
  'Brussel', 'Antwerpen', 'Gent', 'Mechelen', 'Leuven', 'Hasselt', 'Brugge',
  'Kortrijk', 'Oostende', 'Luik', 'Namen', 'Herentals', 'Ternat', 'Heverlee',
  'Dilbeek', 'Mortsel', 'Zaventem', 'Watermaal-Bosvoorde',
]

// Stats
export const institutionStats = {
  totaal: 156,
  verzekeringsmaatschappijen: 42,
  banken: 28,
  tussenpersonen: 35,
  andere: 51,
}

// Type filter options
export const institutionTypeFilters = [
  { value: 'alle', label: 'Alle types' },
  { value: 'verzekeringsmaatschappij', label: 'Verzekeringsmaatschappij' },
  { value: 'bank', label: 'Bank' },
  { value: 'tussenpersoon', label: 'Tussenpersoon' },
  { value: 'reparatiebedrijf', label: 'Reparatiebedrijf' },
  { value: 'expertbureau', label: 'Expertbureau' },
  { value: 'andere', label: 'Andere' },
]
