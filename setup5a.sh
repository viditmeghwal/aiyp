mkdir -p components/brand components/common components/providers \
  components/marketing components/audit \
  components/app components/ui

# ── components/brand/Logo.tsx ─────────────────────────────────────────────────
cat > components/brand/Logo.tsx << 'HEREDOC'
import { cn } from "@/lib/utils";

const sizeMap = { sm: "text-lg", md: "text-2xl", lg: "text-4xl" } as const;

interface LogoProps { size?: keyof typeof sizeMap; withMark?: boolean; className?: string; }

export function Logo({ size = "md", withMark = true, className }: LogoProps) {
  return (
    <span className={cn("inline-flex items-center gap-2", className)}>
      {withMark && (
        <span className="inline-block rounded-md bg-pocket-orange flex-shrink-0"
          style={{ width: size === "lg" ? 24 : size === "md" ? 18 : 14, height: size === "lg" ? 24 : size === "md" ? 18 : 14 }}
          aria-hidden="true" />
      )}
      <span className={cn("font-bold tracking-tight", sizeMap[size])}>
        <span className="text-ink-900 font-sans">Agency in </span>
        <span className="text-pocket-orange" style={{ fontFamily: "var(--font-fraunces)", fontStyle: "italic" }}>Your Pocket</span>
      </span>
    </span>
  );
}
HEREDOC

# ── components/brand/PoweredByBar.tsx ────────────────────────────────────────
cat > components/brand/PoweredByBar.tsx << 'HEREDOC'
const partners = ["Meta", "Google", "Anthropic", "OpenAI", "Ideogram", "Stripe"];

export function PoweredByBar() {
  return (
    <section className="py-12 bg-white border-y border-ink-100">
      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <p className="text-xs text-ink-500 font-semibold uppercase tracking-widest mb-6">Powered by the tools the world&apos;s best agencies use</p>
        <div className="flex flex-wrap items-center justify-center gap-x-8 gap-y-3">
          {partners.map((name, i) => (
            <span key={name} className="flex items-center gap-3">
              <span className="font-mono text-base font-semibold text-ink-500 hover:text-ink-700 transition-colors cursor-default">{name}</span>
              {i < partners.length - 1 && <span className="text-ink-300 hidden sm:inline" aria-hidden>·</span>}
            </span>
          ))}
        </div>
      </div>
    </section>
  );
}
HEREDOC

# ── components/common/PageTransition.tsx ─────────────────────────────────────
cat > components/common/PageTransition.tsx << 'HEREDOC'
"use client";
import { motion } from "framer-motion";
export function PageTransition({ children }: { children: React.ReactNode }) {
  return (
    <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.25, ease: "easeOut" }}>
      {children}
    </motion.div>
  );
}
HEREDOC

# ── components/common/LoadingSpark.tsx ────────────────────────────────────────
cat > components/common/LoadingSpark.tsx << 'HEREDOC'
"use client";
import { motion } from "framer-motion";

const sizes = { sm: "w-4 h-4", md: "w-8 h-8", lg: "w-12 h-12" };

export function LoadingSpark({ size = "md", label }: { size?: "sm" | "md" | "lg"; label?: string }) {
  return (
    <div className="flex flex-col items-center gap-3">
      <motion.div className={`${sizes[size]} rounded-full bg-pocket-orange`}
        animate={{ scale: [1, 1.3, 1], opacity: [1, 0.6, 1] }}
        transition={{ duration: 1.2, repeat: Infinity, ease: "easeInOut" }} />
      {label && <p className="text-sm text-ink-500">{label}</p>}
    </div>
  );
}

export function LoadingSparkPage({ label = "Loading…" }: { label?: string }) {
  return (
    <div className="flex items-center justify-center min-h-[40vh]">
      <LoadingSpark size="lg" label={label} />
    </div>
  );
}
HEREDOC

# ── components/common/EmptyState.tsx ─────────────────────────────────────────
cat > components/common/EmptyState.tsx << 'HEREDOC'
import { LucideIcon } from "lucide-react";
import { Button } from "@/components/ui/button";
import Link from "next/link";

interface EmptyStateProps {
  icon: LucideIcon;
  title: string;
  description: string;
  action?: { label: string; href?: string; onClick?: () => void };
}

export function EmptyState({ icon: Icon, title, description, action }: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center justify-center py-16 px-4 text-center">
      <div className="w-14 h-14 rounded-2xl bg-ink-100 flex items-center justify-center mb-4">
        <Icon className="w-6 h-6 text-ink-500" />
      </div>
      <h3 className="text-lg font-semibold text-ink-900 mb-1">{title}</h3>
      <p className="text-sm text-ink-500 max-w-xs mb-6">{description}</p>
      {action && (action.href ? (
        <Button asChild className="bg-pocket-orange hover:bg-pocket-orange-dark text-white">
          <Link href={action.href}>{action.label}</Link>
        </Button>
      ) : (
        <Button onClick={action.onClick} className="bg-pocket-orange hover:bg-pocket-orange-dark text-white">{action.label}</Button>
      ))}
    </div>
  );
}
HEREDOC

# ── components/common/SuccessConfetti.tsx ────────────────────────────────────
cat > components/common/SuccessConfetti.tsx << 'HEREDOC'
"use client";
import { useEffect } from "react";
import confetti from "canvas-confetti";

export function SuccessConfetti({ trigger = true }: { trigger?: boolean }) {
  useEffect(() => {
    if (!trigger) return;
    confetti({ particleCount: 120, spread: 70, origin: { y: 0.6 }, colors: ["#F97316", "#FFE4D6", "#C2410C", "#FFF8F1", "#0F172A"] });
  }, [trigger]);
  return null;
}
HEREDOC

# ── components/providers/PostHogProvider.tsx ─────────────────────────────────
cat > components/providers/PostHogProvider.tsx << 'HEREDOC'
"use client";
import posthog from "posthog-js";
import { PostHogProvider as PHProvider } from "posthog-js/react";
import { useEffect } from "react";

export function PostHogProvider({ children }: { children: React.ReactNode }) {
  useEffect(() => {
    const key = process.env.NEXT_PUBLIC_POSTHOG_KEY;
    if (!key) return;
    posthog.init(key, { api_host: process.env.NEXT_PUBLIC_POSTHOG_HOST ?? "https://app.posthog.com", capture_pageview: false, capture_pageleave: true });
  }, []);
  return <PHProvider client={posthog}>{children}</PHProvider>;
}
HEREDOC

# ── components/marketing/Nav.tsx ─────────────────────────────────────────────
cat > components/marketing/Nav.tsx << 'HEREDOC'
"use client";
import * as React from "react";
import Link from "next/link";
import { Menu } from "lucide-react";
import { Logo } from "@/components/brand/Logo";
import { Button } from "@/components/ui/button";
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet";
import { VERTICALS } from "@/lib/verticals/config";

const navLinks = [
  { label: "How it works", href: "/#how" },
  { label: "Pricing", href: "/pricing" },
  { label: "About", href: "/about" },
  { label: "Blog", href: "/blog" },
];

export function Nav() {
  const [open, setOpen] = React.useState(false);
  return (
    <nav className="sticky top-0 z-50 w-full border-b border-ink-300/40 bg-pocket-cream/90 backdrop-blur-sm">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex h-16 items-center justify-between">
          <Link href="/"><Logo size="sm" /></Link>
          <div className="hidden md:flex items-center gap-6">
            {navLinks.map((link) => (
              <Link key={link.href} href={link.href} className="text-sm text-ink-700 hover:text-ink-900 transition-colors">{link.label}</Link>
            ))}
            <div className="group relative">
              <button className="text-sm text-ink-700 hover:text-ink-900 transition-colors">Verticals</button>
              <div className="absolute top-full left-0 mt-2 w-48 rounded-xl border border-ink-300/40 bg-white shadow-lg opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all">
                <div className="p-2">
                  {Object.values(VERTICALS).map((v) => (
                    <Link key={v.id} href={`/verticals/${v.id}`} className="flex items-center gap-2 px-3 py-2 text-sm text-ink-700 hover:bg-pocket-cream rounded-lg transition-colors">
                      <span>{v.emoji}</span><span>{v.label}</span>
                    </Link>
                  ))}
                </div>
              </div>
            </div>
          </div>
          <div className="hidden md:flex items-center gap-3">
            <Button variant="ghost" asChild><Link href="/login">Log in</Link></Button>
            <Button className="bg-pocket-orange hover:bg-pocket-orange-dark text-white" asChild><Link href="/free-audit">Get free audit</Link></Button>
          </div>
          <Sheet open={open} onOpenChange={setOpen}>
            <SheetTrigger asChild className="md:hidden">
              <Button variant="ghost" size="icon"><Menu className="h-5 w-5" /><span className="sr-only">Open menu</span></Button>
            </SheetTrigger>
            <SheetContent side="right" className="w-72 bg-pocket-cream">
              <div className="mt-6 flex flex-col gap-4">
                <Logo size="sm" className="mb-4" />
                {navLinks.map((link) => (
                  <Link key={link.href} href={link.href} onClick={() => setOpen(false)} className="text-base text-ink-900 font-medium">{link.label}</Link>
                ))}
                <div className="border-t border-ink-300/40 pt-4 mt-2">
                  <p className="text-xs text-ink-500 font-semibold uppercase tracking-wider mb-2">Verticals</p>
                  {Object.values(VERTICALS).map((v) => (
                    <Link key={v.id} href={`/verticals/${v.id}`} onClick={() => setOpen(false)} className="flex items-center gap-2 py-1.5 text-sm text-ink-700">
                      <span>{v.emoji}</span><span>{v.label}</span>
                    </Link>
                  ))}
                </div>
                <div className="border-t border-ink-300/40 pt-4 flex flex-col gap-2">
                  <Button variant="outline" asChild><Link href="/login" onClick={() => setOpen(false)}>Log in</Link></Button>
                  <Button className="bg-pocket-orange hover:bg-pocket-orange-dark text-white" asChild><Link href="/free-audit" onClick={() => setOpen(false)}>Get free audit</Link></Button>
                </div>
              </div>
            </SheetContent>
          </Sheet>
        </div>
      </div>
    </nav>
  );
}
HEREDOC

# ── components/marketing/Footer.tsx ──────────────────────────────────────────
cat > components/marketing/Footer.tsx << 'HEREDOC'
import Link from "next/link";
import { Camera, MessageCircle, ExternalLink } from "lucide-react";
import { Logo } from "@/components/brand/Logo";

const productLinks = [{ label: "Pricing", href: "/pricing" }, { label: "Free Audit", href: "/free-audit" }, { label: "Blog", href: "/blog" }, { label: "Verticals", href: "/#verticals" }];
const companyLinks = [{ label: "About", href: "/about" }, { label: "Contact", href: "mailto:hello@agencyinyourpocket.com" }, { label: "Privacy", href: "/privacy" }, { label: "Terms", href: "/terms" }];

export function Footer() {
  return (
    <footer className="bg-ink-900 text-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-10">
          <div className="flex flex-col gap-4">
            <Logo size="sm" className="[&_span]:text-white [&_.text-ink-900]:text-white" />
            <p className="text-ink-300 text-sm max-w-xs">Everything a real agency does — right in your pocket.</p>
            <div className="flex gap-4 mt-2">
              {[{ href: "https://instagram.com", icon: Camera, label: "Instagram" }, { href: "https://twitter.com", icon: MessageCircle, label: "Twitter" }, { href: "https://linkedin.com", icon: ExternalLink, label: "LinkedIn" }].map(({ href, icon: Icon, label }) => (
                <a key={label} href={href} target="_blank" rel="noopener noreferrer" aria-label={label} className="text-ink-500 hover:text-white transition-colors"><Icon className="h-5 w-5" /></a>
              ))}
            </div>
          </div>
          <div>
            <p className="text-xs text-ink-500 font-semibold uppercase tracking-wider mb-4">Product</p>
            <ul className="flex flex-col gap-2">{productLinks.map((l) => <li key={l.href}><Link href={l.href} className="text-sm text-ink-300 hover:text-white transition-colors">{l.label}</Link></li>)}</ul>
          </div>
          <div>
            <p className="text-xs text-ink-500 font-semibold uppercase tracking-wider mb-4">Company</p>
            <ul className="flex flex-col gap-2">{companyLinks.map((l) => <li key={l.href}><Link href={l.href} className="text-sm text-ink-300 hover:text-white transition-colors">{l.label}</Link></li>)}</ul>
          </div>
        </div>
        <div className="border-t border-ink-700 mt-12 pt-8 text-center">
          <p className="text-sm text-ink-500">© 2025 Agency in Your Pocket. Built with ❤ for small businesses.</p>
        </div>
      </div>
    </footer>
  );
}
HEREDOC

# ── components/marketing/Hero.tsx ────────────────────────────────────────────
cat > components/marketing/Hero.tsx << 'HEREDOC'
"use client";
import Link from "next/link";
import { motion } from "framer-motion";
import { Button } from "@/components/ui/button";
import { ArrowRight } from "lucide-react";

export function Hero() {
  return (
    <section className="relative overflow-hidden bg-pocket-cream py-24 md:py-32">
      <div aria-hidden className="absolute -top-40 -right-40 w-96 h-96 rounded-full bg-pocket-orange/10 blur-3xl" />
      <div aria-hidden className="absolute -bottom-20 -left-20 w-64 h-64 rounded-full bg-pocket-peach blur-2xl" />
      <div className="relative max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.6, ease: "easeOut" }}>
          <span className="inline-block text-xs font-semibold tracking-widest uppercase text-pocket-orange mb-6 border border-pocket-orange/30 rounded-full px-4 py-1.5 bg-pocket-peach">AI Agency Platform</span>
        </motion.div>
        <motion.h1 className="text-5xl md:text-7xl font-bold leading-tight tracking-tight" initial={{ opacity: 0, y: 24 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.6, ease: "easeOut", delay: 0.1 }}>
          <span className="text-ink-900">Everything a real agency does —</span><br />
          <span className="text-pocket-orange" style={{ fontFamily: "var(--font-fraunces)", fontStyle: "italic" }}>right in your pocket.</span>
        </motion.h1>
        <motion.p className="mt-8 text-lg md:text-xl text-ink-700 max-w-2xl mx-auto leading-relaxed" initial={{ opacity: 0, y: 24 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.6, ease: "easeOut", delay: 0.2 }}>
          Audits, branding, content, social media, SEO. All done for you by AI, guided by 10 years of agency expertise.
        </motion.p>
        <motion.div className="mt-10 flex flex-col sm:flex-row gap-4 justify-center items-center" initial={{ opacity: 0, y: 24 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.6, ease: "easeOut", delay: 0.3 }}>
          <Button size="lg" className="bg-pocket-orange hover:bg-pocket-orange-dark text-white px-8 h-12 text-base gap-2" asChild>
            <Link href="/free-audit">Get my free audit<ArrowRight className="h-4 w-4" /></Link>
          </Button>
          <Button size="lg" variant="outline" className="h-12 px-8 text-base" asChild><Link href="/pricing">See pricing</Link></Button>
        </motion.div>
        <motion.p className="mt-4 text-sm text-ink-500" initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ duration: 0.6, delay: 0.5 }}>No credit card. Takes 3 minutes. See what we&apos;d do.</motion.p>
        <motion.div className="mt-16 grid grid-cols-3 gap-4 max-w-lg mx-auto" initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.6, delay: 0.6 }}>
          {[{ value: "7", label: "Verticals" }, { value: "90s", label: "Free audit" }, { value: "$29", label: "Starting price" }].map((stat) => (
            <div key={stat.label} className="text-center p-4 rounded-xl bg-white shadow-sm">
              <p className="text-2xl font-bold text-pocket-orange">{stat.value}</p>
              <p className="text-xs text-ink-500 mt-1">{stat.label}</p>
            </div>
          ))}
        </motion.div>
      </div>
    </section>
  );
}
HEREDOC

# ── components/marketing/HowItWorks.tsx ──────────────────────────────────────
cat > components/marketing/HowItWorks.tsx << 'HEREDOC'
const steps = [
  { number: "1", title: "Tell us about your business", description: "We ask 10–15 quick questions. Your industry, your stage, your goals. Takes 3 minutes.", icon: "📝" },
  { number: "2", title: "Get your free audit — instantly", description: "We look at your website, your Instagram, your Google presence. In 90 seconds, you see what's working and what's broken.", icon: "🔍" },
  { number: "3", title: "We fix it. Every month.", description: "Subscribe and we'll execute. Brand, content, SEO — all done for you.", icon: "✅" },
];

export function HowItWorks() {
  return (
    <section id="how" className="py-24 bg-white">
      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-4xl font-bold text-ink-900">How it works</h2>
          <p className="mt-4 text-lg text-ink-700">Three steps. Ninety seconds to start.</p>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {steps.map((step, i) => (
            <div key={step.number} className="relative bg-pocket-cream rounded-2xl p-8 flex flex-col gap-4">
              {i < steps.length - 1 && <div aria-hidden className="hidden md:block absolute top-12 -right-4 w-8 h-px bg-ink-300 z-10" />}
              <span className="text-6xl font-bold leading-none" style={{ fontFamily: "var(--font-fraunces)", fontStyle: "italic", color: "#F97316" }}>{step.number}</span>
              <div className="text-3xl">{step.icon}</div>
              <h3 className="text-xl font-semibold text-ink-900">{step.title}</h3>
              <p className="text-ink-700 leading-relaxed">{step.description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
HEREDOC

# ── components/marketing/VerticalGrid.tsx ────────────────────────────────────
cat > components/marketing/VerticalGrid.tsx << 'HEREDOC'
import Link from "next/link";
import { ArrowRight } from "lucide-react";
import { VERTICALS } from "@/lib/verticals/config";

export function VerticalGrid() {
  return (
    <section id="verticals" className="py-24 bg-pocket-cream">
      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-4xl font-bold text-ink-900">Built for your industry</h2>
          <p className="mt-4 text-lg text-ink-700">Not generic AI. We know your business.</p>
        </div>
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4">
          {Object.values(VERTICALS).map((v) => (
            <Link key={v.id} href={`/verticals/${v.id}`}
              className="group relative flex flex-col gap-3 p-6 rounded-2xl border-2 border-transparent transition-all duration-200 hover:-translate-y-1 hover:shadow-lg"
              style={{ backgroundColor: `${v.color}18` }}
              onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.borderColor = v.color; }}
              onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.borderColor = "transparent"; }}>
              <span className="text-4xl">{v.emoji}</span>
              <div>
                <p className="font-semibold text-ink-900 text-sm">{v.label}</p>
                <p className="text-xs text-ink-500 mt-1 leading-relaxed line-clamp-2">{v.shortDescription}</p>
              </div>
              <span className="inline-flex items-center gap-1 text-xs font-medium mt-auto opacity-0 group-hover:opacity-100 transition-opacity" style={{ color: v.color }}>
                Learn more <ArrowRight className="h-3 w-3" />
              </span>
            </Link>
          ))}
        </div>
      </div>
    </section>
  );
}
HEREDOC

# ── components/marketing/PricingTiers.tsx ────────────────────────────────────
cat > components/marketing/PricingTiers.tsx << 'HEREDOC'
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
HEREDOC

# ── components/marketing/FAQ.tsx ──────────────────────────────────────────────
cat > components/marketing/FAQ.tsx << 'HEREDOC'
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion";

const faqs = [
  { q: "Is this actually AI or just templates?", a: "It's real AI — we use Claude (Anthropic), GPT-4, and Ideogram to generate content specific to your business, vertical, and goals. Not templates." },
  { q: "How is this different from just using ChatGPT?", a: "ChatGPT gives you text. We give you outcomes. We orchestrate 6+ APIs, handle the workflow, format the deliverables, and keep it updated every month." },
  { q: "What happens after I get the free audit?", a: "You see your brand score and top issues. Sign up for the full 20+ item audit, a personalized 90-day growth plan, and we start executing right away." },
  { q: "Do I need to connect my Instagram or Google account?", a: "Not to start. The free audit works with just your website or Instagram handle. Connecting accounts later unlocks more powerful features." },
  { q: "Can I cancel anytime?", a: "Yes. No contracts, no fees. Cancel directly from your billing settings. Your deliverables are yours to keep." },
  { q: "Do you support businesses outside the 7 verticals?", a: "Yes — our 'Something else' vertical covers any business type with general brand-building workflows." },
];

export function FAQ() {
  return (
    <section className="py-24 bg-pocket-cream">
      <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-12"><h2 className="text-4xl font-bold text-ink-900">Frequently asked questions</h2></div>
        <Accordion type="single" collapsible className="space-y-2">
          {faqs.map((faq, i) => (
            <AccordionItem key={i} value={`item-${i}`} className="bg-white rounded-xl px-6 border-none shadow-sm">
              <AccordionTrigger className="text-left text-ink-900 font-medium hover:no-underline">{faq.q}</AccordionTrigger>
              <AccordionContent className="text-ink-700 leading-relaxed">{faq.a}</AccordionContent>
            </AccordionItem>
          ))}
        </Accordion>
      </div>
    </section>
  );
}
HEREDOC

# ── components/marketing/FinalCTA.tsx ────────────────────────────────────────
cat > components/marketing/FinalCTA.tsx << 'HEREDOC'
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
HEREDOC

# ── components/audit/FreeAuditForm.tsx ───────────────────────────────────────
cat > components/audit/FreeAuditForm.tsx << 'HEREDOC'
"use client";
import * as React from "react";
import { useRouter } from "next/navigation";
import { ArrowRight, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { VERTICALS } from "@/lib/verticals/config";

export function FreeAuditForm() {
  const router = useRouter();
  const [loading, setLoading] = React.useState(false);
  const [error, setError] = React.useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault(); setError(null);
    const data = new FormData(e.currentTarget);
    const email = data.get("email") as string;
    const businessName = data.get("businessName") as string;
    const websiteUrl = data.get("websiteUrl") as string;
    const vertical = data.get("vertical") as string;
    if (!email || !businessName || !vertical) { setError("Please fill in all required fields."); return; }
    setLoading(true);
    try {
      const res = await fetch("/api/free-audit/start", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ email, businessName, websiteUrl, vertical }) });
      if (!res.ok) throw new Error("Failed to start audit");
      const { auditId } = (await res.json()) as { auditId: string };
      router.push(`/free-audit/analyzing?id=${auditId}`);
    } catch { setError("Something went wrong. Please try again."); setLoading(false); }
  }

  return (
    <form onSubmit={handleSubmit} className="bg-white rounded-2xl shadow-sm border border-ink-200 p-8 flex flex-col gap-5">
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="email">Your email <span className="text-pocket-orange">*</span></Label>
        <Input id="email" name="email" type="email" placeholder="you@yourbusiness.com" required />
      </div>
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="businessName">Business name <span className="text-pocket-orange">*</span></Label>
        <Input id="businessName" name="businessName" type="text" placeholder="Sunrise Cafe" required />
      </div>
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="websiteUrl">Website URL or Instagram handle</Label>
        <Input id="websiteUrl" name="websiteUrl" type="text" placeholder="https://yourbusiness.com or @yourhandle" />
      </div>
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="vertical">What do you do? <span className="text-pocket-orange">*</span></Label>
        <Select name="vertical" required>
          <SelectTrigger id="vertical"><SelectValue placeholder="Select your business type" /></SelectTrigger>
          <SelectContent>{Object.values(VERTICALS).map((v) => <SelectItem key={v.id} value={v.id}>{v.emoji} {v.label}</SelectItem>)}</SelectContent>
        </Select>
      </div>
      {error && <p className="text-sm text-red-600 bg-red-50 rounded-lg px-4 py-3">{error}</p>}
      <Button type="submit" disabled={loading} className="bg-pocket-orange hover:bg-pocket-orange-dark text-white h-12 text-base gap-2 mt-2">
        {loading ? <><Loader2 className="h-4 w-4 animate-spin" />Starting…</> : <>Analyze my brand<ArrowRight className="h-4 w-4" /></>}
      </Button>
    </form>
  );
}
HEREDOC

# ── components/audit/AnalyzingScreen.tsx ─────────────────────────────────────
cat > components/audit/AnalyzingScreen.tsx << 'HEREDOC'
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
HEREDOC

# ── components/audit/TeaserResult.tsx ────────────────────────────────────────
cat > components/audit/TeaserResult.tsx << 'HEREDOC'
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
HEREDOC

# ── components/app/AppNav.tsx ─────────────────────────────────────────────────
cat > components/app/AppNav.tsx << 'HEREDOC'
"use client";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Bell, LogOut, Settings, User, ShieldCheck } from "lucide-react";
import { Logo } from "@/components/brand/Logo";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuSeparator, DropdownMenuTrigger } from "@/components/ui/dropdown-menu";
import { createClient } from "@/lib/supabase/client";

interface AppNavProps { fullName: string | null; email: string; isAdmin: boolean; }

export function AppNav({ fullName, email, isAdmin }: AppNavProps) {
  const router = useRouter();
  async function handleLogout() { const supabase = createClient(); await supabase.auth.signOut(); router.push("/login"); router.refresh(); }
  const initials = fullName ? fullName.split(" ").map((p) => p[0]).join("").toUpperCase().slice(0, 2) : email.slice(0, 2).toUpperCase();
  return (
    <header className="sticky top-0 z-40 h-14 border-b border-ink-200 bg-white/90 backdrop-blur-sm">
      <div className="flex h-full items-center justify-between px-4 max-w-screen-2xl mx-auto">
        <Link href="/dashboard"><Logo size="sm" /></Link>
        <div className="flex items-center gap-2">
          <button className="relative p-2 rounded-lg hover:bg-ink-100 transition-colors"><Bell className="w-4 h-4 text-ink-500" /></button>
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <button className="flex items-center gap-2 rounded-lg px-2 py-1.5 hover:bg-ink-100 transition-colors">
                <Avatar className="w-7 h-7"><AvatarFallback className="bg-pocket-orange text-white text-xs font-semibold">{initials}</AvatarFallback></Avatar>
                <span className="hidden sm:block text-sm font-medium text-ink-700 max-w-[140px] truncate">{fullName ?? email}</span>
              </button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-52">
              <div className="px-3 py-2"><p className="text-sm font-medium text-ink-900 truncate">{fullName ?? "Account"}</p><p className="text-xs text-ink-500 truncate">{email}</p></div>
              <DropdownMenuSeparator />
              <DropdownMenuItem asChild><Link href="/settings/profile" className="flex items-center gap-2"><User className="w-4 h-4" />Profile</Link></DropdownMenuItem>
              <DropdownMenuItem asChild><Link href="/settings/billing" className="flex items-center gap-2"><Settings className="w-4 h-4" />Billing</Link></DropdownMenuItem>
              {isAdmin && (<><DropdownMenuSeparator /><DropdownMenuItem asChild><Link href="/admin" className="flex items-center gap-2 text-pocket-orange"><ShieldCheck className="w-4 h-4" />Admin</Link></DropdownMenuItem></>)}
              <DropdownMenuSeparator />
              <DropdownMenuItem onClick={handleLogout} className="flex items-center gap-2 text-red-600 focus:text-red-600"><LogOut className="w-4 h-4" />Log out</DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>
    </header>
  );
}
HEREDOC

# ── components/app/Sidebar.tsx ────────────────────────────────────────────────
cat > components/app/Sidebar.tsx << 'HEREDOC'
"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { LayoutDashboard, FolderOpen, Settings, Zap } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { VERTICALS, type VerticalSlug } from "@/lib/verticals/config";

const NAV_ITEMS = [{ href: "/dashboard", label: "Dashboard", icon: LayoutDashboard }, { href: "/deliverables", label: "Deliverables", icon: FolderOpen }, { href: "/settings/profile", label: "Settings", icon: Settings }];

export function Sidebar({ businessName, vertical, planTier }: { businessName: string; vertical: VerticalSlug; planTier: string }) {
  const pathname = usePathname();
  const v = VERTICALS[vertical];
  return (
    <aside className="hidden md:flex flex-col w-56 shrink-0 border-r border-ink-200 bg-white min-h-0">
      <div className="px-4 py-4 border-b border-ink-100">
        <div className="flex items-center gap-2 mb-1"><span className="text-lg">{v?.emoji}</span><span className="text-sm font-semibold text-ink-900 truncate">{businessName}</span></div>
        <div className="flex items-center gap-1.5"><span className="inline-block w-2 h-2 rounded-full" style={{ backgroundColor: v?.color ?? "#F97316" }} /><span className="text-xs text-ink-500">{v?.label}</span></div>
      </div>
      <nav className="flex-1 px-2 py-3 flex flex-col gap-0.5">
        {NAV_ITEMS.map(({ href, label, icon: Icon }) => {
          const active = pathname === href || (href !== "/dashboard" && pathname.startsWith(href));
          return (
            <Link key={href} href={href} className={`flex items-center gap-2.5 rounded-lg px-3 py-2 text-sm transition-colors ${active ? "bg-pocket-peach text-pocket-orange font-medium" : "text-ink-700 hover:bg-ink-100"}`}>
              <Icon className="w-4 h-4 shrink-0" />{label}
            </Link>
          );
        })}
      </nav>
      <div className="px-4 py-4 border-t border-ink-100">
        <div className="flex items-center justify-between">
          <span className="text-xs text-ink-500">Plan</span>
          <Badge variant={planTier === "free" ? "secondary" : "default"} className="capitalize text-xs">{planTier === "free" ? "Free" : planTier}</Badge>
        </div>
        {planTier === "free" && <Link href="/settings/billing" className="mt-2 flex items-center gap-1 text-xs text-pocket-orange hover:underline font-medium"><Zap className="w-3 h-3" />Upgrade for full access</Link>}
      </div>
    </aside>
  );
}
HEREDOC

# ── components/app/BillingSuccessNotifier.tsx ────────────────────────────────
cat > components/app/BillingSuccessNotifier.tsx << 'HEREDOC'
"use client";
import { useEffect } from "react";
import { useToast } from "@/hooks/use-toast";

export function BillingSuccessNotifier() {
  const { toast } = useToast();
  useEffect(() => {
    if (typeof window !== "undefined") {
      const params = new URLSearchParams(window.location.search);
      if (params.get("success") === "1") {
        toast({ title: "Plan upgraded!", description: "Your subscription is now active. Welcome to the next level." });
        const url = new URL(window.location.href);
        url.searchParams.delete("success");
        window.history.replaceState({}, "", url.toString());
      }
    }
  }, [toast]);
  return null;
}
HEREDOC

# ── components/app/GrowthPlanKanban.tsx ──────────────────────────────────────
cat > components/app/GrowthPlanKanban.tsx << 'HEREDOC'
import { TaskCard } from "./TaskCard";

type TaskStatus = "not_started" | "in_progress" | "review" | "complete";
interface Task { id: string; title: string; description: string | null; workflow_ref: string | null; phase: string | null; status: TaskStatus; }

const COLUMNS: { status: TaskStatus; label: string; color: string }[] = [
  { status: "not_started", label: "To do", color: "bg-ink-200" },
  { status: "in_progress", label: "In progress", color: "bg-blue-400" },
  { status: "review", label: "Review", color: "bg-amber-400" },
  { status: "complete", label: "Complete", color: "bg-emerald-400" },
];

export function GrowthPlanKanban({ tasks }: { tasks: Task[] }) {
  const byStatus = (s: TaskStatus) => tasks.filter((t) => t.status === s);
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 overflow-x-auto pb-2">
      {COLUMNS.map(({ status, label, color }) => {
        const columnTasks = byStatus(status);
        return (
          <div key={status} className="min-w-[220px]">
            <div className="flex items-center gap-2 mb-3">
              <span className={`w-2 h-2 rounded-full ${color}`} />
              <span className="text-sm font-semibold text-ink-700">{label}</span>
              <span className="ml-auto text-xs text-ink-400 bg-ink-100 rounded-full px-2 py-0.5">{columnTasks.length}</span>
            </div>
            <div className="flex flex-col gap-3">
              {columnTasks.map((task) => <TaskCard key={task.id} {...task} />)}
              {columnTasks.length === 0 && <div className="rounded-xl border-2 border-dashed border-ink-200 px-4 py-6 text-center"><p className="text-xs text-ink-400">Nothing here yet</p></div>}
            </div>
          </div>
        );
      })}
    </div>
  );
}
HEREDOC

# ── components/app/TaskCard.tsx ──────────────────────────────────────────────
cat > components/app/TaskCard.tsx << 'HEREDOC'
"use client";
import { useRouter } from "next/navigation";
import { ArrowRight, CheckCircle2, Eye } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { updateTaskStatus } from "@/app/(app)/dashboard/actions";

type TaskStatus = "not_started" | "in_progress" | "review" | "complete";
interface TaskCardProps { id: string; title: string; description: string | null; workflow_ref: string | null; phase: string | null; status: TaskStatus; }

const phaseLabels: Record<string, string> = { "week-1": "Week 1", "week-2": "Week 2", "weeks-3-4": "Weeks 3–4", "month-2": "Month 2", "month-3": "Month 3", "ongoing": "Ongoing" };

export function TaskCard({ id, title, description, workflow_ref, phase, status }: TaskCardProps) {
  const router = useRouter();
  async function handleStart() {
    if (workflow_ref) { router.push(`/workflow/${workflow_ref}?taskId=${id}`); }
    else { await updateTaskStatus(id, "in_progress"); router.refresh(); }
  }
  async function handleComplete() { await updateTaskStatus(id, "complete"); router.refresh(); }

  return (
    <div className="bg-white rounded-xl border border-ink-200 p-4 flex flex-col gap-3 hover:shadow-sm transition-shadow">
      <div className="flex items-start justify-between gap-2">
        <h3 className="text-sm font-semibold text-ink-900 leading-snug">{title}</h3>
        {phase && <span className="shrink-0 text-[10px] font-medium text-ink-400 bg-ink-100 rounded px-1.5 py-0.5">{phaseLabels[phase] ?? phase}</span>}
      </div>
      {description && <p className="text-xs text-ink-500 leading-relaxed line-clamp-2">{description}</p>}
      <div className="flex items-center justify-between mt-auto pt-1">
        {workflow_ref ? <Badge variant="secondary" className="text-[10px] gap-1"><span className="w-1.5 h-1.5 rounded-full bg-pocket-orange inline-block" />AI workflow</Badge> : <div />}
        {status === "not_started" && <Button size="sm" onClick={handleStart} className="h-7 text-xs gap-1 bg-pocket-orange hover:bg-pocket-orange-dark text-white">Start<ArrowRight className="w-3 h-3" /></Button>}
        {status === "in_progress" && <Button size="sm" variant="outline" onClick={handleComplete} className="h-7 text-xs gap-1"><CheckCircle2 className="w-3 h-3" />Done</Button>}
        {status === "review" && <Button size="sm" variant="outline" onClick={handleComplete} className="h-7 text-xs gap-1"><Eye className="w-3 h-3" />Mark complete</Button>}
        {status === "complete" && <span className="flex items-center gap-1 text-xs text-emerald-600 font-medium"><CheckCircle2 className="w-3.5 h-3.5" />Done</span>}
      </div>
    </div>
  );
}
HEREDOC

# ── components/app/DeliverableCard.tsx ───────────────────────────────────────
cat > components/app/DeliverableCard.tsx << 'HEREDOC'
import Link from "next/link";
import { Download, FileText, Image, Calendar, BarChart3, Type, Package } from "lucide-react";
import { Badge } from "@/components/ui/badge";

type DeliverableType = "audit" | "brand_kit" | "content_calendar" | "reel_scripts" | "website_copy" | "other";
interface DeliverableCardProps { id: string; title: string; type: DeliverableType; file_url: string | null; created_at: string; }

const TYPE_CONFIG: Record<DeliverableType, { label: string; icon: React.ComponentType<{ className?: string }>; color: string }> = {
  audit: { label: "Brand Audit", icon: BarChart3, color: "bg-blue-50 text-blue-700" },
  brand_kit: { label: "Brand Kit", icon: Package, color: "bg-pocket-peach text-pocket-orange" },
  content_calendar: { label: "Content Calendar", icon: Calendar, color: "bg-emerald-50 text-emerald-700" },
  reel_scripts: { label: "Reel Scripts", icon: Image, color: "bg-purple-50 text-purple-700" },
  website_copy: { label: "Website Copy", icon: Type, color: "bg-amber-50 text-amber-700" },
  other: { label: "Document", icon: FileText, color: "bg-ink-100 text-ink-700" },
};

export function DeliverableCard({ id, title, type, file_url, created_at }: DeliverableCardProps) {
  const config = TYPE_CONFIG[type] ?? TYPE_CONFIG.other;
  const Icon = config.icon;
  const date = new Date(created_at).toLocaleDateString("en-GB", { day: "numeric", month: "short", year: "numeric" });
  return (
    <Link href={`/deliverables/${id}`}>
      <div className="bg-white rounded-xl border border-ink-200 p-4 hover:shadow-sm hover:border-ink-300 transition-all flex flex-col gap-3">
        <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${config.color}`}><Icon className="w-5 h-5" /></div>
        <div className="flex-1"><p className="text-sm font-semibold text-ink-900 leading-snug">{title}</p><p className="text-xs text-ink-400 mt-0.5">{date}</p></div>
        <div className="flex items-center justify-between">
          <Badge variant="secondary" className="text-[10px]">{config.label}</Badge>
          {file_url && <a href={file_url} download onClick={(e) => e.stopPropagation()} className="p-1.5 rounded-lg hover:bg-ink-100 transition-colors"><Download className="w-3.5 h-3.5 text-ink-400" /></a>}
        </div>
      </div>
    </Link>
  );
}
HEREDOC

# ── components/app/WorkflowRunner.tsx ────────────────────────────────────────
cat > components/app/WorkflowRunner.tsx << 'HEREDOC'
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
HEREDOC

# ── components/app/OnboardingWizard.tsx — written separately due to length ───
# (see next block)

echo "Part 5a done ✓ — now paste Part 5b for OnboardingWizard"


