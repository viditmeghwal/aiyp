import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import Link from "next/link";
import { Logo } from "@/components/brand/Logo";
import { LayoutDashboard, Users, Zap, Building2 } from "lucide-react";

const ADMIN_NAV = [
  { href: "/admin", label: "Overview", icon: LayoutDashboard },
  { href: "/admin/users", label: "Users", icon: Users },
  { href: "/admin/businesses", label: "Businesses", icon: Building2 },
  { href: "/admin/runs", label: "Workflow Runs", icon: Zap },
];

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: profile } = await supabase.from("profiles").select("is_admin").eq("id", user.id).single();
  if (!profile?.is_admin) redirect("/dashboard");

  return (
    <div className="flex min-h-screen bg-ink-100">
      <aside className="w-52 shrink-0 bg-ink-900 flex flex-col">
        <div className="px-4 py-4 border-b border-ink-700">
          <Logo size="sm" />
          <span className="text-xs text-ink-400 font-mono mt-1 block">admin</span>
        </div>
        <nav className="flex-1 px-2 py-3 flex flex-col gap-0.5">
          {ADMIN_NAV.map(({ href, label, icon: Icon }) => (
            <Link key={href} href={href} className="flex items-center gap-2.5 rounded-lg px-3 py-2 text-sm text-ink-300 hover:bg-ink-800 hover:text-white transition-colors">
              <Icon className="w-4 h-4 shrink-0" />{label}
            </Link>
          ))}
        </nav>
        <div className="px-4 py-3 border-t border-ink-700">
          <Link href="/dashboard" className="text-xs text-ink-500 hover:text-ink-300">← Back to app</Link>
        </div>
      </aside>
      <main className="flex-1 overflow-auto p-8">{children}</main>
    </div>
  );
}
