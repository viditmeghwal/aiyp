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
