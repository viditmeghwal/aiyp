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
