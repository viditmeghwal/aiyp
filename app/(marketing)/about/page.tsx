import type { Metadata } from "next";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { PoweredByBar } from "@/components/brand/PoweredByBar";

export const metadata: Metadata = {
  title: "About",
  description: "We built Agency in Your Pocket because we got tired of watching good businesses fail at branding.",
};

export default function AboutPage() {
  return (
    <>
      <section className="py-24 bg-pocket-cream">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
          <h1 className="text-5xl font-bold text-ink-900 mb-8">
            We built this because we got tired of watching good businesses fail at{" "}
            <span className="text-pocket-orange" style={{ fontFamily: "var(--font-fraunces)", fontStyle: "italic" }}>
              branding.
            </span>
          </h1>
          <div className="prose prose-lg max-w-none text-ink-700 space-y-6">
            <p>Ten years running an agency. Cafes, jewellery brands, hotels, factories. Same story every time: great product, terrible brand presence.</p>
            <p>Real agencies cost $2,000+/month. Tools overwhelm. Generic AI produces generic output. So we built what we wished existed.</p>
            <p className="font-semibold text-ink-900">Every founder deserves agency-quality work. That&apos;s why we exist.</p>
          </div>
          <div className="mt-12 flex gap-4">
            <Button className="bg-pocket-orange hover:bg-pocket-orange-dark text-white" asChild>
              <Link href="/free-audit">Get my free audit →</Link>
            </Button>
            <Button variant="outline" asChild><Link href="/pricing">See pricing</Link></Button>
          </div>
        </div>
      </section>
      <PoweredByBar />
    </>
  );
}
