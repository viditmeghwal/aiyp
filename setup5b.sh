cat > components/app/OnboardingWizard.tsx << 'HEREDOC'
"use client";
import * as React from "react";
import { AnimatePresence, motion } from "framer-motion";
import { ChevronRight, ChevronLeft, Loader2, Check } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { VERTICALS, type VerticalSlug } from "@/lib/verticals/config";
import { completeOnboarding } from "@/app/(app)/onboarding/actions";

const STEPS = ["Welcome", "Your vertical", "Your business", "Your goals", "Review"] as const;
type Step = 0 | 1 | 2 | 3 | 4;

const STAGE_OPTIONS = [
  { value: "prelaunch", label: "Pre-launch (planning stage)" },
  { value: "0-6mo", label: "Just launched (0–6 months)" },
  { value: "6-24mo", label: "Growing (6–24 months)" },
  { value: "2yr+", label: "Established (2+ years)" },
] as const;

const HOURS_OPTIONS = [
  { value: "<2", label: "< 2 hrs/week" },
  { value: "2-5", label: "2–5 hrs/week" },
  { value: "5+", label: "5+ hrs/week" },
] as const;

interface FormData {
  vertical: VerticalSlug | ""; name: string; location: string; website_url: string;
  instagram_handle: string; stage: "prelaunch" | "0-6mo" | "6-24mo" | "2yr+" | "";
  goals: string[]; hours_per_week: "<2" | "2-5" | "5+" | ""; biggest_frustration: string;
}

const initialData: FormData = { vertical: "", name: "", location: "", website_url: "", instagram_handle: "", stage: "", goals: [], hours_per_week: "", biggest_frustration: "" };

const slideVariants = {
  enter: (dir: number) => ({ x: dir > 0 ? 40 : -40, opacity: 0 }),
  center: { x: 0, opacity: 1 },
  exit: (dir: number) => ({ x: dir < 0 ? 40 : -40, opacity: 0 }),
};

export function OnboardingWizard({ userEmail }: { userEmail: string }) {
  const [step, setStep] = React.useState<Step>(0);
  const [direction, setDirection] = React.useState(1);
  const [data, setData] = React.useState<FormData>(initialData);
  const [submitting, setSubmitting] = React.useState(false);
  const [error, setError] = React.useState<string | null>(null);

  const vertical = data.vertical ? VERTICALS[data.vertical] : null;
  const goalOptions: string[] = vertical ? [...vertical.goals] : [];

  function goNext() { setDirection(1); setStep((s) => Math.min(s + 1, 4) as Step); }
  function goBack() { setDirection(-1); setStep((s) => Math.max(s - 1, 0) as Step); }
  function toggleGoal(goal: string) { setData((d) => ({ ...d, goals: d.goals.includes(goal) ? d.goals.filter((g) => g !== goal) : [...d.goals, goal] })); }

  async function handleSubmit() {
    setSubmitting(true); setError(null);
    try {
      const formData = new FormData();
      Object.entries(data).forEach(([k, v]) => formData.append(k, Array.isArray(v) ? JSON.stringify(v) : String(v)));
      await completeOnboarding(formData);
    } catch (err) { setError(err instanceof Error ? err.message : "Something went wrong."); setSubmitting(false); }
  }

  const canAdvance = () => {
    if (step === 0) return true;
    if (step === 1) return data.vertical !== "";
    if (step === 2) return data.name.trim() !== "" && data.stage !== "";
    if (step === 3) return data.goals.length > 0 && data.hours_per_week !== "";
    return true;
  };

  return (
    <div className="w-full max-w-lg">
      <div className="flex gap-1.5 mb-8">
        {STEPS.map((_, i) => <div key={i} className={`h-1 flex-1 rounded-full transition-colors duration-300 ${i <= step ? "bg-pocket-orange" : "bg-ink-200"}`} />)}
      </div>
      <AnimatePresence mode="wait" custom={direction}>
        <motion.div key={step} custom={direction} variants={slideVariants} initial="enter" animate="center" exit="exit" transition={{ duration: 0.22, ease: "easeOut" }}>
          {step === 0 && <StepWelcome userEmail={userEmail} />}
          {step === 1 && <StepVertical selected={data.vertical} onSelect={(v) => setData((d) => ({ ...d, vertical: v }))} />}
          {step === 2 && <StepBusiness data={data} onChange={(patch) => setData((d) => ({ ...d, ...patch }))} />}
          {step === 3 && <StepGoals goalOptions={goalOptions} selectedGoals={data.goals} hoursPerWeek={data.hours_per_week} biggestFrustration={data.biggest_frustration} onToggleGoal={toggleGoal} onHoursChange={(v) => setData((d) => ({ ...d, hours_per_week: v }))} onFrustrationChange={(v) => setData((d) => ({ ...d, biggest_frustration: v }))} />}
          {step === 4 && <StepReview data={data} />}
        </motion.div>
      </AnimatePresence>
      {error && <p className="mt-4 text-sm text-red-600 bg-red-50 rounded-lg px-3 py-2">{error}</p>}
      <div className="flex justify-between mt-8">
        {step > 0 ? <Button variant="ghost" onClick={goBack} className="gap-1.5 text-ink-500"><ChevronLeft className="w-4 h-4" />Back</Button> : <div />}
        {step < 4 ? (
          <Button onClick={goNext} disabled={!canAdvance()} className="gap-1.5 bg-pocket-orange hover:bg-pocket-orange-dark text-white">
            {step === 0 ? "Let's go" : "Continue"}<ChevronRight className="w-4 h-4" />
          </Button>
        ) : (
          <Button onClick={handleSubmit} disabled={submitting} className="gap-2 bg-pocket-orange hover:bg-pocket-orange-dark text-white px-6">
            {submitting && <Loader2 className="w-4 h-4 animate-spin" />}Generate my growth plan
          </Button>
        )}
      </div>
    </div>
  );
}

function StepWelcome({ userEmail }: { userEmail: string }) {
  return (
    <div className="text-center py-4">
      <div className="text-6xl mb-6">🚀</div>
      <h1 className="text-2xl font-bold text-ink-900 mb-3">Welcome to Agency <span style={{ fontFamily: "var(--font-fraunces)", fontStyle: "italic" }} className="text-pocket-orange">in Your Pocket</span></h1>
      <p className="text-ink-500 text-sm mb-2">We&apos;ll set up your personalised AI growth plan in under 2 minutes.</p>
      <p className="text-xs text-ink-400">{userEmail}</p>
    </div>
  );
}

function StepVertical({ selected, onSelect }: { selected: VerticalSlug | ""; onSelect: (v: VerticalSlug) => void }) {
  return (
    <div>
      <h2 className="text-xl font-bold text-ink-900 mb-1">What type of business are you building?</h2>
      <p className="text-sm text-ink-500 mb-6">Pick the one that fits best.</p>
      <div className="grid grid-cols-2 gap-3">
        {Object.values(VERTICALS).map((v) => {
          const isSelected = selected === v.id;
          return (
            <button key={v.id} onClick={() => onSelect(v.id as VerticalSlug)} className={`flex flex-col items-start gap-1 rounded-xl border-2 p-4 text-left transition-all ${isSelected ? "border-pocket-orange bg-pocket-peach" : "border-ink-200 bg-white hover:border-ink-400"}`}>
              <span className="text-2xl">{v.emoji}</span>
              <span className="text-sm font-semibold text-ink-900">{v.label}</span>
              {isSelected && <Check className="w-3.5 h-3.5 text-pocket-orange mt-0.5" />}
            </button>
          );
        })}
      </div>
    </div>
  );
}

function StepBusiness({ data, onChange }: { data: FormData; onChange: (patch: Partial<FormData>) => void }) {
  return (
    <div>
      <h2 className="text-xl font-bold text-ink-900 mb-1">Tell us about your business</h2>
      <p className="text-sm text-ink-500 mb-6">Just the basics — you can update this later.</p>
      <div className="flex flex-col gap-4">
        <div className="flex flex-col gap-1.5"><Label htmlFor="biz-name">Business name *</Label><Input id="biz-name" value={data.name} onChange={(e) => onChange({ name: e.target.value })} placeholder="e.g. The Copper Spoon" /></div>
        <div className="flex flex-col gap-1.5"><Label htmlFor="biz-location">City / location</Label><Input id="biz-location" value={data.location} onChange={(e) => onChange({ location: e.target.value })} placeholder="e.g. Mumbai, India" /></div>
        <div className="flex flex-col gap-1.5"><Label htmlFor="biz-website">Website URL</Label><Input id="biz-website" value={data.website_url} onChange={(e) => onChange({ website_url: e.target.value })} placeholder="https://yoursite.com" type="url" /></div>
        <div className="flex flex-col gap-1.5"><Label htmlFor="biz-ig">Instagram handle</Label><Input id="biz-ig" value={data.instagram_handle} onChange={(e) => onChange({ instagram_handle: e.target.value })} placeholder="@yourbrand" /></div>
        <div className="flex flex-col gap-1.5">
          <Label>Where are you right now? *</Label>
          <div className="grid grid-cols-2 gap-2">
            {STAGE_OPTIONS.map((opt) => (
              <button key={opt.value} onClick={() => onChange({ stage: opt.value })} className={`rounded-lg border-2 p-3 text-left text-sm transition-all ${data.stage === opt.value ? "border-pocket-orange bg-pocket-peach text-pocket-orange font-medium" : "border-ink-200 bg-white text-ink-700 hover:border-ink-400"}`}>{opt.label}</button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

function StepGoals({ goalOptions, selectedGoals, hoursPerWeek, biggestFrustration, onToggleGoal, onHoursChange, onFrustrationChange }: { goalOptions: string[]; selectedGoals: string[]; hoursPerWeek: string; biggestFrustration: string; onToggleGoal: (g: string) => void; onHoursChange: (v: "<2" | "2-5" | "5+") => void; onFrustrationChange: (v: string) => void }) {
  return (
    <div>
      <h2 className="text-xl font-bold text-ink-900 mb-1">What are your goals?</h2>
      <p className="text-sm text-ink-500 mb-6">Select everything that applies.</p>
      <div className="flex flex-wrap gap-2 mb-6">
        {goalOptions.map((goal) => {
          const selected = selectedGoals.includes(goal);
          return <button key={goal} onClick={() => onToggleGoal(goal)} className={`rounded-full border px-3 py-1.5 text-sm transition-all ${selected ? "border-pocket-orange bg-pocket-peach text-pocket-orange font-medium" : "border-ink-200 bg-white text-ink-700 hover:border-ink-400"}`}>{selected && <Check className="inline w-3 h-3 mr-1" />}{goal}</button>;
        })}
      </div>
      <div className="flex flex-col gap-1.5 mb-4">
        <Label>How many hours/week can you dedicate? *</Label>
        <div className="flex gap-2">
          {HOURS_OPTIONS.map((opt) => <button key={opt.value} onClick={() => onHoursChange(opt.value)} className={`flex-1 rounded-lg border-2 py-2 text-sm transition-all ${hoursPerWeek === opt.value ? "border-pocket-orange bg-pocket-peach text-pocket-orange font-medium" : "border-ink-200 bg-white text-ink-700 hover:border-ink-400"}`}>{opt.label}</button>)}
        </div>
      </div>
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="frustration">What&apos;s your biggest marketing challenge?</Label>
        <Textarea id="frustration" value={biggestFrustration} onChange={(e) => onFrustrationChange(e.target.value)} placeholder="e.g. I don't know where to start..." rows={3} />
      </div>
    </div>
  );
}

function StepReview({ data }: { data: FormData }) {
  const vertical = data.vertical ? VERTICALS[data.vertical] : null;
  return (
    <div>
      <h2 className="text-xl font-bold text-ink-900 mb-1">Ready to build your plan?</h2>
      <p className="text-sm text-ink-500 mb-6">We&apos;ll generate a personalised growth plan for your business.</p>
      <div className="rounded-xl border border-ink-200 bg-white divide-y divide-ink-100">
        {[
          ["Business", data.name || "—"],
          vertical ? ["Vertical", `${vertical.emoji} ${vertical.label}`] : null,
          data.location ? ["Location", data.location] : null,
          data.stage ? ["Stage", STAGE_OPTIONS.find((s) => s.value === data.stage)?.label ?? data.stage] : null,
          ["Goals", `${data.goals.length} selected`],
          data.hours_per_week ? ["Time available", HOURS_OPTIONS.find((h) => h.value === data.hours_per_week)?.label ?? data.hours_per_week] : null,
        ].filter(Boolean).map(([label, value]) => (
          <div key={label as string} className="flex justify-between px-4 py-3">
            <span className="text-sm text-ink-500">{label}</span>
            <span className="text-sm font-semibold text-ink-900">{value}</span>
          </div>
        ))}
      </div>
      <p className="mt-4 text-xs text-ink-400 text-center">You&apos;ll get 15 tasks across your first 30 days, personalised for {vertical?.label ?? "your vertical"}.</p>
    </div>
  );
}
HEREDOC

echo "Part 5b done ✓"


