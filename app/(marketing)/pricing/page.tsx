import type { Metadata } from "next";
import { PricingTiers } from "@/components/marketing/PricingTiers";
import { FAQ } from "@/components/marketing/FAQ";
import { FinalCTA } from "@/components/marketing/FinalCTA";

export const metadata: Metadata = {
  title: "Pricing",
  description: "Pocket-size pricing for real agency work. Start free, upgrade when ready.",
};

export default function PricingPage() {
  return (
    <>
      <section className="py-24 bg-pocket-cream text-center">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
          <h1 className="text-5xl font-bold text-ink-900">
            Pocket-size pricing.{" "}
            <span className="text-pocket-orange" style={{ fontFamily: "var(--font-fraunces)", fontStyle: "italic" }}>
              Real agency work.
            </span>
          </h1>
          <p className="mt-6 text-lg text-ink-700">Start free. Upgrade when you&apos;re ready. Cancel anytime.</p>
        </div>
      </section>
      <section className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <PricingTiers />
          <div className="mt-8 max-w-2xl mx-auto text-center p-8 rounded-2xl bg-ink-900 text-white">
            <p className="text-lg font-semibold">Custom / DFY — from $500/mo</p>
            <p className="mt-2 text-ink-300 text-sm">Platform plus our team executing everything.</p>
            <a href="mailto:hello@agencyinyourpocket.com" className="inline-block mt-4 text-pocket-orange font-semibold hover:underline">
              Book a call →
            </a>
          </div>
        </div>
      </section>
      <FAQ />
      <FinalCTA />
    </>
  );
}
