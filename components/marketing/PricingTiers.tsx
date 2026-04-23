import Link from "next/link";
import { Check } from "lucide-react";
import { Button } from "@/components/ui/button";

const tiers = [
  { name: "Free Audit", price: 0, billing: "once", description: "See what's broken in 90 seconds.", features: ["3-page teaser brand audit", "Brand score (out of 100)", "Top 5 issues identified", "Email delivery"], cta: "Get free audit →", href: "/free-audit", highlight: false },
  { name: "Starter", price: 29, billing: "month", description: "Like having a freelance marketer.", features: ["Monthly brand audit", "Brand starter kit", "20 posts + 5 reel scripts/mo", "1 vertical workspace", "Email support"], cta: "Start free →", href: "/signup?plan=starter", highlight: false },
  { name: "Growth", price: 59, billing: "month", description: "Like having an agency retainer.", badge: "Most Popular", features: ["Everything in Starter", "Weekly content refresh", "Google Business management", "Competitor tracking", "Monthly strategy call"], cta: "Start free →", href: "/signup?plan=growth", highlight: true },
  { name: "Agency", price: 129, billing: "month", description: "Your full agency, 1/5th the price.", features: ["Everything in Growth", "Auto-posting across platforms", "SEO implementation", "Priority support", "Quarterly deep-dive review"], cta: "Start free →", href: "/signup?plan=agency", highlight: false },
];

export function PricingTiers() {
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
      {tiers.map((tier) => (
        <div key={tier.name} className={`relative flex flex-col rounded-2xl p-6 border-2 transition-all ${tier.highlight ? "border-pocket-orange bg-pocket-orange shadow-lg shadow-pocket-orange/20" : "border-ink-200 bg-white hover:border-pocket-orange/40"}`}>
          {tier.badge && <span className="absolute -top-3 left-1/2 -translate-x-1/2 bg-ink-900 text-white text-xs font-semibold px-3 py-1 rounded-full">{tier.badge}</span>}
          <div className="mb-6">
            <p className={`font-semibold text-sm ${tier.highlight ? "text-white/80" : "text-ink-500"}`}>{tier.name}</p>
            <div className="mt-2 flex items-baseline gap-1">
              <span className={`text-4xl font-bold ${tier.highlight ? "text-white" : "text-ink-900"}`}>${tier.price}</span>
              {tier.billing === "month" && <span className={`text-sm ${tier.highlight ? "text-white/70" : "text-ink-500"}`}>/mo</span>}
            </div>
            <p className={`mt-2 text-sm ${tier.highlight ? "text-white/80" : "text-ink-700"}`}>{tier.description}</p>
          </div>
          <ul className="flex flex-col gap-2 mb-8 flex-1">
            {tier.features.map((feature) => (
              <li key={feature} className="flex items-start gap-2">
                <Check className={`h-4 w-4 mt-0.5 flex-shrink-0 ${tier.highlight ? "text-white" : "text-pocket-orange"}`} />
                <span className={`text-sm ${tier.highlight ? "text-white/90" : "text-ink-700"}`}>{feature}</span>
              </li>
            ))}
          </ul>
          <Button className={tier.highlight ? "bg-white text-pocket-orange hover:bg-white/90 font-semibold" : "bg-pocket-orange hover:bg-pocket-orange-dark text-white"} asChild>
            <Link href={tier.href}>{tier.cta}</Link>
          </Button>
        </div>
      ))}
    </div>
  );
}
