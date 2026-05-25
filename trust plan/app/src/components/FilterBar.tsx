import { useState } from 'react'
import { Search, Download, Plus, X } from 'lucide-react'

interface FilterChip {
  key: string
  label: string
  value: string
}

interface FilterBarProps {
  filters?: FilterChip[]
  onFilterChange?: (filters: FilterChip[]) => void
  onSearch?: (query: string) => void
  onExport?: () => void
}

export default function FilterBar({
  filters = [],
  onFilterChange,
  onSearch,
  onExport,
}: FilterBarProps) {
  const [searchValue, setSearchValue] = useState('')
  const [activeFilters, setActiveFilters] = useState<FilterChip[]>(filters)

  const removeFilter = (key: string) => {
    const next = activeFilters.filter((f) => f.key !== key)
    setActiveFilters(next)
    onFilterChange?.(next)
  }

  const handleSearch = (value: string) => {
    setSearchValue(value)
    onSearch?.(value)
  }

  return (
    <div
      className="bg-white rounded-lg flex items-center gap-3 flex-wrap"
      style={{
        padding: '12px 16px',
        border: '1px solid #E8EBEE',
      }}
    >
      {/* Active filter chips */}
      {activeFilters.map((filter) => (
        <div
          key={filter.key}
          className="flex items-center gap-1.5"
          style={{
            height: '28px',
            padding: '0 8px 0 10px',
            borderRadius: '6px',
            backgroundColor: '#F4FAF4',
            border: '1px solid #E8F5E8',
            color: '#3A683A',
            fontSize: '12px',
            fontWeight: 500,
          }}
        >
          <span>{filter.label}: {filter.value}</span>
          <button
            onClick={() => removeFilter(filter.key)}
            className="flex items-center justify-center rounded-sm hover:bg-[#E8F5E8] transition-colors duration-100"
            style={{ width: '16px', height: '16px' }}
          >
            <X style={{ width: '12px', height: '12px' }} />
          </button>
        </div>
      ))}

      {/* + Filter button */}
      <button
        className="flex items-center gap-1.5 rounded-md text-[#3D4550] hover:bg-[#F2F4F6] transition-colors duration-150"
        style={{
          height: '28px',
          padding: '0 10px',
          fontSize: '12px',
          fontWeight: 500,
          border: '1px dashed #D1D6DB',
        }}
      >
        <Plus style={{ width: '14px', height: '14px' }} />
        Filter
      </button>

      <div className="flex-1" />

      {/* Search input */}
      <div
        className="relative"
        style={{ minWidth: '200px', maxWidth: '280px' }}
      >
        <Search
          className="absolute left-3 top-1/2 -translate-y-1/2 text-[#95A1AD]"
          style={{ width: '14px', height: '14px' }}
        />
        <input
          type="text"
          placeholder="Zoeken in tabel..."
          value={searchValue}
          onChange={(e) => handleSearch(e.target.value)}
          className="w-full rounded-md border border-[#D1D6DB] bg-[#FAFBFC] text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15 transition-all duration-100"
          style={{
            height: '32px',
            padding: '0 10px 0 32px',
            fontSize: '12px',
            color: '#1A1F24',
          }}
        />
      </div>

      {/* Export button */}
      {onExport && (
        <button
          onClick={onExport}
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
      )}
    </div>
  )
}
