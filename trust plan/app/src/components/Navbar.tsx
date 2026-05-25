import { useState } from 'react'
import { NavLink } from 'react-router-dom'
import {
  LayoutDashboard,
  Users,
  Building2,
  Package,
  FileText,
  AlertCircle,
  BarChart3,
  Settings,
  LogOut,
  ChevronLeft,
  ChevronRight,
} from 'lucide-react'

const navItems = [
  { label: 'Dashboard', icon: LayoutDashboard, path: '/' },
  { label: 'Personen', icon: Users, path: '/personen' },
  { label: 'Instellingen', icon: Building2, path: '/instellingen' },
  { label: 'Objecten', icon: Package, path: '/objecten' },
  { label: 'Contracten', icon: FileText, path: '/contracten' },
  { label: 'Schadeclaims', icon: AlertCircle, path: '/schadeclaims' },
  { label: 'Rapporten', icon: BarChart3, path: '/rapporten' },
  { label: 'Beheer', icon: Settings, path: '/beheer' },
]

export default function Navbar() {
  const [collapsed, setCollapsed] = useState(false)

  return (
    <aside
      className="flex flex-col h-screen transition-all duration-200 shrink-0"
      style={{
        width: collapsed ? '64px' : '256px',
        backgroundColor: '#1B2E1B',
        transitionTimingFunction: 'cubic-bezier(0.4, 0, 0.2, 1)',
      }}
    >
      {/* Logo */}
      <div
        className="flex items-center gap-3 shrink-0"
        style={{
          height: '56px',
          padding: collapsed ? '0 12px' : '0 16px',
          borderBottom: '1px solid #2A4A2A',
        }}
      >
        <img
          src="./logo-shield.svg"
          alt="AssureManager"
          className="shrink-0"
          style={{ width: '32px', height: '32px' }}
        />
        {!collapsed && (
          <img
            src="./logo-wordmark.svg"
            alt="AssureManager"
            className="transition-opacity duration-150"
            style={{ height: '20px' }}
          />
        )}
      </div>

      {/* Nav Items */}
      <nav className="flex-1 overflow-y-auto py-3 px-2 space-y-0.5">
        {navItems.map((item) => {
          const Icon = item.icon
          return (
            <NavLink
              key={item.path}
              to={item.path}
              end={item.path === '/'}
              className={({ isActive }) => {
                const base =
                  'flex items-center gap-3 rounded-md transition-colors duration-150 no-underline'
                const size = collapsed
                  ? 'justify-center px-2'
                  : 'px-3'
                const active = isActive
                  ? 'bg-[#3A683A] text-white border-l-[3px] border-[#5A9A5A]'
                  : 'text-[#95A1AD] hover:bg-[#2A4A2A] hover:text-white border-l-[3px] border-transparent'
                return `${base} ${size} ${active}`
              }}
              style={{
                height: '40px',
                minHeight: '40px',
              }}
              title={collapsed ? item.label : undefined}
            >
              <Icon
                style={{
                  width: '20px',
                  height: '20px',
                  minWidth: '20px',
                  minHeight: '20px',
                }}
              />
              {!collapsed && (
                <span
                  className="text-sm font-medium whitespace-nowrap transition-opacity duration-150"
                >
                  {item.label}
                </span>
              )}
            </NavLink>
          )
        })}
      </nav>

      {/* Bottom: User + Collapse */}
      <div className="shrink-0" style={{ borderTop: '1px solid #2A4A2A' }}>
        {/* User */}
        <div
          className="flex items-center gap-3"
          style={{
            padding: collapsed ? '12px 8px' : '12px 16px',
            minHeight: '52px',
          }}
        >
          <img
            src="./avatar-default.svg"
            alt="Jan De Vries"
            className="shrink-0 rounded-full"
            style={{ width: '32px', height: '32px' }}
          />
          {!collapsed && (
            <div className="flex-1 min-w-0 transition-opacity duration-150">
              <div className="text-sm font-medium text-white truncate">
                Jan De Vries
              </div>
              <div className="text-xs text-[#95A1AD] truncate">Beheerder</div>
            </div>
          )}
          {!collapsed && (
            <button
              className="flex items-center justify-center rounded-md text-[#95A1AD] hover:text-white hover:bg-[#2A4A2A] transition-colors duration-150 shrink-0"
              style={{ width: '28px', height: '28px' }}
              title="Uitloggen"
            >
              <LogOut style={{ width: '16px', height: '16px' }} />
            </button>
          )}
        </div>

        {/* Collapse Toggle */}
        <button
          onClick={() => setCollapsed(!collapsed)}
          className="w-full flex items-center justify-center gap-2 text-[#95A1AD] hover:text-white hover:bg-[#2A4A2A] transition-colors duration-150"
          style={{
            height: '40px',
            borderTop: '1px solid #2A4A2A',
          }}
        >
          {collapsed ? (
            <ChevronRight style={{ width: '16px', height: '16px' }} />
          ) : (
            <>
              <ChevronLeft style={{ width: '16px', height: '16px' }} />
              <span className="text-xs font-medium">Inklappen</span>
            </>
          )}
        </button>
      </div>
    </aside>
  )
}
