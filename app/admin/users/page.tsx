import { createClient } from "@/lib/supabase/server";
import { Badge } from "@/components/ui/badge";
export const metadata = { title: "Users | Admin" };
export default async function AdminUsersPage() {
  const supabase = createClient();
  const { data: users } = await supabase.from("profiles").select("id, email, full_name, plan_tier, is_admin, created_at").order("created_at", { ascending: false }).limit(100);
  return (
    <div>
      <h1 className="text-2xl font-bold text-ink-900 mb-6">Users ({users?.length ?? 0})</h1>
      <div className="bg-white rounded-xl border border-ink-200 overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-ink-50 border-b border-ink-200">
            <tr>{["Name", "Email", "Plan", "Admin", "Joined"].map((h) => <th key={h} className="text-left px-4 py-3 text-xs font-semibold text-ink-500 uppercase tracking-wide">{h}</th>)}</tr>
          </thead>
          <tbody className="divide-y divide-ink-100">
            {(users ?? []).map((u) => (
              <tr key={u.id} className="hover:bg-ink-50">
                <td className="px-4 py-3 font-medium text-ink-900">{u.full_name ?? "—"}</td>
                <td className="px-4 py-3 text-ink-600">{u.email}</td>
                <td className="px-4 py-3"><Badge variant={u.plan_tier === "free" ? "secondary" : "default"} className="capitalize text-xs">{u.plan_tier}</Badge></td>
                <td className="px-4 py-3">{u.is_admin ? "✓" : "—"}</td>
                <td className="px-4 py-3 text-ink-400 text-xs">{new Date(u.created_at).toLocaleDateString("en-GB")}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
