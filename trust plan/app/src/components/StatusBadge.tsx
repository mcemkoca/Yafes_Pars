import type { ReactNode } from 'react'

type StatusVariant = 'active' | 'warning' | 'error' | 'info' | 'neutral'

const statusColors: Record<StatusVariant, { bg: string; text: string }> = {
  active: { bg: '#E8F5E8', text: '#3A683A' },
  warning: { bg: '#FDF5E8', text: '#D4942A' },
  error: { bg: '#FDE8E8', text: '#C04A4A' },
  info: { bg: '#E8F0F8', text: '#3B6EA5' },
  neutral: { bg: '#F2F4F6', text: '#6B7785' },
}

interface StatusBadgeProps {
  status: StatusVariant
  children: ReactNode
}

export default function StatusBadge({ status, children }: StatusBadgeProps) {
  const colors = statusColors[status]

  return (
    <span
      className="inline-flex items-center justify-center font-semibold uppercase"
      style={{
        height: '20px',
        padding: '2px 10px',
        borderRadius: '10px',
        fontSize: '11px',
        fontWeight: 600,
        letterSpacing: '0.02em',
        lineHeight: 1.3,
        backgroundColor: colors.bg,
        color: colors.text,
      }}
    >
      {children}
    </span>
  )
}
