import { inngest } from "@/lib/integrations/inngest/client";
import { createServiceRoleClient } from "@/lib/supabase/server";

export const brandStarterKitWorkflow = inngest.createFunction(
  { id: "brand-starter-kit", name: "Brand Starter Kit Workflow" },
  { event: "workflow/brand-starter-kit.started" },
  async ({ event, step }) => {
    const { runId } = event.data as { runId: string };
    const supabase = createServiceRoleClient();

    await step.run("mark-running", async () => {
      await supabase
        .from("workflow_runs")
        .update({ status: "running", started_at: new Date().toISOString() })
        .eq("id", runId);
    });

    await step.sleep("processing", "15s");

    await step.run("create-deliverable", async () => {
      const { data: run } = await supabase
        .from("workflow_runs")
        .select("user_id, business_id")
        .eq("id", runId)
        .single();
      if (!run) return;

      await supabase.from("deliverables").insert({
        user_id: run.user_id,
        business_id: run.business_id,
        workflow_run_id: runId,
        title: "Brand Starter Kit",
        type: "document",
        category: "Brand Identity",
        content: {
          placeholder: true,
          message: "Colours, fonts, voice guide, and logo concepts coming soon",
        },
      });

      await supabase
        .from("workflow_runs")
        .update({ status: "succeeded", completed_at: new Date().toISOString() })
        .eq("id", runId);
    });
  }
);
