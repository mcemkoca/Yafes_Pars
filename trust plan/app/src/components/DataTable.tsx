import { useState } from 'react'
import { Pencil, Eye, MoreHorizontal } from 'lucide-react'

interface Column<T> {
  key: string
  header: string
  width?: number | string
  render: (row: T) => React.ReactNode
}

interface DataTableProps<T> {
  columns: Column<T>[]
  data: T[]
  onRowClick?: (row: T) => void
  emptyMessage?: string
  emptyAction?: React.ReactNode
}

export default function DataTable<T extends { id?: string | number }>({
  columns,
  data,
  onRowClick,
  emptyMessage = 'Geen gegevens gevonden',
  emptyAction,
}: DataTableProps<T>) {
  const [hoveredRow, setHoveredRow] = useState<string | number | null>(null)

  if (data.length === 0) {
    return (
      <div
        className="bg-white rounded-lg flex flex-col items-center justify-center"
        style={{
          border: '1px solid #E8EBEE',
          padding: '48px 24px',
        }}
      >
        <img
          src="./empty-state-search.svg"
          alt="Geen resultaten"
          style={{ width: '80px', height: '80px', marginBottom: '16px', opacity: 0.6 }}
        />
        <p className="text-sm font-medium" style={{ color: '#6B7785' }}>
          {emptyMessage}
        </p>
        {emptyAction && <div className="mt-4">{emptyAction}</div>}
      </div>
    )
  }

  return (
    <div
      className="bg-white rounded-lg overflow-hidden"
      style={{ border: '1px solid #E8EBEE' }}
    >
      <div className="overflow-x-auto">
        <table className="w-full border-collapse">
          <thead>
            <tr
              style={{
                backgroundColor: '#F2F4F6',
                height: '44px',
              }}
            >
              {columns.map((col) => (
                <th
                  key={col.key}
                  className="text-left font-semibold"
                  style={{
                    width: col.width,
                    padding: '0 16px',
                    fontSize: '13px',
                    color: '#3D4550',
                    whiteSpace: 'nowrap',
                  }}
                >
                  {col.header}
                </th>
              ))}
              <th style={{ width: '80px', padding: 0 }} />
            </tr>
          </thead>
          <tbody>
            {data.map((row, idx) => {
              const rowId = row.id ?? idx
              const isHovered = hoveredRow === rowId
              const bgColor = idx % 2 === 1 ? '#FAFBFC' : '#FFFFFF'

              return (
                <tr
                  key={rowId}
                  onClick={() => onRowClick?.(row)}
                  onMouseEnter={() => setHoveredRow(rowId)}
                  onMouseLeave={() => setHoveredRow(null)}
                  className="transition-colors duration-100"
                  style={{
                    height: '52px',
                    backgroundColor: isHovered ? '#F4FAF4' : bgColor,
                    borderBottom: '1px solid #E8EBEE',
                    cursor: onRowClick ? 'pointer' : 'default',
                  }}
                >
                  {columns.map((col) => (
                    <td
                      key={col.key}
                      style={{
                        padding: '12px 16px',
                        fontSize: '14px',
                        color: '#1A1F24',
                      }}
                    >
                      {col.render(row)}
                    </td>
                  ))}
                  {/* Row actions */}
                  <td style={{ padding: '0 8px' }}>
                    <div
                      className="flex items-center gap-0.5 transition-opacity duration-150"
                      style={{
                        opacity: isHovered ? 1 : 0,
                      }}
                    >
                      <button
                        className="flex items-center justify-center rounded-md text-[#95A1AD] hover:text-[#3D4550] hover:bg-[#F2F4F6] transition-colors duration-100"
                        style={{ width: '28px', height: '28px' }}
                        onClick={(e) => e.stopPropagation()}
                        title="Bewerken"
                      >
                        <Pencil style={{ width: '14px', height: '14px' }} />
                      </button>
                      <button
                        className="flex items-center justify-center rounded-md text-[#95A1AD] hover:text-[#3D4550] hover:bg-[#F2F4F6] transition-colors duration-100"
                        style={{ width: '28px', height: '28px' }}
                        onClick={(e) => e.stopPropagation()}
                        title="Bekijken"
                      >
                        <Eye style={{ width: '14px', height: '14px' }} />
                      </button>
                      <button
                        className="flex items-center justify-center rounded-md text-[#95A1AD] hover:text-[#3D4550] hover:bg-[#F2F4F6] transition-colors duration-100"
                        style={{ width: '28px', height: '28px' }}
                        onClick={(e) => e.stopPropagation()}
                        title="Meer"
                      >
                        <MoreHorizontal style={{ width: '14px', height: '14px' }} />
                      </button>
                    </div>
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>
    </div>
  )
}
