import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { CheckCircle, ArrowRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { VERTICALS, type VerticalSlug } from "@/lib/verticals/config";

export function generateStaticParams() {
  return Object.keys(VERTICALS).map((vertical) => ({ vertical }));
}

export function generateMetadata({ params }: { params: { vertical: string } }): Metadata {
  const v = VERTICALS[params.vertical as VerticalSlug];
  if (!v) return {};
  return { title: `${v.label} — Agency in Your Pocket`, description: v.shortDescription };
}

export default function VerticalPage({ params }: { params: { vertical: string } }) {
  const v = VERTICALS[params.vertical as VerticalSlug];
  if (!v) notFound();
  return (
    <>
      <section className="py-24" style={{ backgroundColor: `${v.color}18` }}>
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <span className="text-6xl mb-6 block">{v.emoji}</span>
          <h1 className="text-4xl md:text-5xl font-bold text-ink-900">{v.heroHeadline}</h1>
          <p className="mt-6 text-lg md:text-xl text-ink-700">{v.heroSubline}</p>
          <div className="mt-10">
            <Button size="lg" className="text-white px-8 h-12 text-base gap-2" style={{ backgroundColor: v.color }} asChild>
              <Link href="/free-audit">Get my free audit <ArrowRight className="h-4 w-4" /></Link>
            </Button>
          </div>
        </div>
      </section>
      <section className="py-20 bg-white">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl font-bold text-ink-900 text-center mb-12">Sound familiar?</h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {v.painPoints.map((pain) => (
              <div key={pain} className="flex items-start gap-3 p-5 rounded-xl bg-pocket-cream border border-ink-200">
                <span className="text-xl mt-0.5">😤</span>
                <p className="text-ink-700">{pain}</p>
              </div>
            ))}
          </div>
        </div>
      </section>
      <section className="py-20" style={{ backgroundColor: `${v.color}10` }}>
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl font-bold text-ink-900 text-center mb-12">What you&apos;ll build</h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {v.goals.map((goal) => (
              <div key={goal} className="flex items-start gap-3 p-4 bg-white rounded-xl shadow-sm">
                <CheckCircle className="h-5 w-5 mt-0.5 flex-shrink-0" style={{ color: v.color }} />
                <p className="text-sm text-ink-700">{goal}</p>
              </div>
            ))}
          </div>
        </div>
      </section>
      <section className="py-20 text-white" style={{ backgroundColor: v.color }}>
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-3xl md:text-4xl font-bold">Ready to build your {v.label} brand?</h2>
          <div className="mt-8">
            <Button size="lg" className="bg-white text-ink-900 hover:bg-white/90 px-8 h-12 text-base" asChild>
              <Link href="/free-audit">Get free audit →</Link>
            </Button>
          </div>
        </div>
      </section>
    </>
  );
}
