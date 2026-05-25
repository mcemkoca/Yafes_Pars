import { useState, useMemo } from 'react'
import {
  Car,
  Home,
  Users,
  Package,
  CalendarDays,
  FileText,
  PackageOpen,
  Bike,
  Truck,
  Search,
  Download,
  Plus,
  X,
  Copy,
  Check,
} from 'lucide-react'
import KPICard from '../components/KPICard'
import DataTable from '../components/DataTable'
import DetailDrawer from '../components/DetailDrawer'
import StatusBadge from '../components/StatusBadge'
import type { Voertuig, OnroerendGoed, Lening, Zaak, Activiteit, PersoonArbeidsongeval } from '../data/objectenData'
import {
  voertuigenData,
  onroerendGoedData,
  leningenData,
  zakenData,
  activiteitenData,
  persoonArbeidsongevalData,
  objectenKPIs,
  formatCurrency,
} from '../data/objectenData'

type CategoryTab = 'voertuigen' | 'onroerend' | 'personen' | 'zaken' | 'activiteiten' | 'leningen'

interface TabConfig {
  key: CategoryTab
  label: string
  icon: React.ReactNode
  count: number
}

const tabs: TabConfig[] = [
  { key: 'voertuigen', label: 'Voertuigen', icon: <Car style={{ width: '16px', height: '16px' }} />, count: objectenKPIs.voertuigen },
  { key: 'onroerend', label: 'Onroerende Goederen', icon: <Home style={{ width: '16px', height: '16px' }} />, count: objectenKPIs.onroerendGoed },
  { key: 'personen', label: 'Personen / AO', icon: <Users style={{ width: '16px', height: '16px' }} />, count: 156 },
  { key: 'zaken', label: 'Zaken', icon: <Package style={{ width: '16px', height: '16px' }} />, count: objectenKPIs.zaken },
  { key: 'activiteiten', label: 'Activiteiten', icon: <CalendarDays style={{ width: '16px', height: '16px' }} />, count: objectenKPIs.activiteiten },
  { key: 'leningen', label: 'Leningen', icon: <FileText style={{ width: '16px', height: '16px' }} />, count: objectenKPIs.leningen },
]

// ====== Copy Button Component ======
function CopyButton({ text }: { text: string }) {
  const [copied, setCopied] = useState(false)

  const handleCopy = (e: React.MouseEvent) => {
    e.stopPropagation()
    navigator.clipboard.writeText(text).catch(() => {})
    setCopied(true)
    setTimeout(() => setCopied(false), 1500)
  }

  return (
    <button
      onClick={handleCopy}
      className="inline-flex items-center justify-center rounded-sm ml-1 text-[#95A1AD] hover:text-[#3D4550] hover:bg-[#F2F4F6] transition-colors duration-100"
      style={{ width: '18px', height: '18px' }}
      title="Kopiëren"
    >
      {copied ? (
        <Check style={{ width: '12px', height: '12px' }} />
      ) : (
        <Copy style={{ width: '12px', height: '12px' }} />
      )}
    </button>
  )
}

// ====== Vehicle Type Icon ======
function VehicleTypeIcon({ type }: { type: Voertuig['type'] }) {
  const iconMap = {
    'Personenauto': <Car style={{ width: '16px', height: '16px' }} />,
    'Bestelwagen': <Truck style={{ width: '16px', height: '16px' }} />,
    'Motorfiets': <Bike style={{ width: '16px', height: '16px' }} />,
    'Aanhangwagen': <PackageOpen style={{ width: '16px', height: '16px' }} />,
    'Camper': <Truck style={{ width: '16px', height: '16px' }} />,
    'Oldtimer': <Car style={{ width: '16px', height: '16px' }} />,
  }
  const colorMap = {
    'Personenauto': '#4A804A',
    'Bestelwagen': '#3B6EA5',
    'Motorfiets': '#C8A456',
    'Aanhangwagen': '#8B5E83',
    'Camper': '#5B8DB8',
    'Oldtimer': '#C07A4A',
  }
  const color = colorMap[type] || '#6B7785'
  return (
    <div
      className="flex items-center justify-center rounded-full"
      style={{
        width: '32px',
        height: '32px',
        backgroundColor: `${color}18`,
        color,
      }}
    >
      {iconMap[type]}
    </div>
  )
}

// ====== Kenteken Badge ======
function KentekenBadge({ kenteken }: { kenteken: string }) {
  return (
    <span
      className="inline-block font-mono text-xs font-medium"
      style={{
        padding: '2px 8px',
        borderRadius: '4px',
        backgroundColor: '#F2F4F6',
        border: '1px solid #E8EBEE',
        color: '#1A1F24',
        fontSize: '12px',
        letterSpacing: '0.03em',
      }}
    >
      {kenteken}
    </span>
  )
}

// ====== Detail Badge ======
function DetailBadge({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex flex-col gap-0.5" style={{ padding: '8px 0' }}>
      <span className="text-xs font-medium" style={{ color: '#6B7785', fontSize: '11px', textTransform: 'uppercase', letterSpacing: '0.02em' }}>
        {label}
      </span>
      <span className="text-sm" style={{ color: '#1A1F24', fontWeight: 500 }}>
        {value}
      </span>
    </div>
  )
}

// ====== Main Page Component ======
export default function ObjectenPage() {
  const [activeTab, setActiveTab] = useState<CategoryTab>('voertuigen')
  const [drawerOpen, setDrawerOpen] = useState(false)
  const [selectedVehicle, setSelectedVehicle] = useState<Voertuig | null>(null)
  const [selectedRealEstate, setSelectedRealEstate] = useState<OnroerendGoed | null>(null)
  const [selectedLoan, setSelectedLoan] = useState<Lening | null>(null)
  const [selectedZaak, setSelectedZaak] = useState<Zaak | null>(null)
  const [selectedActivity, setSelectedActivity] = useState<Activiteit | null>(null)
  const [selectedPersoon, setSelectedPersoon] = useState<PersoonArbeidsongeval | null>(null)

  // Filter states
  const [searchQuery, setSearchQuery] = useState('')
  const [voertuigTypeFilter, setVoertuigTypeFilter] = useState('Alle')
  const [voertuigMerkFilter, setVoertuigMerkFilter] = useState('Alle')
  const [voertuigBrandstofFilter, setVoertuigBrandstofFilter] = useState('Alle')
  const [onroerendTypeFilter, setOnroerendTypeFilter] = useState('Alle')
  const [onroerendStadFilter, setOnroerendStadFilter] = useState('Alle')
  const [leningTypeFilter, setLeningTypeFilter] = useState('Alle')
  const [leningBankFilter, setLeningBankFilter] = useState('Alle')
  const [zaakSubtypeFilter, setZaakSubtypeFilter] = useState('Alle')
  const [zaakRisicoFilter, setZaakRisicoFilter] = useState('Alle')
  const [activiteitTypeFilter, setActiviteitTypeFilter] = useState('Alle')
  const [activiteitRisicoFilter, setActiviteitRisicoFilter] = useState('Alle')
  const [persoonSubtypeFilter, setPersoonSubtypeFilter] = useState('Alle')
  const [persoonRisicoFilter, setPersoonRisicoFilter] = useState('Alle')

  const openDrawer = (item: unknown) => {
    switch (activeTab) {
      case 'voertuigen':
        setSelectedVehicle(item as Voertuig)
        setSelectedRealEstate(null)
        setSelectedLoan(null)
        setSelectedZaak(null)
        setSelectedActivity(null)
        setSelectedPersoon(null)
        break
      case 'onroerend':
        setSelectedVehicle(null)
        setSelectedRealEstate(item as OnroerendGoed)
        setSelectedLoan(null)
        setSelectedZaak(null)
        setSelectedActivity(null)
        setSelectedPersoon(null)
        break
      case 'leningen':
        setSelectedVehicle(null)
        setSelectedRealEstate(null)
        setSelectedLoan(item as Lening)
        setSelectedZaak(null)
        setSelectedActivity(null)
        setSelectedPersoon(null)
        break
      case 'zaken':
        setSelectedVehicle(null)
        setSelectedRealEstate(null)
        setSelectedLoan(null)
        setSelectedZaak(item as Zaak)
        setSelectedActivity(null)
        setSelectedPersoon(null)
        break
      case 'activiteiten':
        setSelectedVehicle(null)
        setSelectedRealEstate(null)
        setSelectedLoan(null)
        setSelectedZaak(null)
        setSelectedActivity(item as Activiteit)
        setSelectedPersoon(null)
        break
      case 'personen':
        setSelectedVehicle(null)
        setSelectedRealEstate(null)
        setSelectedLoan(null)
        setSelectedZaak(null)
        setSelectedActivity(null)
        setSelectedPersoon(item as PersoonArbeidsongeval)
        break
    }
    setDrawerOpen(true)
  }

  const closeDrawer = () => {
    setDrawerOpen(false)
  }

  // ====== Filtered Data ======
  const filteredVoertuigen = useMemo(() => {
    return voertuigenData.filter((v) => {
      const matchSearch = !searchQuery ||
        v.merk.toLowerCase().includes(searchQuery.toLowerCase()) ||
        v.model.toLowerCase().includes(searchQuery.toLowerCase()) ||
        v.chassisnummer.toLowerCase().includes(searchQuery.toLowerCase()) ||
        v.kenteken.toLowerCase().includes(searchQuery.toLowerCase())
      const matchType = voertuigTypeFilter === 'Alle' || v.type === voertuigTypeFilter
      const matchMerk = voertuigMerkFilter === 'Alle' || v.merk === voertuigMerkFilter
      const matchBrandstof = voertuigBrandstofFilter === 'Alle' || v.brandstof === voertuigBrandstofFilter
      return matchSearch && matchType && matchMerk && matchBrandstof
    })
  }, [searchQuery, voertuigTypeFilter, voertuigMerkFilter, voertuigBrandstofFilter])

  const filteredOnroerend = useMemo(() => {
    return onroerendGoedData.filter((o) => {
      const matchSearch = !searchQuery ||
        o.adres.toLowerCase().includes(searchQuery.toLowerCase()) ||
        o.kadasterNummer.toLowerCase().includes(searchQuery.toLowerCase()) ||
        o.stad.toLowerCase().includes(searchQuery.toLowerCase())
      const matchType = onroerendTypeFilter === 'Alle' || o.type === onroerendTypeFilter
      const matchStad = onroerendStadFilter === 'Alle' || o.stad === onroerendStadFilter
      return matchSearch && matchType && matchStad
    })
  }, [searchQuery, onroerendTypeFilter, onroerendStadFilter])

  const filteredLeningen = useMemo(() => {
    return leningenData.filter((l) => {
      const matchSearch = !searchQuery ||
        l.begunstigde.toLowerCase().includes(searchQuery.toLowerCase()) ||
        l.bank.toLowerCase().includes(searchQuery.toLowerCase())
      const matchType = leningTypeFilter === 'Alle' || l.type === leningTypeFilter
      const matchBank = leningBankFilter === 'Alle' || l.bank === leningBankFilter
      return matchSearch && matchType && matchBank
    })
  }, [searchQuery, leningTypeFilter, leningBankFilter])

  const filteredZaken = useMemo(() => {
    return zakenData.filter((z) => {
      const matchSearch = !searchQuery ||
        z.merk.toLowerCase().includes(searchQuery.toLowerCase()) ||
        z.model.toLowerCase().includes(searchQuery.toLowerCase()) ||
        z.serienummer.toLowerCase().includes(searchQuery.toLowerCase())
      const matchSubtype = zaakSubtypeFilter === 'Alle' || z.subtype === zaakSubtypeFilter
      const matchRisico = zaakRisicoFilter === 'Alle' || z.risicocategorie === zaakRisicoFilter
      return matchSearch && matchSubtype && matchRisico
    })
  }, [searchQuery, zaakSubtypeFilter, zaakRisicoFilter])

  const filteredActiviteiten = useMemo(() => {
    return activiteitenData.filter((a) => {
      const matchSearch = !searchQuery ||
        a.beschrijving.toLowerCase().includes(searchQuery.toLowerCase()) ||
        a.locatie.toLowerCase().includes(searchQuery.toLowerCase())
      const matchType = activiteitTypeFilter === 'Alle' || a.type === activiteitTypeFilter
      const matchRisico = activiteitRisicoFilter === 'Alle' || a.risiconiveau === activiteitRisicoFilter
      return matchSearch && matchType && matchRisico
    })
  }, [searchQuery, activiteitTypeFilter, activiteitRisicoFilter])

  const filteredPersonen = useMemo(() => {
    return persoonArbeidsongevalData.filter((p) => {
      const matchSearch = !searchQuery ||
        p.beschrijving.toLowerCase().includes(searchQuery.toLowerCase()) ||
        p.naceCode.toLowerCase().includes(searchQuery.toLowerCase())
      const matchSubtype = persoonSubtypeFilter === 'Alle' || p.subtype === persoonSubtypeFilter
      const matchRisico = persoonRisicoFilter === 'Alle' || p.risicoklasse === persoonRisicoFilter
      return matchSearch && matchSubtype && matchRisico
    })
  }, [searchQuery, persoonSubtypeFilter, persoonRisicoFilter])

  // ====== Table Columns ======
  const voertuigColumns = [
    {
      key: 'type',
      header: 'Type',
      width: 48,
      render: (row: Voertuig) => <VehicleTypeIcon type={row.type} />,
    },
    {
      key: 'merkModel',
      header: 'Merk / Model',
      width: 200,
      render: (row: Voertuig) => (
        <div>
          <div className="font-medium" style={{ fontSize: '14px', color: '#1A1F24' }}>
            {row.merk} {row.model}
          </div>
          <div className="text-xs" style={{ color: '#6B7785' }}>{row.subtype}</div>
        </div>
      ),
    },
    {
      key: 'chassisnummer',
      header: 'Chassisnummer',
      width: 160,
      render: (row: Voertuig) => (
        <div className="flex items-center">
          <span
            className="font-mono text-xs truncate"
            style={{ color: '#3D4550', maxWidth: '140px', display: 'inline-block' }}
            title={row.chassisnummer}
          >
            {row.chassisnummer}
          </span>
          <CopyButton text={row.chassisnummer} />
        </div>
      ),
    },
    {
      key: 'kenteken',
      header: 'Nummerplaat',
      width: 100,
      render: (row: Voertuig) => <KentekenBadge kenteken={row.kenteken} />,
    },
    {
      key: 'bouwjaar',
      header: 'Bouwjaar',
      width: 80,
      render: (row: Voertuig) => <span className="text-sm" style={{ color: '#1A1F24' }}>{row.bouwjaar}</span>,
    },
    {
      key: 'brandstof',
      header: 'Brandstof',
      width: 90,
      render: (row: Voertuig) => <span className="text-sm" style={{ color: '#1A1F24' }}>{row.brandstof}</span>,
    },
    {
      key: 'kmStand',
      header: 'KM-stand',
      width: 90,
      render: (row: Voertuig) => (
        <span className="text-sm tabular-nums" style={{ color: '#1A1F24' }}>
          {row.kmStand.toLocaleString('nl-BE')} km
        </span>
      ),
    },
    {
      key: 'financiering',
      header: 'Financiering',
      width: 90,
      render: (row: Voertuig) => (
        <StatusBadge status={row.financiering === 'Kas' ? 'active' : row.financiering === 'Leasing' ? 'info' : 'warning'}>
          {row.financiering}
        </StatusBadge>
      ),
    },
  ]

  const onroerendColumns = [
    {
      key: 'type',
      header: 'Type',
      width: 130,
      render: (row: OnroerendGoed) => (
        <div className="flex items-center gap-2">
          <Home style={{ width: '16px', height: '16px', color: '#3B6EA5' }} />
          <span className="text-sm font-medium" style={{ color: '#1A1F24' }}>{row.type}</span>
        </div>
      ),
    },
    {
      key: 'adres',
      header: 'Adres',
      width: 220,
      render: (row: OnroerendGoed) => (
        <div>
          <div className="font-medium" style={{ fontSize: '14px', color: '#1A1F24' }}>{row.adres}</div>
          <div className="text-xs" style={{ color: '#6B7785' }}>{row.postcode} {row.stad}</div>
        </div>
      ),
    },
    {
      key: 'stad',
      header: 'Stad',
      width: 110,
      render: (row: OnroerendGoed) => <span className="text-sm" style={{ color: '#1A1F24' }}>{row.stad}</span>,
    },
    {
      key: 'bouwjaar',
      header: 'Bouwjaar',
      width: 80,
      render: (row: OnroerendGoed) => <span className="text-sm" style={{ color: '#1A1F24' }}>{row.bouwjaar || '—'}</span>,
    },
    {
      key: 'gebruikstype',
      header: 'Gebruikstype',
      width: 120,
      render: (row: OnroerendGoed) => <span className="text-sm" style={{ color: '#1A1F24' }}>{row.gebruikstype}</span>,
    },
    {
      key: 'verzekerdeRol',
      header: 'Verzekerde Rol',
      width: 130,
      render: (row: OnroerendGoed) => <span className="text-sm" style={{ color: '#1A1F24' }}>{row.verzekerdeRol}</span>,
    },
    {
      key: 'capitalen',
      header: 'Capitalen',
      width: 120,
      render: (row: OnroerendGoed) => (
        <span className="text-sm font-medium tabular-nums" style={{ color: '#1A1F24' }}>
          {formatCurrency(row.capitalen)}
        </span>
      ),
    },
  ]

  const leningColumns = [
    {
      key: 'type',
      header: 'Type',
      width: 160,
      render: (row: Lening) => (
        <span className="text-sm font-medium" style={{ color: '#1A1F24' }}>{row.type}</span>
      ),
    },
    {
      key: 'hoofdsom',
      header: 'Hoofdsom',
      width: 120,
      render: (row: Lening) => (
        <span className="text-sm font-semibold tabular-nums" style={{ color: '#1A1F24' }}>
          {formatCurrency(row.hoofdsom)}
        </span>
      ),
    },
    {
      key: 'rentevoet',
      header: 'Rentevoet',
      width: 90,
      render: (row: Lening) => (
        <span className="text-sm tabular-nums" style={{ color: '#1A1F24' }}>{row.rentevoet.toFixed(2)}%</span>
      ),
    },
    {
      key: 'periodiciteit',
      header: 'Periodiciteit',
      width: 100,
      render: (row: Lening) => <span className="text-sm" style={{ color: '#1A1F24' }}>{row.periodiciteit}</span>,
    },
    {
      key: 'looptijd',
      header: 'Looptijd',
      width: 90,
      render: (row: Lening) => (
        <span className="text-sm" style={{ color: '#1A1F24' }}>{row.looptijd} {row.looptijdType.toLowerCase()}</span>
      ),
    },
    {
      key: 'startdatum',
      header: 'Startdatum',
      width: 100,
      render: (row: Lening) => <span className="text-sm" style={{ color: '#1A1F24' }}>{row.startdatum}</span>,
    },
    {
      key: 'einddatum',
      header: 'Einddatum',
      width: 100,
      render: (row: Lening) => <span className="text-sm" style={{ color: '#1A1F24' }}>{row.einddatum}</span>,
    },
    {
      key: 'status',
      header: 'Status',
      width: 90,
      render: (row: Lening) => (
        <StatusBadge status={row.status === 'Actief' ? 'active' : 'neutral'}>{row.status}</StatusBadge>
      ),
    },
  ]

  const zaakColumns = [
    {
      key: 'subtype',
      header: 'Subtype',
      width: 110,
      render: (row: Zaak) => (
        <div className="flex items-center gap-2">
          <Package style={{ width: '14px', height: '14px', color: '#5B8DB8' }} />
          <span className="text-sm font-medium" style={{ color: '#1A1F24' }}>{row.subtype}</span>
        </div>
      ),
    },
    {
      key: 'merkModel',
      header: 'Merk / Type',
      width: 200,
      render: (row: Zaak) => (
        <div>
          <div className="font-medium" style={{ fontSize: '14px', color: '#1A1F24' }}>{row.merk} {row.model}</div>
          <div className="text-xs truncate" style={{ color: '#6B7785', maxWidth: '180px' }}>{row.beschrijving}</div>
        </div>
      ),
    },
    {
      key: 'serienummer',
      header: 'Serienummer',
      width: 150,
      render: (row: Zaak) => (
        <div className="flex items-center">
          <span className="font-mono text-xs" style={{ color: '#3D4550' }}>{row.serienummer}</span>
          <CopyButton text={row.serienummer} />
        </div>
      ),
    },
    {
      key: 'verzekerdeWaarde',
      header: 'Verzekerde Waarde',
      width: 120,
      render: (row: Zaak) => (
        <span className="text-sm font-medium tabular-nums" style={{ color: '#1A1F24' }}>
          {formatCurrency(row.verzekerdeWaarde)}
        </span>
      ),
    },
    {
      key: 'nieuwwaarde',
      header: 'Nieuwwaarde',
      width: 110,
      render: (row: Zaak) => (
        <span className="text-sm tabular-nums" style={{ color: '#6B7785' }}>{formatCurrency(row.nieuwwaarde)}</span>
      ),
    },
    {
      key: 'materiaaltype',
      header: 'Materiaaltype',
      width: 120,
      render: (row: Zaak) => <span className="text-sm" style={{ color: '#1A1F24' }}>{row.materiaaltype}</span>,
    },
    {
      key: 'risicocategorie',
      header: 'Risicocat.',
      width: 90,
      render: (row: Zaak) => (
        <StatusBadge
          status={row.risicocategorie === 'Laag' ? 'active' : row.risicocategorie === 'Middel' ? 'warning' : 'error'}
        >
          {row.risicocategorie}
        </StatusBadge>
      ),
    },
  ]

  const activiteitColumns = [
    {
      key: 'type',
      header: 'Type',
      width: 110,
      render: (row: Activiteit) => (
        <div className="flex items-center gap-2">
          <CalendarDays style={{ width: '14px', height: '14px', color: '#C8A456' }} />
          <span className="text-sm font-medium" style={{ color: '#1A1F24' }}>{row.type}</span>
        </div>
      ),
    },
    {
      key: 'beschrijving',
      header: 'Beschrijving',
      width: 240,
      render: (row: Activiteit) => (
        <div>
          <div className="font-medium truncate" style={{ fontSize: '14px', color: '#1A1F24', maxWidth: '220px' }}>
            {row.beschrijving}
          </div>
          <div className="text-xs" style={{ color: '#6B7785' }}>{row.locatie}</div>
        </div>
      ),
    },
    {
      key: 'startdatum',
      header: 'Startdatum',
      width: 100,
      render: (row: Activiteit) => <span className="text-sm" style={{ color: '#1A1F24' }}>{row.startdatum}</span>,
    },
    {
      key: 'einddatum',
      header: 'Einddatum',
      width: 100,
      render: (row: Activiteit) => <span className="text-sm" style={{ color: '#1A1F24' }}>{row.einddatum}</span>,
    },
    {
      key: 'deelnemers',
      header: 'Deelnemers',
      width: 90,
      render: (row: Activiteit) => (
        <span className="text-sm tabular-nums" style={{ color: '#1A1F24' }}>{row.deelnemers}</span>
      ),
    },
    {
      key: 'leeftijdscategorie',
      header: 'Leeftijdscat.',
      width: 100,
      render: (row: Activiteit) => <span className="text-sm" style={{ color: '#1A1F24' }}>{row.leeftijdscategorie}</span>,
    },
    {
      key: 'risiconiveau',
      header: 'Risiconiveau',
      width: 100,
      render: (row: Activiteit) => (
        <StatusBadge
          status={row.risiconiveau === 'Laag' ? 'active' : row.risiconiveau === 'Middel' ? 'warning' : 'error'}
        >
          {row.risiconiveau}
        </StatusBadge>
      ),
    },
  ]

  const persoonColumns = [
    {
      key: 'subtype',
      header: 'Subtype',
      width: 110,
      render: (row: PersoonArbeidsongeval) => (
        <div className="flex items-center gap-2">
          <Users style={{ width: '14px', height: '14px', color: '#4A804A' }} />
          <span className="text-sm font-medium" style={{ color: '#1A1F24' }}>{row.subtype}</span>
        </div>
      ),
    },
    {
      key: 'beschrijving',
      header: 'Beschrijving',
      width: 240,
      render: (row: PersoonArbeidsongeval) => (
        <div>
          <div className="font-medium truncate" style={{ fontSize: '14px', color: '#1A1F24', maxWidth: '220px' }}>
            {row.beschrijving}
          </div>
          <div className="text-xs" style={{ color: '#6B7785' }}>{row.naceCode}</div>
        </div>
      ),
    },
    {
      key: 'aantalPersonen',
      header: 'Aantal Pers.',
      width: 90,
      render: (row: PersoonArbeidsongeval) => (
        <span className="text-sm tabular-nums" style={{ color: '#1A1F24' }}>{row.aantalPersonen}</span>
      ),
    },
    {
      key: 'risicoklasse',
      header: 'Risicoklasse',
      width: 100,
      render: (row: PersoonArbeidsongeval) => (
        <StatusBadge
          status={row.risicoklasse === 'Klasse 1' ? 'active' : row.risicoklasse === 'Klasse 2' ? 'warning' : row.risicoklasse === 'Klasse 3' ? 'error' : 'info'}
        >
          {row.risicoklasse}
        </StatusBadge>
      ),
    },
    {
      key: 'naceCode',
      header: 'NACE-code',
      width: 100,
      render: (row: PersoonArbeidsongeval) => (
        <span className="font-mono text-xs" style={{ color: '#3D4550' }}>{row.naceCode}</span>
      ),
    },
    {
      key: 'leeftijdscategorie',
      header: 'Leeftijdscat.',
      width: 100,
      render: (row: PersoonArbeidsongeval) => <span className="text-sm" style={{ color: '#1A1F24' }}>{row.leeftijdscategorie}</span>,
    },
  ]

  // ====== Render Current Table ======
  const renderTable = () => {
    switch (activeTab) {
      case 'voertuigen':
        return (
          <DataTable
            columns={voertuigColumns}
            data={filteredVoertuigen}
            onRowClick={openDrawer}
            emptyMessage="Geen voertuigen gevonden"
          />
        )
      case 'onroerend':
        return (
          <DataTable
            columns={onroerendColumns}
            data={filteredOnroerend}
            onRowClick={openDrawer}
            emptyMessage="Geen onroerende goederen gevonden"
          />
        )
      case 'leningen':
        return (
          <DataTable
            columns={leningColumns}
            data={filteredLeningen}
            onRowClick={openDrawer}
            emptyMessage="Geen leningen gevonden"
          />
        )
      case 'zaken':
        return (
          <DataTable
            columns={zaakColumns}
            data={filteredZaken}
            onRowClick={openDrawer}
            emptyMessage="Geen zaken gevonden"
          />
        )
      case 'activiteiten':
        return (
          <DataTable
            columns={activiteitColumns}
            data={filteredActiviteiten}
            onRowClick={openDrawer}
            emptyMessage="Geen activiteiten gevonden"
          />
        )
      case 'personen':
        return (
          <DataTable
            columns={persoonColumns}
            data={filteredPersonen}
            onRowClick={openDrawer}
            emptyMessage="Geen personen gevonden"
          />
        )
    }
  }

  // ====== Render Contextual Filter Bar ======
  const renderFilterBar = () => {
    const baseSearch = (
      <div className="relative" style={{ minWidth: '200px', maxWidth: '320px' }}>
        <Search
          className="absolute left-3 top-1/2 -translate-y-1/2 text-[#95A1AD]"
          style={{ width: '14px', height: '14px' }}
        />
        <input
          type="text"
          placeholder={
            activeTab === 'voertuigen'
              ? 'Zoek op merk, model, chassisnummer of kenteken...'
              : activeTab === 'onroerend'
              ? 'Zoek op adres of kadasternummer...'
              : activeTab === 'leningen'
              ? 'Zoek op referentie of begunstigde...'
              : 'Zoeken...'
          }
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="w-full rounded-md border border-[#D1D6DB] bg-[#FAFBFC] text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15 transition-all duration-100"
          style={{
            height: '32px',
            padding: '0 10px 0 32px',
            fontSize: '12px',
            color: '#1A1F24',
          }}
        />
        {searchQuery && (
          <button
            onClick={() => setSearchQuery('')}
            className="absolute right-2 top-1/2 -translate-y-1/2 text-[#95A1AD] hover:text-[#3D4550]"
          >
            <X style={{ width: '12px', height: '12px' }} />
          </button>
        )}
      </div>
    )

    return (
      <div
        className="bg-white rounded-lg flex items-center gap-3 flex-wrap"
        style={{
          padding: '12px 16px',
          border: '1px solid #E8EBEE',
        }}
      >
        {baseSearch}

        {/* Contextual filters per tab */}
        {activeTab === 'voertuigen' && (
          <>
            <select
              value={voertuigTypeFilter}
              onChange={(e) => setVoertuigTypeFilter(e.target.value)}
              className="rounded-md border border-[#D1D6DB] bg-[#FAFBFC] text-xs outline-none focus:border-[#4A804A] transition-colors"
              style={{ height: '32px', padding: '0 8px', color: '#1A1F24' }}
            >
              <option value="Alle">Alle types</option>
              <option value="Personenauto">Auto</option>
              <option value="Bestelwagen">Bestelwagen</option>
              <option value="Motorfiets">Motor</option>
              <option value="Aanhangwagen">Aanhangwagen</option>
              <option value="Camper">Camper</option>
              <option value="Oldtimer">Oldtimer</option>
            </select>
            <select
              value={voertuigMerkFilter}
              onChange={(e) => setVoertuigMerkFilter(e.target.value)}
              className="rounded-md border border-[#D1D6DB] bg-[#FAFBFC] text-xs outline-none focus:border-[#4A804A] transition-colors"
              style={{ height: '32px', padding: '0 8px', color: '#1A1F24' }}
            >
              <option value="Alle">Alle merken</option>
              {Array.from(new Set(voertuigenData.map((v) => v.merk))).sort().map((merk) => (
                <option key={merk} value={merk}>{merk}</option>
              ))}
            </select>
            <select
              value={voertuigBrandstofFilter}
              onChange={(e) => setVoertuigBrandstofFilter(e.target.value)}
              className="rounded-md border border-[#D1D6DB] bg-[#FAFBFC] text-xs outline-none focus:border-[#4A804A] transition-colors"
              style={{ height: '32px', padding: '0 8px', color: '#1A1F24' }}
            >
              <option value="Alle">Alle brandstoffen</option>
              <option value="Benzine">Benzine</option>
              <option value="Diesel">Diesel</option>
              <option value="Hybride">Hybride</option>
              <option value="Elektrisch">Elektrisch</option>
            </select>
          </>
        )}

        {activeTab === 'onroerend' && (
          <>
            <select
              value={onroerendTypeFilter}
              onChange={(e) => setOnroerendTypeFilter(e.target.value)}
              className="rounded-md border border-[#D1D6DB] bg-[#FAFBFC] text-xs outline-none focus:border-[#4A804A] transition-colors"
              style={{ height: '32px', padding: '0 8px', color: '#1A1F24' }}
            >
              <option value="Alle">Alle types</option>
              <option value="Appartement">Appartement</option>
              <option value="Eengezinswoning">Eengezinswoning</option>
              <option value="Villa">Villa</option>
              <option value="Bureel">Bureel</option>
              <option value="Handelspand">Handelspand</option>
              <option value="Industrieel">Industrieel</option>
              <option value="Garagebox">Garagebox</option>
              <option value="Grond">Grond</option>
            </select>
            <select
              value={onroerendStadFilter}
              onChange={(e) => setOnroerendStadFilter(e.target.value)}
              className="rounded-md border border-[#D1D6DB] bg-[#FAFBFC] text-xs outline-none focus:border-[#4A804A] transition-colors"
              style={{ height: '32px', padding: '0 8px', color: '#1A1F24' }}
            >
              <option value="Alle">Alle steden</option>
              {Array.from(new Set(onroerendGoedData.map((o) => o.stad))).sort().map((stad) => (
                <option key={stad} value={stad}>{stad}</option>
              ))}
            </select>
          </>
        )}

        {activeTab === 'leningen' && (
          <>
            <select
              value={leningTypeFilter}
              onChange={(e) => setLeningTypeFilter(e.target.value)}
              className="rounded-md border border-[#D1D6DB] bg-[#FAFBFC] text-xs outline-none focus:border-[#4A804A] transition-colors"
              style={{ height: '32px', padding: '0 8px', color: '#1A1F24' }}
            >
              <option value="Alle">Alle types</option>
              <option value="Hypothecaire lening">Hypothecaire lening</option>
              <option value="Lening op afbetaling">Lening op afbetaling</option>
              <option value="Kredietlijn">Kredietlijn</option>
              <option value="Werkingskrediet">Werkingskrediet</option>
              <option value="Leasing">Leasing</option>
            </select>
            <select
              value={leningBankFilter}
              onChange={(e) => setLeningBankFilter(e.target.value)}
              className="rounded-md border border-[#D1D6DB] bg-[#FAFBFC] text-xs outline-none focus:border-[#4A804A] transition-colors"
              style={{ height: '32px', padding: '0 8px', color: '#1A1F24' }}
            >
              <option value="Alle">Alle banken</option>
              {Array.from(new Set(leningenData.map((l) => l.bank))).sort().map((bank) => (
                <option key={bank} value={bank}>{bank}</option>
              ))}
            </select>
          </>
        )}

        {activeTab === 'zaken' && (
          <>
            <select
              value={zaakSubtypeFilter}
              onChange={(e) => setZaakSubtypeFilter(e.target.value)}
              className="rounded-md border border-[#D1D6DB] bg-[#FAFBFC] text-xs outline-none focus:border-[#4A804A] transition-colors"
              style={{ height: '32px', padding: '0 8px', color: '#1A1F24' }}
            >
              <option value="Alle">Alle subtypes</option>
              <option value="Elektronica">Elektronica</option>
              <option value="Kunst">Kunst</option>
              <option value="Edelstenen">Edelstenen</option>
              <option value="Meubilair">Meubilair</option>
              <option value="Werktuigen">Werktuigen</option>
              <option value="Overig">Overig</option>
            </select>
            <select
              value={zaakRisicoFilter}
              onChange={(e) => setZaakRisicoFilter(e.target.value)}
              className="rounded-md border border-[#D1D6DB] bg-[#FAFBFC] text-xs outline-none focus:border-[#4A804A] transition-colors"
              style={{ height: '32px', padding: '0 8px', color: '#1A1F24' }}
            >
              <option value="Alle">Alle risico&apos;s</option>
              <option value="Laag">Laag</option>
              <option value="Middel">Middel</option>
              <option value="Hoog">Hoog</option>
            </select>
          </>
        )}

        {activeTab === 'activiteiten' && (
          <>
            <select
              value={activiteitTypeFilter}
              onChange={(e) => setActiviteitTypeFilter(e.target.value)}
              className="rounded-md border border-[#D1D6DB] bg-[#FAFBFC] text-xs outline-none focus:border-[#4A804A] transition-colors"
              style={{ height: '32px', padding: '0 8px', color: '#1A1F24' }}
            >
              <option value="Alle">Alle types</option>
              <option value="Evenement">Evenement</option>
              <option value="Wielerwedstrijd">Wielerwedstrijd</option>
              <option value="Concert">Concert</option>
              <option value="Festival">Festival</option>
              <option value="Sportevent">Sportevent</option>
              <option value="Beurs">Beurs</option>
              <option value="Catering">Catering</option>
            </select>
            <select
              value={activiteitRisicoFilter}
              onChange={(e) => setActiviteitRisicoFilter(e.target.value)}
              className="rounded-md border border-[#D1D6DB] bg-[#FAFBFC] text-xs outline-none focus:border-[#4A804A] transition-colors"
              style={{ height: '32px', padding: '0 8px', color: '#1A1F24' }}
            >
              <option value="Alle">Alle risico&apos;s</option>
              <option value="Laag">Laag</option>
              <option value="Middel">Middel</option>
              <option value="Hoog">Hoog</option>
            </select>
          </>
        )}

        {activeTab === 'personen' && (
          <>
            <select
              value={persoonSubtypeFilter}
              onChange={(e) => setPersoonSubtypeFilter(e.target.value)}
              className="rounded-md border border-[#D1D6DB] bg-[#FAFBFC] text-xs outline-none focus:border-[#4A804A] transition-colors"
              style={{ height: '32px', padding: '0 8px', color: '#1A1F24' }}
            >
              <option value="Alle">Alle subtypes</option>
              <option value="Werknemer">Werknemer</option>
              <option value="Zaakvoerder">Zaakvoerder</option>
              <option value="Statutair">Statutair</option>
              <option value="Gedetacheerd">Gedetacheerd</option>
              <option value="Student">Student</option>
            </select>
            <select
              value={persoonRisicoFilter}
              onChange={(e) => setPersoonRisicoFilter(e.target.value)}
              className="rounded-md border border-[#D1D6DB] bg-[#FAFBFC] text-xs outline-none focus:border-[#4A804A] transition-colors"
              style={{ height: '32px', padding: '0 8px', color: '#1A1F24' }}
            >
              <option value="Alle">Alle klassen</option>
              <option value="Klasse 1">Klasse 1</option>
              <option value="Klasse 2">Klasse 2</option>
              <option value="Klasse 3">Klasse 3</option>
              <option value="Klasse 4">Klasse 4</option>
            </select>
          </>
        )}

        <div className="flex-1" />

        <button
          className="flex items-center gap-1.5 rounded-md text-[#3D4550] hover:bg-[#F2F4F6] transition-colors duration-150"
          style={{
            height: '32px',
            padding: '0 12px',
            fontSize: '12px',
            fontWeight: 500,
            border: '1px solid #D1D6DB',
          }}
        >
          <Download style={{ width: '14px', height: '14px' }} />
          Export
        </button>

        <button
          className="flex items-center gap-1.5 rounded-md text-white transition-colors duration-150"
          style={{
            height: '32px',
            padding: '0 14px',
            fontSize: '12px',
            fontWeight: 500,
            backgroundColor: '#4A804A',
          }}
        >
          <Plus style={{ width: '14px', height: '14px' }} />
          Nieuw
        </button>
      </div>
    )
  }

  // ====== Detail Drawer Tabs Content ======
  const getVehicleTabs = (v: Voertuig | null) => {
    if (!v) return []
    return [
      {
        key: 'overzicht',
        label: 'Overzicht',
        content: (
          <div className="space-y-6">
            {/* Basisgegevens */}
            <div>
              <h3 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24', fontSize: '15px' }}>Basisgegevens</h3>
              <div className="grid grid-cols-2 gap-x-6">
                <DetailBadge label="Merk" value={v.merk} />
                <DetailBadge label="Model" value={v.model} />
                <DetailBadge label="Type" value={v.type} />
                <DetailBadge label="Uitvoering" value={`${v.subtype} ${v.bouwjaar}`} />
                <div className="flex flex-col gap-0.5" style={{ padding: '8px 0' }}>
                  <span className="text-xs font-medium" style={{ color: '#6B7785', fontSize: '11px', textTransform: 'uppercase', letterSpacing: '0.02em' }}>Chassisnummer</span>
                  <div className="flex items-center">
                    <span className="font-mono text-sm" style={{ color: '#1A1F24', fontWeight: 500 }}>{v.chassisnummer}</span>
                    <CopyButton text={v.chassisnummer} />
                  </div>
                </div>
                <DetailBadge label="Kenteken" value={v.kenteken} />
                <DetailBadge label="Bouwjaar" value={String(v.bouwjaar)} />
                <DetailBadge label="Eerste inschrijving" value={v.eersteInschrijving} />
              </div>
            </div>

            {/* Eigenaar */}
            <div style={{ borderTop: '1px solid #E8EBEE', paddingTop: '16px' }}>
              <h3 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24', fontSize: '15px' }}>Eigenaar</h3>
              <div className="grid grid-cols-2 gap-x-6">
                <DetailBadge label="Naam" value={v.eigenaar} />
                <DetailBadge label="Financiering" value={v.financiering} />
              </div>
            </div>

            {/* Contract */}
            {v.contractRef && (
              <div style={{ borderTop: '1px solid #E8EBEE', paddingTop: '16px' }}>
                <h3 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24', fontSize: '15px' }}>Contract</h3>
                <div className="grid grid-cols-2 gap-x-6">
                  <DetailBadge label="Contractnr." value={v.contractRef} />
                  <DetailBadge label="Status" value="Actief" />
                </div>
              </div>
            )}

            {/* Waarde */}
            <div style={{ borderTop: '1px solid #E8EBEE', paddingTop: '16px' }}>
              <h3 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24', fontSize: '15px' }}>Waarde</h3>
              <div className="grid grid-cols-2 gap-x-6">
                <DetailBadge label="Aankoopprijs" value={formatCurrency(v.aankoopprijs)} />
                <DetailBadge label="Huidige waarde" value={formatCurrency(v.huidigeWaarde)} />
              </div>
            </div>
          </div>
        ),
      },
      {
        key: 'technisch',
        label: 'Technische Gegevens',
        content: (
          <div className="space-y-2">
            <DetailBadge label="Vermogen" value={`${v.vermogenPk} pk (${v.vermogenKw} kW)`} />
            <DetailBadge label="Cilinderinhoud" value={`${v.cilinderinhoud} cm³`} />
            <DetailBadge label="Brandstof" value={v.brandstof} />
            <DetailBadge label="Transmissie" value={v.transmissie} />
            <DetailBadge label="Aandrijving" value={v.aandrijving} />
            <DetailBadge label="Gewicht" value={`${v.gewicht} kg`} />
            <DetailBadge label="Kleur" value={v.kleur} />
            <DetailBadge label="Aantal deuren" value={String(v.aantalDeuren)} />
            <DetailBadge label="Zitplaatsen" value={String(v.zitplaatsen)} />
            <DetailBadge label="CO₂-uitstoot" value={`${v.co2Uitstoot} g/km`} />
            <DetailBadge label="Euro norm" value={v.euroNorm} />
            <DetailBadge label="APK vervaldatum" value={v.apkVervaldatum} />
            <DetailBadge label="KM-stand" value={`${v.kmStand.toLocaleString('nl-BE')} km`} />
          </div>
        ),
      },
      {
        key: 'verzekering',
        label: 'Verzekering',
        content: (
          <div className="space-y-4">
            {v.contractRef ? (
              <>
                <DetailBadge label="Contract" value={v.contractRef} />
                <DetailBadge label="Status" value="Actief" />
                <DetailBadge label="Verzekerde waarde" value={formatCurrency(v.huidigeWaarde)} />
              </>
            ) : (
              <p className="text-sm" style={{ color: '#6B7785' }}>Geen actief contract gekoppeld.</p>
            )}
          </div>
        ),
      },
      {
        key: 'geschiedenis',
        label: 'Geschiedenis',
        content: (
          <div className="space-y-4">
            <DetailBadge label="Eerste inschrijving" value={v.eersteInschrijving} />
            <DetailBadge label="Laatste wijziging" value="Niet beschikbaar" />
            <DetailBadge label="KM-stand registratie" value={`${v.kmStand.toLocaleString('nl-BE')} km`} />
          </div>
        ),
      },
    ]
  }

  const getOnroerendTabs = (o: OnroerendGoed | null) => {
    if (!o) return []
    return [
      {
        key: 'overzicht',
        label: 'Overzicht',
        content: (
          <div className="space-y-6">
            <div>
              <h3 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24', fontSize: '15px' }}>Basisgegevens</h3>
              <div className="grid grid-cols-2 gap-x-6">
                <DetailBadge label="Type" value={o.type} />
                <DetailBadge label="Adres" value={`${o.adres}, ${o.postcode} ${o.stad}`} />
                <DetailBadge label="Bouwjaar" value={o.bouwjaar ? String(o.bouwjaar) : '—'} />
                <DetailBadge label="Gebruikstype" value={o.gebruikstype} />
                <DetailBadge label="Verzekerde rol" value={o.verzekerdeRol} />
                <DetailBadge label="Kadaster" value={o.kadasterNummer} />
              </div>
            </div>
            <div style={{ borderTop: '1px solid #E8EBEE', paddingTop: '16px' }}>
              <h3 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24', fontSize: '15px' }}>Oppervlakte</h3>
              <div className="grid grid-cols-2 gap-x-6">
                <DetailBadge label="Oppervlakte" value={`${o.oppervlakte} m²`} />
                <DetailBadge label="Verdiepingen" value={String(o.aantalVerdiepingen)} />
              </div>
            </div>
            <div style={{ borderTop: '1px solid #E8EBEE', paddingTop: '16px' }}>
              <h3 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24', fontSize: '15px' }}>Capitalen</h3>
              <DetailBadge label="Verzekerde capitalen" value={formatCurrency(o.capitalen)} />
            </div>
          </div>
        ),
      },
      {
        key: 'bouwkundig',
        label: 'Bouwkundig',
        content: (
          <div className="space-y-2">
            <DetailBadge label="Constructietype" value={o.constructieType} />
            <DetailBadge label="Daktype" value={o.dakType} />
            <DetailBadge label="Nabijheid" value={o.nabijheid} />
            <DetailBadge label="Bezettingsgraad" value={o.bezettingsgraad} />
            <DetailBadge label="Oppervlakte" value={`${o.oppervlakte} m²`} />
            <DetailBadge label="Verdiepingen" value={String(o.aantalVerdiepingen)} />
          </div>
        ),
      },
      {
        key: 'kapitalen',
        label: 'Verzekerde Kapitalen',
        content: (
          <div className="space-y-2">
            <DetailBadge label="Capitalen" value={formatCurrency(o.capitalen)} />
            <DetailBadge label="Kadaster" value={o.kadasterNummer} />
          </div>
        ),
      },
      {
        key: 'beveiliging',
        label: 'Huisbraakbeveiliging',
        content: (
          <div className="space-y-2">
            <DetailBadge label="Brandblusser" value={o.brandblusser ? 'Ja' : 'Nee'} />
            <DetailBadge label="Alarmsysteem" value={o.alarmSysteem ? 'Ja' : 'Nee'} />
            <DetailBadge label="Rolluiken" value={o.rolluiken ? 'Ja' : 'Nee'} />
          </div>
        ),
      },
      {
        key: 'contracten',
        label: 'Contracten',
        content: (
          <div className="space-y-4">
            {o.contractRef ? (
              <DetailBadge label="Contract" value={o.contractRef} />
            ) : (
              <p className="text-sm" style={{ color: '#6B7785' }}>Geen actief contract gekoppeld.</p>
            )}
          </div>
        ),
      },
    ]
  }

  const getLeningTabs = (l: Lening | null) => {
    if (!l) return []
    return [
      {
        key: 'overzicht',
        label: 'Overzicht',
        content: (
          <div className="space-y-6">
            <div className="grid grid-cols-2 gap-x-6">
              <DetailBadge label="Type" value={l.type} />
              <DetailBadge label="Hoofdsom" value={formatCurrency(l.hoofdsom)} />
              <DetailBadge label="Rentevoet" value={`${l.rentevoet.toFixed(2)}%`} />
              <DetailBadge label="Periodiciteit" value={l.periodiciteit} />
              <DetailBadge label="Looptijd" value={`${l.looptijd} ${l.looptijdType.toLowerCase()}`} />
              <DetailBadge label="Bank" value={l.bank} />
            </div>
            <div style={{ borderTop: '1px solid #E8EBEE', paddingTop: '16px' }}>
              <h3 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24', fontSize: '15px' }}>Datums</h3>
              <div className="grid grid-cols-2 gap-x-6">
                <DetailBadge label="Startdatum" value={l.startdatum} />
                <DetailBadge label="Einddatum" value={l.einddatum} />
              </div>
            </div>
            <div style={{ borderTop: '1px solid #E8EBEE', paddingTop: '16px' }}>
              <h3 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24', fontSize: '15px' }}>Status</h3>
              <div className="grid grid-cols-2 gap-x-6">
                <DetailBadge label="Status" value={l.status} />
                <DetailBadge label="Restkapitaal" value={formatCurrency(l.restKapitaal)} />
                <DetailBadge label="Begunstigde" value={l.begunstigde} />
              </div>
            </div>
          </div>
        ),
      },
      {
        key: 'contract',
        label: 'Contract',
        content: (
          <div className="space-y-4">
            {l.contractRef ? (
              <DetailBadge label="Contract" value={l.contractRef} />
            ) : (
              <p className="text-sm" style={{ color: '#6B7785' }}>Geen contract gekoppeld.</p>
            )}
          </div>
        ),
      },
    ]
  }

  const getZaakTabs = (z: Zaak | null) => {
    if (!z) return []
    return [
      {
        key: 'overzicht',
        label: 'Overzicht',
        content: (
          <div className="space-y-6">
            <div className="grid grid-cols-2 gap-x-6">
              <DetailBadge label="Subtype" value={z.subtype} />
              <DetailBadge label="Merk / Model" value={`${z.merk} ${z.model}`} />
              <DetailBadge label="Serienummer" value={z.serienummer} />
              <DetailBadge label="Materiaaltype" value={z.materiaaltype} />
              <DetailBadge label="Risicocategorie" value={z.risicocategorie} />
              <DetailBadge label="Eigenaar" value={z.eigenaar} />
            </div>
            <div style={{ borderTop: '1px solid #E8EBEE', paddingTop: '16px' }}>
              <h3 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24', fontSize: '15px' }}>Waarde</h3>
              <div className="grid grid-cols-3 gap-x-6">
                <DetailBadge label="Verzekerde waarde" value={formatCurrency(z.verzekerdeWaarde)} />
                <DetailBadge label="Nieuwwaarde" value={formatCurrency(z.nieuwwaarde)} />
                <DetailBadge label="Huidige waarde" value={formatCurrency(z.huidigeWaarde)} />
              </div>
            </div>
          </div>
        ),
      },
      {
        key: 'contract',
        label: 'Contract',
        content: (
          <div className="space-y-4">
            {z.contractRef ? (
              <DetailBadge label="Contract" value={z.contractRef} />
            ) : (
              <p className="text-sm" style={{ color: '#6B7785' }}>Geen contract gekoppeld.</p>
            )}
          </div>
        ),
      },
    ]
  }

  const getActiviteitTabs = (a: Activiteit | null) => {
    if (!a) return []
    return [
      {
        key: 'overzicht',
        label: 'Overzicht',
        content: (
          <div className="space-y-6">
            <div className="grid grid-cols-2 gap-x-6">
              <DetailBadge label="Type" value={a.type} />
              <DetailBadge label="Beschrijving" value={a.beschrijving} />
              <DetailBadge label="Locatie" value={a.locatie} />
              <DetailBadge label="Organisator" value={a.organisator} />
              <DetailBadge label="Start" value={`${a.startdatum} ${a.startTijd}`} />
              <DetailBadge label="Einde" value={`${a.einddatum} ${a.eindTijd}`} />
              <DetailBadge label="Deelnemers" value={String(a.deelnemers)} />
              <DetailBadge label="Leeftijdscat." value={a.leeftijdscategorie} />
              <DetailBadge label="Risiconiveau" value={a.risiconiveau} />
            </div>
          </div>
        ),
      },
      {
        key: 'contract',
        label: 'Contract',
        content: (
          <div className="space-y-4">
            {a.contractRef ? (
              <DetailBadge label="Contract" value={a.contractRef} />
            ) : (
              <p className="text-sm" style={{ color: '#6B7785' }}>Geen contract gekoppeld.</p>
            )}
          </div>
        ),
      },
    ]
  }

  const getPersoonTabs = (p: PersoonArbeidsongeval | null) => {
    if (!p) return []
    return [
      {
        key: 'overzicht',
        label: 'Overzicht',
        content: (
          <div className="space-y-6">
            <div className="grid grid-cols-2 gap-x-6">
              <DetailBadge label="Subtype" value={p.subtype} />
              <DetailBadge label="Beschrijving" value={p.beschrijving} />
              <DetailBadge label="Aantal personen" value={String(p.aantalPersonen)} />
              <DetailBadge label="Risicoklasse" value={p.risicoklasse} />
              <DetailBadge label="NACE-code" value={p.naceCode} />
              <DetailBadge label="Leeftijdscat." value={p.leeftijdscategorie} />
              <DetailBadge label="Geslacht" value={p.geslacht === 'M' ? 'Man' : p.geslacht === 'V' ? 'Vrouw' : 'Onbekend'} />
              <DetailBadge label="Startdatum" value={p.startdatum} />
            </div>
          </div>
        ),
      },
      {
        key: 'contract',
        label: 'Contract',
        content: (
          <div className="space-y-4">
            {p.contractRef ? (
              <DetailBadge label="Contract" value={p.contractRef} />
            ) : (
              <p className="text-sm" style={{ color: '#6B7785' }}>Geen contract gekoppeld.</p>
            )}
          </div>
        ),
      },
    ]
  }

  // ====== Drawer Config ======
  const getDrawerConfig = () => {
    switch (activeTab) {
      case 'voertuigen':
        return {
          title: selectedVehicle ? `${selectedVehicle.merk} ${selectedVehicle.model}` : '',
          subtitle: selectedVehicle ? selectedVehicle.eigenaar : '',
          badge: selectedVehicle ? { status: 'active' as const, text: selectedVehicle.type } : undefined,
          tabs: getVehicleTabs(selectedVehicle),
        }
      case 'onroerend':
        return {
          title: selectedRealEstate ? selectedRealEstate.adres : '',
          subtitle: selectedRealEstate ? `${selectedRealEstate.postcode} ${selectedRealEstate.stad}` : '',
          badge: selectedRealEstate ? { status: 'info' as const, text: selectedRealEstate.type } : undefined,
          tabs: getOnroerendTabs(selectedRealEstate),
        }
      case 'leningen':
        return {
          title: selectedLoan ? selectedLoan.type : '',
          subtitle: selectedLoan ? selectedLoan.begunstigde : '',
          badge: selectedLoan ? { status: 'active' as const, text: selectedLoan.status } : undefined,
          tabs: getLeningTabs(selectedLoan),
        }
      case 'zaken':
        return {
          title: selectedZaak ? `${selectedZaak.merk} ${selectedZaak.model}` : '',
          subtitle: selectedZaak ? selectedZaak.eigenaar : '',
          badge: selectedZaak ? { status: 'warning' as const, text: selectedZaak.subtype } : undefined,
          tabs: getZaakTabs(selectedZaak),
        }
      case 'activiteiten':
        return {
          title: selectedActivity ? selectedActivity.beschrijving : '',
          subtitle: selectedActivity ? selectedActivity.locatie : '',
          badge: selectedActivity ? { status: 'info' as const, text: selectedActivity.type } : undefined,
          tabs: getActiviteitTabs(selectedActivity),
        }
      case 'personen':
        return {
          title: selectedPersoon ? selectedPersoon.beschrijving : '',
          subtitle: selectedPersoon ? selectedPersoon.naceCode : '',
          badge: selectedPersoon ? { status: 'active' as const, text: selectedPersoon.subtype } : undefined,
          tabs: getPersoonTabs(selectedPersoon),
        }
    }
  }

  const drawerConfig = getDrawerConfig()

  return (
    <div className="space-y-6">
      {/* Breadcrumb */}
      <div className="flex items-center gap-2 text-xs" style={{ color: '#6B7785' }}>
        <span>Dashboard</span>
        <span style={{ color: '#95A1AD' }}>/</span>
        <span style={{ color: '#3D4550', fontWeight: 500 }}>Objecten</span>
      </div>

      {/* Page Title */}
      <div>
        <h1
          className="font-bold"
          style={{ fontSize: '28px', color: '#1A1F24', letterSpacing: '-0.02em', lineHeight: 1.2 }}
        >
          Objecten
        </h1>
        <p className="text-sm mt-1" style={{ color: '#6B7785' }}>
          Beheer alle verzekerde objecten: voertuigen, onroerende goederen, leningen, zaken en activiteiten.
        </p>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-6 gap-4">
        <KPICard
          icon={<PackageOpen style={{ width: '22px', height: '22px' }} />}
          value="3.421"
          label="Totaal Objecten"
          trend="up"
          trendValue="2.4%"
          color="#3D4550"
          delay={0}
        />
        <KPICard
          icon={<Car style={{ width: '22px', height: '22px' }} />}
          value="892"
          label="Voertuigen"
          subtitle="Auto, motor, aanhangwagen"
          trend="up"
          trendValue="5.1%"
          color="#4A804A"
          delay={50}
        />
        <KPICard
          icon={<Home style={{ width: '22px', height: '22px' }} />}
          value="456"
          label="Onroerende Goederen"
          subtitle="Woningen & appartementen"
          trend="up"
          trendValue="1.8%"
          color="#3B6EA5"
          delay={100}
        />
        <KPICard
          icon={<FileText style={{ width: '22px', height: '22px' }} />}
          value="234"
          label="Leningen"
          subtitle="Hypothecaire & afbetaling"
          trend="down"
          trendValue="0.5%"
          color="#C8A456"
          delay={150}
        />
        <KPICard
          icon={<Package style={{ width: '22px', height: '22px' }} />}
          value="1.203"
          label="Zaken"
          subtitle="Kunst, edelstenen, overige"
          trend="up"
          trendValue="3.2%"
          color="#5B8DB8"
          delay={200}
        />
        <KPICard
          icon={<CalendarDays style={{ width: '22px', height: '22px' }} />}
          value="636"
          label="Activiteiten"
          subtitle="Evenementen & wedstrijden"
          trend="up"
          trendValue="8.7%"
          color="#8B5E83"
          delay={250}
        />
      </div>

      {/* Category Tabs */}
      <div className="bg-white rounded-lg" style={{ border: '1px solid #E8EBEE' }}>
        <div className="flex items-center" style={{ borderBottom: '1px solid #E8EBEE' }}>
          {tabs.map((tab) => {
            const isActive = activeTab === tab.key
            return (
              <button
                key={tab.key}
                onClick={() => {
                  setActiveTab(tab.key)
                  setSearchQuery('')
                }}
                className="relative flex items-center gap-2 transition-colors duration-150"
                style={{
                  height: '48px',
                  padding: '0 20px',
                  fontSize: '14px',
                  fontWeight: 600,
                  color: isActive ? '#4A804A' : '#6B7785',
                  backgroundColor: isActive ? '#F4FAF4' : 'transparent',
                  borderBottom: isActive ? '2px solid #4A804A' : '2px solid transparent',
                  whiteSpace: 'nowrap',
                }}
              >
                {tab.icon}
                <span>{tab.label}</span>
                <span
                  className="text-xs"
                  style={{
                    color: isActive ? '#4A804A' : '#95A1AD',
                    fontWeight: 500,
                  }}
                >
                  ({tab.count.toLocaleString('nl-BE')})
                </span>
              </button>
            )
          })}
        </div>

        {/* Tab Content */}
        <div className="p-4 space-y-4">
          {/* Filter Bar */}
          {renderFilterBar()}

          {/* Table */}
          {renderTable()}
        </div>
      </div>

      {/* Detail Drawer */}
      {drawerConfig && (
        <DetailDrawer
          open={drawerOpen}
          onClose={closeDrawer}
          title={drawerConfig.title}
          subtitle={drawerConfig.subtitle}
          badge={drawerConfig.badge}
          tabs={drawerConfig.tabs}
        />
      )}
    </div>
  )
}
