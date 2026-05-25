import { useState, useMemo, useCallback } from 'react'
import { User, Building2, Users, UserPlus, Search, Download, Plus, X, Phone, Mail, MapPin, FileText, ChevronDown, ChevronRight } from 'lucide-react'
import KPICard from '../components/KPICard'
import DataTable from '../components/DataTable'
import DetailDrawer from '../components/DetailDrawer'
import StatusBadge from '../components/StatusBadge'
import { personenDetails, personContracts, cities, personenStats } from '../data/personenData'
import type { PersonDetail } from '../data/personenData'

// ---- Types ----
interface FilterState {
  search: string
  type: string
  status: string
  stad: string
}

// ---- Helpers ----
const getDisplayNaam = (p: PersonDetail): string => {
  if (p.type === 'natuurlijk') return `${p.achternaam}, ${p.voornaam}`
  return p.naam || ''
}

const getSubtitel = (p: PersonDetail): string => {
  if (p.type === 'natuurlijk') return p.gemeente
  const vormen: Record<string, string> = { BVBA: 'BVBA', NV: 'NV', VZW: 'VZW', 'Comm.V': 'Comm.V', BV: 'BV' }
  const matched = Object.keys(vormen).find((k) => p.naam?.includes(k))
  return matched ? vormen[matched] : 'Rechtspersoon'
}

const getStatusVariant = (status: string): 'active' | 'warning' | 'error' | 'info' | 'neutral' => {
  switch (status) {
    case 'actief': return 'active'
    case 'prospect': return 'info'
    case 'inactief': return 'neutral'
    default: return 'neutral'
  }
}

const formatDate = (dateStr: string): string => {
  if (!dateStr) return '-'
  const [year, month, day] = dateStr.split('-')
  return `${day}/${month}/${year}`
}

const calculateAge = (geboortedatum: string): number | null => {
  if (!geboortedatum) return null
  const birth = new Date(geboortedatum)
  const now = new Date()
  let age = now.getFullYear() - birth.getFullYear()
  const m = now.getMonth() - birth.getMonth()
  if (m < 0 || (m === 0 && now.getDate() < birth.getDate())) age--
  return age
}

// ---- KPI Row ----
function PersonenKPIs() {
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
      <KPICard
        icon={<Users style={{ width: '20px', height: '20px' }} />}
        value={personenStats.totaal.toLocaleString('nl-BE')}
        label="Totaal personen"
        trend="up"
        trendValue="2.856"
        color="#3B6EA5"
      />
      <KPICard
        icon={<User style={{ width: '20px', height: '20px' }} />}
        value={personenStats.natuurlijkePersonen.toLocaleString('nl-BE')}
        label="Natuurlijke personen"
        trend="up"
        trendValue="81%"
        color="#4A804A"
        subtitle="van totaal"
      />
      <KPICard
        icon={<Building2 style={{ width: '20px', height: '20px' }} />}
        value={personenStats.rechtspersonen.toLocaleString('nl-BE')}
        label="Rechtspersonen"
        trend="up"
        trendValue="19%"
        color="#C8A456"
        subtitle="VZW, BV, NV, ..."
      />
      <KPICard
        icon={<UserPlus style={{ width: '20px', height: '20px' }} />}
        value={`+${personenStats.nieuweDitKwartaal}`}
        label="Nieuwe registraties"
        trend="up"
        trendValue="+12%"
        color="#4A804A"
        subtitle="dit kwartaal"
      />
    </div>
  )
}

// ---- Filter Bar ----
function PersonenFilterBar({
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
        <div className="relative" style={{ minWidth: '200px', maxWidth: '280px' }}>
          <Search
            className="absolute left-3 top-1/2 -translate-y-1/2 text-[#95A1AD]"
            style={{ width: '14px', height: '14px' }}
          />
          <input
            type="text"
            placeholder="Zoek op naam, RRN of ondernemingsnummer..."
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
              <div className="absolute left-0 top-full mt-1 bg-white rounded-md shadow-lg z-20" style={{ border: '1px solid #E8EBEE', minWidth: '180px' }}>
                {['Alle', 'Natuurlijk', 'Rechtspersoon'].map((opt) => (
                  <button
                    key={opt}
                    className="w-full text-left px-3 py-2 text-sm hover:bg-[#F4FAF4] transition-colors duration-100"
                    style={{ color: '#1A1F24', fontSize: '13px' }}
                    onClick={() => { update({ type: opt === 'Alle' ? '' : opt }); setShowTypeDropdown(false) }}
                  >
                    {opt}
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
                {['Alle', 'Actief', 'Inactief', 'Prospect'].map((opt) => (
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
                {cities.map((city) => (
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
          Nieuwe Persoon
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

// ---- Detail Drawer Tabs ----
function OverzichtTabNatuurlijk({ persoon }: { persoon: PersonDetail }) {
  const age = calculateAge(persoon.geboortedatum)

  return (
    <div className="flex flex-col gap-6">
      {/* Persoonlijke Gegevens */}
      <div>
        <h4 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24' }}>Persoonlijke Gegevens</h4>
        <div className="grid grid-cols-2 gap-x-6 gap-y-2">
          <FieldRow label="Naam" value={`${persoon.voornaam} ${persoon.achternaam}`} />
          <FieldRow label="Geboortedatum" value={formatDate(persoon.geboortedatum) + (age ? ` (${age} jaar)` : '')} />
          <FieldRow label="Rijksregisternummer" value={persoon.rrn} mono />
          <FieldRow label="Nationaliteit" value={persoon.nationaliteit || '-'} />
          <FieldRow label="Burgerlijke staat" value={persoon.burgerlijkeStaat || '-'} />
          <FieldRow label="Geslacht" value={persoon.geslacht === 'M' ? 'Man' : persoon.geslacht === 'V' ? 'Vrouw' : '-'} />
          <FieldRow label="Taal" value={persoon.taal || '-'} />
          <FieldRow label="Beroep" value={persoon.beroep || '-'} />
        </div>
      </div>

      {/* Adres */}
      <div>
        <h4 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24' }}>Adres</h4>
        <div className="grid grid-cols-2 gap-x-6 gap-y-2">
          <FieldRow label="Straat" value={persoon.adres} />
          <FieldRow label="Postcode" value={persoon.postcode} />
          <FieldRow label="Stad" value={persoon.gemeente} />
          <FieldRow label="Provincie" value={persoon.provincie || '-'} />
          <FieldRow label="Land" value={persoon.land} />
        </div>
      </div>

      {/* Contact */}
      <div>
        <h4 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24' }}>Contact</h4>
        <div className="grid grid-cols-1 gap-y-2">
          <div className="flex items-center gap-2">
            <Phone style={{ width: '14px', height: '14px', color: '#6B7785' }} />
            <FieldRow label="Telefoon (mobiel)" value={persoon.telefoon} />
          </div>
          {persoon.telefoonVast && (
            <div className="flex items-center gap-2">
              <Phone style={{ width: '14px', height: '14px', color: '#6B7785' }} />
              <FieldRow label="Telefoon (vast)" value={persoon.telefoonVast} />
            </div>
          )}
          <div className="flex items-center gap-2">
            <Mail style={{ width: '14px', height: '14px', color: '#6B7785' }} />
            <FieldRow label="E-mail" value={persoon.email} />
          </div>
        </div>
      </div>

      {/* Samenvatting card */}
      <div className="rounded-lg p-4" style={{ backgroundColor: '#F2F4F6', border: '1px solid #E8EBEE' }}>
        <h4 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24' }}>Samenvatting</h4>
        <div className="grid grid-cols-2 gap-x-6 gap-y-2">
          <FieldRow label="Contracten" value={persoon.contractCount.toString()} />
          <FieldRow label="Status" value={<StatusBadge status={getStatusVariant(persoon.status)}>{persoon.status.charAt(0).toUpperCase() + persoon.status.slice(1)}</StatusBadge>} />
          <FieldRow label="Aangemaakt" value={formatDate(persoon.createdAt)} />
          <FieldRow label="Bijgewerkt" value={formatDate(persoon.updatedAt)} />
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
          Nieuwe Schade
        </button>
      </div>
    </div>
  )
}

function OverzichtTabRechtspersoon({ persoon }: { persoon: PersonDetail }) {
  return (
    <div className="flex flex-col gap-6">
      {/* Bedrijfsgegevens */}
      <div>
        <h4 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24' }}>Bedrijfsgegevens</h4>
        <div className="grid grid-cols-2 gap-x-6 gap-y-2">
          <FieldRow label="Handelsnaam" value={persoon.naam || '-'} />
          <FieldRow label="Rechtsvorm" value={persoon.type === 'rechtspersoon' ? 'Rechtspersoon' : '-'} />
          <FieldRow label="Ondernemingsnummer" value={persoon.rrn} mono />
          <FieldRow label="Status" value={<StatusBadge status={getStatusVariant(persoon.status)}>{persoon.status.charAt(0).toUpperCase() + persoon.status.slice(1)}</StatusBadge>} />
        </div>
      </div>

      {/* Contactpersonen */}
      {persoon.contactPersonen && persoon.contactPersonen.length > 0 && (
        <div>
          <h4 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24' }}>Contactpersonen</h4>
          <div className="flex flex-col gap-3">
            {persoon.contactPersonen.map((cp, idx) => (
              <div key={idx} className="rounded-lg p-3" style={{ backgroundColor: '#F2F4F6', border: '1px solid #E8EBEE' }}>
                <div className="font-medium text-sm" style={{ color: '#1A1F24' }}>{cp.naam}</div>
                <div className="text-xs mt-0.5" style={{ color: '#6B7785' }}>{cp.functie}</div>
                <div className="flex items-center gap-3 mt-2">
                  <span className="text-xs flex items-center gap-1" style={{ color: '#3D4550' }}>
                    <Phone style={{ width: '12px', height: '12px' }} /> {cp.telefoon}
                  </span>
                  <span className="text-xs flex items-center gap-1" style={{ color: '#3B6EA5' }}>
                    <Mail style={{ width: '12px', height: '12px' }} /> {cp.email}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Adres */}
      <div>
        <h4 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24' }}>Adres</h4>
        <div className="grid grid-cols-2 gap-x-6 gap-y-2">
          <FieldRow label="Straat" value={persoon.adres} />
          <FieldRow label="Postcode" value={persoon.postcode} />
          <FieldRow label="Stad" value={persoon.gemeente} />
          <FieldRow label="Provincie" value={persoon.provincie || '-'} />
          <FieldRow label="Land" value={persoon.land} />
        </div>
      </div>

      {/* Contact */}
      <div>
        <h4 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24' }}>Contact</h4>
        <div className="grid grid-cols-1 gap-y-2">
          <div className="flex items-center gap-2">
            <Phone style={{ width: '14px', height: '14px', color: '#6B7785' }} />
            <FieldRow label="Telefoon" value={persoon.telefoon} />
          </div>
          <div className="flex items-center gap-2">
            <Mail style={{ width: '14px', height: '14px', color: '#6B7785' }} />
            <FieldRow label="E-mail" value={persoon.email} />
          </div>
          {persoon.website && (
            <div className="flex items-center gap-2">
              <MapPin style={{ width: '14px', height: '14px', color: '#6B7785' }} />
              <FieldRow label="Website" value={persoon.website} />
            </div>
          )}
        </div>
      </div>

      {/* Samenvatting card */}
      <div className="rounded-lg p-4" style={{ backgroundColor: '#F2F4F6', border: '1px solid #E8EBEE' }}>
        <h4 className="text-sm font-semibold mb-3" style={{ color: '#1A1F24' }}>Samenvatting</h4>
        <div className="grid grid-cols-2 gap-x-6 gap-y-2">
          <FieldRow label="Contracten" value={persoon.contractCount.toString()} />
          <FieldRow label="Status" value={<StatusBadge status={getStatusVariant(persoon.status)}>{persoon.status.charAt(0).toUpperCase() + persoon.status.slice(1)}</StatusBadge>} />
          <FieldRow label="Aangemaakt" value={formatDate(persoon.createdAt)} />
          <FieldRow label="Bijgewerkt" value={formatDate(persoon.updatedAt)} />
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
      </div>
    </div>
  )
}

function ContactgegevensTab({ persoon }: { persoon: PersonDetail }) {
  return (
    <div className="flex flex-col gap-4">
      <h4 className="text-sm font-semibold" style={{ color: '#1A1F24' }}>Contactgegevens</h4>
      <div className="rounded-lg" style={{ border: '1px solid #E8EBEE' }}>
        <div className="flex items-center gap-3 p-3" style={{ borderBottom: '1px solid #E8EBEE' }}>
          <Phone style={{ width: '16px', height: '16px', color: '#4A804A' }} />
          <div>
            <div className="text-xs" style={{ color: '#6B7785' }}>Telefoon (mobiel)</div>
            <div className="text-sm font-medium" style={{ color: '#1A1F24' }}>{persoon.telefoon}</div>
          </div>
        </div>
        {persoon.telefoonVast && (
          <div className="flex items-center gap-3 p-3" style={{ borderBottom: '1px solid #E8EBEE' }}>
            <Phone style={{ width: '16px', height: '16px', color: '#6B7785' }} />
            <div>
              <div className="text-xs" style={{ color: '#6B7785' }}>Telefoon (vast)</div>
              <div className="text-sm font-medium" style={{ color: '#1A1F24' }}>{persoon.telefoonVast}</div>
            </div>
          </div>
        )}
        <div className="flex items-center gap-3 p-3" style={{ borderBottom: '1px solid #E8EBEE' }}>
          <Mail style={{ width: '16px', height: '16px', color: '#3B6EA5' }} />
          <div>
            <div className="text-xs" style={{ color: '#6B7785' }}>E-mail</div>
            <div className="text-sm font-medium" style={{ color: '#1A1F24' }}>{persoon.email}</div>
          </div>
        </div>
        {persoon.website && (
          <div className="flex items-center gap-3 p-3">
            <MapPin style={{ width: '16px', height: '16px', color: '#8B5E83' }} />
            <div>
              <div className="text-xs" style={{ color: '#6B7785' }}>Website</div>
              <div className="text-sm font-medium" style={{ color: '#1A1F24' }}>{persoon.website}</div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

function AdressenTab({ persoon }: { persoon: PersonDetail }) {
  return (
    <div className="flex flex-col gap-4">
      <h4 className="text-sm font-semibold" style={{ color: '#1A1F24' }}>Adressen</h4>
      <div className="rounded-lg p-4" style={{ border: '1px solid #E8EBEE', backgroundColor: '#FAFBFC' }}>
        <div className="flex items-start gap-3">
          <div className="flex items-center justify-center rounded-full" style={{ width: '32px', height: '32px', backgroundColor: '#E8F5E8' }}>
            <MapPin style={{ width: '16px', height: '16px', color: '#4A804A' }} />
          </div>
          <div className="flex-1">
            <div className="flex items-center gap-2">
              <span className="font-medium text-sm" style={{ color: '#1A1F24' }}>Hoofdadres</span>
              <span
                className="inline-flex items-center font-semibold uppercase"
                style={{ height: '18px', padding: '0 8px', borderRadius: '9px', fontSize: '10px', backgroundColor: '#E8F5E8', color: '#3A683A' }}
              >
                Primair
              </span>
            </div>
            <div className="text-sm mt-1" style={{ color: '#3D4550' }}>{persoon.adres}</div>
            <div className="text-sm" style={{ color: '#6B7785' }}>{persoon.postcode} {persoon.gemeente}</div>
            <div className="text-sm" style={{ color: '#6B7785' }}>{persoon.provincie || '-'}, {persoon.land}</div>
          </div>
        </div>
      </div>
    </div>
  )
}

function ContractenTab({ persoon }: { persoon: PersonDetail }) {
  const contracts = personContracts.filter((c) => c.personId === persoon.id)

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
      <h4 className="text-sm font-semibold" style={{ color: '#1A1F24' }}>Contracten ({contracts.length})</h4>
      <div className="rounded-lg overflow-hidden" style={{ border: '1px solid #E8EBEE' }}>
        <table className="w-full border-collapse">
          <thead>
            <tr style={{ backgroundColor: '#F2F4F6', height: '36px' }}>
              <th className="text-left font-medium px-3 text-xs" style={{ color: '#3D4550' }}>Contractnr.</th>
              <th className="text-left font-medium px-3 text-xs" style={{ color: '#3D4550' }}>Type</th>
              <th className="text-left font-medium px-3 text-xs" style={{ color: '#3D4550' }}>Status</th>
              <th className="text-left font-medium px-3 text-xs" style={{ color: '#3D4550' }}>Vervaldatum</th>
              <th className="text-left font-medium px-3 text-xs" style={{ color: '#3D4550' }}>Premie</th>
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
                <td className="px-3 text-xs" style={{ color: '#1A1F24' }}>{c.type}</td>
                <td className="px-3"><StatusBadge status="active">{c.status}</StatusBadge></td>
                <td className="px-3 text-xs" style={{ color: '#3D4550' }}>{c.vervaldatum}</td>
                <td className="px-3 text-xs font-medium" style={{ color: '#1A1F24' }}>{c.premie}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}

function GeschiedenisTab({ persoon }: { persoon: PersonDetail }) {
  if (!persoon.geschiedenis || persoon.geschiedenis.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-8">
        <FileText style={{ width: '40px', height: '40px', color: '#D1D6DB' }} />
        <p className="text-sm mt-2" style={{ color: '#6B7785' }}>Geen geschiedenis beschikbaar</p>
      </div>
    )
  }

  return (
    <div className="flex flex-col gap-4">
      <h4 className="text-sm font-semibold" style={{ color: '#1A1F24' }}>Geschiedenis</h4>
      <div className="flex flex-col gap-0">
        {persoon.geschiedenis.map((entry, idx) => (
          <div key={idx} className="flex gap-3 py-3" style={{ borderBottom: idx < persoon.geschiedenis!.length - 1 ? '1px solid #E8EBEE' : 'none' }}>
            <div className="flex flex-col items-center gap-1">
              <div className="rounded-full" style={{ width: '8px', height: '8px', backgroundColor: idx === 0 ? '#4A804A' : '#D1D6DB' }} />
              {idx < persoon.geschiedenis!.length - 1 && (
                <div className="w-px flex-1" style={{ backgroundColor: '#E8EBEE', minHeight: '24px' }} />
              )}
            </div>
            <div className="flex-1 pb-2">
              <div className="flex items-center gap-2">
                <span className="text-xs font-medium" style={{ color: '#1A1F24' }}>{entry.actie}</span>
                <span className="text-xs" style={{ color: '#6B7785' }}>{entry.datum}</span>
              </div>
              <div className="text-xs mt-0.5" style={{ color: '#3D4550' }}>{entry.details}</div>
              <div className="text-xs mt-0.5" style={{ color: '#95A1AD' }}>door {entry.gebruiker}</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

function RelatiesTab({ persoon }: { persoon: PersonDetail }) {
  if (!persoon.relaties || persoon.relaties.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-8">
        <Users style={{ width: '40px', height: '40px', color: '#D1D6DB' }} />
        <p className="text-sm mt-2" style={{ color: '#6B7785' }}>Geen relaties geregistreerd</p>
      </div>
    )
  }

  return (
    <div className="flex flex-col gap-4">
      <h4 className="text-sm font-semibold" style={{ color: '#1A1F24' }}>Relaties</h4>
      <div className="rounded-lg overflow-hidden" style={{ border: '1px solid #E8EBEE' }}>
        <table className="w-full border-collapse">
          <thead>
            <tr style={{ backgroundColor: '#F2F4F6', height: '36px' }}>
              <th className="text-left font-medium px-3 text-xs" style={{ color: '#3D4550' }}>Persoon</th>
              <th className="text-left font-medium px-3 text-xs" style={{ color: '#3D4550' }}>Relatie</th>
              <th className="text-left font-medium px-3 text-xs" style={{ color: '#3D4550' }}>Contracten Gedeeld</th>
            </tr>
          </thead>
          <tbody>
            {persoon.relaties.map((r, idx) => (
              <tr
                key={idx}
                style={{
                  height: '40px',
                  backgroundColor: idx % 2 === 1 ? '#FAFBFC' : '#FFFFFF',
                  borderBottom: '1px solid #E8EBEE',
                }}
                className="hover:bg-[#F4FAF4] transition-colors duration-100 cursor-pointer"
              >
                <td className="px-3 text-xs font-medium" style={{ color: '#1A1F24' }}>{r.naam}</td>
                <td className="px-3 text-xs" style={{ color: '#3D4550' }}>{r.relatie}</td>
                <td className="px-3">
                  <span
                    className="inline-flex items-center justify-center rounded-full font-medium"
                    style={{
                      width: '24px',
                      height: '24px',
                      fontSize: '11px',
                      backgroundColor: '#E8F0F8',
                      color: '#3B6EA5',
                    }}
                  >
                    {r.contractenGedeeld}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}

// ---- Field Row ----
function FieldRow({ label, value, mono }: { label: string; value: React.ReactNode; mono?: boolean }) {
  return (
    <div>
      <div className="text-xs" style={{ color: '#6B7785', marginBottom: '2px' }}>{label}</div>
      <div
        className={`text-sm font-medium ${mono ? 'font-mono' : ''}`}
        style={{ color: '#1A1F24' }}
      >
        {value}
      </div>
    </div>
  )
}

// ---- Main Page ----
export default function PersonenPage() {
  const [filters, setFilters] = useState<FilterState>({ search: '', type: '', status: '', stad: '' })
  const [selectedPerson, setSelectedPerson] = useState<PersonDetail | null>(null)
  const [drawerOpen, setDrawerOpen] = useState(false)

  // Filter logic
  const filteredData = useMemo(() => {
    return personenDetails.filter((p) => {
      const naam = getDisplayNaam(p).toLowerCase()
      const q = filters.search.toLowerCase()
      if (q && !naam.includes(q) && !p.rrn.toLowerCase().includes(q) && !p.email.toLowerCase().includes(q)) return false
      if (filters.type === 'Natuurlijk' && p.type !== 'natuurlijk') return false
      if (filters.type === 'Rechtspersoon' && p.type !== 'rechtspersoon') return false
      if (filters.status && !p.status.toLowerCase().includes(filters.status.toLowerCase())) return false
      if (filters.stad && p.gemeente !== filters.stad) return false
      return true
    })
  }, [filters])

  const openDetail = useCallback((persoon: PersonDetail) => {
    setSelectedPerson(persoon)
    setDrawerOpen(true)
  }, [])

  // Table columns
  const columns = useMemo(
    () => [
      {
        key: 'type',
        header: '',
        width: '48px',
        render: (row: PersonDetail) => (
          <div
            className="flex items-center justify-center rounded-full"
            style={{
              width: '28px',
              height: '28px',
              backgroundColor: row.type === 'natuurlijk' ? '#E8F0F8' : '#FDF5E8',
            }}
          >
            {row.type === 'natuurlijk' ? (
              <User style={{ width: '14px', height: '14px', color: '#3B6EA5' }} />
            ) : (
              <Building2 style={{ width: '14px', height: '14px', color: '#C8A456' }} />
            )}
          </div>
        ),
      },
      {
        key: 'naam',
        header: 'Naam',
        width: '220px',
        render: (row: PersonDetail) => (
          <div>
            <div className="text-sm font-semibold" style={{ color: '#1A1F24' }}>
              {getDisplayNaam(row)}
            </div>
            <div className="text-xs" style={{ color: '#6B7785' }}>{getSubtitel(row)}</div>
          </div>
        ),
      },
      {
        key: 'identificatie',
        header: 'Identificatie',
        width: '140px',
        render: (row: PersonDetail) => (
          <span className="font-mono text-xs" style={{ color: '#3D4550' }}>
            {row.rrn}
          </span>
        ),
      },
      {
        key: 'adres',
        header: 'Adres',
        width: '200px',
        render: (row: PersonDetail) => (
          <div>
            <div className="text-sm truncate" style={{ color: '#1A1F24' }}>{row.adres}</div>
            <div className="text-xs" style={{ color: '#6B7785' }}>{row.postcode} {row.gemeente}</div>
          </div>
        ),
      },
      {
        key: 'contact',
        header: 'Contact',
        width: '180px',
        render: (row: PersonDetail) => (
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
        header: 'Status',
        width: '100px',
        render: (row: PersonDetail) => (
          <StatusBadge status={getStatusVariant(row.status)}>
            {row.status.charAt(0).toUpperCase() + row.status.slice(1)}
          </StatusBadge>
        ),
      },
      {
        key: 'contracten',
        header: 'Contracten',
        width: '80px',
        render: (row: PersonDetail) => (
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
    if (!selectedPerson) return []
    const isNatuurlijk = selectedPerson.type === 'natuurlijk'
    return [
      {
        key: 'overzicht',
        label: 'Overzicht',
        content: isNatuurlijk
          ? <OverzichtTabNatuurlijk persoon={selectedPerson} />
          : <OverzichtTabRechtspersoon persoon={selectedPerson} />,
      },
      {
        key: 'contact',
        label: 'Contactgegevens',
        content: <ContactgegevensTab persoon={selectedPerson} />,
      },
      {
        key: 'adressen',
        label: 'Adressen',
        content: <AdressenTab persoon={selectedPerson} />,
      },
      {
        key: 'contracten',
        label: 'Contracten',
        content: <ContractenTab persoon={selectedPerson} />,
      },
      ...(isNatuurlijk ? [{
        key: 'relaties',
        label: 'Relaties',
        content: <RelatiesTab persoon={selectedPerson} />,
      }] : []),
      {
        key: 'geschiedenis',
        label: 'Geschiedenis',
        content: <GeschiedenisTab persoon={selectedPerson} />,
      },
    ]
  }, [selectedPerson])

  return (
    <div className="flex flex-col gap-6">
      {/* Breadcrumb */}
      <div className="flex items-center gap-1.5 text-xs" style={{ color: '#6B7785' }}>
        <span>Dashboard</span>
        <ChevronRight style={{ width: '14px', height: '14px' }} />
        <span className="text-[#3D4550] font-medium">Personen</span>
      </div>

      {/* Title */}
      <h1
        className="font-bold"
        style={{ fontSize: '28px', color: '#1A1F24', letterSpacing: '-0.02em', lineHeight: 1.2 }}
      >
        Personen
      </h1>

      {/* KPI Cards */}
      <PersonenKPIs />

      {/* Filter Bar */}
      <PersonenFilterBar filters={filters} onFilterChange={setFilters} resultCount={filteredData.length} />

      {/* Data Table */}
      <DataTable
        columns={columns}
        data={filteredData}
        onRowClick={openDetail}
        emptyMessage="Geen personen gevonden"
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
        title={selectedPerson ? getDisplayNaam(selectedPerson) : ''}
        subtitle={selectedPerson ? selectedPerson.rrn : ''}
        badge={
          selectedPerson
            ? {
                status: getStatusVariant(selectedPerson.status),
                text: selectedPerson.type === 'natuurlijk' ? 'Natuurlijke Persoon' : 'Rechtspersoon',
              }
            : undefined
        }
        tabs={detailTabs}
      />
    </div>
  )
}
