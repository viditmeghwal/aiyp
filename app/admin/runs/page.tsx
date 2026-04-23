import { createClient } from "@/lib/supabase/server";
export const metadata = { title: "Workflow Runs | Admin" };
const STATUS_COLORS: Record<string, string> = { queued: "bg-ink-100 text-ink-600", running: "bg-blue-100 text-blue-700", succeeded: "bg-emerald-100 text-emerald-700", failed: "bg-red-100 text-red-700" };
export default async function AdminRunsPage() {
  const supabase = createClient();
  const { data: runs } = await supabase.from("workflow_runs").select("id, workflow_ref, status, duration_ms, cost_usd, created_at, businesses!inner(name)").order("created_at", { ascending: false }).limit(100);
  return (
    <div>
      <h1 className="text-2xl font-bold text-ink-900 mb-6">Workflow Runs ({runs?.length ?? 0})</h1>
      <div className="bg-white rounded-xl border border-ink-200 overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-ink-50 border-b border-ink-200">
            <tr>{["Workflow", "Business", "Status", "Duration", "Cost", "When"].map((h) => <th key={h} className="text-left px-4 py-3 text-xs font-semibold text-ink-500 uppercase tracking-wide">{h}</th>)}</tr>
          </thead>
          <tbody className="divide-y divide-ink-100">
            {(runs ?? []).map((r) => (
              <tr key={r.id} className="hover:bg-ink-50">
                <td className="px-4 py-3 font-mono text-xs text-ink-700">{r.workflow_ref}</td>
                <td className="px-4 py-3 text-ink-700">{(r.businesses as unknown as { name: string })?.name ?? "—"}</td>
                <td className="px-4 py-3"><span className={`px-2 py-0.5 rounded text-xs font-medium ${STATUS_COLORS[r.status] ?? ""}`}>{r.status}</span></td>
                <td className="px-4 py-3 text-ink-500 text-xs">{r.duration_ms ? `${(r.duration_ms / 1000).toFixed(1)}s` : "—"}</td>
                <td className="px-4 py-3 text-ink-500 text-xs">{r.cost_usd != null ? `$${r.cost_usd.toFixed(4)}` : "—"}</td>
                <td className="px-4 py-3 text-ink-400 text-xs">{new Date(r.created_at).toLocaleDateString("en-GB")}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
