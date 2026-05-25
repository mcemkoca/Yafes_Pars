import { useState, type ReactNode } from 'react'
import { X } from 'lucide-react'
import StatusBadge from './StatusBadge'

interface Tab {
  key: string
  label: string
  content: ReactNode
}

interface DetailDrawerProps {
  open: boolean
  onClose: () => void
  title: string
  subtitle?: string
  badge?: { status: 'active' | 'warning' | 'error' | 'info' | 'neutral'; text: string }
  tabs?: Tab[]
  children?: ReactNode
}

export default function DetailDrawer({
  open,
  onClose,
  title,
  subtitle,
  badge,
  tabs,
  children,
}: DetailDrawerProps) {
  const [activeTab, setActiveTab] = useState(tabs?.[0]?.key ?? '')

  if (!open) return null

  return (
    <div className="fixed inset-0 z-50" style={{ pointerEvents: 'none' }}>
      {/* Backdrop */}
      <div
        className="absolute inset-0"
        style={{
          backgroundColor: '#0F1215',
          opacity: 0.3,
          pointerEvents: 'auto',
        }}
        onClick={onClose}
      />

      {/* Drawer */}
      <div
        className="absolute right-0 top-0 h-full bg-white flex flex-col overflow-hidden"
        style={{
          width: '560px',
          pointerEvents: 'auto',
          animation: 'slideInDrawer 300ms cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards',
          boxShadow: '-4px 0 24px rgba(0,0,0,0.12)',
        }}
      >
        {/* Header */}
        <div
          className="shrink-0 flex items-start justify-between"
          style={{
            padding: '20px 24px',
            borderBottom: '1px solid #E8EBEE',
          }}
        >
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 mb-1">
              {badge && <StatusBadge status={badge.status}>{badge.text}</StatusBadge>}
            </div>
            <h2
              className="font-semibold truncate"
              style={{
                fontSize: '18px',
                color: '#1A1F24',
                letterSpacing: '-0.01em',
              }}
            >
              {title}
            </h2>
            {subtitle && (
              <p className="text-sm mt-0.5" style={{ color: '#6B7785' }}>
                {subtitle}
              </p>
            )}
          </div>
          <button
            onClick={onClose}
            className="flex items-center justify-center rounded-md text-[#95A1AD] hover:text-[#1A1F24] hover:bg-[#F2F4F6] transition-colors duration-150 shrink-0 ml-4"
            style={{ width: '32px', height: '32px' }}
          >
            <X style={{ width: '18px', height: '18px' }} />
          </button>
        </div>

        {/* Tabs */}
        {tabs && tabs.length > 0 && (
          <div
            className="shrink-0 flex items-center"
            style={{
              height: '40px',
              borderBottom: '1px solid #E8EBEE',
              padding: '0 24px',
              gap: '0',
            }}
          >
            {tabs.map((tab) => (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key)}
                className="relative font-medium transition-colors duration-150"
                style={{
                  height: '40px',
                  padding: '0 16px',
                  fontSize: '14px',
                  color: activeTab === tab.key ? '#4A804A' : '#6B7785',
                  borderBottom: activeTab === tab.key ? '2px solid #4A804A' : '2px solid transparent',
                }}
              >
                {tab.label}
              </button>
            ))}
          </div>
        )}

        {/* Content */}
        <div className="flex-1 overflow-auto" style={{ padding: '24px' }}>
          {tabs && tabs.length > 0
            ? tabs.find((t) => t.key === activeTab)?.content
            : children}
        </div>
      </div>

      <style>{`
        @keyframes slideInDrawer {
          from { transform: translateX(100%); }
          to { transform: translateX(0); }
        }
      `}</style>
    </div>
  )
}
