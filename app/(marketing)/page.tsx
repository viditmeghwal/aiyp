import { Hero } from "@/components/marketing/Hero";
import { HowItWorks } from "@/components/marketing/HowItWorks";
import { VerticalGrid } from "@/components/marketing/VerticalGrid";
import { PoweredByBar } from "@/components/brand/PoweredByBar";
import { PricingTiers } from "@/components/marketing/PricingTiers";
import { FAQ } from "@/components/marketing/FAQ";
import { FinalCTA } from "@/components/marketing/FinalCTA";

function ProblemSection() {
  return (
    <section className="py-20 bg-pocket-peach">
      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <h2 className="text-3xl md:text-4xl font-bold text-ink-900 mb-8">
          Real agencies cost too much. Tools are too many.
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 text-left max-w-4xl mx-auto">
          <p className="text-ink-700 text-base leading-relaxed">
            You know you need branding, content, and SEO. But real agencies start at $2,000/month.
            Learning Canva + Buffer + Ahrefs + ChatGPT takes months you don&apos;t have.
          </p>
          <p className="text-ink-700 text-base leading-relaxed">
            Generic AI tools give you output that sounds like everyone else. So you keep putting it off.{" "}
            <strong className="text-ink-900">We fixed that.</strong>
          </p>
        </div>
      </div>
    </section>
  );
}

function PricingPreview() {
  return (
    <section className="py-24 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-4xl font-bold text-ink-900">Pocket-size pricing. Real agency work.</h2>
          <p className="mt-4 text-lg text-ink-700">Start free. Upgrade when you&apos;re ready. Cancel anytime.</p>
        </div>
        <PricingTiers />
      </div>
    </section>
  );
}

export default function HomePage() {
  return (
    <>
      <Hero />
      <PoweredByBar />
      <HowItWorks />
      <ProblemSection />
      <VerticalGrid />
      <PricingPreview />
      <FAQ />
      <FinalCTA />
    </>
  );
}
