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
