import { createClient } from "@/lib/supabase/server";
import { Badge } from "@/components/ui/badge";
import { VERTICALS } from "@/lib/verticals/config";
export const metadata = { title: "Businesses | Admin" };
export default async function AdminBusinessesPage() {
  const supabase = createClient();
  const { data: businesses } = await supabase.from("businesses").select("id, name, vertical, stage, onboarding_completed, created_at, profiles!inner(email)").order("created_at", { ascending: false }).limit(100);
  return (
    <div>
      <h1 className="text-2xl font-bold text-ink-900 mb-6">Businesses ({businesses?.length ?? 0})</h1>
      <div className="bg-white rounded-xl border border-ink-200 overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-ink-50 border-b border-ink-200">
            <tr>{["Business", "Vertical", "Stage", "Owner", "Onboarded", "Created"].map((h) => <th key={h} className="text-left px-4 py-3 text-xs font-semibold text-ink-500 uppercase tracking-wide">{h}</th>)}</tr>
          </thead>
          <tbody className="divide-y divide-ink-100">
            {(businesses ?? []).map((b) => {
              const v = VERTICALS[b.vertical as keyof typeof VERTICALS];
              return (
                <tr key={b.id} className="hover:bg-ink-50">
                  <td className="px-4 py-3 font-medium text-ink-900">{b.name}</td>
                  <td className="px-4 py-3 text-ink-600">{v ? `${v.emoji} ${v.label}` : b.vertical}</td>
                  <td className="px-4 py-3 text-ink-600">{b.stage ?? "—"}</td>
                  <td className="px-4 py-3 text-ink-500 text-xs">{(b.profiles as unknown as { email: string })?.email ?? "—"}</td>
                  <td className="px-4 py-3"><Badge variant={b.onboarding_completed ? "default" : "secondary"} className="text-xs">{b.onboarding_completed ? "Yes" : "No"}</Badge></td>
                  <td className="px-4 py-3 text-ink-400 text-xs">{new Date(b.created_at).toLocaleDateString("en-GB")}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}
