import { useState } from 'react'
import {
  LayoutDashboard,
  Euro,
  FileText,
  AlertCircle,
  Users,
  Download,
  FileSpreadsheet,
  FileDigit,
  TrendingUp,
  Calendar,
  Filter,
  Search,
  Settings,
  ChevronDown,
} from 'lucide-react'
import {
  ResponsiveContainer,
  LineChart,
  Line,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  Area,
  AreaChart,
  ComposedChart,
  ReferenceLine,
} from 'recharts'
import KPICard from '@/components/KPICard'
import StatusBadge from '@/components/StatusBadge'

/* ============================================================
   Chart colors
   ============================================================ */
const CHART = {
  1: '#4A804A',
  2: '#3B6EA5',
  3: '#C8A456',
  4: '#8B5E83',
  5: '#C07A4A',
}
const CHART_COLORS = Object.values(CHART)

/* ============================================================
   Mock data
   ============================================================ */

// --- KPI row data (shared) ---
const kpiData = {
  totaalCommissie: { value: '\u20ac 284.560', trend: '+\u20ac 14.230 vs. vorige periode' },
  nieuweContracten: { value: '142', trend: '+23 vs. vorige periode' },
  schadeclaims: { value: '38 open / 127 totaal', trend: '-8% schadecijfer' },
  nps: { value: '72', trend: '+4 vs. vorige periode', subtitle: 'Gebaseerd op 89 reacties' },
}

// --- Monthly commission trend (12 months) ---
const monthlyTrend = [
  { maand: 'Jan', commissie: 18500, contracten: 32, vorigJaar: 16800 },
  { maand: 'Feb', commissie: 21200, contracten: 38, vorigJaar: 19500 },
  { maand: 'Mrt', commissie: 22800, contracten: 41, vorigJaar: 20400 },
  { maand: 'Apr', commissie: 19600, contracten: 28, vorigJaar: 21000 },
  { maand: 'Mei', commissie: 25400, contracten: 45, vorigJaar: 22000 },
  { maand: 'Jun', commissie: 28100, contracten: 52, vorigJaar: 24500 },
  { maand: 'Jul', commissie: 24300, contracten: 39, vorigJaar: 23800 },
  { maand: 'Aug', commissie: 26800, contracten: 44, vorigJaar: 25000 },
  { maand: 'Sep', commissie: 31200, contracten: 48, vorigJaar: 26500 },
  { maand: 'Okt', commissie: 29400, contracten: 42, vorigJaar: 27200 },
  { maand: 'Nov', commissie: 33600, contracten: 55, vorigJaar: 28000 },
  { maand: 'Dec', commissie: 35860, contracten: 58, vorigJaar: 31000 },
]

// --- Loss ratio data ---
const lossRatioData = [
  { maand: 'Jan', ratio: 52, vorigJaar: 58 },
  { maand: 'Feb', ratio: 48, vorigJaar: 55 },
  { maand: 'Mrt', ratio: 61, vorigJaar: 59 },
  { maand: 'Apr', ratio: 55, vorigJaar: 62 },
  { maand: 'Mei', ratio: 58, vorigJaar: 60 },
  { maand: 'Jun', ratio: 63, vorigJaar: 65 },
  { maand: 'Jul', ratio: 67, vorigJaar: 64 },
  { maand: 'Aug', ratio: 59, vorigJaar: 61 },
  { maand: 'Sep', ratio: 54, vorigJaar: 57 },
  { maand: 'Okt', ratio: 50, vorigJaar: 56 },
  { maand: 'Nov', ratio: 46, vorigJaar: 53 },
  { maand: 'Dec', ratio: 44, vorigJaar: 51 },
]

// --- Contracts per insurance line (horizontal bar) ---
const verzekeringslijnen = [
  { naam: 'Auto Omnium', aantal: 892, percentage: 27.5 },
  { naam: 'Auto BA', aantal: 756, percentage: 23.3 },
  { naam: 'Woning', aantal: 534, percentage: 16.4 },
  { naam: 'Brand', aantal: 312, percentage: 9.6 },
  { naam: 'Burgerlijke Aansprakelijkheid', aantal: 287, percentage: 8.8 },
  { naam: 'Rechtsbijstand', aantal: 198, percentage: 6.1 },
  { naam: 'Leven', aantal: 145, percentage: 4.5 },
  { naam: 'Andere', aantal: 123, percentage: 3.8 },
]

// --- Commission per insurer (donut) ---
const commissiePerMaatschappij = [
  { naam: 'Ethias', waarde: 48680, percentage: 22 },
  { naam: 'P&V', waarde: 32850, percentage: 15 },
  { naam: 'AXA Belgium', waarde: 29820, percentage: 13.5 },
  { naam: 'AG Insurance', waarde: 26540, percentage: 12 },
  { naam: 'Baloise', waarde: 22100, percentage: 10 },
  { naam: 'KBC', waarde: 17700, percentage: 8 },
  { naam: 'ING', waarde: 13200, percentage: 6 },
  { naam: 'Overige', waarde: 30470, percentage: 13.5 },
]

// --- Commission detail table ---
const commissieDetails = [
  { id: '1', maatschappij: 'Ethias', lijn: 'Auto Omnium', aantal: 234, premie: 312450, commissiePct: 15, commissieBedrag: 46868 },
  { id: '2', maatschappij: 'P&V', lijn: 'Woning', aantal: 156, premie: 198340, commissiePct: 12, commissieBedrag: 23801 },
  { id: '3', maatschappij: 'AXA Belgium', lijn: 'Auto BA', aantal: 198, premie: 156780, commissiePct: 18, commissieBedrag: 28220 },
  { id: '4', maatschappij: 'AG Insurance', lijn: 'Auto Omnium', aantal: 142, premie: 189340, commissiePct: 14, commissieBedrag: 26508 },
  { id: '5', maatschappij: 'Baloise', lijn: 'Brand', aantal: 98, premie: 124500, commissiePct: 16, commissieBedrag: 19920 },
  { id: '6', maatschappij: 'KBC', lijn: 'Leven', aantal: 87, premie: 245600, commissiePct: 10, commissieBedrag: 24560 },
  { id: '7', maatschappij: 'ING', lijn: 'Woning', aantal: 76, premie: 98700, commissiePct: 13, commissieBedrag: 12831 },
  { id: '8', maatschappij: 'NN', lijn: 'Hospitalisatie', aantal: 112, premie: 156700, commissiePct: 11, commissieBedrag: 17237 },
  { id: '9', maatschappij: 'Allianz', lijn: 'BA', aantal: 89, premie: 67800, commissiePct: 17, commissieBedrag: 11526 },
  { id: '10', maatschappij: 'Foyer', lijn: 'Rechtsbijstand', aantal: 54, premie: 34500, commissiePct: 14, commissieBedrag: 4830 },
]

// --- Contract analytics data ---
const contractEvolutie = [
  { maand: 'Jan', actief: 2840, nieuw: 32, verlengd: 28, geannuleerd: 5 },
  { maand: 'Feb', actief: 2875, nieuw: 38, verlengd: 31, geannuleerd: 3 },
  { maand: 'Mrt', actief: 2910, nieuw: 41, verlengd: 35, geannuleerd: 6 },
  { maand: 'Apr', actief: 2895, nieuw: 28, verlengd: 22, geannuleerd: 8 },
  { maand: 'Mei', actief: 2935, nieuw: 45, verlengd: 38, geannuleerd: 4 },
  { maand: 'Jun', actief: 2985, nieuw: 52, verlengd: 41, geannuleerd: 2 },
  { maand: 'Jul', actief: 2960, nieuw: 39, verlengd: 33, geannuleerd: 7 },
  { maand: 'Aug', actief: 2995, nieuw: 44, verlengd: 36, geannuleerd: 5 },
  { maand: 'Sep', actief: 3040, nieuw: 48, verlengd: 42, geannuleerd: 3 },
  { maand: 'Okt', actief: 3075, nieuw: 42, verlengd: 37, geannuleerd: 4 },
  { maand: 'Nov', actief: 3125, nieuw: 55, verlengd: 48, geannuleerd: 2 },
  { maand: 'Dec', actief: 3178, nieuw: 58, verlengd: 52, geannuleerd: 5 },
]

const contractenDetail = [
  { id: '1', lijn: 'Auto Omnium', actief: 892, nieuw: 45, verlengd: 38, verlopen: 12, geannuleerd: 5, gemPremie: 1180 },
  { id: '2', lijn: 'Auto BA', actief: 756, nieuw: 52, verlengd: 41, verlopen: 18, geannuleerd: 8, gemPremie: 420 },
  { id: '3', lijn: 'Woning', actief: 534, nieuw: 18, verlengd: 22, verlopen: 8, geannuleerd: 3, gemPremie: 920 },
  { id: '4', lijn: 'Brand', actief: 312, nieuw: 12, verlengd: 15, verlopen: 4, geannuleerd: 2, gemPremie: 680 },
  { id: '5', lijn: 'BA', actief: 287, nieuw: 8, verlengd: 10, verlopen: 3, geannuleerd: 1, gemPremie: 340 },
  { id: '6', lijn: 'Rechtsbijstand', actief: 198, nieuw: 6, verlengd: 8, verlopen: 2, geannuleerd: 1, gemPremie: 180 },
  { id: '7', lijn: 'Leven', actief: 145, nieuw: 4, verlengd: 5, verlopen: 1, geannuleerd: 0, gemPremie: 2450 },
]

// --- Schadeclaims analytics ---
const schadesPerMaand = [
  { maand: 'Jan', geopend: 14, afgehandeld: 11 },
  { maand: 'Feb', geopend: 18, afgehandeld: 15 },
  { maand: 'Mrt', geopend: 22, afgehandeld: 18 },
  { maand: 'Apr', geopend: 16, afgehandeld: 14 },
  { maand: 'Mei', geopend: 20, afgehandeld: 17 },
  { maand: 'Jun', geopend: 24, afgehandeld: 20 },
  { maand: 'Jul', geopend: 19, afgehandeld: 16 },
  { maand: 'Aug', geopend: 21, afgehandeld: 18 },
  { maand: 'Sep', geopend: 15, afgehandeld: 13 },
  { maand: 'Okt', geopend: 12, afgehandeld: 10 },
  { maand: 'Nov', geopend: 17, afgehandeld: 14 },
  { maand: 'Dec', geopend: 13, afgehandeld: 11 },
]

const schadePerCategorie = [
  { naam: 'Auto (aanrijding)', aantal: 234, bedrag: 892450 },
  { naam: 'Brand', aantal: 45, bedrag: 1234800 },
  { naam: 'Water/lekkage', aantal: 67, bedrag: 456200 },
  { naam: 'Inbraak/diefstal', aantal: 38, bedrag: 234500 },
  { naam: 'Storm/natuur', aantal: 29, bedrag: 567800 },
  { naam: 'Glasschade', aantal: 52, bedrag: 156400 },
  { naam: 'Overig', aantal: 23, bedrag: 128600 },
]

const schadesDetail = [
  { id: '1', type: 'Auto (aanrijding)', aantal: 234, totaal: 892450, gem: 3814, afhandeltijd: 16, afgehandeldPct: 94 },
  { id: '2', type: 'Brand', aantal: 45, totaal: 1234800, gem: 27440, afhandeltijd: 28, afgehandeldPct: 88 },
  { id: '3', type: 'Water/lekkage', aantal: 67, totaal: 456200, gem: 6809, afhandeltijd: 21, afgehandeldPct: 91 },
  { id: '4', type: 'Inbraak/diefstal', aantal: 38, totaal: 234500, gem: 6171, afhandeltijd: 19, afgehandeldPct: 93 },
  { id: '5', type: 'Storm/natuur', aantal: 29, totaal: 567800, gem: 19579, afhandeltijd: 25, afgehandeldPct: 86 },
  { id: '6', type: 'Glasschade', aantal: 52, totaal: 156400, gem: 3008, afhandeltijd: 8, afgehandeldPct: 97 },
]

// --- Klanten analytics ---
const klantenGroei = [
  { maand: 'Jan', nieuw: 24, totaal: 1850 },
  { maand: 'Feb', nieuw: 28, totaal: 1878 },
  { maand: 'Mrt', nieuw: 32, totaal: 1910 },
  { maand: 'Apr', nieuw: 22, totaal: 1932 },
  { maand: 'Mei', nieuw: 35, totaal: 1967 },
  { maand: 'Jun', nieuw: 38, totaal: 2005 },
  { maand: 'Jul', nieuw: 30, totaal: 2035 },
  { maand: 'Aug', nieuw: 34, totaal: 2069 },
  { maand: 'Sep', nieuw: 41, totaal: 2110 },
  { maand: 'Okt', nieuw: 29, totaal: 2139 },
  { maand: 'Nov', nieuw: 45, totaal: 2184 },
  { maand: 'Dec', nieuw: 38, totaal: 2222 },
]

const leeftijdsverdeling = [
  { groep: '<25', aantal: 145 },
  { groep: '25-34', aantal: 312 },
  { groep: '35-44', aantal: 498 },
  { groep: '45-54', aantal: 534 },
  { groep: '55-64', aantal: 423 },
  { groep: '65+', aantal: 310 },
]

const klantenPerStad = [
  { id: '1', stad: 'Mechelen', klanten: 234, contracten: 412, gemContracten: 1.76, omzet: 89340 },
  { id: '2', stad: 'Brussel', klanten: 198, contracten: 356, gemContracten: 1.80, omzet: 76890 },
  { id: '3', stad: 'Gent', klanten: 156, contracten: 278, gemContracten: 1.78, omzet: 60120 },
  { id: '4', stad: 'Leuven', klanten: 134, contracten: 241, gemContracten: 1.80, omzet: 52450 },
  { id: '5', stad: 'Antwerpen', klanten: 128, contracten: 234, gemContracten: 1.83, omzet: 51200 },
  { id: '6', stad: 'Hasselt', klanten: 98, contracten: 172, gemContracten: 1.76, omzet: 37890 },
  { id: '7', stad: 'Brugge', klanten: 87, contracten: 156, gemContracten: 1.79, omzet: 34560 },
  { id: '8', stad: 'Dilbeek', klanten: 76, contracten: 132, gemContracten: 1.74, omzet: 28900 },
]

const contractenPerKlant = [
  { aantal: '1 contract', klanten: 890 },
  { aantal: '2 contracten', klanten: 756 },
  { aantal: '3-5 contracten', klanten: 432 },
  { aantal: '6-10 contracten', klanten: 98 },
  { aantal: '10+ contracten', klanten: 46 },
]

// --- Saved reports (export tab) ---
const savedReports = [
  { id: '1', naam: 'Maandcommissie Q4', type: 'Excel', gemaaktDoor: 'Admin', laatstUitgevoerd: '01/12/2024' },
  { id: '2', naam: 'Schadeoverzicht 2024', type: 'PDF', gemaaktDoor: 'Marie Dubois', laatstUitgevoerd: '15/11/2024' },
  { id: '3', naam: 'Klantenbestand export', type: 'CSV', gemaaktDoor: 'Admin', laatstUitgevoerd: '01/10/2024' },
  { id: '4', naam: 'Contracten per maatschappij', type: 'Excel', gemaaktDoor: 'Pieter Janssens', laatstUitgevoerd: '20/11/2024' },
]

/* ============================================================
   Tab definitions
   ============================================================ */
const tabs = [
  { key: 'overzicht', label: 'Overzicht', icon: LayoutDashboard },
  { key: 'commissies', label: 'Commissies', icon: Euro },
  { key: 'contracten', label: 'Contracten', icon: FileText },
  { key: 'schades', label: 'Schades', icon: AlertCircle },
  { key: 'klanten', label: 'Klanten', icon: Users },
  { key: 'exporteren', label: 'Exporteren', icon: Download },
]

const dateRanges = [
  'Laatste 30 dagen',
  'Deze maand',
  'Laatste 90 dagen',
  'Dit jaar',
  'Vorig jaar',
  'Aangepast...',
]

/* ============================================================
   Utility formatters
   ============================================================ */
const fmtEUR = (n: number) =>
  '\u20ac ' + n.toLocaleString('nl-BE', { minimumFractionDigits: 0, maximumFractionDigits: 0 })

/* ============================================================
   Custom Recharts Tooltip
   ============================================================ */
function CustomTooltip({ active, payload, label }: { active?: boolean; payload?: Array<{ name: string; value: number; color: string }>; label?: string }) {
  if (!active || !payload || !payload.length) return null
  return (
    <div className="bg-white rounded-lg shadow-lg" style={{ padding: '12px 16px', border: '1px solid #E8EBEE' }}>
      <p className="font-semibold text-xs mb-2" style={{ color: '#1A1F24' }}>{label}</p>
      {payload.map((p, i) => (
        <div key={i} className="flex items-center gap-2 text-xs" style={{ color: '#3D4550', lineHeight: 1.8 }}>
          <span className="inline-block rounded-full" style={{ width: 8, height: 8, backgroundColor: p.color }} />
          <span>{p.name}:</span>
          <span className="font-medium">{p.value.toLocaleString('nl-BE')}</span>
        </div>
      ))}
    </div>
  )
}

/* ============================================================
   Sub-components
   ============================================================ */

function ChartCard({ title, children, action }: { title: string; children: React.ReactNode; action?: React.ReactNode }) {
  return (
    <div className="bg-white rounded-lg" style={{ border: '1px solid #E8EBEE', padding: '20px' }}>
      <div className="flex items-center justify-between mb-4">
        <h3 className="font-semibold" style={{ fontSize: '15px', color: '#1A1F24' }}>{title}</h3>
        {action}
      </div>
      {children}
    </div>
  )
}

function MiniStat({ label, value, suffix }: { label: string; value: string; suffix?: string }) {
  return (
    <div className="flex-1 text-center" style={{ padding: '16px 12px' }}>
      <div className="font-bold" style={{ fontSize: '22px', color: '#1A1F24' }}>{value}</div>
      <div className="text-xs mt-1" style={{ color: '#6B7785' }}>{label}</div>
      {suffix && <div className="text-xs" style={{ color: '#95A1AD' }}>{suffix}</div>}
    </div>
  )
}

/* ============================================================
   Overzicht Tab
   ============================================================ */
function OverzichtTab() {
  return (
    <div className="space-y-5">
      {/* Row 1: Commission trend + Loss ratio */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        <ChartCard title="Commissie & Contracten Trend">
          <ResponsiveContainer width="100%" height={280}>
            <ComposedChart data={monthlyTrend}>
              <CartesianGrid strokeDasharray="3 3" stroke="#E8EBEE" />
              <XAxis dataKey="maand" tick={{ fontSize: 12, fill: '#6B7785' }} />
              <YAxis yAxisId="left" tick={{ fontSize: 12, fill: '#6B7785' }} tickFormatter={(v) => `\u20ac${(v / 1000).toFixed(0)}k`} />
              <YAxis yAxisId="right" orientation="right" tick={{ fontSize: 12, fill: '#6B7785' }} />
              <Tooltip content={<CustomTooltip />} />
              <Legend wrapperStyle={{ fontSize: 12 }} />
              <Bar yAxisId="right" dataKey="contracten" name="Contracten" fill={CHART[2]} radius={[4, 4, 0, 0]} />
              <Line yAxisId="left" type="monotone" dataKey="commissie" name="Commissie (\u20ac)" stroke={CHART[1]} strokeWidth={2.5} dot={{ r: 3, fill: CHART[1] }} />
            </ComposedChart>
          </ResponsiveContainer>
        </ChartCard>

        <ChartCard title="Schade/Loss Ratio">
          <ResponsiveContainer width="100%" height={280}>
            <AreaChart data={lossRatioData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#E8EBEE" />
              <XAxis dataKey="maand" tick={{ fontSize: 12, fill: '#6B7785' }} />
              <YAxis tick={{ fontSize: 12, fill: '#6B7785' }} domain={[0, 100]} tickFormatter={(v) => `${v}%`} />
              <Tooltip content={<CustomTooltip />} />
              <Legend wrapperStyle={{ fontSize: 12 }} />
              <ReferenceLine y={60} stroke="#D4942A" strokeDasharray="5 5" label={{ value: '60%', position: 'right', fontSize: 11, fill: '#D4942A' }} />
              <ReferenceLine y={75} stroke="#C04A4A" strokeDasharray="5 5" label={{ value: '75%', position: 'right', fontSize: 11, fill: '#C04A4A' }} />
              <defs>
                <linearGradient id="ratioGrad" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor={CHART[1]} stopOpacity={0.3} />
                  <stop offset="100%" stopColor={CHART[1]} stopOpacity={0.05} />
                </linearGradient>
              </defs>
              <Area type="monotone" dataKey="ratio" name="Loss Ratio" stroke={CHART[1]} fill="url(#ratioGrad)" strokeWidth={2} />
              <Line type="monotone" dataKey="vorigJaar" name="Vorig jaar" stroke={CHART[5]} strokeWidth={2} strokeDasharray="6 4" dot={false} />
            </AreaChart>
          </ResponsiveContainer>
        </ChartCard>
      </div>

      {/* Row 2: Contracts by line + Top insurers */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        <ChartCard title="Contracten per Verzekeringslijn">
          <ResponsiveContainer width="100%" height={280}>
            <BarChart data={verzekeringslijnen} layout="vertical">
              <CartesianGrid strokeDasharray="3 3" stroke="#E8EBEE" horizontal={false} />
              <XAxis type="number" tick={{ fontSize: 12, fill: '#6B7785' }} />
              <YAxis dataKey="naam" type="category" tick={{ fontSize: 11, fill: '#3D4550' }} width={140} />
              <Tooltip content={<CustomTooltip />} />
              <Bar dataKey="aantal" name="Aantal contracten" fill={CHART[1]} radius={[0, 4, 4, 0]} barSize={20} />
            </BarChart>
          </ResponsiveContainer>
        </ChartCard>

        <ChartCard title="Commissie per Verzekeraar">
          <div className="flex items-center justify-center" style={{ height: 280 }}>
            <ResponsiveContainer width="100%" height={260}>
              <PieChart>
                <Pie
                  data={commissiePerMaatschappij}
                  cx="50%"
                  cy="50%"
                  innerRadius={70}
                  outerRadius={100}
                  paddingAngle={2}
                  dataKey="waarde"
                  nameKey="naam"
                >
                  {commissiePerMaatschappij.map((_, i) => (
                    <Cell key={i} fill={CHART_COLORS[i % CHART_COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip formatter={(value: number) => fmtEUR(value)} />
                <Legend wrapperStyle={{ fontSize: 11 }} />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </ChartCard>
      </div>

      {/* Key metrics row */}
      <div className="bg-white rounded-lg" style={{ border: '1px solid #E8EBEE' }}>
        <div className="flex items-center" style={{ padding: '0 16px', borderBottom: '1px solid #E8EBEE' }}>
          <h3 className="font-semibold" style={{ fontSize: '15px', color: '#1A1F24', padding: '12px 0' }}>Belangrijkste Metrics</h3>
        </div>
        <div className="flex flex-wrap">
          <MiniStat label="Retentiepercentage" value="94.2%" />
          <div style={{ width: 1, backgroundColor: '#E8EBEE' }} />
          <MiniStat label="Gem. Premie" value={fmtEUR(2840)} />
          <div style={{ width: 1, backgroundColor: '#E8EBEE' }} />
          <MiniStat label="Schadecijfer" value="62%" />
          <div style={{ width: 1, backgroundColor: '#E8EBEE' }} />
          <MiniStat label="NPS Score" value="72" suffix="/ 100" />
          <div style={{ width: 1, backgroundColor: '#E8EBEE' }} />
          <MiniStat label="Commissie %" value="12.5%" />
        </div>
      </div>
    </div>
  )
}

/* ============================================================
   Commissies Tab
   ============================================================ */
function CommissiesTab() {
  const [filterMaatschappij, setFilterMaatschappij] = useState('')
  const filtered = commissieDetails.filter(c =>
    !filterMaatschappij || c.maatschappij.toLowerCase().includes(filterMaatschappij.toLowerCase())
  )
  const totaalPremie = filtered.reduce((s, c) => s + c.premie, 0)
  const totaalCommissie = filtered.reduce((s, c) => s + c.commissieBedrag, 0)

  return (
    <div className="space-y-5">
      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        <ChartCard title="Commissie per Maand">
          <ResponsiveContainer width="100%" height={280}>
            <LineChart data={monthlyTrend}>
              <CartesianGrid strokeDasharray="3 3" stroke="#E8EBEE" />
              <XAxis dataKey="maand" tick={{ fontSize: 12, fill: '#6B7785' }} />
              <YAxis tick={{ fontSize: 12, fill: '#6B7785' }} tickFormatter={(v) => `\u20ac${(v / 1000).toFixed(0)}k`} />
              <Tooltip content={<CustomTooltip />} />
              <Legend wrapperStyle={{ fontSize: 12 }} />
              <Line type="monotone" dataKey="commissie" name="Commissie huidig" stroke={CHART[1]} strokeWidth={2.5} dot={{ r: 3 }} />
              <Line type="monotone" dataKey="vorigJaar" name="Commissie vorig jaar" stroke={CHART[5]} strokeWidth={2} strokeDasharray="6 4" dot={false} />
            </LineChart>
          </ResponsiveContainer>
        </ChartCard>

        <ChartCard title="Commissie per Verzekeraar">
          <div className="flex items-center justify-center" style={{ height: 280 }}>
            <ResponsiveContainer width="100%" height={260}>
              <PieChart>
                <Pie data={commissiePerMaatschappij} cx="50%" cy="50%" innerRadius={65} outerRadius={95} paddingAngle={2} dataKey="waarde" nameKey="naam">
                  {commissiePerMaatschappij.map((_, i) => (
                    <Cell key={i} fill={CHART_COLORS[i % CHART_COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip formatter={(value: number) => fmtEUR(value)} />
                <Legend wrapperStyle={{ fontSize: 11 }} />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </ChartCard>
      </div>

      {/* Commission detail table */}
      <div className="bg-white rounded-lg" style={{ border: '1px solid #E8EBEE' }}>
        <div className="flex items-center justify-between" style={{ padding: '14px 20px', borderBottom: '1px solid #E8EBEE' }}>
          <h3 className="font-semibold" style={{ fontSize: '15px', color: '#1A1F24' }}>Commissie Detail</h3>
          <div className="flex items-center gap-3">
            <div className="relative">
              <Search className="absolute left-2.5 top-1/2 -translate-y-1/2 text-[#95A1AD]" style={{ width: 14, height: 14 }} />
              <input
                type="text"
                placeholder="Filter op maatschappij..."
                value={filterMaatschappij}
                onChange={(e) => setFilterMaatschappij(e.target.value)}
                className="rounded-md border border-[#D1D6DB] text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15"
                style={{ height: '34px', padding: '0 10px 0 30px', fontSize: 12, color: '#1A1F24', minWidth: 200 }}
              />
            </div>
            <button className="flex items-center gap-1.5 rounded-md text-[#3D4550] hover:bg-[#F2F4F6] transition-colors" style={{ height: '34px', padding: '0 12px', fontSize: 12, fontWeight: 500, border: '1px solid #D1D6DB' }}>
              <FileSpreadsheet style={{ width: 14, height: 14 }} />
              Excel
            </button>
            <button className="flex items-center gap-1.5 rounded-md text-[#3D4550] hover:bg-[#F2F4F6] transition-colors" style={{ height: '34px', padding: '0 12px', fontSize: 12, fontWeight: 500, border: '1px solid #D1D6DB' }}>
              <FileDigit style={{ width: 14, height: 14 }} />
              CSV
            </button>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full border-collapse">
            <thead>
              <tr style={{ backgroundColor: '#F2F4F6', height: 44 }}>
                {['Verzekeraar', 'Verzekeringslijn', 'Aantal', 'Bruto Premie', 'Commissie %', 'Commissie Bedrag'].map(h => (
                  <th key={h} className="text-left font-semibold" style={{ padding: '0 16px', fontSize: 13, color: '#3D4550' }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.map((row, idx) => (
                <tr key={row.id} style={{ height: 48, backgroundColor: idx % 2 === 1 ? '#FAFBFC' : '#FFFFFF', borderBottom: '1px solid #E8EBEE' }}>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#1A1F24' }}>{row.maatschappij}</td>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#3D4550' }}>{row.lijn}</td>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#1A1F24' }}>{row.aantal}</td>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#1A1F24', fontWeight: 500 }}>{fmtEUR(row.premie)}</td>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#3D4550' }}>{row.commissiePct}%</td>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#4A804A', fontWeight: 600 }}>{fmtEUR(row.commissieBedrag)}</td>
                </tr>
              ))}
            </tbody>
            <tfoot>
              <tr style={{ backgroundColor: '#F4FAF4', height: 48, borderTop: '2px solid #E8F5E8' }}>
                <td colSpan={3} className="font-semibold text-right" style={{ padding: '10px 16px', fontSize: 14, color: '#3A683A' }}>Totaal</td>
                <td className="font-bold" style={{ padding: '10px 16px', fontSize: 14, color: '#3A683A' }}>{fmtEUR(totaalPremie)}</td>
                <td style={{ padding: '10px 16px', fontSize: 14, color: '#3A683A' }}>{totaalPremie > 0 ? (totaalCommissie / totaalPremie * 100).toFixed(1) : '0.0'}%</td>
                <td className="font-bold" style={{ padding: '10px 16px', fontSize: 14, color: '#3A683A' }}>{fmtEUR(totaalCommissie)}</td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </div>
  )
}

/* ============================================================
   Contracten Analytics Tab
   ============================================================ */
function ContractenTab() {
  return (
    <div className="space-y-5">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        <ChartCard title="Contractevolutie (cumulatief)">
          <ResponsiveContainer width="100%" height={280}>
            <AreaChart data={contractEvolutie}>
              <CartesianGrid strokeDasharray="3 3" stroke="#E8EBEE" />
              <XAxis dataKey="maand" tick={{ fontSize: 12, fill: '#6B7785' }} />
              <YAxis tick={{ fontSize: 12, fill: '#6B7785' }} />
              <Tooltip content={<CustomTooltip />} />
              <Legend wrapperStyle={{ fontSize: 12 }} />
              <defs>
                <linearGradient id="activeGrad" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor={CHART[1]} stopOpacity={0.3} />
                  <stop offset="100%" stopColor={CHART[1]} stopOpacity={0.05} />
                </linearGradient>
              </defs>
              <Area type="monotone" dataKey="actief" name="Actieve contracten" stroke={CHART[1]} fill="url(#activeGrad)" strokeWidth={2} />
              <Line type="monotone" dataKey="nieuw" name="Nieuw" stroke={CHART[2]} strokeWidth={2} dot={{ r: 3 }} />
            </AreaChart>
          </ResponsiveContainer>
        </ChartCard>

        <ChartCard title="Verlengingen vs. Churn">
          <ResponsiveContainer width="100%" height={280}>
            <BarChart data={contractEvolutie}>
              <CartesianGrid strokeDasharray="3 3" stroke="#E8EBEE" />
              <XAxis dataKey="maand" tick={{ fontSize: 12, fill: '#6B7785' }} />
              <YAxis tick={{ fontSize: 12, fill: '#6B7785' }} />
              <Tooltip content={<CustomTooltip />} />
              <Legend wrapperStyle={{ fontSize: 12 }} />
              <Bar dataKey="nieuw" name="Nieuw" fill={CHART[2]} radius={[4, 4, 0, 0]} />
              <Bar dataKey="verlengd" name="Verlengd" fill={CHART[1]} radius={[4, 4, 0, 0]} />
              <Bar dataKey="geannuleerd" name="Geannuleerd" fill={'#C04A4A'} radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </ChartCard>
      </div>

      <ChartCard title="Contracten per Verzekeringslijn (detail)">
        <div className="overflow-x-auto">
          <table className="w-full border-collapse">
            <thead>
              <tr style={{ backgroundColor: '#F2F4F6', height: 44 }}>
                {['Verzekeringslijn', 'Actief', 'Nieuw', 'Verlengd', 'Verlopen', 'Geannuleerd', 'Gem. Premie'].map(h => (
                  <th key={h} className="text-left font-semibold" style={{ padding: '0 16px', fontSize: 13, color: '#3D4550' }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {contractenDetail.map((row, idx) => (
                <tr key={row.id} style={{ height: 48, backgroundColor: idx % 2 === 1 ? '#FAFBFC' : '#FFFFFF', borderBottom: '1px solid #E8EBEE' }}>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#1A1F24', fontWeight: 500 }}>{row.lijn}</td>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#1A1F24' }}>{row.actief}</td>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#3B6EA5' }}>{row.nieuw}</td>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#4A804A' }}>{row.verlengd}</td>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#D4942A' }}>{row.verlopen}</td>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#C04A4A' }}>{row.geannuleerd}</td>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#1A1F24', fontWeight: 500 }}>{fmtEUR(row.gemPremie)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </ChartCard>
    </div>
  )
}

/* ============================================================
   Schades Analytics Tab
   ============================================================ */
function SchadesTab() {
  const totaalSchade = schadePerCategorie.reduce((s, c) => s + c.bedrag, 0)
  const totaalAantal = schadePerCategorie.reduce((s, c) => s + c.aantal, 0)

  return (
    <div className="space-y-5">
      {/* Summary stats */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="bg-white rounded-lg" style={{ border: '1px solid #E8EBEE', padding: '16px 20px' }}>
          <div className="text-xs mb-1" style={{ color: '#6B7785' }}>Totaal schadebedrag</div>
          <div className="font-bold" style={{ fontSize: '20px', color: '#1A1F24' }}>{fmtEUR(totaalSchade)}</div>
        </div>
        <div className="bg-white rounded-lg" style={{ border: '1px solid #E8EBEE', padding: '16px 20px' }}>
          <div className="text-xs mb-1" style={{ color: '#6B7785' }}>Aantal schadegevallen</div>
          <div className="font-bold" style={{ fontSize: '20px', color: '#1A1F24' }}>{totaalAantal}</div>
        </div>
        <div className="bg-white rounded-lg" style={{ border: '1px solid #E8EBEE', padding: '16px 20px' }}>
          <div className="text-xs mb-1" style={{ color: '#6B7785' }}>Gem. schadebedrag</div>
          <div className="font-bold" style={{ fontSize: '20px', color: '#1A1F24' }}>{fmtEUR(Math.round(totaalSchade / totaalAantal))}</div>
        </div>
        <div className="bg-white rounded-lg" style={{ border: '1px solid #E8EBEE', padding: '16px 20px' }}>
          <div className="text-xs mb-1" style={{ color: '#6B7785' }}>Gem. afhandeltijd</div>
          <div className="font-bold" style={{ fontSize: '20px', color: '#1A1F24' }}>17 dagen</div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        <ChartCard title="Schades per Maand">
          <ResponsiveContainer width="100%" height={280}>
            <LineChart data={schadesPerMaand}>
              <CartesianGrid strokeDasharray="3 3" stroke="#E8EBEE" />
              <XAxis dataKey="maand" tick={{ fontSize: 12, fill: '#6B7785' }} />
              <YAxis tick={{ fontSize: 12, fill: '#6B7785' }} />
              <Tooltip content={<CustomTooltip />} />
              <Legend wrapperStyle={{ fontSize: 12 }} />
              <Line type="monotone" dataKey="geopend" name="Geopend" stroke={CHART[5]} strokeWidth={2.5} dot={{ r: 3 }} />
              <Line type="monotone" dataKey="afgehandeld" name="Afgehandeld" stroke={CHART[1]} strokeWidth={2} strokeDasharray="6 4" dot={{ r: 3 }} />
            </LineChart>
          </ResponsiveContainer>
        </ChartCard>

        <ChartCard title="Schade per Categorie">
          <div className="flex items-center justify-center" style={{ height: 280 }}>
            <ResponsiveContainer width="100%" height={260}>
              <PieChart>
                <Pie data={schadePerCategorie} cx="50%" cy="50%" innerRadius={60} outerRadius={95} paddingAngle={2} dataKey="aantal" nameKey="naam">
                  {schadePerCategorie.map((_, i) => (
                    <Cell key={i} fill={CHART_COLORS[i % CHART_COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip content={<CustomTooltip />} />
                <Legend wrapperStyle={{ fontSize: 11 }} />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </ChartCard>
      </div>

      <ChartCard title="Schade Detail per Categorie">
        <div className="overflow-x-auto">
          <table className="w-full border-collapse">
            <thead>
              <tr style={{ backgroundColor: '#F2F4F6', height: 44 }}>
                {['Type Schade', 'Aantal', 'Totaal Bedrag', 'Gem. Bedrag', 'Gem. Afhandeltijd', 'Afgehandeld %'].map(h => (
                  <th key={h} className="text-left font-semibold" style={{ padding: '0 16px', fontSize: 13, color: '#3D4550' }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {schadesDetail.map((row, idx) => (
                <tr key={row.id} style={{ height: 48, backgroundColor: idx % 2 === 1 ? '#FAFBFC' : '#FFFFFF', borderBottom: '1px solid #E8EBEE' }}>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#1A1F24', fontWeight: 500 }}>{row.type}</td>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#1A1F24' }}>{row.aantal}</td>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#1A1F24', fontWeight: 500 }}>{fmtEUR(row.totaal)}</td>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#3D4550' }}>{fmtEUR(row.gem)}</td>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#3D4550' }}>{row.afhandeltijd} dagen</td>
                  <td style={{ padding: '10px 16px' }}>
                    <div className="flex items-center gap-2">
                      <div className="rounded-full overflow-hidden" style={{ width: 60, height: 8, backgroundColor: '#E8EBEE' }}>
                        <div style={{ width: `${row.afgehandeldPct}%`, height: '100%', backgroundColor: CHART[1], borderRadius: 9999 }} />
                      </div>
                      <span className="text-xs font-medium" style={{ color: '#3D4550' }}>{row.afgehandeldPct}%</span>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </ChartCard>
    </div>
  )
}

/* ============================================================
   Klanten Analytics Tab
   ============================================================ */
function KlantenTab() {
  return (
    <div className="space-y-5">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        <ChartCard title="Klanten per Maand">
          <ResponsiveContainer width="100%" height={280}>
            <AreaChart data={klantenGroei}>
              <CartesianGrid strokeDasharray="3 3" stroke="#E8EBEE" />
              <XAxis dataKey="maand" tick={{ fontSize: 12, fill: '#6B7785' }} />
              <YAxis tick={{ fontSize: 12, fill: '#6B7785' }} />
              <Tooltip content={<CustomTooltip />} />
              <Legend wrapperStyle={{ fontSize: 12 }} />
              <defs>
                <linearGradient id="klantGrad" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor={CHART[1]} stopOpacity={0.3} />
                  <stop offset="100%" stopColor={CHART[1]} stopOpacity={0.05} />
                </linearGradient>
              </defs>
              <Area type="monotone" dataKey="nieuw" name="Nieuwe klanten" stroke={CHART[1]} fill="url(#klantGrad)" strokeWidth={2} />
              <Line type="monotone" dataKey="totaal" name="Totaal klanten" stroke={CHART[2]} strokeWidth={2} dot={{ r: 3 }} />
            </AreaChart>
          </ResponsiveContainer>
        </ChartCard>

        <ChartCard title="Leeftijdsverdeling">
          <ResponsiveContainer width="100%" height={280}>
            <BarChart data={leeftijdsverdeling}>
              <CartesianGrid strokeDasharray="3 3" stroke="#E8EBEE" />
              <XAxis dataKey="groep" tick={{ fontSize: 12, fill: '#6B7785' }} />
              <YAxis tick={{ fontSize: 12, fill: '#6B7785' }} />
              <Tooltip content={<CustomTooltip />} />
              <Bar dataKey="aantal" name="Aantal klanten" fill={CHART[1]} radius={[4, 4, 0, 0]} barSize={36} />
            </BarChart>
          </ResponsiveContainer>
        </ChartCard>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        <ChartCard title="Contracten per Klant">
          <ResponsiveContainer width="100%" height={280}>
            <BarChart data={contractenPerKlant}>
              <CartesianGrid strokeDasharray="3 3" stroke="#E8EBEE" />
              <XAxis dataKey="aantal" tick={{ fontSize: 11, fill: '#6B7785' }} />
              <YAxis tick={{ fontSize: 12, fill: '#6B7785' }} />
              <Tooltip content={<CustomTooltip />} />
              <Bar dataKey="klanten" name="Aantal klanten" fill={CHART[3]} radius={[4, 4, 0, 0]} barSize={40} />
            </BarChart>
          </ResponsiveContainer>
        </ChartCard>

        <ChartCard title="Klanten per Stad (Top 8)">
          <ResponsiveContainer width="100%" height={280}>
            <BarChart data={klantenPerStad} layout="vertical">
              <CartesianGrid strokeDasharray="3 3" stroke="#E8EBEE" horizontal={false} />
              <XAxis type="number" tick={{ fontSize: 12, fill: '#6B7785' }} />
              <YAxis dataKey="stad" type="category" tick={{ fontSize: 12, fill: '#3D4550' }} width={90} />
              <Tooltip content={<CustomTooltip />} />
              <Bar dataKey="klanten" name="Klanten" fill={CHART[1]} radius={[0, 4, 4, 0]} barSize={18} />
              <Bar dataKey="contracten" name="Contracten" fill={CHART[2]} radius={[0, 4, 4, 0]} barSize={18} />
            </BarChart>
          </ResponsiveContainer>
        </ChartCard>
      </div>

      <ChartCard title="Klanten per Stad (detail)">
        <div className="overflow-x-auto">
          <table className="w-full border-collapse">
            <thead>
              <tr style={{ backgroundColor: '#F2F4F6', height: 44 }}>
                {['Stad', 'Klanten', 'Contracten', 'Gem. Contracten', 'Omzet'].map(h => (
                  <th key={h} className="text-left font-semibold" style={{ padding: '0 16px', fontSize: 13, color: '#3D4550' }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {klantenPerStad.map((row, idx) => (
                <tr key={row.id} style={{ height: 48, backgroundColor: idx % 2 === 1 ? '#FAFBFC' : '#FFFFFF', borderBottom: '1px solid #E8EBEE' }}>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#1A1F24', fontWeight: 500 }}>{row.stad}</td>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#1A1F24' }}>{row.klanten}</td>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#3B6EA5' }}>{row.contracten}</td>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#3D4550' }}>{row.gemContracten}</td>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#4A804A', fontWeight: 500 }}>{fmtEUR(row.omzet)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </ChartCard>
    </div>
  )
}

/* ============================================================
   Exporteren Tab
   ============================================================ */
function ExporterenTab() {
  const [reportName, setReportName] = useState('')
  const [format, setFormat] = useState('pdf')
  const [reportType, setReportType] = useState('commissies')
  const [domains, setDomains] = useState({ contracten: true, schades: false, personen: false, commissies: true, objecten: false })
  const [dateFrom, setDateFrom] = useState('2024-01-01')
  const [dateTo, setDateTo] = useState('2024-12-31')

  const toggleDomain = (key: string) => {
    setDomains(prev => ({ ...prev, [key]: !prev[key as keyof typeof domains] }))
  }

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
        {/* Left panel - configuration */}
        <div className="bg-white rounded-lg" style={{ border: '1px solid #E8EBEE', padding: '20px' }}>
          <h3 className="font-semibold mb-4" style={{ fontSize: '15px', color: '#1A1F24' }}>Rapport Configuratie</h3>

          <div className="space-y-4">
            <div>
              <label className="block text-xs font-semibold mb-1.5" style={{ color: '#3D4550' }}>Rapportnaam</label>
              <input
                type="text"
                placeholder="Mijn rapport..."
                value={reportName}
                onChange={(e) => setReportName(e.target.value)}
                className="w-full rounded-md border border-[#D1D6DB] text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15"
                style={{ height: '40px', padding: '0 12px', color: '#1A1F24' }}
              />
            </div>

            <div>
              <label className="block text-xs font-semibold mb-1.5" style={{ color: '#3D4550' }}>Rapporttype</label>
              <select
                value={reportType}
                onChange={(e) => setReportType(e.target.value)}
                className="w-full rounded-md border border-[#D1D6DB] text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15"
                style={{ height: '40px', padding: '0 12px', color: '#1A1F24', backgroundColor: '#fff' }}
              >
                <option value="commissies">Commissierapport</option>
                <option value="contracten">Contractoverzicht</option>
                <option value="schades">Schadeoverzicht</option>
                <option value="klanten">Klantenrapport</option>
                <option value="compleet">Compleet overzicht</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-semibold mb-1.5" style={{ color: '#3D4550' }}>Data-domeinen</label>
              <div className="space-y-2">
                {Object.entries(domains).map(([key, checked]) => (
                  <label key={key} className="flex items-center gap-2 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={checked}
                      onChange={() => toggleDomain(key)}
                      className="rounded border-[#D1D6DB] text-[#4A804A] focus:ring-[#4A804A]"
                    />
                    <span className="text-sm capitalize" style={{ color: '#3D4550' }}>
                      {key === 'contracten' ? 'Contracten' : key === 'schades' ? 'Schades' : key === 'personen' ? 'Personen' : key === 'commissies' ? 'Commissies' : 'Objecten'}
                    </span>
                  </label>
                ))}
              </div>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-semibold mb-1.5" style={{ color: '#3D4550' }}>Van</label>
                <input
                  type="date"
                  value={dateFrom}
                  onChange={(e) => setDateFrom(e.target.value)}
                  className="w-full rounded-md border border-[#D1D6DB] text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15"
                  style={{ height: '40px', padding: '0 12px', color: '#1A1F24' }}
                />
              </div>
              <div>
                <label className="block text-xs font-semibold mb-1.5" style={{ color: '#3D4550' }}>Tot</label>
                <input
                  type="date"
                  value={dateTo}
                  onChange={(e) => setDateTo(e.target.value)}
                  className="w-full rounded-md border border-[#D1D6DB] text-sm outline-none focus:border-[#4A804A] focus:ring-2 focus:ring-[#4A804A]/15"
                  style={{ height: '40px', padding: '0 12px', color: '#1A1F24' }}
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold mb-1.5" style={{ color: '#3D4550' }}>Formaat</label>
              <div className="flex gap-2">
                {[
                  { key: 'pdf', label: 'PDF', icon: FileText },
                  { key: 'excel', label: 'Excel', icon: FileSpreadsheet },
                  { key: 'csv', label: 'CSV', icon: FileDigit },
                ].map(({ key, label, icon: Icon }) => (
                  <button
                    key={key}
                    onClick={() => setFormat(key)}
                    className="flex-1 flex items-center justify-center gap-1.5 rounded-md transition-colors"
                    style={{
                      height: '36px',
                      fontSize: 12,
                      fontWeight: 500,
                      border: format === key ? '1px solid #4A804A' : '1px solid #D1D6DB',
                      backgroundColor: format === key ? '#F4FAF4' : '#FFFFFF',
                      color: format === key ? '#4A804A' : '#3D4550',
                    }}
                  >
                    <Icon style={{ width: 14, height: 14 }} />
                    {label}
                  </button>
                ))}
              </div>
            </div>

            <button
              className="w-full flex items-center justify-center gap-2 rounded-md text-white font-medium transition-all hover:shadow-md"
              style={{ height: '44px', backgroundColor: '#4A804A', fontSize: 14 }}
            >
              <Download style={{ width: 16, height: 16 }} />
              Rapport Genereren
            </button>
          </div>
        </div>

        {/* Right panel - preview */}
        <div className="lg:col-span-2 bg-white rounded-lg" style={{ border: '1px solid #E8EBEE', padding: '20px' }}>
          <h3 className="font-semibold mb-4" style={{ fontSize: '15px', color: '#1A1F24' }}>Voorbeeld</h3>
          <div className="flex flex-col items-center justify-center rounded-lg" style={{ minHeight: 400, backgroundColor: '#FAFBFC', border: '2px dashed #E8EBEE', padding: 40 }}>
            <Settings style={{ width: 48, height: 48, color: '#D1D6DB', marginBottom: 16 }} />
            <p className="text-sm font-medium mb-1" style={{ color: '#6B7785' }}>Configureer je rapport en klik op &quot;Rapport Genereren&quot;</p>
            <p className="text-xs" style={{ color: '#95A1AD' }}>Een preview van het rapport wordt hier weergegeven.</p>
          </div>
        </div>
      </div>

      {/* Saved reports */}
      <div className="bg-white rounded-lg" style={{ border: '1px solid #E8EBEE' }}>
        <div className="flex items-center" style={{ padding: '14px 20px', borderBottom: '1px solid #E8EBEE' }}>
          <h3 className="font-semibold" style={{ fontSize: '15px', color: '#1A1F24' }}>Opgeslagen Rapporten</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full border-collapse">
            <thead>
              <tr style={{ backgroundColor: '#F2F4F6', height: 44 }}>
                {['Rapportnaam', 'Type', 'Gemaakt door', 'Laatst uitgevoerd', 'Acties'].map(h => (
                  <th key={h} className="text-left font-semibold" style={{ padding: '0 16px', fontSize: 13, color: '#3D4550' }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {savedReports.map((row, idx) => (
                <tr key={row.id} style={{ height: 48, backgroundColor: idx % 2 === 1 ? '#FAFBFC' : '#FFFFFF', borderBottom: '1px solid #E8EBEE' }}>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#1A1F24', fontWeight: 500 }}>{row.naam}</td>
                  <td style={{ padding: '10px 16px' }}>
                    <StatusBadge status={row.type === 'Excel' ? 'active' : row.type === 'PDF' ? 'info' : 'neutral'}>{row.type}</StatusBadge>
                  </td>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#3D4550' }}>{row.gemaaktDoor}</td>
                  <td style={{ padding: '10px 16px', fontSize: 14, color: '#3D4550' }}>{row.laatstUitgevoerd}</td>
                  <td style={{ padding: '10px 16px' }}>
                    <div className="flex items-center gap-1">
                      <button className="flex items-center justify-center rounded-md text-[#4A804A] hover:bg-[#F4FAF4] transition-colors" style={{ width: '28px', height: '28px' }} title="Download">
                        <Download style={{ width: 14, height: 14 }} />
                      </button>
                      <button className="flex items-center justify-center rounded-md text-[#3B6EA5] hover:bg-[#E8F0F8] transition-colors" style={{ width: '28px', height: '28px' }} title="Bewerken">
                        <Settings style={{ width: 14, height: 14 }} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

/* ============================================================
   Main Page Component
   ============================================================ */
export default function RapportenPage() {
  const [activeTab, setActiveTab] = useState('overzicht')
  const [dateRange, setDateRange] = useState('Laatste 30 dagen')
  const [compareTo, setCompareTo] = useState('Vorige periode')
  const [showDateDropdown, setShowDateDropdown] = useState(false)
  const [showCompareDropdown, setShowCompareDropdown] = useState(false)

  const renderTab = () => {
    switch (activeTab) {
      case 'overzicht': return <OverzichtTab />
      case 'commissies': return <CommissiesTab />
      case 'contracten': return <ContractenTab />
      case 'schades': return <SchadesTab />
      case 'klanten': return <KlantenTab />
      case 'exporteren': return <ExporterenTab />
      default: return <OverzichtTab />
    }
  }

  return (
    <div className="space-y-5" style={{ maxWidth: 1400 }}>
      {/* KPI Row */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <KPICard
          icon={<Euro style={{ width: 22, height: 22 }} />}
          value={kpiData.totaalCommissie.value}
          label="Totale commissie (periode)"
          trend="up"
          trendValue={kpiData.totaalCommissie.trend}
          color="#C8A456"
          delay={0}
        />
        <KPICard
          icon={<FileText style={{ width: 22, height: 22 }} />}
          value={kpiData.nieuweContracten.value}
          label="Nieuwe contracten"
          trend="up"
          trendValue={kpiData.nieuweContracten.trend}
          color="#4A804A"
          delay={60}
        />
        <KPICard
          icon={<AlertCircle style={{ width: 22, height: 22 }} />}
          value={kpiData.schadeclaims.value}
          label="Schadeclaims"
          trend="down"
          trendValue={kpiData.schadeclaims.trend}
          color="#D4942A"
          delay={120}
        />
        <KPICard
          icon={<Users style={{ width: 22, height: 22 }} />}
          value={kpiData.nps.value}
          label="Net Promoter Score"
          trend="up"
          trendValue={kpiData.nps.trend}
          color="#3B6EA5"
          subtitle={kpiData.nps.subtitle}
          delay={180}
        />
      </div>

      {/* Tabs */}
      <div className="bg-white rounded-lg" style={{ border: '1px solid #E8EBEE' }}>
        <div className="flex items-center overflow-x-auto" style={{ borderBottom: '1px solid #E8EBEE' }}>
          {tabs.map((tab) => {
            const Icon = tab.icon
            const isActive = activeTab === tab.key
            return (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key)}
                className="flex items-center gap-2 shrink-0 transition-colors duration-150"
                style={{
                  height: '48px',
                  padding: '0 20px',
                  fontSize: '14px',
                  fontWeight: 500,
                  color: isActive ? '#4A804A' : '#6B7785',
                  borderBottom: isActive ? '2px solid #4A804A' : '2px solid transparent',
                  backgroundColor: isActive ? '#F4FAF4' : 'transparent',
                  whiteSpace: 'nowrap',
                }}
              >
                <Icon style={{ width: 16, height: 16 }} />
                {tab.label}
              </button>
            )
          })}
        </div>

        {/* Date range & compare */}
        <div className="flex items-center gap-4 flex-wrap" style={{ padding: '12px 20px', borderBottom: '1px solid #E8EBEE' }}>
          {/* Date range dropdown */}
          <div className="relative">
            <button
              onClick={() => { setShowDateDropdown(!showDateDropdown); setShowCompareDropdown(false) }}
              className="flex items-center gap-2 rounded-md border border-[#D1D6DB] text-sm transition-colors hover:bg-[#F2F4F6]"
              style={{ height: '34px', padding: '0 12px', fontSize: 12, color: '#3D4550', fontWeight: 500 }}
            >
              <Calendar style={{ width: 14, height: 14 }} />
              {dateRange}
              <ChevronDown style={{ width: 12, height: 12 }} />
            </button>
            {showDateDropdown && (
              <div className="absolute z-10 bg-white rounded-md shadow-lg mt-1" style={{ border: '1px solid #E8EBEE', minWidth: 180 }}>
                {dateRanges.map(r => (
                  <button
                    key={r}
                    onClick={() => { setDateRange(r); setShowDateDropdown(false) }}
                    className="w-full text-left px-3 py-2 text-sm transition-colors hover:bg-[#F4FAF4]"
                    style={{ color: dateRange === r ? '#4A804A' : '#3D4550', fontWeight: dateRange === r ? 600 : 400, fontSize: 12 }}
                  >
                    {r}
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Compare dropdown */}
          <div className="relative">
            <button
              onClick={() => { setShowCompareDropdown(!showCompareDropdown); setShowDateDropdown(false) }}
              className="flex items-center gap-2 rounded-md border border-[#D1D6DB] text-sm transition-colors hover:bg-[#F2F4F6]"
              style={{ height: '34px', padding: '0 12px', fontSize: 12, color: '#3D4550', fontWeight: 500 }}
            >
              <TrendingUp style={{ width: 14, height: 14 }} />
              Vergelijk: {compareTo}
              <ChevronDown style={{ width: 12, height: 12 }} />
            </button>
            {showCompareDropdown && (
              <div className="absolute z-10 bg-white rounded-md shadow-lg mt-1" style={{ border: '1px solid #E8EBEE', minWidth: 200 }}>
                {['Geen', 'Vorige periode', 'Zelfde periode vorig jaar'].map(c => (
                  <button
                    key={c}
                    onClick={() => { setCompareTo(c); setShowCompareDropdown(false) }}
                    className="w-full text-left px-3 py-2 text-sm transition-colors hover:bg-[#F4FAF4]"
                    style={{ color: compareTo === c ? '#4A804A' : '#3D4550', fontWeight: compareTo === c ? 600 : 400, fontSize: 12 }}
                  >
                    {c}
                  </button>
                ))}
              </div>
            )}
          </div>

          <div className="flex-1" />

          <button className="flex items-center gap-1.5 rounded-md text-[#3D4550] hover:bg-[#F2F4F6] transition-colors" style={{ height: '34px', padding: '0 12px', fontSize: 12, fontWeight: 500, border: '1px solid #D1D6DB' }}>
            <Filter style={{ width: 14, height: 14 }} />
            Filters
          </button>
        </div>

        {/* Tab content */}
        <div style={{ padding: '20px' }}>
          {renderTab()}
        </div>
      </div>

      {/* Sticky export bar */}
      <div className="sticky bottom-0 z-10 bg-white rounded-lg flex items-center gap-3 flex-wrap" style={{ border: '1px solid #E8EBEE', padding: '10px 16px' }}>
        <span className="text-xs font-medium" style={{ color: '#6B7785' }}>Exporteren:</span>
        <button className="flex items-center gap-1.5 rounded-md text-[#3D4550] hover:bg-[#F2F4F6] transition-colors" style={{ height: '36px', padding: '0 14px', fontSize: 12, fontWeight: 500, border: '1px solid #D1D6DB' }}>
          <FileText style={{ width: 14, height: 14 }} />
          PDF
        </button>
        <button className="flex items-center gap-1.5 rounded-md text-[#3D4550] hover:bg-[#F2F4F6] transition-colors" style={{ height: '36px', padding: '0 14px', fontSize: 12, fontWeight: 500, border: '1px solid #D1D6DB' }}>
          <FileSpreadsheet style={{ width: 14, height: 14 }} />
          Excel
        </button>
        <button className="flex items-center gap-1.5 rounded-md text-[#3D4550] hover:bg-[#F2F4F6] transition-colors" style={{ height: '36px', padding: '0 14px', fontSize: 12, fontWeight: 500, border: '1px solid #D1D6DB' }}>
          <FileDigit style={{ width: 14, height: 14 }} />
          CSV
        </button>
        <button
          onClick={() => setActiveTab('exporteren')}
          className="flex items-center gap-1.5 rounded-md text-white transition-all hover:shadow-md"
          style={{ height: '36px', padding: '0 16px', fontSize: 12, fontWeight: 500, backgroundColor: '#4A804A' }}
        >
          <Settings style={{ width: 14, height: 14 }} />
          Aangepast Rapport
        </button>
        <div className="flex-1" />
        <button className="flex items-center gap-1.5 rounded-md text-[#6B7785] hover:bg-[#F2F4F6] transition-colors" style={{ height: '36px', padding: '0 14px', fontSize: 12, fontWeight: 500, border: '1px dashed #D1D6DB' }}>
          <Calendar style={{ width: 14, height: 14 }} />
          Plan wekelijkse export
        </button>
      </div>
    </div>
  )
}
