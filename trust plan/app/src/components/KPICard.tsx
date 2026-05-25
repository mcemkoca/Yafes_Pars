import type { ReactNode } from 'react'

interface KPICardProps {
  icon: ReactNode
  value: string
  label: string
  trend: 'up' | 'down'
  trendValue: string
  color: string
  subtitle?: string
  delay?: number
}

export default function KPICard({
  icon,
  value,
  label,
  trend,
  trendValue,
  color,
  subtitle,
  delay = 0,
}: KPICardProps) {
  const isUp = trend === 'up'
  const trendBg = isUp ? '#E8F5E8' : '#FDE8E8'
  const trendText = isUp ? '#3A683A' : '#C04A4A'

  return (
    <div
      className="bg-white rounded-lg transition-all duration-200 cursor-default hover:shadow-md"
      style={{
        border: '1px solid #E8EBEE',
        padding: '20px',
        animationDelay: `${delay}ms`,
        transform: 'translateY(-2px)',
      }}
      onMouseEnter={(e) => {
        e.currentTarget.style.transform = 'translateY(-2px)'
        e.currentTarget.style.boxShadow = '0 4px 12px rgba(0,0,0,0.08)'
      }}
      onMouseLeave={(e) => {
        e.currentTarget.style.transform = 'translateY(0)'
        e.currentTarget.style.boxShadow = 'none'
      }}
    >
      {/* Top row: Icon + Trend */}
      <div className="flex items-center justify-between mb-3">
        <div
          className="flex items-center justify-center rounded-full"
          style={{
            width: '40px',
            height: '40px',
            backgroundColor: `${color}18`,
            color: color,
          }}
        >
          {icon}
        </div>
        <div
          className="flex items-center gap-1 rounded-full"
          style={{
            height: '24px',
            padding: '2px 10px',
            backgroundColor: trendBg,
            color: trendText,
            fontSize: '12px',
            fontWeight: 600,
          }}
        >
          {isUp ? (
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="m18 15-6-6-6 6"/></svg>
          ) : (
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="m6 9 6 6 6-6"/></svg>
          )}
          {trendValue}
        </div>
      </div>

      {/* Value */}
      <div
        className="font-bold mb-1"
        style={{ fontSize: '22px', color: '#1A1F24', letterSpacing: '-0.01em' }}
      >
        {value}
      </div>

      {/* Label */}
      <div
        className="text-xs"
        style={{ color: '#6B7785', lineHeight: 1.4 }}
      >
        {label}
      </div>

      {/* Subtitle */}
      {subtitle && (
        <div
          className="text-xs mt-1"
          style={{ color: '#95A1AD', lineHeight: 1.4 }}
        >
          {subtitle}
        </div>
      )}
    </div>
  )
}
