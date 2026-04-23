import { createClient } from "@/lib/supabase/server";
export const metadata = { title: "Admin | Agency in Your Pocket" };

export default async function AdminPage() {
  const supabase = createClient();
  const [{ count: usersCount }, { count: businessesCount }, { count: runsCount }, { data: tierData }] = await Promise.all([
    supabase.from("profiles").select("*", { count: "exact", head: true }),
    supabase.from("businesses").select("*", { count: "exact", head: true }),
    supabase.from("workflow_runs").select("*", { count: "exact", head: true }),
    supabase.from("profiles").select("plan_tier"),
  ]);
  const tierCounts = (tierData ?? []).reduce<Record<string, number>>((acc, { plan_tier }) => {
    acc[plan_tier] = (acc[plan_tier] ?? 0) + 1; return acc;
  }, {});
  return (
    <div>
      <h1 className="text-2xl font-bold text-ink-900 mb-6">Admin Overview</h1>
      <div className="grid grid-cols-3 gap-4 mb-8">
        {[["Total users", usersCount], ["Businesses", businessesCount], ["Workflow runs", runsCount]].map(([label, value]) => (
          <div key={label as string} className="bg-white rounded-xl border border-ink-200 p-5">
            <p className="text-3xl font-bold text-ink-900">{value ?? 0}</p>
            <p className="text-sm text-ink-500 mt-0.5">{label}</p>
          </div>
        ))}
      </div>
      <div className="bg-white rounded-xl border border-ink-200 p-6">
        <h2 className="text-base font-semibold text-ink-900 mb-4">Plan distribution</h2>
        <div className="flex flex-col gap-2">
          {["free", "starter", "growth", "agency", "dfy"].map((tier) => (
            <div key={tier} className="flex items-center justify-between text-sm">
              <span className="capitalize text-ink-700">{tier}</span>
              <span className="font-semibold text-ink-900">{tierCounts[tier] ?? 0}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
