import Link from "next/link";
import { Button } from "@/components/ui/button";

const tiers = [
  { name: "Starter", price: "$29", highlight: false },
  { name: "Growth", price: "$59", highlight: true },
  { name: "Agency", price: "$129", highlight: false },
];

export default function PricingPreview() {
  return (
    <section className="py-24 bg-white">
      <div className="mx-auto max-w-5xl px-6 text-center">
        <h2 className="font-display text-3xl font-bold italic text-ink-900 md:text-4xl">
          Simple, transparent pricing
        </h2>
        <p className="mt-4 text-ink-500">Start free. Upgrade when you&apos;re ready.</p>
        <div className="mt-12 grid gap-6 md:grid-cols-3">
          {tiers.map((tier) => (
            <div
              key={tier.name}
              className={`rounded-2xl border p-8 transition-transform ${
                tier.highlight
                  ? "border-pocket-orange bg-pocket-orange text-white shadow-xl scale-105"
                  : "border-ink-300 bg-pocket-cream"
              }`}
            >
              <p className="text-sm font-semibold uppercase tracking-widest opacity-70">
                {tier.name}
              </p>
              <p className="mt-2 text-4xl font-bold">
                {tier.price}
                <span className="text-base font-normal opacity-60">/mo</span>
              </p>
            </div>
          ))}
        </div>
        <div className="mt-10">
          <Button asChild size="lg" variant="default">
            <Link href="/pricing">See full pricing →</Link>
          </Button>
        </div>
      </div>
    </section>
  );
}
