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
