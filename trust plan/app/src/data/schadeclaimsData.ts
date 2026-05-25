export type ClaimStatus = 'OPENSTAAND' | 'IN_BEHANDELING' | 'AFGEHANDELD' | 'AFGEKEURD'

export type IncidentType =
  | 'AANRIJDING'
  | 'DIEFSTAL'
  | 'BRANDSCHADE'
  | 'WATERSCHADE'
  | 'GLASBRUK'
  | 'STORMSCHADE'
  | 'PARKEERSCHADE'
  | 'STEENSCHADE'
  | 'ACHTERAANRIJDING'
  | 'TOTAL LOSS'
  | 'ARBEIDSONGEVAL'
  | 'RECHTSBIJSTAND'
  | 'HOSPITALISATIE'
  | 'BURGERLIJKE_AANSPRAKELIJKHEID'

export interface SchadeClaim {
  id: string
  claimnummer: string
  contractnummer: string
  status: ClaimStatus
  incidentType: IncidentType
  typeLabel: string
  beschrijving: string
  datumIncident: string
  datumMelding: string
  uitbetaald: number
  eigenRisico: number
  verzekerdeNaam: string
  behandelaar: string
  expert?: string
  dagenOpen: number
  locatie?: string
  prioriteit: 'LAAG' | 'NORMAAL' | 'HOOG' | 'DRINGEND'
}

export interface ClaimPartij {
  id: string
  naam: string
  rol: 'AANSPRAKELIJKE' | 'VERZEKERDE' | 'EXPERT' | 'DERDE' | 'VERZEKERAAR' | 'GETUIGE'
  type: 'NP' | 'RP' | 'VM' | 'EB'
  telefoon?: string
}

export interface ClaimObject {
  id: string
  naam: string
  type: string
  identificatie: string
  schadeBedrag: number
  status: 'In herstel' | 'Totaal loss' | 'Hersteld' | 'In onderzoek'
}

export interface OpvolgingItem {
  datum: string
  gebruiker: string
  activiteit: string
  statusWijziging?: string
}

export interface ClaimDocument {
  id: string
  naam: string
  type: 'PDF' | 'IMG' | 'DOC'
  datum: string
}

export interface ClaimDetail {
  id: string
  claimnummer: string
  status: ClaimStatus
  incidentType: IncidentType
  typeLabel: string
  beschrijving: string
  datumIncident: string
  datumMelding: string
  melder: string
  prioriteit: 'LAAG' | 'NORMAAL' | 'HOOG' | 'DRINGEND'
  contractnummer: string
  verzekerdeNaam: string
  maatschappijNaam: string
  typeDekking: string
  geschatBedrag: number
  goedgekeurdBedrag: number
  eigenRisico: number
  uitbetaald: number
  restant: number
  expertNaam?: string
  expertContact?: string
  expertDatumAanstelling?: string
  expertRapportVerwacht?: string
  dagenOpen: number
  gemDoorlooptijd: number
  verwachteAfhandeling: number
  locatie?: string
  tijd?: string
  weersomstandigheden?: string
  politieAangifte: boolean
  politiePVNummer?: string
  tegenpartij?: string
  getuigen: string
  partijen: ClaimPartij[]
  objecten: ClaimObject[]
  opvolging: OpvolgingItem[]
  documenten: ClaimDocument[]
}

export const statusBadgeMap: Record<ClaimStatus, { variant: 'active' | 'warning' | 'error' | 'info' | 'neutral'; label: string }> = {
  OPENSTAAND: { variant: 'warning', label: 'Openstaand' },
  IN_BEHANDELING: { variant: 'info', label: 'In Behandeling' },
  AFGEHANDELD: { variant: 'active', label: 'Afgehandeld' },
  AFGEKEURD: { variant: 'error', label: 'Afgekeurd' },
}

export function formatCurrency(value: number): string {
  return new Intl.NumberFormat('nl-BE', {
    style: 'currency',
    currency: 'EUR',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(value)
}

export function formatDate(dateStr: string): string {
  if (!dateStr) return '-'
  const d = new Date(dateStr)
  if (isNaN(d.getTime())) return dateStr
  return d.toLocaleDateString('nl-BE', { day: '2-digit', month: '2-digit', year: 'numeric' })
}

export function daysBetween(start: string, end?: string): number {
  const s = new Date(start)
  const e = end ? new Date(end) : new Date()
  const diff = e.getTime() - s.getTime()
  return Math.floor(diff / (1000 * 60 * 60 * 24))
}

export const typeIconMap: Record<IncidentType, { icon: string; color: string }> = {
  AANRIJDING: { icon: 'car', color: '#C04A4A' },
  DIEFSTAL: { icon: 'theft', color: '#D4942A' },
  BRANDSCHADE: { icon: 'flame', color: '#C07A4A' },
  WATERSCHADE: { icon: 'droplets', color: '#3B6EA5' },
  GLASBRUK: { icon: 'glass', color: '#5B8DB8' },
  STORMSCHADE: { icon: 'storm', color: '#8B5E83' },
  PARKEERSCHADE: { icon: 'car', color: '#6B7785' },
  STEENSCHADE: { icon: 'glass', color: '#5B8DB8' },
  ACHTERAANRIJDING: { icon: 'car', color: '#C04A4A' },
  'TOTAL LOSS': { icon: 'car', color: '#1A1F24' },
  ARBEIDSONGEVAL: { icon: 'worker', color: '#D4942A' },
  RECHTSBIJSTAND: { icon: 'scale', color: '#3B6EA5' },
  HOSPITALISATIE: { icon: 'hospital', color: '#4A804A' },
  BURGERLIJKE_AANSPRAKELIJKHEID: { icon: 'shield', color: '#6B7785' },
}

// ====== 20 Claim Detail Records ======
export const claimDetails: ClaimDetail[] = [
  {
    id: 'CL-001',
    claimnummer: 'SCH-2024-005678',
    status: 'IN_BEHANDELING',
    incidentType: 'AANRIJDING',
    typeLabel: 'Aanrijding',
    beschrijving: 'Verzekerde reed op de E19 richting Brussel ter hoogte van Mechelen. Door plots remmen van voorganger kon verzekerde niet tijdig stoppen. Frontale aanrijding achteraan op voorganger. Politie ter plaatse, PV opgemaakt. Geen letsel.',
    datumIncident: '2024-10-15',
    datumMelding: '2024-10-16',
    melder: 'Jan Peeters',
    prioriteit: 'NORMAAL',
    contractnummer: 'POL-2024-001234',
    verzekerdeNaam: 'Jan Peeters',
    maatschappijNaam: 'Ethias',
    typeDekking: 'Auto Omnium',
    geschatBedrag: 4200,
    goedgekeurdBedrag: 4200,
    eigenRisico: 250,
    uitbetaald: 0,
    restant: 3950,
    expertNaam: 'De Vries Expertise BV',
    expertContact: '03/234.56.78',
    expertDatumAanstelling: '2024-10-18',
    expertRapportVerwacht: '2024-11-05',
    dagenOpen: 65,
    gemDoorlooptijd: 18,
    verwachteAfhandeling: -47,
    locatie: 'E19, km 25.3, 2800 Mechelen',
    tijd: '14:30',
    weersomstandigheden: 'Droog, daglicht',
    politieAangifte: true,
    politiePVNummer: '2024-MECH-11234',
    tegenpartij: 'Nog niet gekend',
    getuigen: 'Geen',
    partijen: [
      { id: 'P-001', naam: 'Peeters, Jan', rol: 'VERZEKERDE', type: 'NP', telefoon: '0478/12.34.56' },
      { id: 'U-001', naam: 'Onbekend', rol: 'DERDE', type: 'NP' },
      { id: 'E-001', naam: 'De Vries Expertise BV', rol: 'EXPERT', type: 'EB', telefoon: '03/234.56.78' },
      { id: 'I-001', naam: 'Ethias', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.11.11' },
    ],
    objecten: [
      { id: 'O-001', naam: 'Mercedes C-Klasse Break', type: 'Voertuig', identificatie: '1-ABC-234', schadeBedrag: 4200, status: 'In herstel' },
    ],
    opvolging: [
      { datum: '2024-10-16 16:00', gebruiker: 'Jan Peeters', activiteit: 'Claim aangemeld via telefoon', statusWijziging: 'Nieuw → Openstaand' },
      { datum: '2024-10-16 16:30', gebruiker: 'Marie Dubois', activiteit: 'Schadedossier aangemaakt', statusWijziging: undefined },
      { datum: '2024-10-18 10:00', gebruiker: 'Marie Dubois', activiteit: 'Expert De Vries aangesteld', statusWijziging: '→ In Behandeling' },
      { datum: '2024-10-20 09:00', gebruiker: 'De Vries Expert', activiteit: 'Expertisebezoek gepland 25/10', statusWijziging: undefined },
      { datum: '2024-10-22 14:00', gebruiker: 'Marie Dubois', activiteit: 'Hersteller AutoFix gecontacteerd', statusWijziging: undefined },
    ],
    documenten: [
      { id: 'D-001', naam: 'Schadeaangifte', type: 'PDF', datum: '2024-10-16' },
      { id: 'D-002', naam: 'Offerte herstelling', type: 'PDF', datum: '2024-10-25' },
      { id: 'D-003', naam: 'PV Politie', type: 'PDF', datum: '2024-10-16' },
    ],
  },
  {
    id: 'CL-002',
    claimnummer: 'SCH-2024-005679',
    status: 'OPENSTAAND',
    incidentType: 'DIEFSTAL',
    typeLabel: 'Diefstal',
    beschrijving: 'Navigatiesysteem gestolen uit voertuig tijdens nacht. Voertuig stond geparkeerd op openbare parking. Geen braakschade zichtbaar. Aangifte bij politie gedaan.',
    datumIncident: '2024-09-20',
    datumMelding: '2024-09-21',
    melder: 'Lucas Peeters',
    prioriteit: 'HOOG',
    contractnummer: 'POL-2024-001240',
    verzekerdeNaam: 'Lucas Peeters',
    maatschappijNaam: 'Ethias',
    typeDekking: 'Auto Mini-Omnium',
    geschatBedrag: 850,
    goedgekeurdBedrag: 0,
    eigenRisico: 250,
    uitbetaald: 0,
    restant: 600,
    dagenOpen: 90,
    gemDoorlooptijd: 18,
    verwachteAfhandeling: -72,
    locatie: 'Parking Grote Markt, 3000 Leuven',
    tijd: 'Nacht',
    weersomstandigheden: 'Droog',
    politieAangifte: true,
    politiePVNummer: '2024-LEUV-09321',
    tegenpartij: 'Onbekend',
    getuigen: 'Geen',
    partijen: [
      { id: 'P-006', naam: 'Lucas Peeters', rol: 'VERZEKERDE', type: 'NP', telefoon: '0472/56.78.90' },
      { id: 'I-001', naam: 'Ethias', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.11.11' },
    ],
    objecten: [
      { id: 'O-004', naam: 'BMW R 1250 GS', type: 'Voertuig', identificatie: '3-MNO-789', schadeBedrag: 850, status: 'In onderzoek' },
    ],
    opvolging: [
      { datum: '2024-09-21 09:00', gebruiker: 'Lucas Peeters', activiteit: 'Claim aangemeld via app', statusWijziging: '→ Openstaand' },
      { datum: '2024-09-21 10:30', gebruiker: 'Systeem', activiteit: 'Automatische bevestiging verstuurd', statusWijziging: undefined },
      { datum: '2024-09-25 11:00', gebruiker: 'Marie Dubois', activiteit: 'Documenten opgevraagd bij klant', statusWijziging: undefined },
    ],
    documenten: [
      { id: 'D-004', naam: 'Schadeaangifte', type: 'PDF', datum: '2024-09-21' },
      { id: 'D-005', naam: 'Aangifte politie', type: 'PDF', datum: '2024-09-21' },
    ],
  },
  {
    id: 'CL-003',
    claimnummer: 'SCH-2024-005680',
    status: 'AFGEHANDELD',
    incidentType: 'BRANDSCHADE',
    typeLabel: 'Brandschade',
    beschrijving: 'Korte sluiting in keuken veroorzaakte brand in kookplaat. Rookschade aan plafond en keukenkasten. Brandweer ter plaatse. Geen personenschade.',
    datumIncident: '2024-08-10',
    datumMelding: '2024-08-11',
    melder: 'Marie Dubois',
    prioriteit: 'HOOG',
    contractnummer: 'POL-2024-001235',
    verzekerdeNaam: 'Marie Dubois',
    maatschappijNaam: 'P&V',
    typeDekking: 'Woningverzekering',
    geschatBedrag: 18500,
    goedgekeurdBedrag: 18200,
    eigenRisico: 500,
    uitbetaald: 17700,
    restant: 0,
    expertNaam: 'Bureau All Risk Expertise',
    expertContact: '02/345.67.89',
    expertDatumAanstelling: '2024-08-12',
    expertRapportVerwacht: '2024-08-30',
    dagenOpen: 0,
    gemDoorlooptijd: 18,
    verwachteAfhandeling: 0,
    locatie: 'Rue du Marche 45, 3000 Leuven',
    tijd: '18:45',
    weersomstandigheden: 'Droog',
    politieAangifte: true,
    politiePVNummer: '2024-LEUV-08456',
    getuigen: 'Buurman Janssens',
    partijen: [
      { id: 'P-002', naam: 'Dubois, Marie', rol: 'VERZEKERDE', type: 'NP', telefoon: '0479/23.45.67' },
      { id: 'E-002', naam: 'Bureau All Risk Expertise', rol: 'EXPERT', type: 'EB', telefoon: '02/345.67.89' },
      { id: 'I-012', naam: 'P&V', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.22.22' },
    ],
    objecten: [
      { id: 'O-007', naam: 'Keuken - Rue du Marche 45', type: 'Onroerend goed', identificatie: 'Appartement 3A', schadeBedrag: 15000, status: 'Hersteld' },
      { id: 'O-008', naam: 'Keukenapparatuur', type: 'Inventaris', identificatie: 'Diverse', schadeBedrag: 3200, status: 'Hersteld' },
    ],
    opvolging: [
      { datum: '2024-08-11 08:30', gebruiker: 'Marie Dubois', activiteit: 'Claim aangemeld via telefoon', statusWijziging: '→ Openstaand' },
      { datum: '2024-08-12 09:00', gebruiker: 'Systeem', activiteit: 'Expert Bureau All Risk aangesteld', statusWijziging: '→ In Behandeling' },
      { datum: '2024-08-25 14:00', gebruiker: 'Bureau All Risk', activiteit: 'Expertiserapport ontvangen', statusWijziging: undefined },
      { datum: '2024-08-28 11:00', gebruiker: 'Marie Dubois', activiteit: 'Uitbetaling goedgekeurd', statusWijziging: '→ Afgehandeld' },
      { datum: '2024-09-02 10:00', gebruiker: 'Systeem', activiteit: '€ 17.700 uitbetaald', statusWijziging: undefined },
    ],
    documenten: [
      { id: 'D-006', naam: 'Schadeaangifte', type: 'PDF', datum: '2024-08-11' },
      { id: 'D-007', naam: 'Expertiserapport', type: 'PDF', datum: '2024-08-25' },
      { id: 'D-008', naam: 'Offerte herstelling', type: 'PDF', datum: '2024-08-20' },
      { id: 'D-009', naam: 'Foto\'s schade', type: 'IMG', datum: '2024-08-11' },
    ],
  },
  {
    id: 'CL-004',
    claimnummer: 'SCH-2024-005681',
    status: 'AFGEHANDELD',
    incidentType: 'WATERSCHADE',
    typeLabel: 'Waterschade',
    beschrijving: 'Waterleiding gesprongen in badkamer. Waterschade aan plafond ondergelegen verdieping. Vloerbedekking beschadigd.',
    datumIncident: '2024-07-05',
    datumMelding: '2024-07-06',
    melder: 'Anna Vermeiren',
    prioriteit: 'NORMAAL',
    contractnummer: 'POL-2024-001238',
    verzekerdeNaam: 'Anna Vermeiren',
    maatschappijNaam: 'Allianz Belgium',
    typeDekking: 'BA Privaat',
    geschatBedrag: 3200,
    goedgekeurdBedrag: 3100,
    eigenRisico: 250,
    uitbetaald: 2850,
    restant: 0,
    dagenOpen: 0,
    gemDoorlooptijd: 18,
    verwachteAfhandeling: 0,
    locatie: 'Stationsstraat 33, 9000 Gent',
    tijd: '07:00',
    weersomstandigheden: 'Droog',
    politieAangifte: false,
    getuigen: 'Geen',
    partijen: [
      { id: 'P-005', naam: 'Vermeiren, Anna', rol: 'VERZEKERDE', type: 'NP', telefoon: '0481/45.67.89' },
      { id: 'I-005', naam: 'Allianz Belgium', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.55.55' },
    ],
    objecten: [
      { id: 'O-009', naam: 'Badkamer + plafond', type: 'Onroerend goed', identificatie: 'Stationsstraat 33', schadeBedrag: 3200, status: 'Hersteld' },
    ],
    opvolging: [
      { datum: '2024-07-06 10:00', gebruiker: 'Anna Vermeiren', activiteit: 'Claim aangemeld via portal', statusWijziging: '→ Openstaand' },
      { datum: '2024-07-08 09:00', gebruiker: 'Systeem', activiteit: 'Toegewezen aan behandelaar', statusWijziging: '→ In Behandeling' },
      { datum: '2024-07-15 11:00', gebruiker: 'Systeem', activiteit: 'Uitbetaling goedgekeurd', statusWijziging: '→ Afgehandeld' },
      { datum: '2024-07-18 10:00', gebruiker: 'Systeem', activiteit: '€ 2.850 uitbetaald', statusWijziging: undefined },
    ],
    documenten: [
      { id: 'D-010', naam: 'Schadeaangifte', type: 'PDF', datum: '2024-07-06' },
      { id: 'D-011', naam: 'Offerte herstelling', type: 'PDF', datum: '2024-07-12' },
    ],
  },
  {
    id: 'CL-005',
    claimnummer: 'SCH-2024-005682',
    status: 'IN_BEHANDELING',
    incidentType: 'GLASBRUK',
    typeLabel: 'Glasbreuk',
    beschrijving: 'Voorruit gesprongen door steenslag op autosnelweg. Ruit onherstelbaar beschadigd.',
    datumIncident: '2024-11-20',
    datumMelding: '2024-11-20',
    melder: 'Sarah Michiels',
    prioriteit: 'NORMAAL',
    contractnummer: 'POL-2024-001239',
    verzekerdeNaam: 'Sarah Michiels',
    maatschappijNaam: 'Ethias',
    typeDekking: 'BA Privaat',
    geschatBedrag: 650,
    goedgekeurdBedrag: 650,
    eigenRisico: 150,
    uitbetaald: 500,
    restant: 0,
    dagenOpen: 30,
    gemDoorlooptijd: 18,
    verwachteAfhandeling: -12,
    locatie: 'E40, km 45, 1000 Brussel',
    tijd: '08:15',
    weersomstandigheden: 'Droog',
    politieAangifte: false,
    getuigen: 'Geen',
    partijen: [
      { id: 'P-007', naam: 'Michiels, Sarah', rol: 'VERZEKERDE', type: 'NP', telefoon: '0482/67.89.01' },
      { id: 'I-001', naam: 'Ethias', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.11.11' },
    ],
    objecten: [
      { id: 'O-010', naam: 'Voorruit', type: 'Voertuigonderdeel', identificatie: '1-ABC-999', schadeBedrag: 650, status: 'In herstel' },
    ],
    opvolging: [
      { datum: '2024-11-20 09:00', gebruiker: 'Sarah Michiels', activiteit: 'Claim aangemeld via app', statusWijziging: '→ In Behandeling' },
      { datum: '2024-11-20 14:00', gebruiker: 'Systeem', activiteit: '€ 500 voorschot uitbetaald', statusWijziging: undefined },
    ],
    documenten: [
      { id: 'D-012', naam: 'Schadeaangifte', type: 'PDF', datum: '2024-11-20' },
      { id: 'D-013', naam: 'Offerte ruit', type: 'PDF', datum: '2024-11-21' },
    ],
  },
  {
    id: 'CL-006',
    claimnummer: 'SCH-2024-005683',
    status: 'AFGEKEURD',
    incidentType: 'STORMSCHADE',
    typeLabel: 'Stormschade',
    beschrijving: 'Stormschade aan dakpannen na hevige storm. Dakpannen losgewaaid. Waterinsijpeling op zolder.',
    datumIncident: '2024-06-15',
    datumMelding: '2024-06-16',
    melder: 'Koen Maes',
    prioriteit: 'NORMAAL',
    contractnummer: 'POL-2024-001243',
    verzekerdeNaam: 'Koen Maes',
    maatschappijNaam: 'Vivium',
    typeDekking: 'Rechtsbijstand',
    geschatBedrag: 5600,
    goedgekeurdBedrag: 0,
    eigenRisico: 250,
    uitbetaald: 0,
    restant: 0,
    dagenOpen: 0,
    gemDoorlooptijd: 18,
    verwachteAfhandeling: 0,
    locatie: 'Steenweg op Brussels 56, 1700 Dilbeek',
    tijd: 'Nacht',
    weersomstandigheden: 'Storm, zware windstoten',
    politieAangifte: false,
    getuigen: 'Buurvrouw',
    partijen: [
      { id: 'P-011', naam: 'Maes, Koen', rol: 'VERZEKERDE', type: 'NP', telefoon: '0484/01.23.45' },
      { id: 'I-010', naam: 'Vivium', rol: 'VERZEKERAAR', type: 'VM', telefoon: '03/222.51.11' },
    ],
    objecten: [
      { id: 'O-011', naam: 'Dak woning', type: 'Onroerend goed', identificatie: 'Steenweg 56', schadeBedrag: 5600, status: 'In onderzoek' },
    ],
    opvolging: [
      { datum: '2024-06-16 10:00', gebruiker: 'Koen Maes', activiteit: 'Claim aangemeld', statusWijziging: '→ Openstaand' },
      { datum: '2024-06-20 09:00', gebruiker: 'Systeem', activiteit: 'Expertise uitgevoerd', statusWijziging: '→ In Behandeling' },
      { datum: '2024-07-10 11:00', gebruiker: 'Systeem', activiteit: 'Claim afgewezen - niet gedekt', statusWijziging: '→ Afgekeurd' },
    ],
    documenten: [
      { id: 'D-014', naam: 'Schadeaangifte', type: 'PDF', datum: '2024-06-16' },
      { id: 'D-015', naam: 'Weigeringsbrief', type: 'PDF', datum: '2024-07-10' },
    ],
  },
  {
    id: 'CL-007',
    claimnummer: 'SCH-2024-005684',
    status: 'OPENSTAAND',
    incidentType: 'AANRIJDING',
    typeLabel: 'Aanrijding',
    beschrijving: 'Aanrijding op kruispunt. Verzekerde had voorrang. Tegenpartij reed door rood licht. Zijdelingse aanrijding.',
    datumIncident: '2024-11-01',
    datumMelding: '2024-11-02',
    melder: 'Dirk Verhoeven',
    prioriteit: 'HOOG',
    contractnummer: 'POL-2024-001248',
    verzekerdeNaam: 'Dirk Verhoeven',
    maatschappijNaam: 'AG Insurance',
    typeDekking: 'Auto Toerisme',
    geschatBedrag: 8900,
    goedgekeurdBedrag: 0,
    eigenRisico: 250,
    uitbetaald: 0,
    restant: 8650,
    dagenOpen: 48,
    gemDoorlooptijd: 18,
    verwachteAfhandeling: 30,
    locatie: 'Kruispunt A12 x N115, 2640 Mortsel',
    tijd: '17:30',
    weersomstandigheden: 'Droog, schemer',
    politieAangifte: true,
    politiePVNummer: '2024-MORT-15432',
    tegenpartij: 'Onbekend - doorgereden',
    getuigen: 'Geen',
    partijen: [
      { id: 'P-016', naam: 'Verhoeven, Dirk', rol: 'VERZEKERDE', type: 'NP', telefoon: '0470/45.67.89' },
      { id: 'I-002', naam: 'AG Insurance', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/554.41.11' },
    ],
    objecten: [
      { id: 'O-012', naam: 'Audi A4 Avant', type: 'Voertuig', identificatie: '5-AUDI-444', schadeBedrag: 8900, status: 'In onderzoek' },
    ],
    opvolging: [
      { datum: '2024-11-02 10:00', gebruiker: 'Dirk Verhoeven', activiteit: 'Claim aangemeld', statusWijziging: '→ Openstaand' },
      { datum: '2024-11-05 09:00', gebruiker: 'Systeem', activiteit: 'Documenten opgevraagd', statusWijziging: undefined },
      { datum: '2024-11-15 11:00', gebruiker: 'Marie Dubois', activiteit: 'Expert in afwachting', statusWijziging: undefined },
    ],
    documenten: [
      { id: 'D-016', naam: 'Schadeaangifte', type: 'PDF', datum: '2024-11-02' },
      { id: 'D-017', naam: 'PV Politie', type: 'PDF', datum: '2024-11-02' },
    ],
  },
  {
    id: 'CL-008',
    claimnummer: 'SCH-2024-005685',
    status: 'AFGEHANDELD',
    incidentType: 'PARKEERSCHADE',
    typeLabel: 'Parkeerschade',
    beschrijving: 'Parkeerschade aan linker achterdeur. Vermoedelijk in winkelstraat. Geen briefje achtergelaten.',
    datumIncident: '2024-09-10',
    datumMelding: '2024-09-11',
    melder: 'Lucas Peeters',
    prioriteit: 'LAAG',
    contractnummer: 'POL-2024-001240',
    verzekerdeNaam: 'Lucas Peeters',
    maatschappijNaam: 'Ethias',
    typeDekking: 'Auto Mini-Omnium',
    geschatBedrag: 1200,
    goedgekeurdBedrag: 1100,
    eigenRisico: 250,
    uitbetaald: 850,
    restant: 0,
    dagenOpen: 0,
    gemDoorlooptijd: 18,
    verwachteAfhandeling: 0,
    locatie: 'Diestsestraat, 3000 Leuven',
    tijd: 'Onbekend',
    weersomstandigheden: 'Onbekend',
    politieAangifte: false,
    getuigen: 'Geen',
    partijen: [
      { id: 'P-006', naam: 'Lucas Peeters', rol: 'VERZEKERDE', type: 'NP', telefoon: '0472/56.78.90' },
      { id: 'I-001', naam: 'Ethias', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.11.11' },
    ],
    objecten: [
      { id: 'O-013', naam: 'BMW R 1250 GS', type: 'Voertuig', identificatie: '3-MNO-789', schadeBedrag: 1200, status: 'Hersteld' },
    ],
    opvolging: [
      { datum: '2024-09-11 08:00', gebruiker: 'Lucas Peeters', activiteit: 'Claim aangemeld', statusWijziging: '→ Openstaand' },
      { datum: '2024-09-12 09:00', gebruiker: 'Systeem', activiteit: 'Hersteller gecontacteerd', statusWijziging: '→ In Behandeling' },
      { datum: '2024-09-20 10:00', gebruiker: 'Systeem', activiteit: 'Uitbetaling', statusWijziging: '→ Afgehandeld' },
    ],
    documenten: [
      { id: 'D-018', naam: 'Schadeaangifte', type: 'PDF', datum: '2024-09-11' },
      { id: 'D-019', naam: 'Offerte herstelling', type: 'PDF', datum: '2024-09-15' },
    ],
  },
  {
    id: 'CL-009',
    claimnummer: 'SCH-2024-005686',
    status: 'IN_BEHANDELING',
    incidentType: 'BURGERLIJKE_AANSPRAKELIJKHEID',
    typeLabel: 'BA (Bedrijf)',
    beschrijving: 'Waterleiding gesprongen in bedrijfsgebouw. Schade aan gehuurde ruimte en inventaris huurder.',
    datumIncident: '2024-10-25',
    datumMelding: '2024-10-26',
    melder: 'Luc De Boer',
    prioriteit: 'DRINGEND',
    contractnummer: 'POL-2024-001237',
    verzekerdeNaam: 'BVBA De Boer',
    maatschappijNaam: 'Baloise',
    typeDekking: 'Brand Bedrijf',
    geschatBedrag: 24500,
    goedgekeurdBedrag: 0,
    eigenRisico: 1000,
    uitbetaald: 0,
    restant: 23500,
    expertNaam: 'Expertise NV',
    expertContact: '03/456.78.90',
    expertDatumAanstelling: '2024-10-28',
    expertRapportVerwacht: '2024-11-20',
    dagenOpen: 55,
    gemDoorlooptijd: 18,
    verwachteAfhandeling: -37,
    locatie: 'Industrielaan 45, 2018 Antwerpen',
    tijd: '06:00',
    weersomstandigheden: 'Droog',
    politieAangifte: false,
    getuigen: 'Concierge',
    partijen: [
      { id: 'P-004', naam: 'BVBA De Boer', rol: 'VERZEKERDE', type: 'RP', telefoon: '03/123.45.67' },
      { id: 'P-009', naam: 'Huurder BV', rol: 'AANSPRAKELIJKE', type: 'RP' },
      { id: 'E-003', naam: 'Expertise NV', rol: 'EXPERT', type: 'EB', telefoon: '03/456.78.90' },
      { id: 'I-004', naam: 'Baloise', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.44.44' },
    ],
    objecten: [
      { id: 'O-014', naam: 'Bedrijfsruimte', type: 'Onroerend goed', identificatie: 'Industrielaan 45', schadeBedrag: 18000, status: 'In onderzoek' },
      { id: 'O-015', naam: 'Inventaris huurder', type: 'Inventaris', identificatie: 'Diverse', schadeBedrag: 6500, status: 'In onderzoek' },
    ],
    opvolging: [
      { datum: '2024-10-26 07:30', gebruiker: 'Luc De Boer', activiteit: 'Claim aangemeld', statusWijziging: '→ Openstaand' },
      { datum: '2024-10-28 09:00', gebruiker: 'Systeem', activiteit: 'Expert Expertise NV aangesteld', statusWijziging: '→ In Behandeling' },
      { datum: '2024-11-05 14:00', gebruiker: 'Expertise NV', activiteit: 'Eerste bezoek ter plaatse', statusWijziging: undefined },
    ],
    documenten: [
      { id: 'D-020', naam: 'Schadeaangifte', type: 'PDF', datum: '2024-10-26' },
      { id: 'D-021', naam: 'Huurovereenkomst', type: 'PDF', datum: '2024-10-26' },
    ],
  },
  {
    id: 'CL-010',
    claimnummer: 'SCH-2024-005687',
    status: 'AFGEHANDELD',
    incidentType: 'ACHTERAANRIJDING',
    typeLabel: 'Achteraanrijding',
    beschrijving: 'Achteraanrijding op E40. Verzekerde stond stil in file. Tegenpartij kwam te snel naderen en botste achteraan.',
    datumIncident: '2024-08-20',
    datumMelding: '2024-08-20',
    melder: 'Sofie Claes',
    prioriteit: 'NORMAAL',
    contractnummer: 'POL-2024-001245',
    verzekerdeNaam: 'Sofie Claes',
    maatschappijNaam: 'Ethias',
    typeDekking: 'Auto Bromfietsen',
    geschatBedrag: 3200,
    goedgekeurdBedrag: 3100,
    eigenRisico: 100,
    uitbetaald: 3000,
    restant: 0,
    dagenOpen: 0,
    gemDoorlooptijd: 18,
    verwachteAfhandeling: 0,
    locatie: 'E40, km 65, 3500 Hasselt',
    tijd: '16:45',
    weersomstandigheden: 'Droog',
    politieAangifte: true,
    politiePVNummer: '2024-HASS-17654',
    tegenpartij: 'NV Transport BV',
    getuigen: 'Passagier',
    partijen: [
      { id: 'P-015', naam: 'Claes, Sofie', rol: 'VERZEKERDE', type: 'NP', telefoon: '0483/34.56.78' },
      { id: 'P-019', naam: 'NV Transport BV', rol: 'AANSPRAKELIJKE', type: 'RP' },
      { id: 'I-001', naam: 'Ethias', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.11.11' },
    ],
    objecten: [
      { id: 'O-016', naam: 'Vespa Primavera 125', type: 'Voertuig', identificatie: '4-BROM-001', schadeBedrag: 3200, status: 'Hersteld' },
    ],
    opvolging: [
      { datum: '2024-08-20 17:00', gebruiker: 'Sofie Claes', activiteit: 'Claim aangemeld', statusWijziging: '→ Openstaand' },
      { datum: '2024-08-21 09:00', gebruiker: 'Systeem', activiteit: 'Regres gestart tegen tegenpartij', statusWijziging: '→ In Behandeling' },
      { datum: '2024-09-10 11:00', gebruiker: 'Systeem', activiteit: 'Uitbetaling', statusWijziging: '→ Afgehandeld' },
    ],
    documenten: [
      { id: 'D-022', naam: 'Schadeaangifte', type: 'PDF', datum: '2024-08-20' },
      { id: 'D-023', naam: 'PV Politie', type: 'PDF', datum: '2024-08-20' },
    ],
  },
  {
    id: 'CL-011',
    claimnummer: 'SCH-2024-005688',
    status: 'OPENSTAAND',
    incidentType: 'TOTAL LOSS',
    typeLabel: 'Total Loss',
    beschrijving: 'Voertuig volledig verloren na zware aanrijding. Voertuig beyond herstel. Bestuurder lichtgewond.',
    datumIncident: '2024-09-05',
    datumMelding: '2024-09-06',
    melder: 'Thomas Peeters',
    prioriteit: 'DRINGEND',
    contractnummer: 'POL-2024-001248',
    verzekerdeNaam: 'Thomas Peeters',
    maatschappijNaam: 'Ethias',
    typeDekking: 'Auto Toerisme',
    geschatBedrag: 38500,
    goedgekeurdBedrag: 0,
    eigenRisico: 250,
    uitbetaald: 0,
    restant: 38250,
    expertNaam: 'Bureau Total Loss NV',
    expertContact: '02/567.89.01',
    expertDatumAanstelling: '2024-09-08',
    expertRapportVerwacht: '2024-10-15',
    dagenOpen: 75,
    gemDoorlooptijd: 18,
    verwachteAfhandeling: -57,
    locatie: 'N19, km 12, 2800 Mechelen',
    tijd: '09:30',
    weersomstandigheden: 'Droog',
    politieAangifte: true,
    politiePVNummer: '2024-MECH-18765',
    tegenpartij: 'Onbekend',
    getuigen: 'Wandelaar',
    partijen: [
      { id: 'P-008', naam: 'Peeters, Thomas', rol: 'VERZEKERDE', type: 'NP', telefoon: '0474/78.90.12' },
      { id: 'E-004', naam: 'Bureau Total Loss NV', rol: 'EXPERT', type: 'EB', telefoon: '02/567.89.01' },
      { id: 'I-001', naam: 'Ethias', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.11.11' },
    ],
    objecten: [
      { id: 'O-017', naam: 'Audi A4 Avant', type: 'Voertuig', identificatie: '5-AUDI-444', schadeBedrag: 38500, status: 'Totaal loss' },
    ],
    opvolging: [
      { datum: '2024-09-06 10:00', gebruiker: 'Thomas Peeters', activiteit: 'Claim aangemeld', statusWijziging: '→ Openstaand' },
      { datum: '2024-09-08 09:00', gebruiker: 'Systeem', activiteit: 'Expert aangesteld', statusWijziging: undefined },
      { datum: '2024-09-20 11:00', gebruiker: 'Bureau Total Loss', activiteit: 'Taxatierapport opgesteld', statusWijziging: undefined },
    ],
    documenten: [
      { id: 'D-024', naam: 'Schadeaangifte', type: 'PDF', datum: '2024-09-06' },
      { id: 'D-025', naam: 'PV Politie', type: 'PDF', datum: '2024-09-06' },
      { id: 'D-026', naam: 'Taxatierapport', type: 'PDF', datum: '2024-09-20' },
    ],
  },
  {
    id: 'CL-012',
    claimnummer: 'SCH-2024-005689',
    status: 'AFGEHANDELD',
    incidentType: 'STEENSCHADE',
    typeLabel: 'Steenschade',
    beschrijving: 'Steenschade op voorruit naast bestuurder. Bar ongeveer 15cm lang. Rijzicht belemmerd.',
    datumIncident: '2024-10-01',
    datumMelding: '2024-10-02',
    melder: 'Liesbeth De Smet',
    prioriteit: 'LAAG',
    contractnummer: 'POL-2024-001242',
    verzekerdeNaam: 'Liesbeth De Smet',
    maatschappijNaam: 'AXA Belgium',
    typeDekking: 'Auto Lichte Vracht',
    geschatBedrag: 450,
    goedgekeurdBedrag: 450,
    eigenRisico: 100,
    uitbetaald: 350,
    restant: 0,
    dagenOpen: 0,
    gemDoorlooptijd: 18,
    verwachteAfhandeling: 0,
    locatie: 'E313, km 30, 2200 Herentals',
    tijd: '11:00',
    weersomstandigheden: 'Droog',
    politieAangifte: false,
    getuigen: 'Geen',
    partijen: [
      { id: 'P-012', naam: 'De Smet, Liesbeth', rol: 'VERZEKERDE', type: 'NP', telefoon: '0477/12.34.56' },
      { id: 'I-003', naam: 'AXA Belgium', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.33.33' },
    ],
    objecten: [
      { id: 'O-018', naam: 'Voorruit Mercedes Sprinter', type: 'Voertuigonderdeel', identificatie: '1-VVV-999', schadeBedrag: 450, status: 'Hersteld' },
    ],
    opvolging: [
      { datum: '2024-10-02 08:00', gebruiker: 'Liesbeth De Smet', activiteit: 'Claim aangemeld', statusWijziging: '→ Openstaand' },
      { datum: '2024-10-03 09:00', gebruiker: 'Systeem', activiteit: 'Direct uitbetaald', statusWijziging: '→ Afgehandeld' },
    ],
    documenten: [
      { id: 'D-027', naam: 'Schadeaangifte', type: 'PDF', datum: '2024-10-02' },
      { id: 'D-028', naam: 'Offerte ruit', type: 'PDF', datum: '2024-10-02' },
    ],
  },
  {
    id: 'CL-013',
    claimnummer: 'SCH-2024-005690',
    status: 'IN_BEHANDELING',
    incidentType: 'HOSPITALISATIE',
    typeLabel: 'Hospitalisatie',
    beschrijving: 'Noodzakelijke hospitalisatie voor galblaasoperatie. Verblijf 3 dagen in ziekenhuis.',
    datumIncident: '2024-11-15',
    datumMelding: '2024-11-18',
    melder: 'Marie Dubois',
    prioriteit: 'NORMAAL',
    contractnummer: 'POL-2024-001244',
    verzekerdeNaam: 'Marie Dubois',
    maatschappijNaam: 'DKV Belgium',
    typeDekking: 'Hospitalisatie Groep',
    geschatBedrag: 4200,
    goedgekeurdBedrag: 0,
    eigenRisico: 0,
    uitbetaald: 0,
    restant: 4200,
    dagenOpen: 32,
    gemDoorlooptijd: 18,
    verwachteAfhandeling: -14,
    locatie: 'UZ Leuven, 3000 Leuven',
    tijd: 'N.v.t.',
    weersomstandigheden: 'N.v.t.',
    politieAangifte: false,
    getuigen: 'N.v.t.',
    partijen: [
      { id: 'P-002', naam: 'Dubois, Marie', rol: 'VERZEKERDE', type: 'NP', telefoon: '0479/23.45.67' },
      { id: 'I-011', naam: 'DKV Belgium', rol: 'VERZEKERAAR', type: 'VM', telefoon: '03/222.51.11' },
    ],
    objecten: [],
    opvolging: [
      { datum: '2024-11-18 10:00', gebruiker: 'Marie Dubois', activiteit: 'Claim aangemeld', statusWijziging: '→ Openstaand' },
      { datum: '2024-11-20 09:00', gebruiker: 'Systeem', activiteit: 'Medische documenten opgevraagd', statusWijziging: '→ In Behandeling' },
      { datum: '2024-11-28 11:00', gebruiker: 'Marie Dubois', activiteit: 'Medische documenten ingediend', statusWijziging: undefined },
    ],
    documenten: [
      { id: 'D-029', naam: 'Schadeaangifte', type: 'PDF', datum: '2024-11-18' },
      { id: 'D-030', naam: 'Ziekenhuisbrief', type: 'PDF', datum: '2024-11-20' },
    ],
  },
  {
    id: 'CL-014',
    claimnummer: 'SCH-2024-005691',
    status: 'AFGEKEURD',
    incidentType: 'ARBEIDSONGEVAL',
    typeLabel: 'Arbeidsongeval',
    beschrijving: 'Werknemer gevallen van ladder tijdens werkzaamheden. Polsbreuk. Werkgever niet verzekerd voor AO.',
    datumIncident: '2024-07-20',
    datumMelding: '2024-07-22',
    melder: 'Luc De Boer',
    prioriteit: 'HOOG',
    contractnummer: 'POL-2024-001246',
    verzekerdeNaam: 'NV Verzekerd Goed',
    maatschappijNaam: 'Axa Belgium',
    typeDekking: 'Arbeidsongeval Collectief',
    geschatBedrag: 8500,
    goedgekeurdBedrag: 0,
    eigenRisico: 0,
    uitbetaald: 0,
    restant: 0,
    dagenOpen: 0,
    gemDoorlooptijd: 18,
    verwachteAfhandeling: 0,
    locatie: 'Louizalaan 120, 1050 Brussel',
    tijd: '10:00',
    weersomstandigheden: 'Droog',
    politieAangifte: false,
    getuigen: 'Collega',
    partijen: [
      { id: 'P-010', naam: 'NV Verzekerd Goed', rol: 'VERZEKERDE', type: 'RP', telefoon: '02/234.56.78' },
      { id: 'P-020', naam: 'Werknemer Janssen', rol: 'VERZEKERDE', type: 'NP' },
      { id: 'I-007', naam: 'Axa Belgium', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/550.21.11' },
    ],
    objecten: [],
    opvolging: [
      { datum: '2024-07-22 09:00', gebruiker: 'Luc De Boer', activiteit: 'Claim aangemeld', statusWijziging: '→ Openstaand' },
      { datum: '2024-07-25 10:00', gebruiker: 'Systeem', activiteit: 'Onderzoek gestart', statusWijziging: '→ In Behandeling' },
      { datum: '2024-08-15 11:00', gebruiker: 'Systeem', activiteit: 'Afgewezen - contract geschorst op moment van ongeval', statusWijziging: '→ Afgekeurd' },
    ],
    documenten: [
      { id: 'D-031', naam: 'Schadeaangifte', type: 'PDF', datum: '2024-07-22' },
      { id: 'D-032', naam: 'Medisch rapport', type: 'PDF', datum: '2024-07-22' },
      { id: 'D-033', naam: 'Weigeringsbrief', type: 'PDF', datum: '2024-08-15' },
    ],
  },
  {
    id: 'CL-015',
    claimnummer: 'SCH-2024-005692',
    status: 'AFGEHANDELD',
    incidentType: 'RECHTSBIJSTAND',
    typeLabel: 'Rechtsbijstand',
    beschrijving: 'Geschil met aannemer over slechte uitvoering renovatiewerken. Juridische bijstand nodig voor geschilbeslechting.',
    datumIncident: '2024-06-01',
    datumMelding: '2024-06-05',
    melder: 'Koen Maes',
    prioriteit: 'LAAG',
    contractnummer: 'POL-2024-001243',
    verzekerdeNaam: 'Koen Maes',
    maatschappijNaam: 'Vivium',
    typeDekking: 'Rechtsbijstand Bedrijf',
    geschatBedrag: 3200,
    goedgekeurdBedrag: 2800,
    eigenRisico: 250,
    uitbetaald: 2550,
    restant: 0,
    dagenOpen: 0,
    gemDoorlooptijd: 18,
    verwachteAfhandeling: 0,
    locatie: 'Steenweg op Brussels 56, 1700 Dilbeek',
    tijd: 'N.v.t.',
    weersomstandigheden: 'N.v.t.',
    politieAangifte: false,
    getuigen: 'N.v.t.',
    partijen: [
      { id: 'P-011', naam: 'Maes, Koen', rol: 'VERZEKERDE', type: 'NP', telefoon: '0484/01.23.45' },
      { id: 'I-010', naam: 'Vivium', rol: 'VERZEKERAAR', type: 'VM', telefoon: '03/222.51.11' },
    ],
    objecten: [],
    opvolging: [
      { datum: '2024-06-05 10:00', gebruiker: 'Koen Maes', activiteit: 'Claim aangemeld', statusWijziging: '→ Openstaand' },
      { datum: '2024-06-10 09:00', gebruiker: 'Systeem', activiteit: 'Advocaat toegewezen', statusWijziging: '→ In Behandeling' },
      { datum: '2024-08-20 11:00', gebruiker: 'Advocaat', activiteit: 'Zaak beëindigd via minnelijke schikking', statusWijziging: '→ Afgehandeld' },
      { datum: '2024-08-25 10:00', gebruiker: 'Systeem', activiteit: '€ 2.550 uitbetaald', statusWijziging: undefined },
    ],
    documenten: [
      { id: 'D-034', naam: 'Schadeaangifte', type: 'PDF', datum: '2024-06-05' },
      { id: 'D-035', naam: 'Advies juridisch', type: 'PDF', datum: '2024-06-15' },
      { id: 'D-036', naam: 'Schikkingsvoorstel', type: 'PDF', datum: '2024-08-15' },
    ],
  },
  {
    id: 'CL-016',
    claimnummer: 'SCH-2024-005693',
    status: 'OPENSTAAND',
    incidentType: 'BRANDSCHADE',
    typeLabel: 'Brandschade',
    beschrijving: 'Brand in serverruimte door oververhitting UPS. Rookschade aan apparatuur. Geen personenschade.',
    datumIncident: '2024-08-25',
    datumMelding: '2024-08-26',
    melder: 'Bart Vandenberghe',
    prioriteit: 'DRINGEND',
    contractnummer: 'POL-2024-001249',
    verzekerdeNaam: 'Bart Vandenberghe',
    maatschappijNaam: 'Baloise',
    typeDekking: 'Brand Bedrijf',
    geschatBedrag: 12500,
    goedgekeurdBedrag: 0,
    eigenRisico: 1000,
    uitbetaald: 0,
    restant: 11500,
    expertNaam: 'IT Expertise BV',
    expertContact: '02/678.90.12',
    expertDatumAanstelling: '2024-08-28',
    expertRapportVerwacht: '2024-10-15',
    dagenOpen: 115,
    gemDoorlooptijd: 18,
    verwachteAfhandeling: -97,
    locatie: 'Eikenlaan 44, 2640 Mortsel',
    tijd: '03:00',
    weersomstandigheden: 'Droog',
    politieAangifte: true,
    politiePVNummer: '2024-MORT-19876',
    getuigen: 'Alarmcentrale',
    partijen: [
      { id: 'P-014', naam: 'Vandenberghe, Bart', rol: 'VERZEKERDE', type: 'NP', telefoon: '0478/23.45.67' },
      { id: 'E-005', naam: 'IT Expertise BV', rol: 'EXPERT', type: 'EB', telefoon: '02/678.90.12' },
      { id: 'I-004', naam: 'Baloise', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.44.44' },
    ],
    objecten: [
      { id: 'O-019', naam: 'Serverapparatuur', type: 'IT-inventaris', identificatie: 'Diverse', schadeBedrag: 8000, status: 'In onderzoek' },
      { id: 'O-020', naam: 'Netwerk switches', type: 'IT-inventaris', identificatie: 'Diverse', schadeBedrag: 4500, status: 'In onderzoek' },
    ],
    opvolging: [
      { datum: '2024-08-26 06:00', gebruiker: 'Bart Vandenberghe', activiteit: 'Claim aangemeld', statusWijziging: '→ Openstaand' },
      { datum: '2024-08-28 09:00', gebruiker: 'Systeem', activiteit: 'Expert IT Expertise aangesteld', statusWijziging: undefined },
      { datum: '2024-09-15 10:00', gebruiker: 'IT Expertise BV', activiteit: 'Tweede bezoek ter plaatse', statusWijziging: undefined },
    ],
    documenten: [
      { id: 'D-037', naam: 'Schadeaangifte', type: 'PDF', datum: '2024-08-26' },
      { id: 'D-038', naam: 'PV Politie', type: 'PDF', datum: '2024-08-26' },
      { id: 'D-039', naam: 'Foto\'s schade', type: 'IMG', datum: '2024-08-26' },
    ],
  },
  {
    id: 'CL-017',
    claimnummer: 'SCH-2024-005694',
    status: 'AFGEHANDELD',
    incidentType: 'WATERSCHADE',
    typeLabel: 'Waterschade',
    beschrijving: 'Overstroming kelder na zware regenval. Waterpomp defect. Vloerbedekking en meubelen beschadigd.',
    datumIncident: '2024-05-15',
    datumMelding: '2024-05-16',
    melder: 'Nathalie Bosmans',
    prioriteit: 'NORMAAL',
    contractnummer: 'POL-2024-001247',
    verzekerdeNaam: 'Nathalie Bosmans',
    maatschappijNaam: 'Ethias',
    typeDekking: 'Auto Bromfietsen',
    geschatBedrag: 1800,
    goedgekeurdBedrag: 1650,
    eigenRisico: 250,
    uitbetaald: 1400,
    restant: 0,
    dagenOpen: 0,
    gemDoorlooptijd: 18,
    verwachteAfhandeling: 0,
    locatie: 'Adegemstraat 31, 2800 Mechelen',
    tijd: 'Nacht',
    weersomstandigheden: 'Zware regenval',
    politieAangifte: false,
    getuigen: 'Buurman',
    partijen: [
      { id: 'P-017', naam: 'Bosmans, Nathalie', rol: 'VERZEKERDE', type: 'NP', telefoon: '0471/56.78.90' },
      { id: 'I-001', naam: 'Ethias', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.11.11' },
    ],
    objecten: [
      { id: 'O-021', naam: 'Kelderinrichting', type: 'Inventaris', identificatie: 'Adegemstraat 31', schadeBedrag: 1800, status: 'Hersteld' },
    ],
    opvolging: [
      { datum: '2024-05-16 08:00', gebruiker: 'Nathalie Bosmans', activiteit: 'Claim aangemeld', statusWijziging: '→ Openstaand' },
      { datum: '2024-05-18 09:00', gebruiker: 'Systeem', activiteit: 'Expertise uitgevoerd', statusWijziging: '→ In Behandeling' },
      { datum: '2024-06-01 11:00', gebruiker: 'Systeem', activiteit: 'Uitbetaling', statusWijziging: '→ Afgehandeld' },
    ],
    documenten: [
      { id: 'D-040', naam: 'Schadeaangifte', type: 'PDF', datum: '2024-05-16' },
      { id: 'D-041', naam: 'Offerte herstelling', type: 'PDF', datum: '2024-05-25' },
    ],
  },
  {
    id: 'CL-018',
    claimnummer: 'SCH-2024-005695',
    status: 'IN_BEHANDELING',
    incidentType: 'GLASBRUK',
    typeLabel: 'Glasbreuk',
    beschrijving: 'Ruit van etalage gesneuveld na poging tot inbraak. Veiligheidsglas volledig beschadigd.',
    datumIncident: '2024-11-28',
    datumMelding: '2024-11-29',
    melder: 'Sofie Claes',
    prioriteit: 'HOOG',
    contractnummer: 'POL-2024-001245',
    verzekerdeNaam: 'Sofie Claes',
    maatschappijNaam: 'Ethias',
    typeDekking: 'Auto Bromfietsen',
    geschatBedrag: 2200,
    goedgekeurdBedrag: 0,
    eigenRisico: 250,
    uitbetaald: 0,
    restant: 1950,
    dagenOpen: 21,
    gemDoorlooptijd: 18,
    verwachteAfhandeling: -3,
    locatie: 'Bosstraat 21, 3500 Hasselt',
    tijd: '02:30',
    weersomstandigheden: 'Droog',
    politieAangifte: true,
    politiePVNummer: '2024-HASS-20987',
    getuigen: 'Alarmcentrale',
    partijen: [
      { id: 'P-015', naam: 'Claes, Sofie', rol: 'VERZEKERDE', type: 'NP', telefoon: '0483/34.56.78' },
      { id: 'I-001', naam: 'Ethias', rol: 'VERZEKERAAR', type: 'VM', telefoon: '02/505.11.11' },
    ],
    objecten: [
      { id: 'O-022', naam: 'Etalageruit', type: 'Glas', identificatie: 'Bosstraat 21', schadeBedrag: 2200, status: 'In herstel' },
    ],
    opvolging: [
      { datum: '2024-11-29 07:00', gebruiker: 'Sofie Claes', activiteit: 'Claim aangemeld', statusWijziging: '→ Openstaand' },
      { datum: '2024-11-29 10:00', gebruiker: 'Systeem', activiteit: 'Hersteller gecontacteerd', statusWijziging: '→ In Behandeling' },
      { datum: '2024-12-02 09:00', gebruiker: 'Hersteller', activiteit: 'Offerte ingediend', statusWijziging: undefined },
    ],
    documenten: [
      { id: 'D-042', naam: 'Schadeaangifte', type: 'PDF', datum: '2024-11-29' },
      { id: 'D-043', naam: 'PV Politie', type: 'PDF', datum: '2024-11-29' },
    ],
  },
]
