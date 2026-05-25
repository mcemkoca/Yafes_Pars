import { useNavigate } from 'react-router-dom'
import {
  FileText,
  AlertCircle,
  Users,
  Euro,
  FilePlus,
  CirclePlus,
  UserPlus,
  Car,
  Calculator,
  BarChart3,
  ChevronRight,
  Eye,
  RefreshCw,
  Clock,
  CheckCircle,
} from 'lucide-react'
import {
  ComposedChart,
  Bar,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
} from 'recharts'
import KPICard from '@/components/KPICard'
import StatusBadge from '@/components/StatusBadge'
import {
  kpiData,
  monthlyChartData,
  claimsByCategory,
  activities,
  expiringContracts,
  openClaimsSummary,
} from '@/data/mockData'

const quickActions = [
  { icon: FilePlus, label: 'Nieuw Contract', description: 'Contract aanmaken', path: '/contracten', color: '#4A804A' },
  { icon: CirclePlus, label: 'Nieuwe Schadeclaim', description: 'Schade melden', path: '/schadeclaims', color: '#D4942A' },
  { icon: UserPlus, label: 'Persoon Toevoegen', description: 'Nieuwe persoon', path: '/personen', color: '#3B6EA5' },
  { icon: Car, label: 'Object Registreren', description: 'Voertuig of pand', path: '/objecten', color: '#8B5E83' },
  { icon: Calculator, label: 'Offerte Aanmaken', description: 'Nieuwe offerte', path: '/contracten', color: '#C07A4A' },
  { icon: BarChart3, label: 'Rapport Genereren', description: 'Rapport opstellen', path: '/rapporten', color: '#C8A456' },
]

function getActivityIcon(type: string) {
  switch (type) {
    case 'contract_aangemaakt':
      return <FileText style={{ width: '16px', height: '16px' }} />
    case 'claim_bijgewerkt':
      return <AlertCircle style={{ width: '16px', height: '16px' }} />
    case 'persoon_toegevoegd':
      return <Users style={{ width: '16px', height: '16px' }} />
    case 'herinnering':
      return <Clock style={{ width: '16px', height: '16px' }} />
    case 'verlenging':
      return <RefreshCw style={{ width: '16px', height: '16px' }} />
    case 'commissie':
      return <Euro style={{ width: '16px', height: '16px' }} />
    case 'object_gekoppeld':
      return <Car style={{ width: '16px', height: '16px' }} />
    case 'batch_export':
      return <CheckCircle style={{ width: '16px', height: '16px' }} />
    case 'systeem':
      return <Clock style={{ width: '16px', height: '16px' }} />
    default:
      return <FileText style={{ width: '16px', height: '16px' }} />
  }
}

function getActivityIconBg(type: string) {
  switch (type) {
    case 'contract_aangemaakt':
      return { bg: '#E8F5E8', color: '#4A804A' }
    case 'claim_bijgewerkt':
      return { bg: '#FDF5E8', color: '#D4942A' }
    case 'persoon_toegevoegd':
      return { bg: '#E8F0F8', color: '#3B6EA5' }
    case 'commissie':
      return { bg: '#FDF8EC', color: '#C8A456' }
    case 'systeem':
      return { bg: '#F2F4F6', color: '#6B7785' }
    default:
      return { bg: '#F2F4F6', color: '#6B7785' }
  }
}

const statusColorMap: Record<string, 'active' | 'warning' | 'error' | 'info' | 'neutral'> = {
  in_behandeling: 'active',
  in_afwachting_dossier: 'warning',
  expert_aangesteld: 'info',
  nieuw: 'info',
}

const statusLabelMap: Record<string, string> = {
  in_behandeling: 'In behandeling',
  in_afwachting_dossier: 'In afwachting dossier',
  expert_aangesteld: 'Expert aangesteld',
  nieuw: 'Nieuw',
}

const CustomTooltip = ({ active, payload, label }: { active?: boolean; payload?: Array<{ name: string; value: number; color: string }>; label?: string }) => {
  if (!active || !payload) return null
  return (
    <div
      className="rounded-lg shadow-lg"
      style={{
        backgroundColor: '#FFFFFF',
        padding: '12px 16px',
        border: '1px solid #E8EBEE',
        fontSize: '13px',
      }}
    >
      <div className="font-semibold mb-2" style={{ color: '#1A1F24' }}>{label}</div>
      {payload.map((entry, idx) => (
        <div key={idx} className="flex items-center gap-2">
          <span
            className="inline-block rounded-full"
            style={{
              width: '8px',
              height: '8px',
              backgroundColor: entry.color,
            }}
          />
          <span style={{ color: '#6B7785' }}>{entry.name}:</span>
          <span className="font-semibold" style={{ color: '#1A1F24' }}>
            {entry.name === 'Commissie (€)'
              ? `€ ${entry.value.toLocaleString('nl-BE')}`
              : entry.value}
          </span>
        </div>
      ))}
    </div>
  )
}

export default function Dashboard() {
  const navigate = useNavigate()

  return (
    <div className="space-y-6" style={{ maxWidth: '1440px' }}>
      {/* ====== KPI ROW ====== */}
      <div
        className="grid gap-4"
        style={{
          gridTemplateColumns: 'repeat(4, 1fr)',
        }}
      >
        <KPICard
          icon={<FileText style={{ width: '22px', height: '22px' }} />}
          value={kpiData.actieveContracten.value}
          label="Actieve verzekeringscontracten"
          trend={kpiData.actieveContracten.trend}
          trendValue={kpiData.actieveContracten.trendValue}
          color="#4A804A"
          subtitle={kpiData.actieveContracten.subtitle}
          delay={0}
        />
        <KPICard
          icon={<AlertCircle style={{ width: '22px', height: '22px' }} />}
          value={kpiData.openSchades.value}
          label="Open schadeclaims"
          trend={kpiData.openSchades.trend}
          trendValue={kpiData.openSchades.trendValue}
          color="#D4942A"
          subtitle={kpiData.openSchades.subtitle}
          delay={80}
        />
        <KPICard
          icon={<Users style={{ width: '22px', height: '22px' }} />}
          value={kpiData.totaalPersonen.value}
          label="Geregistreerde personen"
          trend={kpiData.totaalPersonen.trend}
          trendValue={kpiData.totaalPersonen.trendValue}
          color="#3B6EA5"
          subtitle={kpiData.totaalPersonen.subtitle}
          delay={160}
        />
        <KPICard
          icon={<Euro style={{ width: '22px', height: '22px' }} />}
          value={kpiData.maandOmzet.value}
          label="Commissie deze maand"
          trend={kpiData.maandOmzet.trend}
          trendValue={kpiData.maandOmzet.trendValue}
          color="#C8A456"
          subtitle={kpiData.maandOmzet.subtitle}
          delay={240}
        />
      </div>

      {/* ====== CHARTS ROW ====== */}
      <div
        className="grid gap-4"
        style={{ gridTemplateColumns: '3fr 2fr' }}
      >
        {/* Line + Bar Combo Chart */}
        <div
          className="bg-white rounded-lg"
          style={{
            border: '1px solid #E8EBEE',
            padding: '20px',
          }}
        >
          <div className="mb-1">
            <h3
              className="font-semibold"
              style={{ fontSize: '15px', color: '#1A1F24' }}
            >
              Contracten & Commissie per Maand
            </h3>
            <p className="text-xs" style={{ color: '#6B7785' }}>Laatste 12 maanden</p>
          </div>
          <div style={{ width: '100%', height: '300px' }}>
            <ResponsiveContainer width="100%" height="100%">
              <ComposedChart data={monthlyChartData} margin={{ top: 16, right: 16, left: 0, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#E8EBEE" vertical={false} />
                <XAxis
                  dataKey="maand"
                  tick={{ fontSize: 12, fill: '#6B7785' }}
                  axisLine={{ stroke: '#E8EBEE' }}
                  tickLine={false}
                />
                <YAxis
                  yAxisId="left"
                  tick={{ fontSize: 12, fill: '#6B7785' }}
                  axisLine={false}
                  tickLine={false}
                  domain={[0, 160]}
                />
                <YAxis
                  yAxisId="right"
                  orientation="right"
                  tick={{ fontSize: 12, fill: '#6B7785' }}
                  axisLine={false}
                  tickLine={false}
                  domain={[0, 55000]}
                  tickFormatter={(v) => `€${(v / 1000).toFixed(0)}k`}
                />
                <Tooltip content={<CustomTooltip />} />
                <Legend
                  wrapperStyle={{ fontSize: '12px', paddingTop: '8px' }}
                  formatter={(value: string) => <span style={{ color: '#6B7785' }}>{value}</span>}
                />
                <Bar
                  yAxisId="left"
                  dataKey="contracten"
                  name="Contracten"
                  fill="#4A804A"
                  fillOpacity={0.8}
                  radius={[4, 4, 0, 0]}
                />
                <Line
                  yAxisId="right"
                  type="monotone"
                  dataKey="commissie"
                  name="Commissie (€)"
                  stroke="#C8A456"
                  strokeWidth={2}
                  dot={{ r: 4, fill: '#C8A456', stroke: '#fff', strokeWidth: 2 }}
                  activeDot={{ r: 5 }}
                />
              </ComposedChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Donut Chart */}
        <div
          className="bg-white rounded-lg"
          style={{
            border: '1px solid #E8EBEE',
            padding: '20px',
          }}
        >
          <div className="mb-1">
            <h3
              className="font-semibold"
              style={{ fontSize: '15px', color: '#1A1F24' }}
            >
              Schades per Categorie
            </h3>
          </div>
          <div style={{ width: '100%', height: '300px' }}>
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={claimsByCategory}
                  cx="45%"
                  cy="50%"
                  innerRadius="60%"
                  outerRadius="85%"
                  dataKey="value"
                  nameKey="name"
                  strokeWidth={0}
                >
                  {claimsByCategory.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip
                  formatter={(value: number, name: string) => {
                    const total = claimsByCategory.reduce((s, c) => s + c.value, 0)
                    const pct = ((value / total) * 100).toFixed(0)
                    return [`${value} (${pct}%)`, name]
                  }}
                  contentStyle={{
                    backgroundColor: '#FFFFFF',
                    border: '1px solid #E8EBEE',
                    borderRadius: '8px',
                    boxShadow: '0 4px 12px rgba(0,0,0,0.08)',
                    fontSize: '12px',
                  }}
                />
                {/* Center label */}
                <text x="45%" y="47%" textAnchor="middle" dominantBaseline="central" style={{ fontSize: '22px', fontWeight: 700, fill: '#1A1F24' }}>
                  38
                </text>
                <text x="45%" y="56%" textAnchor="middle" dominantBaseline="central" style={{ fontSize: '12px', fill: '#6B7785' }}>
                  open schades
                </text>
              </PieChart>
            </ResponsiveContainer>
          </div>
          {/* Legend */}
          <div className="flex flex-wrap gap-x-4 gap-y-1 justify-center mt-1">
            {claimsByCategory.map((cat) => (
              <div key={cat.name} className="flex items-center gap-1.5">
                <span
                  className="rounded-full"
                  style={{
                    width: '8px',
                    height: '8px',
                    backgroundColor: cat.color,
                  }}
                />
                <span className="text-xs" style={{ color: '#6B7785' }}>
                  {cat.name.split(' ')[0]} ({cat.value})
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* ====== CONTENT ROW: Quick Actions + Activity ====== */}
      <div
        className="grid gap-4"
        style={{ gridTemplateColumns: '1fr 1fr' }}
      >
        {/* Quick Actions */}
        <div
          className="bg-white rounded-lg"
          style={{
            border: '1px solid #E8EBEE',
            padding: '20px',
          }}
        >
          <h3
            className="font-semibold mb-4"
            style={{ fontSize: '15px', color: '#1A1F24' }}
          >
            Snelle Acties
          </h3>
          <div
            className="grid gap-3"
            style={{ gridTemplateColumns: 'repeat(3, 1fr)' }}
          >
            {quickActions.map((action) => {
              const Icon = action.icon
              return (
                <button
                  key={action.label}
                  onClick={() => navigate(action.path)}
                  className="flex flex-col items-center text-center rounded-lg transition-all duration-150 bg-white hover:bg-[#F4FAF4]"
                  style={{
                    padding: '16px 12px',
                    border: '1px solid #E8EBEE',
                    gap: '8px',
                  }}
                  onMouseEnter={(e) => {
                    e.currentTarget.style.borderColor = '#E8F5E8'
                    e.currentTarget.style.transform = 'translateY(-1px)'
                    e.currentTarget.style.boxShadow = '0 2px 8px rgba(0,0,0,0.06)'
                  }}
                  onMouseLeave={(e) => {
                    e.currentTarget.style.borderColor = '#E8EBEE'
                    e.currentTarget.style.transform = 'translateY(0)'
                    e.currentTarget.style.boxShadow = 'none'
                  }}
                >
                  <div style={{ color: action.color }}>
                    <Icon style={{ width: '28px', height: '28px' }} />
                  </div>
                  <div>
                    <div
                      className="font-semibold"
                      style={{ fontSize: '12px', color: '#1A1F24' }}
                    >
                      {action.label}
                    </div>
                    <div
                      className="text-xs mt-0.5"
                      style={{ color: '#6B7785' }}
                    >
                      {action.description}
                    </div>
                  </div>
                </button>
              )
            })}
          </div>
        </div>

        {/* Recent Activity */}
        <div
          className="bg-white rounded-lg"
          style={{
            border: '1px solid #E8EBEE',
            padding: '20px',
          }}
        >
          <div className="flex items-center justify-between mb-4">
            <h3
              className="font-semibold"
              style={{ fontSize: '15px', color: '#1A1F24' }}
            >
              Laatste Activiteit
            </h3>
            <button
              onClick={() => navigate('/beheer')}
              className="text-xs font-medium flex items-center gap-1 transition-colors duration-150"
              style={{ color: '#4A804A' }}
              onMouseEnter={(e) => { e.currentTarget.style.color = '#3A683A' }}
              onMouseLeave={(e) => { e.currentTarget.style.color = '#4A804A' }}
            >
              Bekijk alle activiteit
              <ChevronRight style={{ width: '14px', height: '14px' }} />
            </button>
          </div>
          <div className="space-y-0">
            {activities.map((activity, idx) => {
              const iconStyle = getActivityIconBg(activity.type)
              const parts = activity.beschrijving.split(activity.entityRef || '')
              return (
                <div
                  key={activity.id}
                  className="flex items-start gap-3"
                  style={{
                    padding: idx === 0 ? '0 0 12px 0' : '12px 0',
                    borderLeft: '2px solid #E8EBEE',
                    paddingLeft: '16px',
                    marginLeft: '15px',
                    position: 'relative',
                  }}
                >
                  {/* Dot on the line */}
                  <div
                    className="absolute rounded-full"
                    style={{
                      width: '8px',
                      height: '8px',
                      backgroundColor: '#D1D6DB',
                      left: '-5px',
                      top: idx === 0 ? '4px' : '16px',
                    }}
                  />
                  <div
                    className="rounded-full flex items-center justify-center shrink-0"
                    style={{
                      width: '32px',
                      height: '32px',
                      backgroundColor: iconStyle.bg,
                      color: iconStyle.color,
                      marginLeft: '-4px',
                    }}
                  >
                    {getActivityIcon(activity.type)}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm" style={{ color: '#1A1F24', lineHeight: 1.5 }}>
                      <strong>{activity.gebruiker}</strong>{' '}
                      {activity.entityRef ? (
                        <>
                          {parts[0]}
                          <span style={{ color: '#4A804A', fontWeight: 500 }}>{activity.entityRef}</span>
                          {parts[1] || ''}
                        </>
                      ) : (
                        activity.beschrijving
                      )}
                    </p>
                    <p className="text-xs mt-0.5" style={{ color: '#6B7785' }}>
                      {activity.relativeTime}
                    </p>
                  </div>
                </div>
              )
            })}
          </div>
        </div>
      </div>

      {/* ====== CONTENT ROW: Expiring Contracts + Open Claims ====== */}
      <div
        className="grid gap-4"
        style={{ gridTemplateColumns: '1fr 1fr' }}
      >
        {/* Expiring Contracts */}
        <div
          className="bg-white rounded-lg"
          style={{
            border: '1px solid #E8EBEE',
            padding: '20px',
          }}
        >
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-2">
              <h3
                className="font-semibold"
                style={{ fontSize: '15px', color: '#1A1F24' }}
              >
                Contracten bijna Vervallend
              </h3>
              <span
                className="flex items-center justify-center rounded-full text-white text-xs font-semibold"
                style={{
                  width: '20px',
                  height: '20px',
                  backgroundColor: '#D4942A',
                }}
              >
                7
              </span>
            </div>
            <button
              onClick={() => navigate('/contracten')}
              className="text-xs font-medium flex items-center gap-1 transition-colors duration-150"
              style={{ color: '#4A804A' }}
              onMouseEnter={(e) => { e.currentTarget.style.color = '#3A683A' }}
              onMouseLeave={(e) => { e.currentTarget.style.color = '#4A804A' }}
            >
              Bekijk alle 7
              <ChevronRight style={{ width: '14px', height: '14px' }} />
            </button>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr style={{ borderBottom: '1px solid #E8EBEE' }}>
                  <th className="text-left font-semibold" style={{ padding: '8px 12px 8px 0', fontSize: '12px', color: '#3D4550' }}>Contractnr.</th>
                  <th className="text-left font-semibold" style={{ padding: '8px 12px', fontSize: '12px', color: '#3D4550' }}>Verzekerde</th>
                  <th className="text-left font-semibold" style={{ padding: '8px 12px', fontSize: '12px', color: '#3D4550' }}>Vervaldatum</th>
                  <th className="text-left font-semibold" style={{ padding: '8px 0 8px 12px', fontSize: '12px', color: '#3D4550' }}>Actie</th>
                </tr>
              </thead>
              <tbody>
                {expiringContracts.map((contract) => (
                  <tr
                    key={contract.id}
                    style={{ borderBottom: '1px solid #F2F4F6', height: '44px' }}
                  >
                    <td style={{ padding: '8px 12px 8px 0' }}>
                      <span
                        className="font-mono text-xs font-medium"
                        style={{ color: '#3B6EA5' }}
                      >
                        {contract.contractnummer}
                      </span>
                    </td>
                    <td
                      className="text-sm"
                      style={{ padding: '8px 12px', color: '#1A1F24' }}
                    >
                      {contract.verzekerde}
                    </td>
                    <td style={{ padding: '8px 12px' }}>
                      <StatusBadge
                        status={contract.dagenResterend <= 7 ? 'error' : contract.dagenResterend <= 14 ? 'warning' : 'info'}
                      >
                        {new Date(contract.vervaldatum).toLocaleDateString('nl-BE', { day: '2-digit', month: '2-digit', year: 'numeric' })}
                      </StatusBadge>
                    </td>
                    <td style={{ padding: '8px 0 8px 12px' }}>
                      <div className="flex items-center gap-1">
                        <button
                          className="text-xs font-medium rounded-md transition-colors duration-150"
                          style={{
                            padding: '4px 8px',
                            color: '#3D4550',
                            border: '1px solid #E8EBEE',
                            backgroundColor: 'transparent',
                          }}
                          onMouseEnter={(e) => { e.currentTarget.style.backgroundColor = '#F2F4F6' }}
                          onMouseLeave={(e) => { e.currentTarget.style.backgroundColor = 'transparent' }}
                        >
                          Verlengen
                        </button>
                        <button
                          className="flex items-center justify-center rounded-md text-[#95A1AD] hover:text-[#3D4550] hover:bg-[#F2F4F6] transition-colors duration-150"
                          style={{ width: '28px', height: '28px' }}
                        >
                          <Eye style={{ width: '14px', height: '14px' }} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Open Claims Summary */}
        <div
          className="bg-white rounded-lg"
          style={{
            border: '1px solid #E8EBEE',
            padding: '20px',
          }}
        >
          <div className="flex items-center justify-between mb-4">
            <h3
              className="font-semibold"
              style={{ fontSize: '15px', color: '#1A1F24' }}
            >
              Open Schadeclaims
            </h3>
            <button
              onClick={() => navigate('/schadeclaims')}
              className="text-xs font-medium flex items-center gap-1 transition-colors duration-150"
              style={{ color: '#4A804A' }}
              onMouseEnter={(e) => { e.currentTarget.style.color = '#3A683A' }}
              onMouseLeave={(e) => { e.currentTarget.style.color = '#4A804A' }}
            >
              Bekijk alle
              <ChevronRight style={{ width: '14px', height: '14px' }} />
            </button>
          </div>
          <div className="space-y-2">
            {openClaimsSummary.map((claim) => (
              <div
                key={claim.id}
                className="flex items-center gap-3 rounded-md transition-colors duration-100 hover:bg-[#FAFBFC]"
                style={{
                  padding: '10px 12px',
                  border: '1px solid #F2F4F6',
                }}
              >
                {/* Status bar */}
                <div
                  className="rounded-full shrink-0"
                  style={{
                    width: '4px',
                    height: '36px',
                    backgroundColor: claim.urgent ? '#C04A4A' : '#D4942A',
                  }}
                />
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <span
                      className="font-mono text-xs font-medium"
                      style={{ color: '#3B6EA5' }}
                    >
                      #{claim.claimnummer}
                    </span>
                    <StatusBadge status={statusColorMap[claim.status] || 'neutral'}>
                      {statusLabelMap[claim.status] || claim.status}
                    </StatusBadge>
                  </div>
                  <div
                    className="text-sm truncate"
                    style={{ color: '#1A1F24', marginTop: '2px' }}
                  >
                    {claim.verzekerde}
                  </div>
                  <div className="text-xs" style={{ color: '#6B7785' }}>
                    {claim.type}
                  </div>
                </div>
                <div
                  className="text-xs font-medium shrink-0"
                  style={{ color: claim.dagenOpen > 30 ? '#C04A4A' : '#6B7785' }}
                >
                  {claim.dagenOpen} dagen
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
