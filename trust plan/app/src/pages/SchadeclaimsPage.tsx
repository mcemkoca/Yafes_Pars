import { useState, useMemo } from 'react'
import {
  AlertCircle,
  AlertTriangle,
  CheckCircle,
  Clock,
  Euro,
  Plus,
  Car,
  Flame,
  Droplets,
  ShieldAlert,
  GlassWater,
  CloudLightning,
  Hammer,
  ChevronRight,
  Download,
  X,
  Check,
  Users,
  FileText,
  MapPin,
  Phone,
} from 'lucide-react'
import KPICard from '../components/KPICard'
import StatusBadge from '../components/StatusBadge'
import DataTable from '../components/DataTable'
import DetailDrawer from '../components/DetailDrawer'
import {
  claimDetails,
  statusBadgeMap,
  formatCurrency,
  formatDate,
} from '../data/schadeclaimsData'
import type { ClaimDetail, ClaimStatus, IncidentType } from '../data/schadeclaimsData'

const statusTabs: { key: ClaimStatus | 'ALLE'; label: string; count?: number }[] = [
  { key: 'OPENSTAAND', label: 'Openstaand', count: 38 },
  { key: 'IN_BEHANDELING', label: 'In Behandeling', count: 18 },
  { key: 'AFGEHANDELD', label: 'Afgehandeld', count: 412 },
  { key: 'AFGEKEURD', label: 'Afgekeurd', count: 55 },
  { key: 'ALLE', label: 'Alle', count: 523 },
]

// Incident type options for filter
const typeOptions: { value: IncidentType | ''; label: string }[] = [
  { value: '', label: 'Alle types' },
  { value: 'AANRIJDING', label: 'Aanrijding' },
  { value: 'ACHTERAANRIJDING', label: 'Achteraanrijding' },
  { value: 'PARKEERSCHADE', label: 'Parkeerschade' },
  { value: 'STEENSCHADE', label: 'Steenschade' },
  { value: 'TOTAL LOSS', label: 'Total Loss' },
  { value: 'DIEFSTAL', label: 'Diefstal' },
  { value: 'BRANDSCHADE', label: 'Brandschade' },
  { value: 'WATERSCHADE', label: 'Waterschade' },
  { value: 'GLASBRUK', label: 'Glasbreuk' },
  { value: 'STORMSCHADE', label: 'Stormschade' },
  { value: 'ARBEIDSONGEVAL', label: 'Arbeidsongeval' },
  { value: 'HOSPITALISATIE', label: 'Hospitalisatie' },
  { value: 'RECHTSBIJSTAND', label: 'Rechtsbijstand' },
  { value: 'BURGERLIJKE_AANSPRAKELIJKHEID', label: 'BA (Bedrijf)' },
]

// Behandelaar options
const behandelaarOptions = [
  { value: '', label: 'Alle behandelaars' },
  { value: 'Marie Dubois', label: 'Marie Dubois' },
  { value: 'Systeem', label: 'Systeem' },
  { value: 'Jan Peeters', label: 'Jan Peeters' },
]

export default function SchadeclaimsPage() {
  const [activeTab, setActiveTab] = useState<ClaimStatus | 'ALLE'>('OPENSTAAND')
  const [searchQuery, setSearchQuery] = useState('')
  const [typeFilter, setTypeFilter] = useState<IncidentType | ''>('')
  const [behandelaarFilter, setBehandelaarFilter] = useState('')
  const [drawerOpen, setDrawerOpen] = useState(false)
  const [selectedClaim, setSelectedClaim] = useState<ClaimDetail | null>(null)
  const [createOpen, setCreateOpen] = useState(false)

  // KPI values
  const kpiValues = {
    totaal: 523,
    openstaand: 38,
    afgehandeldDitJaar: 412,
    totaalUitbetaald: '€1.85M',
    gemAfhandeltijd: '18 dagen',
  }

  // Filtered data
  const filteredData = useMemo(() => {
    return claimDetails.filter((c) => {
      if (activeTab !== 'ALLE' && c.status !== activeTab) return false
      if (typeFilter && c.incidentType !== typeFilter) return false
      if (behandelaarFilter) {
        // Check if any opvolging item has this gebruiker, or if claim melder matches
        const hasBehandelaar = c.opvolging.some((o) => o.gebruiker === behandelaarFilter)
        if (!hasBehandelaar && c.melder !== behandelaarFilter) return false
      }
      if (searchQuery) {
        const q = searchQuery.toLowerCase()
        const matchNum = c.claimnummer.toLowerCase().includes(q)
        const matchContract = c.contractnummer.toLowerCase().includes(q)
        const matchName = c.verzekerdeNaam.toLowerCase().includes(q)
        return matchNum || matchContract || matchName
      }
      return true
    })
  }, [activeTab, searchQuery, typeFilter, behandelaarFilter])

  const openDetail = (claim: ClaimDetail) => {
    setSelectedClaim(claim)
    setDrawerOpen(true)
  }

  const getIncidentIcon = (type: IncidentType) => {
    const map: Record<string, { icon: React.ReactNode; color: string }> = {
      AANRIJDING: { icon: <Car style={{ width: '16px', height: '16px' }} />, color: '#C04A4A' },
      ACHTERAANRIJDING: { icon: <Car style={{ width: '16px', height: '16px' }} />, color: '#C04A4A' },
      PARKEERSCHADE: { icon: <Car style={{ width: '16px', height: '16px' }} />, color: '#6B7785' },
      STEENSCHADE: { icon: <GlassWater style={{ width: '16px', height: '16px' }} />, color: '#5B8DB8' },
      'TOTAL LOSS': { icon: <Car style={{ width: '16px', height: '16px' }} />, color: '#1A1F24' },
      DIEFSTAL: { icon: <ShieldAlert style={{ width: '16px', height: '16px' }} />, color: '#D4942A' },
      BRANDSCHADE: { icon: <Flame style={{ width: '16px', height: '16px' }} />, color: '#C07A4A' },
      WATERSCHADE: { icon: <Droplets style={{ width: '16px', height: '16px' }} />, color: '#3B6EA5' },
      GLASBRUK: { icon: <GlassWater style={{ width: '16px', height: '16px' }} />, color: '#5B8DB8' },
      STORMSCHADE: { icon: <CloudLightning style={{ width: '16px', height: '16px' }} />, color: '#8B5E83' },
      ARBEIDSONGEVAL: { icon: <Hammer style={{ width: '16px', height: '16px' }} />, color: '#D4942A' },
      HOSPITALISATIE: { icon: <CheckCircle style={{ width: '16px', height: '16px' }} />, color: '#4A804A' },
      RECHTSBIJSTAND: { icon: <Hammer style={{ width: '16px', height: '16px' }} />, color: '#3B6EA5' },
      BURGERLIJKE_AANSPRAKELIJKHEID: { icon: <ShieldAlert style={{ width: '16px', height: '16px' }} />, color: '#6B7785' },
    }
    return map[type] || { icon: <AlertCircle style={{ width: '16px', height: '16px' }} />, color: '#6B7785' }
  }

  // Check if claim is urgent (>45 days and not closed)
  const isUrgent = (claim: ClaimDetail) => {
    return claim.dagenOpen > 45 && claim.status !== 'AFGEHANDELD' && claim.status !== 'AFGEKEURD'
  }

  // Check if claim is >30 days old and open
  const isWarning = (claim: ClaimDetail) => {
    return claim.dagenOpen > 30 && claim.status !== 'AFGEHANDELD' && claim.status !== 'AFGEKEURD'
  }

  // Table columns
  const columns = [
    {
      key: 'claimnummer',
      header: 'Claimnr',
      width: 130,
      render: (row: ClaimDetail) => (
        <span className="font-mono text-sm" style={{ color: '#3B6EA5' }}>
          #{row.claimnummer}
        </span>
      ),
    },
    {
      key: 'contract',
      header: 'Contract',
      width: 130,
      render: (row: ClaimDetail) => (
        <span className="font-mono text-xs" style={{ color: '#6B7785' }}>
          #{row.contractnummer}
        </span>
      ),
    },
    {
      key: 'type',
      header: 'Type',
      width: 150,
      render: (row: ClaimDetail) => {
        const ic = getIncidentIcon(row.incidentType)
        return (
          <div className="flex items-center gap-2">
            <span style={{ color: ic.color }}>{ic.icon}</span>
            <span className="text-sm" style={{ color: '#1A1F24' }}>{row.typeLabel}</span>
          </div>
        )
      },
    },
    {
      key: 'datumIncident',
      header: 'Datum Incident',
      width: 110,
      render: (row: ClaimDetail) => (
        <span className="text-sm" style={{ color: '#1A1F24' }}>{formatDate(row.datumIncident)}</span>
      ),
    },
    {
      key: 'datumMelding',
      header: 'Aangemeld',
      width: 110,
      render: (row: ClaimDetail) => {
        let color = '#1A1F24'
        if (isWarning(row)) color = '#D4942A'
        if (isUrgent(row)) color = '#C04A4A'
        return (
          <span className="text-sm font-medium" style={{ color }}>
            {formatDate(row.datumMelding)}
          </span>
        )
      },
    },
    {
      key: 'behandelaar',
      header: 'Behandelaar',
      width: 140,
      render: (row: ClaimDetail) => (
        <span className="text-sm" style={{ color: '#1A1F24' }}>
          {row.opvolging.find((o) => o.gebruiker !== 'Systeem')?.gebruiker || row.melder || '—'}
        </span>
      ),
    },
    {
      key: 'uitbetaald',
      header: 'Uitbetaald (€)',
      width: 120,
      render: (row: ClaimDetail) => (
        <span className="text-sm font-medium" style={{ color: row.uitbetaald > 0 ? '#3A683A' : '#6B7785' }}>
          {row.status === 'AFGEHANDELD' ? formatCurrency(row.uitbetaald) : formatCurrency(row.geschatBedrag)}
        </span>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      width: 130,
      render: (row: ClaimDetail) => {
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
  const detailTabs = selectedClaim
    ? [
        {
          key: 'overzicht',
          label: 'Overzicht',
          content: <OverzichtTab claim={selectedClaim} />,
        },
        {
          key: 'partijen',
          label: 'Partijen',
          content: <PartijenTab claim={selectedClaim} />,
        },
        {
          key: 'objecten',
          label: 'Objecten',
          content: <ObjectenTab claim={selectedClaim} />,
        },
        {
          key: 'omstandigheden',
          label: 'Omstandigheden',
          content: <OmstandighedenTab claim={selectedClaim} />,
        },
        {
          key: 'opvolging',
          label: 'Opvolging',
          content: <OpvolgingTab claim={selectedClaim} />,
        },
        {
          key: 'documenten',
          label: 'Documenten',
          content: <DocumentenTab claim={selectedClaim} />,
        },
      ]
    : []

  return (
    <div className="flex flex-col gap-6">
      {/* Breadcrumb */}
      <div className="flex items-center gap-2 text-xs" style={{ color: '#6B7785' }}>
        <span>Dashboard</span>
        <ChevronRight style={{ width: '14px', height: '14px' }} />
        <span className="font-medium" style={{ color: '#3D4550' }}>Schadeclaims</span>
      </div>

      {/* Page Title */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="font-bold" style={{ fontSize: '28px', color: '#1A1F24', letterSpacing: '-0.02em' }}>
            Schadeclaims
          </h1>
          <p className="text-sm mt-1" style={{ color: '#6B7785' }}>
            Beheer schadeclaims, dossiers en uitbetalingen
          </p>
        </div>
        <button
          onClick={() => setCreateOpen(true)}
          className="flex items-center gap-2 rounded-md text-white font-medium transition-all duration-150 hover:opacity-90"
          style={{
            height: '40px',
            padding: '0 20px',
            backgroundColor: '#4A804A',
            fontSize: '14px',
          }}
        >
          <Plus style={{ width: '16px', height: '16px' }} />
          Nieuwe Claim
        </button>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-4">
        <KPICard
          icon={<AlertCircle style={{ width: '20px', height: '20px' }} />}
          value={kpiValues.totaal.toString()}
          label="Totaal Claims"
          trend="up"
          trendValue=""
          color="#6B7785"
          delay={0}
        />
        <KPICard
          icon={<AlertTriangle style={{ width: '20px', height: '20px' }} />}
          value={kpiValues.openstaand.toString()}
          label="Openstaand"
          trend="down"
          trendValue="5 dringend"
          color="#D4942A"
          delay={50}
        />
        <KPICard
          icon={<CheckCircle style={{ width: '20px', height: '20px' }} />}
          value={kpiValues.afgehandeldDitJaar.toString()}
          label="Afgehandeld Dit Jaar"
          trend="up"
          trendValue="+12%"
          color="#4A804A"
          delay={100}
        />
        <KPICard
          icon={<Euro style={{ width: '20px', height: '20px' }} />}
          value={kpiValues.totaalUitbetaald}
          label="Totaal Uitbetaald"
          trend="up"
          trendValue=""
          color="#C04A4A"
          delay={150}
        />
        <KPICard
          icon={<Clock style={{ width: '20px', height: '20px' }} />}
          value={kpiValues.gemAfhandeltijd}
          label="Gem. Afhandeltijd"
          trend="up"
          trendValue="-2 dagen"
          color="#5B8DB8"
          delay={200}
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
              placeholder="Zoek claim nr, contract, verzekerde..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full rounded-md border border-[#D1D6DB] bg-[#FAFBFC] text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15 transition-all duration-100"
              style={{ height: '36px', padding: '0 12px', fontSize: '13px', color: '#1A1F24' }}
            />
          </div>

          {/* Type filter */}
          <select
            value={typeFilter}
            onChange={(e) => setTypeFilter(e.target.value as IncidentType | '')}
            className="rounded-md border border-[#D1D6DB] bg-white text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15 transition-all duration-100"
            style={{ height: '36px', padding: '0 12px', fontSize: '13px', color: '#1A1F24' }}
          >
            {typeOptions.map((o) => (
              <option key={o.value} value={o.value}>{o.label}</option>
            ))}
          </select>

          {/* Behandelaar filter */}
          <select
            value={behandelaarFilter}
            onChange={(e) => setBehandelaarFilter(e.target.value)}
            className="rounded-md border border-[#D1D6DB] bg-white text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15 transition-all duration-100"
            style={{ height: '36px', padding: '0 12px', fontSize: '13px', color: '#1A1F24' }}
          >
            {behandelaarOptions.map((o) => (
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
        emptyMessage="Geen claims gevonden"
      />

      {/* Detail Drawer */}
      {selectedClaim && (
        <DetailDrawer
          open={drawerOpen}
          onClose={() => setDrawerOpen(false)}
          title={`#${selectedClaim.claimnummer}`}
          subtitle={selectedClaim.typeLabel}
          badge={{
            status: statusBadgeMap[selectedClaim.status].variant,
            text: statusBadgeMap[selectedClaim.status].label,
          }}
          tabs={detailTabs}
        />
      )}

      {/* Create Modal (simplified) */}
      {createOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center" style={{ pointerEvents: 'none' }}>
          <div
            className="absolute inset-0"
            style={{ backgroundColor: '#0F1215', opacity: 0.3, pointerEvents: 'auto' }}
            onClick={() => setCreateOpen(false)}
          />
          <div
            className="relative bg-white rounded-xl flex flex-col"
            style={{
              width: '480px',
              maxHeight: '70vh',
              pointerEvents: 'auto',
              boxShadow: '0 20px 60px rgba(0,0,0,0.15)',
            }}
          >
            <div className="shrink-0 flex items-center justify-between" style={{ padding: '20px 24px', borderBottom: '1px solid #E8EBEE' }}>
              <h2 className="font-semibold" style={{ fontSize: '18px', color: '#1A1F24' }}>Nieuwe Schadeclaim</h2>
              <button
                onClick={() => setCreateOpen(false)}
                className="flex items-center justify-center rounded-md text-[#95A1AD] hover:text-[#1A1F24] hover:bg-[#F2F4F6] transition-colors duration-150"
                style={{ width: '32px', height: '32px' }}
              >
                <X style={{ width: '18px', height: '18px' }} />
              </button>
            </div>
            <div className="flex-1 overflow-auto" style={{ padding: '24px' }}>
              <div className="flex flex-col gap-4">
                <div>
                  <label className="block text-xs font-medium mb-2" style={{ color: '#3D4550' }}>Contract</label>
                  <select className="w-full rounded-md border border-[#D1D6DB] bg-white text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15" style={{ height: '40px', padding: '0 12px' }}>
                    <option>Selecteer contract...</option>
                    <option>POL-2024-001234 - Peeters, Jan</option>
                    <option>POL-2024-001235 - Dubois, Marie</option>
                    <option>POL-2024-001237 - BVBA De Boer</option>
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-medium mb-2" style={{ color: '#3D4550' }}>Type schade</label>
                  <select className="w-full rounded-md border border-[#D1D6DB] bg-white text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15" style={{ height: '40px', padding: '0 12px' }}>
                    <option>Selecteer type...</option>
                    {typeOptions.filter((o) => o.value).map((o) => (
                      <option key={o.value} value={o.value}>{o.label}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-medium mb-2" style={{ color: '#3D4550' }}>Datum incident</label>
                  <input type="date" className="w-full rounded-md border border-[#D1D6DB] bg-white text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15" style={{ height: '40px', padding: '0 12px' }} />
                </div>
                <div>
                  <label className="block text-xs font-medium mb-2" style={{ color: '#3D4550' }}>Beschrijving</label>
                  <textarea
                    placeholder="Beschrijf de schade..."
                    className="w-full rounded-md border border-[#D1D6DB] bg-white text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15 resize-none"
                    style={{ height: '80px', padding: '10px 12px' }}
                  />
                </div>
              </div>
            </div>
            <div className="shrink-0 flex items-center justify-end gap-3" style={{ padding: '16px 24px', borderTop: '1px solid #E8EBEE' }}>
              <button
                onClick={() => setCreateOpen(false)}
                className="rounded-md text-sm font-medium transition-colors duration-150 hover:bg-[#F2F4F6]"
                style={{ padding: '10px 20px', color: '#3D4550', border: '1px solid #D1D6DB' }}
              >
                Annuleren
              </button>
              <button
                onClick={() => setCreateOpen(false)}
                className="rounded-md text-sm font-medium text-white transition-all duration-150 hover:opacity-90"
                style={{ padding: '10px 20px', backgroundColor: '#4A804A' }}
              >
                Claim aanmaken
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

// ====== Tab Components ======

function OverzichtTab({ claim }: { claim: ClaimDetail }) {
  return (
    <div className="flex flex-col gap-6">
      {/* Urgency indicator */}
      {isUrgentClaim(claim) && (
        <div
          className="flex items-center gap-3 p-3 rounded-lg"
          style={{ backgroundColor: '#FDE8E8', border: '1px solid #FDE8E8' }}
        >
          <AlertTriangle style={{ width: '18px', height: '18px', color: '#C04A4A' }} />
          <span className="text-sm font-medium" style={{ color: '#C04A4A' }}>
            Dringend — {claim.dagenOpen} dagen open (gem. doorlooptijd: {claim.gemDoorlooptijd} dagen)
          </span>
        </div>
      )}

      {/* Claimgegevens */}
      <Section title="Claimgegevens">
        <div className="grid grid-cols-2 gap-4">
          <Field label="Claimnummer" value={`#${claim.claimnummer}`} mono />
          <Field label="Melddatum" value={`${formatDate(claim.datumMelding)} (door: ${claim.melder})`} />
          <Field label="Incidentdatum" value={formatDate(claim.datumIncident)} />
          <Field label="Status" value={<StatusBadge status={statusBadgeMap[claim.status].variant}>{statusBadgeMap[claim.status].label}</StatusBadge>} />
          <Field label="Prioriteit" value={
            <span
              className="text-xs font-medium px-2 py-0.5 rounded-full"
              style={{
                backgroundColor: claim.prioriteit === 'DRINGEND' ? '#FDE8E8' : claim.prioriteit === 'HOOG' ? '#FDF5E8' : '#F2F4F6',
                color: claim.prioriteit === 'DRINGEND' ? '#C04A4A' : claim.prioriteit === 'HOOG' ? '#D4942A' : '#6B7785',
              }}
            >
              {claim.prioriteit}
            </span>
          } />
        </div>
      </Section>

      {/* Contract & Verzekering */}
      <Section title="Contract & Verzekering">
        <div className="grid grid-cols-2 gap-4">
          <Field label="Contract" value={`#${claim.contractnummer}`} mono />
          <Field label="Verzekerde" value={claim.verzekerdeNaam} />
          <Field label="Verzekeraar" value={claim.maatschappijNaam} />
          <Field label="Type dekking" value={claim.typeDekking} />
        </div>
      </Section>

      {/* Schadebedrag */}
      <Section title="Schadebedrag">
        <div className="grid grid-cols-2 gap-4">
          <Field label="Geschat schadebedrag" value={formatCurrency(claim.geschatBedrag)} />
          <Field label="Goedgekeurd bedrag" value={claim.goedgekeurdBedrag > 0 ? formatCurrency(claim.goedgekeurdBedrag) : 'Nog niet bepaald'} />
          <Field label="Eigen risico" value={formatCurrency(claim.eigenRisico)} />
          <Field label="Uitbetaald" value={formatCurrency(claim.uitbetaald)} />
          <Field label="Restant" value={formatCurrency(claim.restant)} />
        </div>
        {/* Payment progress bar */}
        {claim.geschatBedrag > 0 && (
          <div className="mt-3">
            <div className="w-full rounded-full" style={{ height: '8px', backgroundColor: '#E8EBEE' }}>
              <div
                className="rounded-full"
                style={{
                  height: '8px',
                  backgroundColor: claim.status === 'AFGEHANDELD' ? '#4A804A' : '#5B8DB8',
                  width: `${Math.min(100, (claim.uitbetaald / claim.geschatBedrag) * 100)}%`,
                }}
              />
            </div>
            <div className="flex justify-between mt-1">
              <span className="text-xs" style={{ color: '#6B7785' }}>0%</span>
              <span className="text-xs font-medium" style={{ color: claim.status === 'AFGEHANDELD' ? '#4A804A' : '#5B8DB8' }}>
                {Math.round((claim.uitbetaald / claim.geschatBedrag) * 100)}%
              </span>
            </div>
          </div>
        )}
      </Section>

      {/* Expert */}
      {claim.expertNaam && (
        <Section title="Expert">
          <div className="p-3 rounded-lg" style={{ backgroundColor: '#F2F4F6', border: '1px solid #E8EBEE' }}>
            <div className="font-medium text-sm" style={{ color: '#1A1F24' }}>{claim.expertNaam}</div>
            {claim.expertContact && <div className="text-xs mt-1" style={{ color: '#6B7785' }}>{claim.expertContact}</div>}
            {claim.expertDatumAanstelling && <div className="text-xs mt-1" style={{ color: '#6B7785' }}>Aangesteld: {formatDate(claim.expertDatumAanstelling)}</div>}
            {claim.expertRapportVerwacht && <div className="text-xs mt-1" style={{ color: '#D4942A' }}>Rapport verwacht: {formatDate(claim.expertRapportVerwacht)}</div>}
          </div>
        </Section>
      )}

      {/* Doorlooptijd */}
      <Section title="Doorlooptijd">
        <div className="grid grid-cols-3 gap-3">
          <div className="p-3 rounded-lg text-center" style={{ backgroundColor: '#F2F4F6', border: '1px solid #E8EBEE' }}>
            <div className="text-lg font-bold" style={{ color: isUrgentClaim(claim) ? '#C04A4A' : '#1A1F24' }}>{claim.dagenOpen}</div>
            <div className="text-xs" style={{ color: '#6B7785' }}>dagen open</div>
          </div>
          <div className="p-3 rounded-lg text-center" style={{ backgroundColor: '#F2F4F6', border: '1px solid #E8EBEE' }}>
            <div className="text-lg font-bold" style={{ color: '#5B8DB8' }}>{claim.gemDoorlooptijd}</div>
            <div className="text-xs" style={{ color: '#6B7785' }}>gem. doorlooptijd</div>
          </div>
          <div className="p-3 rounded-lg text-center" style={{ backgroundColor: '#F2F4F6', border: '1px solid #E8EBEE' }}>
            <div className="text-lg font-bold" style={{ color: '#4A804A' }}>{claim.verwachteAfhandeling > 0 ? claim.verwachteAfhandeling : 0}</div>
            <div className="text-xs" style={{ color: '#6B7785' }}>verwachte afhandeling</div>
          </div>
        </div>
      </Section>
    </div>
  )
}

function PartijenTab({ claim }: { claim: ClaimDetail }) {
  const roleColors: Record<string, string> = {
    VERZEKERDE: '#4A804A',
    AANSPRAKELIJKE: '#C04A4A',
    EXPERT: '#3B6EA5',
    DERDE: '#6B7785',
    VERZEKERAAR: '#C07A4A',
    GETUIGE: '#8B5E83',
  }

  return (
    <div className="flex flex-col gap-3">
      {claim.partijen.map((p, idx) => (
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
            {p.type === 'EB' ? <Phone style={{ width: '16px', height: '16px' }} /> : <Users style={{ width: '16px', height: '16px' }} />}
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
            {p.telefoon && <div className="text-xs mt-1" style={{ color: '#6B7785' }}>{p.telefoon}</div>}
          </div>
        </div>
      ))}
    </div>
  )
}

function ObjectenTab({ claim }: { claim: ClaimDetail }) {
  if (claim.objecten.length === 0) {
    return <EmptyState message="Geen objecten gekoppeld" />
  }

  return (
    <div className="flex flex-col gap-3">
      {claim.objecten.map((obj, idx) => (
        <div
          key={idx}
          className="p-4 rounded-lg"
          style={{ backgroundColor: idx % 2 === 0 ? '#F2F4F6' : '#FAFBFC', border: '1px solid #E8EBEE' }}
        >
          <div className="flex items-center justify-between mb-2">
            <span className="font-medium text-sm" style={{ color: '#1A1F24' }}>{obj.naam}</span>
            <StatusBadge status={obj.status === 'Hersteld' ? 'active' : obj.status === 'Totaal loss' ? 'error' : 'warning'}>
              {obj.status}
            </StatusBadge>
          </div>
          <div className="grid grid-cols-3 gap-3">
            <Field label="Type" value={obj.type} />
            <Field label="Identificatie" value={obj.identificatie} mono />
            <Field label="Schade" value={formatCurrency(obj.schadeBedrag)} />
          </div>
        </div>
      ))}
    </div>
  )
}

function OmstandighedenTab({ claim }: { claim: ClaimDetail }) {
  return (
    <div className="flex flex-col gap-6">
      <Section title="Beschrijving">
        <p className="text-sm leading-relaxed" style={{ color: '#1A1F24' }}>{claim.beschrijving}</p>
      </Section>

      <Section title="Details">
        <div className="grid grid-cols-2 gap-4">
          {claim.locatie && (
            <div className="flex items-center gap-2">
              <MapPin style={{ width: '14px', height: '14px', color: '#6B7785' }} />
              <Field label="Plaats" value={claim.locatie} />
            </div>
          )}
          {claim.tijd && <Field label="Tijd" value={claim.tijd} />}
          {claim.weersomstandigheden && <Field label="Weersomstandigheden" value={claim.weersomstandigheden} />}
          <Field label="Aangifte politie" value={claim.politieAangifte ? `Ja — PV: ${claim.politiePVNummer || 'Onbekend'}` : 'Nee'} />
          {claim.tegenpartij && <Field label="Tegenpartij" value={claim.tegenpartij} />}
          <Field label="Getuigen" value={claim.getuigen} />
        </div>
      </Section>
    </div>
  )
}

function OpvolgingTab({ claim }: { claim: ClaimDetail }) {
  return (
    <div className="flex flex-col gap-0">
      {claim.opvolging.map((item, idx) => (
        <div key={idx} className="flex gap-4 relative">
          {/* Timeline line */}
          {idx < claim.opvolging.length - 1 && (
            <div className="absolute left-[15px] top-[36px] w-[2px]" style={{ height: 'calc(100% - 20px)', backgroundColor: '#E8EBEE' }} />
          )}
          {/* Dot */}
          <div className="shrink-0 flex flex-col items-center">
            <div
              className="rounded-full flex items-center justify-center"
              style={{
                width: '32px',
                height: '32px',
                backgroundColor: item.statusWijziging ? '#E8F5E8' : '#F2F4F6',
                border: `2px solid ${item.statusWijziging ? '#4A804A' : '#D1D6DB'}`,
              }}
            >
              {item.statusWijziging ? (
                <Check style={{ width: '14px', height: '14px', color: '#4A804A' }} />
              ) : (
                <div style={{ width: '8px', height: '8px', borderRadius: '50%', backgroundColor: '#D1D6DB' }} />
              )}
            </div>
          </div>
          {/* Content */}
          <div className="flex-1 pb-5">
            <div className="text-xs font-medium" style={{ color: '#6B7785' }}>{item.datum}</div>
            <div className="text-sm mt-0.5" style={{ color: '#1A1F24' }}>
              <span className="font-medium">{item.gebruiker}</span> — {item.activiteit}
            </div>
            {item.statusWijziging && (
              <div className="text-xs mt-1 font-medium" style={{ color: '#4A804A' }}>
                {item.statusWijziging}
              </div>
            )}
          </div>
        </div>
      ))}
    </div>
  )
}

function DocumentenTab({ claim }: { claim: ClaimDetail }) {
  if (claim.documenten.length === 0) {
    return <EmptyState message="Geen documenten beschikbaar" />
  }

  return (
    <div className="flex flex-col gap-3">
      {claim.documenten.map((doc, idx) => (
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
              style={{ backgroundColor: doc.type === 'IMG' ? '#FDF5E8' : '#E8F0F8', color: doc.type === 'IMG' ? '#D4942A' : '#3B6EA5' }}
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

function isUrgentClaim(claim: ClaimDetail): boolean {
  return claim.dagenOpen > 45 && claim.status !== 'AFGEHANDELD' && claim.status !== 'AFGEKEURD'
}

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
