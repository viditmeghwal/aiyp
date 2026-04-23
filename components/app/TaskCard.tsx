"use client";
import { useRouter } from "next/navigation";
import { ArrowRight, CheckCircle2, Eye } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { updateTaskStatus } from "@/app/(app)/dashboard/actions";

type TaskStatus = "not_started" | "in_progress" | "review" | "complete";
interface TaskCardProps { id: string; title: string; description: string | null; workflow_ref: string | null; phase: string | null; status: TaskStatus; }

const phaseLabels: Record<string, string> = { "week-1": "Week 1", "week-2": "Week 2", "weeks-3-4": "Weeks 3–4", "month-2": "Month 2", "month-3": "Month 3", "ongoing": "Ongoing" };

export function TaskCard({ id, title, description, workflow_ref, phase, status }: TaskCardProps) {
  const router = useRouter();
  async function handleStart() {
    if (workflow_ref) { router.push(`/workflow/${workflow_ref}?taskId=${id}`); }
    else { await updateTaskStatus(id, "in_progress"); router.refresh(); }
  }
  async function handleComplete() { await updateTaskStatus(id, "complete"); router.refresh(); }

  return (
    <div className="bg-white rounded-xl border border-ink-200 p-4 flex flex-col gap-3 hover:shadow-sm transition-shadow">
      <div className="flex items-start justify-between gap-2">
        <h3 className="text-sm font-semibold text-ink-900 leading-snug">{title}</h3>
        {phase && <span className="shrink-0 text-[10px] font-medium text-ink-400 bg-ink-100 rounded px-1.5 py-0.5">{phaseLabels[phase] ?? phase}</span>}
      </div>
      {description && <p className="text-xs text-ink-500 leading-relaxed line-clamp-2">{description}</p>}
      <div className="flex items-center justify-between mt-auto pt-1">
        {workflow_ref ? <Badge variant="secondary" className="text-[10px] gap-1"><span className="w-1.5 h-1.5 rounded-full bg-pocket-orange inline-block" />AI workflow</Badge> : <div />}
        {status === "not_started" && <Button size="sm" onClick={handleStart} className="h-7 text-xs gap-1 bg-pocket-orange hover:bg-pocket-orange-dark text-white">Start<ArrowRight className="w-3 h-3" /></Button>}
        {status === "in_progress" && <Button size="sm" variant="outline" onClick={handleComplete} className="h-7 text-xs gap-1"><CheckCircle2 className="w-3 h-3" />Done</Button>}
        {status === "review" && <Button size="sm" variant="outline" onClick={handleComplete} className="h-7 text-xs gap-1"><Eye className="w-3 h-3" />Mark complete</Button>}
        {status === "complete" && <span className="flex items-center gap-1 text-xs text-emerald-600 font-medium"><CheckCircle2 className="w-3.5 h-3.5" />Done</span>}
      </div>
    </div>
  );
}
