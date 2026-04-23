import { Suspense } from "react";
import { AnalyzingScreen } from "@/components/audit/AnalyzingScreen";

export default function AnalyzingPage() {
  return (
    <Suspense fallback={<div className="min-h-screen bg-pocket-cream flex items-center justify-center"><div className="w-8 h-8 rounded-full border-2 border-pocket-orange border-t-transparent animate-spin" /></div>}>
      <AnalyzingScreen />
    </Suspense>
  );
}
