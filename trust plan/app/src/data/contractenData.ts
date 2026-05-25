// Contract data types and mock data for Contracten page

// Extended contract status for the contracten page
export type ContractStatus = 'LOPEND' | 'OPGEZEGD' | 'GESCHORST' | 'IN_WIJZIGING' | 'GEARCHIVEERD'

export type ContractDomein =
  | 'AUTO'
  | 'BRAND_EENVOUDIG'
  | 'BRAND_BIJZONDERE'
  | 'LEVEN_BELEGGINGEN'
  | 'HOSPITALISATIE'
  | 'ARBEIDSONGEVALLEN_COLLECTIEF'
  | 'DIVER'

export type ContractType =
  | 'AUTO_TOERISME'
  | 'AUTO_BROMFIETSEN'
  | 'AUTO_LICHTE_VRACHTWAGENS'
  | 'AUTO_OMNIUM'
  | 'AUTO_BA'
  | 'AUTO_MINI_OMNIUM'
  | 'WOON_VERZEKERING'
  | 'BRAND_BEDRIJF'
  | 'LEVEN_OVERLIJDEN'
  | 'HOSPITALISATIE_INDIVIDUEEL'
  | 'HOSPITALISATIE_GROEP'
  | 'RECHTSBIJSTAND'
  | 'BA_PRIVAAT'
  | 'ARBEIDSONGEVAL'

export type Periodiciteit = 'JAARLIJKS' | 'MAANDELIJKS' | 'DRIEMAANDELIKS' | 'HALFJAARLIJKS' | 'EENMALIG'

export type IncassoWijze = 'DOMICILIERING' | 'KREDIETKAART' | 'OVERSCHRIJVING' | 'INCASSO'

export type Herkomst = 'ACQUISITIE' | 'VERLENGING' | 'OVERNAME'

export interface Partij {
  id: string
  naam: string
  rol: 'VERZEKERINGNEMER' | 'VERZEKERDE' | 'MEDEVERZEKERDE' | 'BEGUNSTIGDE' | 'VERZEKERAAR' | 'BEHANDELAAR'
  type: 'NP' | 'RP' | 'VM' | 'EB'
  adres?: string
  telefoon?: string
}

export interface ContractObject {
  id: string
  naam: string
  type: 'Voertuig' | 'Onroerend goed' | 'Algemeen'
  identificatie: string
  waarde?: string
  status: 'Actief' | 'In herstel' | 'Vermist' | 'Geschrapt'
}

export interface ContractVersie {
  versie: number
  ingangsdatum: string
  status: 'Actief' | 'Vervangen' | 'Beeindigd'
  premie: number
  wijzigingDoor?: string
  wijzigingDatum?: string
  reden?: string
}

export interface Dekking {
  code: string
  omschrijving: string
  limiet?: string
  eigenRisico?: string
  inbegrepen: boolean
}

export interface ContractDocument {
  id: string
  naam: string
  type: 'PDF' | 'DOC' | 'IMG'
  datum: string
}

export interface ContractDetail {
  id: string
  contractnummer: string
  status: ContractStatus
  domein: ContractDomein
  type: ContractType
  typeLabel: string
  herkomst: Herkomst
  ingangsdatum: string
  vervaldatum: string
  opzegtermijn: string
  automatischeVerlenging: boolean
  premie: number
  maandpremie: number
  provisiePct: number
  provisieBedrag: number
  periodiciteit: Periodiciteit
  incassoWijze: IncassoWijze
  maatschappijId: string
  maatschappijNaam: string
  maatschappijAgentnummer?: string
  maatschappijTelefoon?: string
  partijen: Partij[]
  objecten: ContractObject[]
  versies: ContractVersie[]
  dekkingen: Dekking[]
  documenten: ContractDocument[]
  resterendeDagen: number
  versie: number
  laatstBijgewerkt: string
}

// Status badge mapping
export const statusBadgeMap: Record<ContractStatus, { variant: 'active' | 'warning' | 'error' | 'info' | 'neutral'; label: string }> = {
  LOPEND: { variant: 'active', label: 'Lopend' },
  OPGEZEGD: { variant: 'error', label: 'Opgezegd' },
  GESCHORST: { variant: 'warning', label: 'Geschorst' },
  IN_WIJZIGING: { variant: 'info', label: 'In Wijziging' },
  GEARCHIVEERD: { variant: 'neutral', label: 'Gearchiveerd' },
}

// Helper to format currency
export function formatCurrency(value: number): string {
  return new Intl.NumberFormat('nl-BE', {
    style: 'currency',
    currency: 'EUR',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(value)
}

// Helper to format date
export function formatDate(dateStr: string): string {
  if (!dateStr) return '-'
  const d = new Date(dateStr)
  if (isNaN(d.getTime())) return dateStr
  return d.toLocaleDateString('nl-BE', { day: '2-digit', month: '2-digit', year: 'numeric' })
}

// Helper: days remaining
export function daysRemaining(endDate: string): number {
  const end = new Date(endDate)
  const now = new Date()
  const diff = end.getTime() - now.getTime()
  return Math.ceil(diff / (1000 * 60 * 60 * 24))
}

// Get institution name by ID
export function getMaatschappijNaam(id: string): string {
  const map: Record<string, string> = {
    'I-001': 'Ethias',
    'I-002': 'AG Insurance',
    'I-003': 'AXA Belgium',
    'I-004': 'Baloise',
    'I-005': 'Allianz Belgium',
    'I-006': 'Federale Verzekering',
    'I-007': 'Axa Belgium',
    'I-008': 'KBC Verzekeringen',
    'I-009': 'Intervoor',
    'I-010': 'Vivium',
    'I-011': 'DKV Belgium',
    'I-012': 'P&V',
  }
  return map[id] || id
}

// ====== 25 Contract Detail Records ======
export const contractDetails: ContractDetail[] = [
  {
    id: 'C-001',
    contractnummer: 'POL-2024-001234',
    status: 'LOPEND',
    domein: 'AUTO',
    type: 'AUTO_OMNIUM',
    typeLabel: 'Auto Omnium',
    herkomst: 'ACQUISITIE',
    ingangsdatum: '2024-06-15',
    vervaldatum: '2025-06-15',
    opzegtermijn: '3 maanden',
    automatischeVerlenging: true,
    premie: 1240,
    maandpremie: 103.33,
    provisiePct: 15,
    provisieBedrag: 186,
    periodiciteit: 'JAARLIJKS',
    incassoWijze: 'DOMICILIERING',
    maatschappijId: 'I-001',
    maatschappijNaam: 'Ethias',
    maatschappijAgentnummer: '012345',
    maatschappijTelefoon: '02/505.11.11',
    partijen: [
      { id: 'P-2024-0001', naam: 'Peeters, Jan', rol: 'VERZEKERINGNEMER', type: 'NP', adres: 'Kerkstraat 12, 2800 Mechelen', telefoon: '0478/12.34.56' },
      { id: 'P-2024-0002', naam: 'Peeters, Hilde', rol: 'MEDEVERZEKERDE', type: 'NP', adres: 'Kerkstraat 12, 2800 Mechelen', telefoon: '0478/12.34.57' },
      { id: 'P-2024-0006', naam: 'Lucas Peeters', rol: 'MEDEVERZEKERDE', type: 'NP', adres: 'Kerkstraat 12, 2800 Mechelen' },
      { id: 'I-001', naam: 'Ethias', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.11.11' },
    ],
    objecten: [
      { id: 'O-V-001', naam: 'Mercedes-Benz C-Klasse Break d', type: 'Voertuig', identificatie: '1-ABC-234', waarde: '€ 32.800', status: 'Actief' },
    ],
    versies: [
      { versie: 2, ingangsdatum: '2024-06-15', status: 'Actief', premie: 1240, wijzigingDoor: 'Marie Dubois', wijzigingDatum: '2024-09-15', reden: 'Premie aangepast: € 1.180 → € 1.240' },
      { versie: 1, ingangsdatum: '2024-06-15', status: 'Vervangen', premie: 1180, wijzigingDoor: 'Systeem', wijzigingDatum: '2024-06-15', reden: 'Contract aangemaakt' },
    ],
    dekkingen: [
      { code: 'BA', omschrijving: 'Burgerlijke Aansprakelijkheid', limiet: '€ ∞', eigenRisico: '€ 0', inbegrepen: true },
      { code: 'MO', omschrijving: 'Mini-Omnium (glas, brand, diefstal)', limiet: '€ 32.800', eigenRisico: '€ 250', inbegrepen: true },
      { code: 'OM', omschrijving: 'Omnium (alle schades)', limiet: '€ 32.800 (NWO)', eigenRisico: '€ 250', inbegrepen: true },
      { code: 'RB', omschrijving: 'Rechtsbijstand', limiet: undefined, eigenRisico: '€ 0', inbegrepen: true },
      { code: 'BV', omschrijving: 'Bergerging & vervangvervoer', limiet: undefined, eigenRisico: '€ 0', inbegrepen: true },
    ],
    documenten: [
      { id: 'D-001', naam: 'Polisdocument', type: 'PDF', datum: '2024-06-15' },
      { id: 'D-002', naam: 'Algemene Voorwaarden', type: 'PDF', datum: '2024-06-15' },
    ],
    resterendeDagen: 183,
    versie: 2,
    laatstBijgewerkt: '2024-09-15',
  },
  {
    id: 'C-002',
    contractnummer: 'POL-2024-001235',
    status: 'LOPEND',
    domein: 'BRAND_EENVOUDIG',
    type: 'WOON_VERZEKERING',
    typeLabel: 'Woningverzekering',
    herkomst: 'VERLENGING',
    ingangsdatum: '2024-01-01',
    vervaldatum: '2025-01-01',
    opzegtermijn: '3 maanden',
    automatischeVerlenging: true,
    premie: 890,
    maandpremie: 74.17,
    provisiePct: 12,
    provisieBedrag: 106.8,
    periodiciteit: 'JAARLIJKS',
    incassoWijze: 'DOMICILIERING',
    maatschappijId: 'I-012',
    maatschappijNaam: 'P&V',
    maatschappijAgentnummer: '023456',
    maatschappijTelefoon: '02/505.22.22',
    partijen: [
      { id: 'P-2024-0002', naam: 'Dubois, Marie', rol: 'VERZEKERINGNEMER', type: 'NP', adres: 'Rue du Marche 45, 3000 Leuven', telefoon: '0479/23.45.67' },
      { id: 'I-012', naam: 'P&V', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.22.22' },
    ],
    objecten: [
      { id: 'O-R-001', naam: 'Woning - Rue du Marche 45', type: 'Onroerend goed', identificatie: '3000 Leuven', waarde: '€ 285.000', status: 'Actief' },
    ],
    versies: [
      { versie: 3, ingangsdatum: '2024-01-01', status: 'Actief', premie: 890, wijzigingDoor: 'Systeem', wijzigingDatum: '2024-01-01', reden: 'Automatische verlenging' },
      { versie: 2, ingangsdatum: '2023-01-01', status: 'Vervangen', premie: 850, wijzigingDoor: 'Systeem', wijzigingDatum: '2023-01-01' },
      { versie: 1, ingangsdatum: '2022-01-01', status: 'Vervangen', premie: 820, wijzigingDoor: 'Systeem', wijzigingDatum: '2022-01-01' },
    ],
    dekkingen: [
      { code: 'BWG', omschrijving: 'Brand Woning', limiet: '€ 285.000', eigenRisico: '€ 250', inbegrepen: true },
      { code: 'INB', omschrijving: 'Inboedel', limiet: '€ 75.000', eigenRisico: '€ 125', inbegrepen: true },
      { code: 'BOE', omschrijving: 'Burgerlijke Aansprakelijkheid', limiet: '€ 5.000.000', eigenRisico: '€ 0', inbegrepen: true },
      { code: 'REC', omschrijving: 'Rechtsbijstand', limiet: '€ 25.000', eigenRisico: '€ 125', inbegrepen: true },
    ],
    documenten: [
      { id: 'D-003', naam: 'Polisdocument', type: 'PDF', datum: '2024-01-01' },
    ],
    resterendeDagen: 15,
    versie: 3,
    laatstBijgewerkt: '2024-01-01',
  },
  {
    id: 'C-003',
    contractnummer: 'POL-2024-001236',
    status: 'LOPEND',
    domein: 'AUTO',
    type: 'AUTO_BA',
    typeLabel: 'Auto BA',
    herkomst: 'ACQUISITIE',
    ingangsdatum: '2024-03-22',
    vervaldatum: '2025-03-22',
    opzegtermijn: '3 maanden',
    automatischeVerlenging: true,
    premie: 450,
    maandpremie: 37.5,
    provisiePct: 10,
    provisieBedrag: 45,
    periodiciteit: 'JAARLIJKS',
    incassoWijze: 'KREDIETKAART',
    maatschappijId: 'I-003',
    maatschappijNaam: 'AXA Belgium',
    maatschappijAgentnummer: '034567',
    maatschappijTelefoon: '02/505.33.33',
    partijen: [
      { id: 'P-2024-0003', naam: 'Janssens, Pieter', rol: 'VERZEKERINGNEMER', type: 'NP', adres: 'Stationsstraat 8, 3500 Hasselt', telefoon: '0480/34.56.78' },
      { id: 'I-003', naam: 'AXA Belgium', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.33.33' },
    ],
    objecten: [
      { id: 'O-V-002', naam: 'VW Golf VIII', type: 'Voertuig', identificatie: '2-XYZ-567', waarde: '€ 24.500', status: 'Actief' },
    ],
    versies: [
      { versie: 1, ingangsdatum: '2024-03-22', status: 'Actief', premie: 450, wijzigingDoor: 'Systeem', wijzigingDatum: '2024-03-22' },
    ],
    dekkingen: [
      { code: 'BA', omschrijving: 'Burgerlijke Aansprakelijkheid', limiet: '€ ∞', eigenRisico: '€ 0', inbegrepen: true },
      { code: 'BV', omschrijving: 'Bergerging', limiet: undefined, eigenRisico: '€ 0', inbegrepen: true },
    ],
    documenten: [
      { id: 'D-004', naam: 'Polisdocument', type: 'PDF', datum: '2024-03-22' },
    ],
    resterendeDagen: 95,
    versie: 1,
    laatstBijgewerkt: '2024-03-22',
  },
  {
    id: 'C-004',
    contractnummer: 'POL-2024-001237',
    status: 'LOPEND',
    domein: 'BRAND_BIJZONDERE',
    type: 'BRAND_BEDRIJF',
    typeLabel: 'Brand Bedrijf',
    herkomst: 'ACQUISITIE',
    ingangsdatum: '2024-07-01',
    vervaldatum: '2025-07-01',
    opzegtermijn: '3 maanden',
    automatischeVerlenging: true,
    premie: 1680,
    maandpremie: 140,
    provisiePct: 15,
    provisieBedrag: 252,
    periodiciteit: 'JAARLIJKS',
    incassoWijze: 'DOMICILIERING',
    maatschappijId: 'I-004',
    maatschappijNaam: 'Baloise',
    maatschappijAgentnummer: '045678',
    maatschappijTelefoon: '02/505.44.44',
    partijen: [
      { id: 'P-2024-0004', naam: 'BVBA De Boer', rol: 'VERZEKERINGNEMER', type: 'RP', adres: 'Industrielaan 45, 2018 Antwerpen', telefoon: '03/123.45.67' },
      { id: 'P-2024-0004b', naam: 'De Boer, Luc', rol: 'VERZEKERDE', type: 'NP', telefoon: '0475/45.67.89' },
      { id: 'I-004', naam: 'Baloise', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.44.44' },
    ],
    objecten: [
      { id: 'O-R-002', naam: 'Bedrijfsgebouw - Industrielaan 45', type: 'Onroerend goed', identificatie: '2018 Antwerpen', waarde: '€ 450.000', status: 'Actief' },
    ],
    versies: [
      { versie: 1, ingangsdatum: '2024-07-01', status: 'Actief', premie: 1680, wijzigingDoor: 'Systeem', wijzigingDatum: '2024-07-01' },
    ],
    dekkingen: [
      { code: 'BB', omschrijving: 'Brand Bedrijf', limiet: '€ 450.000', eigenRisico: '€ 500', inbegrepen: true },
      { code: 'INB', omschrijving: 'Inboedel Bedrijf', limiet: '€ 125.000', eigenRisico: '€ 250', inbegrepen: true },
      { code: 'BOE', omschrijving: 'Burgerlijke Aansprakelijkheid', limiet: '€ 10.000.000', eigenRisico: '€ 0', inbegrepen: true },
      { code: 'ALW', omschrijving: 'Algemene wetsgebonden aansprakelijkheid', limiet: '€ 2.500.000', eigenRisico: '€ 250', inbegrepen: true },
    ],
    documenten: [
      { id: 'D-005', naam: 'Polisdocument', type: 'PDF', datum: '2024-07-01' },
      { id: 'D-006', naam: 'Clausules', type: 'PDF', datum: '2024-07-01' },
    ],
    resterendeDagen: 196,
    versie: 1,
    laatstBijgewerkt: '2024-07-01',
  },
  {
    id: 'C-005',
    contractnummer: 'POL-2024-001238',
    status: 'LOPEND',
    domein: 'DIVER',
    type: 'RECHTSBIJSTAND',
    typeLabel: 'Rechtsbijstand',
    herkomst: 'ACQUISITIE',
    ingangsdatum: '2024-09-10',
    vervaldatum: '2025-09-10',
    opzegtermijn: '3 maanden',
    automatischeVerlenging: true,
    premie: 125,
    maandpremie: 10.42,
    provisiePct: 12,
    provisieBedrag: 15,
    periodiciteit: 'JAARLIJKS',
    incassoWijze: 'OVERSCHRIJVING',
    maatschappijId: 'I-005',
    maatschappijNaam: 'Allianz Belgium',
    maatschappijAgentnummer: '056789',
    maatschappijTelefoon: '02/505.55.55',
    partijen: [
      { id: 'P-2024-0005', naam: 'Vermeiren, Anna', rol: 'VERZEKERINGNEMER', type: 'NP', adres: 'Korenmarkt 3, 9000 Gent', telefoon: '0481/45.67.89' },
      { id: 'I-005', naam: 'Allianz Belgium', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.55.55' },
    ],
    objecten: [],
    versies: [
      { versie: 1, ingangsdatum: '2024-09-10', status: 'Actief', premie: 125, wijzigingDoor: 'Systeem', wijzigingDatum: '2024-09-10' },
    ],
    dekkingen: [
      { code: 'RB-P', omschrijving: 'Rechtsbijstand Privé', limiet: '€ 25.000', eigenRisico: '€ 125', inbegrepen: true },
      { code: 'RB-V', omschrijving: 'Rechtsbijstand Verkeer', limiet: '€ 25.000', eigenRisico: '€ 125', inbegrepen: true },
    ],
    documenten: [
      { id: 'D-007', naam: 'Polisdocument', type: 'PDF', datum: '2024-09-10' },
    ],
    resterendeDagen: 267,
    versie: 1,
    laatstBijgewerkt: '2024-09-10',
  },
  {
    id: 'C-006',
    contractnummer: 'POL-2024-001239',
    status: 'LOPEND',
    domein: 'DIVER',
    type: 'BA_PRIVAAT',
    typeLabel: 'BA Privaat',
    herkomst: 'ACQUISITIE',
    ingangsdatum: '2024-05-05',
    vervaldatum: '2025-05-05',
    opzegtermijn: '3 maanden',
    automatischeVerlenging: true,
    premie: 195,
    maandpremie: 16.25,
    provisiePct: 12,
    provisieBedrag: 23.4,
    periodiciteit: 'JAARLIJKS',
    incassoWijze: 'DOMICILIERING',
    maatschappijId: 'I-001',
    maatschappijNaam: 'Ethias',
    maatschappijAgentnummer: '012345',
    maatschappijTelefoon: '02/505.11.11',
    partijen: [
      { id: 'P-2024-0007', naam: 'Michiels, Sarah', rol: 'VERZEKERINGNEMER', type: 'NP', adres: 'Grote Markt 5, 1000 Brussel', telefoon: '0482/67.89.01' },
      { id: 'I-001', naam: 'Ethias', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.11.11' },
    ],
    objecten: [],
    versies: [
      { versie: 1, ingangsdatum: '2024-05-05', status: 'Actief', premie: 195, wijzigingDoor: 'Systeem', wijzigingDatum: '2024-05-05' },
    ],
    dekkingen: [
      { code: 'BA-P', omschrijving: 'Burgerlijke Aansprakelijkheid Privaat', limiet: '€ 5.000.000', eigenRisico: '€ 0', inbegrepen: true },
      { code: 'BA-G', omschrijving: 'Burgerlijke Aansprakelijkheid Gezin', limiet: '€ 10.000.000', eigenRisico: '€ 0', inbegrepen: true },
    ],
    documenten: [
      { id: 'D-008', naam: 'Polisdocument', type: 'PDF', datum: '2024-05-05' },
    ],
    resterendeDagen: 139,
    versie: 1,
    laatstBijgewerkt: '2024-05-05',
  },
  {
    id: 'C-007',
    contractnummer: 'POL-2023-000987',
    status: 'OPGEZEGD',
    domein: 'BRAND_EENVOUDIG',
    type: 'WOON_VERZEKERING',
    typeLabel: 'Woningverzekering',
    herkomst: 'VERLENGING',
    ingangsdatum: '2023-03-01',
    vervaldatum: '2024-03-01',
    opzegtermijn: '3 maanden',
    automatischeVerlenging: false,
    premie: 920,
    maandpremie: 76.67,
    provisiePct: 12,
    provisieBedrag: 110.4,
    periodiciteit: 'JAARLIJKS',
    incassoWijze: 'DOMICILIERING',
    maatschappijId: 'I-008',
    maatschappijNaam: 'KBC Verzekeringen',
    maatschappijAgentnummer: '078901',
    maatschappijTelefoon: '016/43.25.11',
    partijen: [
      { id: 'P-2024-0001', naam: 'Peeters, Jan', rol: 'VERZEKERINGNEMER', type: 'NP', adres: 'Kerkstraat 12, 2800 Mechelen', telefoon: '0478/12.34.56' },
      { id: 'I-008', naam: 'KBC Verzekeringen', rol: 'VERZEKERAAR', type: 'VM', telefoon: '016/43.25.11' },
    ],
    objecten: [
      { id: 'O-R-003', naam: 'Woning - Kerkstraat 12', type: 'Onroerend goed', identificatie: '2800 Mechelen', waarde: '€ 320.000', status: 'Actief' },
    ],
    versies: [
      { versie: 1, ingangsdatum: '2023-03-01', status: 'Beeindigd', premie: 920, wijzigingDoor: 'Systeem', wijzigingDatum: '2024-03-01', reden: 'Contract opgezegd - klant naar andere maatschappij' },
    ],
    dekkingen: [
      { code: 'BWG', omschrijving: 'Brand Woning', limiet: '€ 320.000', eigenRisico: '€ 250', inbegrepen: true },
      { code: 'INB', omschrijving: 'Inboedel', limiet: '€ 85.000', eigenRisico: '€ 125', inbegrepen: true },
    ],
    documenten: [
      { id: 'D-009', naam: 'Polisdocument', type: 'PDF', datum: '2023-03-01' },
    ],
    resterendeDagen: 0,
    versie: 1,
    laatstBijgewerkt: '2024-03-01',
  },
  {
    id: 'C-008',
    contractnummer: 'POL-2023-000654',
    status: 'GEARCHIVEERD',
    domein: 'AUTO',
    type: 'AUTO_OMNIUM',
    typeLabel: 'Auto Omnium',
    herkomst: 'VERLENGING',
    ingangsdatum: '2023-06-15',
    vervaldatum: '2024-06-15',
    opzegtermijn: '3 maanden',
    automatischeVerlenging: false,
    premie: 1180,
    maandpremie: 98.33,
    provisiePct: 15,
    provisieBedrag: 177,
    periodiciteit: 'JAARLIJKS',
    incassoWijze: 'DOMICILIERING',
    maatschappijId: 'I-012',
    maatschappijNaam: 'P&V',
    maatschappijAgentnummer: '023456',
    maatschappijTelefoon: '02/505.22.22',
    partijen: [
      { id: 'P-2024-0001', naam: 'Peeters, Jan', rol: 'VERZEKERINGNEMER', type: 'NP', adres: 'Kerkstraat 12, 2800 Mechelen', telefoon: '0478/12.34.56' },
      { id: 'I-012', naam: 'P&V', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.22.22' },
    ],
    objecten: [
      { id: 'O-V-003', naam: 'Mercedes C-Klasse (oud)', type: 'Voertuig', identificatie: '1-ABC-234', waarde: '€ 30.000', status: 'Geschrapt' },
    ],
    versies: [
      { versie: 1, ingangsdatum: '2023-06-15', status: 'Beeindigd', premie: 1180, wijzigingDoor: 'Systeem', wijzigingDatum: '2024-06-15', reden: 'Contract vervangen door nieuw contract' },
    ],
    dekkingen: [
      { code: 'BA', omschrijving: 'Burgerlijke Aansprakelijkheid', limiet: '€ ∞', eigenRisico: '€ 0', inbegrepen: true },
      { code: 'OM', omschrijving: 'Omnium', limiet: '€ 30.000', eigenRisico: '€ 250', inbegrepen: true },
    ],
    documenten: [
      { id: 'D-010', naam: 'Polisdocument', type: 'PDF', datum: '2023-06-15' },
    ],
    resterendeDagen: 0,
    versie: 1,
    laatstBijgewerkt: '2024-06-15',
  },
  {
    id: 'C-009',
    contractnummer: 'POL-2024-001240',
    status: 'LOPEND',
    domein: 'AUTO',
    type: 'AUTO_MINI_OMNIUM',
    typeLabel: 'Auto Mini-Omnium',
    herkomst: 'ACQUISITIE',
    ingangsdatum: '2024-08-01',
    vervaldatum: '2025-08-01',
    opzegtermijn: '3 maanden',
    automatischeVerlenging: true,
    premie: 380,
    maandpremie: 31.67,
    provisiePct: 10,
    provisieBedrag: 38,
    periodiciteit: 'JAARLIJKS',
    incassoWijze: 'DOMICILIERING',
    maatschappijId: 'I-001',
    maatschappijNaam: 'Ethias',
    maatschappijAgentnummer: '012345',
    maatschappijTelefoon: '02/505.11.11',
    partijen: [
      { id: 'P-2024-0006', naam: 'Lucas Peeters', rol: 'VERZEKERINGNEMER', type: 'NP', adres: 'Diestsestraat 67, 3000 Leuven', telefoon: '0472/56.78.90' },
      { id: 'I-001', naam: 'Ethias', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.11.11' },
    ],
    objecten: [
      { id: 'O-V-004', naam: 'BMW R 1250 GS', type: 'Voertuig', identificatie: '3-MNO-789', waarde: '€ 18.500', status: 'Actief' },
    ],
    versies: [
      { versie: 1, ingangsdatum: '2024-08-01', status: 'Actief', premie: 380, wijzigingDoor: 'Systeem', wijzigingDatum: '2024-08-01' },
    ],
    dekkingen: [
      { code: 'BA', omschrijving: 'Burgerlijke Aansprakelijkheid', limiet: '€ ∞', eigenRisico: '€ 0', inbegrepen: true },
      { code: 'MO', omschrijving: 'Mini-Omnium (glas, brand, diefstal)', limiet: '€ 18.500', eigenRisico: '€ 250', inbegrepen: true },
    ],
    documenten: [
      { id: 'D-011', naam: 'Polisdocument', type: 'PDF', datum: '2024-08-01' },
    ],
    resterendeDagen: 226,
    versie: 1,
    laatstBijgewerkt: '2024-08-01',
  },
  {
    id: 'C-010',
    contractnummer: 'POL-2024-001241',
    status: 'LOPEND',
    domein: 'LEVEN_BELEGGINGEN',
    type: 'LEVEN_OVERLIJDEN',
    typeLabel: 'Leven Overlijden',
    herkomst: 'ACQUISITIE',
    ingangsdatum: '2024-01-01',
    vervaldatum: '2054-01-01',
    opzegtermijn: 'Geen',
    automatischeVerlenging: true,
    premie: 2400,
    maandpremie: 200,
    provisiePct: 8,
    provisieBedrag: 192,
    periodiciteit: 'MAANDELIJKS',
    incassoWijze: 'DOMICILIERING',
    maatschappijId: 'I-002',
    maatschappijNaam: 'AG Insurance',
    maatschappijAgentnummer: '067890',
    maatschappijTelefoon: '02/554.41.11',
    partijen: [
      { id: 'P-2024-0001', naam: 'Peeters, Jan', rol: 'VERZEKERINGNEMER', type: 'NP', adres: 'Kerkstraat 12, 2800 Mechelen', telefoon: '0478/12.34.56' },
      { id: 'P-2024-0002', naam: 'Dubois, Hilde', rol: 'BEGUNSTIGDE', type: 'NP' },
      { id: 'I-002', naam: 'AG Insurance', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/554.41.11' },
    ],
    objecten: [],
    versies: [
      { versie: 1, ingangsdatum: '2024-01-01', status: 'Actief', premie: 2400, wijzigingDoor: 'Systeem', wijzigingDatum: '2024-01-01' },
    ],
    dekkingen: [
      { code: 'OL', omschrijving: 'Overlijdensdekking', limiet: '€ 150.000', eigenRisico: '€ 0', inbegrepen: true },
      { code: 'WL', omschrijving: 'Wettelijke voorbescherming', limiet: '€ 10.000', eigenRisico: '€ 0', inbegrepen: true },
    ],
    documenten: [
      { id: 'D-012', naam: 'Polisdocument', type: 'PDF', datum: '2024-01-01' },
      { id: 'D-013', naam: 'Medische vragenlijst', type: 'PDF', datum: '2024-01-01' },
    ],
    resterendeDagen: 10950,
    versie: 1,
    laatstBijgewerkt: '2024-01-01',
  },
  {
    id: 'C-011',
    contractnummer: 'POL-2024-001242',
    status: 'IN_WIJZIGING',
    domein: 'AUTO',
    type: 'AUTO_LICHTE_VRACHTWAGENS',
    typeLabel: 'Auto Lichte Vracht',
    herkomst: 'ACQUISITIE',
    ingangsdatum: '2024-02-01',
    vervaldatum: '2025-02-01',
    opzegtermijn: '3 maanden',
    automatischeVerlenging: true,
    premie: 890,
    maandpremie: 74.17,
    provisiePct: 12,
    provisieBedrag: 106.8,
    periodiciteit: 'JAARLIJKS',
    incassoWijze: 'DOMICILIERING',
    maatschappijId: 'I-003',
    maatschappijNaam: 'AXA Belgium',
    maatschappijAgentnummer: '034567',
    maatschappijTelefoon: '02/505.33.33',
    partijen: [
      { id: 'P-2024-0010', naam: 'NV Verzekerd Goed', rol: 'VERZEKERINGNEMER', type: 'RP', adres: 'Louizalaan 120, 1050 Brussel', telefoon: '02/234.56.78' },
      { id: 'P-2024-0008', naam: 'Thomas Peeters', rol: 'VERZEKERDE', type: 'NP', telefoon: '0474/78.90.12' },
      { id: 'I-003', naam: 'AXA Belgium', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.33.33' },
    ],
    objecten: [
      { id: 'O-V-005', naam: 'Mercedes Sprinter 316', type: 'Voertuig', identificatie: '1-VVV-999', waarde: '€ 42.000', status: 'Actief' },
    ],
    versies: [
      { versie: 2, ingangsdatum: '2024-11-15', status: 'Actief', premie: 890, wijzigingDoor: 'Marie Dubois', wijzigingDatum: '2024-11-15', reden: 'Bestuurder gewijzigd' },
      { versie: 1, ingangsdatum: '2024-02-01', status: 'Vervangen', premie: 890, wijzigingDoor: 'Systeem', wijzigingDatum: '2024-02-01' },
    ],
    dekkingen: [
      { code: 'BA', omschrijving: 'Burgerlijke Aansprakelijkheid', limiet: '€ ∞', eigenRisico: '€ 0', inbegrepen: true },
      { code: 'MO', omschrijving: 'Mini-Omnium', limiet: '€ 42.000', eigenRisico: '€ 500', inbegrepen: true },
      { code: 'GO', omschrijving: 'Goederenvervoer', limiet: '€ 25.000', eigenRisico: '€ 250', inbegrepen: true },
    ],
    documenten: [
      { id: 'D-014', naam: 'Polisdocument', type: 'PDF', datum: '2024-02-01' },
    ],
    resterendeDagen: 45,
    versie: 2,
    laatstBijgewerkt: '2024-11-15',
  },
  {
    id: 'C-012',
    contractnummer: 'POL-2024-001243',
    status: 'LOPEND',
    domein: 'HOSPITALISATIE',
    type: 'HOSPITALISATIE_INDIVIDUEEL',
    typeLabel: 'Hospitalisatie Individueel',
    herkomst: 'ACQUISITIE',
    ingangsdatum: '2024-04-01',
    vervaldatum: '2025-04-01',
    opzegtermijn: '1 jaar',
    automatischeVerlenging: true,
    premie: 1850,
    maandpremie: 154.17,
    provisiePct: 10,
    provisieBedrag: 185,
    periodiciteit: 'JAARLIJKS',
    incassoWijze: 'DOMICILIERING',
    maatschappijId: 'I-011',
    maatschappijNaam: 'DKV Belgium',
    maatschappijAgentnummer: '112233',
    maatschappijTelefoon: '03/222.51.11',
    partijen: [
      { id: 'P-2024-0002', naam: 'Dubois, Marie', rol: 'VERZEKERINGNEMER', type: 'NP', adres: 'Rue du Marche 45, 3000 Leuven', telefoon: '0479/23.45.67' },
      { id: 'P-2024-0009', naam: 'Dubois, Lucas', rol: 'MEDEVERZEKERDE', type: 'NP' },
      { id: 'I-011', naam: 'DKV Belgium', rol: 'VERZEKERAAR', type: 'VM', telefoon: '03/222.51.11' },
    ],
    objecten: [],
    versies: [
      { versie: 1, ingangsdatum: '2024-04-01', status: 'Actief', premie: 1850, wijzigingDoor: 'Systeem', wijzigingDatum: '2024-04-01' },
    ],
    dekkingen: [
      { code: 'HOS', omschrijving: 'Hospitalisatie (1-persoonskamer)', limiet: 'Onbeperkt', eigenRisico: '€ 0', inbegrepen: true },
      { code: 'ZTO', omschrijving: 'Ziektekostenovername', limiet: '€ 500.000', eigenRisico: '€ 0', inbegrepen: true },
      { code: 'DEN', omschrijving: 'Tandheelkunde', limiet: '€ 2.500/jaar', eigenRisico: '€ 25', inbegrepen: true },
      { code: 'AMB', omschrijving: 'Ambulante kosten', limiet: '€ 10.000/jaar', eigenRisico: '€ 0', inbegrepen: true },
    ],
    documenten: [
      { id: 'D-015', naam: 'Polisdocument', type: 'PDF', datum: '2024-04-01' },
      { id: 'D-016', naam: 'Medische vragenlijst', type: 'PDF', datum: '2024-04-01' },
    ],
    resterendeDagen: 105,
    versie: 1,
    laatstBijgewerkt: '2024-04-01',
  },
  {
    id: 'C-013',
    contractnummer: 'POL-2024-001244',
    status: 'GESCHORST',
    domein: 'ARBEIDSONGEVALLEN_COLLECTIEF',
    type: 'ARBEIDSONGEVAL',
    typeLabel: 'Arbeidsongeval Collectief',
    herkomst: 'ACQUISITIE',
    ingangsdatum: '2024-01-01',
    vervaldatum: '2025-01-01',
    opzegtermijn: '3 maanden',
    automatischeVerlenging: true,
    premie: 650,
    maandpremie: 54.17,
    provisiePct: 10,
    provisieBedrag: 65,
    periodiciteit: 'JAARLIJKS',
    incassoWijze: 'DOMICILIERING',
    maatschappijId: 'I-007',
    maatschappijNaam: 'Axa Belgium',
    maatschappijAgentnummer: '089012',
    maatschappijTelefoon: '02/550.21.11',
    partijen: [
      { id: 'P-2024-0010', naam: 'NV Verzekerd Goed', rol: 'VERZEKERINGNEMER', type: 'RP', adres: 'Louizalaan 120, 1050 Brussel', telefoon: '02/234.56.78' },
      { id: 'P-2024-0004', naam: 'BVBA De Boer', rol: 'MEDEVERZEKERDE', type: 'RP', telefoon: '03/123.45.67' },
      { id: 'I-007', naam: 'Axa Belgium', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/550.21.11' },
    ],
    objecten: [],
    versies: [
      { versie: 2, ingangsdatum: '2024-10-01', status: 'Actief', premie: 650, wijzigingDoor: 'Systeem', wijzigingDatum: '2024-10-01', reden: 'Geschorst wegens niet-betaling' },
      { versie: 1, ingangsdatum: '2024-01-01', status: 'Vervangen', premie: 650, wijzigingDoor: 'Systeem', wijzigingDatum: '2024-01-01' },
    ],
    dekkingen: [
      { code: 'AO', omschrijving: 'Arbeidsongeval (alle werknemers)', limiet: 'Onbeperkt', eigenRisico: '€ 0', inbegrepen: true },
      { code: 'WGA', omschrijving: 'WGA-aanvulling', limiet: '€ 50.000/jaar', eigenRisico: '€ 0', inbegrepen: true },
    ],
    documenten: [
      { id: 'D-017', naam: 'Polisdocument', type: 'PDF', datum: '2024-01-01' },
    ],
    resterendeDagen: 15,
    versie: 2,
    laatstBijgewerkt: '2024-10-01',
  },
  {
    id: 'C-014',
    contractnummer: 'POL-2024-001245',
    status: 'LOPEND',
    domein: 'AUTO',
    type: 'AUTO_BROMFIETSEN',
    typeLabel: 'Auto Bromfietsen',
    herkomst: 'ACQUISITIE',
    ingangsdatum: '2024-05-01',
    vervaldatum: '2025-05-01',
    opzegtermijn: '3 maanden',
    automatischeVerlenging: true,
    premie: 195,
    maandpremie: 16.25,
    provisiePct: 10,
    provisieBedrag: 19.5,
    periodiciteit: 'JAARLIJKS',
    incassoWijze: 'DOMICILIERING',
    maatschappijId: 'I-001',
    maatschappijNaam: 'Ethias',
    maatschappijAgentnummer: '012345',
    maatschappijTelefoon: '02/505.11.11',
    partijen: [
      { id: 'P-2024-0015', naam: 'Claes, Sofie', rol: 'VERZEKERINGNEMER', type: 'NP', adres: 'Bosstraat 21, 3500 Hasselt', telefoon: '0483/34.56.78' },
      { id: 'I-001', naam: 'Ethias', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.11.11' },
    ],
    objecten: [
      { id: 'O-V-006', naam: 'Vespa Primavera 125', type: 'Voertuig', identificatie: '4-BROM-001', waarde: '€ 3.200', status: 'Actief' },
    ],
    versies: [
      { versie: 1, ingangsdatum: '2024-05-01', status: 'Actief', premie: 195, wijzigingDoor: 'Systeem', wijzigingDatum: '2024-05-01' },
    ],
    dekkingen: [
      { code: 'BA', omschrijving: 'Burgerlijke Aansprakelijkheid', limiet: '€ ∞', eigenRisico: '€ 0', inbegrepen: true },
      { code: 'OM', omschrijving: 'Omnium', limiet: '€ 3.200', eigenRisico: '€ 100', inbegrepen: true },
    ],
    documenten: [
      { id: 'D-018', naam: 'Polisdocument', type: 'PDF', datum: '2024-05-01' },
    ],
    resterendeDagen: 135,
    versie: 1,
    laatstBijgewerkt: '2024-05-01',
  },
  {
    id: 'C-015',
    contractnummer: 'POL-2024-001246',
    status: 'LOPEND',
    domein: 'BRAND_EENVOUDIG',
    type: 'WOON_VERZEKERING',
    typeLabel: 'Woningverzekering',
    herkomst: 'OVERNAME',
    ingangsdatum: '2024-11-01',
    vervaldatum: '2025-11-01',
    opzegtermijn: '3 maanden',
    automatischeVerlenging: true,
    premie: 650,
    maandpremie: 54.17,
    provisiePct: 12,
    provisieBedrag: 78,
    periodiciteit: 'JAARLIJKS',
    incassoWijze: 'DOMICILIERING',
    maatschappijId: 'I-006',
    maatschappijNaam: 'Federale Verzekering',
    maatschappijAgentnummer: '090123',
    maatschappijTelefoon: '09/269.91.11',
    partijen: [
      { id: 'P-2024-0011', naam: 'Maes, Koen', rol: 'VERZEKERINGNEMER', type: 'NP', adres: 'Steenweg op Brussels 56, 1700 Dilbeek', telefoon: '0484/01.23.45' },
      { id: 'P-2024-0012', naam: 'De Smet, Liesbeth', rol: 'MEDEVERZEKERDE', type: 'NP', telefoon: '0477/12.34.56' },
      { id: 'I-006', naam: 'Federale Verzekering', rol: 'VERZEKERAAR', type: 'VM', telefoon: '09/269.91.11' },
    ],
    objecten: [
      { id: 'O-R-004', naam: 'Appartement - Steenweg op Brussels 56', type: 'Onroerend goed', identificatie: '1700 Dilbeek', waarde: '€ 210.000', status: 'Actief' },
    ],
    versies: [
      { versie: 1, ingangsdatum: '2024-11-01', status: 'Actief', premie: 650, wijzigingDoor: 'Systeem', wijzigingDatum: '2024-11-01', reden: 'Overname van kantoor Janssens' },
    ],
    dekkingen: [
      { code: 'BWG', omschrijving: 'Brand Woning', limiet: '€ 210.000', eigenRisico: '€ 250', inbegrepen: true },
      { code: 'INB', omschrijving: 'Inboedel', limiet: '€ 50.000', eigenRisico: '€ 125', inbegrepen: true },
      { code: 'BOE', omschrijving: 'Burgerlijke Aansprakelijkheid', limiet: '€ 5.000.000', eigenRisico: '€ 0', inbegrepen: true },
    ],
    documenten: [
      { id: 'D-019', naam: 'Polisdocument', type: 'PDF', datum: '2024-11-01' },
      { id: 'D-020', naam: 'Overnameakte', type: 'PDF', datum: '2024-11-01' },
    ],
    resterendeDagen: 319,
    versie: 1,
    laatstBijgewerkt: '2024-11-01',
  },
  {
    id: 'C-016',
    contractnummer: 'POL-2024-001247',
    status: 'LOPEND',
    domein: 'DIVER',
    type: 'RECHTSBIJSTAND',
    typeLabel: 'Rechtsbijstand',
    herkomst: 'ACQUISITIE',
    ingangsdatum: '2024-03-15',
    vervaldatum: '2025-03-15',
    opzegtermijn: '3 maanden',
    automatischeVerlenging: true,
    premie: 145,
    maandpremie: 12.08,
    provisiePct: 12,
    provisieBedrag: 17.4,
    periodiciteit: 'JAARLIJKS',
    incassoWijze: 'OVERSCHRIJVING',
    maatschappijId: 'I-010',
    maatschappijNaam: 'Vivium',
    maatschappijAgentnummer: '101112',
    maatschappijTelefoon: '03/222.51.11',
    partijen: [
      { id: 'P-2024-0013', naam: 'CVBA Wonen Plus', rol: 'VERZEKERINGNEMER', type: 'RP', adres: 'Sint-Pietersnieuwstraat 77, 9000 Gent', telefoon: '09/345.67.89' },
      { id: 'I-010', naam: 'Vivium', rol: 'VERZEKERAAR', type: 'VM', telefoon: '03/222.51.11' },
    ],
    objecten: [],
    versies: [
      { versie: 1, ingangsdatum: '2024-03-15', status: 'Actief', premie: 145, wijzigingDoor: 'Systeem', wijzigingDatum: '2024-03-15' },
    ],
    dekkingen: [
      { code: 'RB-B', omschrijving: 'Rechtsbijstand Bedrijf', limiet: '€ 50.000', eigenRisico: '€ 250', inbegrepen: true },
    ],
    documenten: [
      { id: 'D-021', naam: 'Polisdocument', type: 'PDF', datum: '2024-03-15' },
    ],
    resterendeDagen: 88,
    versie: 1,
    laatstBijgewerkt: '2024-03-15',
  },
  {
    id: 'C-017',
    contractnummer: 'POL-2024-001248',
    status: 'LOPEND',
    domein: 'AUTO',
    type: 'AUTO_TOERISME',
    typeLabel: 'Auto Toerisme',
    herkomst: 'VERLENGING',
    ingangsdatum: '2024-12-01',
    vervaldatum: '2025-12-01',
    opzegtermijn: '3 maanden',
    automatischeVerlenging: true,
    premie: 1680,
    maandpremie: 140,
    provisiePct: 15,
    provisieBedrag: 252,
    periodiciteit: 'JAARLIJKS',
    incassoWijze: 'DOMICILIERING',
    maatschappijId: 'I-001',
    maatschappijNaam: 'Ethias',
    maatschappijAgentnummer: '012345',
    maatschappijTelefoon: '02/505.11.11',
    partijen: [
      { id: 'P-2024-0008', naam: 'Peeters, Thomas', rol: 'VERZEKERINGNEMER', type: 'NP', adres: 'Leuvensestraat 19, 2800 Mechelen', telefoon: '0474/78.90.12' },
      { id: 'P-2024-0017', naam: 'Bosmans, Nathalie', rol: 'MEDEVERZEKERDE', type: 'NP', telefoon: '0471/56.78.90' },
      { id: 'I-001', naam: 'Ethias', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.11.11' },
    ],
    objecten: [
      { id: 'O-V-007', naam: 'Audi A4 Avant', type: 'Voertuig', identificatie: '5-AUDI-444', waarde: '€ 38.500', status: 'Actief' },
    ],
    versies: [
      { versie: 2, ingangsdatum: '2024-12-01', status: 'Actief', premie: 1680, wijzigingDoor: 'Systeem', wijzigingDatum: '2024-12-01', reden: 'Automatische verlenging' },
      { versie: 1, ingangsdatum: '2023-12-01', status: 'Vervangen', premie: 1620, wijzigingDoor: 'Systeem', wijzigingDatum: '2023-12-01' },
    ],
    dekkingen: [
      { code: 'BA', omschrijving: 'Burgerlijke Aansprakelijkheid', limiet: '€ ∞', eigenRisico: '€ 0', inbegrepen: true },
      { code: 'OM', omschrijving: 'Omnium Plus', limiet: '€ 38.500', eigenRisico: '€ 250', inbegrepen: true },
      { code: 'RB', omschrijving: 'Rechtsbijstand', limiet: undefined, eigenRisico: '€ 0', inbegrepen: true },
      { code: 'BV', omschrijving: 'Bergerging', limiet: undefined, eigenRisico: '€ 0', inbegrepen: true },
    ],
    documenten: [
      { id: 'D-022', naam: 'Polisdocument', type: 'PDF', datum: '2024-12-01' },
    ],
    resterendeDagen: 349,
    versie: 2,
    laatstBijgewerkt: '2024-12-01',
  },
  {
    id: 'C-018',
    contractnummer: 'POL-2024-001249',
    status: 'LOPEND',
    domein: 'BRAND_BIJZONDERE',
    type: 'BRAND_BEDRIJF',
    typeLabel: 'Brand Bedrijf',
    herkomst: 'ACQUISITIE',
    ingangsdatum: '2024-07-15',
    vervaldatum: '2025-07-15',
    opzegtermijn: '3 maanden',
    automatischeVerlenging: true,
    premie: 4200,
    maandpremie: 350,
    provisiePct: 15,
    provisieBedrag: 630,
    periodiciteit: 'MAANDELIJKS',
    incassoWijze: 'DOMICILIERING',
    maatschappijId: 'I-004',
    maatschappijNaam: 'Baloise',
    maatschappijAgentnummer: '045678',
    maatschappijTelefoon: '02/505.44.44',
    partijen: [
      { id: 'P-2024-0018', naam: 'BV AutoVloot Beheer', rol: 'VERZEKERINGNEMER', type: 'RP', adres: 'Noorderlaan 150, 2030 Antwerpen', telefoon: '03/456.78.90' },
      { id: 'I-004', naam: 'Baloise', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.44.44' },
    ],
    objecten: [
      { id: 'O-R-005', naam: 'Kantoorgebouw - Noorderlaan 150', type: 'Onroerend goed', identificatie: '2030 Antwerpen', waarde: '€ 1.250.000', status: 'Actief' },
    ],
    versies: [
      { versie: 1, ingangsdatum: '2024-07-15', status: 'Actief', premie: 4200, wijzigingDoor: 'Systeem', wijzigingDatum: '2024-07-15' },
    ],
    dekkingen: [
      { code: 'BB', omschrijving: 'Brand Bedrijf', limiet: '€ 1.250.000', eigenRisico: '€ 1.000', inbegrepen: true },
      { code: 'INB', omschrijving: 'Inboedel', limiet: '€ 250.000', eigenRisico: '€ 500', inbegrepen: true },
      { code: 'BA-B', omschrijving: 'BA Bedrijf', limiet: '€ 10.000.000', eigenRisico: '€ 0', inbegrepen: true },
      { code: 'OAU', omschrijving: 'Ongevallen werknemers', limiet: '€ 100.000', eigenRisico: '€ 0', inbegrepen: true },
    ],
    documenten: [
      { id: 'D-023', naam: 'Polisdocument', type: 'PDF', datum: '2024-07-15' },
      { id: 'D-024', naam: 'Clausules', type: 'PDF', datum: '2024-07-15' },
    ],
    resterendeDagen: 209,
    versie: 1,
    laatstBijgewerkt: '2024-07-15',
  },
  {
    id: 'C-019',
    contractnummer: 'POL-2024-001250',
    status: 'LOPEND',
    domein: 'LEVEN_BELEGGINGEN',
    type: 'LEVEN_OVERLIJDEN',
    typeLabel: 'Leven Overlijden',
    herkomst: 'ACQUISITIE',
    ingangsdatum: '2024-02-01',
    vervaldatum: '2054-02-01',
    opzegtermijn: 'Geen',
    automatischeVerlenging: true,
    premie: 3600,
    maandpremie: 300,
    provisiePct: 8,
    provisieBedrag: 288,
    periodiciteit: 'MAANDELIJKS',
    incassoWijze: 'DOMICILIERING',
    maatschappijId: 'I-002',
    maatschappijNaam: 'AG Insurance',
    maatschappijAgentnummer: '067890',
    maatschappijTelefoon: '02/554.41.11',
    partijen: [
      { id: 'P-2024-0003', naam: 'Janssens, Pieter', rol: 'VERZEKERINGNEMER', type: 'NP', adres: 'Stationsstraat 8, 3500 Hasselt', telefoon: '0480/34.56.78' },
      { id: 'P-2024-0004', naam: 'Janssens, Ann', rol: 'BEGUNSTIGDE', type: 'NP' },
      { id: 'I-002', naam: 'AG Insurance', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/554.41.11' },
    ],
    objecten: [],
    versies: [
      { versie: 1, ingangsdatum: '2024-02-01', status: 'Actief', premie: 3600, wijzigingDoor: 'Systeem', wijzigingDatum: '2024-02-01' },
    ],
    dekkingen: [
      { code: 'OL', omschrijving: 'Overlijdensdekking', limiet: '€ 200.000', eigenRisico: '€ 0', inbegrepen: true },
      { code: 'EX', omschrijving: 'Uitkeringszekerheid', limiet: '€ 5.000/jaar', eigenRisico: '€ 0', inbegrepen: true },
    ],
    documenten: [
      { id: 'D-025', naam: 'Polisdocument', type: 'PDF', datum: '2024-02-01' },
      { id: 'D-026', naam: 'Medische vragenlijst', type: 'PDF', datum: '2024-02-01' },
    ],
    resterendeDagen: 10980,
    versie: 1,
    laatstBijgewerkt: '2024-02-01',
  },
  {
    id: 'C-020',
    contractnummer: 'POL-2024-001251',
    status: 'IN_WIJZIGING',
    domein: 'HOSPITALISATIE',
    type: 'HOSPITALISATIE_GROEP',
    typeLabel: 'Hospitalisatie Groep',
    herkomst: 'ACQUISITIE',
    ingangsdatum: '2024-06-01',
    vervaldatum: '2025-06-01',
    opzegtermijn: '1 jaar',
    automatischeVerlenging: true,
    premie: 4800,
    maandpremie: 400,
    provisiePct: 10,
    provisieBedrag: 480,
    periodiciteit: 'MAANDELIJKS',
    incassoWijze: 'INCASSO',
    maatschappijId: 'I-011',
    maatschappijNaam: 'DKV Belgium',
    maatschappijAgentnummer: '112233',
    maatschappijTelefoon: '03/222.51.11',
    partijen: [
      { id: 'P-2024-0010', naam: 'NV Verzekerd Goed', rol: 'VERZEKERINGNEMER', type: 'RP', adres: 'Louizalaan 120, 1050 Brussel', telefoon: '02/234.56.78' },
      { id: 'P-2024-0004', naam: 'BVBA De Boer', rol: 'MEDEVERZEKERDE', type: 'RP', telefoon: '03/123.45.67' },
      { id: 'P-2024-0016', naam: 'Verhoeven, Dirk', rol: 'MEDEVERZEKERDE', type: 'NP', telefoon: '0470/45.67.89' },
      { id: 'I-011', naam: 'DKV Belgium', rol: 'VERZEKERAAR', type: 'VM', telefoon: '03/222.51.11' },
    ],
    objecten: [],
    versies: [
      { versie: 2, ingangsdatum: '2024-12-10', status: 'Actief', premie: 4800, wijzigingDoor: 'Marie Dubois', wijzigingDatum: '2024-12-10', reden: 'Werknemer toegevoegd' },
      { versie: 1, ingangsdatum: '2024-06-01', status: 'Vervangen', premie: 3600, wijzigingDoor: 'Systeem', wijzigingDatum: '2024-06-01' },
    ],
    dekkingen: [
      { code: 'HOS', omschrijving: 'Hospitalisatie (2-persoonskamer)', limiet: 'Onbeperkt', eigenRisico: '€ 0', inbegrepen: true },
      { code: 'ZTO', omschrijving: 'Ziektekostenovername', limiet: '€ 750.000', eigenRisico: '€ 0', inbegrepen: true },
      { code: 'DEN', omschrijving: 'Tandheelkunde', limiet: '€ 1.500/jaar', eigenRisico: '€ 0', inbegrepen: true },
    ],
    documenten: [
      { id: 'D-027', naam: 'Polisdocument', type: 'PDF', datum: '2024-06-01' },
    ],
    resterendeDagen: 165,
    versie: 2,
    laatstBijgewerkt: '2024-12-10',
  },
]

// Domain label mapping
export const domeinLabelMap: Record<ContractDomein, string> = {
  AUTO: 'Auto',
  BRAND_EENVOUDIG: 'Brand Eenvoudig',
  BRAND_BIJZONDERE: 'Brand Bijzondere',
  LEVEN_BELEGGINGEN: 'Leven',
  HOSPITALISATIE: 'Hospitalisatie',
  ARBEIDSONGEVALLEN_COLLECTIEF: 'Arbeidsongeval',
  DIVER: 'Diverse',
}

// Type label helper
export function getTypeLabel(type: ContractType): string {
  const map: Record<string, string> = {
    AUTO_TOERISME: 'Auto Toerisme',
    AUTO_BROMFIETSEN: 'Auto Bromfietsen',
    AUTO_LICHTE_VRACHTWAGENS: 'Auto Lichte Vracht',
    AUTO_OMNIUM: 'Auto Omnium',
    AUTO_BA: 'Auto BA',
    AUTO_MINI_OMNIUM: 'Auto Mini-Omnium',
    WOON_VERZEKERING: 'Woning',
    BRAND_BEDRIJF: 'Brand Bedrijf',
    LEVEN_OVERLIJDEN: 'Leven Overlijden',
    HOSPITALISATIE_INDIVIDUEEL: 'Hospitalisatie',
    HOSPITALISATIE_GROEP: 'Hosp. Groep',
    RECHTSBIJSTAND: 'Rechtsbijstand',
    BA_PRIVAAT: 'BA Privaat',
    ARBEIDSONGEVAL: 'Arbeidsongeval',
  }
  return map[type] || type
}

// Periodiciteit label
export function getPeriodiciteitLabel(p: Periodiciteit): string {
  const map: Record<Periodiciteit, string> = {
    JAARLIJKS: 'Jaarlijks',
    MAANDELIJKS: 'Maandelijks',
    DRIEMAANDELIKS: 'Driemaandelijks',
    HALFJAARLIJKS: 'Halfjaarlijks',
    EENMALIG: 'Eenmalig',
  }
  return map[p]
}

// Incasso label
export function getIncassoLabel(i: IncassoWijze): string {
  const map: Record<IncassoWijze, string> = {
    DOMICILIERING: 'Domiciliering',
    KREDIETKAART: 'Kredietkaart',
    OVERSCHRIJVING: 'Overschrijving',
    INCASSO: 'Incasso',
  }
  return map[i]
}
