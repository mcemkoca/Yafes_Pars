import { useState, useMemo } from 'react'
import {
  FileText,
  FileCheck,
  FileX,
  FileClock,
  Plus,
  Shield,
  Users,
  Car,
  Home,
  Box,
  ChevronRight,
  Download,
  Pencil,
  X,
  Check,
} from 'lucide-react'
import KPICard from '../components/KPICard'
import StatusBadge from '../components/StatusBadge'
import DataTable from '../components/DataTable'
import DetailDrawer from '../components/DetailDrawer'
import {
  contractDetails,
  statusBadgeMap,
  formatCurrency,
  formatDate,
  domeinLabelMap,
  getTypeLabel,
  getPeriodiciteitLabel,
  getIncassoLabel,
} from '../data/contractenData'
import type { ContractDetail, ContractStatus, ContractDomein, ContractType, Periodiciteit, IncassoWijze } from '../data/contractenData'

const statusTabs: { key: ContractStatus | 'ALLE'; label: string; count?: number }[] = [
  { key: 'LOPEND', label: 'Lopend', count: 3891 },
  { key: 'OPGEZEGD', label: 'Opgezegd', count: 89 },
  { key: 'GESCHORST', label: 'Geschorst', count: 34 },
  { key: 'IN_WIJZIGING', label: 'In Wijziging', count: 127 },
  { key: 'GEARCHIVEERD', label: 'Gearchiveerd', count: 12 },
  { key: 'ALLE', label: 'Alle', count: 4128 },
]

// Domain options for filter
const domeinOptions: { value: ContractDomein | ''; label: string }[] = [
  { value: '', label: 'Alle domeinen' },
  { value: 'AUTO', label: 'Auto' },
  { value: 'BRAND_EENVOUDIG', label: 'Brand Eenvoudig' },
  { value: 'BRAND_BIJZONDERE', label: 'Brand Bijzondere' },
  { value: 'LEVEN_BELEGGINGEN', label: 'Leven' },
  { value: 'HOSPITALISATIE', label: 'Hospitalisatie' },
  { value: 'ARBEIDSONGEVALLEN_COLLECTIEF', label: 'Arbeidsongeval' },
  { value: 'DIVER', label: 'Diverse' },
]

// Maatschappij options
const maatschappijOptions = [
  { value: '', label: 'Alle maatschappijen' },
  { value: 'I-001', label: 'Ethias' },
  { value: 'I-002', label: 'AG Insurance' },
  { value: 'I-003', label: 'AXA Belgium' },
  { value: 'I-004', label: 'Baloise' },
  { value: 'I-005', label: 'Allianz Belgium' },
  { value: 'I-006', label: 'Federale Verzekering' },
  { value: 'I-007', label: 'Axa Belgium' },
  { value: 'I-010', label: 'Vivium' },
  { value: 'I-011', label: 'DKV Belgium' },
  { value: 'I-012', label: 'P&V' },
]

export default function ContractenPage() {
  const [activeTab, setActiveTab] = useState<ContractStatus | 'ALLE'>('LOPEND')
  const [searchQuery, setSearchQuery] = useState('')
  const [domeinFilter, setDomeinFilter] = useState<ContractDomein | ''>('')
  const [maatschappijFilter, setMaatschappijFilter] = useState('')
  const [drawerOpen, setDrawerOpen] = useState(false)
  const [selectedContract, setSelectedContract] = useState<ContractDetail | null>(null)
  const [wizardOpen, setWizardOpen] = useState(false)
  const [wizardStep, setWizardStep] = useState(1)

  // Wizard state
  const [wizardDomein, setWizardDomein] = useState<ContractDomein>('AUTO')
  const [wizardType, setWizardType] = useState<ContractType>('AUTO_TOERISME')
  const [wizardParties, setWizardParties] = useState<string[]>([])
  const [wizardObjects, setWizardObjects] = useState<string[]>([])
  const [wizardIngangsdatum, setWizardIngangsdatum] = useState('')
  const [wizardVervaldatum, setWizardVervaldatum] = useState('')
  const [wizardPeriodiciteit, setWizardPeriodiciteit] = useState<Periodiciteit>('JAARLIJKS')
  const [wizardIncasso, setWizardIncasso] = useState<IncassoWijze>('DOMICILIERING')

  // KPI values
  const kpiValues = {
    totaal: 4128,
    lopend: 3891,
    opgezegd: 89,
    inWijziging: 127,
    verlooptBinnenkort: 127,
    inOvername: 12,
  }

  // Filtered data
  const filteredData = useMemo(() => {
    return contractDetails.filter((c) => {
      if (activeTab !== 'ALLE' && c.status !== activeTab) return false
      if (domeinFilter && c.domein !== domeinFilter) return false
      if (maatschappijFilter && c.maatschappijId !== maatschappijFilter) return false
      if (searchQuery) {
        const q = searchQuery.toLowerCase()
        const matchNum = c.contractnummer.toLowerCase().includes(q)
        const matchName = c.partijen.some((p) => p.naam.toLowerCase().includes(q) && p.rol === 'VERZEKERINGNEMER')
        return matchNum || matchName
      }
      return true
    })
  }, [activeTab, searchQuery, domeinFilter, maatschappijFilter])

  const openDetail = (contract: ContractDetail) => {
    setSelectedContract(contract)
    setDrawerOpen(true)
  }

  const openWizard = () => {
    setWizardStep(1)
    setWizardDomein('AUTO')
    setWizardType('AUTO_TOERISME')
    setWizardParties([])
    setWizardObjects([])
    setWizardIngangsdatum('')
    setWizardVervaldatum('')
    setWizardPeriodiciteit('JAARLIJKS')
    setWizardIncasso('DOMICILIERING')
    setWizardOpen(true)
  }

  const closeWizard = () => {
    setWizardOpen(false)
  }

  const nextStep = () => setWizardStep((s) => Math.min(s + 1, 5))
  const prevStep = () => setWizardStep((s) => Math.max(s - 1, 1))

  // Table columns
  const columns = [
    {
      key: 'contractnummer',
      header: 'Contractnr',
      width: 140,
      render: (row: ContractDetail) => (
        <span className="font-mono text-sm" style={{ color: '#3B6EA5' }}>
          #{row.contractnummer}
        </span>
      ),
    },
    {
      key: 'domein',
      header: 'Domein',
      width: 130,
      render: (row: ContractDetail) => (
        <span className="text-sm" style={{ color: '#1A1F24' }}>
          {domeinLabelMap[row.domein] || row.domein}
        </span>
      ),
    },
    {
      key: 'type',
      header: 'Type',
      width: 150,
      render: (row: ContractDetail) => (
        <div className="flex items-center gap-2">
          {row.domein === 'AUTO' && <Car style={{ width: '16px', height: '16px', color: '#4A804A' }} />}
          {row.domein === 'BRAND_EENVOUDIG' && <Home style={{ width: '16px', height: '16px', color: '#3B6EA5' }} />}
          {row.domein === 'BRAND_BIJZONDERE' && <Home style={{ width: '16px', height: '16px', color: '#3B6EA5' }} />}
          {row.domein === 'LEVEN_BELEGGINGEN' && <Shield style={{ width: '16px', height: '16px', color: '#C8A456' }} />}
          {row.domein === 'HOSPITALISATIE' && <Box style={{ width: '16px', height: '16px', color: '#8B5E83' }} />}
          {row.domein === 'ARBEIDSONGEVALLEN_COLLECTIEF' && <Users style={{ width: '16px', height: '16px', color: '#C07A4A' }} />}
          {(row.domein === 'DIVER' || !row.domein) && <FileText style={{ width: '16px', height: '16px', color: '#6B7785' }} />}
          <span className="text-sm" style={{ color: '#1A1F24' }}>{getTypeLabel(row.type)}</span>
        </div>
      ),
    },
    {
      key: 'verzekeringnemer',
      header: 'Verzekeringnemer',
      width: 180,
      render: (row: ContractDetail) => {
        const v = row.partijen.find((p) => p.rol === 'VERZEKERINGNEMER')
        return (
          <span className="text-sm" style={{ color: '#1A1F24' }}>
            {v?.naam || '-'}
          </span>
        )
      },
    },
    {
      key: 'maatschappij',
      header: 'Maatschappij',
      width: 140,
      render: (row: ContractDetail) => (
        <span className="text-sm" style={{ color: '#1A1F24' }}>{row.maatschappijNaam}</span>
      ),
    },
    {
      key: 'ingangsdatum',
      header: 'Ingangsdatum',
      width: 120,
      render: (row: ContractDetail) => (
        <span className="text-sm" style={{ color: '#1A1F24' }}>{formatDate(row.ingangsdatum)}</span>
      ),
    },
    {
      key: 'vervaldatum',
      header: 'Vervaldatum',
      width: 120,
      render: (row: ContractDetail) => {
        const days = row.resterendeDagen
        let color = '#1A1F24'
        if (days <= 7 && days > 0) color = '#C04A4A'
        else if (days <= 30 && days > 0) color = '#D4942A'
        return (
          <span className="text-sm font-medium" style={{ color }}>
            {formatDate(row.vervaldatum)}
          </span>
        )
      },
    },
    {
      key: 'status',
      header: 'Status',
      width: 120,
      render: (row: ContractDetail) => {
        const mapped = statusBadgeMap[row.status]
        return mapped ? (
          <StatusBadge status={mapped.variant}>{mapped.label}</StatusBadge>
        ) : (
          <span>{row.status}</span>
        )
      },
    },
  ]

  // Detail drawer tabs
  const detailTabs = selectedContract
    ? [
        {
          key: 'overzicht',
          label: 'Overzicht',
          content: <OverzichtTab contract={selectedContract} />,
        },
        {
          key: 'partijen',
          label: 'Partijen',
          content: <PartijenTab contract={selectedContract} />,
        },
        {
          key: 'objecten',
          label: 'Objecten',
          content: <ObjectenTab contract={selectedContract} />,
        },
        {
          key: 'versies',
          label: 'Versies',
          content: <VersiesTab contract={selectedContract} />,
        },
        {
          key: 'dekkingen',
          label: 'Dekkingen',
          content: <DekkingenTab contract={selectedContract} />,
        },
        {
          key: 'documenten',
          label: 'Documenten',
          content: <DocumentenTab contract={selectedContract} />,
        },
      ]
    : []

  return (
    <div className="flex flex-col gap-6">
      {/* Breadcrumb */}
      <div className="flex items-center gap-2 text-xs" style={{ color: '#6B7785' }}>
        <span>Dashboard</span>
        <ChevronRight style={{ width: '14px', height: '14px' }} />
        <span className="font-medium" style={{ color: '#3D4550' }}>Contracten</span>
      </div>

      {/* Page Title */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="font-bold" style={{ fontSize: '28px', color: '#1A1F24', letterSpacing: '-0.02em' }}>
            Contracten
          </h1>
          <p className="text-sm mt-1" style={{ color: '#6B7785' }}>
            Beheer verzekeringscontracten, polissen en dekkingen
          </p>
        </div>
        <button
          onClick={openWizard}
          className="flex items-center gap-2 rounded-md text-white font-medium transition-all duration-150 hover:opacity-90"
          style={{
            height: '40px',
            padding: '0 20px',
            backgroundColor: '#4A804A',
            fontSize: '14px',
          }}
        >
          <Plus style={{ width: '16px', height: '16px' }} />
          Nieuw Contract
        </button>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
        <KPICard
          icon={<FileText style={{ width: '20px', height: '20px' }} />}
          value={kpiValues.totaal.toLocaleString('nl-BE')}
          label="Totaal Contracten"
          trend="up"
          trendValue=""
          color="#6B7785"
          delay={0}
        />
        <KPICard
          icon={<FileCheck style={{ width: '20px', height: '20px' }} />}
          value={kpiValues.lopend.toLocaleString('nl-BE')}
          label="Lopend"
          trend="up"
          trendValue="94,3%"
          color="#4A804A"
          delay={50}
        />
        <KPICard
          icon={<FileX style={{ width: '20px', height: '20px' }} />}
          value={kpiValues.opgezegd.toString()}
          label="Opgezegd"
          trend="down"
          trendValue=""
          color="#C04A4A"
          delay={100}
        />
        <KPICard
          icon={<Pencil style={{ width: '20px', height: '20px' }} />}
          value={kpiValues.inWijziging.toString()}
          label="In Wijziging"
          trend="up"
          trendValue=""
          color="#5B8DB8"
          delay={150}
        />
        <KPICard
          icon={<FileClock style={{ width: '20px', height: '20px' }} />}
          value={kpiValues.verlooptBinnenkort.toString()}
          label="Verloopt Binnenkort"
          trend="up"
          trendValue="< 30d"
          color="#D4942A"
          delay={200}
        />
        <KPICard
          icon={<Download style={{ width: '20px', height: '20px' }} />}
          value={kpiValues.inOvername.toString()}
          label="In Overname"
          trend="up"
          trendValue=""
          color="#8B5E83"
          delay={250}
        />
      </div>

      {/* Status Tabs */}
      <div className="flex items-center gap-0" style={{ borderBottom: '1px solid #E8EBEE' }}>
        {statusTabs.map((tab) => (
          <button
            key={tab.key}
            onClick={() => setActiveTab(tab.key)}
            className="relative flex items-center gap-2 font-medium transition-colors duration-150"
            style={{
              height: '40px',
              padding: '0 20px',
              fontSize: '14px',
              color: activeTab === tab.key ? '#4A804A' : '#6B7785',
              borderBottom: activeTab === tab.key ? '2px solid #4A804A' : '2px solid transparent',
            }}
          >
            {tab.label}
            {tab.count !== undefined && (
              <span
                className="flex items-center justify-center rounded-full text-xs font-semibold"
                style={{
                  minWidth: '20px',
                  height: '20px',
                  padding: '0 6px',
                  backgroundColor: activeTab === tab.key ? '#E8F5E8' : '#F2F4F6',
                  color: activeTab === tab.key ? '#3A683A' : '#6B7785',
                }}
              >
                {tab.count.toLocaleString('nl-BE')}
              </span>
            )}
          </button>
        ))}
      </div>

      {/* Filter Bar */}
      <div className="bg-white rounded-lg" style={{ border: '1px solid #E8EBEE', padding: '12px 16px' }}>
        <div className="flex items-center gap-3 flex-wrap">
          {/* Search */}
          <div className="relative" style={{ minWidth: '220px', maxWidth: '300px' }}>
            <input
              type="text"
              placeholder="Zoek contract nr, verzekeringnemer..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full rounded-md border border-[#D1D6DB] bg-[#FAFBFC] text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15 transition-all duration-100"
              style={{ height: '36px', padding: '0 12px', fontSize: '13px', color: '#1A1F24' }}
            />
          </div>

          {/* Domein filter */}
          <select
            value={domeinFilter}
            onChange={(e) => setDomeinFilter(e.target.value as ContractDomein | '')}
            className="rounded-md border border-[#D1D6DB] bg-white text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15 transition-all duration-100"
            style={{ height: '36px', padding: '0 12px', fontSize: '13px', color: '#1A1F24' }}
          >
            {domeinOptions.map((o) => (
              <option key={o.value} value={o.value}>{o.label}</option>
            ))}
          </select>

          {/* Maatschappij filter */}
          <select
            value={maatschappijFilter}
            onChange={(e) => setMaatschappijFilter(e.target.value)}
            className="rounded-md border border-[#D1D6DB] bg-white text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15 transition-all duration-100"
            style={{ height: '36px', padding: '0 12px', fontSize: '13px', color: '#1A1F24' }}
          >
            {maatschappijOptions.map((o) => (
              <option key={o.value} value={o.value}>{o.label}</option>
            ))}
          </select>

          <div className="flex-1" />

          <button
            className="flex items-center gap-1.5 rounded-md text-[#3D4550] hover:bg-[#F2F4F6] transition-colors duration-150"
            style={{
              height: '36px',
              padding: '0 14px',
              fontSize: '13px',
              fontWeight: 500,
              border: '1px solid #D1D6DB',
            }}
          >
            <Download style={{ width: '14px', height: '14px' }} />
            Export
          </button>
        </div>
      </div>

      {/* Data Table */}
      <DataTable
        columns={columns}
        data={filteredData}
        onRowClick={openDetail}
        emptyMessage="Geen contracten gevonden"
      />

      {/* Detail Drawer */}
      {selectedContract && (
        <DetailDrawer
          open={drawerOpen}
          onClose={() => setDrawerOpen(false)}
          title={`#${selectedContract.contractnummer}`}
          subtitle={getTypeLabel(selectedContract.type)}
          badge={{
            status: statusBadgeMap[selectedContract.status].variant,
            text: statusBadgeMap[selectedContract.status].label,
          }}
          tabs={detailTabs}
        />
      )}

      {/* Wizard Modal */}
      {wizardOpen && (
        <WizardModal
          step={wizardStep}
          onClose={closeWizard}
          onNext={nextStep}
          onPrev={prevStep}
          domein={wizardDomein}
          setDomein={setWizardDomein}
          type={wizardType}
          setType={setWizardType}
          parties={wizardParties}
          setParties={setWizardParties}
          objects={wizardObjects}
          setObjects={setWizardObjects}
          ingangsdatum={wizardIngangsdatum}
          setIngangsdatum={setWizardIngangsdatum}
          vervaldatum={wizardVervaldatum}
          setVervaldatum={setWizardVervaldatum}
          periodiciteit={wizardPeriodiciteit}
          setPeriodiciteit={setWizardPeriodiciteit}
          incasso={wizardIncasso}
          setIncasso={setWizardIncasso}
        />
      )}
    </div>
  )
}

// ====== Tab Components ======

function OverzichtTab({ contract }: { contract: ContractDetail }) {
  return (
    <div className="flex flex-col gap-6">
      {/* Contractgegevens */}
      <Section title="Contractgegevens">
        <div className="grid grid-cols-2 gap-4">
          <Field label="Contractnummer" value={`#${contract.contractnummer}`} mono />
          <Field label="Domein" value={domeinLabelMap[contract.domein] || contract.domein} />
          <Field label="Type" value={getTypeLabel(contract.type)} />
          <Field label="Status" value={<StatusBadge status={statusBadgeMap[contract.status].variant}>{statusBadgeMap[contract.status].label}</StatusBadge>} />
          <Field label="Versie" value={`v${contract.versie}`} />
          <Field label="Herkomst" value={
            <span
              className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium"
              style={{ backgroundColor: '#F4FAF4', color: '#3A683A' }}
            >
              {contract.herkomst}
            </span>
          } />
        </div>
      </Section>

      {/* Looptijd */}
      <Section title="Looptijd">
        <div className="grid grid-cols-2 gap-4">
          <Field label="Ingangsdatum" value={formatDate(contract.ingangsdatum)} />
          <Field label="Vervaldatum" value={formatDate(contract.vervaldatum)} />
          <Field label="Opzegtermijn" value={contract.opzegtermijn} />
          <Field label="Automatische verlenging" value={contract.automatischeVerlenging ? 'Ja' : 'Nee'} />
          <Field label="Resterende dagen" value={`${contract.resterendeDagen} dagen`} />
        </div>
        {/* Progress bar */}
        {contract.resterendeDagen > 0 && (
          <div className="mt-3">
            <div className="w-full rounded-full" style={{ height: '6px', backgroundColor: '#E8EBEE' }}>
              <div
                className="rounded-full"
                style={{
                  height: '6px',
                  backgroundColor: contract.resterendeDagen < 30 ? '#D4942A' : '#4A804A',
                  width: `${Math.max(0, Math.min(100, 100 - (contract.resterendeDagen / 365) * 100))}%`,
                }}
              />
            </div>
          </div>
        )}
      </Section>

      {/* Premie & Commissie */}
      <Section title="Premie & Commissie">
        <div className="grid grid-cols-2 gap-4">
          <Field label="Jaarpremie" value={formatCurrency(contract.premie)} />
          <Field label="Betaalfrequentie" value={getPeriodiciteitLabel(contract.periodiciteit)} />
          <Field label="Maandpremie" value={formatCurrency(contract.maandpremie)} />
          <Field label="Commissie %" value={`${contract.provisiePct}%`} />
          <Field label="Commissie bedrag" value={`${formatCurrency(contract.provisieBedrag)}/jaar`} />
          <Field label="Incasso wijze" value={getIncassoLabel(contract.incassoWijze)} />
        </div>
      </Section>

      {/* Maatschappij */}
      <Section title="Maatschappij">
        <div className="p-4 rounded-lg" style={{ backgroundColor: '#F2F4F6', border: '1px solid #E8EBEE' }}>
          <div className="flex items-center gap-3 mb-2">
            <div className="flex items-center justify-center rounded-full" style={{ width: '36px', height: '36px', backgroundColor: '#E8F5E8' }}>
              <Shield style={{ width: '18px', height: '18px', color: '#4A804A' }} />
            </div>
            <span className="font-semibold text-sm" style={{ color: '#1A1F24' }}>{contract.maatschappijNaam}</span>
          </div>
          <div className="grid grid-cols-2 gap-2 mt-2">
            {contract.maatschappijAgentnummer && (
              <Field label="Agentnummer" value={contract.maatschappijAgentnummer} />
            )}
            {contract.maatschappijTelefoon && (
              <Field label="Contact" value={contract.maatschappijTelefoon} />
            )}
          </div>
        </div>
      </Section>

      {/* Snelle Acties */}
      <Section title="Snelle Acties">
        <div className="flex flex-wrap gap-2">
          <button className="flex items-center gap-1.5 rounded-md text-sm font-medium transition-all duration-150" style={{ padding: '8px 16px', backgroundColor: '#4A804A', color: '#FFFFFF' }}>
            <Pencil style={{ width: '14px', height: '14px' }} />
            Bewerken
          </button>
          {contract.resterendeDagen < 90 && contract.status === 'LOPEND' && (
            <button className="flex items-center gap-1.5 rounded-md text-sm font-medium transition-all duration-150" style={{ padding: '8px 16px', backgroundColor: '#F4FAF4', color: '#3A683A', border: '1px solid #E8F5E8' }}>
              <FileClock style={{ width: '14px', height: '14px' }} />
              Verlengen
            </button>
          )}
          <button className="flex items-center gap-1.5 rounded-md text-sm font-medium transition-all duration-150" style={{ padding: '8px 16px', backgroundColor: '#FDE8E8', color: '#C04A4A', border: '1px solid #FDE8E8' }}>
            <X style={{ width: '14px', height: '14px' }} />
            Annuleren
          </button>
        </div>
      </Section>
    </div>
  )
}

function PartijenTab({ contract }: { contract: ContractDetail }) {
  const roleColors: Record<string, string> = {
    VERZEKERINGNEMER: '#4A804A',
    VERZEKERDE: '#3B6EA5',
    MEDEVERZEKERDE: '#8B5E83',
    BEGUNSTIGDE: '#C8A456',
    VERZEKERAAR: '#C07A4A',
  }

  return (
    <div className="flex flex-col gap-3">
      {contract.partijen.map((p, idx) => (
        <div
          key={idx}
          className="flex items-start gap-3 p-4 rounded-lg"
          style={{ backgroundColor: idx % 2 === 0 ? '#F2F4F6' : '#FAFBFC', border: '1px solid #E8EBEE' }}
        >
          <div
            className="flex items-center justify-center rounded-full shrink-0"
            style={{
              width: '36px',
              height: '36px',
              backgroundColor: `${roleColors[p.rol] || '#6B7785'}18`,
              color: roleColors[p.rol] || '#6B7785',
            }}
          >
            {p.type === 'NP' ? <Users style={{ width: '16px', height: '16px' }} /> : <Shield style={{ width: '16px', height: '16px' }} />}
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2">
              <span className="font-medium text-sm" style={{ color: '#1A1F24' }}>{p.naam}</span>
              <span
                className="text-xs font-medium px-2 py-0.5 rounded-full"
                style={{ backgroundColor: `${roleColors[p.rol] || '#6B7785'}18`, color: roleColors[p.rol] || '#6B7785' }}
              >
                {p.rol}
              </span>
            </div>
            {p.adres && <div className="text-xs mt-1" style={{ color: '#6B7785' }}>{p.adres}</div>}
            {p.telefoon && <div className="text-xs mt-0.5" style={{ color: '#6B7785' }}>{p.telefoon}</div>}
          </div>
        </div>
      ))}
    </div>
  )
}

function ObjectenTab({ contract }: { contract: ContractDetail }) {
  if (contract.objecten.length === 0) {
    return <EmptyState message="Geen objecten gekoppeld" />
  }

  return (
    <div className="flex flex-col gap-3">
      {contract.objecten.map((obj, idx) => (
        <div
          key={idx}
          className="p-4 rounded-lg"
          style={{ backgroundColor: idx % 2 === 0 ? '#F2F4F6' : '#FAFBFC', border: '1px solid #E8EBEE' }}
        >
          <div className="flex items-center gap-2 mb-2">
            {obj.type === 'Voertuig' && <Car style={{ width: '16px', height: '16px', color: '#4A804A' }} />}
            {obj.type === 'Onroerend goed' && <Home style={{ width: '16px', height: '16px', color: '#3B6EA5' }} />}
            {obj.type === 'Algemeen' && <Box style={{ width: '16px', height: '16px', color: '#6B7785' }} />}
            <span className="font-medium text-sm" style={{ color: '#1A1F24' }}>{obj.naam}</span>
          </div>
          <div className="grid grid-cols-3 gap-3 mt-2">
            <Field label="Type" value={obj.type} />
            <Field label="Identificatie" value={obj.identificatie} mono />
            {obj.waarde && <Field label="Waarde" value={obj.waarde} />}
          </div>
          <div className="mt-2">
            <StatusBadge status={obj.status === 'Actief' ? 'active' : 'neutral'}>{obj.status}</StatusBadge>
          </div>
        </div>
      ))}
    </div>
  )
}

function VersiesTab({ contract }: { contract: ContractDetail }) {
  return (
    <div className="flex flex-col gap-3">
      {contract.versies.map((v, idx) => (
        <div
          key={idx}
          className="p-4 rounded-lg"
          style={{ backgroundColor: idx % 2 === 0 ? '#F2F4F6' : '#FAFBFC', border: '1px solid #E8EBEE' }}
        >
          <div className="flex items-center justify-between mb-2">
            <div className="flex items-center gap-2">
              <span className="font-semibold text-sm" style={{ color: '#1A1F24' }}>v{v.versie}</span>
              <StatusBadge status={v.status === 'Actief' ? 'active' : v.status === 'Vervangen' ? 'warning' : 'neutral'}>
                {v.status}
              </StatusBadge>
            </div>
            <span className="text-xs" style={{ color: '#6B7785' }}>{formatDate(v.ingangsdatum)}</span>
          </div>
          <div className="grid grid-cols-2 gap-3">
            <Field label="Premie" value={formatCurrency(v.premie)} />
            {v.wijzigingDoor && <Field label="Door" value={v.wijzigingDoor} />}
            {v.wijzigingDatum && <Field label="Datum" value={formatDate(v.wijzigingDatum)} />}
          </div>
          {v.reden && <div className="text-xs mt-2 italic" style={{ color: '#6B7785' }}>{v.reden}</div>}
        </div>
      ))}
    </div>
  )
}

function DekkingenTab({ contract }: { contract: ContractDetail }) {
  return (
    <div className="flex flex-col gap-3">
      {contract.dekkingen.map((d, idx) => (
        <div
          key={idx}
          className="flex items-center justify-between p-4 rounded-lg"
          style={{
            backgroundColor: d.inbegrepen ? '#F4FAF4' : '#F2F4F6',
            border: `1px solid ${d.inbegrepen ? '#E8F5E8' : '#E8EBEE'}`,
          }}
        >
          <div className="flex items-center gap-3">
            <div
              className="flex items-center justify-center rounded-full"
              style={{
                width: '28px',
                height: '28px',
                backgroundColor: d.inbegrepen ? '#E8F5E8' : '#F2F4F6',
              }}
            >
              {d.inbegrepen ? (
                <Check style={{ width: '14px', height: '14px', color: '#4A804A' }} />
              ) : (
                <X style={{ width: '14px', height: '14px', color: '#6B7785' }} />
              )}
            </div>
            <div>
              <div className="text-sm font-medium" style={{ color: '#1A1F24' }}>
                <span className="font-mono text-xs mr-1" style={{ color: '#6B7785' }}>{d.code}</span>
                {d.omschrijving}
              </div>
              {d.limiet && <div className="text-xs mt-0.5" style={{ color: '#6B7785' }}>Limiet: {d.limiet}</div>}
            </div>
          </div>
          {d.eigenRisico && (
            <span className="text-xs font-medium shrink-0" style={{ color: '#D4942A' }}>
              ER: {d.eigenRisico}
            </span>
          )}
        </div>
      ))}
    </div>
  )
}

function DocumentenTab({ contract }: { contract: ContractDetail }) {
  if (contract.documenten.length === 0) {
    return <EmptyState message="Geen documenten beschikbaar" />
  }

  return (
    <div className="flex flex-col gap-3">
      {contract.documenten.map((doc, idx) => (
        <div
          key={idx}
          className="flex items-center justify-between p-4 rounded-lg"
          style={{ backgroundColor: idx % 2 === 0 ? '#F2F4F6' : '#FAFBFC', border: '1px solid #E8EBEE' }}
        >
          <div className="flex items-center gap-3">
            <FileText style={{ width: '18px', height: '18px', color: '#3B6EA5' }} />
            <span className="text-sm font-medium" style={{ color: '#1A1F24' }}>{doc.naam}</span>
          </div>
          <div className="flex items-center gap-3">
            <span className="text-xs" style={{ color: '#6B7785' }}>{formatDate(doc.datum)}</span>
            <span
              className="text-xs font-medium px-2 py-0.5 rounded"
              style={{ backgroundColor: '#E8F0F8', color: '#3B6EA5' }}
            >
              {doc.type}
            </span>
          </div>
        </div>
      ))}
    </div>
  )
}

// ====== Helper Components ======

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div>
      <h3 className="font-semibold text-sm mb-3" style={{ color: '#1A1F24', fontSize: '15px' }}>{title}</h3>
      {children}
    </div>
  )
}

function Field({ label, value, mono }: { label: string; value: React.ReactNode; mono?: boolean }) {
  return (
    <div>
      <div className="text-xs mb-1" style={{ color: '#6B7785', fontWeight: 500 }}>{label}</div>
      <div className={`text-sm ${mono ? 'font-mono' : ''}`} style={{ color: '#1A1F24' }}>{value}</div>
    </div>
  )
}

function EmptyState({ message }: { message: string }) {
  return (
    <div className="flex flex-col items-center justify-center py-8">
      <FileText style={{ width: '32px', height: '32px', color: '#95A1AD', marginBottom: '8px' }} />
      <p className="text-sm" style={{ color: '#6B7785' }}>{message}</p>
    </div>
  )
}

// ====== Wizard Modal ======

interface WizardModalProps {
  step: number
  onClose: () => void
  onNext: () => void
  onPrev: () => void
  domein: ContractDomein
  setDomein: (d: ContractDomein) => void
  type: ContractType
  setType: (t: ContractType) => void
  parties: string[]
  setParties: (p: string[]) => void
  objects: string[]
  setObjects: (o: string[]) => void
  ingangsdatum: string
  setIngangsdatum: (d: string) => void
  vervaldatum: string
  setVervaldatum: (d: string) => void
  periodiciteit: Periodiciteit
  setPeriodiciteit: (p: Periodiciteit) => void
  incasso: IncassoWijze
  setIncasso: (i: IncassoWijze) => void
}

function WizardModal(props: WizardModalProps) {
  const {
    step, onClose, onNext, onPrev,
    domein, setDomein, type, setType,
    ingangsdatum, setIngangsdatum, vervaldatum, setVervaldatum,
    periodiciteit, setPeriodiciteit, incasso, setIncasso,
  } = props

  const steps = [
    { num: 1, label: 'Domein & Type' },
    { num: 2, label: 'Partijen' },
    { num: 3, label: 'Objecten' },
    { num: 4, label: 'Data & Premie' },
    { num: 5, label: 'Review' },
  ]

  const domeinTypes: Record<ContractDomein, { value: ContractType; label: string }[]> = {
    AUTO: [
      { value: 'AUTO_TOERISME', label: 'Auto Toerisme' },
      { value: 'AUTO_BROMFIETSEN', label: 'Auto Bromfietsen' },
      { value: 'AUTO_LICHTE_VRACHTWAGENS', label: 'Auto Lichte Vracht' },
      { value: 'AUTO_OMNIUM', label: 'Auto Omnium' },
      { value: 'AUTO_BA', label: 'Auto BA' },
      { value: 'AUTO_MINI_OMNIUM', label: 'Auto Mini-Omnium' },
    ],
    BRAND_EENVOUDIG: [
      { value: 'WOON_VERZEKERING', label: 'Woningverzekering' },
      { value: 'BA_PRIVAAT', label: 'BA Privaat' },
    ],
    BRAND_BIJZONDERE: [
      { value: 'BRAND_BEDRIJF', label: 'Brand Bedrijf' },
    ],
    LEVEN_BELEGGINGEN: [
      { value: 'LEVEN_OVERLIJDEN', label: 'Leven Overlijden' },
    ],
    HOSPITALISATIE: [
      { value: 'HOSPITALISATIE_INDIVIDUEEL', label: 'Hospitalisatie Individueel' },
      { value: 'HOSPITALISATIE_GROEP', label: 'Hospitalisatie Groep' },
    ],
    ARBEIDSONGEVALLEN_COLLECTIEF: [
      { value: 'ARBEIDSONGEVAL', label: 'Arbeidsongeval Collectief' },
    ],
    DIVER: [
      { value: 'RECHTSBIJSTAND', label: 'Rechtsbijstand' },
    ],
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center" style={{ pointerEvents: 'none' }}>
      {/* Backdrop */}
      <div
        className="absolute inset-0"
        style={{ backgroundColor: '#0F1215', opacity: 0.3, pointerEvents: 'auto' }}
        onClick={onClose}
      />

      {/* Modal */}
      <div
        className="relative bg-white rounded-xl flex flex-col overflow-hidden"
        style={{
          width: '600px',
          maxHeight: '80vh',
          pointerEvents: 'auto',
          boxShadow: '0 20px 60px rgba(0,0,0,0.15)',
          animation: 'scaleInModal 200ms ease-out forwards',
        }}
      >
        {/* Header */}
        <div className="shrink-0 flex items-center justify-between" style={{ padding: '20px 24px', borderBottom: '1px solid #E8EBEE' }}>
          <h2 className="font-semibold" style={{ fontSize: '18px', color: '#1A1F24' }}>Nieuw Contract</h2>
          <button
            onClick={onClose}
            className="flex items-center justify-center rounded-md text-[#95A1AD] hover:text-[#1A1F24] hover:bg-[#F2F4F6] transition-colors duration-150"
            style={{ width: '32px', height: '32px' }}
          >
            <X style={{ width: '18px', height: '18px' }} />
          </button>
        </div>

        {/* Step indicator */}
        <div className="shrink-0 flex items-center justify-center gap-2" style={{ padding: '16px 24px', borderBottom: '1px solid #E8EBEE' }}>
          {steps.map((s) => (
            <div key={s.num} className="flex items-center gap-1.5">
              <div
                className="flex items-center justify-center rounded-full text-xs font-semibold"
                style={{
                  width: '28px',
                  height: '28px',
                  backgroundColor: s.num === step ? '#4A804A' : s.num < step ? '#E8F5E8' : '#F2F4F6',
                  color: s.num === step ? '#FFFFFF' : s.num < step ? '#3A683A' : '#6B7785',
                }}
              >
                {s.num < step ? <Check style={{ width: '14px', height: '14px' }} /> : s.num}
              </div>
              <span
                className="text-xs font-medium"
                style={{ color: s.num === step ? '#4A804A' : '#6B7785' }}
              >
                {s.label}
              </span>
              {s.num < steps.length && (
                <ChevronRight style={{ width: '14px', height: '14px', color: '#D1D6DB', marginLeft: '4px' }} />
              )}
            </div>
          ))}
        </div>

        {/* Body */}
        <div className="flex-1 overflow-auto" style={{ padding: '24px' }}>
          {step === 1 && (
            <div className="flex flex-col gap-5">
              <div>
                <label className="block text-xs font-medium mb-2" style={{ color: '#3D4550' }}>Domein</label>
                <select
                  value={domein}
                  onChange={(e) => {
                    setDomein(e.target.value as ContractDomein)
                    setType(domeinTypes[e.target.value as ContractDomein][0].value)
                  }}
                  className="w-full rounded-md border border-[#D1D6DB] bg-white text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15"
                  style={{ height: '40px', padding: '0 12px' }}
                >
                  {domeinOptions.filter((d) => d.value).map((d) => (
                    <option key={d.value} value={d.value}>{d.label}</option>
                  ))}
                </select>
              </div>
              <div>
                <label className="block text-xs font-medium mb-2" style={{ color: '#3D4550' }}>Contracttype</label>
                <select
                  value={type}
                  onChange={(e) => setType(e.target.value as ContractType)}
                  className="w-full rounded-md border border-[#D1D6DB] bg-white text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15"
                  style={{ height: '40px', padding: '0 12px' }}
                >
                  {domeinTypes[domein]?.map((t) => (
                    <option key={t.value} value={t.value}>{t.label}</option>
                  ))}
                </select>
              </div>
              <div className="p-3 rounded-md" style={{ backgroundColor: '#E8F0F8', border: '1px solid #D1D6DB' }}>
                <p className="text-xs" style={{ color: '#3B6EA5' }}>
                  Geselecteerd: <strong>{domeinOptions.find((d) => d.value === domein)?.label}</strong> - <strong>{domeinTypes[domein]?.find((t) => t.value === type)?.label}</strong>
                </p>
              </div>
            </div>
          )}

          {step === 2 && (
            <div className="flex flex-col gap-4">
              <p className="text-sm" style={{ color: '#6B7785' }}>
                Voeg partijen toe aan het contract. De verzekeringnemer is verplicht.
              </p>
              {['Verzekeringnemer', 'Verzekerde', 'Medeverzekerde', 'Begunstigde'].map((rol) => (
                <div key={rol} className="flex items-center justify-between p-3 rounded-md" style={{ backgroundColor: '#F2F4F6', border: '1px solid #E8EBEE' }}>
                  <span className="text-sm font-medium" style={{ color: '#1A1F24' }}>{rol}</span>
                  <button className="flex items-center gap-1 text-xs font-medium rounded-md px-3 py-1.5 transition-colors duration-150" style={{ backgroundColor: '#F2F4F6', color: '#4A804A', border: '1px solid #D1D6DB' }}>
                    <Plus style={{ width: '12px', height: '12px' }} />
                    Toevoegen
                  </button>
                </div>
              ))}
            </div>
          )}

          {step === 3 && (
            <div className="flex flex-col gap-4">
              <p className="text-sm" style={{ color: '#6B7785' }}>
                Koppel objecten aan het contract (optioneel voor sommige types).
              </p>
              <div className="flex items-center justify-between p-3 rounded-md" style={{ backgroundColor: '#F2F4F6', border: '1px solid #E8EBEE' }}>
                <span className="text-sm font-medium" style={{ color: '#1A1F24' }}>Objecten zoeken</span>
                <button className="flex items-center gap-1 text-xs font-medium rounded-md px-3 py-1.5 transition-colors duration-150" style={{ backgroundColor: '#F2F4F6', color: '#4A804A', border: '1px solid #D1D6DB' }}>
                  <Plus style={{ width: '12px', height: '12px' }} />
                  Object koppelen
                </button>
              </div>
              <div className="p-4 rounded-md text-center" style={{ backgroundColor: '#FAFBFC', border: '1px dashed #D1D6DB' }}>
                <Box style={{ width: '24px', height: '24px', color: '#95A1AD', margin: '0 auto 8px' }} />
                <p className="text-xs" style={{ color: '#6B7785' }}>Nog geen objecten gekoppeld</p>
              </div>
            </div>
          )}

          {step === 4 && (
            <div className="flex flex-col gap-5">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-medium mb-2" style={{ color: '#3D4550' }}>Ingangsdatum</label>
                  <input
                    type="date"
                    value={ingangsdatum}
                    onChange={(e) => setIngangsdatum(e.target.value)}
                    className="w-full rounded-md border border-[#D1D6DB] bg-white text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15"
                    style={{ height: '40px', padding: '0 12px' }}
                  />
                </div>
                <div>
                  <label className="block text-xs font-medium mb-2" style={{ color: '#3D4550' }}>Vervaldatum</label>
                  <input
                    type="date"
                    value={vervaldatum}
                    onChange={(e) => setVervaldatum(e.target.value)}
                    className="w-full rounded-md border border-[#D1D6DB] bg-white text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15"
                    style={{ height: '40px', padding: '0 12px' }}
                  />
                </div>
              </div>
              <div>
                <label className="block text-xs font-medium mb-2" style={{ color: '#3D4550' }}>Periodiciteit</label>
                <select
                  value={periodiciteit}
                  onChange={(e) => setPeriodiciteit(e.target.value as Periodiciteit)}
                  className="w-full rounded-md border border-[#D1D6DB] bg-white text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15"
                  style={{ height: '40px', padding: '0 12px' }}
                >
                  <option value="JAARLIJKS">Jaarlijks</option>
                  <option value="MAANDELIJKS">Maandelijks</option>
                  <option value="DRIEMAANDELIKS">Driemaandelijks</option>
                  <option value="HALFJAARLIJKS">Halfjaarlijks</option>
                  <option value="EENMALIG">Eenmalig</option>
                </select>
              </div>
              <div>
                <label className="block text-xs font-medium mb-2" style={{ color: '#3D4550' }}>Incasso wijze</label>
                <select
                  value={incasso}
                  onChange={(e) => setIncasso(e.target.value as IncassoWijze)}
                  className="w-full rounded-md border border-[#D1D6DB] bg-white text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15"
                  style={{ height: '40px', padding: '0 12px' }}
                >
                  <option value="DOMICILIERING">Domiciliering</option>
                  <option value="KREDIETKAART">Kredietkaart</option>
                  <option value="OVERSCHRIJVING">Overschrijving</option>
                  <option value="INCASSO">Incasso</option>
                </select>
              </div>
            </div>
          )}

          {step === 5 && (
            <div className="flex flex-col gap-4">
              <div className="p-4 rounded-lg" style={{ backgroundColor: '#F4FAF4', border: '1px solid #E8F5E8' }}>
                <h3 className="font-semibold text-sm mb-3" style={{ color: '#3A683A' }}>Samenvatting</h3>
                <div className="grid grid-cols-2 gap-3">
                  <Field label="Domein" value={domeinOptions.find((d) => d.value === domein)?.label} />
                  <Field label="Type" value={domeinTypes[domein]?.find((t) => t.value === type)?.label} />
                  <Field label="Ingangsdatum" value={ingangsdatum || '-'} />
                  <Field label="Vervaldatum" value={vervaldatum || '-'} />
                  <Field label="Periodiciteit" value={periodiciteit} />
                  <Field label="Incasso" value={incasso} />
                </div>
              </div>
              <p className="text-xs" style={{ color: '#6B7785' }}>
                Controleer de gegevens en klik op &quot;Contract aanmaken&quot; om het contract op te slaan.
              </p>
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="shrink-0 flex items-center justify-between" style={{ padding: '16px 24px', borderTop: '1px solid #E8EBEE' }}>
          <button
            onClick={step === 1 ? onClose : onPrev}
            className="rounded-md text-sm font-medium transition-colors duration-150 hover:bg-[#F2F4F6]"
            style={{ padding: '10px 20px', color: '#3D4550', border: '1px solid #D1D6DB' }}
          >
            {step === 1 ? 'Annuleren' : 'Vorige'}
          </button>
          <button
            onClick={step === 5 ? onClose : onNext}
            className="rounded-md text-sm font-medium text-white transition-all duration-150 hover:opacity-90"
            style={{ padding: '10px 20px', backgroundColor: '#4A804A' }}
          >
            {step === 5 ? 'Contract aanmaken' : 'Volgende'}
          </button>
        </div>
      </div>

      <style>{`
        @keyframes scaleInModal {
          from { transform: scale(0.95); opacity: 0; }
          to { transform: scale(1); opacity: 1; }
        }
      `}</style>
    </div>
  )
}
