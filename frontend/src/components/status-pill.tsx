export function StatusPill({
  label,
  tone = "teal",
}: {
  label: string;
  tone?: "teal" | "amber" | "rose" | "green";
}) {
  const tones = {
    teal: "border-teal-300/30 bg-teal-300/10 text-teal-100",
    amber: "border-amber-300/30 bg-amber-300/10 text-amber-100",
    rose: "border-rose-300/30 bg-rose-300/10 text-rose-100",
    green: "border-emerald-300/30 bg-emerald-300/10 text-emerald-100",
  };

  return (
    <span className={`inline-flex h-7 items-center rounded-md border px-2.5 text-xs ${tones[tone]}`}>
      {label}
    </span>
  );
}
