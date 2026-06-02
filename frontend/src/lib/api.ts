export type CoverageSummary = {
  coverageCode: string;
  labelNl: string;
  labelFr?: string;
  labelEn?: string;
  description?: string;
};

export type DashboardMetric = {
  label: string;
  value: string;
  delta: string;
  tone: "teal" | "amber" | "rose" | "green";
};

const apiBaseUrl = process.env.NEXT_PUBLIC_API_BASE_URL?.replace(/\/$/, "") ?? "";

async function apiGet<T>(path: string, fallback: T): Promise<T> {
  if (!apiBaseUrl) {
    return fallback;
  }

  const response = await fetch(`${apiBaseUrl}${path}`, {
    headers: { Accept: "application/json" },
  });

  if (!response.ok) {
    throw new Error(`API request failed: ${response.status}`);
  }

  return (await response.json()) as T;
}

export async function getCoverage(): Promise<CoverageSummary[]> {
  return apiGet<CoverageSummary[]>("/api/coverage", [
    {
      coverageCode: "BA_AUTO",
      labelNl: "BA Auto",
      labelFr: "RC Auto",
      labelEn: "Motor liability",
      description: "Required vehicle liability coverage.",
    },
    {
      coverageCode: "FIRE_BUILDING",
      labelNl: "Brand gebouw",
      labelFr: "Incendie batiment",
      labelEn: "Fire building",
      description: "Building fire coverage.",
    },
    {
      coverageCode: "FAMILY_LIABILITY",
      labelNl: "Familiale BA",
      labelFr: "RC familiale",
      labelEn: "Family liability",
      description: "Private liability coverage.",
    },
  ]);
}

export const dashboardMetrics: DashboardMetric[] = [
  { label: "Active policies", value: "428", delta: "+18", tone: "teal" },
  { label: "Open claims", value: "36", delta: "-4", tone: "amber" },
  { label: "Renewals due", value: "61", delta: "+12", tone: "rose" },
  { label: "Tasks open", value: "94", delta: "+7", tone: "green" },
];
