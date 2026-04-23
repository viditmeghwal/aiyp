import Link from "next/link";
import { CheckCircle, XCircle, Lock, ArrowRight } from "lucide-react";
import { Button } from "@/components/ui/button";

interface AuditResult {
  businessName: string; vertical: string; overallScore: number;
  scores: { brand: number; content: number; seo: number; social: number };
  working: Array<{ area: string; observation: string }>;
  broken: Array<{ area: string; issue: string; severity: "high" | "medium" }>;
}

export function TeaserResult({ result }: { result: AuditResult }) {
  return (
    <div className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
      <div className="text-center mb-12">
        <div className="inline-flex flex-col items-center justify-center w-32 h-32 rounded-full border-4 border-pocket-orange bg-white shadow-lg mb-4">
          <span className="text-4xl font-bold text-pocket-orange">{result.overallScore}</span>
          <span className="text-xs text-ink-500">/100</span>
        </div>
        <h1 className="text-2xl font-bold text-ink-900 mt-4">{result.businessName}&apos;s Brand Score</h1>
        <p className="text-ink-500 mt-2">Here&apos;s what we found in 90 seconds.</p>
      </div>
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-10">
        {[{ label: "Brand", score: result.scores.brand }, { label: "Content", score: result.scores.content }, { label: "SEO", score: result.scores.seo }, { label: "Social", score: result.scores.social }].map((cat) => (
          <div key={cat.label} className="text-center p-4 bg-white rounded-xl border border-ink-200">
            <p className="text-2xl font-bold text-ink-900">{cat.score}</p>
            <p className="text-xs text-ink-500 mt-1">{cat.label}</p>
          </div>
        ))}
      </div>
      <div className="mb-8">
        <h2 className="text-lg font-semibold text-ink-900 mb-4">What&apos;s working ✅</h2>
        <div className="flex flex-col gap-3">
          {result.working.map((item, i) => (
            <div key={i} className="flex items-start gap-3 p-4 bg-green-50 rounded-xl border border-green-200">
              <CheckCircle className="h-5 w-5 text-green-600 mt-0.5 flex-shrink-0" />
              <div><span className="text-xs font-semibold text-green-700 uppercase tracking-wide">{item.area}</span><p className="text-sm text-ink-700 mt-0.5">{item.observation}</p></div>
            </div>
          ))}
        </div>
      </div>
      <div className="mb-8">
        <h2 className="text-lg font-semibold text-ink-900 mb-4">What needs fixing 🔴</h2>
        <div className="flex flex-col gap-3">
          {result.broken.slice(0, 2).map((item, i) => (
            <div key={i} className="flex items-start gap-3 p-4 bg-red-50 rounded-xl border border-red-200">
              <XCircle className="h-5 w-5 text-red-500 mt-0.5 flex-shrink-0" />
              <div>
                <div className="flex items-center gap-2">
                  <span className="text-xs font-semibold text-red-700 uppercase tracking-wide">{item.area}</span>
                  {item.severity === "high" && <span className="text-xs bg-red-600 text-white px-1.5 py-0.5 rounded">High priority</span>}
                </div>
                <p className="text-sm text-ink-700 mt-0.5">{item.issue}</p>
              </div>
            </div>
          ))}
          <div className="relative">
            <div className="flex flex-col gap-3 select-none pointer-events-none">
              {result.broken.slice(2).map((item, i) => (
                <div key={i} className="flex items-start gap-3 p-4 bg-red-50 rounded-xl border border-red-200 blur-sm">
                  <XCircle className="h-5 w-5 text-red-500 mt-0.5 flex-shrink-0" />
                  <div><span className="text-xs font-semibold text-red-700 uppercase tracking-wide">{item.area}</span><p className="text-sm text-ink-700 mt-0.5">{item.issue}</p></div>
                </div>
              ))}
            </div>
            <div className="absolute inset-0 flex flex-col items-center justify-center bg-gradient-to-b from-transparent to-pocket-cream/80">
              <Lock className="h-6 w-6 text-ink-500 mb-2" />
              <p className="text-sm font-medium text-ink-700">+{result.broken.length - 2} more issues unlocked with free trial</p>
            </div>
          </div>
        </div>
      </div>
      <div className="bg-pocket-orange rounded-2xl p-8 text-white text-center">
        <p className="text-xl font-bold mb-2">See all {result.broken.length}+ issues + your personalized fix plan</p>
        <p className="text-white/80 text-sm mb-6">Start a free 7-day trial. No card required.</p>
        <Button className="bg-white text-pocket-orange hover:bg-white/90 font-semibold px-8 h-12 gap-2" asChild>
          <Link href="/signup">Unlock full audit — Start free →<ArrowRight className="h-4 w-4" /></Link>
        </Button>
      </div>
    </div>
  );
}
