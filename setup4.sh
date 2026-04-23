mkdir -p "app/(app)/onboarding" "app/(app)/dashboard" \
  "app/(app)/deliverables/[id]" "app/(app)/workflow/[ref]" \
  "app/(app)/settings/profile" "app/(app)/settings/billing" "app/(app)/settings/integrations" \
  "app/admin/users" "app/admin/runs" "app/admin/businesses"

# ── app/(app)/layout.tsx ─────────────────────────────────────────────────────
cat > "app/(app)/layout.tsx" << 'HEREDOC'
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { AppNav } from "@/components/app/AppNav";
import { Sidebar } from "@/components/app/Sidebar";
import { Toaster } from "@/components/ui/toaster";
import type { VerticalSlug } from "@/lib/verticals/config";

export default async function AppLayout({ children }: { children: React.ReactNode }) {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const [{ data: profile }, { data: business }] = await Promise.all([
    supabase.from("profiles").select("full_name, plan_tier, is_admin").eq("id", user.id).single(),
    supabase.from("businesses").select("name, vertical, onboarding_completed").eq("user_id", user.id).eq("onboarding_completed", true).maybeSingle(),
  ]);

  if (!business) redirect("/onboarding");

  return (
    <div className="flex flex-col min-h-screen bg-ink-100">
      <AppNav fullName={profile?.full_name ?? null} email={user.email ?? ""} isAdmin={profile?.is_admin ?? false} />
      <div className="flex flex-1 min-h-0">
        <Sidebar businessName={business.name} vertical={business.vertical as VerticalSlug} planTier={profile?.plan_tier ?? "free"} />
        <main className="flex-1 overflow-auto">
          <div className="max-w-5xl mx-auto px-4 sm:px-6 py-6">{children}</div>
        </main>
      </div>
      <Toaster />
    </div>
  );
}
HEREDOC

# ── app/(app)/onboarding/page.tsx ─────────────────────────────────────────────
cat > "app/(app)/onboarding/page.tsx" << 'HEREDOC'
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Logo } from "@/components/brand/Logo";
import { OnboardingWizard } from "@/components/app/OnboardingWizard";

export const metadata = { title: "Set up your account | Agency in Your Pocket" };

export default async function OnboardingPage() {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login?returnTo=/onboarding");

  const { data: business } = await supabase.from("businesses").select("onboarding_completed").eq("user_id", user.id).eq("onboarding_completed", true).maybeSingle();
  if (business) redirect("/dashboard");

  return (
    <div className="min-h-screen bg-pocket-cream flex flex-col items-center px-4 py-10">
      <div className="mb-10"><Logo size="md" /></div>
      <OnboardingWizard userEmail={user.email ?? ""} />
    </div>
  );
}
HEREDOC

# ── app/(app)/onboarding/actions.ts ───────────────────────────────────────────
cat > "app/(app)/onboarding/actions.ts" << 'HEREDOC'
"use server";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { getTasksForVertical } from "@/lib/verticals/questions";
import type { VerticalSlug } from "@/lib/verticals/config";
import { track } from "@/lib/analytics/posthog";

export async function completeOnboarding(formData: FormData) {
  const supabase = createClient();
  const { data: { user }, error: userError } = await supabase.auth.getUser();
  if (userError || !user) throw new Error("Not authenticated");

  const name = (formData.get("name") as string).trim();
  const vertical = formData.get("vertical") as VerticalSlug;
  const location = (formData.get("location") as string | null)?.trim() || null;
  const website_url = (formData.get("website_url") as string | null)?.trim() || null;
  const instagram_handle = (formData.get("instagram_handle") as string | null)?.trim() || null;
  const stage = (formData.get("stage") as string | null) || null;
  const goals = formData.get("goals") ? JSON.parse(formData.get("goals") as string) : [];
  const hours_per_week = (formData.get("hours_per_week") as string | null) || null;
  const biggest_frustration = (formData.get("biggest_frustration") as string | null)?.trim() || null;

  const { data: business, error: bizError } = await supabase.from("businesses").insert({
    user_id: user.id, name, vertical, location, website_url, instagram_handle,
    stage: stage as "prelaunch" | "0-6mo" | "6-24mo" | "2yr+" | null,
    goals, hours_per_week: hours_per_week as "<2" | "2-5" | "5+" | null,
    biggest_frustration, onboarding_completed: true,
  }).select().single();
  if (bizError || !business) throw new Error("Failed to save your business details.");

  const { data: plan, error: planError } = await supabase.from("growth_plans").insert({
    business_id: business.id, version: 1, is_active: true, raw_plan: { vertical, goals, stage, hours_per_week },
  }).select().single();
  if (planError || !plan) throw new Error("Failed to create growth plan.");

  const tasks = getTasksForVertical(vertical);
  const { error: tasksError } = await supabase.from("tasks").insert(tasks.map((t) => ({
    plan_id: plan.id, business_id: business.id, title: t.title, description: t.description,
    workflow_ref: t.workflow_ref, phase: t.phase, order_index: t.order_index, status: "not_started" as const,
  })));
  if (tasksError) throw new Error("Failed to create your task list.");

  track(user.id, "onboarding_completed", { vertical, task_count: tasks.length });
  redirect("/dashboard");
}
HEREDOC

# ── app/(app)/dashboard/page.tsx ──────────────────────────────────────────────
cat > "app/(app)/dashboard/page.tsx" << 'HEREDOC'
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
HEREDOC

# ── app/(app)/dashboard/actions.ts ────────────────────────────────────────────
cat > "app/(app)/dashboard/actions.ts" << 'HEREDOC'
"use server";
import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import { track } from "@/lib/analytics/posthog";

type TaskStatus = "not_started" | "in_progress" | "review" | "complete";

export async function updateTaskStatus(taskId: string, status: TaskStatus) {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error("Not authenticated");
  const updateData: { status: TaskStatus; completed_at?: string | null } = { status };
  if (status === "complete") updateData.completed_at = new Date().toISOString();
  await supabase.from("tasks").update(updateData).eq("id", taskId);
  if (status === "complete") track(user.id, "task_completed", { task_id: taskId });
  revalidatePath("/dashboard");
}
HEREDOC

# ── app/(app)/dashboard/loading.tsx ───────────────────────────────────────────
cat > "app/(app)/dashboard/loading.tsx" << 'HEREDOC'
import { LoadingSparkPage } from "@/components/common/LoadingSpark";
export default function DashboardLoading() { return <LoadingSparkPage label="Loading your dashboard…" />; }
HEREDOC

# ── app/(app)/deliverables/page.tsx ───────────────────────────────────────────
cat > "app/(app)/deliverables/page.tsx" << 'HEREDOC'
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { DeliverableCard } from "@/components/app/DeliverableCard";
import { EmptyState } from "@/components/common/EmptyState";
import { PageTransition } from "@/components/common/PageTransition";
import { FolderOpen } from "lucide-react";

export const metadata = { title: "Deliverables | Agency in Your Pocket" };
type DeliverableType = "audit" | "brand_kit" | "content_calendar" | "reel_scripts" | "website_copy" | "other";

export default async function DeliverablesPage({ searchParams }: { searchParams: { type?: string } }) {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: business } = await supabase.from("businesses").select("id").eq("user_id", user.id).eq("onboarding_completed", true).single();
  if (!business) redirect("/onboarding");

  let query = supabase.from("deliverables").select("id, title, type, file_url, created_at").eq("business_id", business.id).order("created_at", { ascending: false });
  const validTypes = ["audit", "brand_kit", "content_calendar", "reel_scripts", "website_copy", "other"];
  if (searchParams.type && searchParams.type !== "all" && validTypes.includes(searchParams.type)) {
    query = query.eq("type", searchParams.type as DeliverableType);
  }

  const { data: deliverables } = await query;
  const items = deliverables ?? [];

  return (
    <PageTransition>
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-ink-900">Deliverables</h1>
        <p className="text-sm text-ink-500 mt-0.5">Everything your AI agency has produced for you.</p>
      </div>
      {items.length === 0 ? (
        <EmptyState icon={FolderOpen} title="No deliverables yet" description="Complete a task with an AI workflow to generate your first deliverable." action={{ label: "Go to dashboard", href: "/dashboard" }} />
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {items.map((d) => <DeliverableCard key={d.id} {...d} type={d.type as DeliverableType} />)}
        </div>
      )}
    </PageTransition>
  );
}
HEREDOC

# ── app/(app)/deliverables/loading.tsx ────────────────────────────────────────
cat > "app/(app)/deliverables/loading.tsx" << 'HEREDOC'
import { LoadingSparkPage } from "@/components/common/LoadingSpark";
export default function DeliverablesLoading() { return <LoadingSparkPage label="Loading deliverables…" />; }
HEREDOC

# ── app/(app)/deliverables/[id]/page.tsx ──────────────────────────────────────
cat > "app/(app)/deliverables/[id]/page.tsx" << 'HEREDOC'
import { redirect, notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { PageTransition } from "@/components/common/PageTransition";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Download, ArrowLeft } from "lucide-react";
import Link from "next/link";

export default async function DeliverablePage({ params }: { params: { id: string } }) {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: deliverable } = await supabase.from("deliverables").select("*, businesses!inner(user_id)").eq("id", params.id).single();
  if (!deliverable) notFound();

  const date = new Date(deliverable.created_at).toLocaleDateString("en-GB", { day: "numeric", month: "long", year: "numeric" });
  const metadata = deliverable.metadata as Record<string, unknown>;

  return (
    <PageTransition>
      <div className="mb-6">
        <Link href="/deliverables" className="flex items-center gap-1.5 text-sm text-ink-500 hover:text-pocket-orange mb-4">
          <ArrowLeft className="w-4 h-4" />Deliverables
        </Link>
        <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-4">
          <div>
            <h1 className="text-2xl font-bold text-ink-900">{deliverable.title}</h1>
            <div className="flex items-center gap-2 mt-1">
              <Badge variant="secondary" className="capitalize">{deliverable.type.replace("_", " ")}</Badge>
              <span className="text-sm text-ink-400">{date}</span>
            </div>
          </div>
          {deliverable.file_url && (
            <Button asChild className="bg-pocket-orange hover:bg-pocket-orange-dark text-white gap-2 shrink-0">
              <a href={deliverable.file_url} download><Download className="w-4 h-4" />Download</a>
            </Button>
          )}
        </div>
      </div>
      <div className="bg-white rounded-xl border border-ink-200 p-6">
        {metadata?.summary ? (
          <pre className="whitespace-pre-wrap font-sans text-sm leading-relaxed text-ink-700">{String(metadata.summary)}</pre>
        ) : (
          <p className="text-sm text-ink-500">Download the file to view the full content.</p>
        )}
      </div>
    </PageTransition>
  );
}
HEREDOC

# ── app/(app)/workflow/[ref]/page.tsx ─────────────────────────────────────────
cat > "app/(app)/workflow/[ref]/page.tsx" << 'HEREDOC'
import { redirect, notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { WorkflowRunner } from "@/components/app/WorkflowRunner";
import { WORKFLOW_REGISTRY } from "@/lib/workflows/registry";
import { track } from "@/lib/analytics/posthog";

export default async function WorkflowPage({ params, searchParams }: { params: { ref: string }; searchParams: { taskId?: string } }) {
  const workflow = WORKFLOW_REGISTRY[params.ref];
  if (!workflow) notFound();

  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: business } = await supabase.from("businesses").select("id").eq("user_id", user.id).eq("onboarding_completed", true).single();
  if (!business) redirect("/onboarding");

  track(user.id, "workflow_started", { workflow_ref: params.ref, task_id: searchParams.taskId });

  const { data: run } = await supabase.from("workflow_runs").insert({
    business_id: business.id, task_id: searchParams.taskId ?? null, workflow_ref: params.ref, status: "queued",
  }).select("id").single();

  if (run) {
    await supabase.from("workflow_runs").update({ status: "running", started_at: new Date().toISOString() }).eq("id", run.id);
    await supabase.from("deliverables").insert({
      business_id: business.id, workflow_run_id: run.id, type: workflow.deliverableType,
      title: `${workflow.name} — ${new Date().toLocaleDateString("en-GB", { day: "numeric", month: "short", year: "numeric" })}`,
      metadata: { summary: `Your ${workflow.name} has been generated.\n\n${workflow.steps.map((s, i) => `${i + 1}. ${s.replace("…", "")}`).join("\n")}` },
    });
    await supabase.from("workflow_runs").update({ status: "succeeded", completed_at: new Date().toISOString() }).eq("id", run.id);
    track(user.id, "workflow_completed", { workflow_ref: params.ref });
    if (searchParams.taskId) {
      await supabase.from("tasks").update({ status: "complete", completed_at: new Date().toISOString() }).eq("id", searchParams.taskId);
    }
  }

  return <WorkflowRunner workflow={workflow} runId={run?.id ?? ""} />;
}
HEREDOC

# ── app/(app)/settings/page.tsx ───────────────────────────────────────────────
cat > "app/(app)/settings/page.tsx" << 'HEREDOC'
import { redirect } from "next/navigation";
export default function SettingsPage() { redirect("/settings/profile"); }
HEREDOC

# ── app/(app)/settings/profile/page.tsx ──────────────────────────────────────
cat > "app/(app)/settings/profile/page.tsx" << 'HEREDOC'
"use client";
import * as React from "react";
import { useRouter } from "next/navigation";
import { Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { createClient } from "@/lib/supabase/client";
import { PageTransition } from "@/components/common/PageTransition";
import { useToast } from "@/hooks/use-toast";

export default function ProfileSettingsPage() {
  const router = useRouter();
  const { toast } = useToast();
  const [loading, setLoading] = React.useState(true);
  const [saving, setSaving] = React.useState(false);
  const [fullName, setFullName] = React.useState("");
  const [email, setEmail] = React.useState("");
  const [error, setError] = React.useState<string | null>(null);

  React.useEffect(() => {
    const supabase = createClient();
    supabase.auth.getUser().then(({ data: { user } }) => {
      if (!user) { router.push("/login"); return; }
      setEmail(user.email ?? "");
      supabase.from("profiles").select("full_name").eq("id", user.id).single().then(({ data }) => {
        setFullName(data?.full_name ?? "");
        setLoading(false);
      });
    });
  }, [router]);

  async function handleSave(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true); setError(null);
    const supabase = createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return;
    const { error } = await supabase.from("profiles").update({ full_name: fullName, updated_at: new Date().toISOString() }).eq("id", user.id);
    if (error) { setError(error.message); } else { toast({ title: "Profile saved", description: "Your changes have been saved successfully." }); }
    setSaving(false);
  }

  if (loading) return null;

  return (
    <PageTransition>
      <div className="max-w-lg">
        <h1 className="text-2xl font-bold text-ink-900 mb-1">Profile</h1>
        <p className="text-sm text-ink-500 mb-6">Update your account details.</p>
        <div className="bg-white rounded-xl border border-ink-200 p-6">
          <form onSubmit={handleSave} className="flex flex-col gap-4">
            <div className="flex flex-col gap-1.5">
              <Label htmlFor="name">Full name</Label>
              <Input id="name" value={fullName} onChange={(e) => setFullName(e.target.value)} />
            </div>
            <div className="flex flex-col gap-1.5">
              <Label htmlFor="email">Email</Label>
              <Input id="email" value={email} disabled className="bg-ink-50 text-ink-500" />
              <p className="text-xs text-ink-400">Email cannot be changed here.</p>
            </div>
            {error && <p className="text-sm text-red-600 bg-red-50 rounded-lg px-3 py-2">{error}</p>}
            <Button type="submit" disabled={saving} className="self-start bg-pocket-orange hover:bg-pocket-orange-dark text-white gap-2">
              {saving && <Loader2 className="w-4 h-4 animate-spin" />}Save changes
            </Button>
          </form>
        </div>
      </div>
    </PageTransition>
  );
}
HEREDOC

# ── app/(app)/settings/profile/loading.tsx ────────────────────────────────────
cat > "app/(app)/settings/profile/loading.tsx" << 'HEREDOC'
import { LoadingSparkPage } from "@/components/common/LoadingSpark";
export default function ProfileLoading() { return <LoadingSparkPage label="Loading profile…" />; }
HEREDOC

# ── app/(app)/settings/billing/page.tsx ──────────────────────────────────────
cat > "app/(app)/settings/billing/page.tsx" << 'HEREDOC'
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { PageTransition } from "@/components/common/PageTransition";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Zap, Check } from "lucide-react";
import { PLANS } from "@/lib/stripe/plans";
import { BillingSuccessNotifier } from "@/components/app/BillingSuccessNotifier";

export const metadata = { title: "Billing | Agency in Your Pocket" };

export default async function BillingPage() {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: profile } = await supabase.from("profiles").select("plan_tier, stripe_customer_id").eq("id", user.id).single();
  const currentTier = profile?.plan_tier ?? "free";

  return (
    <PageTransition>
      <BillingSuccessNotifier />
      <div className="max-w-lg">
        <h1 className="text-2xl font-bold text-ink-900 mb-1">Billing</h1>
        <p className="text-sm text-ink-500 mb-6">Manage your plan and subscription.</p>
        <div className="bg-white rounded-xl border border-ink-200 p-6 mb-6">
          <div className="flex items-center justify-between mb-1">
            <h2 className="text-sm font-semibold text-ink-700">Current plan</h2>
            <Badge className="capitalize bg-pocket-orange text-white">{currentTier}</Badge>
          </div>
          <p className="text-2xl font-bold text-ink-900">
            {currentTier === "free" ? "Free" : `$${PLANS[currentTier as keyof typeof PLANS]?.price ?? 0}/mo`}
          </p>
          {profile?.stripe_customer_id && (
            <form action="/api/portal" method="POST" className="mt-4">
              <Button type="submit" variant="outline">Manage subscription</Button>
            </form>
          )}
        </div>
        {currentTier === "free" && (
          <div className="flex flex-col gap-3">
            {Object.entries(PLANS).filter(([key]) => key !== "free").map(([key, plan]) => (
              <div key={key} className="bg-white rounded-xl border border-ink-200 p-5">
                <div className="flex items-start justify-between">
                  <div>
                    <h3 className="font-semibold text-ink-900 capitalize">{plan.name}</h3>
                    <p className="text-2xl font-bold text-ink-900 mt-0.5">${plan.price}<span className="text-sm font-normal text-ink-500">/mo</span></p>
                  </div>
                  <form action="/api/checkout" method="POST">
                    <input type="hidden" name="priceId" value={plan.priceId} />
                    <Button type="submit" size="sm" className="bg-pocket-orange hover:bg-pocket-orange-dark text-white gap-1">
                      <Zap className="w-3.5 h-3.5" />Upgrade
                    </Button>
                  </form>
                </div>
                <ul className="mt-3 flex flex-col gap-1">
                  {plan.features.slice(0, 3).map((f) => (
                    <li key={f} className="flex items-start gap-2 text-sm text-ink-600">
                      <Check className="w-3.5 h-3.5 text-emerald-500 shrink-0 mt-0.5" />{f}
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        )}
      </div>
    </PageTransition>
  );
}
HEREDOC

# ── app/(app)/settings/billing/loading.tsx ────────────────────────────────────
cat > "app/(app)/settings/billing/loading.tsx" << 'HEREDOC'
import { LoadingSparkPage } from "@/components/common/LoadingSpark";
export default function BillingLoading() { return <LoadingSparkPage label="Loading billing…" />; }
HEREDOC

# ── app/(app)/settings/integrations/page.tsx ─────────────────────────────────
cat > "app/(app)/settings/integrations/page.tsx" << 'HEREDOC'
import { PageTransition } from "@/components/common/PageTransition";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Camera, Globe } from "lucide-react";

export const metadata = { title: "Integrations | Agency in Your Pocket" };

const INTEGRATIONS = [
  { id: "instagram", name: "Instagram", description: "Connect your Instagram account to auto-post content and read insights.", icon: Camera, color: "text-pink-600", bg: "bg-pink-50", available: false },
  { id: "google-business", name: "Google Business Profile", description: "Sync your Google Business listing to manage posts, reviews, and Q&A.", icon: Globe, color: "text-blue-600", bg: "bg-blue-50", available: false },
];

export default function IntegrationsPage() {
  return (
    <PageTransition>
      <div className="max-w-lg">
        <h1 className="text-2xl font-bold text-ink-900 mb-1">Integrations</h1>
        <p className="text-sm text-ink-500 mb-6">Connect your social and business accounts.</p>
        <div className="flex flex-col gap-4">
          {INTEGRATIONS.map((integration) => {
            const Icon = integration.icon;
            return (
              <div key={integration.id} className="bg-white rounded-xl border border-ink-200 p-5">
                <div className="flex items-start gap-4">
                  <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${integration.bg}`}>
                    <Icon className={`w-5 h-5 ${integration.color}`} />
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center gap-2">
                      <h3 className="text-sm font-semibold text-ink-900">{integration.name}</h3>
                      {!integration.available && <Badge variant="secondary" className="text-[10px]">Coming soon</Badge>}
                    </div>
                    <p className="text-xs text-ink-500 mt-0.5">{integration.description}</p>
                  </div>
                  <Button size="sm" variant="outline" disabled={!integration.available}>Connect</Button>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </PageTransition>
  );
}
HEREDOC

# ── app/admin/layout.tsx ──────────────────────────────────────────────────────
cat > app/admin/layout.tsx << 'HEREDOC'
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import Link from "next/link";
import { Logo } from "@/components/brand/Logo";
import { LayoutDashboard, Users, Zap, Building2 } from "lucide-react";

const ADMIN_NAV = [
  { href: "/admin", label: "Overview", icon: LayoutDashboard },
  { href: "/admin/users", label: "Users", icon: Users },
  { href: "/admin/businesses", label: "Businesses", icon: Building2 },
  { href: "/admin/runs", label: "Workflow Runs", icon: Zap },
];

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: profile } = await supabase.from("profiles").select("is_admin").eq("id", user.id).single();
  if (!profile?.is_admin) redirect("/dashboard");

  return (
    <div className="flex min-h-screen bg-ink-100">
      <aside className="w-52 shrink-0 bg-ink-900 flex flex-col">
        <div className="px-4 py-4 border-b border-ink-700">
          <Logo size="sm" />
          <span className="text-xs text-ink-400 font-mono mt-1 block">admin</span>
        </div>
        <nav className="flex-1 px-2 py-3 flex flex-col gap-0.5">
          {ADMIN_NAV.map(({ href, label, icon: Icon }) => (
            <Link key={href} href={href} className="flex items-center gap-2.5 rounded-lg px-3 py-2 text-sm text-ink-300 hover:bg-ink-800 hover:text-white transition-colors">
              <Icon className="w-4 h-4 shrink-0" />{label}
            </Link>
          ))}
        </nav>
        <div className="px-4 py-3 border-t border-ink-700">
          <Link href="/dashboard" className="text-xs text-ink-500 hover:text-ink-300">← Back to app</Link>
        </div>
      </aside>
      <main className="flex-1 overflow-auto p-8">{children}</main>
    </div>
  );
}
HEREDOC

# ── app/admin/page.tsx ────────────────────────────────────────────────────────
cat > app/admin/page.tsx << 'HEREDOC'
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
HEREDOC

# ── app/admin/loading.tsx ─────────────────────────────────────────────────────
cat > app/admin/loading.tsx << 'HEREDOC'
import { LoadingSparkPage } from "@/components/common/LoadingSpark";
export default function AdminLoading() { return <LoadingSparkPage label="Loading admin data…" />; }
HEREDOC

# ── app/admin/users/page.tsx ──────────────────────────────────────────────────
cat > app/admin/users/page.tsx << 'HEREDOC'
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
HEREDOC

# ── app/admin/runs/page.tsx ───────────────────────────────────────────────────
cat > app/admin/runs/page.tsx << 'HEREDOC'
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
HEREDOC

# ── app/admin/businesses/page.tsx ─────────────────────────────────────────────
cat > app/admin/businesses/page.tsx << 'HEREDOC'
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
HEREDOC

echo "Part 4 done ✓"
