import Link from "next/link";
import { ArrowRight } from "lucide-react";
import { Button } from "@/components/ui/button";

export function FinalCTA() {
  return (
    <section className="py-24 bg-pocket-orange">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <h2 className="text-4xl md:text-5xl font-bold text-white">Your brand. Built tonight.</h2>
        <p className="mt-6 text-lg text-white/80 max-w-xl mx-auto">Get your free audit. No card. No commitment. See what we&apos;d do.</p>
        <div className="mt-10">
          <Button size="lg" className="bg-white text-pocket-orange hover:bg-white/90 px-10 h-14 text-base font-semibold gap-2" asChild>
            <Link href="/free-audit">Start free <ArrowRight className="h-5 w-5" /></Link>
          </Button>
        </div>
        <p className="mt-4 text-sm text-white/60">Takes 3 minutes. No credit card required.</p>
      </div>
    </section>
  );
}
