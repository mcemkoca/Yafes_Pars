import { useState } from 'react'
import type { ReactNode, CSSProperties } from 'react'
import {
  Settings,
  Users,
  ShieldCheck,
  Bell,
  ClipboardList,
  Database,
  UserPlus,
  Pencil,
  X,
  Check,
  Minus,
  Download,
  Save,
  RotateCcw,
  Search,
  AlertTriangle,
  Trash2,
  CheckCircle2,
  XCircle,
  ChevronDown,
  ChevronRight,
} from 'lucide-react'
import StatusBadge from '@/components/StatusBadge'

/* ============================================================
   Types
   ============================================================ */
interface User {
  id: string
  naam: string
  email: string
  rol: string
  status: 'Actief' | 'Inactief'
  laatsteLogin: string
  contractenBeheerd: number
  avatarInitials: string
}

interface AuditEntry {
  id: string
  tijdstip: string
  gebruiker: string
  actie: string
  entiteit: string
  veld?: string
  oudeWaarde?: string
  nieuweWaarde?: string
  ipAdres: string
}

/* ============================================================
   Chart colors
   ============================================================ */
const CHART = {
  1: '#4A804A',
  2: '#3B6EA5',
  3: '#C8A456',
  4: '#8B5E83',
  5: '#C07A4A',
}

/* ============================================================
   Tab definitions
   ============================================================ */
const tabs = [
  { key: 'algemeen', label: 'Algemeen', icon: Settings },
  { key: 'gebruikers', label: 'Gebruikers', icon: Users },
  { key: 'rollen', label: 'Rollen & Rechten', icon: ShieldCheck },
  { key: 'notificaties', label: 'Notificaties', icon: Bell },
  { key: 'audit', label: 'Audit Log', icon: ClipboardList },
  { key: 'backup', label: 'Back-up', icon: Database },
]

/* ============================================================
   Mock data
   ============================================================ */

// --- Users ---
const mockUsers: User[] = [
  { id: '1', naam: 'Jan De Vries', email: 'jan.devries@assuremanager.be', rol: 'Beheerder', status: 'Actief', laatsteLogin: '24/05/2025 08:45', contractenBeheerd: 1240, avatarInitials: 'JD' },
  { id: '2', naam: 'Marie Peeters', email: 'marie.peeters@assuremanager.be', rol: 'Manager', status: 'Actief', laatsteLogin: '24/05/2025 09:12', contractenBeheerd: 856, avatarInitials: 'MP' },
  { id: '3', naam: 'Pieter Janssens', email: 'pieter.janssens@assuremanager.be', rol: 'Medewerker', status: 'Actief', laatsteLogin: '23/05/2025 16:30', contractenBeheerd: 423, avatarInitials: 'PJ' },
  { id: '4', naam: 'Sofie Martens', email: 'sofie.martens@assuremanager.be', rol: 'Schadebehandelaar', status: 'Actief', laatsteLogin: '24/05/2025 07:58', contractenBeheerd: 312, avatarInitials: 'SM' },
  { id: '5', naam: 'Thomas Claes', email: 'thomas.claes@assuremanager.be', rol: 'Commercieel', status: 'Actief', laatsteLogin: '23/05/2025 14:22', contractenBeheerd: 198, avatarInitials: 'TC' },
  { id: '6', naam: 'Lotte Vermeulen', email: 'lotte.vermeulen@assuremanager.be', rol: 'Backoffice', status: 'Actief', laatsteLogin: '22/05/2025 11:05', contractenBeheerd: 567, avatarInitials: 'LV' },
  { id: '7', naam: 'Bart Jacobs', email: 'bart.jacobs@assuremanager.be', rol: 'Financieel', status: 'Actief', laatsteLogin: '24/05/2025 08:15', contractenBeheerd: 0, avatarInitials: 'BJ' },
  { id: '8', naam: 'Emma Deckers', email: 'emma.deckers@assuremanager.be', rol: 'Jurist', status: 'Inactief', laatsteLogin: '15/03/2025 10:30', contractenBeheerd: 45, avatarInitials: 'ED' },
]

const rolBadgeColor = (rol: string): 'active' | 'info' | 'warning' | 'neutral' => {
  switch (rol) {
    case 'Beheerder': return 'active'
    case 'Manager': return 'info'
    case 'Medewerker': return 'warning'
    case 'Schadebehandelaar': return 'neutral'
    case 'Commercieel': return 'active'
    case 'Backoffice': return 'info'
    case 'Financieel': return 'warning'
    case 'Jurist': return 'neutral'
    default: return 'neutral'
  }
}

// --- Audit log entries ---
const mockAuditLog: AuditEntry[] = [
  { id: '1', tijdstip: '24/05/2025 09:15:32', gebruiker: 'Jan De Vries', actie: 'Aangemaakt', entiteit: 'Contract #POL-2025-00189', veld: '—', ipAdres: '192.168.1.45' },
  { id: '2', tijdstip: '24/05/2025 09:12:08', gebruiker: 'Marie Peeters', actie: 'Bewerkt', entiteit: 'Schadeclaim #SCH-2025-00432', veld: 'Status', oudeWaarde: 'In behandeling', nieuweWaarde: 'Afgehandeld', ipAdres: '192.168.1.42' },
  { id: '3', tijdstip: '24/05/2025 08:58:44', gebruiker: 'Sofie Martens', actie: 'Verwijderd', entiteit: 'Persoon #P-2025-00891', veld: '—', ipAdres: '192.168.1.38' },
  { id: '4', tijdstip: '24/05/2025 08:45:12', gebruiker: 'Jan De Vries', actie: 'Ingelogd', entiteit: 'Systeem', ipAdres: '192.168.1.45' },
  { id: '5', tijdstip: '23/05/2025 16:30:22', gebruiker: 'Pieter Janssens', actie: 'Bewerkt', entiteit: 'Contract #POL-2025-00145', veld: 'Premie', oudeWaarde: '\u20ac 1.180', nieuweWaarde: '\u20ac 1.240', ipAdres: '192.168.1.47' },
  { id: '6', tijdstip: '23/05/2025 15:45:00', gebruiker: 'Thomas Claes', actie: 'Aangemaakt', entiteit: 'Persoon #P-2025-00912', veld: '—', ipAdres: '192.168.1.50' },
  { id: '7', tijdstip: '23/05/2025 14:20:18', gebruiker: 'Lotte Vermeulen', actie: 'Bewerkt', entiteit: 'Instelling #I-056', veld: 'Telefoon', oudeWaarde: '03/234.56.78', nieuweWaarde: '03/245.67.89', ipAdres: '192.168.1.44' },
  { id: '8', tijdstip: '23/05/2025 11:05:33', gebruiker: 'Bart Jacobs', actie: 'Geexporteerd', entiteit: 'Rapport: Maandcommissie', ipAdres: '192.168.1.52' },
  { id: '9', tijdstip: '22/05/2025 16:15:45', gebruiker: 'Marie Peeters', actie: 'Aangemaakt', entiteit: 'Schadeclaim #SCH-2025-00445', veld: '—', ipAdres: '192.168.1.42' },
  { id: '10', tijdstip: '22/05/2025 14:30:12', gebruiker: 'Jan De Vries', actie: 'Instelling gewijzigd', entiteit: 'Systeem: Gebruikers', veld: 'Rol', oudeWaarde: 'Medewerker', nieuweWaarde: 'Manager', ipAdres: '192.168.1.45' },
  { id: '11', tijdstip: '22/05/2025 10:22:08', gebruiker: 'Sofie Martens', actie: 'Bewerkt', entiteit: 'Schadeclaim #SCH-2025-00421', veld: 'Bedrag', oudeWaarde: '\u20ac 3.200', nieuweWaarde: '\u20ac 4.500', ipAdres: '192.168.1.38' },
  { id: '12', tijdstip: '21/05/2025 17:00:00', gebruiker: 'Pieter Janssens', actie: 'Ingelogd', entiteit: 'Systeem', ipAdres: '192.168.1.47' },
  { id: '13', tijdstip: '21/05/2025 13:45:22', gebruiker: 'Thomas Claes', actie: 'Aangemaakt', entiteit: 'Contract #POL-2025-00176', veld: '—', ipAdres: '192.168.1.50' },
  { id: '14', tijdstip: '21/05/2025 09:30:15', gebruiker: 'Lotte Vermeulen', actie: 'Bewerkt', entiteit: 'Object #OBJ-2025-00341', veld: 'Eigenaar', oudeWaarde: 'P-2025-00456', nieuweWaarde: 'P-2025-00789', ipAdres: '192.168.1.44' },
  { id: '15', tijdstip: '20/05/2025 16:20:33', gebruiker: 'Marie Peeters', actie: 'Verwijderd', entiteit: 'Contract #POL-2024-00912', veld: '—', ipAdres: '192.168.1.42' },
  { id: '16', tijdstip: '20/05/2025 11:10:45', gebruiker: 'Jan De Vries', actie: 'Bewerkt', entiteit: 'Systeem: Belasting', veld: 'Verzekeringstaks', oudeWaarde: '9,25%', nieuweWaarde: '9,50%', ipAdres: '192.168.1.45' },
  { id: '17', tijdstip: '20/05/2025 08:05:18', gebruiker: 'Bart Jacobs', actie: 'Geexporteerd', entiteit: 'Financieel rapport Q2', ipAdres: '192.168.1.52' },
  { id: '18', tijdstip: '19/05/2025 15:30:00', gebruiker: 'Sofie Martens', actie: 'Aangemaakt', entiteit: 'Schadeclaim #SCH-2025-00438', veld: '—', ipAdres: '192.168.1.38' },
  { id: '19', tijdstip: '19/05/2025 14:22:11', gebruiker: 'Pieter Janssens', actie: 'Bewerkt', entiteit: 'Persoon #P-2025-00823', veld: 'Adres', oudeWaarde: 'Kerkstraat 5', nieuweWaarde: 'Marktplein 12', ipAdres: '192.168.1.47' },
  { id: '20', tijdstip: '19/05/2025 09:00:00', gebruiker: 'Jan De Vries', actie: 'Ingelogd', entiteit: 'Systeem', ipAdres: '192.168.1.45' },
  { id: '21', tijdstip: '18/05/2025 16:45:30', gebruiker: 'Thomas Claes', actie: 'Bewerkt', entiteit: 'Contract #POL-2025-00160', veld: 'Einddatum', oudeWaarde: '18/05/2026', nieuweWaarde: '18/11/2026', ipAdres: '192.168.1.50' },
  { id: '22', tijdstip: '18/05/2025 11:20:05', gebruiker: 'Lotte Vermeulen', actie: 'Aangemaakt', entiteit: 'Instelling #I-089', veld: '—', ipAdres: '192.168.1.44' },
]

const actieBadge = (actie: string) => {
  switch (actie) {
    case 'Aangemaakt': return 'active'
    case 'Bewerkt': return 'info'
    case 'Verwijderd': return 'error'
    case 'Ingelogd': return 'neutral'
    case 'Geexporteerd': return 'warning'
    case 'Instelling gewijzigd': return 'info'
    default: return 'neutral'
  }
}

// --- Permission matrix ---
const modules = ['Personen', 'Instellingen', 'Objecten', 'Contracten', 'Schadeclaims', 'Rapporten', 'Beheer']
const rollen = ['Beheerder', 'Manager', 'Medewerker', 'Schadebehandelaar', 'Commercieel', 'Lezer']

const defaultPermissions: Record<string, Record<string, { read: boolean; write: boolean }>> = {
  Beheerder: { Personen: { read: true, write: true }, Instellingen: { read: true, write: true }, Objecten: { read: true, write: true }, Contracten: { read: true, write: true }, Schadeclaims: { read: true, write: true }, Rapporten: { read: true, write: true }, Beheer: { read: true, write: true } },
  Manager: { Personen: { read: true, write: true }, Instellingen: { read: true, write: true }, Objecten: { read: true, write: true }, Contracten: { read: true, write: true }, Schadeclaims: { read: true, write: false }, Rapporten: { read: true, write: true }, Beheer: { read: true, write: false } },
  Medewerker: { Personen: { read: true, write: true }, Instellingen: { read: true, write: false }, Objecten: { read: true, write: true }, Contracten: { read: true, write: true }, Schadeclaims: { read: true, write: true }, Rapporten: { read: true, write: false }, Beheer: { read: false, write: false } },
  Schadebehandelaar: { Personen: { read: true, write: false }, Instellingen: { read: false, write: false }, Objecten: { read: true, write: false }, Contracten: { read: true, write: false }, Schadeclaims: { read: true, write: true }, Rapporten: { read: true, write: false }, Beheer: { read: false, write: false } },
  Commercieel: { Personen: { read: true, write: true }, Instellingen: { read: true, write: false }, Objecten: { read: true, write: false }, Contracten: { read: true, write: true }, Schadeclaims: { read: true, write: false }, Rapporten: { read: true, write: false }, Beheer: { read: false, write: false } },
  Lezer: { Personen: { read: true, write: false }, Instellingen: { read: true, write: false }, Objecten: { read: true, write: false }, Contracten: { read: true, write: false }, Schadeclaims: { read: true, write: false }, Rapporten: { read: true, write: false }, Beheer: { read: false, write: false } },
}

/* ============================================================
   Sub-components
   ============================================================ */

function Card({ title, children, className = '' }: { title: string; children: ReactNode; className?: string }) {
  return (
    <div className={`bg-white rounded-lg ${className}`} style={{ border: '1px solid #E8EBEE' }}>
      <div className="flex items-center" style={{ padding: '14px 20px', borderBottom: '1px solid #E8EBEE' }}>
        <h3 className="font-semibold" style={{ fontSize: '15px', color: '#1A1F24' }}>{title}</h3>
      </div>
      <div style={{ padding: '20px' }}>
        {children}
      </div>
    </div>
  )
}

function Input({ label, value, onChange, type = 'text', placeholder = '', disabled = false }: {
  label: string; value: string; onChange: (v: string) => void; type?: string; placeholder?: string; disabled?: boolean
}) {
  return (
    <div>
      <label className="block text-xs font-semibold mb-1.5" style={{ color: '#3D4550' }}>{label}</label>
      <input
        type={type}
        value={value}
        disabled={disabled}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        className="w-full rounded-md border border-[#D1D6DB] text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15 transition-all"
        style={{
          height: '40px',
          padding: '0 12px',
          color: disabled ? '#6B7785' : '#1A1F24',
          backgroundColor: disabled ? '#FAFBFC' : '#FFFFFF',
        }}
      />
    </div>
  )
}

function Select({ label, value, onChange, options }: { label: string; value: string; onChange: (v: string) => void; options: string[] }) {
  return (
    <div>
      <label className="block text-xs font-semibold mb-1.5" style={{ color: '#3D4550' }}>{label}</label>
      <select
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="w-full rounded-md border border-[#D1D6DB] text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15"
        style={{ height: '40px', padding: '0 12px', color: '#1A1F24', backgroundColor: '#fff' }}
      >
        {options.map(o => <option key={o} value={o}>{o}</option>)}
      </select>
    </div>
  )
}

function Toggle({ label, checked, onChange }: { label: string; checked: boolean; onChange: (v: boolean) => void }) {
  return (
    <label className="flex items-center gap-3 cursor-pointer">
      <div
        className="relative flex items-center rounded-full transition-colors duration-200"
        style={{
          width: '40px',
          height: '22px',
          backgroundColor: checked ? '#4A804A' : '#D1D6DB',
          cursor: 'pointer',
        }}
        onClick={() => onChange(!checked)}
      >
        <div
          className="absolute rounded-full bg-white transition-transform duration-200"
          style={{
            width: '18px',
            height: '18px',
            left: '2px',
            transform: checked ? 'translateX(18px)' : 'translateX(0)',
            boxShadow: '0 1px 3px rgba(0,0,0,0.2)',
          }}
        />
      </div>
      <span className="text-sm" style={{ color: '#3D4550' }}>{label}</span>
    </label>
  )
}

/* ============================================================
   Algemeen Tab
   ============================================================ */
function AlgemeenTab() {
  const [company, setCompany] = useState({
    naam: 'AssureManager BV',
    ondernemingsnummer: 'BE 0475.987.654',
    btw: 'BE 0475.987.654',
    straat: 'Grote Markt',
    nummer: '15',
    bus: '3',
    postcode: '2800',
    stad: 'Mechelen',
    provincie: 'Antwerpen',
    telefoon: '015/34.56.78',
    email: 'info@assuremanager.be',
    website: 'www.assuremanager.be',
  })
  const [prefs, setPrefs] = useState({
    taal: 'Nederlands',
    datumformaat: 'DD/MM/YYYY',
    valuta: 'EUR (\u20ac)',
    nummerformaat: 'Belgisch',
    tijdzone: 'Europe/Brussels',
    eersteDag: 'Maandag',
    paginagrootte: '25',
  })
  const [contractDefaults, setContractDefaults] = useState({
    opzegtermijn: '3',
    opzegtermijnUnit: 'maanden',
    autoVerlenging: true,
    commissiePct: '15',
    herinneringDagen: '30',
    looptijd: '1 jaar',
  })
  const [tax, setTax] = useState({
    verzekeringstaks: '9,25',
    administratieveTaks: '3,5',
    fsma: 'FSMA-123456',
    bav: true,
    bavPolis: 'BAV-2025-001',
  })

  const updateCompany = (key: string, val: string) => setCompany(prev => ({ ...prev, [key]: val }))
  const updatePrefs = (key: string, val: string) => setPrefs(prev => ({ ...prev, [key]: val }))
  const updateContractDefaults = (key: string, val: string | boolean) => setContractDefaults(prev => ({ ...prev, [key]: val }))
  const updateTax = (key: string, val: string | boolean) => setTax(prev => ({ ...prev, [key]: val }))

  return (
    <div className="space-y-5 max-w-4xl">
      <Card title="Kantoorgegevens">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <Input label="Kantoornaam" value={company.naam} onChange={(v) => updateCompany('naam', v)} />
          <Input label="Ondernemingsnummer" value={company.ondernemingsnummer} onChange={(v) => updateCompany('ondernemingsnummer', v)} />
          <Input label="BTW-nummer" value={company.btw} onChange={(v) => updateCompany('btw', v)} disabled />
          <div />
          <Input label="Straat" value={company.straat} onChange={(v) => updateCompany('straat', v)} />
          <div className="grid grid-cols-2 gap-3">
            <Input label="Nummer" value={company.nummer} onChange={(v) => updateCompany('nummer', v)} />
            <Input label="Bus" value={company.bus} onChange={(v) => updateCompany('bus', v)} />
          </div>
          <Input label="Postcode" value={company.postcode} onChange={(v) => updateCompany('postcode', v)} />
          <Input label="Stad" value={company.stad} onChange={(v) => updateCompany('stad', v)} />
          <Input label="Provincie" value={company.provincie} onChange={(v) => updateCompany('provincie', v)} />
          <Input label="Telefoon" value={company.telefoon} onChange={(v) => updateCompany('telefoon', v)} type="tel" />
          <Input label="E-mail" value={company.email} onChange={(v) => updateCompany('email', v)} type="email" />
          <Input label="Website" value={company.website} onChange={(v) => updateCompany('website', v)} type="url" />
        </div>
      </Card>

      <Card title="Systeemvoorkeuren">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <Select label="Standaard taal" value={prefs.taal} onChange={(v) => updatePrefs('taal', v)} options={['Nederlands', 'Fran\u00e7ais', 'Deutsch']} />
          <Select label="Datumformaat" value={prefs.datumformaat} onChange={(v) => updatePrefs('datumformaat', v)} options={['DD/MM/YYYY', 'YYYY-MM-DD', 'MM/DD/YYYY']} />
          <Select label="Valuta" value={prefs.valuta} onChange={(v) => updatePrefs('valuta', v)} options={['EUR (\u20ac)', 'USD ($)', 'GBP (\u00a3)']} />
          <Select label="Nummerformaat" value={prefs.nummerformaat} onChange={(v) => updatePrefs('nummerformaat', v)} options={['Belgisch', 'Internationaal']} />
          <Select label="Tijdzone" value={prefs.tijdzone} onChange={(v) => updatePrefs('tijdzone', v)} options={['Europe/Brussels', 'Europe/Amsterdam', 'Europe/London']} />
          <Select label="Eerste dag van de week" value={prefs.eersteDag} onChange={(v) => updatePrefs('eersteDag', v)} options={['Maandag', 'Zondag']} />
          <Select label="Standaard paginagrootte" value={prefs.paginagrootte} onChange={(v) => updatePrefs('paginagrootte', v)} options={['10', '25', '50', '100']} />
        </div>
      </Card>

      <Card title="Standaard Contractinstellingen">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="grid grid-cols-2 gap-3">
            <Input label="Opzegtermijn" value={contractDefaults.opzegtermijn} onChange={(v) => updateContractDefaults('opzegtermijn', v)} type="number" />
            <Select label=" " value={contractDefaults.opzegtermijnUnit} onChange={(v) => updateContractDefaults('opzegtermijnUnit', v)} options={['dagen', 'weken', 'maanden']} />
          </div>
          <div className="flex items-end pb-2">
            <Toggle label="Automatische verlenging" checked={contractDefaults.autoVerlenging} onChange={(v) => updateContractDefaults('autoVerlenging', v)} />
          </div>
          <Input label="Commissiepercentage standaard" value={contractDefaults.commissiePct} onChange={(v) => updateContractDefaults('commissiePct', v)} type="number" />
          <Input label="Herinnering vervaldatum (dagen voor)" value={contractDefaults.herinneringDagen} onChange={(v) => updateContractDefaults('herinneringDagen', v)} type="number" />
          <Select label="Standaard looptijd" value={contractDefaults.looptijd} onChange={(v) => updateContractDefaults('looptijd', v)} options={['1 jaar', '2 jaar', '3 jaar', '5 jaar', 'Levenslang']} />
        </div>
      </Card>

      <Card title="Belasting & Regulering">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <Input label="Verzekeringstaks %" value={tax.verzekeringstaks} onChange={(v) => updateTax('verzekeringstaks', v)} type="text" />
          <Input label="Administratieve taks %" value={tax.administratieveTaks} onChange={(v) => updateTax('administratieveTaks', v)} type="text" />
          <Input label="FSMA registratienummer" value={tax.fsma} onChange={(v) => updateTax('fsma', v)} />
          <div className="flex items-end pb-2">
            <Toggle label="BAV verzekering" checked={tax.bav} onChange={(v) => updateTax('bav', v)} />
          </div>
          {tax.bav && (
            <Input label="BAV Polisnummer" value={tax.bavPolis} onChange={(v) => updateTax('bavPolis', v)} />
          )}
        </div>
      </Card>

      <div className="flex justify-end">
        <button
          className="flex items-center gap-2 rounded-md text-white font-medium transition-all hover:shadow-md"
          style={{ height: '44px', padding: '0 24px', backgroundColor: '#4A804A', fontSize: 14 }}
        >
          <Save style={{ width: 16, height: 16 }} />
          Wijzigingen Opslaan
        </button>
      </div>
    </div>
  )
}

/* ============================================================
   Gebruikers Tab
   ============================================================ */
function GebruikersTab() {
  const [users, setUsers] = useState<User[]>(mockUsers)
  const [showAddModal, setShowAddModal] = useState(false)
  const [search, setSearch] = useState('')
  const [newUser, setNewUser] = useState({ naam: '', email: '', rol: 'Medewerker', telefoon: '' })

  const filtered = users.filter(u =>
    u.naam.toLowerCase().includes(search.toLowerCase()) ||
    u.email.toLowerCase().includes(search.toLowerCase()) ||
    u.rol.toLowerCase().includes(search.toLowerCase())
  )

  const addUser = () => {
    if (!newUser.naam || !newUser.email) return
    const initials = newUser.naam.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
    const user: User = {
      id: String(users.length + 1),
      naam: newUser.naam,
      email: newUser.email,
      rol: newUser.rol,
      status: 'Actief',
      laatsteLogin: 'Nooit',
      contractenBeheerd: 0,
      avatarInitials: initials,
    }
    setUsers([...users, user])
    setNewUser({ naam: '', email: '', rol: 'Medewerker', telefoon: '' })
    setShowAddModal(false)
  }

  const toggleStatus = (id: string) => {
    setUsers(users.map(u => u.id === id ? { ...u, status: u.status === 'Actief' ? 'Inactief' : 'Actief' } : u))
  }

  const actiefCount = users.filter(u => u.status === 'Actief').length
  const inactiefCount = users.filter(u => u.status === 'Inactief').length

  return (
    <div className="space-y-5">
      {/* KPI mini row */}
      <div className="grid grid-cols-3 gap-4 max-w-md">
        <div className="bg-white rounded-lg" style={{ border: '1px solid #E8EBEE', padding: '16px 20px' }}>
          <div className="text-xs mb-1" style={{ color: '#6B7785' }}>Totaal gebruikers</div>
          <div className="font-bold" style={{ fontSize: '22px', color: '#1A1F24' }}>{users.length}</div>
        </div>
        <div className="bg-white rounded-lg" style={{ border: '1px solid #E8EBEE', padding: '16px 20px' }}>
          <div className="text-xs mb-1" style={{ color: '#6B7785' }}>Actief</div>
          <div className="font-bold" style={{ fontSize: '22px', color: '#4A804A' }}>{actiefCount}</div>
        </div>
        <div className="bg-white rounded-lg" style={{ border: '1px solid #E8EBEE', padding: '16px 20px' }}>
          <div className="text-xs mb-1" style={{ color: '#6B7785' }}>Inactief</div>
          <div className="font-bold" style={{ fontSize: '22px', color: '#C04A4A' }}>{inactiefCount}</div>
        </div>
      </div>

      {/* Users table */}
      <div className="bg-white rounded-lg" style={{ border: '1px solid #E8EBEE' }}>
        <div className="flex items-center justify-between flex-wrap gap-3" style={{ padding: '14px 20px', borderBottom: '1px solid #E8EBEE' }}>
          <div className="relative" style={{ maxWidth: 280 }}>
            <Search className="absolute left-2.5 top-1/2 -translate-y-1/2 text-[#95A1AD]" style={{ width: 14, height: 14 }} />
            <input
              type="text"
              placeholder="Zoek gebruikers..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full rounded-md border border-[#D1D6DB] text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15"
              style={{ height: '36px', padding: '0 10px 0 30px', fontSize: 12, color: '#1A1F24' }}
            />
          </div>
          <button
            onClick={() => setShowAddModal(true)}
            className="flex items-center gap-2 rounded-md text-white font-medium transition-all hover:shadow-md"
            style={{ height: '36px', padding: '0 16px', backgroundColor: '#4A804A', fontSize: 13 }}
          >
            <UserPlus style={{ width: 15, height: 15 }} />
            Gebruiker Toevoegen
          </button>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full border-collapse">
            <thead>
              <tr style={{ backgroundColor: '#F2F4F6', height: 44 }}>
                {['Gebruiker', 'Rol', 'Status', 'Laatste login', 'Contracten', 'Acties'].map(h => (
                  <th key={h} className="text-left font-semibold" style={{ padding: '0 16px', fontSize: 13, color: '#3D4550' }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.map((user, idx) => (
                <tr key={user.id} style={{ height: 56, backgroundColor: idx % 2 === 1 ? '#FAFBFC' : '#FFFFFF', borderBottom: '1px solid #E8EBEE' }}>
                  <td style={{ padding: '10px 16px' }}>
                    <div className="flex items-center gap-3">
                      <div
                        className="flex items-center justify-center rounded-full text-white text-xs font-bold"
                        style={{ width: '36px', height: '36px', backgroundColor: CHART[(parseInt(user.id, 10) % 5) + 1 as keyof typeof CHART] || CHART[1] }}
                      >
                        {user.avatarInitials}
                      </div>
                      <div>
                        <div className="text-sm font-medium" style={{ color: '#1A1F24' }}>{user.naam}</div>
                        <div className="text-xs" style={{ color: '#6B7785' }}>{user.email}</div>
                      </div>
                    </div>
                  </td>
                  <td style={{ padding: '10px 16px' }}>
                    <StatusBadge status={rolBadgeColor(user.rol)}>{user.rol}</StatusBadge>
                  </td>
                  <td style={{ padding: '10px 16px' }}>
                    <StatusBadge status={user.status === 'Actief' ? 'active' : 'neutral'}>{user.status}</StatusBadge>
                  </td>
                  <td style={{ padding: '10px 16px', fontSize: 13, color: '#3D4550' }}>{user.laatsteLogin}</td>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#1A1F24' }}>{user.contractenBeheerd}</td>
                  <td style={{ padding: '10px 16px' }}>
                    <div className="flex items-center gap-1">
                      <button className="flex items-center justify-center rounded-md text-[#3B6EA5] hover:bg-[#E8F0F8] transition-colors" style={{ width: '28px', height: '28px' }} title="Bewerken">
                        <Pencil style={{ width: 14, height: 14 }} />
                      </button>
                      <button
                        onClick={() => toggleStatus(user.id)}
                        className={`flex items-center justify-center rounded-md transition-colors ${user.status === 'Actief' ? 'text-[#C04A4A] hover:bg-[#FDE8E8]' : 'text-[#4A804A] hover:bg-[#F4FAF4]'}`}
                        style={{ width: '28px', height: '28px' }}
                        title={user.status === 'Actief' ? 'Deactiveren' : 'Activeren'}
                      >
                        {user.status === 'Actief' ? <XCircle style={{ width: 14, height: 14 }} /> : <CheckCircle2 style={{ width: 14, height: 14 }} />}
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Add User Modal */}
      {showAddModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center" style={{ backgroundColor: 'rgba(15, 18, 21, 0.3)' }}>
          <div className="bg-white rounded-lg w-full max-w-md" style={{ boxShadow: '0 20px 60px rgba(0,0,0,0.15)' }}>
            <div className="flex items-center justify-between" style={{ padding: '16px 20px', borderBottom: '1px solid #E8EBEE' }}>
              <h3 className="font-semibold" style={{ fontSize: '16px', color: '#1A1F24' }}>Nieuwe Gebruiker</h3>
              <button onClick={() => setShowAddModal(false)} className="flex items-center justify-center rounded-md text-[#95A1AD] hover:text-[#1A1F24] hover:bg-[#F2F4F6] transition-colors" style={{ width: '28px', height: '28px' }}>
                <X style={{ width: 16, height: 16 }} />
              </button>
            </div>
            <div className="space-y-4" style={{ padding: '20px' }}>
              <Input label="Naam *" value={newUser.naam} onChange={(v) => setNewUser({ ...newUser, naam: v })} placeholder="Jan De Vries" />
              <Input label="E-mail *" value={newUser.email} onChange={(v) => setNewUser({ ...newUser, email: v })} type="email" placeholder="jan@assuremanager.be" />
              <Select label="Rol" value={newUser.rol} onChange={(v) => setNewUser({ ...newUser, rol: v })} options={['Beheerder', 'Manager', 'Medewerker', 'Schadebehandelaar', 'Commercieel', 'Backoffice', 'Financieel', 'Jurist', 'Lezer']} />
              <Input label="Telefoon" value={newUser.telefoon} onChange={(v) => setNewUser({ ...newUser, telefoon: v })} placeholder="+32 475 12 34 56" />
              <div className="rounded-lg" style={{ padding: '12px', backgroundColor: '#F4FAF4', border: '1px solid #E8F5E8' }}>
                <p className="text-xs" style={{ color: '#3A683A' }}>
                  Een tijdelijk wachtwoord wordt automatisch gegenereerd en per e-mail verzonden.
                </p>
              </div>
            </div>
            <div className="flex items-center justify-end gap-3" style={{ padding: '12px 20px', borderTop: '1px solid #E8EBEE' }}>
              <button onClick={() => setShowAddModal(false)} className="rounded-md text-[#3D4550] hover:bg-[#F2F4F6] transition-colors" style={{ height: '40px', padding: '0 16px', fontSize: 13, fontWeight: 500, border: '1px solid #D1D6DB' }}>
                Annuleren
              </button>
              <button onClick={addUser} className="flex items-center gap-2 rounded-md text-white font-medium transition-all hover:shadow-md" style={{ height: '40px', padding: '0 20px', backgroundColor: '#4A804A', fontSize: 13 }}>
                <UserPlus style={{ width: 15, height: 15 }} />
                Gebruiker Aanmaken
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

/* ============================================================
   Rollen & Rechten Tab
   ============================================================ */
function RollenTab() {
  const [permissions, setPermissions] = useState(defaultPermissions)
  const [expandedRole, setExpandedRole] = useState<string | null>('Beheerder')

  const togglePermission = (role: string, module: string, type: 'read' | 'write') => {
    setPermissions(prev => ({
      ...prev,
      [role]: {
        ...prev[role],
        [module]: {
          ...prev[role][module],
          [type]: !prev[role][module]?.[type],
        },
      },
    }))
  }

  const getPermissionDot = (role: string, module: string) => {
    const p = permissions[role]?.[module]
    if (!p) return { color: '#D1D6DB', icon: <Minus style={{ width: 12, height: 12 }} /> }
    if (p.write) return { color: '#4A804A', icon: <Check style={{ width: 12, height: 12 }} /> }
    if (p.read) return { color: '#D4942A', icon: <Check style={{ width: 12, height: 12 }} /> }
    return { color: '#D1D6DB', icon: <Minus style={{ width: 12, height: 12 }} /> }
  }

  return (
    <div className="space-y-4">
      {/* Legend */}
      <div className="flex items-center gap-6 flex-wrap">
        <div className="flex items-center gap-2">
          <span className="inline-block rounded-full" style={{ width: 10, height: 10, backgroundColor: '#4A804A' }} />
          <span className="text-xs" style={{ color: '#6B7785' }}>Volledige toegang</span>
        </div>
        <div className="flex items-center gap-2">
          <span className="inline-block rounded-full" style={{ width: 10, height: 10, backgroundColor: '#D4942A' }} />
          <span className="text-xs" style={{ color: '#6B7785' }}>Alleen lezen</span>
        </div>
        <div className="flex items-center gap-2">
          <span className="inline-block rounded-full" style={{ width: 10, height: 10, backgroundColor: '#D1D6DB' }} />
          <span className="text-xs" style={{ color: '#6B7785' }}>Geen toegang</span>
        </div>
      </div>

      {/* Permission matrix */}
      <div className="bg-white rounded-lg" style={{ border: '1px solid #E8EBEE' }}>
        <div className="overflow-x-auto">
          <table className="w-full border-collapse">
            <thead>
              <tr style={{ backgroundColor: '#F2F4F6', height: 44 }}>
                <th className="text-left font-semibold" style={{ padding: '0 16px', fontSize: 13, color: '#3D4550', minWidth: 160 }}>Rol</th>
                {modules.map(m => (
                  <th key={m} className="text-center font-semibold" style={{ padding: '0 12px', fontSize: 12, color: '#3D4550', minWidth: 100 }}>{m}</th>
                ))}
                <th style={{ width: 50 }} />
              </tr>
            </thead>
            <tbody>
              {rollen.map((rol) => {
                const isExpanded = expandedRole === rol
                return (
                  <>
                    <tr
                      key={rol}
                      className="transition-colors cursor-pointer hover:bg-[#F4FAF4]"
                      style={{ height: 48, backgroundColor: isExpanded ? '#F4FAF4' : '#FFFFFF', borderBottom: '1px solid #E8EBEE' }}
                      onClick={() => setExpandedRole(isExpanded ? null : rol)}
                    >
                      <td style={{ padding: '10px 16px' }}>
                        <div className="flex items-center gap-2">
                          <span className="text-sm font-medium" style={{ color: '#1A1F24' }}>{rol}</span>
                        </div>
                      </td>
                      {modules.map(m => {
                        const { color, icon } = getPermissionDot(rol, m)
                        return (
                          <td key={m} className="text-center" style={{ padding: '10px 12px' }}>
                            <span className="inline-flex items-center justify-center rounded-full text-white" style={{ width: 22, height: 22, backgroundColor: color }}>
                              {icon}
                            </span>
                          </td>
                        )
                      })}
                      <td className="text-center" style={{ color: '#6B7785' }}>
                        {isExpanded ? <ChevronDown style={{ width: 16, height: 16 }} /> : <ChevronRight style={{ width: 16, height: 16 }} />}
                      </td>
                    </tr>
                    {isExpanded && (
                      <tr key={`${rol}-detail`}>
                        <td colSpan={modules.length + 2} style={{ padding: 0, backgroundColor: '#FAFBFC' }}>
                          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4" style={{ padding: '16px 20px' }}>
                            {modules.map(m => {
                              const p = permissions[rol]?.[m]
                              return (
                                <div key={m} className="rounded-lg" style={{ padding: '12px 16px', backgroundColor: '#FFFFFF', border: '1px solid #E8EBEE' }}>
                                  <div className="text-sm font-medium mb-3" style={{ color: '#1A1F24' }}>{m}</div>
                                  <div className="space-y-2">
                                    <Toggle
                                      label="Raadplegen"
                                      checked={!!p?.read}
                                      onChange={() => togglePermission(rol, m, 'read')}
                                    />
                                    <Toggle
                                      label="Bewerken"
                                      checked={!!p?.write}
                                      onChange={() => togglePermission(rol, m, 'write')}
                                    />
                                  </div>
                                </div>
                              )
                            })}
                          </div>
                        </td>
                      </tr>
                    )}
                  </>
                )
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

/* ============================================================
   Notificaties Tab
   ============================================================ */
function NotificatiesTab() {
  const [channels, setChannels] = useState({ email: true, inApp: true, push: false })
  const [templates, setTemplates] = useState([
    { id: '1', event: 'Contract vervalt < 30 dagen', email: true, inApp: true, push: false, beschrijving: 'Herinnering voor vervaldatum' },
    { id: '2', event: 'Nieuwe schadeclaim', email: true, inApp: true, push: true, beschrijving: 'Melding bij nieuwe claim' },
    { id: '3', event: 'Schadeclaim > 30 dagen open', email: true, inApp: true, push: false, beschrijving: 'Waarschuwing lange doorlooptijd' },
    { id: '4', event: 'Contract geannuleerd', email: true, inApp: true, push: false, beschrijving: 'Melding annulering' },
    { id: '5', event: 'Nieuwe persoon geregistreerd', email: false, inApp: true, push: false, beschrijving: 'Melding registratie' },
    { id: '6', event: 'Dagelijkse samenvatting', email: true, inApp: false, push: false, beschrijving: 'Dagoverzicht met KPIs' },
    { id: '7', event: 'Commissiebetaling ontvangen', email: true, inApp: true, push: false, beschrijving: 'Boeking commissie' },
  ])
  const [expandedTemplate, setExpandedTemplate] = useState<string | null>(null)
  const [emailSubject, setEmailSubject] = useState('Herinnering: Contract {contract_nummer} vervalt op {vervaldatum}')
  const [emailBody, setEmailBody] = useState(`Beste {verzekerde_naam},\n\nUw contract {contract_nummer} met verzekeraar {maatschappij} vervalt op {vervaldatum}.\n\nPremie: {bedrag}\n\nGelieve tijdig contact op te nemen voor verlenging.\n\nMet vriendelijke groeten,\nAssureManager`)

  const toggleTemplate = (id: string, channel: 'email' | 'inApp' | 'push') => {
    setTemplates(prev => prev.map(t => t.id === id ? { ...t, [channel]: !t[channel] } : t))
  }

  return (
    <div className="space-y-5">
      {/* Master toggles */}
      <Card title="Notificatiekanalen">
        <div className="flex flex-wrap gap-8">
          <Toggle label="E-mail notificaties" checked={channels.email} onChange={(v) => setChannels({ ...channels, email: v })} />
          <Toggle label="In-app notificaties" checked={channels.inApp} onChange={(v) => setChannels({ ...channels, inApp: v })} />
          <Toggle label="Browser push" checked={channels.push} onChange={(v) => setChannels({ ...channels, push: v })} />
        </div>
      </Card>

      {/* Templates table */}
      <div className="bg-white rounded-lg" style={{ border: '1px solid #E8EBEE' }}>
        <div className="flex items-center" style={{ padding: '14px 20px', borderBottom: '1px solid #E8EBEE' }}>
          <h3 className="font-semibold" style={{ fontSize: '15px', color: '#1A1F24' }}>Notificatietemplates</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full border-collapse">
            <thead>
              <tr style={{ backgroundColor: '#F2F4F6', height: 44 }}>
                {['Gebeurtenis', 'E-mail', 'In-app', 'Push', 'Omschrijving'].map(h => (
                  <th key={h} className="text-left font-semibold" style={{ padding: '0 16px', fontSize: 13, color: '#3D4550' }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {templates.map((t, idx) => (
                <tr
                  key={t.id}
                  className="cursor-pointer transition-colors hover:bg-[#F4FAF4]"
                  style={{ height: 48, backgroundColor: idx % 2 === 1 ? '#FAFBFC' : '#FFFFFF', borderBottom: '1px solid #E8EBEE' }}
                  onClick={() => setExpandedTemplate(expandedTemplate === t.id ? null : t.id)}
                >
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#1A1F24', fontWeight: 500 }}>{t.event}</td>
                  <td style={{ padding: '10px 16px' }} onClick={(e) => e.stopPropagation()}>
                    <Toggle label="" checked={t.email} onChange={() => toggleTemplate(t.id, 'email')} />
                  </td>
                  <td style={{ padding: '10px 16px' }} onClick={(e) => e.stopPropagation()}>
                    <Toggle label="" checked={t.inApp} onChange={() => toggleTemplate(t.id, 'inApp')} />
                  </td>
                  <td style={{ padding: '10px 16px' }} onClick={(e) => e.stopPropagation()}>
                    <Toggle label="" checked={t.push} onChange={() => toggleTemplate(t.id, 'push')} />
                  </td>
                  <td style={{ padding: '10px 16px', fontSize: 13, color: '#6B7785' }}>{t.beschrijving}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Template editor */}
        {expandedTemplate && (
          <div style={{ padding: '20px', borderTop: '1px solid #E8EBEE', backgroundColor: '#FAFBFC' }}>
            <h4 className="font-semibold mb-3" style={{ fontSize: 14, color: '#1A1F24' }}>E-mailtemplate bewerken</h4>
            <div className="space-y-4">
              <Input label="Onderwerp" value={emailSubject} onChange={setEmailSubject} />
              <div>
                <label className="block text-xs font-semibold mb-1.5" style={{ color: '#3D4550' }}>Berichttekst</label>
                <textarea
                  value={emailBody}
                  onChange={(e) => setEmailBody(e.target.value)}
                  className="w-full rounded-md border border-[#D1D6DB] text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15 font-mono"
                  style={{ padding: '12px', color: '#1A1F24', minHeight: 180, resize: 'vertical' }}
                />
              </div>
              <div className="rounded-lg" style={{ padding: '12px', backgroundColor: '#E8F0F8', border: '1px solid #D6E4F0' }}>
                <p className="text-xs font-medium mb-1" style={{ color: '#3B6EA5' }}>Beschikbare placeholders:</p>
                <p className="text-xs font-mono" style={{ color: '#3B6EA5' }}>{'{verzekerde_naam}'}, {'{contract_nummer}'}, {'{vervaldatum}'}, {'{bedrag}'}, {'{maatschappij}'}</p>
              </div>
              <div className="flex gap-3">
                <button className="flex items-center gap-2 rounded-md text-white font-medium transition-all hover:shadow-md" style={{ height: '36px', padding: '0 16px', backgroundColor: '#4A804A', fontSize: 13 }}>
                  <Save style={{ width: 14, height: 14 }} />
                  Template Opslaan
                </button>
                <button className="flex items-center gap-2 rounded-md text-[#3D4550] hover:bg-[#F2F4F6] transition-colors" style={{ height: '36px', padding: '0 16px', fontSize: 13, fontWeight: 500, border: '1px solid #D1D6DB' }}>
                  <RotateCcw style={{ width: 14, height: 14 }} />
                  Reset naar standaard
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

/* ============================================================
   Audit Log Tab
   ============================================================ */
function AuditTab() {
  const [search, setSearch] = useState('')
  const [filterUser, setFilterUser] = useState('Alle')
  const [filterActie, setFilterActie] = useState('Alle')
  const [filterEntiteit, setFilterEntiteit] = useState('Alle')

  const users = ['Alle', ...Array.from(new Set(mockAuditLog.map(e => e.gebruiker)))]
  const acties = ['Alle', 'Aangemaakt', 'Bewerkt', 'Verwijderd', 'Ingelogd', 'Geexporteerd', 'Instelling gewijzigd']
  const entiteiten = ['Alle', 'Contract', 'Schadeclaim', 'Persoon', 'Systeem', 'Rapport', 'Instelling', 'Object']

  const filtered = mockAuditLog.filter(e => {
    const matchSearch = !search ||
      e.gebruiker.toLowerCase().includes(search.toLowerCase()) ||
      e.entiteit.toLowerCase().includes(search.toLowerCase())
    const matchUser = filterUser === 'Alle' || e.gebruiker === filterUser
    const matchActie = filterActie === 'Alle' || e.actie === filterActie
    const matchEntiteit = filterEntiteit === 'Alle' || e.entiteit.toLowerCase().includes(filterEntiteit.toLowerCase())
    return matchSearch && matchUser && matchActie && matchEntiteit
  })

  return (
    <div className="space-y-5">
      {/* Filters */}
      <div className="bg-white rounded-lg flex items-center gap-3 flex-wrap" style={{ border: '1px solid #E8EBEE', padding: '12px 16px' }}>
        <div className="relative">
          <Search className="absolute left-2.5 top-1/2 -translate-y-1/2 text-[#95A1AD]" style={{ width: 14, height: 14 }} />
          <input
            type="text"
            placeholder="Zoeken..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="rounded-md border border-[#D1D6DB] text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15"
            style={{ height: '34px', padding: '0 10px 0 30px', fontSize: 12, color: '#1A1F24', minWidth: 180 }}
          />
        </div>
        <select
          value={filterUser}
          onChange={(e) => setFilterUser(e.target.value)}
          className="rounded-md border border-[#D1D6DB] text-sm outline-none focus:border-[#4A804A]"
          style={{ height: '34px', padding: '0 10px', fontSize: 12, color: '#3D4550' }}
        >
          {users.map(u => <option key={u} value={u}>{u}</option>)}
        </select>
        <select
          value={filterActie}
          onChange={(e) => setFilterActie(e.target.value)}
          className="rounded-md border border-[#D1D6DB] text-sm outline-none focus:border-[#4A804A]"
          style={{ height: '34px', padding: '0 10px', fontSize: 12, color: '#3D4550' }}
        >
          {acties.map(a => <option key={a} value={a}>{a}</option>)}
        </select>
        <select
          value={filterEntiteit}
          onChange={(e) => setFilterEntiteit(e.target.value)}
          className="rounded-md border border-[#D1D6DB] text-sm outline-none focus:border-[#4A804A]"
          style={{ height: '34px', padding: '0 10px', fontSize: 12, color: '#3D4550' }}
        >
          {entiteiten.map(e => <option key={e} value={e}>{e}</option>)}
        </select>
        <div className="flex-1" />
        <button className="flex items-center gap-1.5 rounded-md text-[#3D4550] hover:bg-[#F2F4F6] transition-colors" style={{ height: '34px', padding: '0 12px', fontSize: 12, fontWeight: 500, border: '1px solid #D1D6DB' }}>
          <Download style={{ width: 14, height: 14 }} />
          Exporteer Log
        </button>
      </div>

      {/* Audit table */}
      <div className="bg-white rounded-lg" style={{ border: '1px solid #E8EBEE' }}>
        <div className="overflow-x-auto">
          <table className="w-full border-collapse">
            <thead>
              <tr style={{ backgroundColor: '#F2F4F6', height: 44 }}>
                {['Tijdstip', 'Gebruiker', 'Actie', 'Entiteit', 'Veld', 'Oude waarde', 'Nieuwe waarde', 'IP Adres'].map(h => (
                  <th key={h} className="text-left font-semibold" style={{ padding: '0 14px', fontSize: 12, color: '#3D4550', whiteSpace: 'nowrap' }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.map((entry, idx) => (
                <tr key={entry.id} style={{ height: 44, backgroundColor: idx % 2 === 1 ? '#FAFBFC' : '#FFFFFF', borderBottom: '1px solid #E8EBEE' }}>
                  <td style={{ padding: '8px 14px', fontSize: 12, color: '#6B7785', fontFamily: 'JetBrains Mono, monospace', whiteSpace: 'nowrap' }}>{entry.tijdstip}</td>
                  <td style={{ padding: '8px 14px', fontSize: 13, color: '#1A1F24', fontWeight: 500 }}>{entry.gebruiker}</td>
                  <td style={{ padding: '8px 14px' }}>
                    <StatusBadge status={actieBadge(entry.actie)}>{entry.actie}</StatusBadge>
                  </td>
                  <td style={{ padding: '8px 14px', fontSize: 12, color: '#3D4550', whiteSpace: 'nowrap' }}>{entry.entiteit}</td>
                  <td style={{ padding: '8px 14px', fontSize: 12, color: '#6B7785' }}>{entry.veld || '—'}</td>
                  <td style={{ padding: '8px 14px', fontSize: 12, color: '#C04A4A', textDecoration: entry.actie === 'Verwijderd' ? 'line-through' : undefined }}>{entry.oudeWaarde || '—'}</td>
                  <td style={{ padding: '8px 14px', fontSize: 12, color: '#4A804A' }}>{entry.nieuweWaarde || '—'}</td>
                  <td style={{ padding: '8px 14px', fontSize: 12, color: '#6B7785', fontFamily: 'JetBrains Mono, monospace' }}>{entry.ipAdres}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        {filtered.length === 0 && (
          <div className="flex flex-col items-center justify-center" style={{ padding: 48 }}>
            <Search style={{ width: 40, height: 40, color: '#D1D6DB', marginBottom: 12 }} />
            <p className="text-sm" style={{ color: '#6B7785' }}>Geen logboekvermeldingen gevonden</p>
          </div>
        )}
      </div>
    </div>
  )
}

/* ============================================================
   Backup Tab
   ============================================================ */
function BackupTab() {
  const [backupFreq, setBackupFreq] = useState('Dagelijks')
  const [showRestoreModal, setShowRestoreModal] = useState(false)
  const storageUsed = 2.4
  const storageTotal = 10
  const storagePct = (storageUsed / storageTotal) * 100

  const backupHistory = [
    { id: '1', datum: '24/05/2025 03:15', grootte: '245 MB', type: 'Automatisch', status: 'Succes' },
    { id: '2', datum: '23/05/2025 03:15', grootte: '244 MB', type: 'Automatisch', status: 'Succes' },
    { id: '3', datum: '22/05/2025 03:15', grootte: '243 MB', type: 'Automatisch', status: 'Succes' },
    { id: '4', datum: '21/05/2025 14:30', grootte: '242 MB', type: 'Handmatig', status: 'Succes' },
    { id: '5', datum: '21/05/2025 03:15', grootte: '242 MB', type: 'Automatisch', status: 'Succes' },
  ]

  return (
    <div className="space-y-5 max-w-3xl">
      {/* Backup status */}
      <Card title="Back-up Status">
        <div className="space-y-4">
          <div className="flex items-center gap-3">
            <div className="flex items-center justify-center rounded-full" style={{ width: 40, height: 40, backgroundColor: '#E8F5E8' }}>
              <Check style={{ width: 20, height: 20, color: '#4A804A' }} />
            </div>
            <div>
              <div className="text-sm font-medium" style={{ color: '#1A1F24' }}>Laatste back-up: 24 mei 2025 03:15</div>
              <div className="text-xs" style={{ color: '#6B7785' }}>Automatische dagelijkse back-up voltooid</div>
            </div>
          </div>

          <div className="flex items-center gap-4">
            <Select
              label="Back-up frequentie"
              value={backupFreq}
              onChange={setBackupFreq}
              options={['Dagelijks', 'Wekelijks', 'Maandelijks']}
            />
          </div>

          <div className="flex gap-3">
            <button className="flex items-center gap-2 rounded-md text-white font-medium transition-all hover:shadow-md" style={{ height: '40px', padding: '0 20px', backgroundColor: '#4A804A', fontSize: 13 }}>
              <Database style={{ width: 15, height: 15 }} />
              Backup Nu
            </button>
            <button
              onClick={() => setShowRestoreModal(true)}
              className="flex items-center gap-2 rounded-md text-[#3D4550] hover:bg-[#F2F4F6] transition-colors"
              style={{ height: '40px', padding: '0 20px', fontSize: 13, fontWeight: 500, border: '1px solid #D1D6DB' }}
            >
              <RotateCcw style={{ width: 15, height: 15 }} />
              Herstellen
            </button>
          </div>
        </div>
      </Card>

      {/* Storage usage */}
      <Card title="Opslaggebruik">
        <div className="space-y-3">
          <div className="flex items-center justify-between">
            <span className="text-sm" style={{ color: '#3D4550' }}>{storageUsed} GB / {storageTotal} GB gebruikt</span>
            <span className="text-sm font-medium" style={{ color: '#1A1F24' }}>{storagePct.toFixed(0)}%</span>
          </div>
          <div className="rounded-full overflow-hidden" style={{ height: 12, backgroundColor: '#E8EBEE' }}>
            <div
              className="h-full rounded-full transition-all"
              style={{
                width: `${storagePct}%`,
                backgroundColor: storagePct > 80 ? '#C04A4A' : storagePct > 60 ? '#D4942A' : '#4A804A',
              }}
            />
          </div>
          <p className="text-xs" style={{ color: '#6B7785' }}>
            Ongeveer {Math.round((storageTotal - storageUsed) / 0.08)} dagelijkse back-ups resterend
          </p>
        </div>
      </Card>

      {/* Backup history */}
      <Card title="Back-up Geschiedenis">
        <div className="overflow-x-auto">
          <table className="w-full border-collapse">
            <thead>
              <tr style={{ backgroundColor: '#F2F4F6', height: 40 }}>
                {['Datum', 'Grootte', 'Type', 'Status'].map(h => (
                  <th key={h} className="text-left font-semibold" style={{ padding: '0 14px', fontSize: 12, color: '#3D4550' }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {backupHistory.map((b, idx) => (
                <tr key={b.id} style={{ height: 44, backgroundColor: idx % 2 === 1 ? '#FAFBFC' : '#FFFFFF', borderBottom: '1px solid #E8EBEE' }}>
                  <td style={{ padding: '8px 14px', fontSize: 13, color: '#1A1F24' }}>{b.datum}</td>
                  <td style={{ padding: '8px 14px', fontSize: 13, color: '#3D4550' }}>{b.grootte}</td>
                  <td style={{ padding: '8px 14px' }}>
                    <StatusBadge status={b.type === 'Handmatig' ? 'info' : 'neutral'}>{b.type}</StatusBadge>
                  </td>
                  <td style={{ padding: '8px 14px' }}>
                    <StatusBadge status="active">{b.status}</StatusBadge>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>

      {/* Data maintenance */}
      <Card title="Data Onderhoud">
        <div className="space-y-3">
          <div className="flex items-center justify-between rounded-lg" style={{ padding: '12px 16px', backgroundColor: '#FAFBFC', border: '1px solid #E8EBEE' }}>
            <div>
              <div className="text-sm font-medium" style={{ color: '#1A1F24' }}>Gearchiveerde records</div>
              <div className="text-xs" style={{ color: '#6B7785' }}>234 records gearchiveerd</div>
            </div>
            <button className="flex items-center gap-1.5 rounded-md text-[#3D4550] hover:bg-[#F2F4F6] transition-colors" style={{ height: '32px', padding: '0 12px', fontSize: 12, fontWeight: 500, border: '1px solid #D1D6DB' }}>
              <ArchiveIcon style={{ width: 14, height: 14 }} />
              Exporteren
            </button>
          </div>
          <div className="flex items-center justify-between rounded-lg" style={{ padding: '12px 16px', backgroundColor: '#FAFBFC', border: '1px solid #E8EBEE' }}>
            <div>
              <div className="text-sm font-medium" style={{ color: '#1A1F24' }}>Dubbele detectie</div>
              <div className="text-xs" style={{ color: '#6B7785' }}>Scan op mogelijke duplicaten</div>
            </div>
            <button className="flex items-center gap-1.5 rounded-md text-[#3D4550] hover:bg-[#F2F4F6] transition-colors" style={{ height: '32px', padding: '0 12px', fontSize: 12, fontWeight: 500, border: '1px solid #D1D6DB' }}>
              <Search style={{ width: 14, height: 14 }} />
              Scannen
            </button>
          </div>
          <div className="flex items-center justify-between rounded-lg" style={{ padding: '12px 16px', backgroundColor: '#FAFBFC', border: '1px solid #E8EBEE' }}>
            <div>
              <div className="text-sm font-medium" style={{ color: '#1A1F24' }}>Opschoning</div>
              <div className="text-xs" style={{ color: '#6B7785' }}>Verwijder verlopen concepten &gt; 30 dagen</div>
            </div>
            <button className="flex items-center gap-1.5 rounded-md text-[#C04A4A] hover:bg-[#FDE8E8] transition-colors" style={{ height: '32px', padding: '0 12px', fontSize: 12, fontWeight: 500, border: '1px solid #F5C6C6' }}>
              <Trash2 style={{ width: 14, height: 14 }} />
              Opschonen
            </button>
          </div>
        </div>
      </Card>

      {/* Restore confirmation modal */}
      {showRestoreModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center" style={{ backgroundColor: 'rgba(15, 18, 21, 0.3)' }}>
          <div className="bg-white rounded-lg w-full max-w-md" style={{ boxShadow: '0 20px 60px rgba(0,0,0,0.15)' }}>
            <div className="flex items-center gap-3" style={{ padding: '20px 24px', borderBottom: '1px solid #E8EBEE' }}>
              <div className="flex items-center justify-center rounded-full" style={{ width: 40, height: 40, backgroundColor: '#FDF5E8' }}>
                <AlertTriangle style={{ width: 20, height: 20, color: '#D4942A' }} />
              </div>
              <div>
                <h3 className="font-semibold" style={{ fontSize: '16px', color: '#1A1F24' }}>Herstel bevestigen</h3>
                <p className="text-xs" style={{ color: '#6B7785' }}>Dit overschrijft huidige data</p>
              </div>
            </div>
            <div style={{ padding: '20px 24px' }}>
              <p className="text-sm" style={{ color: '#3D4550' }}>
                Weet je zeker dat je wilt herstellen vanaf een back-up? Alle wijzigingen sinds de geselecteerde back-up gaan verloren.
              </p>
            </div>
            <div className="flex items-center justify-end gap-3" style={{ padding: '12px 24px', borderTop: '1px solid #E8EBEE' }}>
              <button onClick={() => setShowRestoreModal(false)} className="rounded-md text-[#3D4550] hover:bg-[#F2F4F6] transition-colors" style={{ height: '40px', padding: '0 16px', fontSize: 13, fontWeight: 500, border: '1px solid #D1D6DB' }}>
                Annuleren
              </button>
              <button onClick={() => setShowRestoreModal(false)} className="flex items-center gap-2 rounded-md text-white font-medium transition-all hover:shadow-md" style={{ height: '40px', padding: '0 20px', backgroundColor: '#C04A4A', fontSize: 13 }}>
                <RotateCcw style={{ width: 15, height: 15 }} />
                Herstellen
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

/* ============================================================
   Archive icon (local since lucide might not have it)
   ============================================================ */
function ArchiveIcon(props: { style?: CSSProperties }) {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width={Number(props.style?.width) || 14} height={Number(props.style?.height) || 14} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <rect width="20" height="5" x="2" y="3" rx="1" />
      <path d="M4 8v11a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8" />
      <path d="M10 12h4" />
    </svg>
  )
}

/* ============================================================
   Main Page Component
   ============================================================ */
export default function BeheerPage() {
  const [activeTab, setActiveTab] = useState('algemeen')

  const renderTab = () => {
    switch (activeTab) {
      case 'algemeen': return <AlgemeenTab />
      case 'gebruikers': return <GebruikersTab />
      case 'rollen': return <RollenTab />
      case 'notificaties': return <NotificatiesTab />
      case 'audit': return <AuditTab />
      case 'backup': return <BackupTab />
      default: return <AlgemeenTab />
    }
  }

  return (
    <div className="space-y-5" style={{ maxWidth: 1200 }}>
      {/* Settings tabs */}
      <div className="bg-white rounded-lg" style={{ border: '1px solid #E8EBEE' }}>
        <div className="flex items-center overflow-x-auto" style={{ borderBottom: '1px solid #E8EBEE' }}>
          {tabs.map((tab) => {
            const Icon = tab.icon
            const isActive = activeTab === tab.key
            return (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key)}
                className="flex items-center gap-2 shrink-0 transition-colors duration-150"
                style={{
                  height: '48px',
                  padding: '0 20px',
                  fontSize: '14px',
                  fontWeight: 500,
                  color: isActive ? '#4A804A' : '#6B7785',
                  borderBottom: isActive ? '2px solid #4A804A' : '2px solid transparent',
                  backgroundColor: isActive ? '#F4FAF4' : 'transparent',
                  whiteSpace: 'nowrap',
                }}
              >
                <Icon style={{ width: 16, height: 16 }} />
                {tab.label}
              </button>
            )
          })}
        </div>

        {/* Tab content */}
        <div style={{ padding: '20px' }}>
          {renderTab()}
        </div>
      </div>
    </div>
  )
}
