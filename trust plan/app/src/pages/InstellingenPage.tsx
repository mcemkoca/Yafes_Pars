import { useState, useMemo, useCallback } from 'react'
import { Shield, Landmark, Users, Briefcase, Search, Download, Plus, X, Phone, Mail, FileText, Wrench, ClipboardCheck, ChevronDown, ChevronRight, Globe } from 'lucide-react'
import KPICard from '../components/KPICard'
import DataTable from '../components/DataTable'
import DetailDrawer from '../components/DetailDrawer'
import StatusBadge from '../components/StatusBadge'
import { institutionenDetails, institutionTypeLabel, institutionTypeFilters, institutionCities, institutionStats } from '../data/instellingenData'
import type { InstitutionDetail, ExtendedInstitutionType } from '../data/instellingenData'

// ---- Types ----
interface FilterState {
  search: string
  type: string
  status: string
  stad: string
}

// ---- Helpers ----
const getStatusVariant = (status: string): 'active' | 'warning' | 'error' | 'info' | 'neutral' => {
  switch (status) {
    case 'actief': return 'active'
    case 'inactief': return 'neutral'
    case 'geschorst': return 'error'
    default: return 'neutral'
  }
}

const getTypeIcon = (type: ExtendedInstitutionType) => {
  switch (type) {
    case 'verzekeringsmaatschappij': return <Shield style={{ width: '14px', height: '14px' }} />
    case 'bank': return <Landmark style={{ width: '14px', height: '14px' }} />
    case 'tussenpersoon': return <Users style={{ width: '14px', height: '14px' }} />
    case 'reparatiebedrijf': return <Wrench style={{ width: '14px', height: '14px' }} />
    case 'expertbureau': return <ClipboardCheck style={{ width: '14px', height: '14px' }} />
    case 'andere': return <Briefcase style={{ width: '14px', height: '14px' }} />
  }
}

const getTypeIconColor = (type: ExtendedInstitutionType): string => {
  switch (type) {
    case 'verzekeringsmaatschappij': return '#4A804A'
    case 'bank': return '#C8A456'
    case 'tussenpersoon': return '#3B6EA5'
    case 'reparatiebedrijf': return '#6B7785'
    case 'expertbureau': return '#8B5E83'
    case 'andere': return '#95A1AD'
  }
}

const getTypeBgColor = (type: ExtendedInstitutionType): string => {
  switch (type) {
    case 'verzekeringsmaatschappij': return '#E8F5E8'
    case 'bank': return '#FDF5E8'
    case 'tussenpersoon': return '#E8F0F8'
    case 'reparatiebedrijf': return '#F2F4F6'
    case 'expertbureau': return '#F3E8F5'
    case 'andere': return '#F2F4F6'
  }
}

const getTypeBadgeColor = (type: ExtendedInstitutionType): { bg: string; text: string } => {
  switch (type) {
    case 'verzekeringsmaatschappij': return { bg: '#E8F5E8', text: '#3A683A' }
    case 'bank': return { bg: '#FDF5E8', text: '#C8A456' }
    case 'tussenpersoon': return { bg: '#E8F0F8', text: '#3B6EA5' }
    case 'reparatiebedrijf': return { bg: '#F2F4F6', text: '#6B7785' }
    case 'expertbureau': return { bg: '#F3E8F5', text: '#8B5E83' }
    case 'andere': return { bg: '#F2F4F6', text: '#6B7785' }
  }
}

const formatDate = (dateStr: string): string => {
  if (!dateStr) return '-'
  if (dateStr.includes('/')) return dateStr
  const [year, month, day] = dateStr.split('-')
  return day && month && year ? `${day}/${month}/${year}` : dateStr
}

// ---- KPI Row ----
function InstellingenKPIs() {
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
      <KPICard
        icon={<Shield style={{ width: '20px', height: '20px' }} />}
        value={institutionStats.totaal.toString()}
        label="Geregistreerde instellingen"
        trend="up"
        trendValue="156"
        color="#3B6EA5"
      />
      <KPICard
        icon={<Shield style={{ width: '20px', height: '20px' }} />}
        value={institutionStats.verzekeringsmaatschappijen.toString()}
        label="Verzekeringsmaatschappijen"
        trend="up"
        trendValue="42"
        color="#4A804A"
        subtitle="Actief in België"
      />
      <KPICard
        icon={<Landmark style={{ width: '20px', height: '20px' }} />}
        value={institutionStats.banken.toString()}
        label="Banken & Kredietinstellingen"
        trend="up"
        trendValue="28"
        color="#C8A456"
      />
      <KPICard
        icon={<Users style={{ width: '20px', height: '20px' }} />}
        value={institutionStats.tussenpersonen.toString()}
        label="Tussenpersonen & Makelaars"
        trend="up"
        trendValue="35"
        color="#3B6EA5"
        subtitle="+ andere instellingen"
      />
    </div>
  )
}

// ---- Filter Bar ----
function InstellingenFilterBar({
  filters,
  onFilterChange,
  resultCount,
}: {
  filters: FilterState
  onFilterChange: (f: FilterState) => void
  resultCount: number
}) {
  const [showTypeDropdown, setShowTypeDropdown] = useState(false)
  const [showStatusDropdown, setShowStatusDropdown] = useState(false)
  const [showStadDropdown, setShowStadDropdown] = useState(false)

  const update = (partial: Partial<FilterState>) => {
    onFilterChange({ ...filters, ...partial })
  }

  const activeChips = useMemo(() => {
    const chips: { key: string; label: string }[] = []
    if (filters.search) chips.push({ key: 'search', label: `Zoek: ${filters.search}` })
    if (filters.type) chips.push({ key: 'type', label: `Type: ${filters.type}` })
    if (filters.status) chips.push({ key: 'status', label: `Status: ${filters.status}` })
    if (filters.stad) chips.push({ key: 'stad', label: `Stad: ${filters.stad}` })
    return chips
  }, [filters])

  const removeChip = (key: string) => {
    const map: Record<string, Partial<FilterState>> = {
      search: { search: '' },
      type: { type: '' },
      status: { status: '' },
      stad: { stad: '' },
    }
    update(map[key] || {})
  }

  return (
    <div
      className="bg-white rounded-lg"
      style={{ border: '1px solid #E8EBEE', padding: '12px 16px' }}
    >
      <div className="flex items-center gap-3 flex-wrap">
        {/* Search */}
        <div className="relative" style={{ minWidth: '200px', maxWidth: '320px' }}>
          <Search
            className="absolute left-3 top-1/2 -translate-y-1/2 text-[#95A1AD]"
            style={{ width: '14px', height: '14px' }}
          />
          <input
            type="text"
            placeholder="Zoek op naam, ondernemingsnummer of agentnummer..."
            value={filters.search}
            onChange={(e) => update({ search: e.target.value })}
            className="w-full rounded-full border border-[#D1D6DB] bg-[#FAFBFC] text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15 transition-all duration-100"
            style={{ height: '32px', padding: '0 14px 0 32px', fontSize: '12px', color: '#1A1F24' }}
          />
        </div>

        {/* Type filter */}
        <div className="relative">
          <button
            onClick={() => setShowTypeDropdown(!showTypeDropdown)}
            className="flex items-center gap-1.5 rounded-md text-[#3D4550] hover:bg-[#F2F4F6] transition-colors duration-150"
            style={{ height: '32px', padding: '0 12px', fontSize: '12px', fontWeight: 500, border: '1px solid #D1D6DB' }}
          >
            Type {filters.type && <span className="text-[#4A804A] font-semibold">({filters.type})</span>}
            <ChevronDown style={{ width: '12px', height: '12px' }} />
          </button>
          {showTypeDropdown && (
            <>
              <div className="fixed inset-0 z-10" onClick={() => setShowTypeDropdown(false)} />
              <div className="absolute left-0 top-full mt-1 bg-white rounded-md shadow-lg z-20" style={{ border: '1px solid #E8EBEE', minWidth: '220px' }}>
                {institutionTypeFilters.map((opt) => (
                  <button
                    key={opt.value}
                    className="w-full text-left px-3 py-2 text-sm hover:bg-[#F4FAF4] transition-colors duration-100"
                    style={{ color: '#1A1F24', fontSize: '13px' }}
                    onClick={() => { update({ type: opt.value === 'alle' ? '' : opt.label }); setShowTypeDropdown(false) }}
                  >
                    {opt.label}
                  </button>
                ))}
              </div>
            </>
          )}
        </div>

        {/* Status filter */}
        <div className="relative">
          <button
            onClick={() => setShowStatusDropdown(!showStatusDropdown)}
            className="flex items-center gap-1.5 rounded-md text-[#3D4550] hover:bg-[#F2F4F6] transition-colors duration-150"
            style={{ height: '32px', padding: '0 12px', fontSize: '12px', fontWeight: 500, border: '1px solid #D1D6DB' }}
          >
            Status {filters.status && <span className="text-[#4A804A] font-semibold">({filters.status})</span>}
            <ChevronDown style={{ width: '12px', height: '12px' }} />
          </button>
          {showStatusDropdown && (
            <>
              <div className="fixed inset-0 z-10" onClick={() => setShowStatusDropdown(false)} />
              <div className="absolute left-0 top-full mt-1 bg-white rounded-md shadow-lg z-20" style={{ border: '1px solid #E8EBEE', minWidth: '160px' }}>
                {['Alle', 'Actief', 'Inactief', 'Geschorst'].map((opt) => (
                  <button
                    key={opt}
                    className="w-full text-left px-3 py-2 text-sm hover:bg-[#F4FAF4] transition-colors duration-100"
                    style={{ color: '#1A1F24', fontSize: '13px' }}
                    onClick={() => { update({ status: opt === 'Alle' ? '' : opt }); setShowStatusDropdown(false) }}
                  >
                    {opt}
                  </button>
                ))}
              </div>
            </>
          )}
        </div>

        {/* Stad filter */}
        <div className="relative">
          <button
            onClick={() => setShowStadDropdown(!showStadDropdown)}
            className="flex items-center gap-1.5 rounded-md text-[#3D4550] hover:bg-[#F2F4F6] transition-colors duration-150"
            style={{ height: '32px', padding: '0 12px', fontSize: '12px', fontWeight: 500, border: '1px solid #D1D6DB' }}
          >
            Stad {filters.stad && <span className="text-[#4A804A] font-semibold">({filters.stad})</span>}
            <ChevronDown style={{ width: '12px', height: '12px' }} />
          </button>
          {showStadDropdown && (
            <>
              <div className="fixed inset-0 z-10" onClick={() => setShowStadDropdown(false)} />
              <div className="absolute left-0 top-full mt-1 bg-white rounded-md shadow-lg z-20" style={{ border: '1px solid #E8EBEE', minWidth: '180px', maxHeight: '240px', overflow: 'auto' }}>
                <button
                  className="w-full text-left px-3 py-2 text-sm hover:bg-[#F4FAF4] transition-colors duration-100"
                  style={{ color: '#1A1F24', fontSize: '13px' }}
                  onClick={() => { update({ stad: '' }); setShowStadDropdown(false) }}
                >
                  Alle steden
                </button>
                {institutionCities.map((city) => (
                  <button
                    key={city}
                    className="w-full text-left px-3 py-2 text-sm hover:bg-[#F4FAF4] transition-colors duration-100"
                    style={{ color: '#1A1F24', fontSize: '13px' }}
                    onClick={() => { update({ stad: city }); setShowStadDropdown(false) }}
                  >
                    {city}
                  </button>
                ))}
              </div>
            </>
          )}
        </div>

        <div className="flex-1" />

        {/* Export */}
        <button
          className="flex items-center gap-1.5 rounded-md text-[#3D4550] hover:bg-[#F2F4F6] transition-colors duration-150"
          style={{ height: '32px', padding: '0 12px', fontSize: '12px', fontWeight: 500, border: '1px solid #D1D6DB' }}
        >
          <Download style={{ width: '14px', height: '14px' }} />
          Export
        </button>

        {/* Add */}
        <button
          className="flex items-center gap-1.5 rounded-md text-white transition-all duration-150 hover:opacity-90"
          style={{ height: '32px', padding: '0 16px', fontSize: '12px', fontWeight: 600, backgroundColor: '#4A804A' }}
        >
          <Plus style={{ width: '14px', height: '14px' }} />
          Nieuwe Instelling
        </button>
      </div>

      {/* Active filter chips */}
      {activeChips.length > 0 && (
        <div className="flex items-center gap-2 mt-3 flex-wrap">
          {activeChips.map((chip) => (
            <div
              key={chip.key}
              className="flex items-center gap-1.5"
              style={{
                height: '24px',
                padding: '0 8px 0 10px',
                borderRadius: '6px',
                backgroundColor: '#F4FAF4',
                border: '1px solid #E8F5E8',
                color: '#3A683A',
                fontSize: '11px',
                fontWeight: 500,
              }}
            >
              <span>{chip.label}</span>
              <button onClick={() => removeChip(chip.key)} className="flex items-center justify-center hover:opacity-70">
                <X style={{ width: '10px', height: '10px' }} />
              </button>
            </div>
          ))}
          <button
            onClick={() => onFilterChange({ search: '', type: '', status: '', stad: '' })}
            className="text-xs font-medium hover:underline"
            style={{ color: '#4A804A' }}
          >
            Wis alle filters
          </button>
        </div>
      )}

      {/* Result count */}
      <div className="mt-2 text-xs" style={{ color: '#6B7785' }}>
        {resultCount} resultaten gevonden
      </div>
    </div>
  )
}

// ---- Detail Drawer Tab Components ----

function FieldRow({ label, value, mono }: { label: string; value: React.ReactNode; mono?: boolean }) {
  return (
    <div>
      <div className="text-xs" style={{ color: '#6B7785', marginBottom: '2px' }}>{label}</div>
      <div className={`text-sm font-medium ${mono ? 'font-mono' : ''}`} style={{ color: '#1A1F24' }}>
        {value}
      </div>
    </div>
  )
}

function InstellingOverzichtTab({ instelling }: { instelling: InstitutionDetail }) {
  const badgeColors = getTypeBadgeColor(instelling.type)

  return (
    <div className="flex flex-col gap-6">
      {/* Bedrijfsgegevens */}
      <div>
        <h4 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24' }}>Bedrijfsgegevens</h4>
        <div className="grid grid-cols-2 gap-x-6 gap-y-2">
          <FieldRow label="Handelsnaam" value={instelling.naam} />
          {instelling.juridischeNaam && <FieldRow label="Juridische naam" value={instelling.juridischeNaam} />}
          <FieldRow label="Ondernemingsnummer" value={instelling.kbo} mono />
          <FieldRow
            label="Type"
            value={
              <span
                className="inline-flex items-center font-semibold"
                style={{
                  height: '20px',
                  padding: '0 10px',
                  borderRadius: '10px',
                  fontSize: '11px',
                  fontWeight: 600,
                  backgroundColor: badgeColors.bg,
                  color: badgeColors.text,
                }}
              >
                {institutionTypeLabel[instelling.type]}
              </span>
            }
          />
          <FieldRow label="Status" value={<StatusBadge status={getStatusVariant(instelling.status)}>{instelling.status.charAt(0).toUpperCase() + instelling.status.slice(1)}</StatusBadge>} />
          {instelling.fsmaNummer && <FieldRow label="FSMA nummer" value={instelling.fsmaNummer} mono />}
          <FieldRow label="Land" value={instelling.land} />
          {instelling.rechtsvorm && <FieldRow label="Rechtsvorm" value={instelling.rechtsvorm} />}
          {instelling.oprichtingsdatum && <FieldRow label="Oprichtingsdatum" value={instelling.oprichtingsdatum} />}
        </div>
      </div>

      {/* Adres */}
      <div>
        <h4 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24' }}>Adres</h4>
        <div className="grid grid-cols-2 gap-x-6 gap-y-2">
          <FieldRow label="Straat" value={instelling.adres} />
          <FieldRow label="Postcode" value={instelling.postcode} />
          <FieldRow label="Stad" value={instelling.gemeente} />
          <FieldRow label="Provincie" value={instelling.provincie || '-'} />
        </div>
      </div>

      {/* Contact */}
      <div>
        <h4 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24' }}>Contact</h4>
        <div className="rounded-lg overflow-hidden" style={{ border: '1px solid #E8EBEE' }}>
          <div className="flex items-center gap-3 p-3" style={{ borderBottom: '1px solid #E8EBEE' }}>
            <Phone style={{ width: '14px', height: '14px', color: '#4A804A' }} />
            <div className="flex-1">
              <div className="text-xs" style={{ color: '#6B7785' }}>Algemeen</div>
              <div className="text-sm font-medium" style={{ color: '#1A1F24' }}>{instelling.telefoon}</div>
            </div>
          </div>
          {instelling.telefoonSchade && (
            <div className="flex items-center gap-3 p-3" style={{ borderBottom: '1px solid #E8EBEE' }}>
              <Phone style={{ width: '14px', height: '14px', color: '#D4942A' }} />
              <div className="flex-1">
                <div className="text-xs" style={{ color: '#6B7785' }}>Schades</div>
                <div className="text-sm font-medium" style={{ color: '#1A1F24' }}>{instelling.telefoonSchade}</div>
              </div>
            </div>
          )}
          <div className="flex items-center gap-3 p-3" style={{ borderBottom: '1px solid #E8EBEE' }}>
            <Mail style={{ width: '14px', height: '14px', color: '#3B6EA5' }} />
            <div className="flex-1">
              <div className="text-xs" style={{ color: '#6B7785' }}>E-mail</div>
              <div className="text-sm font-medium" style={{ color: '#1A1F24' }}>{instelling.email}</div>
            </div>
          </div>
          {instelling.website && (
            <div className="flex items-center gap-3 p-3">
              <Globe style={{ width: '14px', height: '14px', color: '#8B5E83' }} />
              <div className="flex-1">
                <div className="text-xs" style={{ color: '#6B7785' }}>Website</div>
                <div className="text-sm font-medium" style={{ color: '#1A1F24' }}>{instelling.website}</div>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Samenvatting */}
      <div className="rounded-lg p-4" style={{ backgroundColor: '#F2F4F6', border: '1px solid #E8EBEE' }}>
        <h4 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24' }}>Samenvatting</h4>
        <div className="grid grid-cols-2 gap-x-6 gap-y-2">
          <FieldRow label="Actieve contracten" value={instelling.contractCount.toString()} />
          {instelling.aantalWerknemers && <FieldRow label="Werknemers" value={instelling.aantalWerknemers.toString()} />}
          {instelling.hoofdsector && <FieldRow label="Hoofdsector" value={instelling.hoofdsector} />}
          {instelling.interneRef && <FieldRow label="Interne ref." value={instelling.interneRef} mono />}
          <FieldRow label="Aangemaakt" value={formatDate(instelling.createdAt)} />
          {instelling.updatedAt && <FieldRow label="Bijgewerkt" value={formatDate(instelling.updatedAt)} />}
        </div>
      </div>

      {/* Snelle Acties */}
      <div className="flex items-center gap-2">
        <button className="rounded-md text-[#3D4550] transition-all duration-150 hover:bg-[#F2F4F6]" style={{ padding: '8px 16px', fontSize: '13px', fontWeight: 500, border: '1px solid #D1D6DB' }}>
          Bewerken
        </button>
        <button className="rounded-md text-white transition-all duration-150 hover:opacity-90" style={{ padding: '8px 16px', fontSize: '13px', fontWeight: 500, backgroundColor: '#4A804A' }}>
          Nieuw Contract
        </button>
        <button className="rounded-md text-[#3D4550] transition-all duration-150 hover:bg-[#F2F4F6]" style={{ padding: '8px 16px', fontSize: '13px', fontWeight: 500 }}>
          Contactpersoon Toevoegen
        </button>
      </div>
    </div>
  )
}

function InstellingDetailsTab({ instelling }: { instelling: InstitutionDetail }) {
  return (
    <div className="flex flex-col gap-6">
      {/* Bedrijfsinformatie */}
      <div>
        <h4 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24' }}>Bedrijfsinformatie</h4>
        <div className="grid grid-cols-2 gap-x-6 gap-y-2">
          <FieldRow label="Type" value={institutionTypeLabel[instelling.type]} />
          {instelling.rechtsvorm && <FieldRow label="Rechtsvorm" value={instelling.rechtsvorm} />}
          {instelling.oprichtingsdatum && <FieldRow label="Oprichtingsdatum" value={instelling.oprichtingsdatum} />}
          {instelling.fsmaNummer && <FieldRow label="FSMA vergunningnummer" value={instelling.fsmaNummer} />}
          {instelling.fsmaVergunningVerval && <FieldRow label="Vergunning vervaldatum" value={instelling.fsmaVergunningVerval} />}
          {instelling.hoofdsector && <FieldRow label="Hoofdsector" value={instelling.hoofdsector} />}
          {instelling.aantalWerknemers && <FieldRow label="Aantal werknemers" value={instelling.aantalWerknemers.toLocaleString('nl-BE')} />}
        </div>
      </div>

      {/* Adresgegevens */}
      <div>
        <h4 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24' }}>Adresgegevens</h4>
        <div className="grid grid-cols-2 gap-x-6 gap-y-2">
          <FieldRow label="Straat" value={instelling.adres} />
          <FieldRow label="Postcode" value={instelling.postcode} />
          <FieldRow label="Stad" value={instelling.gemeente} />
          <FieldRow label="Provincie" value={instelling.provincie || '-'} />
          <FieldRow label="Land" value={instelling.land} />
        </div>
      </div>

      {/* Bankgegevens */}
      {(instelling.iban || instelling.bic) && (
        <div>
          <h4 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24' }}>Bankgegevens</h4>
          <div className="grid grid-cols-2 gap-x-6 gap-y-2">
            {instelling.iban && <FieldRow label="IBAN" value={instelling.iban} mono />}
            {instelling.bic && <FieldRow label="BIC" value={instelling.bic} mono />}
          </div>
        </div>
      )}

      {/* Bijkomende info */}
      {instelling.notities && (
        <div>
          <h4 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24' }}>Notities</h4>
          <p className="text-sm" style={{ color: '#3D4550', lineHeight: 1.6 }}>{instelling.notities}</p>
        </div>
      )}
    </div>
  )
}

function InstellingContractenTab({ instelling }: { instelling: InstitutionDetail }) {
  // Generate mock contracts for this institution based on its contract count
  const contracts = useMemo(() => {
    const domeinen = ['Auto Omnium', 'Woning', 'BA', 'Leven', 'Hospitalisatie', 'Arbeidsongevallen', 'Brand', 'Rechtsbijstand']
    const statussen = ['Actief', 'Actief', 'Actief', 'Verlopen']
    const result = []
    for (let i = 0; i < Math.min(instelling.contractCount, 10); i++) {
      const d = new Date()
      d.setMonth(d.getMonth() + Math.floor(Math.random() * 12) + 1)
      result.push({
        id: `IC-${instelling.id}-${i}`,
        contractnummer: `#VC-2024-${String(4000 + i).padStart(4, '0')}`,
        verzekerde: ['Peeters, Jan', 'Dubois, Marie', 'Janssens, Pieter', 'Vermeiren, Anna'][i % 4],
        type: domeinen[i % domeinen.length],
        status: statussen[i % statussen.length],
        premie: `€ ${(200 + i * 350).toLocaleString('nl-BE')}`,
        looptijd: `01/01/2024 – ${d.toLocaleDateString('nl-BE')}`,
      })
    }
    return result
  }, [instelling])

  if (contracts.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-8">
        <FileText style={{ width: '40px', height: '40px', color: '#D1D6DB' }} />
        <p className="text-sm mt-2" style={{ color: '#6B7785' }}>Geen contracten gekoppeld</p>
      </div>
    )
  }

  return (
    <div className="flex flex-col gap-4">
      <h4 className="text-sm font-semibold" style={{ color: '#1A1F24' }}>Contracten ({instelling.contractCount})</h4>
      <div className="rounded-lg overflow-hidden" style={{ border: '1px solid #E8EBEE' }}>
        <table className="w-full border-collapse">
          <thead>
            <tr style={{ backgroundColor: '#F2F4F6', height: '36px' }}>
              <th className="text-left font-medium px-3 text-xs" style={{ color: '#3D4550' }}>Contractnr.</th>
              <th className="text-left font-medium px-3 text-xs" style={{ color: '#3D4550' }}>Verzekerde</th>
              <th className="text-left font-medium px-3 text-xs" style={{ color: '#3D4550' }}>Type</th>
              <th className="text-left font-medium px-3 text-xs" style={{ color: '#3D4550' }}>Status</th>
              <th className="text-left font-medium px-3 text-xs" style={{ color: '#3D4550' }}>Premie</th>
              <th className="text-left font-medium px-3 text-xs" style={{ color: '#3D4550' }}>Looptijd</th>
            </tr>
          </thead>
          <tbody>
            {contracts.map((c, idx) => (
              <tr
                key={c.id}
                style={{
                  height: '40px',
                  backgroundColor: idx % 2 === 1 ? '#FAFBFC' : '#FFFFFF',
                  borderBottom: '1px solid #E8EBEE',
                }}
                className="hover:bg-[#F4FAF4] transition-colors duration-100 cursor-pointer"
              >
                <td className="px-3 text-xs font-medium" style={{ color: '#3B6EA5' }}>{c.contractnummer}</td>
                <td className="px-3 text-xs" style={{ color: '#1A1F24' }}>{c.verzekerde}</td>
                <td className="px-3 text-xs" style={{ color: '#3D4550' }}>{c.type}</td>
                <td className="px-3"><StatusBadge status={c.status === 'Actief' ? 'active' : 'neutral'}>{c.status}</StatusBadge></td>
                <td className="px-3 text-xs font-medium" style={{ color: '#1A1F24' }}>{c.premie}</td>
                <td className="px-3 text-xs" style={{ color: '#6B7785' }}>{c.looptijd}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}

function InstellingContactpersonenTab({ instelling }: { instelling: InstitutionDetail }) {
  if (!instelling.contactpersonen || instelling.contactpersonen.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-8">
        <Users style={{ width: '40px', height: '40px', color: '#D1D6DB' }} />
        <p className="text-sm mt-2" style={{ color: '#6B7785' }}>Geen contactpersonen geregistreerd</p>
      </div>
    )
  }

  return (
    <div className="flex flex-col gap-4">
      <h4 className="text-sm font-semibold" style={{ color: '#1A1F24' }}>Contactpersonen ({instelling.contactpersonen.length})</h4>
      <div className="rounded-lg overflow-hidden" style={{ border: '1px solid #E8EBEE' }}>
        <table className="w-full border-collapse">
          <thead>
            <tr style={{ backgroundColor: '#F2F4F6', height: '36px' }}>
              <th className="text-left font-medium px-3 text-xs" style={{ color: '#3D4550' }}>Naam</th>
              <th className="text-left font-medium px-3 text-xs" style={{ color: '#3D4550' }}>Functie</th>
              <th className="text-left font-medium px-3 text-xs" style={{ color: '#3D4550' }}>Telefoon</th>
              <th className="text-left font-medium px-3 text-xs" style={{ color: '#3D4550' }}>E-mail</th>
              <th className="text-left font-medium px-3 text-xs" style={{ color: '#3D4550' }}>Primair</th>
            </tr>
          </thead>
          <tbody>
            {instelling.contactpersonen.map((cp, idx) => (
              <tr
                key={idx}
                style={{
                  height: '40px',
                  backgroundColor: idx % 2 === 1 ? '#FAFBFC' : '#FFFFFF',
                  borderBottom: '1px solid #E8EBEE',
                }}
              >
                <td className="px-3 text-xs font-medium" style={{ color: '#1A1F24' }}>{cp.naam}</td>
                <td className="px-3 text-xs" style={{ color: '#3D4550' }}>{cp.functie}</td>
                <td className="px-3 text-xs" style={{ color: '#3D4550' }}>{cp.telefoon}</td>
                <td className="px-3 text-xs" style={{ color: '#3B6EA5' }}>{cp.email}</td>
                <td className="px-3">
                  {cp.primair ? (
                    <span
                      className="inline-flex items-center justify-center rounded-full font-semibold"
                      style={{ height: '18px', padding: '0 8px', borderRadius: '9px', fontSize: '10px', backgroundColor: '#E8F5E8', color: '#3A683A' }}
                    >
                      Ja
                    </span>
                  ) : (
                    <span className="text-xs" style={{ color: '#6B7785' }}>Nee</span>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}

function InstellingDocumentenTab({ instelling: _instelling }: { instelling: InstitutionDetail }) {
  const docs = [
    { naam: 'agentovereenkomst_2024.pdf', type: 'Overeenkomst', grootte: '1.2 MB', datum: '15/01/2024' },
    { naam: 'provisietabel_q3.pdf', type: 'Provisie', grootte: '845 KB', datum: '01/10/2024' },
    { naam: 'fsma_vergunning.pdf', type: ' Vergunning', grootte: '320 KB', datum: '20/03/2023' },
  ]

  return (
    <div className="flex flex-col gap-4">
      <h4 className="text-sm font-semibold" style={{ color: '#1A1F24' }}>Documenten</h4>
      <div className="rounded-lg overflow-hidden" style={{ border: '1px solid #E8EBEE' }}>
        <table className="w-full border-collapse">
          <thead>
            <tr style={{ backgroundColor: '#F2F4F6', height: '36px' }}>
              <th className="text-left font-medium px-3 text-xs" style={{ color: '#3D4550' }}>Bestandsnaam</th>
              <th className="text-left font-medium px-3 text-xs" style={{ color: '#3D4550' }}>Type</th>
              <th className="text-left font-medium px-3 text-xs" style={{ color: '#3D4550' }}>Grootte</th>
              <th className="text-left font-medium px-3 text-xs" style={{ color: '#3D4550' }}>Geüpload</th>
            </tr>
          </thead>
          <tbody>
            {docs.map((d, idx) => (
              <tr
                key={idx}
                style={{
                  height: '40px',
                  backgroundColor: idx % 2 === 1 ? '#FAFBFC' : '#FFFFFF',
                  borderBottom: '1px solid #E8EBEE',
                }}
                className="hover:bg-[#F4FAF4] transition-colors duration-100 cursor-pointer"
              >
                <td className="px-3 text-xs font-medium flex items-center gap-2" style={{ color: '#3B6EA5' }}>
                  <FileText style={{ width: '14px', height: '14px' }} />
                  {d.naam}
                </td>
                <td className="px-3 text-xs" style={{ color: '#3D4550' }}>{d.type}</td>
                <td className="px-3 text-xs" style={{ color: '#6B7785' }}>{d.grootte}</td>
                <td className="px-3 text-xs" style={{ color: '#6B7785' }}>{d.datum}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}

// ---- Main Page ----
export default function InstellingenPage() {
  const [filters, setFilters] = useState<FilterState>({ search: '', type: '', status: '', stad: '' })
  const [selectedInstitution, setSelectedInstitution] = useState<InstitutionDetail | null>(null)
  const [drawerOpen, setDrawerOpen] = useState(false)

  // Filter logic
  const filteredData = useMemo(() => {
    return institutionenDetails.filter((i) => {
      const naam = i.naam.toLowerCase()
      const q = filters.search.toLowerCase()
      if (q && !naam.includes(q) && !i.kbo.toLowerCase().includes(q)) return false
      if (filters.type && !institutionTypeLabel[i.type].toLowerCase().includes(filters.type.toLowerCase())) return false
      if (filters.status && !i.status.toLowerCase().includes(filters.status.toLowerCase())) return false
      if (filters.stad && i.gemeente !== filters.stad) return false
      return true
    })
  }, [filters])

  const openDetail = useCallback((inst: InstitutionDetail) => {
    setSelectedInstitution(inst)
    setDrawerOpen(true)
  }, [])

  // Table columns
  const columns = useMemo(
    () => [
      {
        key: 'type',
        header: '',
        width: '48px',
        render: (row: InstitutionDetail) => {
          const bgColor = getTypeBgColor(row.type)
          const iconColor = getTypeIconColor(row.type)
          return (
            <div
              className="flex items-center justify-center rounded-full"
              style={{ width: '28px', height: '28px', backgroundColor: bgColor, color: iconColor }}
            >
              {getTypeIcon(row.type)}
            </div>
          )
        },
      },
      {
        key: 'naam',
        header: 'Naam',
        width: '240px',
        render: (row: InstitutionDetail) => (
          <div>
            <div className="text-sm font-semibold" style={{ color: '#1A1F24' }}>{row.naam}</div>
            {row.juridischeNaam && row.juridischeNaam !== row.naam && (
              <div className="text-xs truncate" style={{ color: '#6B7785' }}>{row.juridischeNaam}</div>
            )}
          </div>
        ),
      },
      {
        key: 'kbo',
        header: 'KBO Nummer',
        width: '140px',
        render: (row: InstitutionDetail) => (
          <span className="font-mono text-xs" style={{ color: '#3D4550' }}>{row.kbo}</span>
        ),
      },
      {
        key: 'adres',
        header: 'Hoofdzetel',
        width: '200px',
        render: (row: InstitutionDetail) => (
          <div>
            <div className="text-sm truncate" style={{ color: '#1A1F24' }}>{row.adres}</div>
            <div className="text-xs" style={{ color: '#6B7785' }}>{row.postcode} {row.gemeente}</div>
          </div>
        ),
      },
      {
        key: 'stad',
        header: 'Stad',
        width: '120px',
        render: (row: InstitutionDetail) => (
          <span className="text-sm" style={{ color: '#3D4550' }}>{row.gemeente}</span>
        ),
      },
      {
        key: 'contact',
        header: 'Contact',
        width: '160px',
        render: (row: InstitutionDetail) => (
          <div>
            <div className="text-xs flex items-center gap-1" style={{ color: '#3D4550' }}>
              <Phone style={{ width: '10px', height: '10px' }} /> {row.telefoon}
            </div>
            <div className="text-xs flex items-center gap-1 mt-0.5 truncate" style={{ color: '#3B6EA5' }}>
              <Mail style={{ width: '10px', height: '10px' }} /> {row.email}
            </div>
          </div>
        ),
      },
      {
        key: 'status',
        header: 'Actief',
        width: '90px',
        render: (row: InstitutionDetail) => (
          <StatusBadge status={getStatusVariant(row.status)}>
            {row.status.charAt(0).toUpperCase() + row.status.slice(1)}
          </StatusBadge>
        ),
      },
      {
        key: 'contracten',
        header: 'Contracten',
        width: '80px',
        render: (row: InstitutionDetail) => (
          <span
            className="inline-flex items-center justify-center rounded-full font-medium"
            style={{
              width: '24px',
              height: '24px',
              fontSize: '11px',
              backgroundColor: row.contractCount > 0 ? '#E8F0F8' : '#F2F4F6',
              color: row.contractCount > 0 ? '#3B6EA5' : '#6B7785',
            }}
          >
            {row.contractCount}
          </span>
        ),
      },
    ],
    []
  )

  // Detail drawer tabs
  const detailTabs = useMemo(() => {
    if (!selectedInstitution) return []
    return [
      {
        key: 'overzicht',
        label: 'Overzicht',
        content: <InstellingOverzichtTab instelling={selectedInstitution} />,
      },
      {
        key: 'details',
        label: 'Details',
        content: <InstellingDetailsTab instelling={selectedInstitution} />,
      },
      {
        key: 'contracten',
        label: 'Contracten',
        content: <InstellingContractenTab instelling={selectedInstitution} />,
      },
      {
        key: 'contactpersonen',
        label: 'Contactpersonen',
        content: <InstellingContactpersonenTab instelling={selectedInstitution} />,
      },
      {
        key: 'documenten',
        label: 'Documenten',
        content: <InstellingDocumentenTab instelling={selectedInstitution} />,
      },
    ]
  }, [selectedInstitution])

  return (
    <div className="flex flex-col gap-6">
      {/* Breadcrumb */}
      <div className="flex items-center gap-1.5 text-xs" style={{ color: '#6B7785' }}>
        <span>Dashboard</span>
        <ChevronRight style={{ width: '14px', height: '14px' }} />
        <span className="text-[#3D4550] font-medium">Instellingen</span>
      </div>

      {/* Title */}
      <h1
        className="font-bold"
        style={{ fontSize: '28px', color: '#1A1F24', letterSpacing: '-0.02em', lineHeight: 1.2 }}
      >
        Instellingen
      </h1>

      {/* KPI Cards */}
      <InstellingenKPIs />

      {/* Filter Bar */}
      <InstellingenFilterBar filters={filters} onFilterChange={setFilters} resultCount={filteredData.length} />

      {/* Data Table */}
      <DataTable
        columns={columns}
        data={filteredData}
        onRowClick={openDetail}
        emptyMessage="Geen instellingen gevonden"
        emptyAction={
          <button
            onClick={() => setFilters({ search: '', type: '', status: '', stad: '' })}
            className="rounded-md text-[#3D4550] transition-all duration-150 hover:bg-[#F2F4F6]"
            style={{ padding: '8px 16px', fontSize: '13px', fontWeight: 500, border: '1px solid #D1D6DB' }}
          >
            Wis alle filters
          </button>
        }
      />

      {/* Detail Drawer */}
      <DetailDrawer
        open={drawerOpen}
        onClose={() => setDrawerOpen(false)}
        title={selectedInstitution?.naam || ''}
        subtitle={selectedInstitution?.kbo || ''}
        badge={
          selectedInstitution
            ? {
                status: getStatusVariant(selectedInstitution.status),
                text: institutionTypeLabel[selectedInstitution.type],
              }
            : undefined
        }
        tabs={detailTabs}
      />
    </div>
  )
}
