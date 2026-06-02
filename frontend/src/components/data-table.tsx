import { AlertCircle, Loader2 } from "lucide-react";

type Column<T> = {
  key: keyof T;
  label: string;
  render?: (row: T) => string;
};

export function DataTable<T extends Record<string, unknown>>({
  rows,
  columns,
  loading,
  error,
  emptyLabel,
}: {
  rows: T[];
  columns: Column<T>[];
  loading?: boolean;
  error?: string;
  emptyLabel: string;
}) {
  if (loading) {
    return (
      <div className="flex min-h-48 items-center justify-center rounded-lg border border-white/10 bg-[#17191b] text-sm text-zinc-300">
        <Loader2 className="mr-2 h-4 w-4 animate-spin text-teal-300" />
        Loading
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex min-h-48 items-center justify-center rounded-lg border border-rose-400/30 bg-rose-950/20 text-sm text-rose-100">
        <AlertCircle className="mr-2 h-4 w-4" />
        {error}
      </div>
    );
  }

  if (rows.length === 0) {
    return (
      <div className="flex min-h-48 items-center justify-center rounded-lg border border-dashed border-white/15 bg-[#17191b] text-sm text-zinc-400">
        {emptyLabel}
      </div>
    );
  }

  return (
    <div className="overflow-hidden rounded-lg border border-white/10 bg-[#17191b]">
      <div className="overflow-x-auto">
        <table className="w-full min-w-[720px] table-fixed text-left text-sm">
          <thead className="bg-white/[0.04] text-xs uppercase text-zinc-400">
            <tr>
              {columns.map((column) => (
                <th key={String(column.key)} className="px-4 py-3 font-medium">
                  {column.label}
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-white/10">
            {rows.map((row, index) => (
              <tr key={index} className="text-zinc-200">
                {columns.map((column) => (
                  <td key={String(column.key)} className="truncate px-4 py-3">
                    {column.render ? column.render(row) : String(row[column.key] ?? "")}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
