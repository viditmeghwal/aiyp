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
