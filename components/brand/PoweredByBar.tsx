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
