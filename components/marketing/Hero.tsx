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
