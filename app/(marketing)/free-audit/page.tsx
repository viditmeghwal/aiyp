import type { Metadata } from "next";
import { FreeAuditForm } from "@/components/audit/FreeAuditForm";

export const metadata: Metadata = {
  title: "Free Brand Audit",
  description: "See what an agency would charge $2,000 to tell you. Give us 3 things. We'll show you what's working, what's broken, and exactly what to fix.",
};

export default function FreeAuditPage() {
  return (
    <section className="py-24 bg-pocket-cream min-h-screen">
      <div className="max-w-xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-10">
          <span className="text-4xl mb-4 block">🔍</span>
          <h1 className="text-4xl font-bold text-ink-900">
            See what an agency would charge{" "}
            <span className="text-pocket-orange" style={{ fontFamily: "var(--font-fraunces)", fontStyle: "italic" }}>$2,000</span>{" "}
            to tell you.
          </h1>
          <p className="mt-4 text-lg text-ink-700">Give us three things. We&apos;ll show you what&apos;s working, what&apos;s broken, and exactly what to fix.</p>
        </div>
        <FreeAuditForm />
        <p className="mt-6 text-center text-sm text-ink-500">We&apos;ll email you the full audit. Takes 90 seconds. No spam.</p>
      </div>
    </section>
  );
}
