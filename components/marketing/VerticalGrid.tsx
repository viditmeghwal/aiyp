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
