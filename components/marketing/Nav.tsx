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
