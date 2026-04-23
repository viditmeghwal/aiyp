import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { GrowthPlanKanban } from "@/components/app/GrowthPlanKanban";
import { PageTransition } from "@/components/common/PageTransition";
import { CheckCircle2, ListTodo, FolderOpen, Zap } from "lucide-react";
import Link from "next/link";

export const metadata = { title: "Dashboard | Agency in Your Pocket" };

export default async function DashboardPage() {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const [{ data: profile }, { data: business }] = await Promise.all([
    supabase.from("profiles").select("full_name").eq("id", user.id).single(),
    supabase.from("businesses").select("id, name, vertical").eq("user_id", user.id).eq("onboarding_completed", true).single(),
  ]);
  if (!business) redirect("/onboarding");

  const [{ data: tasks }, { data: deliverables }] = await Promise.all([
    supabase.from("tasks").select("id, title, description, workflow_ref, phase, status").eq("business_id", business.id).order("order_index"),
    supabase.from("deliverables").select("id").eq("business_id", business.id),
  ]);

  const allTasks = tasks ?? [];
  const completedTasks = allTasks.filter((t) => t.status === "complete");
  const completionPct = allTasks.length > 0 ? Math.round((completedTasks.length / allTasks.length) * 100) : 0;
  const firstName = profile?.full_name?.split(" ")[0] ?? "there";

  return (
    <PageTransition>
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-ink-900">Hey {firstName} 👋</h1>
        <p className="text-sm text-ink-500 mt-0.5">Here&apos;s your growth plan for {business.name}.</p>
      </div>
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-8">
        <StatCard icon={CheckCircle2} label="Completed" value={`${completedTasks.length} / ${allTasks.length}`} color="text-emerald-600" />
        <StatCard icon={ListTodo} label="To do" value={String(allTasks.filter((t) => t.status === "not_started").length)} color="text-ink-500" />
        <StatCard icon={Zap} label="In progress" value={String(allTasks.filter((t) => t.status === "in_progress").length)} color="text-blue-600" />
        <StatCard icon={FolderOpen} label="Deliverables" value={String(deliverables?.length ?? 0)} color="text-pocket-orange" href="/deliverables" />
      </div>
      {allTasks.length > 0 && (
        <div className="mb-6">
          <div className="flex justify-between text-xs text-ink-500 mb-1.5"><span>Overall progress</span><span>{completionPct}%</span></div>
          <div className="h-2 bg-ink-200 rounded-full overflow-hidden">
            <div className="h-full bg-pocket-orange rounded-full transition-all duration-500" style={{ width: `${completionPct}%` }} />
          </div>
        </div>
      )}
      <div>
        <h2 className="text-base font-semibold text-ink-900 mb-4">Your growth plan</h2>
        <GrowthPlanKanban tasks={allTasks} />
      </div>
    </PageTransition>
  );
}

function StatCard({ icon: Icon, label, value, color, href }: { icon: React.ComponentType<{ className?: string }>; label: string; value: string; color: string; href?: string }) {
  const content = (
    <div className="bg-white rounded-xl border border-ink-200 px-4 py-3 flex items-center gap-3">
      <Icon className={`w-4 h-4 shrink-0 ${color}`} />
      <div><p className="text-lg font-bold text-ink-900 leading-none">{value}</p><p className="text-xs text-ink-500 mt-0.5">{label}</p></div>
    </div>
  );
  return href ? <Link href={href}>{content}</Link> : content;
}
