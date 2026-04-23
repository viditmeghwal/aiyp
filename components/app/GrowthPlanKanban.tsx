import { TaskCard } from "./TaskCard";

type TaskStatus = "not_started" | "in_progress" | "review" | "complete";
interface Task { id: string; title: string; description: string | null; workflow_ref: string | null; phase: string | null; status: TaskStatus; }

const COLUMNS: { status: TaskStatus; label: string; color: string }[] = [
  { status: "not_started", label: "To do", color: "bg-ink-200" },
  { status: "in_progress", label: "In progress", color: "bg-blue-400" },
  { status: "review", label: "Review", color: "bg-amber-400" },
  { status: "complete", label: "Complete", color: "bg-emerald-400" },
];

export function GrowthPlanKanban({ tasks }: { tasks: Task[] }) {
  const byStatus = (s: TaskStatus) => tasks.filter((t) => t.status === s);
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 overflow-x-auto pb-2">
      {COLUMNS.map(({ status, label, color }) => {
        const columnTasks = byStatus(status);
        return (
          <div key={status} className="min-w-[220px]">
            <div className="flex items-center gap-2 mb-3">
              <span className={`w-2 h-2 rounded-full ${color}`} />
              <span className="text-sm font-semibold text-ink-700">{label}</span>
              <span className="ml-auto text-xs text-ink-400 bg-ink-100 rounded-full px-2 py-0.5">{columnTasks.length}</span>
            </div>
            <div className="flex flex-col gap-3">
              {columnTasks.map((task) => <TaskCard key={task.id} {...task} />)}
              {columnTasks.length === 0 && <div className="rounded-xl border-2 border-dashed border-ink-200 px-4 py-6 text-center"><p className="text-xs text-ink-400">Nothing here yet</p></div>}
            </div>
          </div>
        );
      })}
    </div>
  );
}
