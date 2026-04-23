"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { LayoutDashboard, FolderOpen, Settings, Zap } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { VERTICALS, type VerticalSlug } from "@/lib/verticals/config";

const NAV_ITEMS = [{ href: "/dashboard", label: "Dashboard", icon: LayoutDashboard }, { href: "/deliverables", label: "Deliverables", icon: FolderOpen }, { href: "/settings/profile", label: "Settings", icon: Settings }];

export function Sidebar({ businessName, vertical, planTier }: { businessName: string; vertical: VerticalSlug; planTier: string }) {
  const pathname = usePathname();
  const v = VERTICALS[vertical];
  return (
    <aside className="hidden md:flex flex-col w-56 shrink-0 border-r border-ink-200 bg-white min-h-0">
      <div className="px-4 py-4 border-b border-ink-100">
        <div className="flex items-center gap-2 mb-1"><span className="text-lg">{v?.emoji}</span><span className="text-sm font-semibold text-ink-900 truncate">{businessName}</span></div>
        <div className="flex items-center gap-1.5"><span className="inline-block w-2 h-2 rounded-full" style={{ backgroundColor: v?.color ?? "#F97316" }} /><span className="text-xs text-ink-500">{v?.label}</span></div>
      </div>
      <nav className="flex-1 px-2 py-3 flex flex-col gap-0.5">
        {NAV_ITEMS.map(({ href, label, icon: Icon }) => {
          const active = pathname === href || (href !== "/dashboard" && pathname.startsWith(href));
          return (
            <Link key={href} href={href} className={`flex items-center gap-2.5 rounded-lg px-3 py-2 text-sm transition-colors ${active ? "bg-pocket-peach text-pocket-orange font-medium" : "text-ink-700 hover:bg-ink-100"}`}>
              <Icon className="w-4 h-4 shrink-0" />{label}
            </Link>
          );
        })}
      </nav>
      <div className="px-4 py-4 border-t border-ink-100">
        <div className="flex items-center justify-between">
          <span className="text-xs text-ink-500">Plan</span>
          <Badge variant={planTier === "free" ? "secondary" : "default"} className="capitalize text-xs">{planTier === "free" ? "Free" : planTier}</Badge>
        </div>
        {planTier === "free" && <Link href="/settings/billing" className="mt-2 flex items-center gap-1 text-xs text-pocket-orange hover:underline font-medium"><Zap className="w-3 h-3" />Upgrade for full access</Link>}
      </div>
    </aside>
  );
}
