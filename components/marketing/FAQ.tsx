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
