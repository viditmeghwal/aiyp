"use client";
import * as React from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import { Progress } from "@/components/ui/progress";

const messages = [
  { text: "✨ Checking your website speed..." },
  { text: "🔍 Analyzing your Instagram grid..." },
  { text: "📍 Looking at your Google presence..." },
  { text: "🧠 Claude is reading your brand..." },
  { text: "🎨 Spotting design gaps..." },
  { text: "✍️ Writing your audit..." },
  { text: "🎉 Almost ready..." },
];
const STEP_DURATION = 12000;

export function AnalyzingScreen() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const auditId = searchParams.get("id");
  const [currentStep, setCurrentStep] = React.useState(0);
  const [progress, setProgress] = React.useState(0);
  const [done, setDone] = React.useState(false);

  React.useEffect(() => {
    const totalDuration = STEP_DURATION * messages.length;
    const interval = setInterval(() => { setProgress((p) => Math.min(p + (100 / (totalDuration / 100)), 99)); }, 100);
    return () => clearInterval(interval);
  }, []);

  React.useEffect(() => {
    if (currentStep >= messages.length - 1) return;
    const t = setTimeout(() => setCurrentStep((s) => s + 1), STEP_DURATION);
    return () => clearTimeout(t);
  }, [currentStep]);

  React.useEffect(() => {
    if (!auditId || done) return;
    const poll = setInterval(async () => {
      try {
        const res = await fetch(`/api/free-audit/${auditId}`);
        if (res.ok) {
          const data = (await res.json()) as { status: string };
          if (data.status === "complete") { setDone(true); setProgress(100); clearInterval(poll); setTimeout(() => router.push(`/free-audit/result/${auditId}`), 800); }
        }
      } catch { /* ignore */ }
    }, 2000);
    return () => clearInterval(poll);
  }, [auditId, done, router]);

  return (
    <div className="min-h-screen bg-pocket-cream flex flex-col items-center justify-center px-4">
      <motion.div className="w-20 h-20 rounded-2xl bg-pocket-orange flex items-center justify-center mb-12" animate={{ scale: [1, 1.05, 1] }} transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}>
        <span className="text-4xl">📦</span>
      </motion.div>
      <div className="h-12 flex items-center justify-center mb-8">
        <AnimatePresence mode="wait">
          <motion.p key={currentStep} className="text-xl md:text-2xl font-semibold text-ink-900 text-center" initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -8 }} transition={{ duration: 0.4 }}>
            {messages[currentStep].text}
          </motion.p>
        </AnimatePresence>
      </div>
      <div className="w-full max-w-md">
        <Progress value={progress} className="h-2" />
        <p className="mt-3 text-sm text-ink-500 text-center">{done ? "Done! Taking you to your results..." : "Analyzing your brand…"}</p>
      </div>
      <div className="flex gap-2 mt-8">
        {messages.map((_, i) => <div key={i} className={`w-2 h-2 rounded-full transition-all duration-300 ${i <= currentStep ? "bg-pocket-orange" : "bg-ink-300"}`} />)}
      </div>
    </div>
  );
}
