import { useState } from 'react'
import { useLocation } from 'react-router-dom'
import { Search, Bell, ChevronRight } from 'lucide-react'

const routeTitles: Record<string, string> = {
  '/': 'Dashboard',
  '/personen': 'Personen',
  '/instellingen': 'Instellingen',
  '/objecten': 'Objecten',
  '/contracten': 'Contracten',
  '/schadeclaims': 'Schadeclaims',
  '/rapporten': 'Rapporten',
  '/beheer': 'Beheer',
}

export default function TopBar() {
  const location = useLocation()
  const [searchValue, setSearchValue] = useState('')

  const title = routeTitles[location.pathname] || 'Dashboard'

  return (
    <header
      className="shrink-0 flex items-center justify-between bg-white"
      style={{
        height: '56px',
        borderBottom: '1px solid #E8EBEE',
        padding: '0 24px',
      }}
    >
      {/* Left: Breadcrumb + Title */}
      <div className="flex items-center gap-2">
        <div className="flex items-center gap-1.5 text-xs text-[#6B7785]">
          <span>Home</span>
          <ChevronRight style={{ width: '14px', height: '14px' }} />
          <span className="text-[#3D4550] font-medium">{title}</span>
        </div>
      </div>

      <h1
        className="absolute left-1/2 -translate-x-1/2 font-bold"
        style={{
          fontSize: '18px',
          color: '#1A1F24',
          letterSpacing: '-0.01em',
        }}
      >
        {title}
      </h1>

      {/* Right: Search + Notifications + User */}
      <div className="flex items-center gap-3">
        {/* Search */}
        <div
          className="relative"
          style={{ width: '240px' }}
        >
          <Search
            className="absolute left-3 top-1/2 -translate-y-1/2 text-[#95A1AD]"
            style={{ width: '16px', height: '16px' }}
          />
          <input
            type="text"
            placeholder="Zoeken..."
            value={searchValue}
            onChange={(e) => setSearchValue(e.target.value)}
            className="w-full rounded-full border border-[#D1D6DB] bg-[#FAFBFC] text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15 transition-all duration-100"
            style={{
              height: '36px',
              padding: '0 14px 0 36px',
              fontSize: '13px',
              color: '#1A1F24',
            }}
          />
        </div>

        {/* Notification Bell */}
        <button
          className="relative flex items-center justify-center rounded-md text-[#6B7785] hover:text-[#1A1F24] hover:bg-[#F2F4F6] transition-colors duration-150"
          style={{ width: '36px', height: '36px' }}
        >
          <Bell style={{ width: '18px', height: '18px' }} />
          <span
            className="absolute top-1 right-1 flex items-center justify-center rounded-full text-white text-[10px] font-semibold"
            style={{
              width: '16px',
              height: '16px',
              backgroundColor: '#C04A4A',
            }}
          >
            3
          </span>
        </button>

        {/* User avatar */}
        <button className="flex items-center gap-2 rounded-md hover:bg-[#F2F4F6] transition-colors duration-150" style={{ padding: '4px 8px' }}>
          <img
            src="./avatar-default.svg"
            alt="Jan De Vries"
            className="rounded-full"
            style={{ width: '28px', height: '28px' }}
          />
        </button>
      </div>
    </header>
  )
}
