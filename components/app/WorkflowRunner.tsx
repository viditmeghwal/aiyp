"use client";
import * as React from "react";
import { useRouter } from "next/navigation";
import { AnimatePresence, motion } from "framer-motion";
import { CheckCircle2, Sparkles } from "lucide-react";
import { SuccessConfetti } from "@/components/common/SuccessConfetti";
import type { WorkflowDefinition } from "@/lib/workflows/registry";

const STEP_DURATION = 2200;

// eslint-disable-next-line @typescript-eslint/no-unused-vars
export function WorkflowRunner({ workflow, runId: _runId }: { workflow: WorkflowDefinition; runId: string }) {
  const router = useRouter();
  const [stepIndex, setStepIndex] = React.useState(0);
  const [complete, setComplete] = React.useState(false);
  const [confetti, setConfetti] = React.useState(false);
  const totalSteps = workflow.steps.length;
  const progress = Math.round(((stepIndex + 1) / totalSteps) * 100);

  React.useEffect(() => {
    if (complete) return;
    const interval = setInterval(() => {
      setStepIndex((prev) => {
        const next = prev + 1;
        if (next >= totalSteps) { clearInterval(interval); setComplete(true); setConfetti(true); setTimeout(() => router.push("/deliverables"), 2200); return prev; }
        return next;
      });
    }, STEP_DURATION);
    return () => clearInterval(interval);
  }, [complete, totalSteps, router]);

  return (
    <div className="min-h-[70vh] flex flex-col items-center justify-center px-4 text-center">
      <SuccessConfetti trigger={confetti} />
      <AnimatePresence mode="wait">
        {!complete ? (
          <motion.div key="running" initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }} className="flex flex-col items-center gap-6 max-w-sm w-full">
            <div className="relative w-20 h-20">
              <motion.div className="absolute inset-0 rounded-full bg-pocket-orange/20" animate={{ scale: [1, 1.6, 1] }} transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }} />
              <motion.div className="absolute inset-2 rounded-full bg-pocket-orange/40" animate={{ scale: [1, 1.3, 1] }} transition={{ duration: 2, repeat: Infinity, ease: "easeInOut", delay: 0.3 }} />
              <div className="absolute inset-4 rounded-full bg-pocket-orange flex items-center justify-center"><Sparkles className="w-5 h-5 text-white" /></div>
            </div>
            <div><h2 className="text-xl font-bold text-ink-900 mb-1">{workflow.name}</h2><p className="text-sm text-ink-500">Your AI agency is working on it…</p></div>
            <AnimatePresence mode="wait">
              <motion.p key={stepIndex} initial={{ opacity: 0, y: 6 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -6 }} transition={{ duration: 0.3 }} className="text-sm font-medium text-pocket-orange">{workflow.steps[stepIndex]}</motion.p>
            </AnimatePresence>
            <div className="w-full">
              <div className="flex justify-between text-xs text-ink-400 mb-1.5"><span>Step {stepIndex + 1} of {totalSteps}</span><span>{progress}%</span></div>
              <div className="h-2 bg-ink-200 rounded-full overflow-hidden">
                <motion.div className="h-full bg-pocket-orange rounded-full" animate={{ width: `${progress}%` }} transition={{ duration: 0.5, ease: "easeOut" }} />
              </div>
            </div>
            <div className="flex gap-1.5">
              {workflow.steps.map((_, i) => <motion.div key={i} className="w-1.5 h-1.5 rounded-full" animate={{ backgroundColor: i <= stepIndex ? "#F97316" : "#CBD5E1" }} transition={{ duration: 0.3 }} />)}
            </div>
          </motion.div>
        ) : (
          <motion.div key="complete" initial={{ opacity: 0, scale: 0.9 }} animate={{ opacity: 1, scale: 1 }} className="flex flex-col items-center gap-4">
            <div className="w-16 h-16 rounded-full bg-emerald-100 flex items-center justify-center"><CheckCircle2 className="w-8 h-8 text-emerald-600" /></div>
            <h2 className="text-xl font-bold text-ink-900">All done!</h2>
            <p className="text-sm text-ink-500">Your {workflow.name} is ready. Redirecting…</p>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
