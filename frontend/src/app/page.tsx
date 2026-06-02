"use client";

import { useQuery } from "@tanstack/react-query";
import {
  Building2,
  ClipboardList,
  FileText,
  Gauge,
  LayoutDashboard,
  Lock,
  Search,
  Settings,
  ShieldCheck,
  Siren,
  Users,
  WalletCards,
} from "lucide-react";
import { useMemo, useState } from "react";
import { DataTable } from "@/components/data-table";
import { StatusPill } from "@/components/status-pill";
import { dashboardMetrics, getCoverage } from "@/lib/api";

const sections = [
  { id: "login", label: "Login", icon: Lock },
  { id: "dashboard", label: "Dashboard", icon: LayoutDashboard },
  { id: "persons", label: "Customers", icon: Users },
  { id: "institutions", label: "Institutions", icon: Building2 },
  { id: "risks", label: "Risk Objects", icon: ShieldCheck },
  { id: "policies", label: "Policies", icon: WalletCards },
  { id: "claims", label: "Claims", icon: Siren },
  { id: "documents", label: "Documents", icon: FileText },
  { id: "tasks", label: "Tasks", icon: ClipboardList },
  { id: "coverage", label: "Coverage", icon: Gauge },
  { id: "settings", label: "Settings", icon: Settings },
] as const;

const sampleRows = {
  persons: [
    { dossier: "DEMO-P-001", name: "Jan Peeters", type: "Natural", status: "Active" },
    { dossier: "DEMO-L-001", name: "Yafes Demo Broker BV", type: "Legal", status: "Active" },
  ],
  institutions: [
    { code: "AG-BE", name: "AG Insurance", role: "Insurer", status: "Active" },
    { code: "KBC-BE", name: "KBC Bank", role: "Bank", status: "Active" },
  ],
  risks: [
    { code: "1ABC123", object: "Volkswagen Golf", type: "Vehicle", status: "Active" },
    { code: "2018", object: "Family home Antwerp", type: "Real estate", status: "Active" },
  ],
  policies: [
    { number: "POL-2026-0001", domain: "Motor", company: "AG Insurance", status: "Active" },
    { number: "POL-2026-0003", domain: "Fire", company: "AG Insurance", status: "Active" },
  ],
  claims: [
    { number: "CLM-2026-0001", policy: "POL-2026-0001", status: "Open", amount: "1500.00" },
    { number: "CLM-2026-0002", policy: "POL-2026-0003", status: "Closed", amount: "2400.00" },
  ],
  documents: [
    { file: "POL-2026-0001.pdf", owner: "Policy", type: "Policy document", size: "245 KB" },
    { file: "CLM-2026-0001-report.pdf", owner: "Claim", type: "Claim report", size: "180 KB" },
  ],
  tasks: [
    { title: "Renew policy POL-2026-0001", owner: "Policy", priority: "High", status: "Open" },
    { title: "Follow up claim CLM-2026-0001", owner: "Claim", priority: "Normal", status: "In progress" },
  ],
};

export default function Home() {
  const [activeSection, setActiveSection] = useState<(typeof sections)[number]["id"]>("dashboard");
  const [search, setSearch] = useState("");
  const active = useMemo(
    () => sections.find((section) => section.id === activeSection) ?? sections[1],
    [activeSection],
  );
  const ActiveIcon = active.icon;

  return (
    <main className="min-h-screen bg-[#101112] text-zinc-100">
      <div className="flex min-h-screen">
        <aside className="hidden w-72 shrink-0 border-r border-white/10 bg-[#141617] p-5 lg:block">
          <div className="mb-8 flex h-12 items-center gap-3">
            <div className="grid h-10 w-10 place-items-center rounded-lg bg-teal-300 text-[#0b1514]">
              <ShieldCheck className="h-5 w-5" />
            </div>
            <div>
              <div className="text-base font-semibold">Yafes Pars</div>
              <div className="text-xs text-zinc-400">Broker Ops</div>
            </div>
          </div>
          <nav className="space-y-1">
            {sections.map((section) => {
              const Icon = section.icon;
              const selected = activeSection === section.id;
              return (
                <button
                  key={section.id}
                  type="button"
                  onClick={() => setActiveSection(section.id)}
                  className={`flex h-11 w-full items-center gap-3 rounded-lg px-3 text-left text-sm transition ${
                    selected ? "bg-white text-[#111314]" : "text-zinc-300 hover:bg-white/8 hover:text-white"
                  }`}
                >
                  <Icon className="h-4 w-4 shrink-0" />
                  <span className="truncate">{section.label}</span>
                </button>
              );
            })}
          </nav>
        </aside>

        <section className="flex min-w-0 flex-1 flex-col">
          <header className="border-b border-white/10 bg-[#141617] px-4 py-4 lg:px-8">
            <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
              <div className="flex items-center gap-3">
                <div className="grid h-10 w-10 place-items-center rounded-lg border border-white/10 bg-white/[0.04]">
                  <ActiveIcon className="h-5 w-5 text-teal-200" />
                </div>
                <div>
                  <h1 className="text-xl font-semibold">{active.label}</h1>
                  <p className="text-sm text-zinc-400">DEV tenant: DEMO-BE-BROKER</p>
                </div>
              </div>
              <div className="flex items-center gap-2">
                <div className="relative w-full min-w-0 lg:w-80">
                  <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-zinc-500" />
                  <input
                    value={search}
                    onChange={(event) => setSearch(event.target.value)}
                    className="h-10 w-full rounded-lg border border-white/10 bg-[#101112] pl-10 pr-3 text-sm text-zinc-100 outline-none focus:border-teal-300/60"
                    placeholder="Search"
                  />
                </div>
                <StatusPill label="DEV" tone="teal" />
              </div>
            </div>
            <div className="mt-4 flex gap-2 overflow-x-auto lg:hidden">
              {sections.map((section) => {
                const Icon = section.icon;
                return (
                  <button
                    key={section.id}
                    type="button"
                    onClick={() => setActiveSection(section.id)}
                    className={`grid h-10 w-10 shrink-0 place-items-center rounded-lg border ${
                      activeSection === section.id
                        ? "border-teal-300 bg-teal-300 text-[#0b1514]"
                        : "border-white/10 bg-white/[0.04] text-zinc-300"
                    }`}
                    aria-label={section.label}
                    title={section.label}
                  >
                    <Icon className="h-4 w-4" />
                  </button>
                );
              })}
            </div>
          </header>

          <div className="flex-1 space-y-6 p-4 lg:p-8">
            {activeSection === "dashboard" && <Dashboard />}
            {activeSection === "login" && <LoginPanel />}
            {activeSection === "coverage" && <CoveragePanel />}
            {activeSection !== "dashboard" && activeSection !== "login" && activeSection !== "coverage" && (
              <DomainPanel section={activeSection} search={search} />
            )}
          </div>
        </section>
      </div>
    </main>
  );
}

function Dashboard() {
  return (
    <div className="space-y-6">
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {dashboardMetrics.map((metric) => (
          <div key={metric.label} className="rounded-lg border border-white/10 bg-[#17191b] p-4">
            <div className="text-sm text-zinc-400">{metric.label}</div>
            <div className="mt-3 flex items-end justify-between">
              <div className="text-3xl font-semibold">{metric.value}</div>
              <StatusPill label={metric.delta} tone={metric.tone} />
            </div>
          </div>
        ))}
      </div>
      <div className="grid gap-6 xl:grid-cols-[1.25fr_0.75fr]">
        <DataTable
          rows={sampleRows.policies}
          emptyLabel="No policies"
          columns={[
            { key: "number", label: "Number" },
            { key: "domain", label: "Domain" },
            { key: "company", label: "Company" },
            { key: "status", label: "Status" },
          ]}
        />
        <div className="rounded-lg border border-white/10 bg-[#17191b] p-4">
          <div className="mb-4 flex items-center justify-between">
            <h2 className="text-base font-semibold">Renewal Queue</h2>
            <StatusPill label="61 due" tone="rose" />
          </div>
          <div className="space-y-3">
            {sampleRows.tasks.map((task) => (
              <div key={task.title} className="rounded-lg border border-white/10 bg-[#101112] p-3">
                <div className="truncate text-sm font-medium">{task.title}</div>
                <div className="mt-2 flex items-center justify-between text-xs text-zinc-400">
                  <span>{task.owner}</span>
                  <span>{task.priority}</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

function LoginPanel() {
  return (
    <div className="max-w-md rounded-lg border border-white/10 bg-[#17191b] p-5">
      <div className="mb-5 flex items-center gap-3">
        <div className="grid h-10 w-10 place-items-center rounded-lg bg-amber-300 text-[#201704]">
          <Lock className="h-5 w-5" />
        </div>
        <div>
          <h2 className="text-base font-semibold">Broker Login</h2>
          <p className="text-sm text-zinc-400">JWT provider pending</p>
        </div>
      </div>
      <div className="space-y-3">
        <input className="h-11 w-full rounded-lg border border-white/10 bg-[#101112] px-3 text-sm outline-none focus:border-teal-300/60" placeholder="Email" />
        <input className="h-11 w-full rounded-lg border border-white/10 bg-[#101112] px-3 text-sm outline-none focus:border-teal-300/60" placeholder="Password" type="password" />
        <button className="h-11 w-full rounded-lg bg-teal-300 px-4 text-sm font-semibold text-[#0b1514]">
          Sign in
        </button>
      </div>
    </div>
  );
}

function DomainPanel({ section, search }: { section: string; search: string }) {
  const rowsBySection: Record<string, Record<string, string>[]> = {
    persons: sampleRows.persons,
    institutions: sampleRows.institutions,
    risks: sampleRows.risks,
    policies: sampleRows.policies,
    claims: sampleRows.claims,
    documents: sampleRows.documents,
    tasks: sampleRows.tasks,
    settings: [
      { key: "API base URL", value: process.env.NEXT_PUBLIC_API_BASE_URL ?? "local" },
      { key: "Theme", value: "Dark" },
    ],
  };
  const rows = (rowsBySection[section] ?? []).filter((row) =>
    Object.values(row).some((value) => value.toLowerCase().includes(search.toLowerCase())),
  );
  const keys = Object.keys(rowsBySection[section]?.[0] ?? { key: "", value: "" });

  return (
    <DataTable
      rows={rows}
      emptyLabel="No records"
      columns={keys.map((key) => ({
        key,
        label: key.replace(/^\w/, (value) => value.toUpperCase()),
      }))}
    />
  );
}

function CoveragePanel() {
  const query = useQuery({
    queryKey: ["coverage"],
    queryFn: getCoverage,
  });

  return (
    <DataTable
      rows={(query.data ?? []) as unknown as Record<string, unknown>[]}
      loading={query.isLoading}
      error={query.error ? "Coverage API unavailable" : undefined}
      emptyLabel="No coverage"
      columns={[
        { key: "coverageCode", label: "Code" },
        { key: "labelNl", label: "Dutch" },
        { key: "labelFr", label: "French" },
        { key: "labelEn", label: "English" },
        { key: "description", label: "Description" },
      ]}
    />
  );
}
